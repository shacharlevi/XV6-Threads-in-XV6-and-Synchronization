
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
    80000068:	4cc78793          	addi	a5,a5,1228 # 80006530 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc047f>
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
    80000130:	5b4080e7          	jalr	1460(ra) # 800026e0 <either_copyin>
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
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	818080e7          	jalr	-2024(ra) # 800019d8 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	362080e7          	jalr	866(ra) # 8000252a <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f96080e7          	jalr	-106(ra) # 8000216c <sleep>
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
    80000216:	476080e7          	jalr	1142(ra) # 80002688 <either_copyout>
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
    800002f6:	446080e7          	jalr	1094(ra) # 80002738 <procdump>
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
    8000044a:	d8a080e7          	jalr	-630(ra) # 800021d0 <wakeup>
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
    80000478:	0003d797          	auipc	a5,0x3d
    8000047c:	d7078793          	addi	a5,a5,-656 # 8003d1e8 <devsw>
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
    80000896:	93e080e7          	jalr	-1730(ra) # 800021d0 <wakeup>
    
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
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	850080e7          	jalr	-1968(ra) # 8000216c <sleep>
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
    800009fe:	0003e797          	auipc	a5,0x3e
    80000a02:	98278793          	addi	a5,a5,-1662 # 8003e380 <end>
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
    80000ace:	0003e517          	auipc	a0,0x3e
    80000ad2:	8b250513          	addi	a0,a0,-1870 # 8003e380 <end>
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
    80000b74:	e4c080e7          	jalr	-436(ra) # 800019bc <mycpu>
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
    80000ba6:	e1a080e7          	jalr	-486(ra) # 800019bc <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	e0e080e7          	jalr	-498(ra) # 800019bc <mycpu>
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
    80000bca:	df6080e7          	jalr	-522(ra) # 800019bc <mycpu>
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
    80000c0a:	db6080e7          	jalr	-586(ra) # 800019bc <mycpu>
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
    80000c36:	d8a080e7          	jalr	-630(ra) # 800019bc <mycpu>
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
    80000e84:	b2c080e7          	jalr	-1236(ra) # 800019ac <cpuid>
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
    80000ea0:	b10080e7          	jalr	-1264(ra) # 800019ac <cpuid>
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
    80000ec2:	f0c080e7          	jalr	-244(ra) # 80002dca <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	6aa080e7          	jalr	1706(ra) # 80006570 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	076080e7          	jalr	118(ra) # 80001f44 <scheduler>
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
    80000f32:	9f0080e7          	jalr	-1552(ra) # 8000191e <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	e6c080e7          	jalr	-404(ra) # 80002da2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	e8c080e7          	jalr	-372(ra) # 80002dca <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	614080e7          	jalr	1556(ra) # 8000655a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	622080e7          	jalr	1570(ra) # 80006570 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	738080e7          	jalr	1848(ra) # 8000368e <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	ddc080e7          	jalr	-548(ra) # 80003d3a <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	d7e080e7          	jalr	-642(ra) # 80004ce4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	70a080e7          	jalr	1802(ra) # 80006678 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d5a080e7          	jalr	-678(ra) # 80001cd0 <userinit>
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
    80001836:	711d                	addi	sp,sp,-96
    80001838:	ec86                	sd	ra,88(sp)
    8000183a:	e8a2                	sd	s0,80(sp)
    8000183c:	e4a6                	sd	s1,72(sp)
    8000183e:	e0ca                	sd	s2,64(sp)
    80001840:	fc4e                	sd	s3,56(sp)
    80001842:	f852                	sd	s4,48(sp)
    80001844:	f456                	sd	s5,40(sp)
    80001846:	f05a                	sd	s6,32(sp)
    80001848:	ec5e                	sd	s7,24(sp)
    8000184a:	e862                	sd	s8,16(sp)
    8000184c:	e466                	sd	s9,8(sp)
    8000184e:	e06a                	sd	s10,0(sp)
    80001850:	1080                	addi	s0,sp,96
    80001852:	8b2a                	mv	s6,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	00010997          	auipc	s3,0x10
    80001858:	ef498993          	addi	s3,s3,-268 # 80011748 <proc+0x7a8>
    8000185c:	00032d17          	auipc	s10,0x32
    80001860:	eecd0d13          	addi	s10,s10,-276 # 80033748 <bcache+0x790>
    for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++) {
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      uint64 va = KSTACK((int) ((p - proc) * NKT + (kt - p->kthread)));
    80001864:	0000fc97          	auipc	s9,0xf
    80001868:	73cc8c93          	addi	s9,s9,1852 # 80010fa0 <proc>
    8000186c:	00006c17          	auipc	s8,0x6
    80001870:	794c3c03          	ld	s8,1940(s8) # 80008000 <etext>
    80001874:	00006b97          	auipc	s7,0x6
    80001878:	794b8b93          	addi	s7,s7,1940 # 80008008 <etext+0x8>
    8000187c:	04000ab7          	lui	s5,0x4000
    80001880:	1afd                	addi	s5,s5,-1
    80001882:	0ab2                	slli	s5,s5,0xc
    80001884:	a839                	j	800018a2 <proc_mapstacks+0x6c>
        panic("kalloc");
    80001886:	00007517          	auipc	a0,0x7
    8000188a:	95250513          	addi	a0,a0,-1710 # 800081d8 <digits+0x198>
    8000188e:	fffff097          	auipc	ra,0xfffff
    80001892:	cb0080e7          	jalr	-848(ra) # 8000053e <panic>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001896:	6785                	lui	a5,0x1
    80001898:	88078793          	addi	a5,a5,-1920 # 880 <_entry-0x7ffff780>
    8000189c:	99be                	add	s3,s3,a5
    8000189e:	07a98263          	beq	s3,s10,80001902 <proc_mapstacks+0xcc>
    for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++) {
    800018a2:	88098a13          	addi	s4,s3,-1920
      uint64 va = KSTACK((int) ((p - proc) * NKT + (kt - p->kthread)));
    800018a6:	85898793          	addi	a5,s3,-1960
    800018aa:	419787b3          	sub	a5,a5,s9
    800018ae:	879d                	srai	a5,a5,0x7
    800018b0:	038787b3          	mul	a5,a5,s8
    800018b4:	0027991b          	slliw	s2,a5,0x2
    800018b8:	00f9093b          	addw	s2,s2,a5
    800018bc:	0019191b          	slliw	s2,s2,0x1
    for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++) {
    800018c0:	84d2                	mv	s1,s4
      char *pa = kalloc();
    800018c2:	fffff097          	auipc	ra,0xfffff
    800018c6:	224080e7          	jalr	548(ra) # 80000ae6 <kalloc>
    800018ca:	862a                	mv	a2,a0
      if(pa == 0)
    800018cc:	dd4d                	beqz	a0,80001886 <proc_mapstacks+0x50>
      uint64 va = KSTACK((int) ((p - proc) * NKT + (kt - p->kthread)));
    800018ce:	414485b3          	sub	a1,s1,s4
    800018d2:	8599                	srai	a1,a1,0x6
    800018d4:	000bb783          	ld	a5,0(s7)
    800018d8:	02f585b3          	mul	a1,a1,a5
    800018dc:	012585bb          	addw	a1,a1,s2
    800018e0:	2585                	addiw	a1,a1,1
    800018e2:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018e6:	4719                	li	a4,6
    800018e8:	6685                	lui	a3,0x1
    800018ea:	40ba85b3          	sub	a1,s5,a1
    800018ee:	855a                	mv	a0,s6
    800018f0:	00000097          	auipc	ra,0x0
    800018f4:	84e080e7          	jalr	-1970(ra) # 8000113e <kvmmap>
    for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++) {
    800018f8:	0c048493          	addi	s1,s1,192
    800018fc:	fd3493e3          	bne	s1,s3,800018c2 <proc_mapstacks+0x8c>
    80001900:	bf59                	j	80001896 <proc_mapstacks+0x60>
    }
  }
}
    80001902:	60e6                	ld	ra,88(sp)
    80001904:	6446                	ld	s0,80(sp)
    80001906:	64a6                	ld	s1,72(sp)
    80001908:	6906                	ld	s2,64(sp)
    8000190a:	79e2                	ld	s3,56(sp)
    8000190c:	7a42                	ld	s4,48(sp)
    8000190e:	7aa2                	ld	s5,40(sp)
    80001910:	7b02                	ld	s6,32(sp)
    80001912:	6be2                	ld	s7,24(sp)
    80001914:	6c42                	ld	s8,16(sp)
    80001916:	6ca2                	ld	s9,8(sp)
    80001918:	6d02                	ld	s10,0(sp)
    8000191a:	6125                	addi	sp,sp,96
    8000191c:	8082                	ret

000000008000191e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000191e:	7179                	addi	sp,sp,-48
    80001920:	f406                	sd	ra,40(sp)
    80001922:	f022                	sd	s0,32(sp)
    80001924:	ec26                	sd	s1,24(sp)
    80001926:	e84a                	sd	s2,16(sp)
    80001928:	e44e                	sd	s3,8(sp)
    8000192a:	e052                	sd	s4,0(sp)
    8000192c:	1800                	addi	s0,sp,48
  struct proc *p;
  initlock(&pid_lock, "nextpid");
    8000192e:	00007597          	auipc	a1,0x7
    80001932:	8b258593          	addi	a1,a1,-1870 # 800081e0 <digits+0x1a0>
    80001936:	0000f517          	auipc	a0,0xf
    8000193a:	23a50513          	addi	a0,a0,570 # 80010b70 <pid_lock>
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001946:	00007597          	auipc	a1,0x7
    8000194a:	8a258593          	addi	a1,a1,-1886 # 800081e8 <digits+0x1a8>
    8000194e:	0000f517          	auipc	a0,0xf
    80001952:	23a50513          	addi	a0,a0,570 # 80010b88 <wait_lock>
    80001956:	fffff097          	auipc	ra,0xfffff
    8000195a:	1f0080e7          	jalr	496(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195e:	0000f497          	auipc	s1,0xf
    80001962:	64248493          	addi	s1,s1,1602 # 80010fa0 <proc>
     initlock(&p->lock, "proc"); 
    80001966:	00007a17          	auipc	s4,0x7
    8000196a:	892a0a13          	addi	s4,s4,-1902 # 800081f8 <digits+0x1b8>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000196e:	6905                	lui	s2,0x1
    80001970:	88090913          	addi	s2,s2,-1920 # 880 <_entry-0x7ffff780>
    80001974:	00031997          	auipc	s3,0x31
    80001978:	62c98993          	addi	s3,s3,1580 # 80032fa0 <tickslock>
     initlock(&p->lock, "proc"); 
    8000197c:	85d2                	mv	a1,s4
    8000197e:	8526                	mv	a0,s1
    80001980:	fffff097          	auipc	ra,0xfffff
    80001984:	1c6080e7          	jalr	454(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001988:	0004ac23          	sw	zero,24(s1)
      kthreadinit(p);
    8000198c:	8526                	mv	a0,s1
    8000198e:	00001097          	auipc	ra,0x1
    80001992:	e60080e7          	jalr	-416(ra) # 800027ee <kthreadinit>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001996:	94ca                	add	s1,s1,s2
    80001998:	ff3492e3          	bne	s1,s3,8000197c <procinit+0x5e>
  }

}
    8000199c:	70a2                	ld	ra,40(sp)
    8000199e:	7402                	ld	s0,32(sp)
    800019a0:	64e2                	ld	s1,24(sp)
    800019a2:	6942                	ld	s2,16(sp)
    800019a4:	69a2                	ld	s3,8(sp)
    800019a6:	6a02                	ld	s4,0(sp)
    800019a8:	6145                	addi	sp,sp,48
    800019aa:	8082                	ret

00000000800019ac <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019ac:	1141                	addi	sp,sp,-16
    800019ae:	e422                	sd	s0,8(sp)
    800019b0:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019b2:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019b4:	2501                	sext.w	a0,a0
    800019b6:	6422                	ld	s0,8(sp)
    800019b8:	0141                	addi	sp,sp,16
    800019ba:	8082                	ret

00000000800019bc <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019bc:	1141                	addi	sp,sp,-16
    800019be:	e422                	sd	s0,8(sp)
    800019c0:	0800                	addi	s0,sp,16
    800019c2:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019c4:	2781                	sext.w	a5,a5
    800019c6:	079e                	slli	a5,a5,0x7
  return c;
}
    800019c8:	0000f517          	auipc	a0,0xf
    800019cc:	1d850513          	addi	a0,a0,472 # 80010ba0 <cpus>
    800019d0:	953e                	add	a0,a0,a5
    800019d2:	6422                	ld	s0,8(sp)
    800019d4:	0141                	addi	sp,sp,16
    800019d6:	8082                	ret

00000000800019d8 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019d8:	1101                	addi	sp,sp,-32
    800019da:	ec06                	sd	ra,24(sp)
    800019dc:	e822                	sd	s0,16(sp)
    800019de:	e426                	sd	s1,8(sp)
    800019e0:	1000                	addi	s0,sp,32
  push_off();
    800019e2:	fffff097          	auipc	ra,0xfffff
    800019e6:	1a8080e7          	jalr	424(ra) # 80000b8a <push_off>
    800019ea:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p=0;
  if(c->kthread !=0){
    800019ec:	2781                	sext.w	a5,a5
    800019ee:	079e                	slli	a5,a5,0x7
    800019f0:	0000f717          	auipc	a4,0xf
    800019f4:	18070713          	addi	a4,a4,384 # 80010b70 <pid_lock>
    800019f8:	97ba                	add	a5,a5,a4
    800019fa:	7b84                	ld	s1,48(a5)
    800019fc:	c091                	beqz	s1,80001a00 <myproc+0x28>
    struct kthread *kthread = c->kthread;
    p=kthread->process;
    800019fe:	7c84                	ld	s1,56(s1)
  }
  pop_off();
    80001a00:	fffff097          	auipc	ra,0xfffff
    80001a04:	22a080e7          	jalr	554(ra) # 80000c2a <pop_off>
  return p;
}
    80001a08:	8526                	mv	a0,s1
    80001a0a:	60e2                	ld	ra,24(sp)
    80001a0c:	6442                	ld	s0,16(sp)
    80001a0e:	64a2                	ld	s1,8(sp)
    80001a10:	6105                	addi	sp,sp,32
    80001a12:	8082                	ret

0000000080001a14 <allocpid>:

int
allocpid()
{
    80001a14:	1101                	addi	sp,sp,-32
    80001a16:	ec06                	sd	ra,24(sp)
    80001a18:	e822                	sd	s0,16(sp)
    80001a1a:	e426                	sd	s1,8(sp)
    80001a1c:	e04a                	sd	s2,0(sp)
    80001a1e:	1000                	addi	s0,sp,32
  int pid;
  
  acquire(&pid_lock);
    80001a20:	0000f917          	auipc	s2,0xf
    80001a24:	15090913          	addi	s2,s2,336 # 80010b70 <pid_lock>
    80001a28:	854a                	mv	a0,s2
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	1ac080e7          	jalr	428(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a32:	00007797          	auipc	a5,0x7
    80001a36:	e3278793          	addi	a5,a5,-462 # 80008864 <nextpid>
    80001a3a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a3c:	0014871b          	addiw	a4,s1,1
    80001a40:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a42:	854a                	mv	a0,s2
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	246080e7          	jalr	582(ra) # 80000c8a <release>

  return pid;
}
    80001a4c:	8526                	mv	a0,s1
    80001a4e:	60e2                	ld	ra,24(sp)
    80001a50:	6442                	ld	s0,16(sp)
    80001a52:	64a2                	ld	s1,8(sp)
    80001a54:	6902                	ld	s2,0(sp)
    80001a56:	6105                	addi	sp,sp,32
    80001a58:	8082                	ret

0000000080001a5a <proc_pagetable>:

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
    80001a5a:	1101                	addi	sp,sp,-32
    80001a5c:	ec06                	sd	ra,24(sp)
    80001a5e:	e822                	sd	s0,16(sp)
    80001a60:	e426                	sd	s1,8(sp)
    80001a62:	e04a                	sd	s2,0(sp)
    80001a64:	1000                	addi	s0,sp,32
    80001a66:	892a                	mv	s2,a0
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
    80001a68:	00000097          	auipc	ra,0x0
    80001a6c:	8c0080e7          	jalr	-1856(ra) # 80001328 <uvmcreate>
    80001a70:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a72:	c121                	beqz	a0,80001ab2 <proc_pagetable+0x58>

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a74:	4729                	li	a4,10
    80001a76:	00005697          	auipc	a3,0x5
    80001a7a:	58a68693          	addi	a3,a3,1418 # 80007000 <_trampoline>
    80001a7e:	6605                	lui	a2,0x1
    80001a80:	040005b7          	lui	a1,0x4000
    80001a84:	15fd                	addi	a1,a1,-1
    80001a86:	05b2                	slli	a1,a1,0xc
    80001a88:	fffff097          	auipc	ra,0xfffff
    80001a8c:	616080e7          	jalr	1558(ra) # 8000109e <mappages>
    80001a90:	02054863          	bltz	a0,80001ac0 <proc_pagetable+0x66>
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME(0), PGSIZE,
    80001a94:	4719                	li	a4,6
    80001a96:	7a893683          	ld	a3,1960(s2)
    80001a9a:	6605                	lui	a2,0x1
    80001a9c:	020005b7          	lui	a1,0x2000
    80001aa0:	15fd                	addi	a1,a1,-1
    80001aa2:	05b6                	slli	a1,a1,0xd
    80001aa4:	8526                	mv	a0,s1
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	5f8080e7          	jalr	1528(ra) # 8000109e <mappages>
    80001aae:	02054163          	bltz	a0,80001ad0 <proc_pagetable+0x76>
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	60e2                	ld	ra,24(sp)
    80001ab6:	6442                	ld	s0,16(sp)
    80001ab8:	64a2                	ld	s1,8(sp)
    80001aba:	6902                	ld	s2,0(sp)
    80001abc:	6105                	addi	sp,sp,32
    80001abe:	8082                	ret
    uvmfree(pagetable, 0);
    80001ac0:	4581                	li	a1,0
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	00000097          	auipc	ra,0x0
    80001ac8:	a68080e7          	jalr	-1432(ra) # 8000152c <uvmfree>
    return 0;
    80001acc:	4481                	li	s1,0
    80001ace:	b7d5                	j	80001ab2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad0:	4681                	li	a3,0
    80001ad2:	4605                	li	a2,1
    80001ad4:	040005b7          	lui	a1,0x4000
    80001ad8:	15fd                	addi	a1,a1,-1
    80001ada:	05b2                	slli	a1,a1,0xc
    80001adc:	8526                	mv	a0,s1
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	786080e7          	jalr	1926(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ae6:	4581                	li	a1,0
    80001ae8:	8526                	mv	a0,s1
    80001aea:	00000097          	auipc	ra,0x0
    80001aee:	a42080e7          	jalr	-1470(ra) # 8000152c <uvmfree>
    return 0;
    80001af2:	4481                	li	s1,0
    80001af4:	bf7d                	j	80001ab2 <proc_pagetable+0x58>

0000000080001af6 <proc_freepagetable>:

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
    80001af6:	1101                	addi	sp,sp,-32
    80001af8:	ec06                	sd	ra,24(sp)
    80001afa:	e822                	sd	s0,16(sp)
    80001afc:	e426                	sd	s1,8(sp)
    80001afe:	e04a                	sd	s2,0(sp)
    80001b00:	1000                	addi	s0,sp,32
    80001b02:	84aa                	mv	s1,a0
    80001b04:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b06:	4681                	li	a3,0
    80001b08:	4605                	li	a2,1
    80001b0a:	040005b7          	lui	a1,0x4000
    80001b0e:	15fd                	addi	a1,a1,-1
    80001b10:	05b2                	slli	a1,a1,0xc
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	752080e7          	jalr	1874(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME(0), 1, 0);
    80001b1a:	4681                	li	a3,0
    80001b1c:	4605                	li	a2,1
    80001b1e:	020005b7          	lui	a1,0x2000
    80001b22:	15fd                	addi	a1,a1,-1
    80001b24:	05b6                	slli	a1,a1,0xd
    80001b26:	8526                	mv	a0,s1
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b30:	85ca                	mv	a1,s2
    80001b32:	8526                	mv	a0,s1
    80001b34:	00000097          	auipc	ra,0x0
    80001b38:	9f8080e7          	jalr	-1544(ra) # 8000152c <uvmfree>
}
    80001b3c:	60e2                	ld	ra,24(sp)
    80001b3e:	6442                	ld	s0,16(sp)
    80001b40:	64a2                	ld	s1,8(sp)
    80001b42:	6902                	ld	s2,0(sp)
    80001b44:	6105                	addi	sp,sp,32
    80001b46:	8082                	ret

0000000080001b48 <freeproc>:
{
    80001b48:	7179                	addi	sp,sp,-48
    80001b4a:	f406                	sd	ra,40(sp)
    80001b4c:	f022                	sd	s0,32(sp)
    80001b4e:	ec26                	sd	s1,24(sp)
    80001b50:	e84a                	sd	s2,16(sp)
    80001b52:	e44e                	sd	s3,8(sp)
    80001b54:	1800                	addi	s0,sp,48
    80001b56:	892a                	mv	s2,a0
   for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++){
    80001b58:	02850493          	addi	s1,a0,40
    80001b5c:	7a850993          	addi	s3,a0,1960
    acquire(&kt->t_lock);
    80001b60:	8526                	mv	a0,s1
    80001b62:	fffff097          	auipc	ra,0xfffff
    80001b66:	074080e7          	jalr	116(ra) # 80000bd6 <acquire>
      freethread(kt);
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	00001097          	auipc	ra,0x1
    80001b70:	e88080e7          	jalr	-376(ra) # 800029f4 <freethread>
   for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++){
    80001b74:	0c048493          	addi	s1,s1,192
    80001b78:	fe9994e3          	bne	s3,s1,80001b60 <freeproc+0x18>
  if(p->base_trapframes)
    80001b7c:	7a893503          	ld	a0,1960(s2)
    80001b80:	c509                	beqz	a0,80001b8a <freeproc+0x42>
    kfree((void*)p->base_trapframes);
    80001b82:	fffff097          	auipc	ra,0xfffff
    80001b86:	e68080e7          	jalr	-408(ra) # 800009ea <kfree>
  p->base_trapframes = 0;
    80001b8a:	7a093423          	sd	zero,1960(s2)
  if(p->pagetable)
    80001b8e:	7c093503          	ld	a0,1984(s2)
    80001b92:	c519                	beqz	a0,80001ba0 <freeproc+0x58>
    proc_freepagetable(p->pagetable, p->sz);
    80001b94:	7b893583          	ld	a1,1976(s2)
    80001b98:	00000097          	auipc	ra,0x0
    80001b9c:	f5e080e7          	jalr	-162(ra) # 80001af6 <proc_freepagetable>
  p->pagetable = 0;
    80001ba0:	7c093023          	sd	zero,1984(s2)
  p->sz = 0;
    80001ba4:	7a093c23          	sd	zero,1976(s2)
  p->pid = 0;
    80001ba8:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80001bac:	7a093823          	sd	zero,1968(s2)
  p->name[0] = 0;
    80001bb0:	6785                	lui	a5,0x1
    80001bb2:	97ca                	add	a5,a5,s2
    80001bb4:	84078823          	sb	zero,-1968(a5) # 850 <_entry-0x7ffff7b0>
  p->killed = 0;
    80001bb8:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    80001bbc:	02092023          	sw	zero,32(s2)
  p->state = UNUSED;
    80001bc0:	00092c23          	sw	zero,24(s2)
  p->p_counter=0;
    80001bc4:	8607a023          	sw	zero,-1952(a5)
}
    80001bc8:	70a2                	ld	ra,40(sp)
    80001bca:	7402                	ld	s0,32(sp)
    80001bcc:	64e2                	ld	s1,24(sp)
    80001bce:	6942                	ld	s2,16(sp)
    80001bd0:	69a2                	ld	s3,8(sp)
    80001bd2:	6145                	addi	sp,sp,48
    80001bd4:	8082                	ret

0000000080001bd6 <allocproc>:
{
    80001bd6:	7179                	addi	sp,sp,-48
    80001bd8:	f406                	sd	ra,40(sp)
    80001bda:	f022                	sd	s0,32(sp)
    80001bdc:	ec26                	sd	s1,24(sp)
    80001bde:	e84a                	sd	s2,16(sp)
    80001be0:	e44e                	sd	s3,8(sp)
    80001be2:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be4:	0000f497          	auipc	s1,0xf
    80001be8:	3bc48493          	addi	s1,s1,956 # 80010fa0 <proc>
    80001bec:	6905                	lui	s2,0x1
    80001bee:	88090913          	addi	s2,s2,-1920 # 880 <_entry-0x7ffff780>
    80001bf2:	00031997          	auipc	s3,0x31
    80001bf6:	3ae98993          	addi	s3,s3,942 # 80032fa0 <tickslock>
    acquire(&p->lock);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	fda080e7          	jalr	-38(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001c04:	4c9c                	lw	a5,24(s1)
    80001c06:	cb99                	beqz	a5,80001c1c <allocproc+0x46>
      release(&p->lock);
    80001c08:	8526                	mv	a0,s1
    80001c0a:	fffff097          	auipc	ra,0xfffff
    80001c0e:	080080e7          	jalr	128(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c12:	94ca                	add	s1,s1,s2
    80001c14:	ff3493e3          	bne	s1,s3,80001bfa <allocproc+0x24>
  return 0;
    80001c18:	4481                	li	s1,0
    80001c1a:	a0a9                	j	80001c64 <allocproc+0x8e>
  p->p_counter=1;
    80001c1c:	6785                	lui	a5,0x1
    80001c1e:	97a6                	add	a5,a5,s1
    80001c20:	4905                	li	s2,1
    80001c22:	8727a023          	sw	s2,-1952(a5) # 860 <_entry-0x7ffff7a0>
  p->pid = allocpid();
    80001c26:	00000097          	auipc	ra,0x0
    80001c2a:	dee080e7          	jalr	-530(ra) # 80001a14 <allocpid>
    80001c2e:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001c30:	0124ac23          	sw	s2,24(s1)
  if((p->base_trapframes = (struct trapframe *)kalloc()) == 0){
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	eb2080e7          	jalr	-334(ra) # 80000ae6 <kalloc>
    80001c3c:	892a                	mv	s2,a0
    80001c3e:	7aa4b423          	sd	a0,1960(s1)
    80001c42:	c90d                	beqz	a0,80001c74 <allocproc+0x9e>
  struct kthread *new_t=allockthread(p);
    80001c44:	8526                	mv	a0,s1
    80001c46:	00001097          	auipc	ra,0x1
    80001c4a:	d1c080e7          	jalr	-740(ra) # 80002962 <allockthread>
    80001c4e:	89aa                	mv	s3,a0
  if(new_t==0){
    80001c50:	cd15                	beqz	a0,80001c8c <allocproc+0xb6>
  p->pagetable = proc_pagetable(p);
    80001c52:	8526                	mv	a0,s1
    80001c54:	00000097          	auipc	ra,0x0
    80001c58:	e06080e7          	jalr	-506(ra) # 80001a5a <proc_pagetable>
    80001c5c:	892a                	mv	s2,a0
    80001c5e:	7ca4b023          	sd	a0,1984(s1)
  if(p->pagetable == 0){
    80001c62:	c531                	beqz	a0,80001cae <allocproc+0xd8>
}
    80001c64:	8526                	mv	a0,s1
    80001c66:	70a2                	ld	ra,40(sp)
    80001c68:	7402                	ld	s0,32(sp)
    80001c6a:	64e2                	ld	s1,24(sp)
    80001c6c:	6942                	ld	s2,16(sp)
    80001c6e:	69a2                	ld	s3,8(sp)
    80001c70:	6145                	addi	sp,sp,48
    80001c72:	8082                	ret
    freeproc(p);
    80001c74:	8526                	mv	a0,s1
    80001c76:	00000097          	auipc	ra,0x0
    80001c7a:	ed2080e7          	jalr	-302(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
    return 0;
    80001c88:	84ca                	mv	s1,s2
    80001c8a:	bfe9                	j	80001c64 <allocproc+0x8e>
    release(&new_t->t_lock);
    80001c8c:	4501                	li	a0,0
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	ffc080e7          	jalr	-4(ra) # 80000c8a <release>
    freeproc(p);
    80001c96:	8526                	mv	a0,s1
    80001c98:	00000097          	auipc	ra,0x0
    80001c9c:	eb0080e7          	jalr	-336(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	fe8080e7          	jalr	-24(ra) # 80000c8a <release>
    return (struct proc *)-1;
    80001caa:	54fd                	li	s1,-1
    80001cac:	bf65                	j	80001c64 <allocproc+0x8e>
    release(&new_t->t_lock);
    80001cae:	854e                	mv	a0,s3
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	fda080e7          	jalr	-38(ra) # 80000c8a <release>
    freeproc(p);
    80001cb8:	8526                	mv	a0,s1
    80001cba:	00000097          	auipc	ra,0x0
    80001cbe:	e8e080e7          	jalr	-370(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	fc6080e7          	jalr	-58(ra) # 80000c8a <release>
    return 0;
    80001ccc:	84ca                	mv	s1,s2
    80001cce:	bf59                	j	80001c64 <allocproc+0x8e>

0000000080001cd0 <userinit>:
};

// Set up first user process.
void
userinit(void)
{
    80001cd0:	1101                	addi	sp,sp,-32
    80001cd2:	ec06                	sd	ra,24(sp)
    80001cd4:	e822                	sd	s0,16(sp)
    80001cd6:	e426                	sd	s1,8(sp)
    80001cd8:	e04a                	sd	s2,0(sp)
    80001cda:	1000                	addi	s0,sp,32
  struct proc *p;
  p = allocproc();
    80001cdc:	00000097          	auipc	ra,0x0
    80001ce0:	efa080e7          	jalr	-262(ra) # 80001bd6 <allocproc>
    80001ce4:	84aa                	mv	s1,a0
  initproc = p;
    80001ce6:	00007797          	auipc	a5,0x7
    80001cea:	c0a7b923          	sd	a0,-1006(a5) # 800088f8 <initproc>
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cee:	03400613          	li	a2,52
    80001cf2:	00007597          	auipc	a1,0x7
    80001cf6:	b7e58593          	addi	a1,a1,-1154 # 80008870 <initcode>
    80001cfa:	7c053503          	ld	a0,1984(a0)
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	658080e7          	jalr	1624(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d06:	6905                	lui	s2,0x1
    80001d08:	7b24bc23          	sd	s2,1976(s1)
  // prepare for the very first "return" from kernel to user.
  // mykthread()->trapframe->epc = 0;      // user program counter
  p->kthread[0].trapframe->epc=0;
    80001d0c:	70fc                	ld	a5,224(s1)
    80001d0e:	0007bc23          	sd	zero,24(a5)
  // mykthread()->trapframe->sp = PGSIZE;  // user stack pointer
  p->kthread[0].trapframe->sp=PGSIZE;
    80001d12:	70fc                	ld	a5,224(s1)
    80001d14:	0327b823          	sd	s2,48(a5)
  // mykthread()->t_state=RUNNABLE_t;
  p->kthread[0].t_state=RUNNABLE_t;
    80001d18:	478d                	li	a5,3
    80001d1a:	c0bc                	sw	a5,64(s1)

  release(&(p->kthread[0].t_lock));
    80001d1c:	02848513          	addi	a0,s1,40
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	f6a080e7          	jalr	-150(ra) # 80000c8a <release>

  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d28:	85090513          	addi	a0,s2,-1968 # 850 <_entry-0x7ffff7b0>
    80001d2c:	4641                	li	a2,16
    80001d2e:	00006597          	auipc	a1,0x6
    80001d32:	4d258593          	addi	a1,a1,1234 # 80008200 <digits+0x1c0>
    80001d36:	9526                	add	a0,a0,s1
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	0e4080e7          	jalr	228(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d40:	00006517          	auipc	a0,0x6
    80001d44:	4d050513          	addi	a0,a0,1232 # 80008210 <digits+0x1d0>
    80001d48:	00003097          	auipc	ra,0x3
    80001d4c:	998080e7          	jalr	-1640(ra) # 800046e0 <namei>
    80001d50:	9926                	add	s2,s2,s1
    80001d52:	84a93423          	sd	a0,-1976(s2)

  // p->state = RUNNABLE;

  release(&p->lock);
    80001d56:	8526                	mv	a0,s1
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	f32080e7          	jalr	-206(ra) # 80000c8a <release>

}
    80001d60:	60e2                	ld	ra,24(sp)
    80001d62:	6442                	ld	s0,16(sp)
    80001d64:	64a2                	ld	s1,8(sp)
    80001d66:	6902                	ld	s2,0(sp)
    80001d68:	6105                	addi	sp,sp,32
    80001d6a:	8082                	ret

0000000080001d6c <growproc>:

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
    80001d6c:	1101                	addi	sp,sp,-32
    80001d6e:	ec06                	sd	ra,24(sp)
    80001d70:	e822                	sd	s0,16(sp)
    80001d72:	e426                	sd	s1,8(sp)
    80001d74:	e04a                	sd	s2,0(sp)
    80001d76:	1000                	addi	s0,sp,32
    80001d78:	892a                	mv	s2,a0
  uint64 sz;
  struct proc *p = myproc();
    80001d7a:	00000097          	auipc	ra,0x0
    80001d7e:	c5e080e7          	jalr	-930(ra) # 800019d8 <myproc>
    80001d82:	84aa                	mv	s1,a0

  sz = p->sz;
    80001d84:	7b853583          	ld	a1,1976(a0)
  if(n > 0){
    80001d88:	01204d63          	bgtz	s2,80001da2 <growproc+0x36>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    80001d8c:	02094863          	bltz	s2,80001dbc <growproc+0x50>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
    80001d90:	7ab4bc23          	sd	a1,1976(s1)
  return 0;
    80001d94:	4501                	li	a0,0
}
    80001d96:	60e2                	ld	ra,24(sp)
    80001d98:	6442                	ld	s0,16(sp)
    80001d9a:	64a2                	ld	s1,8(sp)
    80001d9c:	6902                	ld	s2,0(sp)
    80001d9e:	6105                	addi	sp,sp,32
    80001da0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001da2:	4691                	li	a3,4
    80001da4:	00b90633          	add	a2,s2,a1
    80001da8:	7c053503          	ld	a0,1984(a0)
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	664080e7          	jalr	1636(ra) # 80001410 <uvmalloc>
    80001db4:	85aa                	mv	a1,a0
    80001db6:	fd69                	bnez	a0,80001d90 <growproc+0x24>
      return -1;
    80001db8:	557d                	li	a0,-1
    80001dba:	bff1                	j	80001d96 <growproc+0x2a>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dbc:	00b90633          	add	a2,s2,a1
    80001dc0:	7c053503          	ld	a0,1984(a0)
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	604080e7          	jalr	1540(ra) # 800013c8 <uvmdealloc>
    80001dcc:	85aa                	mv	a1,a0
    80001dce:	b7c9                	j	80001d90 <growproc+0x24>

0000000080001dd0 <fork>:

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
    80001dd0:	7139                	addi	sp,sp,-64
    80001dd2:	fc06                	sd	ra,56(sp)
    80001dd4:	f822                	sd	s0,48(sp)
    80001dd6:	f426                	sd	s1,40(sp)
    80001dd8:	f04a                	sd	s2,32(sp)
    80001dda:	ec4e                	sd	s3,24(sp)
    80001ddc:	e852                	sd	s4,16(sp)
    80001dde:	e456                	sd	s5,8(sp)
    80001de0:	0080                	addi	s0,sp,64
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
    80001de2:	00000097          	auipc	ra,0x0
    80001de6:	bf6080e7          	jalr	-1034(ra) # 800019d8 <myproc>
    80001dea:	8aaa                	mv	s5,a0
  struct kthread *kt = mykthread();
    80001dec:	00001097          	auipc	ra,0x1
    80001df0:	ace080e7          	jalr	-1330(ra) # 800028ba <mykthread>
    80001df4:	84aa                	mv	s1,a0
  // Allocate process.
  if((np = allocproc()) == 0){
    80001df6:	00000097          	auipc	ra,0x0
    80001dfa:	de0080e7          	jalr	-544(ra) # 80001bd6 <allocproc>
    80001dfe:	14050163          	beqz	a0,80001f40 <fork+0x170>
    80001e02:	8a2a                	mv	s4,a0
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e04:	7b8ab603          	ld	a2,1976(s5) # 40007b8 <_entry-0x7bfff848>
    80001e08:	7c053583          	ld	a1,1984(a0)
    80001e0c:	7c0ab503          	ld	a0,1984(s5)
    80001e10:	fffff097          	auipc	ra,0xfffff
    80001e14:	754080e7          	jalr	1876(ra) # 80001564 <uvmcopy>
    80001e18:	04054963          	bltz	a0,80001e6a <fork+0x9a>
    freeproc(np);
    release(&np->kthread[0].t_lock);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;
    80001e1c:	7b8ab783          	ld	a5,1976(s5)
    80001e20:	7afa3c23          	sd	a5,1976(s4)
  //   freeproc(np);
  //    release(&np->lock);
  //   return -1;
  // }
  // copy saved user registers.
  *(np->kthread[0].trapframe) = *(kt->trapframe);
    80001e24:	7cd4                	ld	a3,184(s1)
    80001e26:	87b6                	mv	a5,a3
    80001e28:	0e0a3703          	ld	a4,224(s4)
    80001e2c:	12068693          	addi	a3,a3,288
    80001e30:	0007b803          	ld	a6,0(a5)
    80001e34:	6788                	ld	a0,8(a5)
    80001e36:	6b8c                	ld	a1,16(a5)
    80001e38:	6f90                	ld	a2,24(a5)
    80001e3a:	01073023          	sd	a6,0(a4)
    80001e3e:	e708                	sd	a0,8(a4)
    80001e40:	eb0c                	sd	a1,16(a4)
    80001e42:	ef10                	sd	a2,24(a4)
    80001e44:	02078793          	addi	a5,a5,32
    80001e48:	02070713          	addi	a4,a4,32
    80001e4c:	fed792e3          	bne	a5,a3,80001e30 <fork+0x60>

  // Cause fork to return 0 in the child.
  np->kthread[0].trapframe->a0 = 0;
    80001e50:	0e0a3783          	ld	a5,224(s4)
    80001e54:	0607b823          	sd	zero,112(a5)

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    80001e58:	7c8a8493          	addi	s1,s5,1992
    80001e5c:	7c8a0913          	addi	s2,s4,1992
    80001e60:	6985                	lui	s3,0x1
    80001e62:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001e66:	99d6                	add	s3,s3,s5
    80001e68:	a03d                	j	80001e96 <fork+0xc6>
    freeproc(np);
    80001e6a:	8552                	mv	a0,s4
    80001e6c:	00000097          	auipc	ra,0x0
    80001e70:	cdc080e7          	jalr	-804(ra) # 80001b48 <freeproc>
    release(&np->kthread[0].t_lock);
    80001e74:	028a0513          	addi	a0,s4,40
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	e12080e7          	jalr	-494(ra) # 80000c8a <release>
    release(&np->lock);
    80001e80:	8552                	mv	a0,s4
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	e08080e7          	jalr	-504(ra) # 80000c8a <release>
    return -1;
    80001e8a:	59fd                	li	s3,-1
    80001e8c:	a045                	j	80001f2c <fork+0x15c>
  for(i = 0; i < NOFILE; i++)
    80001e8e:	04a1                	addi	s1,s1,8
    80001e90:	0921                	addi	s2,s2,8
    80001e92:	01348b63          	beq	s1,s3,80001ea8 <fork+0xd8>
    if(p->ofile[i])
    80001e96:	6088                	ld	a0,0(s1)
    80001e98:	d97d                	beqz	a0,80001e8e <fork+0xbe>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e9a:	00003097          	auipc	ra,0x3
    80001e9e:	edc080e7          	jalr	-292(ra) # 80004d76 <filedup>
    80001ea2:	00a93023          	sd	a0,0(s2)
    80001ea6:	b7e5                	j	80001e8e <fork+0xbe>
  np->cwd = idup(p->cwd);
    80001ea8:	6485                	lui	s1,0x1
    80001eaa:	009a87b3          	add	a5,s5,s1
    80001eae:	8487b503          	ld	a0,-1976(a5)
    80001eb2:	00002097          	auipc	ra,0x2
    80001eb6:	046080e7          	jalr	70(ra) # 80003ef8 <idup>
    80001eba:	009a07b3          	add	a5,s4,s1
    80001ebe:	84a7b423          	sd	a0,-1976(a5)

  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ec2:	85048513          	addi	a0,s1,-1968 # 850 <_entry-0x7ffff7b0>
    80001ec6:	4641                	li	a2,16
    80001ec8:	00aa85b3          	add	a1,s5,a0
    80001ecc:	9552                	add	a0,a0,s4
    80001ece:	fffff097          	auipc	ra,0xfffff
    80001ed2:	f4e080e7          	jalr	-178(ra) # 80000e1c <safestrcpy>

  pid = np->pid;
    80001ed6:	024a2983          	lw	s3,36(s4)

  release(&np->kthread[0].t_lock);///acqire in allockthread
    80001eda:	028a0493          	addi	s1,s4,40
    80001ede:	8526                	mv	a0,s1
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	daa080e7          	jalr	-598(ra) # 80000c8a <release>
  release(&np->lock);///acqire in allocproc
    80001ee8:	8552                	mv	a0,s4
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	da0080e7          	jalr	-608(ra) # 80000c8a <release>

  acquire(&wait_lock);
    80001ef2:	0000f917          	auipc	s2,0xf
    80001ef6:	c9690913          	addi	s2,s2,-874 # 80010b88 <wait_lock>
    80001efa:	854a                	mv	a0,s2
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	cda080e7          	jalr	-806(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001f04:	7b5a3823          	sd	s5,1968(s4)
  release(&wait_lock);
    80001f08:	854a                	mv	a0,s2
    80001f0a:	fffff097          	auipc	ra,0xfffff
    80001f0e:	d80080e7          	jalr	-640(ra) # 80000c8a <release>

  // acquire(&np->lock);
  acquire(&np->kthread[0].t_lock);
    80001f12:	8526                	mv	a0,s1
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	cc2080e7          	jalr	-830(ra) # 80000bd6 <acquire>
  np->kthread[0].t_state = RUNNABLE_t;
    80001f1c:	478d                	li	a5,3
    80001f1e:	04fa2023          	sw	a5,64(s4)
  release(&np->kthread[0].t_lock);
    80001f22:	8526                	mv	a0,s1
    80001f24:	fffff097          	auipc	ra,0xfffff
    80001f28:	d66080e7          	jalr	-666(ra) # 80000c8a <release>
  // release(&np->lock);



  return pid;
}
    80001f2c:	854e                	mv	a0,s3
    80001f2e:	70e2                	ld	ra,56(sp)
    80001f30:	7442                	ld	s0,48(sp)
    80001f32:	74a2                	ld	s1,40(sp)
    80001f34:	7902                	ld	s2,32(sp)
    80001f36:	69e2                	ld	s3,24(sp)
    80001f38:	6a42                	ld	s4,16(sp)
    80001f3a:	6aa2                	ld	s5,8(sp)
    80001f3c:	6121                	addi	sp,sp,64
    80001f3e:	8082                	ret
    return -1;
    80001f40:	59fd                	li	s3,-1
    80001f42:	b7ed                	j	80001f2c <fork+0x15c>

0000000080001f44 <scheduler>:
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
    80001f44:	711d                	addi	sp,sp,-96
    80001f46:	ec86                	sd	ra,88(sp)
    80001f48:	e8a2                	sd	s0,80(sp)
    80001f4a:	e4a6                	sd	s1,72(sp)
    80001f4c:	e0ca                	sd	s2,64(sp)
    80001f4e:	fc4e                	sd	s3,56(sp)
    80001f50:	f852                	sd	s4,48(sp)
    80001f52:	f456                	sd	s5,40(sp)
    80001f54:	f05a                	sd	s6,32(sp)
    80001f56:	ec5e                	sd	s7,24(sp)
    80001f58:	e862                	sd	s8,16(sp)
    80001f5a:	e466                	sd	s9,8(sp)
    80001f5c:	e06a                	sd	s10,0(sp)
    80001f5e:	1080                	addi	s0,sp,96
    80001f60:	8792                	mv	a5,tp
  int id = r_tp();
    80001f62:	2781                	sext.w	a5,a5
  struct proc *p;
  struct cpu *c = mycpu();
  c->kthread = 0;
    80001f64:	00779c13          	slli	s8,a5,0x7
    80001f68:	0000f717          	auipc	a4,0xf
    80001f6c:	c0870713          	addi	a4,a4,-1016 # 80010b70 <pid_lock>
    80001f70:	9762                	add	a4,a4,s8
    80001f72:	02073823          	sd	zero,48(a4)
          acquire(&kt->t_lock);
            if(kt->t_state == RUNNABLE_t) {

              kt->t_state = RUNNING_t;
              c->kthread=kt;
              swtch(&c->context, &kt->context);
    80001f76:	0000f717          	auipc	a4,0xf
    80001f7a:	c3270713          	addi	a4,a4,-974 # 80010ba8 <cpus+0x8>
    80001f7e:	9c3a                	add	s8,s8,a4
    80001f80:	00031b17          	auipc	s6,0x31
    80001f84:	7c8b0b13          	addi	s6,s6,1992 # 80033748 <bcache+0x790>
              kt->t_state = RUNNING_t;
    80001f88:	4c91                	li	s9,4
              c->kthread=kt;
    80001f8a:	079e                	slli	a5,a5,0x7
    80001f8c:	0000fb97          	auipc	s7,0xf
    80001f90:	be4b8b93          	addi	s7,s7,-1052 # 80010b70 <pid_lock>
    80001f94:	9bbe                	add	s7,s7,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f96:	6a85                	lui	s5,0x1
    80001f98:	880a8a93          	addi	s5,s5,-1920 # 880 <_entry-0x7ffff780>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fa0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fa4:	10079073          	csrw	sstatus,a5
    80001fa8:	0000f917          	auipc	s2,0xf
    80001fac:	7a090913          	addi	s2,s2,1952 # 80011748 <proc+0x7a8>
      if (p->state==USED){
    80001fb0:	4a05                	li	s4,1
    80001fb2:	a099                	j	80001ff8 <scheduler+0xb4>
              c->kthread = 0;

            }
        release(&kt->t_lock); // Release the thread lock
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	cd4080e7          	jalr	-812(ra) # 80000c8a <release>
        for(struct kthread *kt=p->kthread;kt<&p->kthread[NKT];kt++){
    80001fbe:	0c048493          	addi	s1,s1,192
    80001fc2:	03348863          	beq	s1,s3,80001ff2 <scheduler+0xae>
          acquire(&kt->t_lock);
    80001fc6:	8526                	mv	a0,s1
    80001fc8:	fffff097          	auipc	ra,0xfffff
    80001fcc:	c0e080e7          	jalr	-1010(ra) # 80000bd6 <acquire>
            if(kt->t_state == RUNNABLE_t) {
    80001fd0:	4c9c                	lw	a5,24(s1)
    80001fd2:	ffa791e3          	bne	a5,s10,80001fb4 <scheduler+0x70>
              kt->t_state = RUNNING_t;
    80001fd6:	0194ac23          	sw	s9,24(s1)
              c->kthread=kt;
    80001fda:	029bb823          	sd	s1,48(s7)
              swtch(&c->context, &kt->context);
    80001fde:	04048593          	addi	a1,s1,64
    80001fe2:	8562                	mv	a0,s8
    80001fe4:	00001097          	auipc	ra,0x1
    80001fe8:	d54080e7          	jalr	-684(ra) # 80002d38 <swtch>
              c->kthread = 0;
    80001fec:	020bb823          	sd	zero,48(s7)
    80001ff0:	b7d1                	j	80001fb4 <scheduler+0x70>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ff2:	9956                	add	s2,s2,s5
    80001ff4:	fb6904e3          	beq	s2,s6,80001f9c <scheduler+0x58>
      if (p->state==USED){
    80001ff8:	89ca                	mv	s3,s2
    80001ffa:	87092783          	lw	a5,-1936(s2)
    80001ffe:	ff479ae3          	bne	a5,s4,80001ff2 <scheduler+0xae>
        for(struct kthread *kt=p->kthread;kt<&p->kthread[NKT];kt++){
    80002002:	88090493          	addi	s1,s2,-1920
            if(kt->t_state == RUNNABLE_t) {
    80002006:	4d0d                	li	s10,3
    80002008:	bf7d                	j	80001fc6 <scheduler+0x82>

000000008000200a <sched>:
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
    8000200a:	7179                	addi	sp,sp,-48
    8000200c:	f406                	sd	ra,40(sp)
    8000200e:	f022                	sd	s0,32(sp)
    80002010:	ec26                	sd	s1,24(sp)
    80002012:	e84a                	sd	s2,16(sp)
    80002014:	e44e                	sd	s3,8(sp)
    80002016:	1800                	addi	s0,sp,48
  int intena;
  struct kthread *t = mykthread();
    80002018:	00001097          	auipc	ra,0x1
    8000201c:	8a2080e7          	jalr	-1886(ra) # 800028ba <mykthread>
    80002020:	84aa                	mv	s1,a0
  if(!holding(&t->t_lock))
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	b3a080e7          	jalr	-1222(ra) # 80000b5c <holding>
    8000202a:	c93d                	beqz	a0,800020a0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000202c:	8792                	mv	a5,tp
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    8000202e:	2781                	sext.w	a5,a5
    80002030:	079e                	slli	a5,a5,0x7
    80002032:	0000f717          	auipc	a4,0xf
    80002036:	b3e70713          	addi	a4,a4,-1218 # 80010b70 <pid_lock>
    8000203a:	97ba                	add	a5,a5,a4
    8000203c:	0a87a703          	lw	a4,168(a5)
    80002040:	4785                	li	a5,1
    80002042:	06f71763          	bne	a4,a5,800020b0 <sched+0xa6>
    panic("sched locks");
  if(t->t_state == RUNNING_t)
    80002046:	4c98                	lw	a4,24(s1)
    80002048:	4791                	li	a5,4
    8000204a:	06f70b63          	beq	a4,a5,800020c0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000204e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002052:	8b89                	andi	a5,a5,2
    panic("sched running");
  if(intr_get())
    80002054:	efb5                	bnez	a5,800020d0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002056:	8792                	mv	a5,tp
    panic("sched interruptible");

  intena = mycpu()->intena;
    80002058:	0000f917          	auipc	s2,0xf
    8000205c:	b1890913          	addi	s2,s2,-1256 # 80010b70 <pid_lock>
    80002060:	2781                	sext.w	a5,a5
    80002062:	079e                	slli	a5,a5,0x7
    80002064:	97ca                	add	a5,a5,s2
    80002066:	0ac7a983          	lw	s3,172(a5)
    8000206a:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    8000206c:	2781                	sext.w	a5,a5
    8000206e:	079e                	slli	a5,a5,0x7
    80002070:	0000f597          	auipc	a1,0xf
    80002074:	b3858593          	addi	a1,a1,-1224 # 80010ba8 <cpus+0x8>
    80002078:	95be                	add	a1,a1,a5
    8000207a:	04048513          	addi	a0,s1,64
    8000207e:	00001097          	auipc	ra,0x1
    80002082:	cba080e7          	jalr	-838(ra) # 80002d38 <swtch>
    80002086:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002088:	2781                	sext.w	a5,a5
    8000208a:	079e                	slli	a5,a5,0x7
    8000208c:	97ca                	add	a5,a5,s2
    8000208e:	0b37a623          	sw	s3,172(a5)
}
    80002092:	70a2                	ld	ra,40(sp)
    80002094:	7402                	ld	s0,32(sp)
    80002096:	64e2                	ld	s1,24(sp)
    80002098:	6942                	ld	s2,16(sp)
    8000209a:	69a2                	ld	s3,8(sp)
    8000209c:	6145                	addi	sp,sp,48
    8000209e:	8082                	ret
    panic("sched p->lock");
    800020a0:	00006517          	auipc	a0,0x6
    800020a4:	17850513          	addi	a0,a0,376 # 80008218 <digits+0x1d8>
    800020a8:	ffffe097          	auipc	ra,0xffffe
    800020ac:	496080e7          	jalr	1174(ra) # 8000053e <panic>
    panic("sched locks");
    800020b0:	00006517          	auipc	a0,0x6
    800020b4:	17850513          	addi	a0,a0,376 # 80008228 <digits+0x1e8>
    800020b8:	ffffe097          	auipc	ra,0xffffe
    800020bc:	486080e7          	jalr	1158(ra) # 8000053e <panic>
    panic("sched running");
    800020c0:	00006517          	auipc	a0,0x6
    800020c4:	17850513          	addi	a0,a0,376 # 80008238 <digits+0x1f8>
    800020c8:	ffffe097          	auipc	ra,0xffffe
    800020cc:	476080e7          	jalr	1142(ra) # 8000053e <panic>
    panic("sched interruptible");
    800020d0:	00006517          	auipc	a0,0x6
    800020d4:	17850513          	addi	a0,a0,376 # 80008248 <digits+0x208>
    800020d8:	ffffe097          	auipc	ra,0xffffe
    800020dc:	466080e7          	jalr	1126(ra) # 8000053e <panic>

00000000800020e0 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
    800020e0:	1101                	addi	sp,sp,-32
    800020e2:	ec06                	sd	ra,24(sp)
    800020e4:	e822                	sd	s0,16(sp)
    800020e6:	e426                	sd	s1,8(sp)
    800020e8:	e04a                	sd	s2,0(sp)
    800020ea:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020ec:	00000097          	auipc	ra,0x0
    800020f0:	8ec080e7          	jalr	-1812(ra) # 800019d8 <myproc>
    800020f4:	84aa                	mv	s1,a0
  // acquire(&p->lock);
  acquire(&p->kthread[0].t_lock);
    800020f6:	02850913          	addi	s2,a0,40
    800020fa:	854a                	mv	a0,s2
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	ada080e7          	jalr	-1318(ra) # 80000bd6 <acquire>
  p->kthread[0].t_state = RUNNABLE_t;
    80002104:	478d                	li	a5,3
    80002106:	c0bc                	sw	a5,64(s1)
  // release(&p->lock);
     sched();
    80002108:	00000097          	auipc	ra,0x0
    8000210c:	f02080e7          	jalr	-254(ra) # 8000200a <sched>
  release(&p->kthread[0].t_lock);
    80002110:	854a                	mv	a0,s2
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	b78080e7          	jalr	-1160(ra) # 80000c8a <release>
 
   

}
    8000211a:	60e2                	ld	ra,24(sp)
    8000211c:	6442                	ld	s0,16(sp)
    8000211e:	64a2                	ld	s1,8(sp)
    80002120:	6902                	ld	s2,0(sp)
    80002122:	6105                	addi	sp,sp,32
    80002124:	8082                	ret

0000000080002126 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80002126:	1141                	addi	sp,sp,-16
    80002128:	e406                	sd	ra,8(sp)
    8000212a:	e022                	sd	s0,0(sp)
    8000212c:	0800                	addi	s0,sp,16
  static int first = 1;
  release(&(mykthread()->t_lock)); //still holding kt->lock from scheduler
    8000212e:	00000097          	auipc	ra,0x0
    80002132:	78c080e7          	jalr	1932(ra) # 800028ba <mykthread>
    80002136:	fffff097          	auipc	ra,0xfffff
    8000213a:	b54080e7          	jalr	-1196(ra) # 80000c8a <release>
  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);
  if (first) {
    8000213e:	00006797          	auipc	a5,0x6
    80002142:	7227a783          	lw	a5,1826(a5) # 80008860 <first.1>
    80002146:	eb89                	bnez	a5,80002158 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80002148:	00001097          	auipc	ra,0x1
    8000214c:	c9a080e7          	jalr	-870(ra) # 80002de2 <usertrapret>
}
    80002150:	60a2                	ld	ra,8(sp)
    80002152:	6402                	ld	s0,0(sp)
    80002154:	0141                	addi	sp,sp,16
    80002156:	8082                	ret
    first = 0;
    80002158:	00006797          	auipc	a5,0x6
    8000215c:	7007a423          	sw	zero,1800(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80002160:	4505                	li	a0,1
    80002162:	00002097          	auipc	ra,0x2
    80002166:	b58080e7          	jalr	-1192(ra) # 80003cba <fsinit>
    8000216a:	bff9                	j	80002148 <forkret+0x22>

000000008000216c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000216c:	7179                	addi	sp,sp,-48
    8000216e:	f406                	sd	ra,40(sp)
    80002170:	f022                	sd	s0,32(sp)
    80002172:	ec26                	sd	s1,24(sp)
    80002174:	e84a                	sd	s2,16(sp)
    80002176:	e44e                	sd	s3,8(sp)
    80002178:	1800                	addi	s0,sp,48
    8000217a:	89aa                	mv	s3,a0
    8000217c:	892e                	mv	s2,a1
  struct kthread *kt = mykthread();
    8000217e:	00000097          	auipc	ra,0x0
    80002182:	73c080e7          	jalr	1852(ra) # 800028ba <mykthread>
    80002186:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.
  // acquire(&p->lock);  //DOC: sleeplock1 mayby return
  acquire(&kt->t_lock);
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	a4e080e7          	jalr	-1458(ra) # 80000bd6 <acquire>
  release(lk);
    80002190:	854a                	mv	a0,s2
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	af8080e7          	jalr	-1288(ra) # 80000c8a <release>

  // Go to sleep.
  kt->chan = chan;
    8000219a:	0334b023          	sd	s3,32(s1)
  kt->t_state = SLEEPING_t;
    8000219e:	4789                	li	a5,2
    800021a0:	cc9c                	sw	a5,24(s1)

  sched();
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	e68080e7          	jalr	-408(ra) # 8000200a <sched>

  // Tidy up.
  kt->chan= 0;
    800021aa:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&kt->t_lock);
    800021ae:	8526                	mv	a0,s1
    800021b0:	fffff097          	auipc	ra,0xfffff
    800021b4:	ada080e7          	jalr	-1318(ra) # 80000c8a <release>
  // release(&p->lock);//mayby return
  acquire(lk);
    800021b8:	854a                	mv	a0,s2
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	a1c080e7          	jalr	-1508(ra) # 80000bd6 <acquire>

}
    800021c2:	70a2                	ld	ra,40(sp)
    800021c4:	7402                	ld	s0,32(sp)
    800021c6:	64e2                	ld	s1,24(sp)
    800021c8:	6942                	ld	s2,16(sp)
    800021ca:	69a2                	ld	s3,8(sp)
    800021cc:	6145                	addi	sp,sp,48
    800021ce:	8082                	ret

00000000800021d0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021d0:	715d                	addi	sp,sp,-80
    800021d2:	e486                	sd	ra,72(sp)
    800021d4:	e0a2                	sd	s0,64(sp)
    800021d6:	fc26                	sd	s1,56(sp)
    800021d8:	f84a                	sd	s2,48(sp)
    800021da:	f44e                	sd	s3,40(sp)
    800021dc:	f052                	sd	s4,32(sp)
    800021de:	ec56                	sd	s5,24(sp)
    800021e0:	e85a                	sd	s6,16(sp)
    800021e2:	e45e                	sd	s7,8(sp)
    800021e4:	0880                	addi	s0,sp,80
    800021e6:	8a2a                	mv	s4,a0
  struct proc *p;
  struct kthread *kt;
  for(p = proc; p < &proc[NPROC]; p++) {
    800021e8:	0000f917          	auipc	s2,0xf
    800021ec:	56090913          	addi	s2,s2,1376 # 80011748 <proc+0x7a8>
    800021f0:	00031b17          	auipc	s6,0x31
    800021f4:	558b0b13          	addi	s6,s6,1368 # 80033748 <bcache+0x790>
    // acquire(&p->lock);
      // acquire(&p->lock);
    for(kt=p->kthread;kt<&p->kthread[NKT];kt++){
        if(kt !=mykthread()){
          acquire(&kt->t_lock);
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    800021f8:	4989                	li	s3,2
          kt->t_state = RUNNABLE_t;
    800021fa:	4b8d                	li	s7,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021fc:	6a85                	lui	s5,0x1
    800021fe:	880a8a93          	addi	s5,s5,-1920 # 880 <_entry-0x7ffff780>
    80002202:	a089                	j	80002244 <wakeup+0x74>
        }
        release(&kt->t_lock);
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	a84080e7          	jalr	-1404(ra) # 80000c8a <release>
    for(kt=p->kthread;kt<&p->kthread[NKT];kt++){
    8000220e:	0c048493          	addi	s1,s1,192
    80002212:	03248663          	beq	s1,s2,8000223e <wakeup+0x6e>
        if(kt !=mykthread()){
    80002216:	00000097          	auipc	ra,0x0
    8000221a:	6a4080e7          	jalr	1700(ra) # 800028ba <mykthread>
    8000221e:	fea488e3          	beq	s1,a0,8000220e <wakeup+0x3e>
          acquire(&kt->t_lock);
    80002222:	8526                	mv	a0,s1
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	9b2080e7          	jalr	-1614(ra) # 80000bd6 <acquire>
        if(kt->t_state == SLEEPING_t && kt->chan == chan) {
    8000222c:	4c9c                	lw	a5,24(s1)
    8000222e:	fd379be3          	bne	a5,s3,80002204 <wakeup+0x34>
    80002232:	709c                	ld	a5,32(s1)
    80002234:	fd4798e3          	bne	a5,s4,80002204 <wakeup+0x34>
          kt->t_state = RUNNABLE_t;
    80002238:	0174ac23          	sw	s7,24(s1)
    8000223c:	b7e1                	j	80002204 <wakeup+0x34>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000223e:	9956                	add	s2,s2,s5
    80002240:	01690563          	beq	s2,s6,8000224a <wakeup+0x7a>
    for(kt=p->kthread;kt<&p->kthread[NKT];kt++){
    80002244:	88090493          	addi	s1,s2,-1920
    80002248:	b7f9                	j	80002216 <wakeup+0x46>

       }
    }
    // release(&p->lock);
  }
}
    8000224a:	60a6                	ld	ra,72(sp)
    8000224c:	6406                	ld	s0,64(sp)
    8000224e:	74e2                	ld	s1,56(sp)
    80002250:	7942                	ld	s2,48(sp)
    80002252:	79a2                	ld	s3,40(sp)
    80002254:	7a02                	ld	s4,32(sp)
    80002256:	6ae2                	ld	s5,24(sp)
    80002258:	6b42                	ld	s6,16(sp)
    8000225a:	6ba2                	ld	s7,8(sp)
    8000225c:	6161                	addi	sp,sp,80
    8000225e:	8082                	ret

0000000080002260 <reparent>:
{
    80002260:	7139                	addi	sp,sp,-64
    80002262:	fc06                	sd	ra,56(sp)
    80002264:	f822                	sd	s0,48(sp)
    80002266:	f426                	sd	s1,40(sp)
    80002268:	f04a                	sd	s2,32(sp)
    8000226a:	ec4e                	sd	s3,24(sp)
    8000226c:	e852                	sd	s4,16(sp)
    8000226e:	e456                	sd	s5,8(sp)
    80002270:	0080                	addi	s0,sp,64
    80002272:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002274:	0000f497          	auipc	s1,0xf
    80002278:	d2c48493          	addi	s1,s1,-724 # 80010fa0 <proc>
      pp->parent = initproc;
    8000227c:	00006a97          	auipc	s5,0x6
    80002280:	67ca8a93          	addi	s5,s5,1660 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002284:	6905                	lui	s2,0x1
    80002286:	88090913          	addi	s2,s2,-1920 # 880 <_entry-0x7ffff780>
    8000228a:	00031a17          	auipc	s4,0x31
    8000228e:	d16a0a13          	addi	s4,s4,-746 # 80032fa0 <tickslock>
    80002292:	a021                	j	8000229a <reparent+0x3a>
    80002294:	94ca                	add	s1,s1,s2
    80002296:	01448f63          	beq	s1,s4,800022b4 <reparent+0x54>
    if(pp->parent == p){
    8000229a:	7b04b783          	ld	a5,1968(s1)
    8000229e:	ff379be3          	bne	a5,s3,80002294 <reparent+0x34>
      pp->parent = initproc;
    800022a2:	000ab503          	ld	a0,0(s5)
    800022a6:	7aa4b823          	sd	a0,1968(s1)
      wakeup(initproc);
    800022aa:	00000097          	auipc	ra,0x0
    800022ae:	f26080e7          	jalr	-218(ra) # 800021d0 <wakeup>
    800022b2:	b7cd                	j	80002294 <reparent+0x34>
}
    800022b4:	70e2                	ld	ra,56(sp)
    800022b6:	7442                	ld	s0,48(sp)
    800022b8:	74a2                	ld	s1,40(sp)
    800022ba:	7902                	ld	s2,32(sp)
    800022bc:	69e2                	ld	s3,24(sp)
    800022be:	6a42                	ld	s4,16(sp)
    800022c0:	6aa2                	ld	s5,8(sp)
    800022c2:	6121                	addi	sp,sp,64
    800022c4:	8082                	ret

00000000800022c6 <exit>:
{
    800022c6:	715d                	addi	sp,sp,-80
    800022c8:	e486                	sd	ra,72(sp)
    800022ca:	e0a2                	sd	s0,64(sp)
    800022cc:	fc26                	sd	s1,56(sp)
    800022ce:	f84a                	sd	s2,48(sp)
    800022d0:	f44e                	sd	s3,40(sp)
    800022d2:	f052                	sd	s4,32(sp)
    800022d4:	ec56                	sd	s5,24(sp)
    800022d6:	e85a                	sd	s6,16(sp)
    800022d8:	e45e                	sd	s7,8(sp)
    800022da:	e062                	sd	s8,0(sp)
    800022dc:	0880                	addi	s0,sp,80
    800022de:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	6f8080e7          	jalr	1784(ra) # 800019d8 <myproc>
    800022e8:	8aaa                	mv	s5,a0
  struct kthread *kt =mykthread();
    800022ea:	00000097          	auipc	ra,0x0
    800022ee:	5d0080e7          	jalr	1488(ra) # 800028ba <mykthread>
  if(p == initproc)
    800022f2:	00006797          	auipc	a5,0x6
    800022f6:	6067b783          	ld	a5,1542(a5) # 800088f8 <initproc>
    800022fa:	01578b63          	beq	a5,s5,80002310 <exit+0x4a>
    800022fe:	8a2a                	mv	s4,a0
  for(struct kthread *t2 = p->kthread ; t2< &p->kthread[NKT]; t2++){
    80002300:	028a8493          	addi	s1,s5,40
    80002304:	7a8a8993          	addi	s3,s5,1960
    80002308:	8926                	mv	s2,s1
        if(t2->t_state != UNUSED_t && t2->t_state != ZOMBIE_t){
    8000230a:	4b95                	li	s7,5
          t2->t_killed = 1;
    8000230c:	4c05                	li	s8,1
    8000230e:	a015                	j	80002332 <exit+0x6c>
    panic("init exiting");
    80002310:	00006517          	auipc	a0,0x6
    80002314:	f5050513          	addi	a0,a0,-176 # 80008260 <digits+0x220>
    80002318:	ffffe097          	auipc	ra,0xffffe
    8000231c:	226080e7          	jalr	550(ra) # 8000053e <panic>
          release(&t2->t_lock);  
    80002320:	854a                	mv	a0,s2
    80002322:	fffff097          	auipc	ra,0xfffff
    80002326:	968080e7          	jalr	-1688(ra) # 80000c8a <release>
  for(struct kthread *t2 = p->kthread ; t2< &p->kthread[NKT]; t2++){
    8000232a:	0c090913          	addi	s2,s2,192
    8000232e:	03390d63          	beq	s2,s3,80002368 <exit+0xa2>
      if(kt !=t2){
    80002332:	ff2a0ce3          	beq	s4,s2,8000232a <exit+0x64>
        acquire(&t2->t_lock);
    80002336:	854a                	mv	a0,s2
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	89e080e7          	jalr	-1890(ra) # 80000bd6 <acquire>
        if(t2->t_state != UNUSED_t && t2->t_state != ZOMBIE_t){
    80002340:	01892783          	lw	a5,24(s2)
    80002344:	dff1                	beqz	a5,80002320 <exit+0x5a>
    80002346:	fd778de3          	beq	a5,s7,80002320 <exit+0x5a>
          t2->t_killed = 1;
    8000234a:	03892423          	sw	s8,40(s2)
          release(&t2->t_lock);  
    8000234e:	854a                	mv	a0,s2
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	93a080e7          	jalr	-1734(ra) # 80000c8a <release>
          kthread_join(kt->tid,0);
    80002358:	4581                	li	a1,0
    8000235a:	030a2503          	lw	a0,48(s4)
    8000235e:	00001097          	auipc	ra,0x1
    80002362:	8e8080e7          	jalr	-1816(ra) # 80002c46 <kthread_join>
    80002366:	bf6d                	j	80002320 <exit+0x5a>
    80002368:	7c8a8913          	addi	s2,s5,1992
    8000236c:	6a05                	lui	s4,0x1
    8000236e:	848a0a13          	addi	s4,s4,-1976 # 848 <_entry-0x7ffff7b8>
    80002372:	9a56                	add	s4,s4,s5
    80002374:	a811                	j	80002388 <exit+0xc2>
      fileclose(f);
    80002376:	00003097          	auipc	ra,0x3
    8000237a:	a52080e7          	jalr	-1454(ra) # 80004dc8 <fileclose>
      p->ofile[fd] = 0;
    8000237e:	00093023          	sd	zero,0(s2)
  for(int fd = 0; fd < NOFILE; fd++){
    80002382:	0921                	addi	s2,s2,8
    80002384:	01490663          	beq	s2,s4,80002390 <exit+0xca>
    if(p->ofile[fd]){
    80002388:	00093503          	ld	a0,0(s2)
    8000238c:	f56d                	bnez	a0,80002376 <exit+0xb0>
    8000238e:	bfd5                	j	80002382 <exit+0xbc>
  begin_op();
    80002390:	00002097          	auipc	ra,0x2
    80002394:	56c080e7          	jalr	1388(ra) # 800048fc <begin_op>
  iput(p->cwd);
    80002398:	6905                	lui	s2,0x1
    8000239a:	9956                	add	s2,s2,s5
    8000239c:	84893503          	ld	a0,-1976(s2) # 848 <_entry-0x7ffff7b8>
    800023a0:	00002097          	auipc	ra,0x2
    800023a4:	d50080e7          	jalr	-688(ra) # 800040f0 <iput>
  end_op();
    800023a8:	00002097          	auipc	ra,0x2
    800023ac:	5d4080e7          	jalr	1492(ra) # 8000497c <end_op>
  p->cwd = 0;
    800023b0:	84093423          	sd	zero,-1976(s2)
  acquire(&wait_lock);
    800023b4:	0000e517          	auipc	a0,0xe
    800023b8:	7d450513          	addi	a0,a0,2004 # 80010b88 <wait_lock>
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	81a080e7          	jalr	-2022(ra) # 80000bd6 <acquire>
  reparent(p);
    800023c4:	8556                	mv	a0,s5
    800023c6:	00000097          	auipc	ra,0x0
    800023ca:	e9a080e7          	jalr	-358(ra) # 80002260 <reparent>
  wakeup(p->parent);
    800023ce:	7b0ab503          	ld	a0,1968(s5)
    800023d2:	00000097          	auipc	ra,0x0
    800023d6:	dfe080e7          	jalr	-514(ra) # 800021d0 <wakeup>
  acquire(&p->lock);
    800023da:	8556                	mv	a0,s5
    800023dc:	ffffe097          	auipc	ra,0xffffe
    800023e0:	7fa080e7          	jalr	2042(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800023e4:	036aa023          	sw	s6,32(s5)
  p->state = ZOMBIE;
    800023e8:	4789                	li	a5,2
    800023ea:	00faac23          	sw	a5,24(s5)
  release(&p->lock);
    800023ee:	8556                	mv	a0,s5
    800023f0:	fffff097          	auipc	ra,0xfffff
    800023f4:	89a080e7          	jalr	-1894(ra) # 80000c8a <release>
    kt->t_state=ZOMBIE_t;
    800023f8:	4915                	li	s2,5
    800023fa:	a029                	j	80002404 <exit+0x13e>
  for(struct kthread *kt=p->kthread;kt<&p->kthread[NKT];kt++){
    800023fc:	0c048493          	addi	s1,s1,192
    80002400:	03348763          	beq	s1,s3,8000242e <exit+0x168>
    acquire(&kt->t_lock);
    80002404:	8526                	mv	a0,s1
    80002406:	ffffe097          	auipc	ra,0xffffe
    8000240a:	7d0080e7          	jalr	2000(ra) # 80000bd6 <acquire>
    kt->t_xstate=status;
    8000240e:	0364a623          	sw	s6,44(s1)
    kt->t_state=ZOMBIE_t;
    80002412:	0124ac23          	sw	s2,24(s1)
    if(kt !=mykthread()){
    80002416:	00000097          	auipc	ra,0x0
    8000241a:	4a4080e7          	jalr	1188(ra) # 800028ba <mykthread>
    8000241e:	fca48fe3          	beq	s1,a0,800023fc <exit+0x136>
      release(&kt->t_lock);
    80002422:	8526                	mv	a0,s1
    80002424:	fffff097          	auipc	ra,0xfffff
    80002428:	866080e7          	jalr	-1946(ra) # 80000c8a <release>
    8000242c:	bfc1                	j	800023fc <exit+0x136>
  release(&wait_lock);
    8000242e:	0000e517          	auipc	a0,0xe
    80002432:	75a50513          	addi	a0,a0,1882 # 80010b88 <wait_lock>
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	854080e7          	jalr	-1964(ra) # 80000c8a <release>
  sched();
    8000243e:	00000097          	auipc	ra,0x0
    80002442:	bcc080e7          	jalr	-1076(ra) # 8000200a <sched>
  panic("zombie exit");
    80002446:	00006517          	auipc	a0,0x6
    8000244a:	e2a50513          	addi	a0,a0,-470 # 80008270 <digits+0x230>
    8000244e:	ffffe097          	auipc	ra,0xffffe
    80002452:	0f0080e7          	jalr	240(ra) # 8000053e <panic>

0000000080002456 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002456:	7139                	addi	sp,sp,-64
    80002458:	fc06                	sd	ra,56(sp)
    8000245a:	f822                	sd	s0,48(sp)
    8000245c:	f426                	sd	s1,40(sp)
    8000245e:	f04a                	sd	s2,32(sp)
    80002460:	ec4e                	sd	s3,24(sp)
    80002462:	e852                	sd	s4,16(sp)
    80002464:	e456                	sd	s5,8(sp)
    80002466:	0080                	addi	s0,sp,64
    80002468:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000246a:	0000f497          	auipc	s1,0xf
    8000246e:	b3648493          	addi	s1,s1,-1226 # 80010fa0 <proc>
    80002472:	6985                	lui	s3,0x1
    80002474:	88098993          	addi	s3,s3,-1920 # 880 <_entry-0x7ffff780>
    80002478:	00031a17          	auipc	s4,0x31
    8000247c:	b28a0a13          	addi	s4,s4,-1240 # 80032fa0 <tickslock>
    acquire(&p->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	754080e7          	jalr	1876(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    8000248a:	50dc                	lw	a5,36(s1)
    8000248c:	01278c63          	beq	a5,s2,800024a4 <kill+0x4e>
      // }
      release(&p->lock);
      return 0;
    }
    
    release(&p->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	7f8080e7          	jalr	2040(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000249a:	94ce                	add	s1,s1,s3
    8000249c:	ff4492e3          	bne	s1,s4,80002480 <kill+0x2a>
  }
  return -1;
    800024a0:	557d                	li	a0,-1
    800024a2:	a0a9                	j	800024ec <kill+0x96>
      p->killed = 1;
    800024a4:	4785                	li	a5,1
    800024a6:	ccdc                	sw	a5,28(s1)
      for (struct kthread *t = p->kthread; t < &p->kthread[NKT]; t++) {
    800024a8:	02848913          	addi	s2,s1,40
    800024ac:	7a848a13          	addi	s4,s1,1960
        if(t->t_state == SLEEPING_t) {
    800024b0:	4989                	li	s3,2
          t->t_state = RUNNABLE_t;
    800024b2:	4a8d                	li	s5,3
    800024b4:	a811                	j	800024c8 <kill+0x72>
        release(&t->t_lock);
    800024b6:	854a                	mv	a0,s2
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	7d2080e7          	jalr	2002(ra) # 80000c8a <release>
      for (struct kthread *t = p->kthread; t < &p->kthread[NKT]; t++) {
    800024c0:	0c090913          	addi	s2,s2,192
    800024c4:	01490e63          	beq	s2,s4,800024e0 <kill+0x8a>
        acquire(&t->t_lock);
    800024c8:	854a                	mv	a0,s2
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	70c080e7          	jalr	1804(ra) # 80000bd6 <acquire>
        if(t->t_state == SLEEPING_t) {
    800024d2:	01892783          	lw	a5,24(s2)
    800024d6:	ff3790e3          	bne	a5,s3,800024b6 <kill+0x60>
          t->t_state = RUNNABLE_t;
    800024da:	01592c23          	sw	s5,24(s2)
    800024de:	bfe1                	j	800024b6 <kill+0x60>
      release(&p->lock);
    800024e0:	8526                	mv	a0,s1
    800024e2:	ffffe097          	auipc	ra,0xffffe
    800024e6:	7a8080e7          	jalr	1960(ra) # 80000c8a <release>
      return 0;
    800024ea:	4501                	li	a0,0
}
    800024ec:	70e2                	ld	ra,56(sp)
    800024ee:	7442                	ld	s0,48(sp)
    800024f0:	74a2                	ld	s1,40(sp)
    800024f2:	7902                	ld	s2,32(sp)
    800024f4:	69e2                	ld	s3,24(sp)
    800024f6:	6a42                	ld	s4,16(sp)
    800024f8:	6aa2                	ld	s5,8(sp)
    800024fa:	6121                	addi	sp,sp,64
    800024fc:	8082                	ret

00000000800024fe <setkilled>:


void
setkilled(struct proc *p)
{
    800024fe:	1101                	addi	sp,sp,-32
    80002500:	ec06                	sd	ra,24(sp)
    80002502:	e822                	sd	s0,16(sp)
    80002504:	e426                	sd	s1,8(sp)
    80002506:	1000                	addi	s0,sp,32
    80002508:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	6cc080e7          	jalr	1740(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002512:	4785                	li	a5,1
    80002514:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    80002516:	8526                	mv	a0,s1
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	772080e7          	jalr	1906(ra) # 80000c8a <release>
}
    80002520:	60e2                	ld	ra,24(sp)
    80002522:	6442                	ld	s0,16(sp)
    80002524:	64a2                	ld	s1,8(sp)
    80002526:	6105                	addi	sp,sp,32
    80002528:	8082                	ret

000000008000252a <killed>:

int
killed(struct proc *p)
{
    8000252a:	1101                	addi	sp,sp,-32
    8000252c:	ec06                	sd	ra,24(sp)
    8000252e:	e822                	sd	s0,16(sp)
    80002530:	e426                	sd	s1,8(sp)
    80002532:	e04a                	sd	s2,0(sp)
    80002534:	1000                	addi	s0,sp,32
    80002536:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002538:	ffffe097          	auipc	ra,0xffffe
    8000253c:	69e080e7          	jalr	1694(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002540:	01c4a903          	lw	s2,28(s1)
  release(&p->lock);
    80002544:	8526                	mv	a0,s1
    80002546:	ffffe097          	auipc	ra,0xffffe
    8000254a:	744080e7          	jalr	1860(ra) # 80000c8a <release>
  return k;
}
    8000254e:	854a                	mv	a0,s2
    80002550:	60e2                	ld	ra,24(sp)
    80002552:	6442                	ld	s0,16(sp)
    80002554:	64a2                	ld	s1,8(sp)
    80002556:	6902                	ld	s2,0(sp)
    80002558:	6105                	addi	sp,sp,32
    8000255a:	8082                	ret

000000008000255c <wait>:
{
    8000255c:	715d                	addi	sp,sp,-80
    8000255e:	e486                	sd	ra,72(sp)
    80002560:	e0a2                	sd	s0,64(sp)
    80002562:	fc26                	sd	s1,56(sp)
    80002564:	f84a                	sd	s2,48(sp)
    80002566:	f44e                	sd	s3,40(sp)
    80002568:	f052                	sd	s4,32(sp)
    8000256a:	ec56                	sd	s5,24(sp)
    8000256c:	e85a                	sd	s6,16(sp)
    8000256e:	e45e                	sd	s7,8(sp)
    80002570:	0880                	addi	s0,sp,80
    80002572:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002574:	fffff097          	auipc	ra,0xfffff
    80002578:	464080e7          	jalr	1124(ra) # 800019d8 <myproc>
    8000257c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000257e:	0000e517          	auipc	a0,0xe
    80002582:	60a50513          	addi	a0,a0,1546 # 80010b88 <wait_lock>
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	650080e7          	jalr	1616(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    8000258e:	4a89                	li	s5,2
        havekids = 1;
    80002590:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002592:	6985                	lui	s3,0x1
    80002594:	88098993          	addi	s3,s3,-1920 # 880 <_entry-0x7ffff780>
    80002598:	00031a17          	auipc	s4,0x31
    8000259c:	a08a0a13          	addi	s4,s4,-1528 # 80032fa0 <tickslock>
    havekids = 0;
    800025a0:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025a2:	0000f497          	auipc	s1,0xf
    800025a6:	9fe48493          	addi	s1,s1,-1538 # 80010fa0 <proc>
    800025aa:	a0b5                	j	80002616 <wait+0xba>
          pid = pp->pid;
    800025ac:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025b0:	000b8e63          	beqz	s7,800025cc <wait+0x70>
    800025b4:	4691                	li	a3,4
    800025b6:	02048613          	addi	a2,s1,32
    800025ba:	85de                	mv	a1,s7
    800025bc:	7c093503          	ld	a0,1984(s2)
    800025c0:	fffff097          	auipc	ra,0xfffff
    800025c4:	0a8080e7          	jalr	168(ra) # 80001668 <copyout>
    800025c8:	02054563          	bltz	a0,800025f2 <wait+0x96>
          freeproc(pp);
    800025cc:	8526                	mv	a0,s1
    800025ce:	fffff097          	auipc	ra,0xfffff
    800025d2:	57a080e7          	jalr	1402(ra) # 80001b48 <freeproc>
          release(&pp->lock);
    800025d6:	8526                	mv	a0,s1
    800025d8:	ffffe097          	auipc	ra,0xffffe
    800025dc:	6b2080e7          	jalr	1714(ra) # 80000c8a <release>
          release(&wait_lock);
    800025e0:	0000e517          	auipc	a0,0xe
    800025e4:	5a850513          	addi	a0,a0,1448 # 80010b88 <wait_lock>
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	6a2080e7          	jalr	1698(ra) # 80000c8a <release>
          return pid;
    800025f0:	a0b5                	j	8000265c <wait+0x100>
            release(&pp->lock);
    800025f2:	8526                	mv	a0,s1
    800025f4:	ffffe097          	auipc	ra,0xffffe
    800025f8:	696080e7          	jalr	1686(ra) # 80000c8a <release>
            release(&wait_lock);
    800025fc:	0000e517          	auipc	a0,0xe
    80002600:	58c50513          	addi	a0,a0,1420 # 80010b88 <wait_lock>
    80002604:	ffffe097          	auipc	ra,0xffffe
    80002608:	686080e7          	jalr	1670(ra) # 80000c8a <release>
            return -1;
    8000260c:	59fd                	li	s3,-1
    8000260e:	a0b9                	j	8000265c <wait+0x100>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002610:	94ce                	add	s1,s1,s3
    80002612:	03448563          	beq	s1,s4,8000263c <wait+0xe0>
      if(pp->parent == p){
    80002616:	7b04b783          	ld	a5,1968(s1)
    8000261a:	ff279be3          	bne	a5,s2,80002610 <wait+0xb4>
        acquire(&pp->lock);
    8000261e:	8526                	mv	a0,s1
    80002620:	ffffe097          	auipc	ra,0xffffe
    80002624:	5b6080e7          	jalr	1462(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002628:	4c9c                	lw	a5,24(s1)
    8000262a:	f95781e3          	beq	a5,s5,800025ac <wait+0x50>
        release(&pp->lock);
    8000262e:	8526                	mv	a0,s1
    80002630:	ffffe097          	auipc	ra,0xffffe
    80002634:	65a080e7          	jalr	1626(ra) # 80000c8a <release>
        havekids = 1;
    80002638:	875a                	mv	a4,s6
    8000263a:	bfd9                	j	80002610 <wait+0xb4>
    if(!havekids || killed(p)){
    8000263c:	c719                	beqz	a4,8000264a <wait+0xee>
    8000263e:	854a                	mv	a0,s2
    80002640:	00000097          	auipc	ra,0x0
    80002644:	eea080e7          	jalr	-278(ra) # 8000252a <killed>
    80002648:	c515                	beqz	a0,80002674 <wait+0x118>
      release(&wait_lock);
    8000264a:	0000e517          	auipc	a0,0xe
    8000264e:	53e50513          	addi	a0,a0,1342 # 80010b88 <wait_lock>
    80002652:	ffffe097          	auipc	ra,0xffffe
    80002656:	638080e7          	jalr	1592(ra) # 80000c8a <release>
      return -1;
    8000265a:	59fd                	li	s3,-1
}
    8000265c:	854e                	mv	a0,s3
    8000265e:	60a6                	ld	ra,72(sp)
    80002660:	6406                	ld	s0,64(sp)
    80002662:	74e2                	ld	s1,56(sp)
    80002664:	7942                	ld	s2,48(sp)
    80002666:	79a2                	ld	s3,40(sp)
    80002668:	7a02                	ld	s4,32(sp)
    8000266a:	6ae2                	ld	s5,24(sp)
    8000266c:	6b42                	ld	s6,16(sp)
    8000266e:	6ba2                	ld	s7,8(sp)
    80002670:	6161                	addi	sp,sp,80
    80002672:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002674:	0000e597          	auipc	a1,0xe
    80002678:	51458593          	addi	a1,a1,1300 # 80010b88 <wait_lock>
    8000267c:	854a                	mv	a0,s2
    8000267e:	00000097          	auipc	ra,0x0
    80002682:	aee080e7          	jalr	-1298(ra) # 8000216c <sleep>
    havekids = 0;
    80002686:	bf29                	j	800025a0 <wait+0x44>

0000000080002688 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002688:	7179                	addi	sp,sp,-48
    8000268a:	f406                	sd	ra,40(sp)
    8000268c:	f022                	sd	s0,32(sp)
    8000268e:	ec26                	sd	s1,24(sp)
    80002690:	e84a                	sd	s2,16(sp)
    80002692:	e44e                	sd	s3,8(sp)
    80002694:	e052                	sd	s4,0(sp)
    80002696:	1800                	addi	s0,sp,48
    80002698:	84aa                	mv	s1,a0
    8000269a:	892e                	mv	s2,a1
    8000269c:	89b2                	mv	s3,a2
    8000269e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026a0:	fffff097          	auipc	ra,0xfffff
    800026a4:	338080e7          	jalr	824(ra) # 800019d8 <myproc>
  if(user_dst){
    800026a8:	c095                	beqz	s1,800026cc <either_copyout+0x44>
    return copyout(p->pagetable, dst, src, len);
    800026aa:	86d2                	mv	a3,s4
    800026ac:	864e                	mv	a2,s3
    800026ae:	85ca                	mv	a1,s2
    800026b0:	7c053503          	ld	a0,1984(a0)
    800026b4:	fffff097          	auipc	ra,0xfffff
    800026b8:	fb4080e7          	jalr	-76(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026bc:	70a2                	ld	ra,40(sp)
    800026be:	7402                	ld	s0,32(sp)
    800026c0:	64e2                	ld	s1,24(sp)
    800026c2:	6942                	ld	s2,16(sp)
    800026c4:	69a2                	ld	s3,8(sp)
    800026c6:	6a02                	ld	s4,0(sp)
    800026c8:	6145                	addi	sp,sp,48
    800026ca:	8082                	ret
    memmove((char *)dst, src, len);
    800026cc:	000a061b          	sext.w	a2,s4
    800026d0:	85ce                	mv	a1,s3
    800026d2:	854a                	mv	a0,s2
    800026d4:	ffffe097          	auipc	ra,0xffffe
    800026d8:	65a080e7          	jalr	1626(ra) # 80000d2e <memmove>
    return 0;
    800026dc:	8526                	mv	a0,s1
    800026de:	bff9                	j	800026bc <either_copyout+0x34>

00000000800026e0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026e0:	7179                	addi	sp,sp,-48
    800026e2:	f406                	sd	ra,40(sp)
    800026e4:	f022                	sd	s0,32(sp)
    800026e6:	ec26                	sd	s1,24(sp)
    800026e8:	e84a                	sd	s2,16(sp)
    800026ea:	e44e                	sd	s3,8(sp)
    800026ec:	e052                	sd	s4,0(sp)
    800026ee:	1800                	addi	s0,sp,48
    800026f0:	892a                	mv	s2,a0
    800026f2:	84ae                	mv	s1,a1
    800026f4:	89b2                	mv	s3,a2
    800026f6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026f8:	fffff097          	auipc	ra,0xfffff
    800026fc:	2e0080e7          	jalr	736(ra) # 800019d8 <myproc>
  if(user_src){
    80002700:	c095                	beqz	s1,80002724 <either_copyin+0x44>
    return copyin(p->pagetable, dst, src, len);
    80002702:	86d2                	mv	a3,s4
    80002704:	864e                	mv	a2,s3
    80002706:	85ca                	mv	a1,s2
    80002708:	7c053503          	ld	a0,1984(a0)
    8000270c:	fffff097          	auipc	ra,0xfffff
    80002710:	fe8080e7          	jalr	-24(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002714:	70a2                	ld	ra,40(sp)
    80002716:	7402                	ld	s0,32(sp)
    80002718:	64e2                	ld	s1,24(sp)
    8000271a:	6942                	ld	s2,16(sp)
    8000271c:	69a2                	ld	s3,8(sp)
    8000271e:	6a02                	ld	s4,0(sp)
    80002720:	6145                	addi	sp,sp,48
    80002722:	8082                	ret
    memmove(dst, (char*)src, len);
    80002724:	000a061b          	sext.w	a2,s4
    80002728:	85ce                	mv	a1,s3
    8000272a:	854a                	mv	a0,s2
    8000272c:	ffffe097          	auipc	ra,0xffffe
    80002730:	602080e7          	jalr	1538(ra) # 80000d2e <memmove>
    return 0;
    80002734:	8526                	mv	a0,s1
    80002736:	bff9                	j	80002714 <either_copyin+0x34>

0000000080002738 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002738:	715d                	addi	sp,sp,-80
    8000273a:	e486                	sd	ra,72(sp)
    8000273c:	e0a2                	sd	s0,64(sp)
    8000273e:	fc26                	sd	s1,56(sp)
    80002740:	f84a                	sd	s2,48(sp)
    80002742:	f44e                	sd	s3,40(sp)
    80002744:	f052                	sd	s4,32(sp)
    80002746:	ec56                	sd	s5,24(sp)
    80002748:	e85a                	sd	s6,16(sp)
    8000274a:	e45e                	sd	s7,8(sp)
    8000274c:	e062                	sd	s8,0(sp)
    8000274e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002750:	00006517          	auipc	a0,0x6
    80002754:	97850513          	addi	a0,a0,-1672 # 800080c8 <digits+0x88>
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	e30080e7          	jalr	-464(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002760:	0000f497          	auipc	s1,0xf
    80002764:	84048493          	addi	s1,s1,-1984 # 80010fa0 <proc>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002768:	4b89                	li	s7,2
      state = states[p->state];
    else
      state = "???";
    8000276a:	00006a17          	auipc	s4,0x6
    8000276e:	b16a0a13          	addi	s4,s4,-1258 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002772:	6905                	lui	s2,0x1
    80002774:	85090b13          	addi	s6,s2,-1968 # 850 <_entry-0x7ffff7b0>
    80002778:	00006a97          	auipc	s5,0x6
    8000277c:	b10a8a93          	addi	s5,s5,-1264 # 80008288 <digits+0x248>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002780:	00006c17          	auipc	s8,0x6
    80002784:	b30c0c13          	addi	s8,s8,-1232 # 800082b0 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002788:	88090913          	addi	s2,s2,-1920
    8000278c:	00031997          	auipc	s3,0x31
    80002790:	81498993          	addi	s3,s3,-2028 # 80032fa0 <tickslock>
    80002794:	a025                	j	800027bc <procdump+0x84>
    printf("%d %s %s", p->pid, state, p->name);
    80002796:	016486b3          	add	a3,s1,s6
    8000279a:	50cc                	lw	a1,36(s1)
    8000279c:	8556                	mv	a0,s5
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	dea080e7          	jalr	-534(ra) # 80000588 <printf>
    printf("\n");
    800027a6:	00006517          	auipc	a0,0x6
    800027aa:	92250513          	addi	a0,a0,-1758 # 800080c8 <digits+0x88>
    800027ae:	ffffe097          	auipc	ra,0xffffe
    800027b2:	dda080e7          	jalr	-550(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027b6:	94ca                	add	s1,s1,s2
    800027b8:	01348f63          	beq	s1,s3,800027d6 <procdump+0x9e>
    if(p->state == UNUSED)
    800027bc:	4c9c                	lw	a5,24(s1)
    800027be:	dfe5                	beqz	a5,800027b6 <procdump+0x7e>
      state = "???";
    800027c0:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027c2:	fcfbeae3          	bltu	s7,a5,80002796 <procdump+0x5e>
    800027c6:	1782                	slli	a5,a5,0x20
    800027c8:	9381                	srli	a5,a5,0x20
    800027ca:	078e                	slli	a5,a5,0x3
    800027cc:	97e2                	add	a5,a5,s8
    800027ce:	6390                	ld	a2,0(a5)
    800027d0:	f279                	bnez	a2,80002796 <procdump+0x5e>
      state = "???";
    800027d2:	8652                	mv	a2,s4
    800027d4:	b7c9                	j	80002796 <procdump+0x5e>
  }
}
    800027d6:	60a6                	ld	ra,72(sp)
    800027d8:	6406                	ld	s0,64(sp)
    800027da:	74e2                	ld	s1,56(sp)
    800027dc:	7942                	ld	s2,48(sp)
    800027de:	79a2                	ld	s3,40(sp)
    800027e0:	7a02                	ld	s4,32(sp)
    800027e2:	6ae2                	ld	s5,24(sp)
    800027e4:	6b42                	ld	s6,16(sp)
    800027e6:	6ba2                	ld	s7,8(sp)
    800027e8:	6c02                	ld	s8,0(sp)
    800027ea:	6161                	addi	sp,sp,80
    800027ec:	8082                	ret

00000000800027ee <kthreadinit>:
extern struct proc proc[NPROC];
extern void forkret(void);


void kthreadinit(struct proc *p)
{
    800027ee:	715d                	addi	sp,sp,-80
    800027f0:	e486                	sd	ra,72(sp)
    800027f2:	e0a2                	sd	s0,64(sp)
    800027f4:	fc26                	sd	s1,56(sp)
    800027f6:	f84a                	sd	s2,48(sp)
    800027f8:	f44e                	sd	s3,40(sp)
    800027fa:	f052                	sd	s4,32(sp)
    800027fc:	ec56                	sd	s5,24(sp)
    800027fe:	e85a                	sd	s6,16(sp)
    80002800:	e45e                	sd	s7,8(sp)
    80002802:	e062                	sd	s8,0(sp)
    80002804:	0880                	addi	s0,sp,80
    80002806:	892a                	mv	s2,a0
  initlock(&(p->alloc_lock),"aloc_thread");
    80002808:	00006597          	auipc	a1,0x6
    8000280c:	ac058593          	addi	a1,a1,-1344 # 800082c8 <states.0+0x18>
    80002810:	6505                	lui	a0,0x1
    80002812:	86850513          	addi	a0,a0,-1944 # 868 <_entry-0x7ffff798>
    80002816:	954a                	add	a0,a0,s2
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	32e080e7          	jalr	814(ra) # 80000b46 <initlock>
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    80002820:	02890a93          	addi	s5,s2,40
    initlock(&kt->t_lock, "thread_lock"); 
      kt->t_state = UNUSED_t;
      kt->process=p;
    // WARNING: Don't change this line!
    // get the pointer to the kernel stack of the kthread
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    80002824:	0000e797          	auipc	a5,0xe
    80002828:	77c78793          	addi	a5,a5,1916 # 80010fa0 <proc>
    8000282c:	40f907b3          	sub	a5,s2,a5
    80002830:	879d                	srai	a5,a5,0x7
    80002832:	00005a17          	auipc	s4,0x5
    80002836:	7cea3a03          	ld	s4,1998(s4) # 80008000 <etext>
    8000283a:	034787b3          	mul	a5,a5,s4
    8000283e:	00279a1b          	slliw	s4,a5,0x2
    80002842:	00fa0a3b          	addw	s4,s4,a5
    80002846:	001a1a1b          	slliw	s4,s4,0x1
    8000284a:	7a890c13          	addi	s8,s2,1960
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    8000284e:	84d6                	mv	s1,s5
    initlock(&kt->t_lock, "thread_lock"); 
    80002850:	00006b97          	auipc	s7,0x6
    80002854:	a88b8b93          	addi	s7,s7,-1400 # 800082d8 <states.0+0x28>
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    80002858:	00005b17          	auipc	s6,0x5
    8000285c:	7b0b0b13          	addi	s6,s6,1968 # 80008008 <etext+0x8>
    80002860:	040009b7          	lui	s3,0x4000
    80002864:	19fd                	addi	s3,s3,-1
    80002866:	09b2                	slli	s3,s3,0xc
    initlock(&kt->t_lock, "thread_lock"); 
    80002868:	85de                	mv	a1,s7
    8000286a:	8526                	mv	a0,s1
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	2da080e7          	jalr	730(ra) # 80000b46 <initlock>
      kt->t_state = UNUSED_t;
    80002874:	0004ac23          	sw	zero,24(s1)
      kt->process=p;
    80002878:	0324bc23          	sd	s2,56(s1)
    kt->kstack = KSTACK((int)((p - proc) * NKT + (kt - p->kthread)));
    8000287c:	415487b3          	sub	a5,s1,s5
    80002880:	8799                	srai	a5,a5,0x6
    80002882:	000b3703          	ld	a4,0(s6)
    80002886:	02e787b3          	mul	a5,a5,a4
    8000288a:	014787bb          	addw	a5,a5,s4
    8000288e:	2785                	addiw	a5,a5,1
    80002890:	00d7979b          	slliw	a5,a5,0xd
    80002894:	40f987b3          	sub	a5,s3,a5
    80002898:	f8dc                	sd	a5,176(s1)
  for (struct kthread *kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    8000289a:	0c048493          	addi	s1,s1,192
    8000289e:	fc9c15e3          	bne	s8,s1,80002868 <kthreadinit+0x7a>
  }
}
    800028a2:	60a6                	ld	ra,72(sp)
    800028a4:	6406                	ld	s0,64(sp)
    800028a6:	74e2                	ld	s1,56(sp)
    800028a8:	7942                	ld	s2,48(sp)
    800028aa:	79a2                	ld	s3,40(sp)
    800028ac:	7a02                	ld	s4,32(sp)
    800028ae:	6ae2                	ld	s5,24(sp)
    800028b0:	6b42                	ld	s6,16(sp)
    800028b2:	6ba2                	ld	s7,8(sp)
    800028b4:	6c02                	ld	s8,0(sp)
    800028b6:	6161                	addi	sp,sp,80
    800028b8:	8082                	ret

00000000800028ba <mykthread>:

struct kthread *mykthread()
{
    800028ba:	1101                	addi	sp,sp,-32
    800028bc:	ec06                	sd	ra,24(sp)
    800028be:	e822                	sd	s0,16(sp)
    800028c0:	e426                	sd	s1,8(sp)
    800028c2:	1000                	addi	s0,sp,32
  push_off();
    800028c4:	ffffe097          	auipc	ra,0xffffe
    800028c8:	2c6080e7          	jalr	710(ra) # 80000b8a <push_off>
  struct cpu *c = mycpu();
    800028cc:	fffff097          	auipc	ra,0xfffff
    800028d0:	0f0080e7          	jalr	240(ra) # 800019bc <mycpu>
  struct kthread *kthread = c->kthread;
    800028d4:	6104                	ld	s1,0(a0)
  pop_off();
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	354080e7          	jalr	852(ra) # 80000c2a <pop_off>
  return kthread;
}
    800028de:	8526                	mv	a0,s1
    800028e0:	60e2                	ld	ra,24(sp)
    800028e2:	6442                	ld	s0,16(sp)
    800028e4:	64a2                	ld	s1,8(sp)
    800028e6:	6105                	addi	sp,sp,32
    800028e8:	8082                	ret

00000000800028ea <alloctid>:

int alloctid(struct proc *p){
    800028ea:	7179                	addi	sp,sp,-48
    800028ec:	f406                	sd	ra,40(sp)
    800028ee:	f022                	sd	s0,32(sp)
    800028f0:	ec26                	sd	s1,24(sp)
    800028f2:	e84a                	sd	s2,16(sp)
    800028f4:	e44e                	sd	s3,8(sp)
    800028f6:	1800                	addi	s0,sp,48
    800028f8:	84aa                	mv	s1,a0
  int tid;
  acquire(&(p->alloc_lock));
    800028fa:	6985                	lui	s3,0x1
    800028fc:	86898913          	addi	s2,s3,-1944 # 868 <_entry-0x7ffff798>
    80002900:	992a                	add	s2,s2,a0
    80002902:	854a                	mv	a0,s2
    80002904:	ffffe097          	auipc	ra,0xffffe
    80002908:	2d2080e7          	jalr	722(ra) # 80000bd6 <acquire>
  tid = p->p_counter;
    8000290c:	94ce                	add	s1,s1,s3
    8000290e:	8604a983          	lw	s3,-1952(s1)
  p->p_counter++;
    80002912:	0019879b          	addiw	a5,s3,1
    80002916:	86f4a023          	sw	a5,-1952(s1)
  release(&(p->alloc_lock));
    8000291a:	854a                	mv	a0,s2
    8000291c:	ffffe097          	auipc	ra,0xffffe
    80002920:	36e080e7          	jalr	878(ra) # 80000c8a <release>
  return tid;
}
    80002924:	854e                	mv	a0,s3
    80002926:	70a2                	ld	ra,40(sp)
    80002928:	7402                	ld	s0,32(sp)
    8000292a:	64e2                	ld	s1,24(sp)
    8000292c:	6942                	ld	s2,16(sp)
    8000292e:	69a2                	ld	s3,8(sp)
    80002930:	6145                	addi	sp,sp,48
    80002932:	8082                	ret

0000000080002934 <get_kthread_trapframe>:

struct trapframe *get_kthread_trapframe(struct proc *p, struct kthread *kt)
{
    80002934:	1141                	addi	sp,sp,-16
    80002936:	e422                	sd	s0,8(sp)
    80002938:	0800                	addi	s0,sp,16
  return p->base_trapframes + ((int)(kt - p->kthread));
    8000293a:	02850793          	addi	a5,a0,40
    8000293e:	8d9d                	sub	a1,a1,a5
    80002940:	8599                	srai	a1,a1,0x6
    80002942:	00005797          	auipc	a5,0x5
    80002946:	6c67b783          	ld	a5,1734(a5) # 80008008 <etext+0x8>
    8000294a:	02f585bb          	mulw	a1,a1,a5
    8000294e:	00359793          	slli	a5,a1,0x3
    80002952:	95be                	add	a1,a1,a5
    80002954:	0596                	slli	a1,a1,0x5
    80002956:	7a853503          	ld	a0,1960(a0)
}
    8000295a:	952e                	add	a0,a0,a1
    8000295c:	6422                	ld	s0,8(sp)
    8000295e:	0141                	addi	sp,sp,16
    80002960:	8082                	ret

0000000080002962 <allockthread>:

struct kthread* allockthread(struct proc *p){
    80002962:	7179                	addi	sp,sp,-48
    80002964:	f406                	sd	ra,40(sp)
    80002966:	f022                	sd	s0,32(sp)
    80002968:	ec26                	sd	s1,24(sp)
    8000296a:	e84a                	sd	s2,16(sp)
    8000296c:	e44e                	sd	s3,8(sp)
    8000296e:	1800                	addi	s0,sp,48
    80002970:	89aa                	mv	s3,a0
  struct kthread *kt;
  for (kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    80002972:	02850493          	addi	s1,a0,40
    80002976:	7a850913          	addi	s2,a0,1960
    {
      acquire(&kt->t_lock);
    8000297a:	8526                	mv	a0,s1
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	25a080e7          	jalr	602(ra) # 80000bd6 <acquire>
      if(kt->t_state == UNUSED_t) {
    80002984:	4c9c                	lw	a5,24(s1)
    80002986:	c39d                	beqz	a5,800029ac <allockthread+0x4a>
        kt->context.sp = kt->kstack + PGSIZE;

        return kt;
      } 
      else {
        release(&kt->t_lock);
    80002988:	8526                	mv	a0,s1
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	300080e7          	jalr	768(ra) # 80000c8a <release>
  for (kt = p->kthread; kt < &p->kthread[NKT]; kt++)
    80002992:	0c048493          	addi	s1,s1,192
    80002996:	ff2492e3          	bne	s1,s2,8000297a <allockthread+0x18>
      }
  }
  return 0;
    8000299a:	4481                	li	s1,0
}
    8000299c:	8526                	mv	a0,s1
    8000299e:	70a2                	ld	ra,40(sp)
    800029a0:	7402                	ld	s0,32(sp)
    800029a2:	64e2                	ld	s1,24(sp)
    800029a4:	6942                	ld	s2,16(sp)
    800029a6:	69a2                	ld	s3,8(sp)
    800029a8:	6145                	addi	sp,sp,48
    800029aa:	8082                	ret
        kt->tid = alloctid(p);
    800029ac:	854e                	mv	a0,s3
    800029ae:	00000097          	auipc	ra,0x0
    800029b2:	f3c080e7          	jalr	-196(ra) # 800028ea <alloctid>
    800029b6:	d888                	sw	a0,48(s1)
        kt->t_state = USED_t;
    800029b8:	4785                	li	a5,1
    800029ba:	cc9c                	sw	a5,24(s1)
        kt->process=p;
    800029bc:	0334bc23          	sd	s3,56(s1)
        kt->trapframe = get_kthread_trapframe(p,kt);
    800029c0:	85a6                	mv	a1,s1
    800029c2:	854e                	mv	a0,s3
    800029c4:	00000097          	auipc	ra,0x0
    800029c8:	f70080e7          	jalr	-144(ra) # 80002934 <get_kthread_trapframe>
    800029cc:	fcc8                	sd	a0,184(s1)
        memset(&kt->context, 0, sizeof(kt->context));   
    800029ce:	07000613          	li	a2,112
    800029d2:	4581                	li	a1,0
    800029d4:	04048513          	addi	a0,s1,64
    800029d8:	ffffe097          	auipc	ra,0xffffe
    800029dc:	2fa080e7          	jalr	762(ra) # 80000cd2 <memset>
        kt->context.ra = (uint64)forkret;
    800029e0:	fffff797          	auipc	a5,0xfffff
    800029e4:	74678793          	addi	a5,a5,1862 # 80002126 <forkret>
    800029e8:	e0bc                	sd	a5,64(s1)
        kt->context.sp = kt->kstack + PGSIZE;
    800029ea:	78dc                	ld	a5,176(s1)
    800029ec:	6705                	lui	a4,0x1
    800029ee:	97ba                	add	a5,a5,a4
    800029f0:	e4bc                	sd	a5,72(s1)
        return kt;
    800029f2:	b76d                	j	8000299c <allockthread+0x3a>

00000000800029f4 <freethread>:

void
freethread(struct kthread *t){
    800029f4:	1101                	addi	sp,sp,-32
    800029f6:	ec06                	sd	ra,24(sp)
    800029f8:	e822                	sd	s0,16(sp)
    800029fa:	e426                	sd	s1,8(sp)
    800029fc:	1000                	addi	s0,sp,32
    800029fe:	84aa                	mv	s1,a0
  t->chan = 0;
    80002a00:	02053023          	sd	zero,32(a0)
  t->t_killed = 0;
    80002a04:	02052423          	sw	zero,40(a0)
  t->t_xstate = 0;
    80002a08:	02052623          	sw	zero,44(a0)
  t->t_state = UNUSED_t;
    80002a0c:	00052c23          	sw	zero,24(a0)
  t->tid=0;
    80002a10:	02052823          	sw	zero,48(a0)
  t->process=0;
    80002a14:	02053c23          	sd	zero,56(a0)
  t->trapframe = 0;
    80002a18:	0a053c23          	sd	zero,184(a0)
  memset(&t->context,0,sizeof(&t->context));
    80002a1c:	4621                	li	a2,8
    80002a1e:	4581                	li	a1,0
    80002a20:	04050513          	addi	a0,a0,64
    80002a24:	ffffe097          	auipc	ra,0xffffe
    80002a28:	2ae080e7          	jalr	686(ra) # 80000cd2 <memset>
  release(&t->t_lock);
    80002a2c:	8526                	mv	a0,s1
    80002a2e:	ffffe097          	auipc	ra,0xffffe
    80002a32:	25c080e7          	jalr	604(ra) # 80000c8a <release>
}
    80002a36:	60e2                	ld	ra,24(sp)
    80002a38:	6442                	ld	s0,16(sp)
    80002a3a:	64a2                	ld	s1,8(sp)
    80002a3c:	6105                	addi	sp,sp,32
    80002a3e:	8082                	ret

0000000080002a40 <kthread_create>:

// find UNUSED thread from the calling proc 
// set state to runnable , alloc stack(malloc)-4000 bytes(macro),
//set epc to start_func,sp to top of the stack
// return tid or -1 if no UNUSED thread found
int kthread_create(void *(*start_func)(), void *stack, uint stack_size){
    80002a40:	7179                	addi	sp,sp,-48
    80002a42:	f406                	sd	ra,40(sp)
    80002a44:	f022                	sd	s0,32(sp)
    80002a46:	ec26                	sd	s1,24(sp)
    80002a48:	e84a                	sd	s2,16(sp)
    80002a4a:	e44e                	sd	s3,8(sp)
    80002a4c:	e052                	sd	s4,0(sp)
    80002a4e:	1800                	addi	s0,sp,48
    80002a50:	8a2a                	mv	s4,a0
    80002a52:	892e                	mv	s2,a1
    80002a54:	89b2                	mv	s3,a2
  //struct proc* p = myproc();
  struct kthread *t = allockthread(myproc());
    80002a56:	fffff097          	auipc	ra,0xfffff
    80002a5a:	f82080e7          	jalr	-126(ra) # 800019d8 <myproc>
    80002a5e:	00000097          	auipc	ra,0x0
    80002a62:	f04080e7          	jalr	-252(ra) # 80002962 <allockthread>
  //printf("pid in kthread_create: %d\n",t->tid);
  // *t = allockthread(p);
  if(t == 0){
    80002a66:	c915                	beqz	a0,80002a9a <kthread_create+0x5a>
    80002a68:	84aa                	mv	s1,a0
   // printf("in kthread created:%d",t->tid);
    return -1;
  }
  t->trapframe->epc = (uint64)start_func;
    80002a6a:	7d5c                	ld	a5,184(a0)
    80002a6c:	0147bc23          	sd	s4,24(a5)
  t->trapframe->sp = (uint64)(stack + stack_size);
    80002a70:	7d5c                	ld	a5,184(a0)
    80002a72:	02099593          	slli	a1,s3,0x20
    80002a76:	9181                	srli	a1,a1,0x20
    80002a78:	95ca                	add	a1,a1,s2
    80002a7a:	fb8c                	sd	a1,48(a5)
  t->t_state = RUNNABLE_t;
    80002a7c:	478d                	li	a5,3
    80002a7e:	cd1c                	sw	a5,24(a0)
  release(&t->t_lock);
    80002a80:	ffffe097          	auipc	ra,0xffffe
    80002a84:	20a080e7          	jalr	522(ra) # 80000c8a <release>
  return t->tid;
    80002a88:	5888                	lw	a0,48(s1)
}
    80002a8a:	70a2                	ld	ra,40(sp)
    80002a8c:	7402                	ld	s0,32(sp)
    80002a8e:	64e2                	ld	s1,24(sp)
    80002a90:	6942                	ld	s2,16(sp)
    80002a92:	69a2                	ld	s3,8(sp)
    80002a94:	6a02                	ld	s4,0(sp)
    80002a96:	6145                	addi	sp,sp,48
    80002a98:	8082                	ret
    return -1;
    80002a9a:	557d                	li	a0,-1
    80002a9c:	b7fd                	j	80002a8a <kthread_create+0x4a>

0000000080002a9e <kthread_kill>:



int kthread_kill(int ktid){
    80002a9e:	7179                	addi	sp,sp,-48
    80002aa0:	f406                	sd	ra,40(sp)
    80002aa2:	f022                	sd	s0,32(sp)
    80002aa4:	ec26                	sd	s1,24(sp)
    80002aa6:	e84a                	sd	s2,16(sp)
    80002aa8:	e44e                	sd	s3,8(sp)
    80002aaa:	1800                	addi	s0,sp,48
    80002aac:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    80002aae:	fffff097          	auipc	ra,0xfffff
    80002ab2:	f2a080e7          	jalr	-214(ra) # 800019d8 <myproc>
  struct kthread *kt;

  for(kt = p->kthread; kt < &p->kthread[NKT]; kt++){
    80002ab6:	02850493          	addi	s1,a0,40
    80002aba:	7a850913          	addi	s2,a0,1960
    acquire(&kt->t_lock);
    80002abe:	8526                	mv	a0,s1
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	116080e7          	jalr	278(ra) # 80000bd6 <acquire>
    if(kt->tid == ktid){
    80002ac8:	589c                	lw	a5,48(s1)
    80002aca:	03378363          	beq	a5,s3,80002af0 <kthread_kill+0x52>
        kt->t_state = RUNNABLE_t;
      }
      release(&kt->t_lock);
      return 0;
    }
    release(&kt->t_lock);
    80002ace:	8526                	mv	a0,s1
    80002ad0:	ffffe097          	auipc	ra,0xffffe
    80002ad4:	1ba080e7          	jalr	442(ra) # 80000c8a <release>
  for(kt = p->kthread; kt < &p->kthread[NKT]; kt++){
    80002ad8:	0c048493          	addi	s1,s1,192
    80002adc:	ff2491e3          	bne	s1,s2,80002abe <kthread_kill+0x20>
  }
  return -1;
    80002ae0:	557d                	li	a0,-1
}
    80002ae2:	70a2                	ld	ra,40(sp)
    80002ae4:	7402                	ld	s0,32(sp)
    80002ae6:	64e2                	ld	s1,24(sp)
    80002ae8:	6942                	ld	s2,16(sp)
    80002aea:	69a2                	ld	s3,8(sp)
    80002aec:	6145                	addi	sp,sp,48
    80002aee:	8082                	ret
      kt->t_killed = 1;
    80002af0:	4785                	li	a5,1
    80002af2:	d49c                	sw	a5,40(s1)
      if(kt->t_state == SLEEPING_t){
    80002af4:	4c98                	lw	a4,24(s1)
    80002af6:	4789                	li	a5,2
    80002af8:	00f70963          	beq	a4,a5,80002b0a <kthread_kill+0x6c>
      release(&kt->t_lock);
    80002afc:	8526                	mv	a0,s1
    80002afe:	ffffe097          	auipc	ra,0xffffe
    80002b02:	18c080e7          	jalr	396(ra) # 80000c8a <release>
      return 0;
    80002b06:	4501                	li	a0,0
    80002b08:	bfe9                	j	80002ae2 <kthread_kill+0x44>
        kt->t_state = RUNNABLE_t;
    80002b0a:	478d                	li	a5,3
    80002b0c:	cc9c                	sw	a5,24(s1)
    80002b0e:	b7fd                	j	80002afc <kthread_kill+0x5e>

0000000080002b10 <t_killed>:


int
t_killed(struct kthread *t)
{
    80002b10:	1101                	addi	sp,sp,-32
    80002b12:	ec06                	sd	ra,24(sp)
    80002b14:	e822                	sd	s0,16(sp)
    80002b16:	e426                	sd	s1,8(sp)
    80002b18:	e04a                	sd	s2,0(sp)
    80002b1a:	1000                	addi	s0,sp,32
    80002b1c:	84aa                	mv	s1,a0
  int k;
  acquire(&t->t_lock);
    80002b1e:	ffffe097          	auipc	ra,0xffffe
    80002b22:	0b8080e7          	jalr	184(ra) # 80000bd6 <acquire>
  k = t->t_killed;
    80002b26:	0284a903          	lw	s2,40(s1)
  release(&t->t_lock);
    80002b2a:	8526                	mv	a0,s1
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	15e080e7          	jalr	350(ra) # 80000c8a <release>
  return k;
}
    80002b34:	854a                	mv	a0,s2
    80002b36:	60e2                	ld	ra,24(sp)
    80002b38:	6442                	ld	s0,16(sp)
    80002b3a:	64a2                	ld	s1,8(sp)
    80002b3c:	6902                	ld	s2,0(sp)
    80002b3e:	6105                	addi	sp,sp,32
    80002b40:	8082                	ret

0000000080002b42 <if_last_thread>:


//checks if kt  is the last thread of its process p.
//The function returns 1 if kt is the last thread and 0 otherwise.
int
if_last_thread(struct kthread *kt){
    80002b42:	7179                	addi	sp,sp,-48
    80002b44:	f406                	sd	ra,40(sp)
    80002b46:	f022                	sd	s0,32(sp)
    80002b48:	ec26                	sd	s1,24(sp)
    80002b4a:	e84a                	sd	s2,16(sp)
    80002b4c:	e44e                	sd	s3,8(sp)
    80002b4e:	e052                	sd	s4,0(sp)
    80002b50:	1800                	addi	s0,sp,48
    80002b52:	89aa                	mv	s3,a0
  struct kthread* t;
  struct proc *p = myproc();
    80002b54:	fffff097          	auipc	ra,0xfffff
    80002b58:	e84080e7          	jalr	-380(ra) # 800019d8 <myproc>
  for(t = p->kthread; t < &p->kthread[NKT]; t++){
    80002b5c:	02850493          	addi	s1,a0,40
    80002b60:	7a850913          	addi	s2,a0,1960
    if(t != kt){
      acquire(&t->t_lock);
      if(t->t_state != UNUSED_t && t->t_state != ZOMBIE_t){
    80002b64:	4a15                	li	s4,5
    80002b66:	a811                	j	80002b7a <if_last_thread+0x38>
        release(&t->t_lock);
        return 0;
      }
      release(&t->t_lock);
    80002b68:	8526                	mv	a0,s1
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	120080e7          	jalr	288(ra) # 80000c8a <release>
  for(t = p->kthread; t < &p->kthread[NKT]; t++){
    80002b72:	0c048493          	addi	s1,s1,192
    80002b76:	03248463          	beq	s1,s2,80002b9e <if_last_thread+0x5c>
    if(t != kt){
    80002b7a:	fe998ce3          	beq	s3,s1,80002b72 <if_last_thread+0x30>
      acquire(&t->t_lock);
    80002b7e:	8526                	mv	a0,s1
    80002b80:	ffffe097          	auipc	ra,0xffffe
    80002b84:	056080e7          	jalr	86(ra) # 80000bd6 <acquire>
      if(t->t_state != UNUSED_t && t->t_state != ZOMBIE_t){
    80002b88:	4c9c                	lw	a5,24(s1)
    80002b8a:	dff9                	beqz	a5,80002b68 <if_last_thread+0x26>
    80002b8c:	fd478ee3          	beq	a5,s4,80002b68 <if_last_thread+0x26>
        release(&t->t_lock);
    80002b90:	8526                	mv	a0,s1
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	0f8080e7          	jalr	248(ra) # 80000c8a <release>
        return 0;
    80002b9a:	4501                	li	a0,0
    80002b9c:	a011                	j	80002ba0 <if_last_thread+0x5e>
    }
  }
  return 1;
    80002b9e:	4505                	li	a0,1
}
    80002ba0:	70a2                	ld	ra,40(sp)
    80002ba2:	7402                	ld	s0,32(sp)
    80002ba4:	64e2                	ld	s1,24(sp)
    80002ba6:	6942                	ld	s2,16(sp)
    80002ba8:	69a2                	ld	s3,8(sp)
    80002baa:	6a02                	ld	s4,0(sp)
    80002bac:	6145                	addi	sp,sp,48
    80002bae:	8082                	ret

0000000080002bb0 <kthread_exit>:

void
kthread_exit(int status){
    80002bb0:	7179                	addi	sp,sp,-48
    80002bb2:	f406                	sd	ra,40(sp)
    80002bb4:	f022                	sd	s0,32(sp)
    80002bb6:	ec26                	sd	s1,24(sp)
    80002bb8:	e84a                	sd	s2,16(sp)
    80002bba:	e44e                	sd	s3,8(sp)
    80002bbc:	1800                	addi	s0,sp,48
    80002bbe:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    80002bc0:	fffff097          	auipc	ra,0xfffff
    80002bc4:	e18080e7          	jalr	-488(ra) # 800019d8 <myproc>
    80002bc8:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80002bca:	00000097          	auipc	ra,0x0
    80002bce:	cf0080e7          	jalr	-784(ra) # 800028ba <mykthread>
    80002bd2:	84aa                	mv	s1,a0

  if(if_last_thread(t)){
    80002bd4:	00000097          	auipc	ra,0x0
    80002bd8:	f6e080e7          	jalr	-146(ra) # 80002b42 <if_last_thread>
    80002bdc:	ed39                	bnez	a0,80002c3a <kthread_exit+0x8a>
    exit(status);
  }
  
  acquire(&t->t_lock);
    80002bde:	8526                	mv	a0,s1
    80002be0:	ffffe097          	auipc	ra,0xffffe
    80002be4:	ff6080e7          	jalr	-10(ra) # 80000bd6 <acquire>
  t->t_state = ZOMBIE_t;
    80002be8:	4795                	li	a5,5
    80002bea:	cc9c                	sw	a5,24(s1)
  t->t_xstate = status;
    80002bec:	0334a623          	sw	s3,44(s1)
  release(&t->t_lock);
    80002bf0:	8526                	mv	a0,s1
    80002bf2:	ffffe097          	auipc	ra,0xffffe
    80002bf6:	098080e7          	jalr	152(ra) # 80000c8a <release>
  
  acquire(&p->lock); 
    80002bfa:	854a                	mv	a0,s2
    80002bfc:	ffffe097          	auipc	ra,0xffffe
    80002c00:	fda080e7          	jalr	-38(ra) # 80000bd6 <acquire>
  wakeup(t);
    80002c04:	8526                	mv	a0,s1
    80002c06:	fffff097          	auipc	ra,0xfffff
    80002c0a:	5ca080e7          	jalr	1482(ra) # 800021d0 <wakeup>
  release(&p->lock);
    80002c0e:	854a                	mv	a0,s2
    80002c10:	ffffe097          	auipc	ra,0xffffe
    80002c14:	07a080e7          	jalr	122(ra) # 80000c8a <release>
  
  acquire(&t->t_lock);
    80002c18:	8526                	mv	a0,s1
    80002c1a:	ffffe097          	auipc	ra,0xffffe
    80002c1e:	fbc080e7          	jalr	-68(ra) # 80000bd6 <acquire>
  sched();
    80002c22:	fffff097          	auipc	ra,0xfffff
    80002c26:	3e8080e7          	jalr	1000(ra) # 8000200a <sched>
  panic("zombie exit");
    80002c2a:	00005517          	auipc	a0,0x5
    80002c2e:	64650513          	addi	a0,a0,1606 # 80008270 <digits+0x230>
    80002c32:	ffffe097          	auipc	ra,0xffffe
    80002c36:	90c080e7          	jalr	-1780(ra) # 8000053e <panic>
    exit(status);
    80002c3a:	854e                	mv	a0,s3
    80002c3c:	fffff097          	auipc	ra,0xfffff
    80002c40:	68a080e7          	jalr	1674(ra) # 800022c6 <exit>
    80002c44:	bf69                	j	80002bde <kthread_exit+0x2e>

0000000080002c46 <kthread_join>:
}

int 
kthread_join(int ktid, int *status){
    80002c46:	7139                	addi	sp,sp,-64
    80002c48:	fc06                	sd	ra,56(sp)
    80002c4a:	f822                	sd	s0,48(sp)
    80002c4c:	f426                	sd	s1,40(sp)
    80002c4e:	f04a                	sd	s2,32(sp)
    80002c50:	ec4e                	sd	s3,24(sp)
    80002c52:	e852                	sd	s4,16(sp)
    80002c54:	e456                	sd	s5,8(sp)
    80002c56:	e05a                	sd	s6,0(sp)
    80002c58:	0080                	addi	s0,sp,64
    80002c5a:	8a2a                	mv	s4,a0
    80002c5c:	8b2e                	mv	s6,a1
  struct kthread *t_search;
  struct kthread *t_by_ktid=0;
  struct proc *p = myproc();
    80002c5e:	fffff097          	auipc	ra,0xfffff
    80002c62:	d7a080e7          	jalr	-646(ra) # 800019d8 <myproc>
    80002c66:	89aa                	mv	s3,a0
  for(t_search = p->kthread; t_search < &p->kthread[NKT]; t_search++) {
    80002c68:	02850493          	addi	s1,a0,40
    80002c6c:	7a850a93          	addi	s5,a0,1960
  struct kthread *t_by_ktid=0;
    80002c70:	4901                	li	s2,0
    80002c72:	a811                	j	80002c86 <kthread_join+0x40>
    acquire(&t_search->t_lock);
    if (t_search->tid==ktid){
      t_by_ktid=t_search;
    }
    release(&t_search->t_lock);
    80002c74:	8526                	mv	a0,s1
    80002c76:	ffffe097          	auipc	ra,0xffffe
    80002c7a:	014080e7          	jalr	20(ra) # 80000c8a <release>
  for(t_search = p->kthread; t_search < &p->kthread[NKT]; t_search++) {
    80002c7e:	0c048493          	addi	s1,s1,192
    80002c82:	01548c63          	beq	s1,s5,80002c9a <kthread_join+0x54>
    acquire(&t_search->t_lock);
    80002c86:	8526                	mv	a0,s1
    80002c88:	ffffe097          	auipc	ra,0xffffe
    80002c8c:	f4e080e7          	jalr	-178(ra) # 80000bd6 <acquire>
    if (t_search->tid==ktid){
    80002c90:	589c                	lw	a5,48(s1)
    80002c92:	ff4791e3          	bne	a5,s4,80002c74 <kthread_join+0x2e>
    80002c96:	8926                	mv	s2,s1
    80002c98:	bff1                	j	80002c74 <kthread_join+0x2e>
 }
  if(t_by_ktid== 0){
    80002c9a:	08090d63          	beqz	s2,80002d34 <kthread_join+0xee>
      return -1;
  }

  acquire(&p->lock);
    80002c9e:	854e                	mv	a0,s3
    80002ca0:	ffffe097          	auipc	ra,0xffffe
    80002ca4:	f36080e7          	jalr	-202(ra) # 80000bd6 <acquire>
  for(;;){
    if(t_by_ktid->t_state == ZOMBIE_t){
    80002ca8:	01892703          	lw	a4,24(s2)
    80002cac:	4795                	li	a5,5
    80002cae:	4495                	li	s1,5
    80002cb0:	00f70c63          	beq	a4,a5,80002cc8 <kthread_join+0x82>
      freethread(t_by_ktid);
      release(&p->lock);
      return 0;
    }

    sleep(t_by_ktid, &p->lock);
    80002cb4:	85ce                	mv	a1,s3
    80002cb6:	854a                	mv	a0,s2
    80002cb8:	fffff097          	auipc	ra,0xfffff
    80002cbc:	4b4080e7          	jalr	1204(ra) # 8000216c <sleep>
    if(t_by_ktid->t_state == ZOMBIE_t){
    80002cc0:	01892783          	lw	a5,24(s2)
    80002cc4:	fe9798e3          	bne	a5,s1,80002cb4 <kthread_join+0x6e>
      acquire(&t_by_ktid->t_lock);
    80002cc8:	854a                	mv	a0,s2
    80002cca:	ffffe097          	auipc	ra,0xffffe
    80002cce:	f0c080e7          	jalr	-244(ra) # 80000bd6 <acquire>
      if(status != 0 && copyout(t_by_ktid->process->pagetable, (uint64) status, (char *)&t_by_ktid->t_xstate,
    80002cd2:	020b0063          	beqz	s6,80002cf2 <kthread_join+0xac>
    80002cd6:	03893783          	ld	a5,56(s2)
    80002cda:	4691                	li	a3,4
    80002cdc:	02c90613          	addi	a2,s2,44
    80002ce0:	85da                	mv	a1,s6
    80002ce2:	7c07b503          	ld	a0,1984(a5)
    80002ce6:	fffff097          	auipc	ra,0xfffff
    80002cea:	982080e7          	jalr	-1662(ra) # 80001668 <copyout>
    80002cee:	02054763          	bltz	a0,80002d1c <kthread_join+0xd6>
      freethread(t_by_ktid);
    80002cf2:	854a                	mv	a0,s2
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	d00080e7          	jalr	-768(ra) # 800029f4 <freethread>
      release(&p->lock);
    80002cfc:	854e                	mv	a0,s3
    80002cfe:	ffffe097          	auipc	ra,0xffffe
    80002d02:	f8c080e7          	jalr	-116(ra) # 80000c8a <release>
      return 0;
    80002d06:	4501                	li	a0,0
  }
}
    80002d08:	70e2                	ld	ra,56(sp)
    80002d0a:	7442                	ld	s0,48(sp)
    80002d0c:	74a2                	ld	s1,40(sp)
    80002d0e:	7902                	ld	s2,32(sp)
    80002d10:	69e2                	ld	s3,24(sp)
    80002d12:	6a42                	ld	s4,16(sp)
    80002d14:	6aa2                	ld	s5,8(sp)
    80002d16:	6b02                	ld	s6,0(sp)
    80002d18:	6121                	addi	sp,sp,64
    80002d1a:	8082                	ret
        release(&t_by_ktid->t_lock);
    80002d1c:	854a                	mv	a0,s2
    80002d1e:	ffffe097          	auipc	ra,0xffffe
    80002d22:	f6c080e7          	jalr	-148(ra) # 80000c8a <release>
        release(&p->lock);
    80002d26:	854e                	mv	a0,s3
    80002d28:	ffffe097          	auipc	ra,0xffffe
    80002d2c:	f62080e7          	jalr	-158(ra) # 80000c8a <release>
        return -1;
    80002d30:	557d                	li	a0,-1
    80002d32:	bfd9                	j	80002d08 <kthread_join+0xc2>
      return -1;
    80002d34:	557d                	li	a0,-1
    80002d36:	bfc9                	j	80002d08 <kthread_join+0xc2>

0000000080002d38 <swtch>:
    80002d38:	00153023          	sd	ra,0(a0)
    80002d3c:	00253423          	sd	sp,8(a0)
    80002d40:	e900                	sd	s0,16(a0)
    80002d42:	ed04                	sd	s1,24(a0)
    80002d44:	03253023          	sd	s2,32(a0)
    80002d48:	03353423          	sd	s3,40(a0)
    80002d4c:	03453823          	sd	s4,48(a0)
    80002d50:	03553c23          	sd	s5,56(a0)
    80002d54:	05653023          	sd	s6,64(a0)
    80002d58:	05753423          	sd	s7,72(a0)
    80002d5c:	05853823          	sd	s8,80(a0)
    80002d60:	05953c23          	sd	s9,88(a0)
    80002d64:	07a53023          	sd	s10,96(a0)
    80002d68:	07b53423          	sd	s11,104(a0)
    80002d6c:	0005b083          	ld	ra,0(a1)
    80002d70:	0085b103          	ld	sp,8(a1)
    80002d74:	6980                	ld	s0,16(a1)
    80002d76:	6d84                	ld	s1,24(a1)
    80002d78:	0205b903          	ld	s2,32(a1)
    80002d7c:	0285b983          	ld	s3,40(a1)
    80002d80:	0305ba03          	ld	s4,48(a1)
    80002d84:	0385ba83          	ld	s5,56(a1)
    80002d88:	0405bb03          	ld	s6,64(a1)
    80002d8c:	0485bb83          	ld	s7,72(a1)
    80002d90:	0505bc03          	ld	s8,80(a1)
    80002d94:	0585bc83          	ld	s9,88(a1)
    80002d98:	0605bd03          	ld	s10,96(a1)
    80002d9c:	0685bd83          	ld	s11,104(a1)
    80002da0:	8082                	ret

0000000080002da2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002da2:	1141                	addi	sp,sp,-16
    80002da4:	e406                	sd	ra,8(sp)
    80002da6:	e022                	sd	s0,0(sp)
    80002da8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002daa:	00005597          	auipc	a1,0x5
    80002dae:	53e58593          	addi	a1,a1,1342 # 800082e8 <states.0+0x38>
    80002db2:	00030517          	auipc	a0,0x30
    80002db6:	1ee50513          	addi	a0,a0,494 # 80032fa0 <tickslock>
    80002dba:	ffffe097          	auipc	ra,0xffffe
    80002dbe:	d8c080e7          	jalr	-628(ra) # 80000b46 <initlock>
}
    80002dc2:	60a2                	ld	ra,8(sp)
    80002dc4:	6402                	ld	s0,0(sp)
    80002dc6:	0141                	addi	sp,sp,16
    80002dc8:	8082                	ret

0000000080002dca <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002dca:	1141                	addi	sp,sp,-16
    80002dcc:	e422                	sd	s0,8(sp)
    80002dce:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002dd0:	00003797          	auipc	a5,0x3
    80002dd4:	6d078793          	addi	a5,a5,1744 # 800064a0 <kernelvec>
    80002dd8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ddc:	6422                	ld	s0,8(sp)
    80002dde:	0141                	addi	sp,sp,16
    80002de0:	8082                	ret

0000000080002de2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002de2:	1101                	addi	sp,sp,-32
    80002de4:	ec06                	sd	ra,24(sp)
    80002de6:	e822                	sd	s0,16(sp)
    80002de8:	e426                	sd	s1,8(sp)
    80002dea:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002dec:	fffff097          	auipc	ra,0xfffff
    80002df0:	bec080e7          	jalr	-1044(ra) # 800019d8 <myproc>
    80002df4:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    80002df6:	00000097          	auipc	ra,0x0
    80002dfa:	ac4080e7          	jalr	-1340(ra) # 800028ba <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dfe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002e02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e04:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002e08:	00004617          	auipc	a2,0x4
    80002e0c:	1f860613          	addi	a2,a2,504 # 80007000 <_trampoline>
    80002e10:	00004697          	auipc	a3,0x4
    80002e14:	1f068693          	addi	a3,a3,496 # 80007000 <_trampoline>
    80002e18:	8e91                	sub	a3,a3,a2
    80002e1a:	040007b7          	lui	a5,0x4000
    80002e1e:	17fd                	addi	a5,a5,-1
    80002e20:	07b2                	slli	a5,a5,0xc
    80002e22:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e24:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  kt->trapframe->kernel_satp = r_satp();         // kernel page table
    80002e28:	7d58                	ld	a4,184(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002e2a:	180026f3          	csrr	a3,satp
    80002e2e:	e314                	sd	a3,0(a4)
  kt->trapframe->kernel_sp = kt->kstack + PGSIZE; // process's kernel stack
    80002e30:	7d58                	ld	a4,184(a0)
    80002e32:	7954                	ld	a3,176(a0)
    80002e34:	6585                	lui	a1,0x1
    80002e36:	96ae                	add	a3,a3,a1
    80002e38:	e714                	sd	a3,8(a4)
  kt->trapframe->kernel_trap = (uint64)usertrap;
    80002e3a:	7d58                	ld	a4,184(a0)
    80002e3c:	00000697          	auipc	a3,0x0
    80002e40:	15e68693          	addi	a3,a3,350 # 80002f9a <usertrap>
    80002e44:	eb14                	sd	a3,16(a4)
  kt->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002e46:	7d58                	ld	a4,184(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002e48:	8692                	mv	a3,tp
    80002e4a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e4c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002e50:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002e54:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e58:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(kt->trapframe->epc);
    80002e5c:	7d58                	ld	a4,184(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e5e:	6f18                	ld	a4,24(a4)
    80002e60:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002e64:	7c04b583          	ld	a1,1984(s1)
    80002e68:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002e6a:	02848493          	addi	s1,s1,40
    80002e6e:	8d05                	sub	a0,a0,s1
    80002e70:	8519                	srai	a0,a0,0x6
    80002e72:	00005717          	auipc	a4,0x5
    80002e76:	19673703          	ld	a4,406(a4) # 80008008 <etext+0x8>
    80002e7a:	02e50533          	mul	a0,a0,a4
    80002e7e:	1502                	slli	a0,a0,0x20
    80002e80:	9101                	srli	a0,a0,0x20
    80002e82:	00351693          	slli	a3,a0,0x3
    80002e86:	9536                	add	a0,a0,a3
    80002e88:	0516                	slli	a0,a0,0x5
    80002e8a:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002e8e:	00004717          	auipc	a4,0x4
    80002e92:	20670713          	addi	a4,a4,518 # 80007094 <userret>
    80002e96:	8f11                	sub	a4,a4,a2
    80002e98:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME((uint)(kt - p->kthread)), satp);
    80002e9a:	577d                	li	a4,-1
    80002e9c:	177e                	slli	a4,a4,0x3f
    80002e9e:	8dd9                	or	a1,a1,a4
    80002ea0:	16fd                	addi	a3,a3,-1
    80002ea2:	06b6                	slli	a3,a3,0xd
    80002ea4:	9536                	add	a0,a0,a3
    80002ea6:	9782                	jalr	a5
}
    80002ea8:	60e2                	ld	ra,24(sp)
    80002eaa:	6442                	ld	s0,16(sp)
    80002eac:	64a2                	ld	s1,8(sp)
    80002eae:	6105                	addi	sp,sp,32
    80002eb0:	8082                	ret

0000000080002eb2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002eb2:	1101                	addi	sp,sp,-32
    80002eb4:	ec06                	sd	ra,24(sp)
    80002eb6:	e822                	sd	s0,16(sp)
    80002eb8:	e426                	sd	s1,8(sp)
    80002eba:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ebc:	00030497          	auipc	s1,0x30
    80002ec0:	0e448493          	addi	s1,s1,228 # 80032fa0 <tickslock>
    80002ec4:	8526                	mv	a0,s1
    80002ec6:	ffffe097          	auipc	ra,0xffffe
    80002eca:	d10080e7          	jalr	-752(ra) # 80000bd6 <acquire>
  ticks++;
    80002ece:	00006517          	auipc	a0,0x6
    80002ed2:	a3250513          	addi	a0,a0,-1486 # 80008900 <ticks>
    80002ed6:	411c                	lw	a5,0(a0)
    80002ed8:	2785                	addiw	a5,a5,1
    80002eda:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002edc:	fffff097          	auipc	ra,0xfffff
    80002ee0:	2f4080e7          	jalr	756(ra) # 800021d0 <wakeup>
  release(&tickslock);
    80002ee4:	8526                	mv	a0,s1
    80002ee6:	ffffe097          	auipc	ra,0xffffe
    80002eea:	da4080e7          	jalr	-604(ra) # 80000c8a <release>
}
    80002eee:	60e2                	ld	ra,24(sp)
    80002ef0:	6442                	ld	s0,16(sp)
    80002ef2:	64a2                	ld	s1,8(sp)
    80002ef4:	6105                	addi	sp,sp,32
    80002ef6:	8082                	ret

0000000080002ef8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002ef8:	1101                	addi	sp,sp,-32
    80002efa:	ec06                	sd	ra,24(sp)
    80002efc:	e822                	sd	s0,16(sp)
    80002efe:	e426                	sd	s1,8(sp)
    80002f00:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f02:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002f06:	00074d63          	bltz	a4,80002f20 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002f0a:	57fd                	li	a5,-1
    80002f0c:	17fe                	slli	a5,a5,0x3f
    80002f0e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002f10:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002f12:	06f70363          	beq	a4,a5,80002f78 <devintr+0x80>
  }
    80002f16:	60e2                	ld	ra,24(sp)
    80002f18:	6442                	ld	s0,16(sp)
    80002f1a:	64a2                	ld	s1,8(sp)
    80002f1c:	6105                	addi	sp,sp,32
    80002f1e:	8082                	ret
     (scause & 0xff) == 9){
    80002f20:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002f24:	46a5                	li	a3,9
    80002f26:	fed792e3          	bne	a5,a3,80002f0a <devintr+0x12>
    int irq = plic_claim();
    80002f2a:	00003097          	auipc	ra,0x3
    80002f2e:	67e080e7          	jalr	1662(ra) # 800065a8 <plic_claim>
    80002f32:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002f34:	47a9                	li	a5,10
    80002f36:	02f50763          	beq	a0,a5,80002f64 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002f3a:	4785                	li	a5,1
    80002f3c:	02f50963          	beq	a0,a5,80002f6e <devintr+0x76>
    return 1;
    80002f40:	4505                	li	a0,1
    } else if(irq){
    80002f42:	d8f1                	beqz	s1,80002f16 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002f44:	85a6                	mv	a1,s1
    80002f46:	00005517          	auipc	a0,0x5
    80002f4a:	3aa50513          	addi	a0,a0,938 # 800082f0 <states.0+0x40>
    80002f4e:	ffffd097          	auipc	ra,0xffffd
    80002f52:	63a080e7          	jalr	1594(ra) # 80000588 <printf>
      plic_complete(irq);
    80002f56:	8526                	mv	a0,s1
    80002f58:	00003097          	auipc	ra,0x3
    80002f5c:	674080e7          	jalr	1652(ra) # 800065cc <plic_complete>
    return 1;
    80002f60:	4505                	li	a0,1
    80002f62:	bf55                	j	80002f16 <devintr+0x1e>
      uartintr();
    80002f64:	ffffe097          	auipc	ra,0xffffe
    80002f68:	a36080e7          	jalr	-1482(ra) # 8000099a <uartintr>
    80002f6c:	b7ed                	j	80002f56 <devintr+0x5e>
      virtio_disk_intr();
    80002f6e:	00004097          	auipc	ra,0x4
    80002f72:	b2a080e7          	jalr	-1238(ra) # 80006a98 <virtio_disk_intr>
    80002f76:	b7c5                	j	80002f56 <devintr+0x5e>
    if(cpuid() == 0){
    80002f78:	fffff097          	auipc	ra,0xfffff
    80002f7c:	a34080e7          	jalr	-1484(ra) # 800019ac <cpuid>
    80002f80:	c901                	beqz	a0,80002f90 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002f82:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002f86:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002f88:	14479073          	csrw	sip,a5
    return 2;
    80002f8c:	4509                	li	a0,2
    80002f8e:	b761                	j	80002f16 <devintr+0x1e>
      clockintr();
    80002f90:	00000097          	auipc	ra,0x0
    80002f94:	f22080e7          	jalr	-222(ra) # 80002eb2 <clockintr>
    80002f98:	b7ed                	j	80002f82 <devintr+0x8a>

0000000080002f9a <usertrap>:
{
    80002f9a:	7179                	addi	sp,sp,-48
    80002f9c:	f406                	sd	ra,40(sp)
    80002f9e:	f022                	sd	s0,32(sp)
    80002fa0:	ec26                	sd	s1,24(sp)
    80002fa2:	e84a                	sd	s2,16(sp)
    80002fa4:	e44e                	sd	s3,8(sp)
    80002fa6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fa8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002fac:	1007f793          	andi	a5,a5,256
    80002fb0:	ebb5                	bnez	a5,80003024 <usertrap+0x8a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002fb2:	00003797          	auipc	a5,0x3
    80002fb6:	4ee78793          	addi	a5,a5,1262 # 800064a0 <kernelvec>
    80002fba:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002fbe:	fffff097          	auipc	ra,0xfffff
    80002fc2:	a1a080e7          	jalr	-1510(ra) # 800019d8 <myproc>
    80002fc6:	89aa                	mv	s3,a0
  struct kthread *kt = mykthread();
    80002fc8:	00000097          	auipc	ra,0x0
    80002fcc:	8f2080e7          	jalr	-1806(ra) # 800028ba <mykthread>
    80002fd0:	84aa                	mv	s1,a0
  kt->trapframe->epc = r_sepc();
    80002fd2:	7d5c                	ld	a5,184(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fd4:	14102773          	csrr	a4,sepc
    80002fd8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fda:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002fde:	47a1                	li	a5,8
    80002fe0:	04f70a63          	beq	a4,a5,80003034 <usertrap+0x9a>
  } else if((which_dev = devintr()) != 0){
    80002fe4:	00000097          	auipc	ra,0x0
    80002fe8:	f14080e7          	jalr	-236(ra) # 80002ef8 <devintr>
    80002fec:	892a                	mv	s2,a0
    80002fee:	c959                	beqz	a0,80003084 <usertrap+0xea>
    if(killed(p))
    80002ff0:	854e                	mv	a0,s3
    80002ff2:	fffff097          	auipc	ra,0xfffff
    80002ff6:	538080e7          	jalr	1336(ra) # 8000252a <killed>
    80002ffa:	e179                	bnez	a0,800030c0 <usertrap+0x126>
    if(t_killed(kt))
    80002ffc:	8526                	mv	a0,s1
    80002ffe:	00000097          	auipc	ra,0x0
    80003002:	b12080e7          	jalr	-1262(ra) # 80002b10 <t_killed>
    80003006:	e179                	bnez	a0,800030cc <usertrap+0x132>
  if(which_dev == 2)
    80003008:	4789                	li	a5,2
    8000300a:	0cf90763          	beq	s2,a5,800030d8 <usertrap+0x13e>
  usertrapret();
    8000300e:	00000097          	auipc	ra,0x0
    80003012:	dd4080e7          	jalr	-556(ra) # 80002de2 <usertrapret>
}
    80003016:	70a2                	ld	ra,40(sp)
    80003018:	7402                	ld	s0,32(sp)
    8000301a:	64e2                	ld	s1,24(sp)
    8000301c:	6942                	ld	s2,16(sp)
    8000301e:	69a2                	ld	s3,8(sp)
    80003020:	6145                	addi	sp,sp,48
    80003022:	8082                	ret
    panic("usertrap: not from user mode");
    80003024:	00005517          	auipc	a0,0x5
    80003028:	2ec50513          	addi	a0,a0,748 # 80008310 <states.0+0x60>
    8000302c:	ffffd097          	auipc	ra,0xffffd
    80003030:	512080e7          	jalr	1298(ra) # 8000053e <panic>
    if(killed(p))
    80003034:	854e                	mv	a0,s3
    80003036:	fffff097          	auipc	ra,0xfffff
    8000303a:	4f4080e7          	jalr	1268(ra) # 8000252a <killed>
    8000303e:	e51d                	bnez	a0,8000306c <usertrap+0xd2>
    if(t_killed(kt))
    80003040:	8526                	mv	a0,s1
    80003042:	00000097          	auipc	ra,0x0
    80003046:	ace080e7          	jalr	-1330(ra) # 80002b10 <t_killed>
    8000304a:	e51d                	bnez	a0,80003078 <usertrap+0xde>
    kt->trapframe->epc += 4;
    8000304c:	7cd8                	ld	a4,184(s1)
    8000304e:	6f1c                	ld	a5,24(a4)
    80003050:	0791                	addi	a5,a5,4
    80003052:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003054:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003058:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000305c:	10079073          	csrw	sstatus,a5
    syscall();
    80003060:	00000097          	auipc	ra,0x0
    80003064:	2d2080e7          	jalr	722(ra) # 80003332 <syscall>
  int which_dev = 0;
    80003068:	4901                	li	s2,0
    8000306a:	b759                	j	80002ff0 <usertrap+0x56>
      exit(-1);
    8000306c:	557d                	li	a0,-1
    8000306e:	fffff097          	auipc	ra,0xfffff
    80003072:	258080e7          	jalr	600(ra) # 800022c6 <exit>
    80003076:	b7e9                	j	80003040 <usertrap+0xa6>
      kthread_exit(-1);
    80003078:	557d                	li	a0,-1
    8000307a:	00000097          	auipc	ra,0x0
    8000307e:	b36080e7          	jalr	-1226(ra) # 80002bb0 <kthread_exit>
    80003082:	b7e9                	j	8000304c <usertrap+0xb2>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003084:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003088:	0249a603          	lw	a2,36(s3)
    8000308c:	00005517          	auipc	a0,0x5
    80003090:	2a450513          	addi	a0,a0,676 # 80008330 <states.0+0x80>
    80003094:	ffffd097          	auipc	ra,0xffffd
    80003098:	4f4080e7          	jalr	1268(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000309c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030a0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030a4:	00005517          	auipc	a0,0x5
    800030a8:	2bc50513          	addi	a0,a0,700 # 80008360 <states.0+0xb0>
    800030ac:	ffffd097          	auipc	ra,0xffffd
    800030b0:	4dc080e7          	jalr	1244(ra) # 80000588 <printf>
    setkilled(p);
    800030b4:	854e                	mv	a0,s3
    800030b6:	fffff097          	auipc	ra,0xfffff
    800030ba:	448080e7          	jalr	1096(ra) # 800024fe <setkilled>
    800030be:	bf0d                	j	80002ff0 <usertrap+0x56>
      exit(-1);
    800030c0:	557d                	li	a0,-1
    800030c2:	fffff097          	auipc	ra,0xfffff
    800030c6:	204080e7          	jalr	516(ra) # 800022c6 <exit>
    800030ca:	bf0d                	j	80002ffc <usertrap+0x62>
      kthread_exit(-1);
    800030cc:	557d                	li	a0,-1
    800030ce:	00000097          	auipc	ra,0x0
    800030d2:	ae2080e7          	jalr	-1310(ra) # 80002bb0 <kthread_exit>
    800030d6:	bf0d                	j	80003008 <usertrap+0x6e>
    yield();
    800030d8:	fffff097          	auipc	ra,0xfffff
    800030dc:	008080e7          	jalr	8(ra) # 800020e0 <yield>
    800030e0:	b73d                	j	8000300e <usertrap+0x74>

00000000800030e2 <kerneltrap>:
{
    800030e2:	7179                	addi	sp,sp,-48
    800030e4:	f406                	sd	ra,40(sp)
    800030e6:	f022                	sd	s0,32(sp)
    800030e8:	ec26                	sd	s1,24(sp)
    800030ea:	e84a                	sd	s2,16(sp)
    800030ec:	e44e                	sd	s3,8(sp)
    800030ee:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030f0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030f4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030f8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800030fc:	1004f793          	andi	a5,s1,256
    80003100:	cb85                	beqz	a5,80003130 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003102:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003106:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003108:	ef85                	bnez	a5,80003140 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000310a:	00000097          	auipc	ra,0x0
    8000310e:	dee080e7          	jalr	-530(ra) # 80002ef8 <devintr>
    80003112:	cd1d                	beqz	a0,80003150 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    80003114:	4789                	li	a5,2
    80003116:	06f50a63          	beq	a0,a5,8000318a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000311a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000311e:	10049073          	csrw	sstatus,s1
}
    80003122:	70a2                	ld	ra,40(sp)
    80003124:	7402                	ld	s0,32(sp)
    80003126:	64e2                	ld	s1,24(sp)
    80003128:	6942                	ld	s2,16(sp)
    8000312a:	69a2                	ld	s3,8(sp)
    8000312c:	6145                	addi	sp,sp,48
    8000312e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003130:	00005517          	auipc	a0,0x5
    80003134:	25050513          	addi	a0,a0,592 # 80008380 <states.0+0xd0>
    80003138:	ffffd097          	auipc	ra,0xffffd
    8000313c:	406080e7          	jalr	1030(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80003140:	00005517          	auipc	a0,0x5
    80003144:	26850513          	addi	a0,a0,616 # 800083a8 <states.0+0xf8>
    80003148:	ffffd097          	auipc	ra,0xffffd
    8000314c:	3f6080e7          	jalr	1014(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80003150:	85ce                	mv	a1,s3
    80003152:	00005517          	auipc	a0,0x5
    80003156:	27650513          	addi	a0,a0,630 # 800083c8 <states.0+0x118>
    8000315a:	ffffd097          	auipc	ra,0xffffd
    8000315e:	42e080e7          	jalr	1070(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003162:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003166:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000316a:	00005517          	auipc	a0,0x5
    8000316e:	26e50513          	addi	a0,a0,622 # 800083d8 <states.0+0x128>
    80003172:	ffffd097          	auipc	ra,0xffffd
    80003176:	416080e7          	jalr	1046(ra) # 80000588 <printf>
    panic("kerneltrap");
    8000317a:	00005517          	auipc	a0,0x5
    8000317e:	27650513          	addi	a0,a0,630 # 800083f0 <states.0+0x140>
    80003182:	ffffd097          	auipc	ra,0xffffd
    80003186:	3bc080e7          	jalr	956(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->kthread[0].t_state == RUNNING_t)
    8000318a:	fffff097          	auipc	ra,0xfffff
    8000318e:	84e080e7          	jalr	-1970(ra) # 800019d8 <myproc>
    80003192:	d541                	beqz	a0,8000311a <kerneltrap+0x38>
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	844080e7          	jalr	-1980(ra) # 800019d8 <myproc>
    8000319c:	4138                	lw	a4,64(a0)
    8000319e:	4791                	li	a5,4
    800031a0:	f6f71de3          	bne	a4,a5,8000311a <kerneltrap+0x38>
    yield();
    800031a4:	fffff097          	auipc	ra,0xfffff
    800031a8:	f3c080e7          	jalr	-196(ra) # 800020e0 <yield>
    800031ac:	b7bd                	j	8000311a <kerneltrap+0x38>

00000000800031ae <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800031ae:	1101                	addi	sp,sp,-32
    800031b0:	ec06                	sd	ra,24(sp)
    800031b2:	e822                	sd	s0,16(sp)
    800031b4:	e426                	sd	s1,8(sp)
    800031b6:	1000                	addi	s0,sp,32
    800031b8:	84aa                	mv	s1,a0
  struct kthread* kt = mykthread();
    800031ba:	fffff097          	auipc	ra,0xfffff
    800031be:	700080e7          	jalr	1792(ra) # 800028ba <mykthread>
  switch (n) {
    800031c2:	4795                	li	a5,5
    800031c4:	0497e163          	bltu	a5,s1,80003206 <argraw+0x58>
    800031c8:	048a                	slli	s1,s1,0x2
    800031ca:	00005717          	auipc	a4,0x5
    800031ce:	25e70713          	addi	a4,a4,606 # 80008428 <states.0+0x178>
    800031d2:	94ba                	add	s1,s1,a4
    800031d4:	409c                	lw	a5,0(s1)
    800031d6:	97ba                	add	a5,a5,a4
    800031d8:	8782                	jr	a5
  case 0:
    return kt->trapframe->a0;
    800031da:	7d5c                	ld	a5,184(a0)
    800031dc:	7ba8                	ld	a0,112(a5)
  case 5:
    return kt->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800031de:	60e2                	ld	ra,24(sp)
    800031e0:	6442                	ld	s0,16(sp)
    800031e2:	64a2                	ld	s1,8(sp)
    800031e4:	6105                	addi	sp,sp,32
    800031e6:	8082                	ret
    return kt->trapframe->a1;
    800031e8:	7d5c                	ld	a5,184(a0)
    800031ea:	7fa8                	ld	a0,120(a5)
    800031ec:	bfcd                	j	800031de <argraw+0x30>
    return kt->trapframe->a2;
    800031ee:	7d5c                	ld	a5,184(a0)
    800031f0:	63c8                	ld	a0,128(a5)
    800031f2:	b7f5                	j	800031de <argraw+0x30>
    return kt->trapframe->a3;
    800031f4:	7d5c                	ld	a5,184(a0)
    800031f6:	67c8                	ld	a0,136(a5)
    800031f8:	b7dd                	j	800031de <argraw+0x30>
    return kt->trapframe->a4;
    800031fa:	7d5c                	ld	a5,184(a0)
    800031fc:	6bc8                	ld	a0,144(a5)
    800031fe:	b7c5                	j	800031de <argraw+0x30>
    return kt->trapframe->a5;
    80003200:	7d5c                	ld	a5,184(a0)
    80003202:	6fc8                	ld	a0,152(a5)
    80003204:	bfe9                	j	800031de <argraw+0x30>
  panic("argraw");
    80003206:	00005517          	auipc	a0,0x5
    8000320a:	1fa50513          	addi	a0,a0,506 # 80008400 <states.0+0x150>
    8000320e:	ffffd097          	auipc	ra,0xffffd
    80003212:	330080e7          	jalr	816(ra) # 8000053e <panic>

0000000080003216 <fetchaddr>:
{
    80003216:	1101                	addi	sp,sp,-32
    80003218:	ec06                	sd	ra,24(sp)
    8000321a:	e822                	sd	s0,16(sp)
    8000321c:	e426                	sd	s1,8(sp)
    8000321e:	e04a                	sd	s2,0(sp)
    80003220:	1000                	addi	s0,sp,32
    80003222:	84aa                	mv	s1,a0
    80003224:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003226:	ffffe097          	auipc	ra,0xffffe
    8000322a:	7b2080e7          	jalr	1970(ra) # 800019d8 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000322e:	7b853783          	ld	a5,1976(a0)
    80003232:	02f4f963          	bgeu	s1,a5,80003264 <fetchaddr+0x4e>
    80003236:	00848713          	addi	a4,s1,8
    8000323a:	02e7e763          	bltu	a5,a4,80003268 <fetchaddr+0x52>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000323e:	46a1                	li	a3,8
    80003240:	8626                	mv	a2,s1
    80003242:	85ca                	mv	a1,s2
    80003244:	7c053503          	ld	a0,1984(a0)
    80003248:	ffffe097          	auipc	ra,0xffffe
    8000324c:	4ac080e7          	jalr	1196(ra) # 800016f4 <copyin>
    80003250:	00a03533          	snez	a0,a0
    80003254:	40a00533          	neg	a0,a0
}
    80003258:	60e2                	ld	ra,24(sp)
    8000325a:	6442                	ld	s0,16(sp)
    8000325c:	64a2                	ld	s1,8(sp)
    8000325e:	6902                	ld	s2,0(sp)
    80003260:	6105                	addi	sp,sp,32
    80003262:	8082                	ret
    return -1;
    80003264:	557d                	li	a0,-1
    80003266:	bfcd                	j	80003258 <fetchaddr+0x42>
    80003268:	557d                	li	a0,-1
    8000326a:	b7fd                	j	80003258 <fetchaddr+0x42>

000000008000326c <fetchstr>:
{
    8000326c:	7179                	addi	sp,sp,-48
    8000326e:	f406                	sd	ra,40(sp)
    80003270:	f022                	sd	s0,32(sp)
    80003272:	ec26                	sd	s1,24(sp)
    80003274:	e84a                	sd	s2,16(sp)
    80003276:	e44e                	sd	s3,8(sp)
    80003278:	1800                	addi	s0,sp,48
    8000327a:	892a                	mv	s2,a0
    8000327c:	84ae                	mv	s1,a1
    8000327e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	758080e7          	jalr	1880(ra) # 800019d8 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003288:	86ce                	mv	a3,s3
    8000328a:	864a                	mv	a2,s2
    8000328c:	85a6                	mv	a1,s1
    8000328e:	7c053503          	ld	a0,1984(a0)
    80003292:	ffffe097          	auipc	ra,0xffffe
    80003296:	4f0080e7          	jalr	1264(ra) # 80001782 <copyinstr>
    8000329a:	00054e63          	bltz	a0,800032b6 <fetchstr+0x4a>
  return strlen(buf);
    8000329e:	8526                	mv	a0,s1
    800032a0:	ffffe097          	auipc	ra,0xffffe
    800032a4:	bae080e7          	jalr	-1106(ra) # 80000e4e <strlen>
}
    800032a8:	70a2                	ld	ra,40(sp)
    800032aa:	7402                	ld	s0,32(sp)
    800032ac:	64e2                	ld	s1,24(sp)
    800032ae:	6942                	ld	s2,16(sp)
    800032b0:	69a2                	ld	s3,8(sp)
    800032b2:	6145                	addi	sp,sp,48
    800032b4:	8082                	ret
    return -1;
    800032b6:	557d                	li	a0,-1
    800032b8:	bfc5                	j	800032a8 <fetchstr+0x3c>

00000000800032ba <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	1000                	addi	s0,sp,32
    800032c4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	ee8080e7          	jalr	-280(ra) # 800031ae <argraw>
    800032ce:	c088                	sw	a0,0(s1)
}
    800032d0:	60e2                	ld	ra,24(sp)
    800032d2:	6442                	ld	s0,16(sp)
    800032d4:	64a2                	ld	s1,8(sp)
    800032d6:	6105                	addi	sp,sp,32
    800032d8:	8082                	ret

00000000800032da <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800032da:	1101                	addi	sp,sp,-32
    800032dc:	ec06                	sd	ra,24(sp)
    800032de:	e822                	sd	s0,16(sp)
    800032e0:	e426                	sd	s1,8(sp)
    800032e2:	1000                	addi	s0,sp,32
    800032e4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032e6:	00000097          	auipc	ra,0x0
    800032ea:	ec8080e7          	jalr	-312(ra) # 800031ae <argraw>
    800032ee:	e088                	sd	a0,0(s1)
}
    800032f0:	60e2                	ld	ra,24(sp)
    800032f2:	6442                	ld	s0,16(sp)
    800032f4:	64a2                	ld	s1,8(sp)
    800032f6:	6105                	addi	sp,sp,32
    800032f8:	8082                	ret

00000000800032fa <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800032fa:	7179                	addi	sp,sp,-48
    800032fc:	f406                	sd	ra,40(sp)
    800032fe:	f022                	sd	s0,32(sp)
    80003300:	ec26                	sd	s1,24(sp)
    80003302:	e84a                	sd	s2,16(sp)
    80003304:	1800                	addi	s0,sp,48
    80003306:	84ae                	mv	s1,a1
    80003308:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000330a:	fd840593          	addi	a1,s0,-40
    8000330e:	00000097          	auipc	ra,0x0
    80003312:	fcc080e7          	jalr	-52(ra) # 800032da <argaddr>
  return fetchstr(addr, buf, max);
    80003316:	864a                	mv	a2,s2
    80003318:	85a6                	mv	a1,s1
    8000331a:	fd843503          	ld	a0,-40(s0)
    8000331e:	00000097          	auipc	ra,0x0
    80003322:	f4e080e7          	jalr	-178(ra) # 8000326c <fetchstr>
}
    80003326:	70a2                	ld	ra,40(sp)
    80003328:	7402                	ld	s0,32(sp)
    8000332a:	64e2                	ld	s1,24(sp)
    8000332c:	6942                	ld	s2,16(sp)
    8000332e:	6145                	addi	sp,sp,48
    80003330:	8082                	ret

0000000080003332 <syscall>:
[SYS_kthread_join]   sys_kthread_join,
};

void
syscall(void)
{
    80003332:	7179                	addi	sp,sp,-48
    80003334:	f406                	sd	ra,40(sp)
    80003336:	f022                	sd	s0,32(sp)
    80003338:	ec26                	sd	s1,24(sp)
    8000333a:	e84a                	sd	s2,16(sp)
    8000333c:	e44e                	sd	s3,8(sp)
    8000333e:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003340:	ffffe097          	auipc	ra,0xffffe
    80003344:	698080e7          	jalr	1688(ra) # 800019d8 <myproc>
    80003348:	892a                	mv	s2,a0
  struct kthread *kt = mykthread();
    8000334a:	fffff097          	auipc	ra,0xfffff
    8000334e:	570080e7          	jalr	1392(ra) # 800028ba <mykthread>
    80003352:	84aa                	mv	s1,a0

  num = kt->trapframe->a7;
    80003354:	0b853983          	ld	s3,184(a0)
    80003358:	0a89b783          	ld	a5,168(s3)
    8000335c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003360:	37fd                	addiw	a5,a5,-1
    80003362:	4765                	li	a4,25
    80003364:	00f76f63          	bltu	a4,a5,80003382 <syscall+0x50>
    80003368:	00369713          	slli	a4,a3,0x3
    8000336c:	00005797          	auipc	a5,0x5
    80003370:	0d478793          	addi	a5,a5,212 # 80008440 <syscalls>
    80003374:	97ba                	add	a5,a5,a4
    80003376:	639c                	ld	a5,0(a5)
    80003378:	c789                	beqz	a5,80003382 <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    kt->trapframe->a0 = syscalls[num]();
    8000337a:	9782                	jalr	a5
    8000337c:	06a9b823          	sd	a0,112(s3)
    80003380:	a015                	j	800033a4 <syscall+0x72>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003382:	6605                	lui	a2,0x1
    80003384:	85060613          	addi	a2,a2,-1968 # 850 <_entry-0x7ffff7b0>
    80003388:	964a                	add	a2,a2,s2
    8000338a:	02492583          	lw	a1,36(s2)
    8000338e:	00005517          	auipc	a0,0x5
    80003392:	07a50513          	addi	a0,a0,122 # 80008408 <states.0+0x158>
    80003396:	ffffd097          	auipc	ra,0xffffd
    8000339a:	1f2080e7          	jalr	498(ra) # 80000588 <printf>
            p->pid, p->name, num);
    kt->trapframe->a0 = -1;
    8000339e:	7cdc                	ld	a5,184(s1)
    800033a0:	577d                	li	a4,-1
    800033a2:	fbb8                	sd	a4,112(a5)
  }
}
    800033a4:	70a2                	ld	ra,40(sp)
    800033a6:	7402                	ld	s0,32(sp)
    800033a8:	64e2                	ld	s1,24(sp)
    800033aa:	6942                	ld	s2,16(sp)
    800033ac:	69a2                	ld	s3,8(sp)
    800033ae:	6145                	addi	sp,sp,48
    800033b0:	8082                	ret

00000000800033b2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800033b2:	1101                	addi	sp,sp,-32
    800033b4:	ec06                	sd	ra,24(sp)
    800033b6:	e822                	sd	s0,16(sp)
    800033b8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800033ba:	fec40593          	addi	a1,s0,-20
    800033be:	4501                	li	a0,0
    800033c0:	00000097          	auipc	ra,0x0
    800033c4:	efa080e7          	jalr	-262(ra) # 800032ba <argint>
  exit(n);
    800033c8:	fec42503          	lw	a0,-20(s0)
    800033cc:	fffff097          	auipc	ra,0xfffff
    800033d0:	efa080e7          	jalr	-262(ra) # 800022c6 <exit>
  return 0;  // not reached
}
    800033d4:	4501                	li	a0,0
    800033d6:	60e2                	ld	ra,24(sp)
    800033d8:	6442                	ld	s0,16(sp)
    800033da:	6105                	addi	sp,sp,32
    800033dc:	8082                	ret

00000000800033de <sys_getpid>:

uint64
sys_getpid(void)
{
    800033de:	1141                	addi	sp,sp,-16
    800033e0:	e406                	sd	ra,8(sp)
    800033e2:	e022                	sd	s0,0(sp)
    800033e4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800033e6:	ffffe097          	auipc	ra,0xffffe
    800033ea:	5f2080e7          	jalr	1522(ra) # 800019d8 <myproc>
}
    800033ee:	5148                	lw	a0,36(a0)
    800033f0:	60a2                	ld	ra,8(sp)
    800033f2:	6402                	ld	s0,0(sp)
    800033f4:	0141                	addi	sp,sp,16
    800033f6:	8082                	ret

00000000800033f8 <sys_fork>:

uint64
sys_fork(void)
{
    800033f8:	1141                	addi	sp,sp,-16
    800033fa:	e406                	sd	ra,8(sp)
    800033fc:	e022                	sd	s0,0(sp)
    800033fe:	0800                	addi	s0,sp,16
  return fork();
    80003400:	fffff097          	auipc	ra,0xfffff
    80003404:	9d0080e7          	jalr	-1584(ra) # 80001dd0 <fork>
}
    80003408:	60a2                	ld	ra,8(sp)
    8000340a:	6402                	ld	s0,0(sp)
    8000340c:	0141                	addi	sp,sp,16
    8000340e:	8082                	ret

0000000080003410 <sys_wait>:

uint64
sys_wait(void)
{
    80003410:	1101                	addi	sp,sp,-32
    80003412:	ec06                	sd	ra,24(sp)
    80003414:	e822                	sd	s0,16(sp)
    80003416:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003418:	fe840593          	addi	a1,s0,-24
    8000341c:	4501                	li	a0,0
    8000341e:	00000097          	auipc	ra,0x0
    80003422:	ebc080e7          	jalr	-324(ra) # 800032da <argaddr>
  return wait(p);
    80003426:	fe843503          	ld	a0,-24(s0)
    8000342a:	fffff097          	auipc	ra,0xfffff
    8000342e:	132080e7          	jalr	306(ra) # 8000255c <wait>
}
    80003432:	60e2                	ld	ra,24(sp)
    80003434:	6442                	ld	s0,16(sp)
    80003436:	6105                	addi	sp,sp,32
    80003438:	8082                	ret

000000008000343a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000343a:	7179                	addi	sp,sp,-48
    8000343c:	f406                	sd	ra,40(sp)
    8000343e:	f022                	sd	s0,32(sp)
    80003440:	ec26                	sd	s1,24(sp)
    80003442:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003444:	fdc40593          	addi	a1,s0,-36
    80003448:	4501                	li	a0,0
    8000344a:	00000097          	auipc	ra,0x0
    8000344e:	e70080e7          	jalr	-400(ra) # 800032ba <argint>
  addr = myproc()->sz;
    80003452:	ffffe097          	auipc	ra,0xffffe
    80003456:	586080e7          	jalr	1414(ra) # 800019d8 <myproc>
    8000345a:	7b853483          	ld	s1,1976(a0)
  if(growproc(n) < 0)
    8000345e:	fdc42503          	lw	a0,-36(s0)
    80003462:	fffff097          	auipc	ra,0xfffff
    80003466:	90a080e7          	jalr	-1782(ra) # 80001d6c <growproc>
    8000346a:	00054863          	bltz	a0,8000347a <sys_sbrk+0x40>
    return -1;
  return addr;
}
    8000346e:	8526                	mv	a0,s1
    80003470:	70a2                	ld	ra,40(sp)
    80003472:	7402                	ld	s0,32(sp)
    80003474:	64e2                	ld	s1,24(sp)
    80003476:	6145                	addi	sp,sp,48
    80003478:	8082                	ret
    return -1;
    8000347a:	54fd                	li	s1,-1
    8000347c:	bfcd                	j	8000346e <sys_sbrk+0x34>

000000008000347e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000347e:	7139                	addi	sp,sp,-64
    80003480:	fc06                	sd	ra,56(sp)
    80003482:	f822                	sd	s0,48(sp)
    80003484:	f426                	sd	s1,40(sp)
    80003486:	f04a                	sd	s2,32(sp)
    80003488:	ec4e                	sd	s3,24(sp)
    8000348a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000348c:	fcc40593          	addi	a1,s0,-52
    80003490:	4501                	li	a0,0
    80003492:	00000097          	auipc	ra,0x0
    80003496:	e28080e7          	jalr	-472(ra) # 800032ba <argint>
  acquire(&tickslock);
    8000349a:	00030517          	auipc	a0,0x30
    8000349e:	b0650513          	addi	a0,a0,-1274 # 80032fa0 <tickslock>
    800034a2:	ffffd097          	auipc	ra,0xffffd
    800034a6:	734080e7          	jalr	1844(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    800034aa:	00005917          	auipc	s2,0x5
    800034ae:	45692903          	lw	s2,1110(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    800034b2:	fcc42783          	lw	a5,-52(s0)
    800034b6:	cf9d                	beqz	a5,800034f4 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800034b8:	00030997          	auipc	s3,0x30
    800034bc:	ae898993          	addi	s3,s3,-1304 # 80032fa0 <tickslock>
    800034c0:	00005497          	auipc	s1,0x5
    800034c4:	44048493          	addi	s1,s1,1088 # 80008900 <ticks>
    if(killed(myproc())){
    800034c8:	ffffe097          	auipc	ra,0xffffe
    800034cc:	510080e7          	jalr	1296(ra) # 800019d8 <myproc>
    800034d0:	fffff097          	auipc	ra,0xfffff
    800034d4:	05a080e7          	jalr	90(ra) # 8000252a <killed>
    800034d8:	ed15                	bnez	a0,80003514 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800034da:	85ce                	mv	a1,s3
    800034dc:	8526                	mv	a0,s1
    800034de:	fffff097          	auipc	ra,0xfffff
    800034e2:	c8e080e7          	jalr	-882(ra) # 8000216c <sleep>
  while(ticks - ticks0 < n){
    800034e6:	409c                	lw	a5,0(s1)
    800034e8:	412787bb          	subw	a5,a5,s2
    800034ec:	fcc42703          	lw	a4,-52(s0)
    800034f0:	fce7ece3          	bltu	a5,a4,800034c8 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800034f4:	00030517          	auipc	a0,0x30
    800034f8:	aac50513          	addi	a0,a0,-1364 # 80032fa0 <tickslock>
    800034fc:	ffffd097          	auipc	ra,0xffffd
    80003500:	78e080e7          	jalr	1934(ra) # 80000c8a <release>
  return 0;
    80003504:	4501                	li	a0,0
}
    80003506:	70e2                	ld	ra,56(sp)
    80003508:	7442                	ld	s0,48(sp)
    8000350a:	74a2                	ld	s1,40(sp)
    8000350c:	7902                	ld	s2,32(sp)
    8000350e:	69e2                	ld	s3,24(sp)
    80003510:	6121                	addi	sp,sp,64
    80003512:	8082                	ret
      release(&tickslock);
    80003514:	00030517          	auipc	a0,0x30
    80003518:	a8c50513          	addi	a0,a0,-1396 # 80032fa0 <tickslock>
    8000351c:	ffffd097          	auipc	ra,0xffffd
    80003520:	76e080e7          	jalr	1902(ra) # 80000c8a <release>
      return -1;
    80003524:	557d                	li	a0,-1
    80003526:	b7c5                	j	80003506 <sys_sleep+0x88>

0000000080003528 <sys_kill>:

uint64
sys_kill(void)
{
    80003528:	1101                	addi	sp,sp,-32
    8000352a:	ec06                	sd	ra,24(sp)
    8000352c:	e822                	sd	s0,16(sp)
    8000352e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003530:	fec40593          	addi	a1,s0,-20
    80003534:	4501                	li	a0,0
    80003536:	00000097          	auipc	ra,0x0
    8000353a:	d84080e7          	jalr	-636(ra) # 800032ba <argint>
  return kill(pid);
    8000353e:	fec42503          	lw	a0,-20(s0)
    80003542:	fffff097          	auipc	ra,0xfffff
    80003546:	f14080e7          	jalr	-236(ra) # 80002456 <kill>
}
    8000354a:	60e2                	ld	ra,24(sp)
    8000354c:	6442                	ld	s0,16(sp)
    8000354e:	6105                	addi	sp,sp,32
    80003550:	8082                	ret

0000000080003552 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003552:	1101                	addi	sp,sp,-32
    80003554:	ec06                	sd	ra,24(sp)
    80003556:	e822                	sd	s0,16(sp)
    80003558:	e426                	sd	s1,8(sp)
    8000355a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000355c:	00030517          	auipc	a0,0x30
    80003560:	a4450513          	addi	a0,a0,-1468 # 80032fa0 <tickslock>
    80003564:	ffffd097          	auipc	ra,0xffffd
    80003568:	672080e7          	jalr	1650(ra) # 80000bd6 <acquire>
  xticks = ticks;
    8000356c:	00005497          	auipc	s1,0x5
    80003570:	3944a483          	lw	s1,916(s1) # 80008900 <ticks>
  release(&tickslock);
    80003574:	00030517          	auipc	a0,0x30
    80003578:	a2c50513          	addi	a0,a0,-1492 # 80032fa0 <tickslock>
    8000357c:	ffffd097          	auipc	ra,0xffffd
    80003580:	70e080e7          	jalr	1806(ra) # 80000c8a <release>
  return xticks;
}
    80003584:	02049513          	slli	a0,s1,0x20
    80003588:	9101                	srli	a0,a0,0x20
    8000358a:	60e2                	ld	ra,24(sp)
    8000358c:	6442                	ld	s0,16(sp)
    8000358e:	64a2                	ld	s1,8(sp)
    80003590:	6105                	addi	sp,sp,32
    80003592:	8082                	ret

0000000080003594 <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80003594:	7179                	addi	sp,sp,-48
    80003596:	f406                	sd	ra,40(sp)
    80003598:	f022                	sd	s0,32(sp)
    8000359a:	1800                	addi	s0,sp,48
  uint64 start_func;
  argaddr(0, &start_func);
    8000359c:	fe840593          	addi	a1,s0,-24
    800035a0:	4501                	li	a0,0
    800035a2:	00000097          	auipc	ra,0x0
    800035a6:	d38080e7          	jalr	-712(ra) # 800032da <argaddr>
  uint64 stack;
  argaddr(1, &stack);
    800035aa:	fe040593          	addi	a1,s0,-32
    800035ae:	4505                	li	a0,1
    800035b0:	00000097          	auipc	ra,0x0
    800035b4:	d2a080e7          	jalr	-726(ra) # 800032da <argaddr>
  int stack_size;
  argint(2, &stack_size);
    800035b8:	fdc40593          	addi	a1,s0,-36
    800035bc:	4509                	li	a0,2
    800035be:	00000097          	auipc	ra,0x0
    800035c2:	cfc080e7          	jalr	-772(ra) # 800032ba <argint>
  return kthread_create((void*(*)()) start_func, (void *) stack, (uint) stack_size);
    800035c6:	fdc42603          	lw	a2,-36(s0)
    800035ca:	fe043583          	ld	a1,-32(s0)
    800035ce:	fe843503          	ld	a0,-24(s0)
    800035d2:	fffff097          	auipc	ra,0xfffff
    800035d6:	46e080e7          	jalr	1134(ra) # 80002a40 <kthread_create>
}
    800035da:	70a2                	ld	ra,40(sp)
    800035dc:	7402                	ld	s0,32(sp)
    800035de:	6145                	addi	sp,sp,48
    800035e0:	8082                	ret

00000000800035e2 <sys_kthread_id>:

uint64
sys_kthread_id(void)
{
    800035e2:	1141                	addi	sp,sp,-16
    800035e4:	e406                	sd	ra,8(sp)
    800035e6:	e022                	sd	s0,0(sp)
    800035e8:	0800                	addi	s0,sp,16
  return mykthread()->tid;
    800035ea:	fffff097          	auipc	ra,0xfffff
    800035ee:	2d0080e7          	jalr	720(ra) # 800028ba <mykthread>
}
    800035f2:	5908                	lw	a0,48(a0)
    800035f4:	60a2                	ld	ra,8(sp)
    800035f6:	6402                	ld	s0,0(sp)
    800035f8:	0141                	addi	sp,sp,16
    800035fa:	8082                	ret

00000000800035fc <sys_kthread_kill>:

uint64
sys_kthread_kill(void)
{
    800035fc:	1101                	addi	sp,sp,-32
    800035fe:	ec06                	sd	ra,24(sp)
    80003600:	e822                	sd	s0,16(sp)
    80003602:	1000                	addi	s0,sp,32
  int ktid;
  argint(0, &ktid);
    80003604:	fec40593          	addi	a1,s0,-20
    80003608:	4501                	li	a0,0
    8000360a:	00000097          	auipc	ra,0x0
    8000360e:	cb0080e7          	jalr	-848(ra) # 800032ba <argint>
  return kthread_kill(ktid);
    80003612:	fec42503          	lw	a0,-20(s0)
    80003616:	fffff097          	auipc	ra,0xfffff
    8000361a:	488080e7          	jalr	1160(ra) # 80002a9e <kthread_kill>
}
    8000361e:	60e2                	ld	ra,24(sp)
    80003620:	6442                	ld	s0,16(sp)
    80003622:	6105                	addi	sp,sp,32
    80003624:	8082                	ret

0000000080003626 <sys_kthread_exit>:

uint64
sys_kthread_exit(void){
    80003626:	1101                	addi	sp,sp,-32
    80003628:	ec06                	sd	ra,24(sp)
    8000362a:	e822                	sd	s0,16(sp)
    8000362c:	1000                	addi	s0,sp,32
  int status;
  argint(0, &status);
    8000362e:	fec40593          	addi	a1,s0,-20
    80003632:	4501                	li	a0,0
    80003634:	00000097          	auipc	ra,0x0
    80003638:	c86080e7          	jalr	-890(ra) # 800032ba <argint>
  kthread_exit(status);
    8000363c:	fec42503          	lw	a0,-20(s0)
    80003640:	fffff097          	auipc	ra,0xfffff
    80003644:	570080e7          	jalr	1392(ra) # 80002bb0 <kthread_exit>
  return 0;
}
    80003648:	4501                	li	a0,0
    8000364a:	60e2                	ld	ra,24(sp)
    8000364c:	6442                	ld	s0,16(sp)
    8000364e:	6105                	addi	sp,sp,32
    80003650:	8082                	ret

0000000080003652 <sys_kthread_join>:

uint64
sys_kthread_join(void){
    80003652:	1101                	addi	sp,sp,-32
    80003654:	ec06                	sd	ra,24(sp)
    80003656:	e822                	sd	s0,16(sp)
    80003658:	1000                	addi	s0,sp,32
  int ktid;
  argint(0, &ktid);
    8000365a:	fec40593          	addi	a1,s0,-20
    8000365e:	4501                	li	a0,0
    80003660:	00000097          	auipc	ra,0x0
    80003664:	c5a080e7          	jalr	-934(ra) # 800032ba <argint>
  uint64 status;
  argaddr(1, &status);
    80003668:	fe040593          	addi	a1,s0,-32
    8000366c:	4505                	li	a0,1
    8000366e:	00000097          	auipc	ra,0x0
    80003672:	c6c080e7          	jalr	-916(ra) # 800032da <argaddr>
  return kthread_join(ktid, (int*) status);
    80003676:	fe043583          	ld	a1,-32(s0)
    8000367a:	fec42503          	lw	a0,-20(s0)
    8000367e:	fffff097          	auipc	ra,0xfffff
    80003682:	5c8080e7          	jalr	1480(ra) # 80002c46 <kthread_join>
    80003686:	60e2                	ld	ra,24(sp)
    80003688:	6442                	ld	s0,16(sp)
    8000368a:	6105                	addi	sp,sp,32
    8000368c:	8082                	ret

000000008000368e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000368e:	7179                	addi	sp,sp,-48
    80003690:	f406                	sd	ra,40(sp)
    80003692:	f022                	sd	s0,32(sp)
    80003694:	ec26                	sd	s1,24(sp)
    80003696:	e84a                	sd	s2,16(sp)
    80003698:	e44e                	sd	s3,8(sp)
    8000369a:	e052                	sd	s4,0(sp)
    8000369c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000369e:	00005597          	auipc	a1,0x5
    800036a2:	e7a58593          	addi	a1,a1,-390 # 80008518 <syscalls+0xd8>
    800036a6:	00030517          	auipc	a0,0x30
    800036aa:	91250513          	addi	a0,a0,-1774 # 80032fb8 <bcache>
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	498080e7          	jalr	1176(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800036b6:	00038797          	auipc	a5,0x38
    800036ba:	90278793          	addi	a5,a5,-1790 # 8003afb8 <bcache+0x8000>
    800036be:	00038717          	auipc	a4,0x38
    800036c2:	b6270713          	addi	a4,a4,-1182 # 8003b220 <bcache+0x8268>
    800036c6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800036ca:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036ce:	00030497          	auipc	s1,0x30
    800036d2:	90248493          	addi	s1,s1,-1790 # 80032fd0 <bcache+0x18>
    b->next = bcache.head.next;
    800036d6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800036d8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800036da:	00005a17          	auipc	s4,0x5
    800036de:	e46a0a13          	addi	s4,s4,-442 # 80008520 <syscalls+0xe0>
    b->next = bcache.head.next;
    800036e2:	2b893783          	ld	a5,696(s2)
    800036e6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800036e8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800036ec:	85d2                	mv	a1,s4
    800036ee:	01048513          	addi	a0,s1,16
    800036f2:	00001097          	auipc	ra,0x1
    800036f6:	4c8080e7          	jalr	1224(ra) # 80004bba <initsleeplock>
    bcache.head.next->prev = b;
    800036fa:	2b893783          	ld	a5,696(s2)
    800036fe:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003700:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003704:	45848493          	addi	s1,s1,1112
    80003708:	fd349de3          	bne	s1,s3,800036e2 <binit+0x54>
  }
}
    8000370c:	70a2                	ld	ra,40(sp)
    8000370e:	7402                	ld	s0,32(sp)
    80003710:	64e2                	ld	s1,24(sp)
    80003712:	6942                	ld	s2,16(sp)
    80003714:	69a2                	ld	s3,8(sp)
    80003716:	6a02                	ld	s4,0(sp)
    80003718:	6145                	addi	sp,sp,48
    8000371a:	8082                	ret

000000008000371c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000371c:	7179                	addi	sp,sp,-48
    8000371e:	f406                	sd	ra,40(sp)
    80003720:	f022                	sd	s0,32(sp)
    80003722:	ec26                	sd	s1,24(sp)
    80003724:	e84a                	sd	s2,16(sp)
    80003726:	e44e                	sd	s3,8(sp)
    80003728:	1800                	addi	s0,sp,48
    8000372a:	892a                	mv	s2,a0
    8000372c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000372e:	00030517          	auipc	a0,0x30
    80003732:	88a50513          	addi	a0,a0,-1910 # 80032fb8 <bcache>
    80003736:	ffffd097          	auipc	ra,0xffffd
    8000373a:	4a0080e7          	jalr	1184(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000373e:	00038497          	auipc	s1,0x38
    80003742:	b324b483          	ld	s1,-1230(s1) # 8003b270 <bcache+0x82b8>
    80003746:	00038797          	auipc	a5,0x38
    8000374a:	ada78793          	addi	a5,a5,-1318 # 8003b220 <bcache+0x8268>
    8000374e:	02f48f63          	beq	s1,a5,8000378c <bread+0x70>
    80003752:	873e                	mv	a4,a5
    80003754:	a021                	j	8000375c <bread+0x40>
    80003756:	68a4                	ld	s1,80(s1)
    80003758:	02e48a63          	beq	s1,a4,8000378c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000375c:	449c                	lw	a5,8(s1)
    8000375e:	ff279ce3          	bne	a5,s2,80003756 <bread+0x3a>
    80003762:	44dc                	lw	a5,12(s1)
    80003764:	ff3799e3          	bne	a5,s3,80003756 <bread+0x3a>
      b->refcnt++;
    80003768:	40bc                	lw	a5,64(s1)
    8000376a:	2785                	addiw	a5,a5,1
    8000376c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000376e:	00030517          	auipc	a0,0x30
    80003772:	84a50513          	addi	a0,a0,-1974 # 80032fb8 <bcache>
    80003776:	ffffd097          	auipc	ra,0xffffd
    8000377a:	514080e7          	jalr	1300(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000377e:	01048513          	addi	a0,s1,16
    80003782:	00001097          	auipc	ra,0x1
    80003786:	472080e7          	jalr	1138(ra) # 80004bf4 <acquiresleep>
      return b;
    8000378a:	a8b9                	j	800037e8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000378c:	00038497          	auipc	s1,0x38
    80003790:	adc4b483          	ld	s1,-1316(s1) # 8003b268 <bcache+0x82b0>
    80003794:	00038797          	auipc	a5,0x38
    80003798:	a8c78793          	addi	a5,a5,-1396 # 8003b220 <bcache+0x8268>
    8000379c:	00f48863          	beq	s1,a5,800037ac <bread+0x90>
    800037a0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800037a2:	40bc                	lw	a5,64(s1)
    800037a4:	cf81                	beqz	a5,800037bc <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037a6:	64a4                	ld	s1,72(s1)
    800037a8:	fee49de3          	bne	s1,a4,800037a2 <bread+0x86>
  panic("bget: no buffers");
    800037ac:	00005517          	auipc	a0,0x5
    800037b0:	d7c50513          	addi	a0,a0,-644 # 80008528 <syscalls+0xe8>
    800037b4:	ffffd097          	auipc	ra,0xffffd
    800037b8:	d8a080e7          	jalr	-630(ra) # 8000053e <panic>
      b->dev = dev;
    800037bc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800037c0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800037c4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800037c8:	4785                	li	a5,1
    800037ca:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037cc:	0002f517          	auipc	a0,0x2f
    800037d0:	7ec50513          	addi	a0,a0,2028 # 80032fb8 <bcache>
    800037d4:	ffffd097          	auipc	ra,0xffffd
    800037d8:	4b6080e7          	jalr	1206(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800037dc:	01048513          	addi	a0,s1,16
    800037e0:	00001097          	auipc	ra,0x1
    800037e4:	414080e7          	jalr	1044(ra) # 80004bf4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800037e8:	409c                	lw	a5,0(s1)
    800037ea:	cb89                	beqz	a5,800037fc <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800037ec:	8526                	mv	a0,s1
    800037ee:	70a2                	ld	ra,40(sp)
    800037f0:	7402                	ld	s0,32(sp)
    800037f2:	64e2                	ld	s1,24(sp)
    800037f4:	6942                	ld	s2,16(sp)
    800037f6:	69a2                	ld	s3,8(sp)
    800037f8:	6145                	addi	sp,sp,48
    800037fa:	8082                	ret
    virtio_disk_rw(b, 0);
    800037fc:	4581                	li	a1,0
    800037fe:	8526                	mv	a0,s1
    80003800:	00003097          	auipc	ra,0x3
    80003804:	064080e7          	jalr	100(ra) # 80006864 <virtio_disk_rw>
    b->valid = 1;
    80003808:	4785                	li	a5,1
    8000380a:	c09c                	sw	a5,0(s1)
  return b;
    8000380c:	b7c5                	j	800037ec <bread+0xd0>

000000008000380e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000380e:	1101                	addi	sp,sp,-32
    80003810:	ec06                	sd	ra,24(sp)
    80003812:	e822                	sd	s0,16(sp)
    80003814:	e426                	sd	s1,8(sp)
    80003816:	1000                	addi	s0,sp,32
    80003818:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000381a:	0541                	addi	a0,a0,16
    8000381c:	00001097          	auipc	ra,0x1
    80003820:	472080e7          	jalr	1138(ra) # 80004c8e <holdingsleep>
    80003824:	cd01                	beqz	a0,8000383c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003826:	4585                	li	a1,1
    80003828:	8526                	mv	a0,s1
    8000382a:	00003097          	auipc	ra,0x3
    8000382e:	03a080e7          	jalr	58(ra) # 80006864 <virtio_disk_rw>
}
    80003832:	60e2                	ld	ra,24(sp)
    80003834:	6442                	ld	s0,16(sp)
    80003836:	64a2                	ld	s1,8(sp)
    80003838:	6105                	addi	sp,sp,32
    8000383a:	8082                	ret
    panic("bwrite");
    8000383c:	00005517          	auipc	a0,0x5
    80003840:	d0450513          	addi	a0,a0,-764 # 80008540 <syscalls+0x100>
    80003844:	ffffd097          	auipc	ra,0xffffd
    80003848:	cfa080e7          	jalr	-774(ra) # 8000053e <panic>

000000008000384c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000384c:	1101                	addi	sp,sp,-32
    8000384e:	ec06                	sd	ra,24(sp)
    80003850:	e822                	sd	s0,16(sp)
    80003852:	e426                	sd	s1,8(sp)
    80003854:	e04a                	sd	s2,0(sp)
    80003856:	1000                	addi	s0,sp,32
    80003858:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000385a:	01050913          	addi	s2,a0,16
    8000385e:	854a                	mv	a0,s2
    80003860:	00001097          	auipc	ra,0x1
    80003864:	42e080e7          	jalr	1070(ra) # 80004c8e <holdingsleep>
    80003868:	c92d                	beqz	a0,800038da <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000386a:	854a                	mv	a0,s2
    8000386c:	00001097          	auipc	ra,0x1
    80003870:	3de080e7          	jalr	990(ra) # 80004c4a <releasesleep>

  acquire(&bcache.lock);
    80003874:	0002f517          	auipc	a0,0x2f
    80003878:	74450513          	addi	a0,a0,1860 # 80032fb8 <bcache>
    8000387c:	ffffd097          	auipc	ra,0xffffd
    80003880:	35a080e7          	jalr	858(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003884:	40bc                	lw	a5,64(s1)
    80003886:	37fd                	addiw	a5,a5,-1
    80003888:	0007871b          	sext.w	a4,a5
    8000388c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000388e:	eb05                	bnez	a4,800038be <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003890:	68bc                	ld	a5,80(s1)
    80003892:	64b8                	ld	a4,72(s1)
    80003894:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003896:	64bc                	ld	a5,72(s1)
    80003898:	68b8                	ld	a4,80(s1)
    8000389a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000389c:	00037797          	auipc	a5,0x37
    800038a0:	71c78793          	addi	a5,a5,1820 # 8003afb8 <bcache+0x8000>
    800038a4:	2b87b703          	ld	a4,696(a5)
    800038a8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800038aa:	00038717          	auipc	a4,0x38
    800038ae:	97670713          	addi	a4,a4,-1674 # 8003b220 <bcache+0x8268>
    800038b2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800038b4:	2b87b703          	ld	a4,696(a5)
    800038b8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800038ba:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800038be:	0002f517          	auipc	a0,0x2f
    800038c2:	6fa50513          	addi	a0,a0,1786 # 80032fb8 <bcache>
    800038c6:	ffffd097          	auipc	ra,0xffffd
    800038ca:	3c4080e7          	jalr	964(ra) # 80000c8a <release>
}
    800038ce:	60e2                	ld	ra,24(sp)
    800038d0:	6442                	ld	s0,16(sp)
    800038d2:	64a2                	ld	s1,8(sp)
    800038d4:	6902                	ld	s2,0(sp)
    800038d6:	6105                	addi	sp,sp,32
    800038d8:	8082                	ret
    panic("brelse");
    800038da:	00005517          	auipc	a0,0x5
    800038de:	c6e50513          	addi	a0,a0,-914 # 80008548 <syscalls+0x108>
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	c5c080e7          	jalr	-932(ra) # 8000053e <panic>

00000000800038ea <bpin>:

void
bpin(struct buf *b) {
    800038ea:	1101                	addi	sp,sp,-32
    800038ec:	ec06                	sd	ra,24(sp)
    800038ee:	e822                	sd	s0,16(sp)
    800038f0:	e426                	sd	s1,8(sp)
    800038f2:	1000                	addi	s0,sp,32
    800038f4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038f6:	0002f517          	auipc	a0,0x2f
    800038fa:	6c250513          	addi	a0,a0,1730 # 80032fb8 <bcache>
    800038fe:	ffffd097          	auipc	ra,0xffffd
    80003902:	2d8080e7          	jalr	728(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003906:	40bc                	lw	a5,64(s1)
    80003908:	2785                	addiw	a5,a5,1
    8000390a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000390c:	0002f517          	auipc	a0,0x2f
    80003910:	6ac50513          	addi	a0,a0,1708 # 80032fb8 <bcache>
    80003914:	ffffd097          	auipc	ra,0xffffd
    80003918:	376080e7          	jalr	886(ra) # 80000c8a <release>
}
    8000391c:	60e2                	ld	ra,24(sp)
    8000391e:	6442                	ld	s0,16(sp)
    80003920:	64a2                	ld	s1,8(sp)
    80003922:	6105                	addi	sp,sp,32
    80003924:	8082                	ret

0000000080003926 <bunpin>:

void
bunpin(struct buf *b) {
    80003926:	1101                	addi	sp,sp,-32
    80003928:	ec06                	sd	ra,24(sp)
    8000392a:	e822                	sd	s0,16(sp)
    8000392c:	e426                	sd	s1,8(sp)
    8000392e:	1000                	addi	s0,sp,32
    80003930:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003932:	0002f517          	auipc	a0,0x2f
    80003936:	68650513          	addi	a0,a0,1670 # 80032fb8 <bcache>
    8000393a:	ffffd097          	auipc	ra,0xffffd
    8000393e:	29c080e7          	jalr	668(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003942:	40bc                	lw	a5,64(s1)
    80003944:	37fd                	addiw	a5,a5,-1
    80003946:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003948:	0002f517          	auipc	a0,0x2f
    8000394c:	67050513          	addi	a0,a0,1648 # 80032fb8 <bcache>
    80003950:	ffffd097          	auipc	ra,0xffffd
    80003954:	33a080e7          	jalr	826(ra) # 80000c8a <release>
}
    80003958:	60e2                	ld	ra,24(sp)
    8000395a:	6442                	ld	s0,16(sp)
    8000395c:	64a2                	ld	s1,8(sp)
    8000395e:	6105                	addi	sp,sp,32
    80003960:	8082                	ret

0000000080003962 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003962:	1101                	addi	sp,sp,-32
    80003964:	ec06                	sd	ra,24(sp)
    80003966:	e822                	sd	s0,16(sp)
    80003968:	e426                	sd	s1,8(sp)
    8000396a:	e04a                	sd	s2,0(sp)
    8000396c:	1000                	addi	s0,sp,32
    8000396e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003970:	00d5d59b          	srliw	a1,a1,0xd
    80003974:	00038797          	auipc	a5,0x38
    80003978:	d207a783          	lw	a5,-736(a5) # 8003b694 <sb+0x1c>
    8000397c:	9dbd                	addw	a1,a1,a5
    8000397e:	00000097          	auipc	ra,0x0
    80003982:	d9e080e7          	jalr	-610(ra) # 8000371c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003986:	0074f713          	andi	a4,s1,7
    8000398a:	4785                	li	a5,1
    8000398c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003990:	14ce                	slli	s1,s1,0x33
    80003992:	90d9                	srli	s1,s1,0x36
    80003994:	00950733          	add	a4,a0,s1
    80003998:	05874703          	lbu	a4,88(a4)
    8000399c:	00e7f6b3          	and	a3,a5,a4
    800039a0:	c69d                	beqz	a3,800039ce <bfree+0x6c>
    800039a2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800039a4:	94aa                	add	s1,s1,a0
    800039a6:	fff7c793          	not	a5,a5
    800039aa:	8ff9                	and	a5,a5,a4
    800039ac:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800039b0:	00001097          	auipc	ra,0x1
    800039b4:	124080e7          	jalr	292(ra) # 80004ad4 <log_write>
  brelse(bp);
    800039b8:	854a                	mv	a0,s2
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	e92080e7          	jalr	-366(ra) # 8000384c <brelse>
}
    800039c2:	60e2                	ld	ra,24(sp)
    800039c4:	6442                	ld	s0,16(sp)
    800039c6:	64a2                	ld	s1,8(sp)
    800039c8:	6902                	ld	s2,0(sp)
    800039ca:	6105                	addi	sp,sp,32
    800039cc:	8082                	ret
    panic("freeing free block");
    800039ce:	00005517          	auipc	a0,0x5
    800039d2:	b8250513          	addi	a0,a0,-1150 # 80008550 <syscalls+0x110>
    800039d6:	ffffd097          	auipc	ra,0xffffd
    800039da:	b68080e7          	jalr	-1176(ra) # 8000053e <panic>

00000000800039de <balloc>:
{
    800039de:	711d                	addi	sp,sp,-96
    800039e0:	ec86                	sd	ra,88(sp)
    800039e2:	e8a2                	sd	s0,80(sp)
    800039e4:	e4a6                	sd	s1,72(sp)
    800039e6:	e0ca                	sd	s2,64(sp)
    800039e8:	fc4e                	sd	s3,56(sp)
    800039ea:	f852                	sd	s4,48(sp)
    800039ec:	f456                	sd	s5,40(sp)
    800039ee:	f05a                	sd	s6,32(sp)
    800039f0:	ec5e                	sd	s7,24(sp)
    800039f2:	e862                	sd	s8,16(sp)
    800039f4:	e466                	sd	s9,8(sp)
    800039f6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800039f8:	00038797          	auipc	a5,0x38
    800039fc:	c847a783          	lw	a5,-892(a5) # 8003b67c <sb+0x4>
    80003a00:	10078163          	beqz	a5,80003b02 <balloc+0x124>
    80003a04:	8baa                	mv	s7,a0
    80003a06:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a08:	00038b17          	auipc	s6,0x38
    80003a0c:	c70b0b13          	addi	s6,s6,-912 # 8003b678 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a10:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003a12:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a14:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a16:	6c89                	lui	s9,0x2
    80003a18:	a061                	j	80003aa0 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a1a:	974a                	add	a4,a4,s2
    80003a1c:	8fd5                	or	a5,a5,a3
    80003a1e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003a22:	854a                	mv	a0,s2
    80003a24:	00001097          	auipc	ra,0x1
    80003a28:	0b0080e7          	jalr	176(ra) # 80004ad4 <log_write>
        brelse(bp);
    80003a2c:	854a                	mv	a0,s2
    80003a2e:	00000097          	auipc	ra,0x0
    80003a32:	e1e080e7          	jalr	-482(ra) # 8000384c <brelse>
  bp = bread(dev, bno);
    80003a36:	85a6                	mv	a1,s1
    80003a38:	855e                	mv	a0,s7
    80003a3a:	00000097          	auipc	ra,0x0
    80003a3e:	ce2080e7          	jalr	-798(ra) # 8000371c <bread>
    80003a42:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003a44:	40000613          	li	a2,1024
    80003a48:	4581                	li	a1,0
    80003a4a:	05850513          	addi	a0,a0,88
    80003a4e:	ffffd097          	auipc	ra,0xffffd
    80003a52:	284080e7          	jalr	644(ra) # 80000cd2 <memset>
  log_write(bp);
    80003a56:	854a                	mv	a0,s2
    80003a58:	00001097          	auipc	ra,0x1
    80003a5c:	07c080e7          	jalr	124(ra) # 80004ad4 <log_write>
  brelse(bp);
    80003a60:	854a                	mv	a0,s2
    80003a62:	00000097          	auipc	ra,0x0
    80003a66:	dea080e7          	jalr	-534(ra) # 8000384c <brelse>
}
    80003a6a:	8526                	mv	a0,s1
    80003a6c:	60e6                	ld	ra,88(sp)
    80003a6e:	6446                	ld	s0,80(sp)
    80003a70:	64a6                	ld	s1,72(sp)
    80003a72:	6906                	ld	s2,64(sp)
    80003a74:	79e2                	ld	s3,56(sp)
    80003a76:	7a42                	ld	s4,48(sp)
    80003a78:	7aa2                	ld	s5,40(sp)
    80003a7a:	7b02                	ld	s6,32(sp)
    80003a7c:	6be2                	ld	s7,24(sp)
    80003a7e:	6c42                	ld	s8,16(sp)
    80003a80:	6ca2                	ld	s9,8(sp)
    80003a82:	6125                	addi	sp,sp,96
    80003a84:	8082                	ret
    brelse(bp);
    80003a86:	854a                	mv	a0,s2
    80003a88:	00000097          	auipc	ra,0x0
    80003a8c:	dc4080e7          	jalr	-572(ra) # 8000384c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003a90:	015c87bb          	addw	a5,s9,s5
    80003a94:	00078a9b          	sext.w	s5,a5
    80003a98:	004b2703          	lw	a4,4(s6)
    80003a9c:	06eaf363          	bgeu	s5,a4,80003b02 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003aa0:	41fad79b          	sraiw	a5,s5,0x1f
    80003aa4:	0137d79b          	srliw	a5,a5,0x13
    80003aa8:	015787bb          	addw	a5,a5,s5
    80003aac:	40d7d79b          	sraiw	a5,a5,0xd
    80003ab0:	01cb2583          	lw	a1,28(s6)
    80003ab4:	9dbd                	addw	a1,a1,a5
    80003ab6:	855e                	mv	a0,s7
    80003ab8:	00000097          	auipc	ra,0x0
    80003abc:	c64080e7          	jalr	-924(ra) # 8000371c <bread>
    80003ac0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ac2:	004b2503          	lw	a0,4(s6)
    80003ac6:	000a849b          	sext.w	s1,s5
    80003aca:	8662                	mv	a2,s8
    80003acc:	faa4fde3          	bgeu	s1,a0,80003a86 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003ad0:	41f6579b          	sraiw	a5,a2,0x1f
    80003ad4:	01d7d69b          	srliw	a3,a5,0x1d
    80003ad8:	00c6873b          	addw	a4,a3,a2
    80003adc:	00777793          	andi	a5,a4,7
    80003ae0:	9f95                	subw	a5,a5,a3
    80003ae2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003ae6:	4037571b          	sraiw	a4,a4,0x3
    80003aea:	00e906b3          	add	a3,s2,a4
    80003aee:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    80003af2:	00d7f5b3          	and	a1,a5,a3
    80003af6:	d195                	beqz	a1,80003a1a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003af8:	2605                	addiw	a2,a2,1
    80003afa:	2485                	addiw	s1,s1,1
    80003afc:	fd4618e3          	bne	a2,s4,80003acc <balloc+0xee>
    80003b00:	b759                	j	80003a86 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003b02:	00005517          	auipc	a0,0x5
    80003b06:	a6650513          	addi	a0,a0,-1434 # 80008568 <syscalls+0x128>
    80003b0a:	ffffd097          	auipc	ra,0xffffd
    80003b0e:	a7e080e7          	jalr	-1410(ra) # 80000588 <printf>
  return 0;
    80003b12:	4481                	li	s1,0
    80003b14:	bf99                	j	80003a6a <balloc+0x8c>

0000000080003b16 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b16:	7179                	addi	sp,sp,-48
    80003b18:	f406                	sd	ra,40(sp)
    80003b1a:	f022                	sd	s0,32(sp)
    80003b1c:	ec26                	sd	s1,24(sp)
    80003b1e:	e84a                	sd	s2,16(sp)
    80003b20:	e44e                	sd	s3,8(sp)
    80003b22:	e052                	sd	s4,0(sp)
    80003b24:	1800                	addi	s0,sp,48
    80003b26:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b28:	47ad                	li	a5,11
    80003b2a:	02b7e763          	bltu	a5,a1,80003b58 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003b2e:	02059493          	slli	s1,a1,0x20
    80003b32:	9081                	srli	s1,s1,0x20
    80003b34:	048a                	slli	s1,s1,0x2
    80003b36:	94aa                	add	s1,s1,a0
    80003b38:	0504a903          	lw	s2,80(s1)
    80003b3c:	06091e63          	bnez	s2,80003bb8 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003b40:	4108                	lw	a0,0(a0)
    80003b42:	00000097          	auipc	ra,0x0
    80003b46:	e9c080e7          	jalr	-356(ra) # 800039de <balloc>
    80003b4a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b4e:	06090563          	beqz	s2,80003bb8 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003b52:	0524a823          	sw	s2,80(s1)
    80003b56:	a08d                	j	80003bb8 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003b58:	ff45849b          	addiw	s1,a1,-12
    80003b5c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003b60:	0ff00793          	li	a5,255
    80003b64:	08e7e563          	bltu	a5,a4,80003bee <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003b68:	08052903          	lw	s2,128(a0)
    80003b6c:	00091d63          	bnez	s2,80003b86 <bmap+0x70>
      addr = balloc(ip->dev);
    80003b70:	4108                	lw	a0,0(a0)
    80003b72:	00000097          	auipc	ra,0x0
    80003b76:	e6c080e7          	jalr	-404(ra) # 800039de <balloc>
    80003b7a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b7e:	02090d63          	beqz	s2,80003bb8 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003b82:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003b86:	85ca                	mv	a1,s2
    80003b88:	0009a503          	lw	a0,0(s3)
    80003b8c:	00000097          	auipc	ra,0x0
    80003b90:	b90080e7          	jalr	-1136(ra) # 8000371c <bread>
    80003b94:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003b96:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003b9a:	02049593          	slli	a1,s1,0x20
    80003b9e:	9181                	srli	a1,a1,0x20
    80003ba0:	058a                	slli	a1,a1,0x2
    80003ba2:	00b784b3          	add	s1,a5,a1
    80003ba6:	0004a903          	lw	s2,0(s1)
    80003baa:	02090063          	beqz	s2,80003bca <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003bae:	8552                	mv	a0,s4
    80003bb0:	00000097          	auipc	ra,0x0
    80003bb4:	c9c080e7          	jalr	-868(ra) # 8000384c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003bb8:	854a                	mv	a0,s2
    80003bba:	70a2                	ld	ra,40(sp)
    80003bbc:	7402                	ld	s0,32(sp)
    80003bbe:	64e2                	ld	s1,24(sp)
    80003bc0:	6942                	ld	s2,16(sp)
    80003bc2:	69a2                	ld	s3,8(sp)
    80003bc4:	6a02                	ld	s4,0(sp)
    80003bc6:	6145                	addi	sp,sp,48
    80003bc8:	8082                	ret
      addr = balloc(ip->dev);
    80003bca:	0009a503          	lw	a0,0(s3)
    80003bce:	00000097          	auipc	ra,0x0
    80003bd2:	e10080e7          	jalr	-496(ra) # 800039de <balloc>
    80003bd6:	0005091b          	sext.w	s2,a0
      if(addr){
    80003bda:	fc090ae3          	beqz	s2,80003bae <bmap+0x98>
        a[bn] = addr;
    80003bde:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003be2:	8552                	mv	a0,s4
    80003be4:	00001097          	auipc	ra,0x1
    80003be8:	ef0080e7          	jalr	-272(ra) # 80004ad4 <log_write>
    80003bec:	b7c9                	j	80003bae <bmap+0x98>
  panic("bmap: out of range");
    80003bee:	00005517          	auipc	a0,0x5
    80003bf2:	99250513          	addi	a0,a0,-1646 # 80008580 <syscalls+0x140>
    80003bf6:	ffffd097          	auipc	ra,0xffffd
    80003bfa:	948080e7          	jalr	-1720(ra) # 8000053e <panic>

0000000080003bfe <iget>:
{
    80003bfe:	7179                	addi	sp,sp,-48
    80003c00:	f406                	sd	ra,40(sp)
    80003c02:	f022                	sd	s0,32(sp)
    80003c04:	ec26                	sd	s1,24(sp)
    80003c06:	e84a                	sd	s2,16(sp)
    80003c08:	e44e                	sd	s3,8(sp)
    80003c0a:	e052                	sd	s4,0(sp)
    80003c0c:	1800                	addi	s0,sp,48
    80003c0e:	89aa                	mv	s3,a0
    80003c10:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c12:	00038517          	auipc	a0,0x38
    80003c16:	a8650513          	addi	a0,a0,-1402 # 8003b698 <itable>
    80003c1a:	ffffd097          	auipc	ra,0xffffd
    80003c1e:	fbc080e7          	jalr	-68(ra) # 80000bd6 <acquire>
  empty = 0;
    80003c22:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c24:	00038497          	auipc	s1,0x38
    80003c28:	a8c48493          	addi	s1,s1,-1396 # 8003b6b0 <itable+0x18>
    80003c2c:	00039697          	auipc	a3,0x39
    80003c30:	51468693          	addi	a3,a3,1300 # 8003d140 <log>
    80003c34:	a039                	j	80003c42 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c36:	02090b63          	beqz	s2,80003c6c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c3a:	08848493          	addi	s1,s1,136
    80003c3e:	02d48a63          	beq	s1,a3,80003c72 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c42:	449c                	lw	a5,8(s1)
    80003c44:	fef059e3          	blez	a5,80003c36 <iget+0x38>
    80003c48:	4098                	lw	a4,0(s1)
    80003c4a:	ff3716e3          	bne	a4,s3,80003c36 <iget+0x38>
    80003c4e:	40d8                	lw	a4,4(s1)
    80003c50:	ff4713e3          	bne	a4,s4,80003c36 <iget+0x38>
      ip->ref++;
    80003c54:	2785                	addiw	a5,a5,1
    80003c56:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003c58:	00038517          	auipc	a0,0x38
    80003c5c:	a4050513          	addi	a0,a0,-1472 # 8003b698 <itable>
    80003c60:	ffffd097          	auipc	ra,0xffffd
    80003c64:	02a080e7          	jalr	42(ra) # 80000c8a <release>
      return ip;
    80003c68:	8926                	mv	s2,s1
    80003c6a:	a03d                	j	80003c98 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c6c:	f7f9                	bnez	a5,80003c3a <iget+0x3c>
    80003c6e:	8926                	mv	s2,s1
    80003c70:	b7e9                	j	80003c3a <iget+0x3c>
  if(empty == 0)
    80003c72:	02090c63          	beqz	s2,80003caa <iget+0xac>
  ip->dev = dev;
    80003c76:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003c7a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003c7e:	4785                	li	a5,1
    80003c80:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003c84:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003c88:	00038517          	auipc	a0,0x38
    80003c8c:	a1050513          	addi	a0,a0,-1520 # 8003b698 <itable>
    80003c90:	ffffd097          	auipc	ra,0xffffd
    80003c94:	ffa080e7          	jalr	-6(ra) # 80000c8a <release>
}
    80003c98:	854a                	mv	a0,s2
    80003c9a:	70a2                	ld	ra,40(sp)
    80003c9c:	7402                	ld	s0,32(sp)
    80003c9e:	64e2                	ld	s1,24(sp)
    80003ca0:	6942                	ld	s2,16(sp)
    80003ca2:	69a2                	ld	s3,8(sp)
    80003ca4:	6a02                	ld	s4,0(sp)
    80003ca6:	6145                	addi	sp,sp,48
    80003ca8:	8082                	ret
    panic("iget: no inodes");
    80003caa:	00005517          	auipc	a0,0x5
    80003cae:	8ee50513          	addi	a0,a0,-1810 # 80008598 <syscalls+0x158>
    80003cb2:	ffffd097          	auipc	ra,0xffffd
    80003cb6:	88c080e7          	jalr	-1908(ra) # 8000053e <panic>

0000000080003cba <fsinit>:
fsinit(int dev) {
    80003cba:	7179                	addi	sp,sp,-48
    80003cbc:	f406                	sd	ra,40(sp)
    80003cbe:	f022                	sd	s0,32(sp)
    80003cc0:	ec26                	sd	s1,24(sp)
    80003cc2:	e84a                	sd	s2,16(sp)
    80003cc4:	e44e                	sd	s3,8(sp)
    80003cc6:	1800                	addi	s0,sp,48
    80003cc8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003cca:	4585                	li	a1,1
    80003ccc:	00000097          	auipc	ra,0x0
    80003cd0:	a50080e7          	jalr	-1456(ra) # 8000371c <bread>
    80003cd4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003cd6:	00038997          	auipc	s3,0x38
    80003cda:	9a298993          	addi	s3,s3,-1630 # 8003b678 <sb>
    80003cde:	02000613          	li	a2,32
    80003ce2:	05850593          	addi	a1,a0,88
    80003ce6:	854e                	mv	a0,s3
    80003ce8:	ffffd097          	auipc	ra,0xffffd
    80003cec:	046080e7          	jalr	70(ra) # 80000d2e <memmove>
  brelse(bp);
    80003cf0:	8526                	mv	a0,s1
    80003cf2:	00000097          	auipc	ra,0x0
    80003cf6:	b5a080e7          	jalr	-1190(ra) # 8000384c <brelse>
  if(sb.magic != FSMAGIC)
    80003cfa:	0009a703          	lw	a4,0(s3)
    80003cfe:	102037b7          	lui	a5,0x10203
    80003d02:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d06:	02f71263          	bne	a4,a5,80003d2a <fsinit+0x70>
  initlog(dev, &sb);
    80003d0a:	00038597          	auipc	a1,0x38
    80003d0e:	96e58593          	addi	a1,a1,-1682 # 8003b678 <sb>
    80003d12:	854a                	mv	a0,s2
    80003d14:	00001097          	auipc	ra,0x1
    80003d18:	b44080e7          	jalr	-1212(ra) # 80004858 <initlog>
}
    80003d1c:	70a2                	ld	ra,40(sp)
    80003d1e:	7402                	ld	s0,32(sp)
    80003d20:	64e2                	ld	s1,24(sp)
    80003d22:	6942                	ld	s2,16(sp)
    80003d24:	69a2                	ld	s3,8(sp)
    80003d26:	6145                	addi	sp,sp,48
    80003d28:	8082                	ret
    panic("invalid file system");
    80003d2a:	00005517          	auipc	a0,0x5
    80003d2e:	87e50513          	addi	a0,a0,-1922 # 800085a8 <syscalls+0x168>
    80003d32:	ffffd097          	auipc	ra,0xffffd
    80003d36:	80c080e7          	jalr	-2036(ra) # 8000053e <panic>

0000000080003d3a <iinit>:
{
    80003d3a:	7179                	addi	sp,sp,-48
    80003d3c:	f406                	sd	ra,40(sp)
    80003d3e:	f022                	sd	s0,32(sp)
    80003d40:	ec26                	sd	s1,24(sp)
    80003d42:	e84a                	sd	s2,16(sp)
    80003d44:	e44e                	sd	s3,8(sp)
    80003d46:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003d48:	00005597          	auipc	a1,0x5
    80003d4c:	87858593          	addi	a1,a1,-1928 # 800085c0 <syscalls+0x180>
    80003d50:	00038517          	auipc	a0,0x38
    80003d54:	94850513          	addi	a0,a0,-1720 # 8003b698 <itable>
    80003d58:	ffffd097          	auipc	ra,0xffffd
    80003d5c:	dee080e7          	jalr	-530(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003d60:	00038497          	auipc	s1,0x38
    80003d64:	96048493          	addi	s1,s1,-1696 # 8003b6c0 <itable+0x28>
    80003d68:	00039997          	auipc	s3,0x39
    80003d6c:	3e898993          	addi	s3,s3,1000 # 8003d150 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d70:	00005917          	auipc	s2,0x5
    80003d74:	85890913          	addi	s2,s2,-1960 # 800085c8 <syscalls+0x188>
    80003d78:	85ca                	mv	a1,s2
    80003d7a:	8526                	mv	a0,s1
    80003d7c:	00001097          	auipc	ra,0x1
    80003d80:	e3e080e7          	jalr	-450(ra) # 80004bba <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d84:	08848493          	addi	s1,s1,136
    80003d88:	ff3498e3          	bne	s1,s3,80003d78 <iinit+0x3e>
}
    80003d8c:	70a2                	ld	ra,40(sp)
    80003d8e:	7402                	ld	s0,32(sp)
    80003d90:	64e2                	ld	s1,24(sp)
    80003d92:	6942                	ld	s2,16(sp)
    80003d94:	69a2                	ld	s3,8(sp)
    80003d96:	6145                	addi	sp,sp,48
    80003d98:	8082                	ret

0000000080003d9a <ialloc>:
{
    80003d9a:	715d                	addi	sp,sp,-80
    80003d9c:	e486                	sd	ra,72(sp)
    80003d9e:	e0a2                	sd	s0,64(sp)
    80003da0:	fc26                	sd	s1,56(sp)
    80003da2:	f84a                	sd	s2,48(sp)
    80003da4:	f44e                	sd	s3,40(sp)
    80003da6:	f052                	sd	s4,32(sp)
    80003da8:	ec56                	sd	s5,24(sp)
    80003daa:	e85a                	sd	s6,16(sp)
    80003dac:	e45e                	sd	s7,8(sp)
    80003dae:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003db0:	00038717          	auipc	a4,0x38
    80003db4:	8d472703          	lw	a4,-1836(a4) # 8003b684 <sb+0xc>
    80003db8:	4785                	li	a5,1
    80003dba:	04e7fa63          	bgeu	a5,a4,80003e0e <ialloc+0x74>
    80003dbe:	8aaa                	mv	s5,a0
    80003dc0:	8bae                	mv	s7,a1
    80003dc2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003dc4:	00038a17          	auipc	s4,0x38
    80003dc8:	8b4a0a13          	addi	s4,s4,-1868 # 8003b678 <sb>
    80003dcc:	00048b1b          	sext.w	s6,s1
    80003dd0:	0044d793          	srli	a5,s1,0x4
    80003dd4:	018a2583          	lw	a1,24(s4)
    80003dd8:	9dbd                	addw	a1,a1,a5
    80003dda:	8556                	mv	a0,s5
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	940080e7          	jalr	-1728(ra) # 8000371c <bread>
    80003de4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003de6:	05850993          	addi	s3,a0,88
    80003dea:	00f4f793          	andi	a5,s1,15
    80003dee:	079a                	slli	a5,a5,0x6
    80003df0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003df2:	00099783          	lh	a5,0(s3)
    80003df6:	c3a1                	beqz	a5,80003e36 <ialloc+0x9c>
    brelse(bp);
    80003df8:	00000097          	auipc	ra,0x0
    80003dfc:	a54080e7          	jalr	-1452(ra) # 8000384c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e00:	0485                	addi	s1,s1,1
    80003e02:	00ca2703          	lw	a4,12(s4)
    80003e06:	0004879b          	sext.w	a5,s1
    80003e0a:	fce7e1e3          	bltu	a5,a4,80003dcc <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003e0e:	00004517          	auipc	a0,0x4
    80003e12:	7c250513          	addi	a0,a0,1986 # 800085d0 <syscalls+0x190>
    80003e16:	ffffc097          	auipc	ra,0xffffc
    80003e1a:	772080e7          	jalr	1906(ra) # 80000588 <printf>
  return 0;
    80003e1e:	4501                	li	a0,0
}
    80003e20:	60a6                	ld	ra,72(sp)
    80003e22:	6406                	ld	s0,64(sp)
    80003e24:	74e2                	ld	s1,56(sp)
    80003e26:	7942                	ld	s2,48(sp)
    80003e28:	79a2                	ld	s3,40(sp)
    80003e2a:	7a02                	ld	s4,32(sp)
    80003e2c:	6ae2                	ld	s5,24(sp)
    80003e2e:	6b42                	ld	s6,16(sp)
    80003e30:	6ba2                	ld	s7,8(sp)
    80003e32:	6161                	addi	sp,sp,80
    80003e34:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e36:	04000613          	li	a2,64
    80003e3a:	4581                	li	a1,0
    80003e3c:	854e                	mv	a0,s3
    80003e3e:	ffffd097          	auipc	ra,0xffffd
    80003e42:	e94080e7          	jalr	-364(ra) # 80000cd2 <memset>
      dip->type = type;
    80003e46:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003e4a:	854a                	mv	a0,s2
    80003e4c:	00001097          	auipc	ra,0x1
    80003e50:	c88080e7          	jalr	-888(ra) # 80004ad4 <log_write>
      brelse(bp);
    80003e54:	854a                	mv	a0,s2
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	9f6080e7          	jalr	-1546(ra) # 8000384c <brelse>
      return iget(dev, inum);
    80003e5e:	85da                	mv	a1,s6
    80003e60:	8556                	mv	a0,s5
    80003e62:	00000097          	auipc	ra,0x0
    80003e66:	d9c080e7          	jalr	-612(ra) # 80003bfe <iget>
    80003e6a:	bf5d                	j	80003e20 <ialloc+0x86>

0000000080003e6c <iupdate>:
{
    80003e6c:	1101                	addi	sp,sp,-32
    80003e6e:	ec06                	sd	ra,24(sp)
    80003e70:	e822                	sd	s0,16(sp)
    80003e72:	e426                	sd	s1,8(sp)
    80003e74:	e04a                	sd	s2,0(sp)
    80003e76:	1000                	addi	s0,sp,32
    80003e78:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e7a:	415c                	lw	a5,4(a0)
    80003e7c:	0047d79b          	srliw	a5,a5,0x4
    80003e80:	00038597          	auipc	a1,0x38
    80003e84:	8105a583          	lw	a1,-2032(a1) # 8003b690 <sb+0x18>
    80003e88:	9dbd                	addw	a1,a1,a5
    80003e8a:	4108                	lw	a0,0(a0)
    80003e8c:	00000097          	auipc	ra,0x0
    80003e90:	890080e7          	jalr	-1904(ra) # 8000371c <bread>
    80003e94:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e96:	05850793          	addi	a5,a0,88
    80003e9a:	40c8                	lw	a0,4(s1)
    80003e9c:	893d                	andi	a0,a0,15
    80003e9e:	051a                	slli	a0,a0,0x6
    80003ea0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ea2:	04449703          	lh	a4,68(s1)
    80003ea6:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003eaa:	04649703          	lh	a4,70(s1)
    80003eae:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003eb2:	04849703          	lh	a4,72(s1)
    80003eb6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003eba:	04a49703          	lh	a4,74(s1)
    80003ebe:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ec2:	44f8                	lw	a4,76(s1)
    80003ec4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ec6:	03400613          	li	a2,52
    80003eca:	05048593          	addi	a1,s1,80
    80003ece:	0531                	addi	a0,a0,12
    80003ed0:	ffffd097          	auipc	ra,0xffffd
    80003ed4:	e5e080e7          	jalr	-418(ra) # 80000d2e <memmove>
  log_write(bp);
    80003ed8:	854a                	mv	a0,s2
    80003eda:	00001097          	auipc	ra,0x1
    80003ede:	bfa080e7          	jalr	-1030(ra) # 80004ad4 <log_write>
  brelse(bp);
    80003ee2:	854a                	mv	a0,s2
    80003ee4:	00000097          	auipc	ra,0x0
    80003ee8:	968080e7          	jalr	-1688(ra) # 8000384c <brelse>
}
    80003eec:	60e2                	ld	ra,24(sp)
    80003eee:	6442                	ld	s0,16(sp)
    80003ef0:	64a2                	ld	s1,8(sp)
    80003ef2:	6902                	ld	s2,0(sp)
    80003ef4:	6105                	addi	sp,sp,32
    80003ef6:	8082                	ret

0000000080003ef8 <idup>:
{
    80003ef8:	1101                	addi	sp,sp,-32
    80003efa:	ec06                	sd	ra,24(sp)
    80003efc:	e822                	sd	s0,16(sp)
    80003efe:	e426                	sd	s1,8(sp)
    80003f00:	1000                	addi	s0,sp,32
    80003f02:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f04:	00037517          	auipc	a0,0x37
    80003f08:	79450513          	addi	a0,a0,1940 # 8003b698 <itable>
    80003f0c:	ffffd097          	auipc	ra,0xffffd
    80003f10:	cca080e7          	jalr	-822(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003f14:	449c                	lw	a5,8(s1)
    80003f16:	2785                	addiw	a5,a5,1
    80003f18:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f1a:	00037517          	auipc	a0,0x37
    80003f1e:	77e50513          	addi	a0,a0,1918 # 8003b698 <itable>
    80003f22:	ffffd097          	auipc	ra,0xffffd
    80003f26:	d68080e7          	jalr	-664(ra) # 80000c8a <release>
}
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	60e2                	ld	ra,24(sp)
    80003f2e:	6442                	ld	s0,16(sp)
    80003f30:	64a2                	ld	s1,8(sp)
    80003f32:	6105                	addi	sp,sp,32
    80003f34:	8082                	ret

0000000080003f36 <ilock>:
{
    80003f36:	1101                	addi	sp,sp,-32
    80003f38:	ec06                	sd	ra,24(sp)
    80003f3a:	e822                	sd	s0,16(sp)
    80003f3c:	e426                	sd	s1,8(sp)
    80003f3e:	e04a                	sd	s2,0(sp)
    80003f40:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003f42:	c115                	beqz	a0,80003f66 <ilock+0x30>
    80003f44:	84aa                	mv	s1,a0
    80003f46:	451c                	lw	a5,8(a0)
    80003f48:	00f05f63          	blez	a5,80003f66 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003f4c:	0541                	addi	a0,a0,16
    80003f4e:	00001097          	auipc	ra,0x1
    80003f52:	ca6080e7          	jalr	-858(ra) # 80004bf4 <acquiresleep>
  if(ip->valid == 0){
    80003f56:	40bc                	lw	a5,64(s1)
    80003f58:	cf99                	beqz	a5,80003f76 <ilock+0x40>
}
    80003f5a:	60e2                	ld	ra,24(sp)
    80003f5c:	6442                	ld	s0,16(sp)
    80003f5e:	64a2                	ld	s1,8(sp)
    80003f60:	6902                	ld	s2,0(sp)
    80003f62:	6105                	addi	sp,sp,32
    80003f64:	8082                	ret
    panic("ilock");
    80003f66:	00004517          	auipc	a0,0x4
    80003f6a:	68250513          	addi	a0,a0,1666 # 800085e8 <syscalls+0x1a8>
    80003f6e:	ffffc097          	auipc	ra,0xffffc
    80003f72:	5d0080e7          	jalr	1488(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f76:	40dc                	lw	a5,4(s1)
    80003f78:	0047d79b          	srliw	a5,a5,0x4
    80003f7c:	00037597          	auipc	a1,0x37
    80003f80:	7145a583          	lw	a1,1812(a1) # 8003b690 <sb+0x18>
    80003f84:	9dbd                	addw	a1,a1,a5
    80003f86:	4088                	lw	a0,0(s1)
    80003f88:	fffff097          	auipc	ra,0xfffff
    80003f8c:	794080e7          	jalr	1940(ra) # 8000371c <bread>
    80003f90:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f92:	05850593          	addi	a1,a0,88
    80003f96:	40dc                	lw	a5,4(s1)
    80003f98:	8bbd                	andi	a5,a5,15
    80003f9a:	079a                	slli	a5,a5,0x6
    80003f9c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f9e:	00059783          	lh	a5,0(a1)
    80003fa2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003fa6:	00259783          	lh	a5,2(a1)
    80003faa:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003fae:	00459783          	lh	a5,4(a1)
    80003fb2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003fb6:	00659783          	lh	a5,6(a1)
    80003fba:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003fbe:	459c                	lw	a5,8(a1)
    80003fc0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003fc2:	03400613          	li	a2,52
    80003fc6:	05b1                	addi	a1,a1,12
    80003fc8:	05048513          	addi	a0,s1,80
    80003fcc:	ffffd097          	auipc	ra,0xffffd
    80003fd0:	d62080e7          	jalr	-670(ra) # 80000d2e <memmove>
    brelse(bp);
    80003fd4:	854a                	mv	a0,s2
    80003fd6:	00000097          	auipc	ra,0x0
    80003fda:	876080e7          	jalr	-1930(ra) # 8000384c <brelse>
    ip->valid = 1;
    80003fde:	4785                	li	a5,1
    80003fe0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003fe2:	04449783          	lh	a5,68(s1)
    80003fe6:	fbb5                	bnez	a5,80003f5a <ilock+0x24>
      panic("ilock: no type");
    80003fe8:	00004517          	auipc	a0,0x4
    80003fec:	60850513          	addi	a0,a0,1544 # 800085f0 <syscalls+0x1b0>
    80003ff0:	ffffc097          	auipc	ra,0xffffc
    80003ff4:	54e080e7          	jalr	1358(ra) # 8000053e <panic>

0000000080003ff8 <iunlock>:
{
    80003ff8:	1101                	addi	sp,sp,-32
    80003ffa:	ec06                	sd	ra,24(sp)
    80003ffc:	e822                	sd	s0,16(sp)
    80003ffe:	e426                	sd	s1,8(sp)
    80004000:	e04a                	sd	s2,0(sp)
    80004002:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004004:	c905                	beqz	a0,80004034 <iunlock+0x3c>
    80004006:	84aa                	mv	s1,a0
    80004008:	01050913          	addi	s2,a0,16
    8000400c:	854a                	mv	a0,s2
    8000400e:	00001097          	auipc	ra,0x1
    80004012:	c80080e7          	jalr	-896(ra) # 80004c8e <holdingsleep>
    80004016:	cd19                	beqz	a0,80004034 <iunlock+0x3c>
    80004018:	449c                	lw	a5,8(s1)
    8000401a:	00f05d63          	blez	a5,80004034 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000401e:	854a                	mv	a0,s2
    80004020:	00001097          	auipc	ra,0x1
    80004024:	c2a080e7          	jalr	-982(ra) # 80004c4a <releasesleep>
}
    80004028:	60e2                	ld	ra,24(sp)
    8000402a:	6442                	ld	s0,16(sp)
    8000402c:	64a2                	ld	s1,8(sp)
    8000402e:	6902                	ld	s2,0(sp)
    80004030:	6105                	addi	sp,sp,32
    80004032:	8082                	ret
    panic("iunlock");
    80004034:	00004517          	auipc	a0,0x4
    80004038:	5cc50513          	addi	a0,a0,1484 # 80008600 <syscalls+0x1c0>
    8000403c:	ffffc097          	auipc	ra,0xffffc
    80004040:	502080e7          	jalr	1282(ra) # 8000053e <panic>

0000000080004044 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004044:	7179                	addi	sp,sp,-48
    80004046:	f406                	sd	ra,40(sp)
    80004048:	f022                	sd	s0,32(sp)
    8000404a:	ec26                	sd	s1,24(sp)
    8000404c:	e84a                	sd	s2,16(sp)
    8000404e:	e44e                	sd	s3,8(sp)
    80004050:	e052                	sd	s4,0(sp)
    80004052:	1800                	addi	s0,sp,48
    80004054:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004056:	05050493          	addi	s1,a0,80
    8000405a:	08050913          	addi	s2,a0,128
    8000405e:	a021                	j	80004066 <itrunc+0x22>
    80004060:	0491                	addi	s1,s1,4
    80004062:	01248d63          	beq	s1,s2,8000407c <itrunc+0x38>
    if(ip->addrs[i]){
    80004066:	408c                	lw	a1,0(s1)
    80004068:	dde5                	beqz	a1,80004060 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000406a:	0009a503          	lw	a0,0(s3)
    8000406e:	00000097          	auipc	ra,0x0
    80004072:	8f4080e7          	jalr	-1804(ra) # 80003962 <bfree>
      ip->addrs[i] = 0;
    80004076:	0004a023          	sw	zero,0(s1)
    8000407a:	b7dd                	j	80004060 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000407c:	0809a583          	lw	a1,128(s3)
    80004080:	e185                	bnez	a1,800040a0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004082:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004086:	854e                	mv	a0,s3
    80004088:	00000097          	auipc	ra,0x0
    8000408c:	de4080e7          	jalr	-540(ra) # 80003e6c <iupdate>
}
    80004090:	70a2                	ld	ra,40(sp)
    80004092:	7402                	ld	s0,32(sp)
    80004094:	64e2                	ld	s1,24(sp)
    80004096:	6942                	ld	s2,16(sp)
    80004098:	69a2                	ld	s3,8(sp)
    8000409a:	6a02                	ld	s4,0(sp)
    8000409c:	6145                	addi	sp,sp,48
    8000409e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800040a0:	0009a503          	lw	a0,0(s3)
    800040a4:	fffff097          	auipc	ra,0xfffff
    800040a8:	678080e7          	jalr	1656(ra) # 8000371c <bread>
    800040ac:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800040ae:	05850493          	addi	s1,a0,88
    800040b2:	45850913          	addi	s2,a0,1112
    800040b6:	a021                	j	800040be <itrunc+0x7a>
    800040b8:	0491                	addi	s1,s1,4
    800040ba:	01248b63          	beq	s1,s2,800040d0 <itrunc+0x8c>
      if(a[j])
    800040be:	408c                	lw	a1,0(s1)
    800040c0:	dde5                	beqz	a1,800040b8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800040c2:	0009a503          	lw	a0,0(s3)
    800040c6:	00000097          	auipc	ra,0x0
    800040ca:	89c080e7          	jalr	-1892(ra) # 80003962 <bfree>
    800040ce:	b7ed                	j	800040b8 <itrunc+0x74>
    brelse(bp);
    800040d0:	8552                	mv	a0,s4
    800040d2:	fffff097          	auipc	ra,0xfffff
    800040d6:	77a080e7          	jalr	1914(ra) # 8000384c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800040da:	0809a583          	lw	a1,128(s3)
    800040de:	0009a503          	lw	a0,0(s3)
    800040e2:	00000097          	auipc	ra,0x0
    800040e6:	880080e7          	jalr	-1920(ra) # 80003962 <bfree>
    ip->addrs[NDIRECT] = 0;
    800040ea:	0809a023          	sw	zero,128(s3)
    800040ee:	bf51                	j	80004082 <itrunc+0x3e>

00000000800040f0 <iput>:
{
    800040f0:	1101                	addi	sp,sp,-32
    800040f2:	ec06                	sd	ra,24(sp)
    800040f4:	e822                	sd	s0,16(sp)
    800040f6:	e426                	sd	s1,8(sp)
    800040f8:	e04a                	sd	s2,0(sp)
    800040fa:	1000                	addi	s0,sp,32
    800040fc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800040fe:	00037517          	auipc	a0,0x37
    80004102:	59a50513          	addi	a0,a0,1434 # 8003b698 <itable>
    80004106:	ffffd097          	auipc	ra,0xffffd
    8000410a:	ad0080e7          	jalr	-1328(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000410e:	4498                	lw	a4,8(s1)
    80004110:	4785                	li	a5,1
    80004112:	02f70363          	beq	a4,a5,80004138 <iput+0x48>
  ip->ref--;
    80004116:	449c                	lw	a5,8(s1)
    80004118:	37fd                	addiw	a5,a5,-1
    8000411a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000411c:	00037517          	auipc	a0,0x37
    80004120:	57c50513          	addi	a0,a0,1404 # 8003b698 <itable>
    80004124:	ffffd097          	auipc	ra,0xffffd
    80004128:	b66080e7          	jalr	-1178(ra) # 80000c8a <release>
}
    8000412c:	60e2                	ld	ra,24(sp)
    8000412e:	6442                	ld	s0,16(sp)
    80004130:	64a2                	ld	s1,8(sp)
    80004132:	6902                	ld	s2,0(sp)
    80004134:	6105                	addi	sp,sp,32
    80004136:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004138:	40bc                	lw	a5,64(s1)
    8000413a:	dff1                	beqz	a5,80004116 <iput+0x26>
    8000413c:	04a49783          	lh	a5,74(s1)
    80004140:	fbf9                	bnez	a5,80004116 <iput+0x26>
    acquiresleep(&ip->lock);
    80004142:	01048913          	addi	s2,s1,16
    80004146:	854a                	mv	a0,s2
    80004148:	00001097          	auipc	ra,0x1
    8000414c:	aac080e7          	jalr	-1364(ra) # 80004bf4 <acquiresleep>
    release(&itable.lock);
    80004150:	00037517          	auipc	a0,0x37
    80004154:	54850513          	addi	a0,a0,1352 # 8003b698 <itable>
    80004158:	ffffd097          	auipc	ra,0xffffd
    8000415c:	b32080e7          	jalr	-1230(ra) # 80000c8a <release>
    itrunc(ip);
    80004160:	8526                	mv	a0,s1
    80004162:	00000097          	auipc	ra,0x0
    80004166:	ee2080e7          	jalr	-286(ra) # 80004044 <itrunc>
    ip->type = 0;
    8000416a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000416e:	8526                	mv	a0,s1
    80004170:	00000097          	auipc	ra,0x0
    80004174:	cfc080e7          	jalr	-772(ra) # 80003e6c <iupdate>
    ip->valid = 0;
    80004178:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000417c:	854a                	mv	a0,s2
    8000417e:	00001097          	auipc	ra,0x1
    80004182:	acc080e7          	jalr	-1332(ra) # 80004c4a <releasesleep>
    acquire(&itable.lock);
    80004186:	00037517          	auipc	a0,0x37
    8000418a:	51250513          	addi	a0,a0,1298 # 8003b698 <itable>
    8000418e:	ffffd097          	auipc	ra,0xffffd
    80004192:	a48080e7          	jalr	-1464(ra) # 80000bd6 <acquire>
    80004196:	b741                	j	80004116 <iput+0x26>

0000000080004198 <iunlockput>:
{
    80004198:	1101                	addi	sp,sp,-32
    8000419a:	ec06                	sd	ra,24(sp)
    8000419c:	e822                	sd	s0,16(sp)
    8000419e:	e426                	sd	s1,8(sp)
    800041a0:	1000                	addi	s0,sp,32
    800041a2:	84aa                	mv	s1,a0
  iunlock(ip);
    800041a4:	00000097          	auipc	ra,0x0
    800041a8:	e54080e7          	jalr	-428(ra) # 80003ff8 <iunlock>
  iput(ip);
    800041ac:	8526                	mv	a0,s1
    800041ae:	00000097          	auipc	ra,0x0
    800041b2:	f42080e7          	jalr	-190(ra) # 800040f0 <iput>
}
    800041b6:	60e2                	ld	ra,24(sp)
    800041b8:	6442                	ld	s0,16(sp)
    800041ba:	64a2                	ld	s1,8(sp)
    800041bc:	6105                	addi	sp,sp,32
    800041be:	8082                	ret

00000000800041c0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800041c0:	1141                	addi	sp,sp,-16
    800041c2:	e422                	sd	s0,8(sp)
    800041c4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800041c6:	411c                	lw	a5,0(a0)
    800041c8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800041ca:	415c                	lw	a5,4(a0)
    800041cc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800041ce:	04451783          	lh	a5,68(a0)
    800041d2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800041d6:	04a51783          	lh	a5,74(a0)
    800041da:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800041de:	04c56783          	lwu	a5,76(a0)
    800041e2:	e99c                	sd	a5,16(a1)
}
    800041e4:	6422                	ld	s0,8(sp)
    800041e6:	0141                	addi	sp,sp,16
    800041e8:	8082                	ret

00000000800041ea <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041ea:	457c                	lw	a5,76(a0)
    800041ec:	0ed7e963          	bltu	a5,a3,800042de <readi+0xf4>
{
    800041f0:	7159                	addi	sp,sp,-112
    800041f2:	f486                	sd	ra,104(sp)
    800041f4:	f0a2                	sd	s0,96(sp)
    800041f6:	eca6                	sd	s1,88(sp)
    800041f8:	e8ca                	sd	s2,80(sp)
    800041fa:	e4ce                	sd	s3,72(sp)
    800041fc:	e0d2                	sd	s4,64(sp)
    800041fe:	fc56                	sd	s5,56(sp)
    80004200:	f85a                	sd	s6,48(sp)
    80004202:	f45e                	sd	s7,40(sp)
    80004204:	f062                	sd	s8,32(sp)
    80004206:	ec66                	sd	s9,24(sp)
    80004208:	e86a                	sd	s10,16(sp)
    8000420a:	e46e                	sd	s11,8(sp)
    8000420c:	1880                	addi	s0,sp,112
    8000420e:	8b2a                	mv	s6,a0
    80004210:	8bae                	mv	s7,a1
    80004212:	8a32                	mv	s4,a2
    80004214:	84b6                	mv	s1,a3
    80004216:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004218:	9f35                	addw	a4,a4,a3
    return 0;
    8000421a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000421c:	0ad76063          	bltu	a4,a3,800042bc <readi+0xd2>
  if(off + n > ip->size)
    80004220:	00e7f463          	bgeu	a5,a4,80004228 <readi+0x3e>
    n = ip->size - off;
    80004224:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004228:	0a0a8963          	beqz	s5,800042da <readi+0xf0>
    8000422c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000422e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004232:	5c7d                	li	s8,-1
    80004234:	a82d                	j	8000426e <readi+0x84>
    80004236:	020d1d93          	slli	s11,s10,0x20
    8000423a:	020ddd93          	srli	s11,s11,0x20
    8000423e:	05890793          	addi	a5,s2,88
    80004242:	86ee                	mv	a3,s11
    80004244:	963e                	add	a2,a2,a5
    80004246:	85d2                	mv	a1,s4
    80004248:	855e                	mv	a0,s7
    8000424a:	ffffe097          	auipc	ra,0xffffe
    8000424e:	43e080e7          	jalr	1086(ra) # 80002688 <either_copyout>
    80004252:	05850d63          	beq	a0,s8,800042ac <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004256:	854a                	mv	a0,s2
    80004258:	fffff097          	auipc	ra,0xfffff
    8000425c:	5f4080e7          	jalr	1524(ra) # 8000384c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004260:	013d09bb          	addw	s3,s10,s3
    80004264:	009d04bb          	addw	s1,s10,s1
    80004268:	9a6e                	add	s4,s4,s11
    8000426a:	0559f763          	bgeu	s3,s5,800042b8 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000426e:	00a4d59b          	srliw	a1,s1,0xa
    80004272:	855a                	mv	a0,s6
    80004274:	00000097          	auipc	ra,0x0
    80004278:	8a2080e7          	jalr	-1886(ra) # 80003b16 <bmap>
    8000427c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004280:	cd85                	beqz	a1,800042b8 <readi+0xce>
    bp = bread(ip->dev, addr);
    80004282:	000b2503          	lw	a0,0(s6)
    80004286:	fffff097          	auipc	ra,0xfffff
    8000428a:	496080e7          	jalr	1174(ra) # 8000371c <bread>
    8000428e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004290:	3ff4f613          	andi	a2,s1,1023
    80004294:	40cc87bb          	subw	a5,s9,a2
    80004298:	413a873b          	subw	a4,s5,s3
    8000429c:	8d3e                	mv	s10,a5
    8000429e:	2781                	sext.w	a5,a5
    800042a0:	0007069b          	sext.w	a3,a4
    800042a4:	f8f6f9e3          	bgeu	a3,a5,80004236 <readi+0x4c>
    800042a8:	8d3a                	mv	s10,a4
    800042aa:	b771                	j	80004236 <readi+0x4c>
      brelse(bp);
    800042ac:	854a                	mv	a0,s2
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	59e080e7          	jalr	1438(ra) # 8000384c <brelse>
      tot = -1;
    800042b6:	59fd                	li	s3,-1
  }
  return tot;
    800042b8:	0009851b          	sext.w	a0,s3
}
    800042bc:	70a6                	ld	ra,104(sp)
    800042be:	7406                	ld	s0,96(sp)
    800042c0:	64e6                	ld	s1,88(sp)
    800042c2:	6946                	ld	s2,80(sp)
    800042c4:	69a6                	ld	s3,72(sp)
    800042c6:	6a06                	ld	s4,64(sp)
    800042c8:	7ae2                	ld	s5,56(sp)
    800042ca:	7b42                	ld	s6,48(sp)
    800042cc:	7ba2                	ld	s7,40(sp)
    800042ce:	7c02                	ld	s8,32(sp)
    800042d0:	6ce2                	ld	s9,24(sp)
    800042d2:	6d42                	ld	s10,16(sp)
    800042d4:	6da2                	ld	s11,8(sp)
    800042d6:	6165                	addi	sp,sp,112
    800042d8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042da:	89d6                	mv	s3,s5
    800042dc:	bff1                	j	800042b8 <readi+0xce>
    return 0;
    800042de:	4501                	li	a0,0
}
    800042e0:	8082                	ret

00000000800042e2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800042e2:	457c                	lw	a5,76(a0)
    800042e4:	10d7e863          	bltu	a5,a3,800043f4 <writei+0x112>
{
    800042e8:	7159                	addi	sp,sp,-112
    800042ea:	f486                	sd	ra,104(sp)
    800042ec:	f0a2                	sd	s0,96(sp)
    800042ee:	eca6                	sd	s1,88(sp)
    800042f0:	e8ca                	sd	s2,80(sp)
    800042f2:	e4ce                	sd	s3,72(sp)
    800042f4:	e0d2                	sd	s4,64(sp)
    800042f6:	fc56                	sd	s5,56(sp)
    800042f8:	f85a                	sd	s6,48(sp)
    800042fa:	f45e                	sd	s7,40(sp)
    800042fc:	f062                	sd	s8,32(sp)
    800042fe:	ec66                	sd	s9,24(sp)
    80004300:	e86a                	sd	s10,16(sp)
    80004302:	e46e                	sd	s11,8(sp)
    80004304:	1880                	addi	s0,sp,112
    80004306:	8aaa                	mv	s5,a0
    80004308:	8bae                	mv	s7,a1
    8000430a:	8a32                	mv	s4,a2
    8000430c:	8936                	mv	s2,a3
    8000430e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004310:	00e687bb          	addw	a5,a3,a4
    80004314:	0ed7e263          	bltu	a5,a3,800043f8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004318:	00043737          	lui	a4,0x43
    8000431c:	0ef76063          	bltu	a4,a5,800043fc <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004320:	0c0b0863          	beqz	s6,800043f0 <writei+0x10e>
    80004324:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004326:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000432a:	5c7d                	li	s8,-1
    8000432c:	a091                	j	80004370 <writei+0x8e>
    8000432e:	020d1d93          	slli	s11,s10,0x20
    80004332:	020ddd93          	srli	s11,s11,0x20
    80004336:	05848793          	addi	a5,s1,88
    8000433a:	86ee                	mv	a3,s11
    8000433c:	8652                	mv	a2,s4
    8000433e:	85de                	mv	a1,s7
    80004340:	953e                	add	a0,a0,a5
    80004342:	ffffe097          	auipc	ra,0xffffe
    80004346:	39e080e7          	jalr	926(ra) # 800026e0 <either_copyin>
    8000434a:	07850263          	beq	a0,s8,800043ae <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000434e:	8526                	mv	a0,s1
    80004350:	00000097          	auipc	ra,0x0
    80004354:	784080e7          	jalr	1924(ra) # 80004ad4 <log_write>
    brelse(bp);
    80004358:	8526                	mv	a0,s1
    8000435a:	fffff097          	auipc	ra,0xfffff
    8000435e:	4f2080e7          	jalr	1266(ra) # 8000384c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004362:	013d09bb          	addw	s3,s10,s3
    80004366:	012d093b          	addw	s2,s10,s2
    8000436a:	9a6e                	add	s4,s4,s11
    8000436c:	0569f663          	bgeu	s3,s6,800043b8 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004370:	00a9559b          	srliw	a1,s2,0xa
    80004374:	8556                	mv	a0,s5
    80004376:	fffff097          	auipc	ra,0xfffff
    8000437a:	7a0080e7          	jalr	1952(ra) # 80003b16 <bmap>
    8000437e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004382:	c99d                	beqz	a1,800043b8 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004384:	000aa503          	lw	a0,0(s5)
    80004388:	fffff097          	auipc	ra,0xfffff
    8000438c:	394080e7          	jalr	916(ra) # 8000371c <bread>
    80004390:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004392:	3ff97513          	andi	a0,s2,1023
    80004396:	40ac87bb          	subw	a5,s9,a0
    8000439a:	413b073b          	subw	a4,s6,s3
    8000439e:	8d3e                	mv	s10,a5
    800043a0:	2781                	sext.w	a5,a5
    800043a2:	0007069b          	sext.w	a3,a4
    800043a6:	f8f6f4e3          	bgeu	a3,a5,8000432e <writei+0x4c>
    800043aa:	8d3a                	mv	s10,a4
    800043ac:	b749                	j	8000432e <writei+0x4c>
      brelse(bp);
    800043ae:	8526                	mv	a0,s1
    800043b0:	fffff097          	auipc	ra,0xfffff
    800043b4:	49c080e7          	jalr	1180(ra) # 8000384c <brelse>
  }

  if(off > ip->size)
    800043b8:	04caa783          	lw	a5,76(s5)
    800043bc:	0127f463          	bgeu	a5,s2,800043c4 <writei+0xe2>
    ip->size = off;
    800043c0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800043c4:	8556                	mv	a0,s5
    800043c6:	00000097          	auipc	ra,0x0
    800043ca:	aa6080e7          	jalr	-1370(ra) # 80003e6c <iupdate>

  return tot;
    800043ce:	0009851b          	sext.w	a0,s3
}
    800043d2:	70a6                	ld	ra,104(sp)
    800043d4:	7406                	ld	s0,96(sp)
    800043d6:	64e6                	ld	s1,88(sp)
    800043d8:	6946                	ld	s2,80(sp)
    800043da:	69a6                	ld	s3,72(sp)
    800043dc:	6a06                	ld	s4,64(sp)
    800043de:	7ae2                	ld	s5,56(sp)
    800043e0:	7b42                	ld	s6,48(sp)
    800043e2:	7ba2                	ld	s7,40(sp)
    800043e4:	7c02                	ld	s8,32(sp)
    800043e6:	6ce2                	ld	s9,24(sp)
    800043e8:	6d42                	ld	s10,16(sp)
    800043ea:	6da2                	ld	s11,8(sp)
    800043ec:	6165                	addi	sp,sp,112
    800043ee:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043f0:	89da                	mv	s3,s6
    800043f2:	bfc9                	j	800043c4 <writei+0xe2>
    return -1;
    800043f4:	557d                	li	a0,-1
}
    800043f6:	8082                	ret
    return -1;
    800043f8:	557d                	li	a0,-1
    800043fa:	bfe1                	j	800043d2 <writei+0xf0>
    return -1;
    800043fc:	557d                	li	a0,-1
    800043fe:	bfd1                	j	800043d2 <writei+0xf0>

0000000080004400 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004400:	1141                	addi	sp,sp,-16
    80004402:	e406                	sd	ra,8(sp)
    80004404:	e022                	sd	s0,0(sp)
    80004406:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004408:	4639                	li	a2,14
    8000440a:	ffffd097          	auipc	ra,0xffffd
    8000440e:	998080e7          	jalr	-1640(ra) # 80000da2 <strncmp>
}
    80004412:	60a2                	ld	ra,8(sp)
    80004414:	6402                	ld	s0,0(sp)
    80004416:	0141                	addi	sp,sp,16
    80004418:	8082                	ret

000000008000441a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000441a:	7139                	addi	sp,sp,-64
    8000441c:	fc06                	sd	ra,56(sp)
    8000441e:	f822                	sd	s0,48(sp)
    80004420:	f426                	sd	s1,40(sp)
    80004422:	f04a                	sd	s2,32(sp)
    80004424:	ec4e                	sd	s3,24(sp)
    80004426:	e852                	sd	s4,16(sp)
    80004428:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000442a:	04451703          	lh	a4,68(a0)
    8000442e:	4785                	li	a5,1
    80004430:	00f71a63          	bne	a4,a5,80004444 <dirlookup+0x2a>
    80004434:	892a                	mv	s2,a0
    80004436:	89ae                	mv	s3,a1
    80004438:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000443a:	457c                	lw	a5,76(a0)
    8000443c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000443e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004440:	e79d                	bnez	a5,8000446e <dirlookup+0x54>
    80004442:	a8a5                	j	800044ba <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004444:	00004517          	auipc	a0,0x4
    80004448:	1c450513          	addi	a0,a0,452 # 80008608 <syscalls+0x1c8>
    8000444c:	ffffc097          	auipc	ra,0xffffc
    80004450:	0f2080e7          	jalr	242(ra) # 8000053e <panic>
      panic("dirlookup read");
    80004454:	00004517          	auipc	a0,0x4
    80004458:	1cc50513          	addi	a0,a0,460 # 80008620 <syscalls+0x1e0>
    8000445c:	ffffc097          	auipc	ra,0xffffc
    80004460:	0e2080e7          	jalr	226(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004464:	24c1                	addiw	s1,s1,16
    80004466:	04c92783          	lw	a5,76(s2)
    8000446a:	04f4f763          	bgeu	s1,a5,800044b8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000446e:	4741                	li	a4,16
    80004470:	86a6                	mv	a3,s1
    80004472:	fc040613          	addi	a2,s0,-64
    80004476:	4581                	li	a1,0
    80004478:	854a                	mv	a0,s2
    8000447a:	00000097          	auipc	ra,0x0
    8000447e:	d70080e7          	jalr	-656(ra) # 800041ea <readi>
    80004482:	47c1                	li	a5,16
    80004484:	fcf518e3          	bne	a0,a5,80004454 <dirlookup+0x3a>
    if(de.inum == 0)
    80004488:	fc045783          	lhu	a5,-64(s0)
    8000448c:	dfe1                	beqz	a5,80004464 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000448e:	fc240593          	addi	a1,s0,-62
    80004492:	854e                	mv	a0,s3
    80004494:	00000097          	auipc	ra,0x0
    80004498:	f6c080e7          	jalr	-148(ra) # 80004400 <namecmp>
    8000449c:	f561                	bnez	a0,80004464 <dirlookup+0x4a>
      if(poff)
    8000449e:	000a0463          	beqz	s4,800044a6 <dirlookup+0x8c>
        *poff = off;
    800044a2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800044a6:	fc045583          	lhu	a1,-64(s0)
    800044aa:	00092503          	lw	a0,0(s2)
    800044ae:	fffff097          	auipc	ra,0xfffff
    800044b2:	750080e7          	jalr	1872(ra) # 80003bfe <iget>
    800044b6:	a011                	j	800044ba <dirlookup+0xa0>
  return 0;
    800044b8:	4501                	li	a0,0
}
    800044ba:	70e2                	ld	ra,56(sp)
    800044bc:	7442                	ld	s0,48(sp)
    800044be:	74a2                	ld	s1,40(sp)
    800044c0:	7902                	ld	s2,32(sp)
    800044c2:	69e2                	ld	s3,24(sp)
    800044c4:	6a42                	ld	s4,16(sp)
    800044c6:	6121                	addi	sp,sp,64
    800044c8:	8082                	ret

00000000800044ca <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800044ca:	711d                	addi	sp,sp,-96
    800044cc:	ec86                	sd	ra,88(sp)
    800044ce:	e8a2                	sd	s0,80(sp)
    800044d0:	e4a6                	sd	s1,72(sp)
    800044d2:	e0ca                	sd	s2,64(sp)
    800044d4:	fc4e                	sd	s3,56(sp)
    800044d6:	f852                	sd	s4,48(sp)
    800044d8:	f456                	sd	s5,40(sp)
    800044da:	f05a                	sd	s6,32(sp)
    800044dc:	ec5e                	sd	s7,24(sp)
    800044de:	e862                	sd	s8,16(sp)
    800044e0:	e466                	sd	s9,8(sp)
    800044e2:	1080                	addi	s0,sp,96
    800044e4:	84aa                	mv	s1,a0
    800044e6:	8aae                	mv	s5,a1
    800044e8:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800044ea:	00054703          	lbu	a4,0(a0)
    800044ee:	02f00793          	li	a5,47
    800044f2:	02f70563          	beq	a4,a5,8000451c <namex+0x52>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800044f6:	ffffd097          	auipc	ra,0xffffd
    800044fa:	4e2080e7          	jalr	1250(ra) # 800019d8 <myproc>
    800044fe:	6785                	lui	a5,0x1
    80004500:	97aa                	add	a5,a5,a0
    80004502:	8487b503          	ld	a0,-1976(a5) # 848 <_entry-0x7ffff7b8>
    80004506:	00000097          	auipc	ra,0x0
    8000450a:	9f2080e7          	jalr	-1550(ra) # 80003ef8 <idup>
    8000450e:	89aa                	mv	s3,a0
  while(*path == '/')
    80004510:	02f00913          	li	s2,47
  len = path - s;
    80004514:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004516:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004518:	4b85                	li	s7,1
    8000451a:	a865                	j	800045d2 <namex+0x108>
    ip = iget(ROOTDEV, ROOTINO);
    8000451c:	4585                	li	a1,1
    8000451e:	4505                	li	a0,1
    80004520:	fffff097          	auipc	ra,0xfffff
    80004524:	6de080e7          	jalr	1758(ra) # 80003bfe <iget>
    80004528:	89aa                	mv	s3,a0
    8000452a:	b7dd                	j	80004510 <namex+0x46>
      iunlockput(ip);
    8000452c:	854e                	mv	a0,s3
    8000452e:	00000097          	auipc	ra,0x0
    80004532:	c6a080e7          	jalr	-918(ra) # 80004198 <iunlockput>
      return 0;
    80004536:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004538:	854e                	mv	a0,s3
    8000453a:	60e6                	ld	ra,88(sp)
    8000453c:	6446                	ld	s0,80(sp)
    8000453e:	64a6                	ld	s1,72(sp)
    80004540:	6906                	ld	s2,64(sp)
    80004542:	79e2                	ld	s3,56(sp)
    80004544:	7a42                	ld	s4,48(sp)
    80004546:	7aa2                	ld	s5,40(sp)
    80004548:	7b02                	ld	s6,32(sp)
    8000454a:	6be2                	ld	s7,24(sp)
    8000454c:	6c42                	ld	s8,16(sp)
    8000454e:	6ca2                	ld	s9,8(sp)
    80004550:	6125                	addi	sp,sp,96
    80004552:	8082                	ret
      iunlock(ip);
    80004554:	854e                	mv	a0,s3
    80004556:	00000097          	auipc	ra,0x0
    8000455a:	aa2080e7          	jalr	-1374(ra) # 80003ff8 <iunlock>
      return ip;
    8000455e:	bfe9                	j	80004538 <namex+0x6e>
      iunlockput(ip);
    80004560:	854e                	mv	a0,s3
    80004562:	00000097          	auipc	ra,0x0
    80004566:	c36080e7          	jalr	-970(ra) # 80004198 <iunlockput>
      return 0;
    8000456a:	89e6                	mv	s3,s9
    8000456c:	b7f1                	j	80004538 <namex+0x6e>
  len = path - s;
    8000456e:	40b48633          	sub	a2,s1,a1
    80004572:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004576:	099c5463          	bge	s8,s9,800045fe <namex+0x134>
    memmove(name, s, DIRSIZ);
    8000457a:	4639                	li	a2,14
    8000457c:	8552                	mv	a0,s4
    8000457e:	ffffc097          	auipc	ra,0xffffc
    80004582:	7b0080e7          	jalr	1968(ra) # 80000d2e <memmove>
  while(*path == '/')
    80004586:	0004c783          	lbu	a5,0(s1)
    8000458a:	01279763          	bne	a5,s2,80004598 <namex+0xce>
    path++;
    8000458e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004590:	0004c783          	lbu	a5,0(s1)
    80004594:	ff278de3          	beq	a5,s2,8000458e <namex+0xc4>
    ilock(ip);
    80004598:	854e                	mv	a0,s3
    8000459a:	00000097          	auipc	ra,0x0
    8000459e:	99c080e7          	jalr	-1636(ra) # 80003f36 <ilock>
    if(ip->type != T_DIR){
    800045a2:	04499783          	lh	a5,68(s3)
    800045a6:	f97793e3          	bne	a5,s7,8000452c <namex+0x62>
    if(nameiparent && *path == '\0'){
    800045aa:	000a8563          	beqz	s5,800045b4 <namex+0xea>
    800045ae:	0004c783          	lbu	a5,0(s1)
    800045b2:	d3cd                	beqz	a5,80004554 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800045b4:	865a                	mv	a2,s6
    800045b6:	85d2                	mv	a1,s4
    800045b8:	854e                	mv	a0,s3
    800045ba:	00000097          	auipc	ra,0x0
    800045be:	e60080e7          	jalr	-416(ra) # 8000441a <dirlookup>
    800045c2:	8caa                	mv	s9,a0
    800045c4:	dd51                	beqz	a0,80004560 <namex+0x96>
    iunlockput(ip);
    800045c6:	854e                	mv	a0,s3
    800045c8:	00000097          	auipc	ra,0x0
    800045cc:	bd0080e7          	jalr	-1072(ra) # 80004198 <iunlockput>
    ip = next;
    800045d0:	89e6                	mv	s3,s9
  while(*path == '/')
    800045d2:	0004c783          	lbu	a5,0(s1)
    800045d6:	05279763          	bne	a5,s2,80004624 <namex+0x15a>
    path++;
    800045da:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045dc:	0004c783          	lbu	a5,0(s1)
    800045e0:	ff278de3          	beq	a5,s2,800045da <namex+0x110>
  if(*path == 0)
    800045e4:	c79d                	beqz	a5,80004612 <namex+0x148>
    path++;
    800045e6:	85a6                	mv	a1,s1
  len = path - s;
    800045e8:	8cda                	mv	s9,s6
    800045ea:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800045ec:	01278963          	beq	a5,s2,800045fe <namex+0x134>
    800045f0:	dfbd                	beqz	a5,8000456e <namex+0xa4>
    path++;
    800045f2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800045f4:	0004c783          	lbu	a5,0(s1)
    800045f8:	ff279ce3          	bne	a5,s2,800045f0 <namex+0x126>
    800045fc:	bf8d                	j	8000456e <namex+0xa4>
    memmove(name, s, len);
    800045fe:	2601                	sext.w	a2,a2
    80004600:	8552                	mv	a0,s4
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	72c080e7          	jalr	1836(ra) # 80000d2e <memmove>
    name[len] = 0;
    8000460a:	9cd2                	add	s9,s9,s4
    8000460c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004610:	bf9d                	j	80004586 <namex+0xbc>
  if(nameiparent){
    80004612:	f20a83e3          	beqz	s5,80004538 <namex+0x6e>
    iput(ip);
    80004616:	854e                	mv	a0,s3
    80004618:	00000097          	auipc	ra,0x0
    8000461c:	ad8080e7          	jalr	-1320(ra) # 800040f0 <iput>
    return 0;
    80004620:	4981                	li	s3,0
    80004622:	bf19                	j	80004538 <namex+0x6e>
  if(*path == 0)
    80004624:	d7fd                	beqz	a5,80004612 <namex+0x148>
  while(*path != '/' && *path != 0)
    80004626:	0004c783          	lbu	a5,0(s1)
    8000462a:	85a6                	mv	a1,s1
    8000462c:	b7d1                	j	800045f0 <namex+0x126>

000000008000462e <dirlink>:
{
    8000462e:	7139                	addi	sp,sp,-64
    80004630:	fc06                	sd	ra,56(sp)
    80004632:	f822                	sd	s0,48(sp)
    80004634:	f426                	sd	s1,40(sp)
    80004636:	f04a                	sd	s2,32(sp)
    80004638:	ec4e                	sd	s3,24(sp)
    8000463a:	e852                	sd	s4,16(sp)
    8000463c:	0080                	addi	s0,sp,64
    8000463e:	892a                	mv	s2,a0
    80004640:	8a2e                	mv	s4,a1
    80004642:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004644:	4601                	li	a2,0
    80004646:	00000097          	auipc	ra,0x0
    8000464a:	dd4080e7          	jalr	-556(ra) # 8000441a <dirlookup>
    8000464e:	e93d                	bnez	a0,800046c4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004650:	04c92483          	lw	s1,76(s2)
    80004654:	c49d                	beqz	s1,80004682 <dirlink+0x54>
    80004656:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004658:	4741                	li	a4,16
    8000465a:	86a6                	mv	a3,s1
    8000465c:	fc040613          	addi	a2,s0,-64
    80004660:	4581                	li	a1,0
    80004662:	854a                	mv	a0,s2
    80004664:	00000097          	auipc	ra,0x0
    80004668:	b86080e7          	jalr	-1146(ra) # 800041ea <readi>
    8000466c:	47c1                	li	a5,16
    8000466e:	06f51163          	bne	a0,a5,800046d0 <dirlink+0xa2>
    if(de.inum == 0)
    80004672:	fc045783          	lhu	a5,-64(s0)
    80004676:	c791                	beqz	a5,80004682 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004678:	24c1                	addiw	s1,s1,16
    8000467a:	04c92783          	lw	a5,76(s2)
    8000467e:	fcf4ede3          	bltu	s1,a5,80004658 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004682:	4639                	li	a2,14
    80004684:	85d2                	mv	a1,s4
    80004686:	fc240513          	addi	a0,s0,-62
    8000468a:	ffffc097          	auipc	ra,0xffffc
    8000468e:	754080e7          	jalr	1876(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004692:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004696:	4741                	li	a4,16
    80004698:	86a6                	mv	a3,s1
    8000469a:	fc040613          	addi	a2,s0,-64
    8000469e:	4581                	li	a1,0
    800046a0:	854a                	mv	a0,s2
    800046a2:	00000097          	auipc	ra,0x0
    800046a6:	c40080e7          	jalr	-960(ra) # 800042e2 <writei>
    800046aa:	1541                	addi	a0,a0,-16
    800046ac:	00a03533          	snez	a0,a0
    800046b0:	40a00533          	neg	a0,a0
}
    800046b4:	70e2                	ld	ra,56(sp)
    800046b6:	7442                	ld	s0,48(sp)
    800046b8:	74a2                	ld	s1,40(sp)
    800046ba:	7902                	ld	s2,32(sp)
    800046bc:	69e2                	ld	s3,24(sp)
    800046be:	6a42                	ld	s4,16(sp)
    800046c0:	6121                	addi	sp,sp,64
    800046c2:	8082                	ret
    iput(ip);
    800046c4:	00000097          	auipc	ra,0x0
    800046c8:	a2c080e7          	jalr	-1492(ra) # 800040f0 <iput>
    return -1;
    800046cc:	557d                	li	a0,-1
    800046ce:	b7dd                	j	800046b4 <dirlink+0x86>
      panic("dirlink read");
    800046d0:	00004517          	auipc	a0,0x4
    800046d4:	f6050513          	addi	a0,a0,-160 # 80008630 <syscalls+0x1f0>
    800046d8:	ffffc097          	auipc	ra,0xffffc
    800046dc:	e66080e7          	jalr	-410(ra) # 8000053e <panic>

00000000800046e0 <namei>:

struct inode*
namei(char *path)
{
    800046e0:	1101                	addi	sp,sp,-32
    800046e2:	ec06                	sd	ra,24(sp)
    800046e4:	e822                	sd	s0,16(sp)
    800046e6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800046e8:	fe040613          	addi	a2,s0,-32
    800046ec:	4581                	li	a1,0
    800046ee:	00000097          	auipc	ra,0x0
    800046f2:	ddc080e7          	jalr	-548(ra) # 800044ca <namex>
}
    800046f6:	60e2                	ld	ra,24(sp)
    800046f8:	6442                	ld	s0,16(sp)
    800046fa:	6105                	addi	sp,sp,32
    800046fc:	8082                	ret

00000000800046fe <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800046fe:	1141                	addi	sp,sp,-16
    80004700:	e406                	sd	ra,8(sp)
    80004702:	e022                	sd	s0,0(sp)
    80004704:	0800                	addi	s0,sp,16
    80004706:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004708:	4585                	li	a1,1
    8000470a:	00000097          	auipc	ra,0x0
    8000470e:	dc0080e7          	jalr	-576(ra) # 800044ca <namex>
}
    80004712:	60a2                	ld	ra,8(sp)
    80004714:	6402                	ld	s0,0(sp)
    80004716:	0141                	addi	sp,sp,16
    80004718:	8082                	ret

000000008000471a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000471a:	1101                	addi	sp,sp,-32
    8000471c:	ec06                	sd	ra,24(sp)
    8000471e:	e822                	sd	s0,16(sp)
    80004720:	e426                	sd	s1,8(sp)
    80004722:	e04a                	sd	s2,0(sp)
    80004724:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004726:	00039917          	auipc	s2,0x39
    8000472a:	a1a90913          	addi	s2,s2,-1510 # 8003d140 <log>
    8000472e:	01892583          	lw	a1,24(s2)
    80004732:	02892503          	lw	a0,40(s2)
    80004736:	fffff097          	auipc	ra,0xfffff
    8000473a:	fe6080e7          	jalr	-26(ra) # 8000371c <bread>
    8000473e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004740:	02c92683          	lw	a3,44(s2)
    80004744:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004746:	02d05763          	blez	a3,80004774 <write_head+0x5a>
    8000474a:	00039797          	auipc	a5,0x39
    8000474e:	a2678793          	addi	a5,a5,-1498 # 8003d170 <log+0x30>
    80004752:	05c50713          	addi	a4,a0,92
    80004756:	36fd                	addiw	a3,a3,-1
    80004758:	1682                	slli	a3,a3,0x20
    8000475a:	9281                	srli	a3,a3,0x20
    8000475c:	068a                	slli	a3,a3,0x2
    8000475e:	00039617          	auipc	a2,0x39
    80004762:	a1660613          	addi	a2,a2,-1514 # 8003d174 <log+0x34>
    80004766:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004768:	4390                	lw	a2,0(a5)
    8000476a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000476c:	0791                	addi	a5,a5,4
    8000476e:	0711                	addi	a4,a4,4
    80004770:	fed79ce3          	bne	a5,a3,80004768 <write_head+0x4e>
  }
  bwrite(buf);
    80004774:	8526                	mv	a0,s1
    80004776:	fffff097          	auipc	ra,0xfffff
    8000477a:	098080e7          	jalr	152(ra) # 8000380e <bwrite>
  brelse(buf);
    8000477e:	8526                	mv	a0,s1
    80004780:	fffff097          	auipc	ra,0xfffff
    80004784:	0cc080e7          	jalr	204(ra) # 8000384c <brelse>
}
    80004788:	60e2                	ld	ra,24(sp)
    8000478a:	6442                	ld	s0,16(sp)
    8000478c:	64a2                	ld	s1,8(sp)
    8000478e:	6902                	ld	s2,0(sp)
    80004790:	6105                	addi	sp,sp,32
    80004792:	8082                	ret

0000000080004794 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004794:	00039797          	auipc	a5,0x39
    80004798:	9d87a783          	lw	a5,-1576(a5) # 8003d16c <log+0x2c>
    8000479c:	0af05d63          	blez	a5,80004856 <install_trans+0xc2>
{
    800047a0:	7139                	addi	sp,sp,-64
    800047a2:	fc06                	sd	ra,56(sp)
    800047a4:	f822                	sd	s0,48(sp)
    800047a6:	f426                	sd	s1,40(sp)
    800047a8:	f04a                	sd	s2,32(sp)
    800047aa:	ec4e                	sd	s3,24(sp)
    800047ac:	e852                	sd	s4,16(sp)
    800047ae:	e456                	sd	s5,8(sp)
    800047b0:	e05a                	sd	s6,0(sp)
    800047b2:	0080                	addi	s0,sp,64
    800047b4:	8b2a                	mv	s6,a0
    800047b6:	00039a97          	auipc	s5,0x39
    800047ba:	9baa8a93          	addi	s5,s5,-1606 # 8003d170 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047be:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047c0:	00039997          	auipc	s3,0x39
    800047c4:	98098993          	addi	s3,s3,-1664 # 8003d140 <log>
    800047c8:	a00d                	j	800047ea <install_trans+0x56>
    brelse(lbuf);
    800047ca:	854a                	mv	a0,s2
    800047cc:	fffff097          	auipc	ra,0xfffff
    800047d0:	080080e7          	jalr	128(ra) # 8000384c <brelse>
    brelse(dbuf);
    800047d4:	8526                	mv	a0,s1
    800047d6:	fffff097          	auipc	ra,0xfffff
    800047da:	076080e7          	jalr	118(ra) # 8000384c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047de:	2a05                	addiw	s4,s4,1
    800047e0:	0a91                	addi	s5,s5,4
    800047e2:	02c9a783          	lw	a5,44(s3)
    800047e6:	04fa5e63          	bge	s4,a5,80004842 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047ea:	0189a583          	lw	a1,24(s3)
    800047ee:	014585bb          	addw	a1,a1,s4
    800047f2:	2585                	addiw	a1,a1,1
    800047f4:	0289a503          	lw	a0,40(s3)
    800047f8:	fffff097          	auipc	ra,0xfffff
    800047fc:	f24080e7          	jalr	-220(ra) # 8000371c <bread>
    80004800:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004802:	000aa583          	lw	a1,0(s5)
    80004806:	0289a503          	lw	a0,40(s3)
    8000480a:	fffff097          	auipc	ra,0xfffff
    8000480e:	f12080e7          	jalr	-238(ra) # 8000371c <bread>
    80004812:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004814:	40000613          	li	a2,1024
    80004818:	05890593          	addi	a1,s2,88
    8000481c:	05850513          	addi	a0,a0,88
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	50e080e7          	jalr	1294(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004828:	8526                	mv	a0,s1
    8000482a:	fffff097          	auipc	ra,0xfffff
    8000482e:	fe4080e7          	jalr	-28(ra) # 8000380e <bwrite>
    if(recovering == 0)
    80004832:	f80b1ce3          	bnez	s6,800047ca <install_trans+0x36>
      bunpin(dbuf);
    80004836:	8526                	mv	a0,s1
    80004838:	fffff097          	auipc	ra,0xfffff
    8000483c:	0ee080e7          	jalr	238(ra) # 80003926 <bunpin>
    80004840:	b769                	j	800047ca <install_trans+0x36>
}
    80004842:	70e2                	ld	ra,56(sp)
    80004844:	7442                	ld	s0,48(sp)
    80004846:	74a2                	ld	s1,40(sp)
    80004848:	7902                	ld	s2,32(sp)
    8000484a:	69e2                	ld	s3,24(sp)
    8000484c:	6a42                	ld	s4,16(sp)
    8000484e:	6aa2                	ld	s5,8(sp)
    80004850:	6b02                	ld	s6,0(sp)
    80004852:	6121                	addi	sp,sp,64
    80004854:	8082                	ret
    80004856:	8082                	ret

0000000080004858 <initlog>:
{
    80004858:	7179                	addi	sp,sp,-48
    8000485a:	f406                	sd	ra,40(sp)
    8000485c:	f022                	sd	s0,32(sp)
    8000485e:	ec26                	sd	s1,24(sp)
    80004860:	e84a                	sd	s2,16(sp)
    80004862:	e44e                	sd	s3,8(sp)
    80004864:	1800                	addi	s0,sp,48
    80004866:	892a                	mv	s2,a0
    80004868:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000486a:	00039497          	auipc	s1,0x39
    8000486e:	8d648493          	addi	s1,s1,-1834 # 8003d140 <log>
    80004872:	00004597          	auipc	a1,0x4
    80004876:	dce58593          	addi	a1,a1,-562 # 80008640 <syscalls+0x200>
    8000487a:	8526                	mv	a0,s1
    8000487c:	ffffc097          	auipc	ra,0xffffc
    80004880:	2ca080e7          	jalr	714(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004884:	0149a583          	lw	a1,20(s3)
    80004888:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000488a:	0109a783          	lw	a5,16(s3)
    8000488e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004890:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004894:	854a                	mv	a0,s2
    80004896:	fffff097          	auipc	ra,0xfffff
    8000489a:	e86080e7          	jalr	-378(ra) # 8000371c <bread>
  log.lh.n = lh->n;
    8000489e:	4d34                	lw	a3,88(a0)
    800048a0:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800048a2:	02d05563          	blez	a3,800048cc <initlog+0x74>
    800048a6:	05c50793          	addi	a5,a0,92
    800048aa:	00039717          	auipc	a4,0x39
    800048ae:	8c670713          	addi	a4,a4,-1850 # 8003d170 <log+0x30>
    800048b2:	36fd                	addiw	a3,a3,-1
    800048b4:	1682                	slli	a3,a3,0x20
    800048b6:	9281                	srli	a3,a3,0x20
    800048b8:	068a                	slli	a3,a3,0x2
    800048ba:	06050613          	addi	a2,a0,96
    800048be:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800048c0:	4390                	lw	a2,0(a5)
    800048c2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800048c4:	0791                	addi	a5,a5,4
    800048c6:	0711                	addi	a4,a4,4
    800048c8:	fed79ce3          	bne	a5,a3,800048c0 <initlog+0x68>
  brelse(buf);
    800048cc:	fffff097          	auipc	ra,0xfffff
    800048d0:	f80080e7          	jalr	-128(ra) # 8000384c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800048d4:	4505                	li	a0,1
    800048d6:	00000097          	auipc	ra,0x0
    800048da:	ebe080e7          	jalr	-322(ra) # 80004794 <install_trans>
  log.lh.n = 0;
    800048de:	00039797          	auipc	a5,0x39
    800048e2:	8807a723          	sw	zero,-1906(a5) # 8003d16c <log+0x2c>
  write_head(); // clear the log
    800048e6:	00000097          	auipc	ra,0x0
    800048ea:	e34080e7          	jalr	-460(ra) # 8000471a <write_head>
}
    800048ee:	70a2                	ld	ra,40(sp)
    800048f0:	7402                	ld	s0,32(sp)
    800048f2:	64e2                	ld	s1,24(sp)
    800048f4:	6942                	ld	s2,16(sp)
    800048f6:	69a2                	ld	s3,8(sp)
    800048f8:	6145                	addi	sp,sp,48
    800048fa:	8082                	ret

00000000800048fc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800048fc:	1101                	addi	sp,sp,-32
    800048fe:	ec06                	sd	ra,24(sp)
    80004900:	e822                	sd	s0,16(sp)
    80004902:	e426                	sd	s1,8(sp)
    80004904:	e04a                	sd	s2,0(sp)
    80004906:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004908:	00039517          	auipc	a0,0x39
    8000490c:	83850513          	addi	a0,a0,-1992 # 8003d140 <log>
    80004910:	ffffc097          	auipc	ra,0xffffc
    80004914:	2c6080e7          	jalr	710(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004918:	00039497          	auipc	s1,0x39
    8000491c:	82848493          	addi	s1,s1,-2008 # 8003d140 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004920:	4979                	li	s2,30
    80004922:	a039                	j	80004930 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004924:	85a6                	mv	a1,s1
    80004926:	8526                	mv	a0,s1
    80004928:	ffffe097          	auipc	ra,0xffffe
    8000492c:	844080e7          	jalr	-1980(ra) # 8000216c <sleep>
    if(log.committing){
    80004930:	50dc                	lw	a5,36(s1)
    80004932:	fbed                	bnez	a5,80004924 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004934:	509c                	lw	a5,32(s1)
    80004936:	0017871b          	addiw	a4,a5,1
    8000493a:	0007069b          	sext.w	a3,a4
    8000493e:	0027179b          	slliw	a5,a4,0x2
    80004942:	9fb9                	addw	a5,a5,a4
    80004944:	0017979b          	slliw	a5,a5,0x1
    80004948:	54d8                	lw	a4,44(s1)
    8000494a:	9fb9                	addw	a5,a5,a4
    8000494c:	00f95963          	bge	s2,a5,8000495e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004950:	85a6                	mv	a1,s1
    80004952:	8526                	mv	a0,s1
    80004954:	ffffe097          	auipc	ra,0xffffe
    80004958:	818080e7          	jalr	-2024(ra) # 8000216c <sleep>
    8000495c:	bfd1                	j	80004930 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000495e:	00038517          	auipc	a0,0x38
    80004962:	7e250513          	addi	a0,a0,2018 # 8003d140 <log>
    80004966:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004968:	ffffc097          	auipc	ra,0xffffc
    8000496c:	322080e7          	jalr	802(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004970:	60e2                	ld	ra,24(sp)
    80004972:	6442                	ld	s0,16(sp)
    80004974:	64a2                	ld	s1,8(sp)
    80004976:	6902                	ld	s2,0(sp)
    80004978:	6105                	addi	sp,sp,32
    8000497a:	8082                	ret

000000008000497c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000497c:	7139                	addi	sp,sp,-64
    8000497e:	fc06                	sd	ra,56(sp)
    80004980:	f822                	sd	s0,48(sp)
    80004982:	f426                	sd	s1,40(sp)
    80004984:	f04a                	sd	s2,32(sp)
    80004986:	ec4e                	sd	s3,24(sp)
    80004988:	e852                	sd	s4,16(sp)
    8000498a:	e456                	sd	s5,8(sp)
    8000498c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000498e:	00038497          	auipc	s1,0x38
    80004992:	7b248493          	addi	s1,s1,1970 # 8003d140 <log>
    80004996:	8526                	mv	a0,s1
    80004998:	ffffc097          	auipc	ra,0xffffc
    8000499c:	23e080e7          	jalr	574(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800049a0:	509c                	lw	a5,32(s1)
    800049a2:	37fd                	addiw	a5,a5,-1
    800049a4:	0007891b          	sext.w	s2,a5
    800049a8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800049aa:	50dc                	lw	a5,36(s1)
    800049ac:	e7b9                	bnez	a5,800049fa <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800049ae:	04091e63          	bnez	s2,80004a0a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800049b2:	00038497          	auipc	s1,0x38
    800049b6:	78e48493          	addi	s1,s1,1934 # 8003d140 <log>
    800049ba:	4785                	li	a5,1
    800049bc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800049be:	8526                	mv	a0,s1
    800049c0:	ffffc097          	auipc	ra,0xffffc
    800049c4:	2ca080e7          	jalr	714(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800049c8:	54dc                	lw	a5,44(s1)
    800049ca:	06f04763          	bgtz	a5,80004a38 <end_op+0xbc>
    acquire(&log.lock);
    800049ce:	00038497          	auipc	s1,0x38
    800049d2:	77248493          	addi	s1,s1,1906 # 8003d140 <log>
    800049d6:	8526                	mv	a0,s1
    800049d8:	ffffc097          	auipc	ra,0xffffc
    800049dc:	1fe080e7          	jalr	510(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800049e0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800049e4:	8526                	mv	a0,s1
    800049e6:	ffffd097          	auipc	ra,0xffffd
    800049ea:	7ea080e7          	jalr	2026(ra) # 800021d0 <wakeup>
    release(&log.lock);
    800049ee:	8526                	mv	a0,s1
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	29a080e7          	jalr	666(ra) # 80000c8a <release>
}
    800049f8:	a03d                	j	80004a26 <end_op+0xaa>
    panic("log.committing");
    800049fa:	00004517          	auipc	a0,0x4
    800049fe:	c4e50513          	addi	a0,a0,-946 # 80008648 <syscalls+0x208>
    80004a02:	ffffc097          	auipc	ra,0xffffc
    80004a06:	b3c080e7          	jalr	-1220(ra) # 8000053e <panic>
    wakeup(&log);
    80004a0a:	00038497          	auipc	s1,0x38
    80004a0e:	73648493          	addi	s1,s1,1846 # 8003d140 <log>
    80004a12:	8526                	mv	a0,s1
    80004a14:	ffffd097          	auipc	ra,0xffffd
    80004a18:	7bc080e7          	jalr	1980(ra) # 800021d0 <wakeup>
  release(&log.lock);
    80004a1c:	8526                	mv	a0,s1
    80004a1e:	ffffc097          	auipc	ra,0xffffc
    80004a22:	26c080e7          	jalr	620(ra) # 80000c8a <release>
}
    80004a26:	70e2                	ld	ra,56(sp)
    80004a28:	7442                	ld	s0,48(sp)
    80004a2a:	74a2                	ld	s1,40(sp)
    80004a2c:	7902                	ld	s2,32(sp)
    80004a2e:	69e2                	ld	s3,24(sp)
    80004a30:	6a42                	ld	s4,16(sp)
    80004a32:	6aa2                	ld	s5,8(sp)
    80004a34:	6121                	addi	sp,sp,64
    80004a36:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a38:	00038a97          	auipc	s5,0x38
    80004a3c:	738a8a93          	addi	s5,s5,1848 # 8003d170 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a40:	00038a17          	auipc	s4,0x38
    80004a44:	700a0a13          	addi	s4,s4,1792 # 8003d140 <log>
    80004a48:	018a2583          	lw	a1,24(s4)
    80004a4c:	012585bb          	addw	a1,a1,s2
    80004a50:	2585                	addiw	a1,a1,1
    80004a52:	028a2503          	lw	a0,40(s4)
    80004a56:	fffff097          	auipc	ra,0xfffff
    80004a5a:	cc6080e7          	jalr	-826(ra) # 8000371c <bread>
    80004a5e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004a60:	000aa583          	lw	a1,0(s5)
    80004a64:	028a2503          	lw	a0,40(s4)
    80004a68:	fffff097          	auipc	ra,0xfffff
    80004a6c:	cb4080e7          	jalr	-844(ra) # 8000371c <bread>
    80004a70:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004a72:	40000613          	li	a2,1024
    80004a76:	05850593          	addi	a1,a0,88
    80004a7a:	05848513          	addi	a0,s1,88
    80004a7e:	ffffc097          	auipc	ra,0xffffc
    80004a82:	2b0080e7          	jalr	688(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004a86:	8526                	mv	a0,s1
    80004a88:	fffff097          	auipc	ra,0xfffff
    80004a8c:	d86080e7          	jalr	-634(ra) # 8000380e <bwrite>
    brelse(from);
    80004a90:	854e                	mv	a0,s3
    80004a92:	fffff097          	auipc	ra,0xfffff
    80004a96:	dba080e7          	jalr	-582(ra) # 8000384c <brelse>
    brelse(to);
    80004a9a:	8526                	mv	a0,s1
    80004a9c:	fffff097          	auipc	ra,0xfffff
    80004aa0:	db0080e7          	jalr	-592(ra) # 8000384c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004aa4:	2905                	addiw	s2,s2,1
    80004aa6:	0a91                	addi	s5,s5,4
    80004aa8:	02ca2783          	lw	a5,44(s4)
    80004aac:	f8f94ee3          	blt	s2,a5,80004a48 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004ab0:	00000097          	auipc	ra,0x0
    80004ab4:	c6a080e7          	jalr	-918(ra) # 8000471a <write_head>
    install_trans(0); // Now install writes to home locations
    80004ab8:	4501                	li	a0,0
    80004aba:	00000097          	auipc	ra,0x0
    80004abe:	cda080e7          	jalr	-806(ra) # 80004794 <install_trans>
    log.lh.n = 0;
    80004ac2:	00038797          	auipc	a5,0x38
    80004ac6:	6a07a523          	sw	zero,1706(a5) # 8003d16c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004aca:	00000097          	auipc	ra,0x0
    80004ace:	c50080e7          	jalr	-944(ra) # 8000471a <write_head>
    80004ad2:	bdf5                	j	800049ce <end_op+0x52>

0000000080004ad4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004ad4:	1101                	addi	sp,sp,-32
    80004ad6:	ec06                	sd	ra,24(sp)
    80004ad8:	e822                	sd	s0,16(sp)
    80004ada:	e426                	sd	s1,8(sp)
    80004adc:	e04a                	sd	s2,0(sp)
    80004ade:	1000                	addi	s0,sp,32
    80004ae0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004ae2:	00038917          	auipc	s2,0x38
    80004ae6:	65e90913          	addi	s2,s2,1630 # 8003d140 <log>
    80004aea:	854a                	mv	a0,s2
    80004aec:	ffffc097          	auipc	ra,0xffffc
    80004af0:	0ea080e7          	jalr	234(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004af4:	02c92603          	lw	a2,44(s2)
    80004af8:	47f5                	li	a5,29
    80004afa:	06c7c563          	blt	a5,a2,80004b64 <log_write+0x90>
    80004afe:	00038797          	auipc	a5,0x38
    80004b02:	65e7a783          	lw	a5,1630(a5) # 8003d15c <log+0x1c>
    80004b06:	37fd                	addiw	a5,a5,-1
    80004b08:	04f65e63          	bge	a2,a5,80004b64 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004b0c:	00038797          	auipc	a5,0x38
    80004b10:	6547a783          	lw	a5,1620(a5) # 8003d160 <log+0x20>
    80004b14:	06f05063          	blez	a5,80004b74 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004b18:	4781                	li	a5,0
    80004b1a:	06c05563          	blez	a2,80004b84 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b1e:	44cc                	lw	a1,12(s1)
    80004b20:	00038717          	auipc	a4,0x38
    80004b24:	65070713          	addi	a4,a4,1616 # 8003d170 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004b28:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b2a:	4314                	lw	a3,0(a4)
    80004b2c:	04b68c63          	beq	a3,a1,80004b84 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004b30:	2785                	addiw	a5,a5,1
    80004b32:	0711                	addi	a4,a4,4
    80004b34:	fef61be3          	bne	a2,a5,80004b2a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004b38:	0621                	addi	a2,a2,8
    80004b3a:	060a                	slli	a2,a2,0x2
    80004b3c:	00038797          	auipc	a5,0x38
    80004b40:	60478793          	addi	a5,a5,1540 # 8003d140 <log>
    80004b44:	963e                	add	a2,a2,a5
    80004b46:	44dc                	lw	a5,12(s1)
    80004b48:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004b4a:	8526                	mv	a0,s1
    80004b4c:	fffff097          	auipc	ra,0xfffff
    80004b50:	d9e080e7          	jalr	-610(ra) # 800038ea <bpin>
    log.lh.n++;
    80004b54:	00038717          	auipc	a4,0x38
    80004b58:	5ec70713          	addi	a4,a4,1516 # 8003d140 <log>
    80004b5c:	575c                	lw	a5,44(a4)
    80004b5e:	2785                	addiw	a5,a5,1
    80004b60:	d75c                	sw	a5,44(a4)
    80004b62:	a835                	j	80004b9e <log_write+0xca>
    panic("too big a transaction");
    80004b64:	00004517          	auipc	a0,0x4
    80004b68:	af450513          	addi	a0,a0,-1292 # 80008658 <syscalls+0x218>
    80004b6c:	ffffc097          	auipc	ra,0xffffc
    80004b70:	9d2080e7          	jalr	-1582(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004b74:	00004517          	auipc	a0,0x4
    80004b78:	afc50513          	addi	a0,a0,-1284 # 80008670 <syscalls+0x230>
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	9c2080e7          	jalr	-1598(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004b84:	00878713          	addi	a4,a5,8
    80004b88:	00271693          	slli	a3,a4,0x2
    80004b8c:	00038717          	auipc	a4,0x38
    80004b90:	5b470713          	addi	a4,a4,1460 # 8003d140 <log>
    80004b94:	9736                	add	a4,a4,a3
    80004b96:	44d4                	lw	a3,12(s1)
    80004b98:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004b9a:	faf608e3          	beq	a2,a5,80004b4a <log_write+0x76>
  }
  release(&log.lock);
    80004b9e:	00038517          	auipc	a0,0x38
    80004ba2:	5a250513          	addi	a0,a0,1442 # 8003d140 <log>
    80004ba6:	ffffc097          	auipc	ra,0xffffc
    80004baa:	0e4080e7          	jalr	228(ra) # 80000c8a <release>
}
    80004bae:	60e2                	ld	ra,24(sp)
    80004bb0:	6442                	ld	s0,16(sp)
    80004bb2:	64a2                	ld	s1,8(sp)
    80004bb4:	6902                	ld	s2,0(sp)
    80004bb6:	6105                	addi	sp,sp,32
    80004bb8:	8082                	ret

0000000080004bba <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004bba:	1101                	addi	sp,sp,-32
    80004bbc:	ec06                	sd	ra,24(sp)
    80004bbe:	e822                	sd	s0,16(sp)
    80004bc0:	e426                	sd	s1,8(sp)
    80004bc2:	e04a                	sd	s2,0(sp)
    80004bc4:	1000                	addi	s0,sp,32
    80004bc6:	84aa                	mv	s1,a0
    80004bc8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004bca:	00004597          	auipc	a1,0x4
    80004bce:	ac658593          	addi	a1,a1,-1338 # 80008690 <syscalls+0x250>
    80004bd2:	0521                	addi	a0,a0,8
    80004bd4:	ffffc097          	auipc	ra,0xffffc
    80004bd8:	f72080e7          	jalr	-142(ra) # 80000b46 <initlock>
  lk->name = name;
    80004bdc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004be0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004be4:	0204a423          	sw	zero,40(s1)
}
    80004be8:	60e2                	ld	ra,24(sp)
    80004bea:	6442                	ld	s0,16(sp)
    80004bec:	64a2                	ld	s1,8(sp)
    80004bee:	6902                	ld	s2,0(sp)
    80004bf0:	6105                	addi	sp,sp,32
    80004bf2:	8082                	ret

0000000080004bf4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004bf4:	1101                	addi	sp,sp,-32
    80004bf6:	ec06                	sd	ra,24(sp)
    80004bf8:	e822                	sd	s0,16(sp)
    80004bfa:	e426                	sd	s1,8(sp)
    80004bfc:	e04a                	sd	s2,0(sp)
    80004bfe:	1000                	addi	s0,sp,32
    80004c00:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c02:	00850913          	addi	s2,a0,8
    80004c06:	854a                	mv	a0,s2
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	fce080e7          	jalr	-50(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004c10:	409c                	lw	a5,0(s1)
    80004c12:	cb89                	beqz	a5,80004c24 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004c14:	85ca                	mv	a1,s2
    80004c16:	8526                	mv	a0,s1
    80004c18:	ffffd097          	auipc	ra,0xffffd
    80004c1c:	554080e7          	jalr	1364(ra) # 8000216c <sleep>
  while (lk->locked) {
    80004c20:	409c                	lw	a5,0(s1)
    80004c22:	fbed                	bnez	a5,80004c14 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c24:	4785                	li	a5,1
    80004c26:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c28:	ffffd097          	auipc	ra,0xffffd
    80004c2c:	db0080e7          	jalr	-592(ra) # 800019d8 <myproc>
    80004c30:	515c                	lw	a5,36(a0)
    80004c32:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004c34:	854a                	mv	a0,s2
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	054080e7          	jalr	84(ra) # 80000c8a <release>
}
    80004c3e:	60e2                	ld	ra,24(sp)
    80004c40:	6442                	ld	s0,16(sp)
    80004c42:	64a2                	ld	s1,8(sp)
    80004c44:	6902                	ld	s2,0(sp)
    80004c46:	6105                	addi	sp,sp,32
    80004c48:	8082                	ret

0000000080004c4a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c4a:	1101                	addi	sp,sp,-32
    80004c4c:	ec06                	sd	ra,24(sp)
    80004c4e:	e822                	sd	s0,16(sp)
    80004c50:	e426                	sd	s1,8(sp)
    80004c52:	e04a                	sd	s2,0(sp)
    80004c54:	1000                	addi	s0,sp,32
    80004c56:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c58:	00850913          	addi	s2,a0,8
    80004c5c:	854a                	mv	a0,s2
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	f78080e7          	jalr	-136(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004c66:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c6a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004c6e:	8526                	mv	a0,s1
    80004c70:	ffffd097          	auipc	ra,0xffffd
    80004c74:	560080e7          	jalr	1376(ra) # 800021d0 <wakeup>
  release(&lk->lk);
    80004c78:	854a                	mv	a0,s2
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	010080e7          	jalr	16(ra) # 80000c8a <release>
}
    80004c82:	60e2                	ld	ra,24(sp)
    80004c84:	6442                	ld	s0,16(sp)
    80004c86:	64a2                	ld	s1,8(sp)
    80004c88:	6902                	ld	s2,0(sp)
    80004c8a:	6105                	addi	sp,sp,32
    80004c8c:	8082                	ret

0000000080004c8e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004c8e:	7179                	addi	sp,sp,-48
    80004c90:	f406                	sd	ra,40(sp)
    80004c92:	f022                	sd	s0,32(sp)
    80004c94:	ec26                	sd	s1,24(sp)
    80004c96:	e84a                	sd	s2,16(sp)
    80004c98:	e44e                	sd	s3,8(sp)
    80004c9a:	1800                	addi	s0,sp,48
    80004c9c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c9e:	00850913          	addi	s2,a0,8
    80004ca2:	854a                	mv	a0,s2
    80004ca4:	ffffc097          	auipc	ra,0xffffc
    80004ca8:	f32080e7          	jalr	-206(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cac:	409c                	lw	a5,0(s1)
    80004cae:	ef99                	bnez	a5,80004ccc <holdingsleep+0x3e>
    80004cb0:	4481                	li	s1,0
  release(&lk->lk);
    80004cb2:	854a                	mv	a0,s2
    80004cb4:	ffffc097          	auipc	ra,0xffffc
    80004cb8:	fd6080e7          	jalr	-42(ra) # 80000c8a <release>
  return r;
}
    80004cbc:	8526                	mv	a0,s1
    80004cbe:	70a2                	ld	ra,40(sp)
    80004cc0:	7402                	ld	s0,32(sp)
    80004cc2:	64e2                	ld	s1,24(sp)
    80004cc4:	6942                	ld	s2,16(sp)
    80004cc6:	69a2                	ld	s3,8(sp)
    80004cc8:	6145                	addi	sp,sp,48
    80004cca:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ccc:	0284a983          	lw	s3,40(s1)
    80004cd0:	ffffd097          	auipc	ra,0xffffd
    80004cd4:	d08080e7          	jalr	-760(ra) # 800019d8 <myproc>
    80004cd8:	5144                	lw	s1,36(a0)
    80004cda:	413484b3          	sub	s1,s1,s3
    80004cde:	0014b493          	seqz	s1,s1
    80004ce2:	bfc1                	j	80004cb2 <holdingsleep+0x24>

0000000080004ce4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004ce4:	1141                	addi	sp,sp,-16
    80004ce6:	e406                	sd	ra,8(sp)
    80004ce8:	e022                	sd	s0,0(sp)
    80004cea:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004cec:	00004597          	auipc	a1,0x4
    80004cf0:	9b458593          	addi	a1,a1,-1612 # 800086a0 <syscalls+0x260>
    80004cf4:	00038517          	auipc	a0,0x38
    80004cf8:	59450513          	addi	a0,a0,1428 # 8003d288 <ftable>
    80004cfc:	ffffc097          	auipc	ra,0xffffc
    80004d00:	e4a080e7          	jalr	-438(ra) # 80000b46 <initlock>
}
    80004d04:	60a2                	ld	ra,8(sp)
    80004d06:	6402                	ld	s0,0(sp)
    80004d08:	0141                	addi	sp,sp,16
    80004d0a:	8082                	ret

0000000080004d0c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004d0c:	1101                	addi	sp,sp,-32
    80004d0e:	ec06                	sd	ra,24(sp)
    80004d10:	e822                	sd	s0,16(sp)
    80004d12:	e426                	sd	s1,8(sp)
    80004d14:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004d16:	00038517          	auipc	a0,0x38
    80004d1a:	57250513          	addi	a0,a0,1394 # 8003d288 <ftable>
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	eb8080e7          	jalr	-328(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d26:	00038497          	auipc	s1,0x38
    80004d2a:	57a48493          	addi	s1,s1,1402 # 8003d2a0 <ftable+0x18>
    80004d2e:	00039717          	auipc	a4,0x39
    80004d32:	51270713          	addi	a4,a4,1298 # 8003e240 <disk>
    if(f->ref == 0){
    80004d36:	40dc                	lw	a5,4(s1)
    80004d38:	cf99                	beqz	a5,80004d56 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d3a:	02848493          	addi	s1,s1,40
    80004d3e:	fee49ce3          	bne	s1,a4,80004d36 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004d42:	00038517          	auipc	a0,0x38
    80004d46:	54650513          	addi	a0,a0,1350 # 8003d288 <ftable>
    80004d4a:	ffffc097          	auipc	ra,0xffffc
    80004d4e:	f40080e7          	jalr	-192(ra) # 80000c8a <release>
  return 0;
    80004d52:	4481                	li	s1,0
    80004d54:	a819                	j	80004d6a <filealloc+0x5e>
      f->ref = 1;
    80004d56:	4785                	li	a5,1
    80004d58:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004d5a:	00038517          	auipc	a0,0x38
    80004d5e:	52e50513          	addi	a0,a0,1326 # 8003d288 <ftable>
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	f28080e7          	jalr	-216(ra) # 80000c8a <release>
}
    80004d6a:	8526                	mv	a0,s1
    80004d6c:	60e2                	ld	ra,24(sp)
    80004d6e:	6442                	ld	s0,16(sp)
    80004d70:	64a2                	ld	s1,8(sp)
    80004d72:	6105                	addi	sp,sp,32
    80004d74:	8082                	ret

0000000080004d76 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004d76:	1101                	addi	sp,sp,-32
    80004d78:	ec06                	sd	ra,24(sp)
    80004d7a:	e822                	sd	s0,16(sp)
    80004d7c:	e426                	sd	s1,8(sp)
    80004d7e:	1000                	addi	s0,sp,32
    80004d80:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004d82:	00038517          	auipc	a0,0x38
    80004d86:	50650513          	addi	a0,a0,1286 # 8003d288 <ftable>
    80004d8a:	ffffc097          	auipc	ra,0xffffc
    80004d8e:	e4c080e7          	jalr	-436(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004d92:	40dc                	lw	a5,4(s1)
    80004d94:	02f05263          	blez	a5,80004db8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004d98:	2785                	addiw	a5,a5,1
    80004d9a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d9c:	00038517          	auipc	a0,0x38
    80004da0:	4ec50513          	addi	a0,a0,1260 # 8003d288 <ftable>
    80004da4:	ffffc097          	auipc	ra,0xffffc
    80004da8:	ee6080e7          	jalr	-282(ra) # 80000c8a <release>
  return f;
}
    80004dac:	8526                	mv	a0,s1
    80004dae:	60e2                	ld	ra,24(sp)
    80004db0:	6442                	ld	s0,16(sp)
    80004db2:	64a2                	ld	s1,8(sp)
    80004db4:	6105                	addi	sp,sp,32
    80004db6:	8082                	ret
    panic("filedup");
    80004db8:	00004517          	auipc	a0,0x4
    80004dbc:	8f050513          	addi	a0,a0,-1808 # 800086a8 <syscalls+0x268>
    80004dc0:	ffffb097          	auipc	ra,0xffffb
    80004dc4:	77e080e7          	jalr	1918(ra) # 8000053e <panic>

0000000080004dc8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004dc8:	7139                	addi	sp,sp,-64
    80004dca:	fc06                	sd	ra,56(sp)
    80004dcc:	f822                	sd	s0,48(sp)
    80004dce:	f426                	sd	s1,40(sp)
    80004dd0:	f04a                	sd	s2,32(sp)
    80004dd2:	ec4e                	sd	s3,24(sp)
    80004dd4:	e852                	sd	s4,16(sp)
    80004dd6:	e456                	sd	s5,8(sp)
    80004dd8:	0080                	addi	s0,sp,64
    80004dda:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ddc:	00038517          	auipc	a0,0x38
    80004de0:	4ac50513          	addi	a0,a0,1196 # 8003d288 <ftable>
    80004de4:	ffffc097          	auipc	ra,0xffffc
    80004de8:	df2080e7          	jalr	-526(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004dec:	40dc                	lw	a5,4(s1)
    80004dee:	06f05163          	blez	a5,80004e50 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004df2:	37fd                	addiw	a5,a5,-1
    80004df4:	0007871b          	sext.w	a4,a5
    80004df8:	c0dc                	sw	a5,4(s1)
    80004dfa:	06e04363          	bgtz	a4,80004e60 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004dfe:	0004a903          	lw	s2,0(s1)
    80004e02:	0094ca83          	lbu	s5,9(s1)
    80004e06:	0104ba03          	ld	s4,16(s1)
    80004e0a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004e0e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004e12:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004e16:	00038517          	auipc	a0,0x38
    80004e1a:	47250513          	addi	a0,a0,1138 # 8003d288 <ftable>
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	e6c080e7          	jalr	-404(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004e26:	4785                	li	a5,1
    80004e28:	04f90d63          	beq	s2,a5,80004e82 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e2c:	3979                	addiw	s2,s2,-2
    80004e2e:	4785                	li	a5,1
    80004e30:	0527e063          	bltu	a5,s2,80004e70 <fileclose+0xa8>
    begin_op();
    80004e34:	00000097          	auipc	ra,0x0
    80004e38:	ac8080e7          	jalr	-1336(ra) # 800048fc <begin_op>
    iput(ff.ip);
    80004e3c:	854e                	mv	a0,s3
    80004e3e:	fffff097          	auipc	ra,0xfffff
    80004e42:	2b2080e7          	jalr	690(ra) # 800040f0 <iput>
    end_op();
    80004e46:	00000097          	auipc	ra,0x0
    80004e4a:	b36080e7          	jalr	-1226(ra) # 8000497c <end_op>
    80004e4e:	a00d                	j	80004e70 <fileclose+0xa8>
    panic("fileclose");
    80004e50:	00004517          	auipc	a0,0x4
    80004e54:	86050513          	addi	a0,a0,-1952 # 800086b0 <syscalls+0x270>
    80004e58:	ffffb097          	auipc	ra,0xffffb
    80004e5c:	6e6080e7          	jalr	1766(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004e60:	00038517          	auipc	a0,0x38
    80004e64:	42850513          	addi	a0,a0,1064 # 8003d288 <ftable>
    80004e68:	ffffc097          	auipc	ra,0xffffc
    80004e6c:	e22080e7          	jalr	-478(ra) # 80000c8a <release>
  }
}
    80004e70:	70e2                	ld	ra,56(sp)
    80004e72:	7442                	ld	s0,48(sp)
    80004e74:	74a2                	ld	s1,40(sp)
    80004e76:	7902                	ld	s2,32(sp)
    80004e78:	69e2                	ld	s3,24(sp)
    80004e7a:	6a42                	ld	s4,16(sp)
    80004e7c:	6aa2                	ld	s5,8(sp)
    80004e7e:	6121                	addi	sp,sp,64
    80004e80:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004e82:	85d6                	mv	a1,s5
    80004e84:	8552                	mv	a0,s4
    80004e86:	00000097          	auipc	ra,0x0
    80004e8a:	34c080e7          	jalr	844(ra) # 800051d2 <pipeclose>
    80004e8e:	b7cd                	j	80004e70 <fileclose+0xa8>

0000000080004e90 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004e90:	715d                	addi	sp,sp,-80
    80004e92:	e486                	sd	ra,72(sp)
    80004e94:	e0a2                	sd	s0,64(sp)
    80004e96:	fc26                	sd	s1,56(sp)
    80004e98:	f84a                	sd	s2,48(sp)
    80004e9a:	f44e                	sd	s3,40(sp)
    80004e9c:	0880                	addi	s0,sp,80
    80004e9e:	84aa                	mv	s1,a0
    80004ea0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ea2:	ffffd097          	auipc	ra,0xffffd
    80004ea6:	b36080e7          	jalr	-1226(ra) # 800019d8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004eaa:	409c                	lw	a5,0(s1)
    80004eac:	37f9                	addiw	a5,a5,-2
    80004eae:	4705                	li	a4,1
    80004eb0:	04f76763          	bltu	a4,a5,80004efe <filestat+0x6e>
    80004eb4:	892a                	mv	s2,a0
    ilock(f->ip);
    80004eb6:	6c88                	ld	a0,24(s1)
    80004eb8:	fffff097          	auipc	ra,0xfffff
    80004ebc:	07e080e7          	jalr	126(ra) # 80003f36 <ilock>
    stati(f->ip, &st);
    80004ec0:	fb840593          	addi	a1,s0,-72
    80004ec4:	6c88                	ld	a0,24(s1)
    80004ec6:	fffff097          	auipc	ra,0xfffff
    80004eca:	2fa080e7          	jalr	762(ra) # 800041c0 <stati>
    iunlock(f->ip);
    80004ece:	6c88                	ld	a0,24(s1)
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	128080e7          	jalr	296(ra) # 80003ff8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ed8:	46e1                	li	a3,24
    80004eda:	fb840613          	addi	a2,s0,-72
    80004ede:	85ce                	mv	a1,s3
    80004ee0:	7c093503          	ld	a0,1984(s2)
    80004ee4:	ffffc097          	auipc	ra,0xffffc
    80004ee8:	784080e7          	jalr	1924(ra) # 80001668 <copyout>
    80004eec:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ef0:	60a6                	ld	ra,72(sp)
    80004ef2:	6406                	ld	s0,64(sp)
    80004ef4:	74e2                	ld	s1,56(sp)
    80004ef6:	7942                	ld	s2,48(sp)
    80004ef8:	79a2                	ld	s3,40(sp)
    80004efa:	6161                	addi	sp,sp,80
    80004efc:	8082                	ret
  return -1;
    80004efe:	557d                	li	a0,-1
    80004f00:	bfc5                	j	80004ef0 <filestat+0x60>

0000000080004f02 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004f02:	7179                	addi	sp,sp,-48
    80004f04:	f406                	sd	ra,40(sp)
    80004f06:	f022                	sd	s0,32(sp)
    80004f08:	ec26                	sd	s1,24(sp)
    80004f0a:	e84a                	sd	s2,16(sp)
    80004f0c:	e44e                	sd	s3,8(sp)
    80004f0e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004f10:	00854783          	lbu	a5,8(a0)
    80004f14:	c3d5                	beqz	a5,80004fb8 <fileread+0xb6>
    80004f16:	84aa                	mv	s1,a0
    80004f18:	89ae                	mv	s3,a1
    80004f1a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f1c:	411c                	lw	a5,0(a0)
    80004f1e:	4705                	li	a4,1
    80004f20:	04e78963          	beq	a5,a4,80004f72 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f24:	470d                	li	a4,3
    80004f26:	04e78d63          	beq	a5,a4,80004f80 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f2a:	4709                	li	a4,2
    80004f2c:	06e79e63          	bne	a5,a4,80004fa8 <fileread+0xa6>
    ilock(f->ip);
    80004f30:	6d08                	ld	a0,24(a0)
    80004f32:	fffff097          	auipc	ra,0xfffff
    80004f36:	004080e7          	jalr	4(ra) # 80003f36 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f3a:	874a                	mv	a4,s2
    80004f3c:	5094                	lw	a3,32(s1)
    80004f3e:	864e                	mv	a2,s3
    80004f40:	4585                	li	a1,1
    80004f42:	6c88                	ld	a0,24(s1)
    80004f44:	fffff097          	auipc	ra,0xfffff
    80004f48:	2a6080e7          	jalr	678(ra) # 800041ea <readi>
    80004f4c:	892a                	mv	s2,a0
    80004f4e:	00a05563          	blez	a0,80004f58 <fileread+0x56>
      f->off += r;
    80004f52:	509c                	lw	a5,32(s1)
    80004f54:	9fa9                	addw	a5,a5,a0
    80004f56:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004f58:	6c88                	ld	a0,24(s1)
    80004f5a:	fffff097          	auipc	ra,0xfffff
    80004f5e:	09e080e7          	jalr	158(ra) # 80003ff8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004f62:	854a                	mv	a0,s2
    80004f64:	70a2                	ld	ra,40(sp)
    80004f66:	7402                	ld	s0,32(sp)
    80004f68:	64e2                	ld	s1,24(sp)
    80004f6a:	6942                	ld	s2,16(sp)
    80004f6c:	69a2                	ld	s3,8(sp)
    80004f6e:	6145                	addi	sp,sp,48
    80004f70:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004f72:	6908                	ld	a0,16(a0)
    80004f74:	00000097          	auipc	ra,0x0
    80004f78:	3c6080e7          	jalr	966(ra) # 8000533a <piperead>
    80004f7c:	892a                	mv	s2,a0
    80004f7e:	b7d5                	j	80004f62 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004f80:	02451783          	lh	a5,36(a0)
    80004f84:	03079693          	slli	a3,a5,0x30
    80004f88:	92c1                	srli	a3,a3,0x30
    80004f8a:	4725                	li	a4,9
    80004f8c:	02d76863          	bltu	a4,a3,80004fbc <fileread+0xba>
    80004f90:	0792                	slli	a5,a5,0x4
    80004f92:	00038717          	auipc	a4,0x38
    80004f96:	25670713          	addi	a4,a4,598 # 8003d1e8 <devsw>
    80004f9a:	97ba                	add	a5,a5,a4
    80004f9c:	639c                	ld	a5,0(a5)
    80004f9e:	c38d                	beqz	a5,80004fc0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004fa0:	4505                	li	a0,1
    80004fa2:	9782                	jalr	a5
    80004fa4:	892a                	mv	s2,a0
    80004fa6:	bf75                	j	80004f62 <fileread+0x60>
    panic("fileread");
    80004fa8:	00003517          	auipc	a0,0x3
    80004fac:	71850513          	addi	a0,a0,1816 # 800086c0 <syscalls+0x280>
    80004fb0:	ffffb097          	auipc	ra,0xffffb
    80004fb4:	58e080e7          	jalr	1422(ra) # 8000053e <panic>
    return -1;
    80004fb8:	597d                	li	s2,-1
    80004fba:	b765                	j	80004f62 <fileread+0x60>
      return -1;
    80004fbc:	597d                	li	s2,-1
    80004fbe:	b755                	j	80004f62 <fileread+0x60>
    80004fc0:	597d                	li	s2,-1
    80004fc2:	b745                	j	80004f62 <fileread+0x60>

0000000080004fc4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004fc4:	715d                	addi	sp,sp,-80
    80004fc6:	e486                	sd	ra,72(sp)
    80004fc8:	e0a2                	sd	s0,64(sp)
    80004fca:	fc26                	sd	s1,56(sp)
    80004fcc:	f84a                	sd	s2,48(sp)
    80004fce:	f44e                	sd	s3,40(sp)
    80004fd0:	f052                	sd	s4,32(sp)
    80004fd2:	ec56                	sd	s5,24(sp)
    80004fd4:	e85a                	sd	s6,16(sp)
    80004fd6:	e45e                	sd	s7,8(sp)
    80004fd8:	e062                	sd	s8,0(sp)
    80004fda:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004fdc:	00954783          	lbu	a5,9(a0)
    80004fe0:	10078663          	beqz	a5,800050ec <filewrite+0x128>
    80004fe4:	892a                	mv	s2,a0
    80004fe6:	8aae                	mv	s5,a1
    80004fe8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004fea:	411c                	lw	a5,0(a0)
    80004fec:	4705                	li	a4,1
    80004fee:	02e78263          	beq	a5,a4,80005012 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ff2:	470d                	li	a4,3
    80004ff4:	02e78663          	beq	a5,a4,80005020 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ff8:	4709                	li	a4,2
    80004ffa:	0ee79163          	bne	a5,a4,800050dc <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004ffe:	0ac05d63          	blez	a2,800050b8 <filewrite+0xf4>
    int i = 0;
    80005002:	4981                	li	s3,0
    80005004:	6b05                	lui	s6,0x1
    80005006:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000500a:	6b85                	lui	s7,0x1
    8000500c:	c00b8b9b          	addiw	s7,s7,-1024
    80005010:	a861                	j	800050a8 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005012:	6908                	ld	a0,16(a0)
    80005014:	00000097          	auipc	ra,0x0
    80005018:	22e080e7          	jalr	558(ra) # 80005242 <pipewrite>
    8000501c:	8a2a                	mv	s4,a0
    8000501e:	a045                	j	800050be <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005020:	02451783          	lh	a5,36(a0)
    80005024:	03079693          	slli	a3,a5,0x30
    80005028:	92c1                	srli	a3,a3,0x30
    8000502a:	4725                	li	a4,9
    8000502c:	0cd76263          	bltu	a4,a3,800050f0 <filewrite+0x12c>
    80005030:	0792                	slli	a5,a5,0x4
    80005032:	00038717          	auipc	a4,0x38
    80005036:	1b670713          	addi	a4,a4,438 # 8003d1e8 <devsw>
    8000503a:	97ba                	add	a5,a5,a4
    8000503c:	679c                	ld	a5,8(a5)
    8000503e:	cbdd                	beqz	a5,800050f4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005040:	4505                	li	a0,1
    80005042:	9782                	jalr	a5
    80005044:	8a2a                	mv	s4,a0
    80005046:	a8a5                	j	800050be <filewrite+0xfa>
    80005048:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000504c:	00000097          	auipc	ra,0x0
    80005050:	8b0080e7          	jalr	-1872(ra) # 800048fc <begin_op>
      ilock(f->ip);
    80005054:	01893503          	ld	a0,24(s2)
    80005058:	fffff097          	auipc	ra,0xfffff
    8000505c:	ede080e7          	jalr	-290(ra) # 80003f36 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005060:	8762                	mv	a4,s8
    80005062:	02092683          	lw	a3,32(s2)
    80005066:	01598633          	add	a2,s3,s5
    8000506a:	4585                	li	a1,1
    8000506c:	01893503          	ld	a0,24(s2)
    80005070:	fffff097          	auipc	ra,0xfffff
    80005074:	272080e7          	jalr	626(ra) # 800042e2 <writei>
    80005078:	84aa                	mv	s1,a0
    8000507a:	00a05763          	blez	a0,80005088 <filewrite+0xc4>
        f->off += r;
    8000507e:	02092783          	lw	a5,32(s2)
    80005082:	9fa9                	addw	a5,a5,a0
    80005084:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005088:	01893503          	ld	a0,24(s2)
    8000508c:	fffff097          	auipc	ra,0xfffff
    80005090:	f6c080e7          	jalr	-148(ra) # 80003ff8 <iunlock>
      end_op();
    80005094:	00000097          	auipc	ra,0x0
    80005098:	8e8080e7          	jalr	-1816(ra) # 8000497c <end_op>

      if(r != n1){
    8000509c:	009c1f63          	bne	s8,s1,800050ba <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800050a0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800050a4:	0149db63          	bge	s3,s4,800050ba <filewrite+0xf6>
      int n1 = n - i;
    800050a8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800050ac:	84be                	mv	s1,a5
    800050ae:	2781                	sext.w	a5,a5
    800050b0:	f8fb5ce3          	bge	s6,a5,80005048 <filewrite+0x84>
    800050b4:	84de                	mv	s1,s7
    800050b6:	bf49                	j	80005048 <filewrite+0x84>
    int i = 0;
    800050b8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800050ba:	013a1f63          	bne	s4,s3,800050d8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800050be:	8552                	mv	a0,s4
    800050c0:	60a6                	ld	ra,72(sp)
    800050c2:	6406                	ld	s0,64(sp)
    800050c4:	74e2                	ld	s1,56(sp)
    800050c6:	7942                	ld	s2,48(sp)
    800050c8:	79a2                	ld	s3,40(sp)
    800050ca:	7a02                	ld	s4,32(sp)
    800050cc:	6ae2                	ld	s5,24(sp)
    800050ce:	6b42                	ld	s6,16(sp)
    800050d0:	6ba2                	ld	s7,8(sp)
    800050d2:	6c02                	ld	s8,0(sp)
    800050d4:	6161                	addi	sp,sp,80
    800050d6:	8082                	ret
    ret = (i == n ? n : -1);
    800050d8:	5a7d                	li	s4,-1
    800050da:	b7d5                	j	800050be <filewrite+0xfa>
    panic("filewrite");
    800050dc:	00003517          	auipc	a0,0x3
    800050e0:	5f450513          	addi	a0,a0,1524 # 800086d0 <syscalls+0x290>
    800050e4:	ffffb097          	auipc	ra,0xffffb
    800050e8:	45a080e7          	jalr	1114(ra) # 8000053e <panic>
    return -1;
    800050ec:	5a7d                	li	s4,-1
    800050ee:	bfc1                	j	800050be <filewrite+0xfa>
      return -1;
    800050f0:	5a7d                	li	s4,-1
    800050f2:	b7f1                	j	800050be <filewrite+0xfa>
    800050f4:	5a7d                	li	s4,-1
    800050f6:	b7e1                	j	800050be <filewrite+0xfa>

00000000800050f8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800050f8:	7179                	addi	sp,sp,-48
    800050fa:	f406                	sd	ra,40(sp)
    800050fc:	f022                	sd	s0,32(sp)
    800050fe:	ec26                	sd	s1,24(sp)
    80005100:	e84a                	sd	s2,16(sp)
    80005102:	e44e                	sd	s3,8(sp)
    80005104:	e052                	sd	s4,0(sp)
    80005106:	1800                	addi	s0,sp,48
    80005108:	84aa                	mv	s1,a0
    8000510a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000510c:	0005b023          	sd	zero,0(a1)
    80005110:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005114:	00000097          	auipc	ra,0x0
    80005118:	bf8080e7          	jalr	-1032(ra) # 80004d0c <filealloc>
    8000511c:	e088                	sd	a0,0(s1)
    8000511e:	c551                	beqz	a0,800051aa <pipealloc+0xb2>
    80005120:	00000097          	auipc	ra,0x0
    80005124:	bec080e7          	jalr	-1044(ra) # 80004d0c <filealloc>
    80005128:	00aa3023          	sd	a0,0(s4)
    8000512c:	c92d                	beqz	a0,8000519e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000512e:	ffffc097          	auipc	ra,0xffffc
    80005132:	9b8080e7          	jalr	-1608(ra) # 80000ae6 <kalloc>
    80005136:	892a                	mv	s2,a0
    80005138:	c125                	beqz	a0,80005198 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000513a:	4985                	li	s3,1
    8000513c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005140:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005144:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005148:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000514c:	00003597          	auipc	a1,0x3
    80005150:	59458593          	addi	a1,a1,1428 # 800086e0 <syscalls+0x2a0>
    80005154:	ffffc097          	auipc	ra,0xffffc
    80005158:	9f2080e7          	jalr	-1550(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    8000515c:	609c                	ld	a5,0(s1)
    8000515e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005162:	609c                	ld	a5,0(s1)
    80005164:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005168:	609c                	ld	a5,0(s1)
    8000516a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000516e:	609c                	ld	a5,0(s1)
    80005170:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005174:	000a3783          	ld	a5,0(s4)
    80005178:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000517c:	000a3783          	ld	a5,0(s4)
    80005180:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005184:	000a3783          	ld	a5,0(s4)
    80005188:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000518c:	000a3783          	ld	a5,0(s4)
    80005190:	0127b823          	sd	s2,16(a5)
  return 0;
    80005194:	4501                	li	a0,0
    80005196:	a025                	j	800051be <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005198:	6088                	ld	a0,0(s1)
    8000519a:	e501                	bnez	a0,800051a2 <pipealloc+0xaa>
    8000519c:	a039                	j	800051aa <pipealloc+0xb2>
    8000519e:	6088                	ld	a0,0(s1)
    800051a0:	c51d                	beqz	a0,800051ce <pipealloc+0xd6>
    fileclose(*f0);
    800051a2:	00000097          	auipc	ra,0x0
    800051a6:	c26080e7          	jalr	-986(ra) # 80004dc8 <fileclose>
  if(*f1)
    800051aa:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800051ae:	557d                	li	a0,-1
  if(*f1)
    800051b0:	c799                	beqz	a5,800051be <pipealloc+0xc6>
    fileclose(*f1);
    800051b2:	853e                	mv	a0,a5
    800051b4:	00000097          	auipc	ra,0x0
    800051b8:	c14080e7          	jalr	-1004(ra) # 80004dc8 <fileclose>
  return -1;
    800051bc:	557d                	li	a0,-1
}
    800051be:	70a2                	ld	ra,40(sp)
    800051c0:	7402                	ld	s0,32(sp)
    800051c2:	64e2                	ld	s1,24(sp)
    800051c4:	6942                	ld	s2,16(sp)
    800051c6:	69a2                	ld	s3,8(sp)
    800051c8:	6a02                	ld	s4,0(sp)
    800051ca:	6145                	addi	sp,sp,48
    800051cc:	8082                	ret
  return -1;
    800051ce:	557d                	li	a0,-1
    800051d0:	b7fd                	j	800051be <pipealloc+0xc6>

00000000800051d2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800051d2:	1101                	addi	sp,sp,-32
    800051d4:	ec06                	sd	ra,24(sp)
    800051d6:	e822                	sd	s0,16(sp)
    800051d8:	e426                	sd	s1,8(sp)
    800051da:	e04a                	sd	s2,0(sp)
    800051dc:	1000                	addi	s0,sp,32
    800051de:	84aa                	mv	s1,a0
    800051e0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800051e2:	ffffc097          	auipc	ra,0xffffc
    800051e6:	9f4080e7          	jalr	-1548(ra) # 80000bd6 <acquire>
  if(writable){
    800051ea:	02090d63          	beqz	s2,80005224 <pipeclose+0x52>
    pi->writeopen = 0;
    800051ee:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800051f2:	21848513          	addi	a0,s1,536
    800051f6:	ffffd097          	auipc	ra,0xffffd
    800051fa:	fda080e7          	jalr	-38(ra) # 800021d0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800051fe:	2204b783          	ld	a5,544(s1)
    80005202:	eb95                	bnez	a5,80005236 <pipeclose+0x64>
    release(&pi->lock);
    80005204:	8526                	mv	a0,s1
    80005206:	ffffc097          	auipc	ra,0xffffc
    8000520a:	a84080e7          	jalr	-1404(ra) # 80000c8a <release>
    kfree((char*)pi);
    8000520e:	8526                	mv	a0,s1
    80005210:	ffffb097          	auipc	ra,0xffffb
    80005214:	7da080e7          	jalr	2010(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80005218:	60e2                	ld	ra,24(sp)
    8000521a:	6442                	ld	s0,16(sp)
    8000521c:	64a2                	ld	s1,8(sp)
    8000521e:	6902                	ld	s2,0(sp)
    80005220:	6105                	addi	sp,sp,32
    80005222:	8082                	ret
    pi->readopen = 0;
    80005224:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005228:	21c48513          	addi	a0,s1,540
    8000522c:	ffffd097          	auipc	ra,0xffffd
    80005230:	fa4080e7          	jalr	-92(ra) # 800021d0 <wakeup>
    80005234:	b7e9                	j	800051fe <pipeclose+0x2c>
    release(&pi->lock);
    80005236:	8526                	mv	a0,s1
    80005238:	ffffc097          	auipc	ra,0xffffc
    8000523c:	a52080e7          	jalr	-1454(ra) # 80000c8a <release>
}
    80005240:	bfe1                	j	80005218 <pipeclose+0x46>

0000000080005242 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005242:	711d                	addi	sp,sp,-96
    80005244:	ec86                	sd	ra,88(sp)
    80005246:	e8a2                	sd	s0,80(sp)
    80005248:	e4a6                	sd	s1,72(sp)
    8000524a:	e0ca                	sd	s2,64(sp)
    8000524c:	fc4e                	sd	s3,56(sp)
    8000524e:	f852                	sd	s4,48(sp)
    80005250:	f456                	sd	s5,40(sp)
    80005252:	f05a                	sd	s6,32(sp)
    80005254:	ec5e                	sd	s7,24(sp)
    80005256:	e862                	sd	s8,16(sp)
    80005258:	1080                	addi	s0,sp,96
    8000525a:	84aa                	mv	s1,a0
    8000525c:	8aae                	mv	s5,a1
    8000525e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005260:	ffffc097          	auipc	ra,0xffffc
    80005264:	778080e7          	jalr	1912(ra) # 800019d8 <myproc>
    80005268:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000526a:	8526                	mv	a0,s1
    8000526c:	ffffc097          	auipc	ra,0xffffc
    80005270:	96a080e7          	jalr	-1686(ra) # 80000bd6 <acquire>
  while(i < n){
    80005274:	0b405663          	blez	s4,80005320 <pipewrite+0xde>
  int i = 0;
    80005278:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000527a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000527c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005280:	21c48b93          	addi	s7,s1,540
    80005284:	a089                	j	800052c6 <pipewrite+0x84>
      release(&pi->lock);
    80005286:	8526                	mv	a0,s1
    80005288:	ffffc097          	auipc	ra,0xffffc
    8000528c:	a02080e7          	jalr	-1534(ra) # 80000c8a <release>
      return -1;
    80005290:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005292:	854a                	mv	a0,s2
    80005294:	60e6                	ld	ra,88(sp)
    80005296:	6446                	ld	s0,80(sp)
    80005298:	64a6                	ld	s1,72(sp)
    8000529a:	6906                	ld	s2,64(sp)
    8000529c:	79e2                	ld	s3,56(sp)
    8000529e:	7a42                	ld	s4,48(sp)
    800052a0:	7aa2                	ld	s5,40(sp)
    800052a2:	7b02                	ld	s6,32(sp)
    800052a4:	6be2                	ld	s7,24(sp)
    800052a6:	6c42                	ld	s8,16(sp)
    800052a8:	6125                	addi	sp,sp,96
    800052aa:	8082                	ret
      wakeup(&pi->nread);
    800052ac:	8562                	mv	a0,s8
    800052ae:	ffffd097          	auipc	ra,0xffffd
    800052b2:	f22080e7          	jalr	-222(ra) # 800021d0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800052b6:	85a6                	mv	a1,s1
    800052b8:	855e                	mv	a0,s7
    800052ba:	ffffd097          	auipc	ra,0xffffd
    800052be:	eb2080e7          	jalr	-334(ra) # 8000216c <sleep>
  while(i < n){
    800052c2:	07495063          	bge	s2,s4,80005322 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800052c6:	2204a783          	lw	a5,544(s1)
    800052ca:	dfd5                	beqz	a5,80005286 <pipewrite+0x44>
    800052cc:	854e                	mv	a0,s3
    800052ce:	ffffd097          	auipc	ra,0xffffd
    800052d2:	25c080e7          	jalr	604(ra) # 8000252a <killed>
    800052d6:	f945                	bnez	a0,80005286 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800052d8:	2184a783          	lw	a5,536(s1)
    800052dc:	21c4a703          	lw	a4,540(s1)
    800052e0:	2007879b          	addiw	a5,a5,512
    800052e4:	fcf704e3          	beq	a4,a5,800052ac <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052e8:	4685                	li	a3,1
    800052ea:	01590633          	add	a2,s2,s5
    800052ee:	faf40593          	addi	a1,s0,-81
    800052f2:	7c09b503          	ld	a0,1984(s3)
    800052f6:	ffffc097          	auipc	ra,0xffffc
    800052fa:	3fe080e7          	jalr	1022(ra) # 800016f4 <copyin>
    800052fe:	03650263          	beq	a0,s6,80005322 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005302:	21c4a783          	lw	a5,540(s1)
    80005306:	0017871b          	addiw	a4,a5,1
    8000530a:	20e4ae23          	sw	a4,540(s1)
    8000530e:	1ff7f793          	andi	a5,a5,511
    80005312:	97a6                	add	a5,a5,s1
    80005314:	faf44703          	lbu	a4,-81(s0)
    80005318:	00e78c23          	sb	a4,24(a5)
      i++;
    8000531c:	2905                	addiw	s2,s2,1
    8000531e:	b755                	j	800052c2 <pipewrite+0x80>
  int i = 0;
    80005320:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005322:	21848513          	addi	a0,s1,536
    80005326:	ffffd097          	auipc	ra,0xffffd
    8000532a:	eaa080e7          	jalr	-342(ra) # 800021d0 <wakeup>
  release(&pi->lock);
    8000532e:	8526                	mv	a0,s1
    80005330:	ffffc097          	auipc	ra,0xffffc
    80005334:	95a080e7          	jalr	-1702(ra) # 80000c8a <release>
  return i;
    80005338:	bfa9                	j	80005292 <pipewrite+0x50>

000000008000533a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000533a:	715d                	addi	sp,sp,-80
    8000533c:	e486                	sd	ra,72(sp)
    8000533e:	e0a2                	sd	s0,64(sp)
    80005340:	fc26                	sd	s1,56(sp)
    80005342:	f84a                	sd	s2,48(sp)
    80005344:	f44e                	sd	s3,40(sp)
    80005346:	f052                	sd	s4,32(sp)
    80005348:	ec56                	sd	s5,24(sp)
    8000534a:	e85a                	sd	s6,16(sp)
    8000534c:	0880                	addi	s0,sp,80
    8000534e:	84aa                	mv	s1,a0
    80005350:	892e                	mv	s2,a1
    80005352:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005354:	ffffc097          	auipc	ra,0xffffc
    80005358:	684080e7          	jalr	1668(ra) # 800019d8 <myproc>
    8000535c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000535e:	8526                	mv	a0,s1
    80005360:	ffffc097          	auipc	ra,0xffffc
    80005364:	876080e7          	jalr	-1930(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005368:	2184a703          	lw	a4,536(s1)
    8000536c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005370:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005374:	02f71763          	bne	a4,a5,800053a2 <piperead+0x68>
    80005378:	2244a783          	lw	a5,548(s1)
    8000537c:	c39d                	beqz	a5,800053a2 <piperead+0x68>
    if(killed(pr)){
    8000537e:	8552                	mv	a0,s4
    80005380:	ffffd097          	auipc	ra,0xffffd
    80005384:	1aa080e7          	jalr	426(ra) # 8000252a <killed>
    80005388:	e941                	bnez	a0,80005418 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000538a:	85a6                	mv	a1,s1
    8000538c:	854e                	mv	a0,s3
    8000538e:	ffffd097          	auipc	ra,0xffffd
    80005392:	dde080e7          	jalr	-546(ra) # 8000216c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005396:	2184a703          	lw	a4,536(s1)
    8000539a:	21c4a783          	lw	a5,540(s1)
    8000539e:	fcf70de3          	beq	a4,a5,80005378 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053a2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053a4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053a6:	05505363          	blez	s5,800053ec <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800053aa:	2184a783          	lw	a5,536(s1)
    800053ae:	21c4a703          	lw	a4,540(s1)
    800053b2:	02f70d63          	beq	a4,a5,800053ec <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800053b6:	0017871b          	addiw	a4,a5,1
    800053ba:	20e4ac23          	sw	a4,536(s1)
    800053be:	1ff7f793          	andi	a5,a5,511
    800053c2:	97a6                	add	a5,a5,s1
    800053c4:	0187c783          	lbu	a5,24(a5)
    800053c8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053cc:	4685                	li	a3,1
    800053ce:	fbf40613          	addi	a2,s0,-65
    800053d2:	85ca                	mv	a1,s2
    800053d4:	7c0a3503          	ld	a0,1984(s4)
    800053d8:	ffffc097          	auipc	ra,0xffffc
    800053dc:	290080e7          	jalr	656(ra) # 80001668 <copyout>
    800053e0:	01650663          	beq	a0,s6,800053ec <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053e4:	2985                	addiw	s3,s3,1
    800053e6:	0905                	addi	s2,s2,1
    800053e8:	fd3a91e3          	bne	s5,s3,800053aa <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800053ec:	21c48513          	addi	a0,s1,540
    800053f0:	ffffd097          	auipc	ra,0xffffd
    800053f4:	de0080e7          	jalr	-544(ra) # 800021d0 <wakeup>
  release(&pi->lock);
    800053f8:	8526                	mv	a0,s1
    800053fa:	ffffc097          	auipc	ra,0xffffc
    800053fe:	890080e7          	jalr	-1904(ra) # 80000c8a <release>
  return i;
}
    80005402:	854e                	mv	a0,s3
    80005404:	60a6                	ld	ra,72(sp)
    80005406:	6406                	ld	s0,64(sp)
    80005408:	74e2                	ld	s1,56(sp)
    8000540a:	7942                	ld	s2,48(sp)
    8000540c:	79a2                	ld	s3,40(sp)
    8000540e:	7a02                	ld	s4,32(sp)
    80005410:	6ae2                	ld	s5,24(sp)
    80005412:	6b42                	ld	s6,16(sp)
    80005414:	6161                	addi	sp,sp,80
    80005416:	8082                	ret
      release(&pi->lock);
    80005418:	8526                	mv	a0,s1
    8000541a:	ffffc097          	auipc	ra,0xffffc
    8000541e:	870080e7          	jalr	-1936(ra) # 80000c8a <release>
      return -1;
    80005422:	59fd                	li	s3,-1
    80005424:	bff9                	j	80005402 <piperead+0xc8>

0000000080005426 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005426:	1141                	addi	sp,sp,-16
    80005428:	e422                	sd	s0,8(sp)
    8000542a:	0800                	addi	s0,sp,16
    8000542c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000542e:	8905                	andi	a0,a0,1
    80005430:	c111                	beqz	a0,80005434 <flags2perm+0xe>
      perm = PTE_X;
    80005432:	4521                	li	a0,8
    if(flags & 0x2)
    80005434:	8b89                	andi	a5,a5,2
    80005436:	c399                	beqz	a5,8000543c <flags2perm+0x16>
      perm |= PTE_W;
    80005438:	00456513          	ori	a0,a0,4
    return perm;
}
    8000543c:	6422                	ld	s0,8(sp)
    8000543e:	0141                	addi	sp,sp,16
    80005440:	8082                	ret

0000000080005442 <exec>:

int
exec(char *path, char **argv)
{
    80005442:	de010113          	addi	sp,sp,-544
    80005446:	20113c23          	sd	ra,536(sp)
    8000544a:	20813823          	sd	s0,528(sp)
    8000544e:	20913423          	sd	s1,520(sp)
    80005452:	21213023          	sd	s2,512(sp)
    80005456:	ffce                	sd	s3,504(sp)
    80005458:	fbd2                	sd	s4,496(sp)
    8000545a:	f7d6                	sd	s5,488(sp)
    8000545c:	f3da                	sd	s6,480(sp)
    8000545e:	efde                	sd	s7,472(sp)
    80005460:	ebe2                	sd	s8,464(sp)
    80005462:	e7e6                	sd	s9,456(sp)
    80005464:	e3ea                	sd	s10,448(sp)
    80005466:	ff6e                	sd	s11,440(sp)
    80005468:	1400                	addi	s0,sp,544
    8000546a:	892a                	mv	s2,a0
    8000546c:	dea43423          	sd	a0,-536(s0)
    80005470:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005474:	ffffc097          	auipc	ra,0xffffc
    80005478:	564080e7          	jalr	1380(ra) # 800019d8 <myproc>
    8000547c:	84aa                	mv	s1,a0
  struct kthread *kt = mykthread();
    8000547e:	ffffd097          	auipc	ra,0xffffd
    80005482:	43c080e7          	jalr	1084(ra) # 800028ba <mykthread>

  begin_op();
    80005486:	fffff097          	auipc	ra,0xfffff
    8000548a:	476080e7          	jalr	1142(ra) # 800048fc <begin_op>

  if((ip = namei(path)) == 0){
    8000548e:	854a                	mv	a0,s2
    80005490:	fffff097          	auipc	ra,0xfffff
    80005494:	250080e7          	jalr	592(ra) # 800046e0 <namei>
    80005498:	c93d                	beqz	a0,8000550e <exec+0xcc>
    8000549a:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000549c:	fffff097          	auipc	ra,0xfffff
    800054a0:	a9a080e7          	jalr	-1382(ra) # 80003f36 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800054a4:	04000713          	li	a4,64
    800054a8:	4681                	li	a3,0
    800054aa:	e5040613          	addi	a2,s0,-432
    800054ae:	4581                	li	a1,0
    800054b0:	8556                	mv	a0,s5
    800054b2:	fffff097          	auipc	ra,0xfffff
    800054b6:	d38080e7          	jalr	-712(ra) # 800041ea <readi>
    800054ba:	04000793          	li	a5,64
    800054be:	00f51a63          	bne	a0,a5,800054d2 <exec+0x90>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800054c2:	e5042703          	lw	a4,-432(s0)
    800054c6:	464c47b7          	lui	a5,0x464c4
    800054ca:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800054ce:	04f70663          	beq	a4,a5,8000551a <exec+0xd8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800054d2:	8556                	mv	a0,s5
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	cc4080e7          	jalr	-828(ra) # 80004198 <iunlockput>
    end_op();
    800054dc:	fffff097          	auipc	ra,0xfffff
    800054e0:	4a0080e7          	jalr	1184(ra) # 8000497c <end_op>
  }
  return -1;
    800054e4:	557d                	li	a0,-1
}
    800054e6:	21813083          	ld	ra,536(sp)
    800054ea:	21013403          	ld	s0,528(sp)
    800054ee:	20813483          	ld	s1,520(sp)
    800054f2:	20013903          	ld	s2,512(sp)
    800054f6:	79fe                	ld	s3,504(sp)
    800054f8:	7a5e                	ld	s4,496(sp)
    800054fa:	7abe                	ld	s5,488(sp)
    800054fc:	7b1e                	ld	s6,480(sp)
    800054fe:	6bfe                	ld	s7,472(sp)
    80005500:	6c5e                	ld	s8,464(sp)
    80005502:	6cbe                	ld	s9,456(sp)
    80005504:	6d1e                	ld	s10,448(sp)
    80005506:	7dfa                	ld	s11,440(sp)
    80005508:	22010113          	addi	sp,sp,544
    8000550c:	8082                	ret
    end_op();
    8000550e:	fffff097          	auipc	ra,0xfffff
    80005512:	46e080e7          	jalr	1134(ra) # 8000497c <end_op>
    return -1;
    80005516:	557d                	li	a0,-1
    80005518:	b7f9                	j	800054e6 <exec+0xa4>
  if((pagetable = proc_pagetable(p)) == 0)
    8000551a:	8526                	mv	a0,s1
    8000551c:	ffffc097          	auipc	ra,0xffffc
    80005520:	53e080e7          	jalr	1342(ra) # 80001a5a <proc_pagetable>
    80005524:	8b2a                	mv	s6,a0
    80005526:	d555                	beqz	a0,800054d2 <exec+0x90>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005528:	e7042783          	lw	a5,-400(s0)
    8000552c:	e8845703          	lhu	a4,-376(s0)
    80005530:	c735                	beqz	a4,8000559c <exec+0x15a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005532:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005534:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005538:	6a05                	lui	s4,0x1
    8000553a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000553e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005542:	6d85                	lui	s11,0x1
    80005544:	7d7d                	lui	s10,0xfffff
    80005546:	a47d                	j	800057f4 <exec+0x3b2>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005548:	00003517          	auipc	a0,0x3
    8000554c:	1a050513          	addi	a0,a0,416 # 800086e8 <syscalls+0x2a8>
    80005550:	ffffb097          	auipc	ra,0xffffb
    80005554:	fee080e7          	jalr	-18(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005558:	874a                	mv	a4,s2
    8000555a:	009c86bb          	addw	a3,s9,s1
    8000555e:	4581                	li	a1,0
    80005560:	8556                	mv	a0,s5
    80005562:	fffff097          	auipc	ra,0xfffff
    80005566:	c88080e7          	jalr	-888(ra) # 800041ea <readi>
    8000556a:	2501                	sext.w	a0,a0
    8000556c:	22a91163          	bne	s2,a0,8000578e <exec+0x34c>
  for(i = 0; i < sz; i += PGSIZE){
    80005570:	009d84bb          	addw	s1,s11,s1
    80005574:	013d09bb          	addw	s3,s10,s3
    80005578:	2574fe63          	bgeu	s1,s7,800057d4 <exec+0x392>
    pa = walkaddr(pagetable, va + i);
    8000557c:	02049593          	slli	a1,s1,0x20
    80005580:	9181                	srli	a1,a1,0x20
    80005582:	95e2                	add	a1,a1,s8
    80005584:	855a                	mv	a0,s6
    80005586:	ffffc097          	auipc	ra,0xffffc
    8000558a:	ad6080e7          	jalr	-1322(ra) # 8000105c <walkaddr>
    8000558e:	862a                	mv	a2,a0
    if(pa == 0)
    80005590:	dd45                	beqz	a0,80005548 <exec+0x106>
      n = PGSIZE;
    80005592:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005594:	fd49f2e3          	bgeu	s3,s4,80005558 <exec+0x116>
      n = sz - i;
    80005598:	894e                	mv	s2,s3
    8000559a:	bf7d                	j	80005558 <exec+0x116>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000559c:	4901                	li	s2,0
  iunlockput(ip);
    8000559e:	8556                	mv	a0,s5
    800055a0:	fffff097          	auipc	ra,0xfffff
    800055a4:	bf8080e7          	jalr	-1032(ra) # 80004198 <iunlockput>
  end_op();
    800055a8:	fffff097          	auipc	ra,0xfffff
    800055ac:	3d4080e7          	jalr	980(ra) # 8000497c <end_op>
  p = myproc();
    800055b0:	ffffc097          	auipc	ra,0xffffc
    800055b4:	428080e7          	jalr	1064(ra) # 800019d8 <myproc>
    800055b8:	8baa                	mv	s7,a0
  kt = mykthread();
    800055ba:	ffffd097          	auipc	ra,0xffffd
    800055be:	300080e7          	jalr	768(ra) # 800028ba <mykthread>
    800055c2:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    800055c4:	7b8bbd83          	ld	s11,1976(s7) # 17b8 <_entry-0x7fffe848>
  sz = PGROUNDUP(sz);
    800055c8:	6785                	lui	a5,0x1
    800055ca:	17fd                	addi	a5,a5,-1
    800055cc:	993e                	add	s2,s2,a5
    800055ce:	77fd                	lui	a5,0xfffff
    800055d0:	00f977b3          	and	a5,s2,a5
    800055d4:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800055d8:	4691                	li	a3,4
    800055da:	6609                	lui	a2,0x2
    800055dc:	963e                	add	a2,a2,a5
    800055de:	85be                	mv	a1,a5
    800055e0:	855a                	mv	a0,s6
    800055e2:	ffffc097          	auipc	ra,0xffffc
    800055e6:	e2e080e7          	jalr	-466(ra) # 80001410 <uvmalloc>
    800055ea:	8c2a                	mv	s8,a0
  ip = 0;
    800055ec:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800055ee:	1a050063          	beqz	a0,8000578e <exec+0x34c>
  uvmclear(pagetable, sz-2*PGSIZE);
    800055f2:	75f9                	lui	a1,0xffffe
    800055f4:	95aa                	add	a1,a1,a0
    800055f6:	855a                	mv	a0,s6
    800055f8:	ffffc097          	auipc	ra,0xffffc
    800055fc:	03e080e7          	jalr	62(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80005600:	7afd                	lui	s5,0xfffff
    80005602:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005604:	df043783          	ld	a5,-528(s0)
    80005608:	6388                	ld	a0,0(a5)
    8000560a:	c925                	beqz	a0,8000567a <exec+0x238>
    8000560c:	e9040993          	addi	s3,s0,-368
    80005610:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005614:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005616:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005618:	ffffc097          	auipc	ra,0xffffc
    8000561c:	836080e7          	jalr	-1994(ra) # 80000e4e <strlen>
    80005620:	0015079b          	addiw	a5,a0,1
    80005624:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005628:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000562c:	19596863          	bltu	s2,s5,800057bc <exec+0x37a>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005630:	df043783          	ld	a5,-528(s0)
    80005634:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffc0c80>
    80005638:	8552                	mv	a0,s4
    8000563a:	ffffc097          	auipc	ra,0xffffc
    8000563e:	814080e7          	jalr	-2028(ra) # 80000e4e <strlen>
    80005642:	0015069b          	addiw	a3,a0,1
    80005646:	8652                	mv	a2,s4
    80005648:	85ca                	mv	a1,s2
    8000564a:	855a                	mv	a0,s6
    8000564c:	ffffc097          	auipc	ra,0xffffc
    80005650:	01c080e7          	jalr	28(ra) # 80001668 <copyout>
    80005654:	16054863          	bltz	a0,800057c4 <exec+0x382>
    ustack[argc] = sp;
    80005658:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000565c:	0485                	addi	s1,s1,1
    8000565e:	df043783          	ld	a5,-528(s0)
    80005662:	07a1                	addi	a5,a5,8
    80005664:	def43823          	sd	a5,-528(s0)
    80005668:	6388                	ld	a0,0(a5)
    8000566a:	c911                	beqz	a0,8000567e <exec+0x23c>
    if(argc >= MAXARG)
    8000566c:	09a1                	addi	s3,s3,8
    8000566e:	fb9995e3          	bne	s3,s9,80005618 <exec+0x1d6>
  sz = sz1;
    80005672:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005676:	4a81                	li	s5,0
    80005678:	aa19                	j	8000578e <exec+0x34c>
  sp = sz;
    8000567a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000567c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000567e:	00349793          	slli	a5,s1,0x3
    80005682:	f9040713          	addi	a4,s0,-112
    80005686:	97ba                	add	a5,a5,a4
    80005688:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000568c:	00148693          	addi	a3,s1,1
    80005690:	068e                	slli	a3,a3,0x3
    80005692:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005696:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000569a:	01597663          	bgeu	s2,s5,800056a6 <exec+0x264>
  sz = sz1;
    8000569e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056a2:	4a81                	li	s5,0
    800056a4:	a0ed                	j	8000578e <exec+0x34c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800056a6:	e9040613          	addi	a2,s0,-368
    800056aa:	85ca                	mv	a1,s2
    800056ac:	855a                	mv	a0,s6
    800056ae:	ffffc097          	auipc	ra,0xffffc
    800056b2:	fba080e7          	jalr	-70(ra) # 80001668 <copyout>
    800056b6:	10054b63          	bltz	a0,800057cc <exec+0x38a>
  for(struct kthread *t2 = p->kthread ; t2< &p->kthread[NKT]; t2++){
    800056ba:	028b8a13          	addi	s4,s7,40
    800056be:	7a8b8a93          	addi	s5,s7,1960
    800056c2:	89d2                	mv	s3,s4
      t2->t_state = ZOMBIE_t;
    800056c4:	4c95                	li	s9,5
    800056c6:	a029                	j	800056d0 <exec+0x28e>
  for(struct kthread *t2 = p->kthread ; t2< &p->kthread[NKT]; t2++){
    800056c8:	0c098993          	addi	s3,s3,192
    800056cc:	033a8a63          	beq	s5,s3,80005700 <exec+0x2be>
    if(kt !=t2 && t2->t_state != UNUSED_t){
    800056d0:	ff3d0ce3          	beq	s10,s3,800056c8 <exec+0x286>
    800056d4:	0189a783          	lw	a5,24(s3)
    800056d8:	dbe5                	beqz	a5,800056c8 <exec+0x286>
      acquire(&t2->t_lock);
    800056da:	854e                	mv	a0,s3
    800056dc:	ffffb097          	auipc	ra,0xffffb
    800056e0:	4fa080e7          	jalr	1274(ra) # 80000bd6 <acquire>
      t2->t_xstate = 0;
    800056e4:	0209a623          	sw	zero,44(s3)
      t2->t_state = ZOMBIE_t;
    800056e8:	0199ac23          	sw	s9,24(s3)
      release(&t2->t_lock);  
    800056ec:	854e                	mv	a0,s3
    800056ee:	ffffb097          	auipc	ra,0xffffb
    800056f2:	59c080e7          	jalr	1436(ra) # 80000c8a <release>
    800056f6:	bfc9                	j	800056c8 <exec+0x286>
  for(struct kthread *t2 = p->kthread ; t2< &p->kthread[NKT]; t2++){
    800056f8:	0c0a0a13          	addi	s4,s4,192
    800056fc:	014a8f63          	beq	s5,s4,8000571a <exec+0x2d8>
    if(kt !=t2 && t2->t_state != UNUSED_t){
    80005700:	ff4d0ce3          	beq	s10,s4,800056f8 <exec+0x2b6>
    80005704:	018a2783          	lw	a5,24(s4)
    80005708:	dbe5                	beqz	a5,800056f8 <exec+0x2b6>
      kthread_join(t2->tid,0);
    8000570a:	4581                	li	a1,0
    8000570c:	030a2503          	lw	a0,48(s4)
    80005710:	ffffd097          	auipc	ra,0xffffd
    80005714:	536080e7          	jalr	1334(ra) # 80002c46 <kthread_join>
    80005718:	b7c5                	j	800056f8 <exec+0x2b6>
  kt->trapframe->a1 = sp;
    8000571a:	0b8d3783          	ld	a5,184(s10) # fffffffffffff0b8 <end+0xffffffff7ffc0d38>
    8000571e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005722:	de843783          	ld	a5,-536(s0)
    80005726:	0007c703          	lbu	a4,0(a5)
    8000572a:	cf11                	beqz	a4,80005746 <exec+0x304>
    8000572c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000572e:	02f00693          	li	a3,47
    80005732:	a039                	j	80005740 <exec+0x2fe>
      last = s+1;
    80005734:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005738:	0785                	addi	a5,a5,1
    8000573a:	fff7c703          	lbu	a4,-1(a5)
    8000573e:	c701                	beqz	a4,80005746 <exec+0x304>
    if(*s == '/')
    80005740:	fed71ce3          	bne	a4,a3,80005738 <exec+0x2f6>
    80005744:	bfc5                	j	80005734 <exec+0x2f2>
  safestrcpy(p->name, last, sizeof(p->name));
    80005746:	4641                	li	a2,16
    80005748:	de843583          	ld	a1,-536(s0)
    8000574c:	6505                	lui	a0,0x1
    8000574e:	85050513          	addi	a0,a0,-1968 # 850 <_entry-0x7ffff7b0>
    80005752:	955e                	add	a0,a0,s7
    80005754:	ffffb097          	auipc	ra,0xffffb
    80005758:	6c8080e7          	jalr	1736(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000575c:	7c0bb503          	ld	a0,1984(s7)
  p->pagetable = pagetable;
    80005760:	7d6bb023          	sd	s6,1984(s7)
  p->sz = sz;
    80005764:	7b8bbc23          	sd	s8,1976(s7)
  kt->trapframe->epc = elf.entry;  // initial program counter = main
    80005768:	0b8d3783          	ld	a5,184(s10)
    8000576c:	e6843703          	ld	a4,-408(s0)
    80005770:	ef98                	sd	a4,24(a5)
  kt->trapframe->sp = sp; // initial stack pointer
    80005772:	0b8d3783          	ld	a5,184(s10)
    80005776:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000577a:	85ee                	mv	a1,s11
    8000577c:	ffffc097          	auipc	ra,0xffffc
    80005780:	37a080e7          	jalr	890(ra) # 80001af6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005784:	0004851b          	sext.w	a0,s1
    80005788:	bbb9                	j	800054e6 <exec+0xa4>
    8000578a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000578e:	df843583          	ld	a1,-520(s0)
    80005792:	855a                	mv	a0,s6
    80005794:	ffffc097          	auipc	ra,0xffffc
    80005798:	362080e7          	jalr	866(ra) # 80001af6 <proc_freepagetable>
  if(ip){
    8000579c:	d20a9be3          	bnez	s5,800054d2 <exec+0x90>
  return -1;
    800057a0:	557d                	li	a0,-1
    800057a2:	b391                	j	800054e6 <exec+0xa4>
    800057a4:	df243c23          	sd	s2,-520(s0)
    800057a8:	b7dd                	j	8000578e <exec+0x34c>
    800057aa:	df243c23          	sd	s2,-520(s0)
    800057ae:	b7c5                	j	8000578e <exec+0x34c>
    800057b0:	df243c23          	sd	s2,-520(s0)
    800057b4:	bfe9                	j	8000578e <exec+0x34c>
    800057b6:	df243c23          	sd	s2,-520(s0)
    800057ba:	bfd1                	j	8000578e <exec+0x34c>
  sz = sz1;
    800057bc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057c0:	4a81                	li	s5,0
    800057c2:	b7f1                	j	8000578e <exec+0x34c>
  sz = sz1;
    800057c4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057c8:	4a81                	li	s5,0
    800057ca:	b7d1                	j	8000578e <exec+0x34c>
  sz = sz1;
    800057cc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057d0:	4a81                	li	s5,0
    800057d2:	bf75                	j	8000578e <exec+0x34c>
    sz = sz1;
    800057d4:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800057d8:	e0843783          	ld	a5,-504(s0)
    800057dc:	0017869b          	addiw	a3,a5,1
    800057e0:	e0d43423          	sd	a3,-504(s0)
    800057e4:	e0043783          	ld	a5,-512(s0)
    800057e8:	0387879b          	addiw	a5,a5,56
    800057ec:	e8845703          	lhu	a4,-376(s0)
    800057f0:	dae6d7e3          	bge	a3,a4,8000559e <exec+0x15c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800057f4:	2781                	sext.w	a5,a5
    800057f6:	e0f43023          	sd	a5,-512(s0)
    800057fa:	03800713          	li	a4,56
    800057fe:	86be                	mv	a3,a5
    80005800:	e1840613          	addi	a2,s0,-488
    80005804:	4581                	li	a1,0
    80005806:	8556                	mv	a0,s5
    80005808:	fffff097          	auipc	ra,0xfffff
    8000580c:	9e2080e7          	jalr	-1566(ra) # 800041ea <readi>
    80005810:	03800793          	li	a5,56
    80005814:	f6f51be3          	bne	a0,a5,8000578a <exec+0x348>
    if(ph.type != ELF_PROG_LOAD)
    80005818:	e1842783          	lw	a5,-488(s0)
    8000581c:	4705                	li	a4,1
    8000581e:	fae79de3          	bne	a5,a4,800057d8 <exec+0x396>
    if(ph.memsz < ph.filesz)
    80005822:	e4043483          	ld	s1,-448(s0)
    80005826:	e3843783          	ld	a5,-456(s0)
    8000582a:	f6f4ede3          	bltu	s1,a5,800057a4 <exec+0x362>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000582e:	e2843783          	ld	a5,-472(s0)
    80005832:	94be                	add	s1,s1,a5
    80005834:	f6f4ebe3          	bltu	s1,a5,800057aa <exec+0x368>
    if(ph.vaddr % PGSIZE != 0)
    80005838:	de043703          	ld	a4,-544(s0)
    8000583c:	8ff9                	and	a5,a5,a4
    8000583e:	fbad                	bnez	a5,800057b0 <exec+0x36e>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005840:	e1c42503          	lw	a0,-484(s0)
    80005844:	00000097          	auipc	ra,0x0
    80005848:	be2080e7          	jalr	-1054(ra) # 80005426 <flags2perm>
    8000584c:	86aa                	mv	a3,a0
    8000584e:	8626                	mv	a2,s1
    80005850:	85ca                	mv	a1,s2
    80005852:	855a                	mv	a0,s6
    80005854:	ffffc097          	auipc	ra,0xffffc
    80005858:	bbc080e7          	jalr	-1092(ra) # 80001410 <uvmalloc>
    8000585c:	dea43c23          	sd	a0,-520(s0)
    80005860:	d939                	beqz	a0,800057b6 <exec+0x374>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005862:	e2843c03          	ld	s8,-472(s0)
    80005866:	e2042c83          	lw	s9,-480(s0)
    8000586a:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000586e:	f60b83e3          	beqz	s7,800057d4 <exec+0x392>
    80005872:	89de                	mv	s3,s7
    80005874:	4481                	li	s1,0
    80005876:	b319                	j	8000557c <exec+0x13a>

0000000080005878 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005878:	7179                	addi	sp,sp,-48
    8000587a:	f406                	sd	ra,40(sp)
    8000587c:	f022                	sd	s0,32(sp)
    8000587e:	ec26                	sd	s1,24(sp)
    80005880:	e84a                	sd	s2,16(sp)
    80005882:	1800                	addi	s0,sp,48
    80005884:	892e                	mv	s2,a1
    80005886:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005888:	fdc40593          	addi	a1,s0,-36
    8000588c:	ffffe097          	auipc	ra,0xffffe
    80005890:	a2e080e7          	jalr	-1490(ra) # 800032ba <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005894:	fdc42703          	lw	a4,-36(s0)
    80005898:	47bd                	li	a5,15
    8000589a:	02e7eb63          	bltu	a5,a4,800058d0 <argfd+0x58>
    8000589e:	ffffc097          	auipc	ra,0xffffc
    800058a2:	13a080e7          	jalr	314(ra) # 800019d8 <myproc>
    800058a6:	fdc42703          	lw	a4,-36(s0)
    800058aa:	0f870793          	addi	a5,a4,248
    800058ae:	078e                	slli	a5,a5,0x3
    800058b0:	953e                	add	a0,a0,a5
    800058b2:	651c                	ld	a5,8(a0)
    800058b4:	c385                	beqz	a5,800058d4 <argfd+0x5c>
    return -1;
  if(pfd)
    800058b6:	00090463          	beqz	s2,800058be <argfd+0x46>
    *pfd = fd;
    800058ba:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800058be:	4501                	li	a0,0
  if(pf)
    800058c0:	c091                	beqz	s1,800058c4 <argfd+0x4c>
    *pf = f;
    800058c2:	e09c                	sd	a5,0(s1)
}
    800058c4:	70a2                	ld	ra,40(sp)
    800058c6:	7402                	ld	s0,32(sp)
    800058c8:	64e2                	ld	s1,24(sp)
    800058ca:	6942                	ld	s2,16(sp)
    800058cc:	6145                	addi	sp,sp,48
    800058ce:	8082                	ret
    return -1;
    800058d0:	557d                	li	a0,-1
    800058d2:	bfcd                	j	800058c4 <argfd+0x4c>
    800058d4:	557d                	li	a0,-1
    800058d6:	b7fd                	j	800058c4 <argfd+0x4c>

00000000800058d8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800058d8:	1101                	addi	sp,sp,-32
    800058da:	ec06                	sd	ra,24(sp)
    800058dc:	e822                	sd	s0,16(sp)
    800058de:	e426                	sd	s1,8(sp)
    800058e0:	1000                	addi	s0,sp,32
    800058e2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800058e4:	ffffc097          	auipc	ra,0xffffc
    800058e8:	0f4080e7          	jalr	244(ra) # 800019d8 <myproc>
    800058ec:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800058ee:	7c850793          	addi	a5,a0,1992
    800058f2:	4501                	li	a0,0
    800058f4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800058f6:	6398                	ld	a4,0(a5)
    800058f8:	cb19                	beqz	a4,8000590e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800058fa:	2505                	addiw	a0,a0,1
    800058fc:	07a1                	addi	a5,a5,8
    800058fe:	fed51ce3          	bne	a0,a3,800058f6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005902:	557d                	li	a0,-1
}
    80005904:	60e2                	ld	ra,24(sp)
    80005906:	6442                	ld	s0,16(sp)
    80005908:	64a2                	ld	s1,8(sp)
    8000590a:	6105                	addi	sp,sp,32
    8000590c:	8082                	ret
      p->ofile[fd] = f;
    8000590e:	0f850793          	addi	a5,a0,248
    80005912:	078e                	slli	a5,a5,0x3
    80005914:	963e                	add	a2,a2,a5
    80005916:	e604                	sd	s1,8(a2)
      return fd;
    80005918:	b7f5                	j	80005904 <fdalloc+0x2c>

000000008000591a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000591a:	715d                	addi	sp,sp,-80
    8000591c:	e486                	sd	ra,72(sp)
    8000591e:	e0a2                	sd	s0,64(sp)
    80005920:	fc26                	sd	s1,56(sp)
    80005922:	f84a                	sd	s2,48(sp)
    80005924:	f44e                	sd	s3,40(sp)
    80005926:	f052                	sd	s4,32(sp)
    80005928:	ec56                	sd	s5,24(sp)
    8000592a:	e85a                	sd	s6,16(sp)
    8000592c:	0880                	addi	s0,sp,80
    8000592e:	8b2e                	mv	s6,a1
    80005930:	89b2                	mv	s3,a2
    80005932:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005934:	fb040593          	addi	a1,s0,-80
    80005938:	fffff097          	auipc	ra,0xfffff
    8000593c:	dc6080e7          	jalr	-570(ra) # 800046fe <nameiparent>
    80005940:	84aa                	mv	s1,a0
    80005942:	14050f63          	beqz	a0,80005aa0 <create+0x186>
    return 0;

  ilock(dp);
    80005946:	ffffe097          	auipc	ra,0xffffe
    8000594a:	5f0080e7          	jalr	1520(ra) # 80003f36 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000594e:	4601                	li	a2,0
    80005950:	fb040593          	addi	a1,s0,-80
    80005954:	8526                	mv	a0,s1
    80005956:	fffff097          	auipc	ra,0xfffff
    8000595a:	ac4080e7          	jalr	-1340(ra) # 8000441a <dirlookup>
    8000595e:	8aaa                	mv	s5,a0
    80005960:	c931                	beqz	a0,800059b4 <create+0x9a>
    iunlockput(dp);
    80005962:	8526                	mv	a0,s1
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	834080e7          	jalr	-1996(ra) # 80004198 <iunlockput>
    ilock(ip);
    8000596c:	8556                	mv	a0,s5
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	5c8080e7          	jalr	1480(ra) # 80003f36 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005976:	000b059b          	sext.w	a1,s6
    8000597a:	4789                	li	a5,2
    8000597c:	02f59563          	bne	a1,a5,800059a6 <create+0x8c>
    80005980:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffc0cc4>
    80005984:	37f9                	addiw	a5,a5,-2
    80005986:	17c2                	slli	a5,a5,0x30
    80005988:	93c1                	srli	a5,a5,0x30
    8000598a:	4705                	li	a4,1
    8000598c:	00f76d63          	bltu	a4,a5,800059a6 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005990:	8556                	mv	a0,s5
    80005992:	60a6                	ld	ra,72(sp)
    80005994:	6406                	ld	s0,64(sp)
    80005996:	74e2                	ld	s1,56(sp)
    80005998:	7942                	ld	s2,48(sp)
    8000599a:	79a2                	ld	s3,40(sp)
    8000599c:	7a02                	ld	s4,32(sp)
    8000599e:	6ae2                	ld	s5,24(sp)
    800059a0:	6b42                	ld	s6,16(sp)
    800059a2:	6161                	addi	sp,sp,80
    800059a4:	8082                	ret
    iunlockput(ip);
    800059a6:	8556                	mv	a0,s5
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	7f0080e7          	jalr	2032(ra) # 80004198 <iunlockput>
    return 0;
    800059b0:	4a81                	li	s5,0
    800059b2:	bff9                	j	80005990 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800059b4:	85da                	mv	a1,s6
    800059b6:	4088                	lw	a0,0(s1)
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	3e2080e7          	jalr	994(ra) # 80003d9a <ialloc>
    800059c0:	8a2a                	mv	s4,a0
    800059c2:	c539                	beqz	a0,80005a10 <create+0xf6>
  ilock(ip);
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	572080e7          	jalr	1394(ra) # 80003f36 <ilock>
  ip->major = major;
    800059cc:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800059d0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800059d4:	4905                	li	s2,1
    800059d6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800059da:	8552                	mv	a0,s4
    800059dc:	ffffe097          	auipc	ra,0xffffe
    800059e0:	490080e7          	jalr	1168(ra) # 80003e6c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800059e4:	000b059b          	sext.w	a1,s6
    800059e8:	03258b63          	beq	a1,s2,80005a1e <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800059ec:	004a2603          	lw	a2,4(s4)
    800059f0:	fb040593          	addi	a1,s0,-80
    800059f4:	8526                	mv	a0,s1
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	c38080e7          	jalr	-968(ra) # 8000462e <dirlink>
    800059fe:	06054f63          	bltz	a0,80005a7c <create+0x162>
  iunlockput(dp);
    80005a02:	8526                	mv	a0,s1
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	794080e7          	jalr	1940(ra) # 80004198 <iunlockput>
  return ip;
    80005a0c:	8ad2                	mv	s5,s4
    80005a0e:	b749                	j	80005990 <create+0x76>
    iunlockput(dp);
    80005a10:	8526                	mv	a0,s1
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	786080e7          	jalr	1926(ra) # 80004198 <iunlockput>
    return 0;
    80005a1a:	8ad2                	mv	s5,s4
    80005a1c:	bf95                	j	80005990 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005a1e:	004a2603          	lw	a2,4(s4)
    80005a22:	00003597          	auipc	a1,0x3
    80005a26:	ce658593          	addi	a1,a1,-794 # 80008708 <syscalls+0x2c8>
    80005a2a:	8552                	mv	a0,s4
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	c02080e7          	jalr	-1022(ra) # 8000462e <dirlink>
    80005a34:	04054463          	bltz	a0,80005a7c <create+0x162>
    80005a38:	40d0                	lw	a2,4(s1)
    80005a3a:	00003597          	auipc	a1,0x3
    80005a3e:	cd658593          	addi	a1,a1,-810 # 80008710 <syscalls+0x2d0>
    80005a42:	8552                	mv	a0,s4
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	bea080e7          	jalr	-1046(ra) # 8000462e <dirlink>
    80005a4c:	02054863          	bltz	a0,80005a7c <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a50:	004a2603          	lw	a2,4(s4)
    80005a54:	fb040593          	addi	a1,s0,-80
    80005a58:	8526                	mv	a0,s1
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	bd4080e7          	jalr	-1068(ra) # 8000462e <dirlink>
    80005a62:	00054d63          	bltz	a0,80005a7c <create+0x162>
    dp->nlink++;  // for ".."
    80005a66:	04a4d783          	lhu	a5,74(s1)
    80005a6a:	2785                	addiw	a5,a5,1
    80005a6c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a70:	8526                	mv	a0,s1
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	3fa080e7          	jalr	1018(ra) # 80003e6c <iupdate>
    80005a7a:	b761                	j	80005a02 <create+0xe8>
  ip->nlink = 0;
    80005a7c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005a80:	8552                	mv	a0,s4
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	3ea080e7          	jalr	1002(ra) # 80003e6c <iupdate>
  iunlockput(ip);
    80005a8a:	8552                	mv	a0,s4
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	70c080e7          	jalr	1804(ra) # 80004198 <iunlockput>
  iunlockput(dp);
    80005a94:	8526                	mv	a0,s1
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	702080e7          	jalr	1794(ra) # 80004198 <iunlockput>
  return 0;
    80005a9e:	bdcd                	j	80005990 <create+0x76>
    return 0;
    80005aa0:	8aaa                	mv	s5,a0
    80005aa2:	b5fd                	j	80005990 <create+0x76>

0000000080005aa4 <sys_dup>:
{
    80005aa4:	7179                	addi	sp,sp,-48
    80005aa6:	f406                	sd	ra,40(sp)
    80005aa8:	f022                	sd	s0,32(sp)
    80005aaa:	ec26                	sd	s1,24(sp)
    80005aac:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005aae:	fd840613          	addi	a2,s0,-40
    80005ab2:	4581                	li	a1,0
    80005ab4:	4501                	li	a0,0
    80005ab6:	00000097          	auipc	ra,0x0
    80005aba:	dc2080e7          	jalr	-574(ra) # 80005878 <argfd>
    return -1;
    80005abe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005ac0:	02054363          	bltz	a0,80005ae6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005ac4:	fd843503          	ld	a0,-40(s0)
    80005ac8:	00000097          	auipc	ra,0x0
    80005acc:	e10080e7          	jalr	-496(ra) # 800058d8 <fdalloc>
    80005ad0:	84aa                	mv	s1,a0
    return -1;
    80005ad2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005ad4:	00054963          	bltz	a0,80005ae6 <sys_dup+0x42>
  filedup(f);
    80005ad8:	fd843503          	ld	a0,-40(s0)
    80005adc:	fffff097          	auipc	ra,0xfffff
    80005ae0:	29a080e7          	jalr	666(ra) # 80004d76 <filedup>
  return fd;
    80005ae4:	87a6                	mv	a5,s1
}
    80005ae6:	853e                	mv	a0,a5
    80005ae8:	70a2                	ld	ra,40(sp)
    80005aea:	7402                	ld	s0,32(sp)
    80005aec:	64e2                	ld	s1,24(sp)
    80005aee:	6145                	addi	sp,sp,48
    80005af0:	8082                	ret

0000000080005af2 <sys_read>:
{
    80005af2:	7179                	addi	sp,sp,-48
    80005af4:	f406                	sd	ra,40(sp)
    80005af6:	f022                	sd	s0,32(sp)
    80005af8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005afa:	fd840593          	addi	a1,s0,-40
    80005afe:	4505                	li	a0,1
    80005b00:	ffffd097          	auipc	ra,0xffffd
    80005b04:	7da080e7          	jalr	2010(ra) # 800032da <argaddr>
  argint(2, &n);
    80005b08:	fe440593          	addi	a1,s0,-28
    80005b0c:	4509                	li	a0,2
    80005b0e:	ffffd097          	auipc	ra,0xffffd
    80005b12:	7ac080e7          	jalr	1964(ra) # 800032ba <argint>
  if(argfd(0, 0, &f) < 0)
    80005b16:	fe840613          	addi	a2,s0,-24
    80005b1a:	4581                	li	a1,0
    80005b1c:	4501                	li	a0,0
    80005b1e:	00000097          	auipc	ra,0x0
    80005b22:	d5a080e7          	jalr	-678(ra) # 80005878 <argfd>
    80005b26:	87aa                	mv	a5,a0
    return -1;
    80005b28:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b2a:	0007cc63          	bltz	a5,80005b42 <sys_read+0x50>
  return fileread(f, p, n);
    80005b2e:	fe442603          	lw	a2,-28(s0)
    80005b32:	fd843583          	ld	a1,-40(s0)
    80005b36:	fe843503          	ld	a0,-24(s0)
    80005b3a:	fffff097          	auipc	ra,0xfffff
    80005b3e:	3c8080e7          	jalr	968(ra) # 80004f02 <fileread>
}
    80005b42:	70a2                	ld	ra,40(sp)
    80005b44:	7402                	ld	s0,32(sp)
    80005b46:	6145                	addi	sp,sp,48
    80005b48:	8082                	ret

0000000080005b4a <sys_write>:
{
    80005b4a:	7179                	addi	sp,sp,-48
    80005b4c:	f406                	sd	ra,40(sp)
    80005b4e:	f022                	sd	s0,32(sp)
    80005b50:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005b52:	fd840593          	addi	a1,s0,-40
    80005b56:	4505                	li	a0,1
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	782080e7          	jalr	1922(ra) # 800032da <argaddr>
  argint(2, &n);
    80005b60:	fe440593          	addi	a1,s0,-28
    80005b64:	4509                	li	a0,2
    80005b66:	ffffd097          	auipc	ra,0xffffd
    80005b6a:	754080e7          	jalr	1876(ra) # 800032ba <argint>
  if(argfd(0, 0, &f) < 0)
    80005b6e:	fe840613          	addi	a2,s0,-24
    80005b72:	4581                	li	a1,0
    80005b74:	4501                	li	a0,0
    80005b76:	00000097          	auipc	ra,0x0
    80005b7a:	d02080e7          	jalr	-766(ra) # 80005878 <argfd>
    80005b7e:	87aa                	mv	a5,a0
    return -1;
    80005b80:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b82:	0007cc63          	bltz	a5,80005b9a <sys_write+0x50>
  return filewrite(f, p, n);
    80005b86:	fe442603          	lw	a2,-28(s0)
    80005b8a:	fd843583          	ld	a1,-40(s0)
    80005b8e:	fe843503          	ld	a0,-24(s0)
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	432080e7          	jalr	1074(ra) # 80004fc4 <filewrite>
}
    80005b9a:	70a2                	ld	ra,40(sp)
    80005b9c:	7402                	ld	s0,32(sp)
    80005b9e:	6145                	addi	sp,sp,48
    80005ba0:	8082                	ret

0000000080005ba2 <sys_close>:
{
    80005ba2:	1101                	addi	sp,sp,-32
    80005ba4:	ec06                	sd	ra,24(sp)
    80005ba6:	e822                	sd	s0,16(sp)
    80005ba8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005baa:	fe040613          	addi	a2,s0,-32
    80005bae:	fec40593          	addi	a1,s0,-20
    80005bb2:	4501                	li	a0,0
    80005bb4:	00000097          	auipc	ra,0x0
    80005bb8:	cc4080e7          	jalr	-828(ra) # 80005878 <argfd>
    return -1;
    80005bbc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005bbe:	02054563          	bltz	a0,80005be8 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005bc2:	ffffc097          	auipc	ra,0xffffc
    80005bc6:	e16080e7          	jalr	-490(ra) # 800019d8 <myproc>
    80005bca:	fec42783          	lw	a5,-20(s0)
    80005bce:	0f878793          	addi	a5,a5,248
    80005bd2:	078e                	slli	a5,a5,0x3
    80005bd4:	97aa                	add	a5,a5,a0
    80005bd6:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005bda:	fe043503          	ld	a0,-32(s0)
    80005bde:	fffff097          	auipc	ra,0xfffff
    80005be2:	1ea080e7          	jalr	490(ra) # 80004dc8 <fileclose>
  return 0;
    80005be6:	4781                	li	a5,0
}
    80005be8:	853e                	mv	a0,a5
    80005bea:	60e2                	ld	ra,24(sp)
    80005bec:	6442                	ld	s0,16(sp)
    80005bee:	6105                	addi	sp,sp,32
    80005bf0:	8082                	ret

0000000080005bf2 <sys_fstat>:
{
    80005bf2:	1101                	addi	sp,sp,-32
    80005bf4:	ec06                	sd	ra,24(sp)
    80005bf6:	e822                	sd	s0,16(sp)
    80005bf8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005bfa:	fe040593          	addi	a1,s0,-32
    80005bfe:	4505                	li	a0,1
    80005c00:	ffffd097          	auipc	ra,0xffffd
    80005c04:	6da080e7          	jalr	1754(ra) # 800032da <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005c08:	fe840613          	addi	a2,s0,-24
    80005c0c:	4581                	li	a1,0
    80005c0e:	4501                	li	a0,0
    80005c10:	00000097          	auipc	ra,0x0
    80005c14:	c68080e7          	jalr	-920(ra) # 80005878 <argfd>
    80005c18:	87aa                	mv	a5,a0
    return -1;
    80005c1a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c1c:	0007ca63          	bltz	a5,80005c30 <sys_fstat+0x3e>
  return filestat(f, st);
    80005c20:	fe043583          	ld	a1,-32(s0)
    80005c24:	fe843503          	ld	a0,-24(s0)
    80005c28:	fffff097          	auipc	ra,0xfffff
    80005c2c:	268080e7          	jalr	616(ra) # 80004e90 <filestat>
}
    80005c30:	60e2                	ld	ra,24(sp)
    80005c32:	6442                	ld	s0,16(sp)
    80005c34:	6105                	addi	sp,sp,32
    80005c36:	8082                	ret

0000000080005c38 <sys_link>:
{
    80005c38:	7169                	addi	sp,sp,-304
    80005c3a:	f606                	sd	ra,296(sp)
    80005c3c:	f222                	sd	s0,288(sp)
    80005c3e:	ee26                	sd	s1,280(sp)
    80005c40:	ea4a                	sd	s2,272(sp)
    80005c42:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c44:	08000613          	li	a2,128
    80005c48:	ed040593          	addi	a1,s0,-304
    80005c4c:	4501                	li	a0,0
    80005c4e:	ffffd097          	auipc	ra,0xffffd
    80005c52:	6ac080e7          	jalr	1708(ra) # 800032fa <argstr>
    return -1;
    80005c56:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c58:	10054e63          	bltz	a0,80005d74 <sys_link+0x13c>
    80005c5c:	08000613          	li	a2,128
    80005c60:	f5040593          	addi	a1,s0,-176
    80005c64:	4505                	li	a0,1
    80005c66:	ffffd097          	auipc	ra,0xffffd
    80005c6a:	694080e7          	jalr	1684(ra) # 800032fa <argstr>
    return -1;
    80005c6e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c70:	10054263          	bltz	a0,80005d74 <sys_link+0x13c>
  begin_op();
    80005c74:	fffff097          	auipc	ra,0xfffff
    80005c78:	c88080e7          	jalr	-888(ra) # 800048fc <begin_op>
  if((ip = namei(old)) == 0){
    80005c7c:	ed040513          	addi	a0,s0,-304
    80005c80:	fffff097          	auipc	ra,0xfffff
    80005c84:	a60080e7          	jalr	-1440(ra) # 800046e0 <namei>
    80005c88:	84aa                	mv	s1,a0
    80005c8a:	c551                	beqz	a0,80005d16 <sys_link+0xde>
  ilock(ip);
    80005c8c:	ffffe097          	auipc	ra,0xffffe
    80005c90:	2aa080e7          	jalr	682(ra) # 80003f36 <ilock>
  if(ip->type == T_DIR){
    80005c94:	04449703          	lh	a4,68(s1)
    80005c98:	4785                	li	a5,1
    80005c9a:	08f70463          	beq	a4,a5,80005d22 <sys_link+0xea>
  ip->nlink++;
    80005c9e:	04a4d783          	lhu	a5,74(s1)
    80005ca2:	2785                	addiw	a5,a5,1
    80005ca4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ca8:	8526                	mv	a0,s1
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	1c2080e7          	jalr	450(ra) # 80003e6c <iupdate>
  iunlock(ip);
    80005cb2:	8526                	mv	a0,s1
    80005cb4:	ffffe097          	auipc	ra,0xffffe
    80005cb8:	344080e7          	jalr	836(ra) # 80003ff8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005cbc:	fd040593          	addi	a1,s0,-48
    80005cc0:	f5040513          	addi	a0,s0,-176
    80005cc4:	fffff097          	auipc	ra,0xfffff
    80005cc8:	a3a080e7          	jalr	-1478(ra) # 800046fe <nameiparent>
    80005ccc:	892a                	mv	s2,a0
    80005cce:	c935                	beqz	a0,80005d42 <sys_link+0x10a>
  ilock(dp);
    80005cd0:	ffffe097          	auipc	ra,0xffffe
    80005cd4:	266080e7          	jalr	614(ra) # 80003f36 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005cd8:	00092703          	lw	a4,0(s2)
    80005cdc:	409c                	lw	a5,0(s1)
    80005cde:	04f71d63          	bne	a4,a5,80005d38 <sys_link+0x100>
    80005ce2:	40d0                	lw	a2,4(s1)
    80005ce4:	fd040593          	addi	a1,s0,-48
    80005ce8:	854a                	mv	a0,s2
    80005cea:	fffff097          	auipc	ra,0xfffff
    80005cee:	944080e7          	jalr	-1724(ra) # 8000462e <dirlink>
    80005cf2:	04054363          	bltz	a0,80005d38 <sys_link+0x100>
  iunlockput(dp);
    80005cf6:	854a                	mv	a0,s2
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	4a0080e7          	jalr	1184(ra) # 80004198 <iunlockput>
  iput(ip);
    80005d00:	8526                	mv	a0,s1
    80005d02:	ffffe097          	auipc	ra,0xffffe
    80005d06:	3ee080e7          	jalr	1006(ra) # 800040f0 <iput>
  end_op();
    80005d0a:	fffff097          	auipc	ra,0xfffff
    80005d0e:	c72080e7          	jalr	-910(ra) # 8000497c <end_op>
  return 0;
    80005d12:	4781                	li	a5,0
    80005d14:	a085                	j	80005d74 <sys_link+0x13c>
    end_op();
    80005d16:	fffff097          	auipc	ra,0xfffff
    80005d1a:	c66080e7          	jalr	-922(ra) # 8000497c <end_op>
    return -1;
    80005d1e:	57fd                	li	a5,-1
    80005d20:	a891                	j	80005d74 <sys_link+0x13c>
    iunlockput(ip);
    80005d22:	8526                	mv	a0,s1
    80005d24:	ffffe097          	auipc	ra,0xffffe
    80005d28:	474080e7          	jalr	1140(ra) # 80004198 <iunlockput>
    end_op();
    80005d2c:	fffff097          	auipc	ra,0xfffff
    80005d30:	c50080e7          	jalr	-944(ra) # 8000497c <end_op>
    return -1;
    80005d34:	57fd                	li	a5,-1
    80005d36:	a83d                	j	80005d74 <sys_link+0x13c>
    iunlockput(dp);
    80005d38:	854a                	mv	a0,s2
    80005d3a:	ffffe097          	auipc	ra,0xffffe
    80005d3e:	45e080e7          	jalr	1118(ra) # 80004198 <iunlockput>
  ilock(ip);
    80005d42:	8526                	mv	a0,s1
    80005d44:	ffffe097          	auipc	ra,0xffffe
    80005d48:	1f2080e7          	jalr	498(ra) # 80003f36 <ilock>
  ip->nlink--;
    80005d4c:	04a4d783          	lhu	a5,74(s1)
    80005d50:	37fd                	addiw	a5,a5,-1
    80005d52:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d56:	8526                	mv	a0,s1
    80005d58:	ffffe097          	auipc	ra,0xffffe
    80005d5c:	114080e7          	jalr	276(ra) # 80003e6c <iupdate>
  iunlockput(ip);
    80005d60:	8526                	mv	a0,s1
    80005d62:	ffffe097          	auipc	ra,0xffffe
    80005d66:	436080e7          	jalr	1078(ra) # 80004198 <iunlockput>
  end_op();
    80005d6a:	fffff097          	auipc	ra,0xfffff
    80005d6e:	c12080e7          	jalr	-1006(ra) # 8000497c <end_op>
  return -1;
    80005d72:	57fd                	li	a5,-1
}
    80005d74:	853e                	mv	a0,a5
    80005d76:	70b2                	ld	ra,296(sp)
    80005d78:	7412                	ld	s0,288(sp)
    80005d7a:	64f2                	ld	s1,280(sp)
    80005d7c:	6952                	ld	s2,272(sp)
    80005d7e:	6155                	addi	sp,sp,304
    80005d80:	8082                	ret

0000000080005d82 <sys_unlink>:
{
    80005d82:	7151                	addi	sp,sp,-240
    80005d84:	f586                	sd	ra,232(sp)
    80005d86:	f1a2                	sd	s0,224(sp)
    80005d88:	eda6                	sd	s1,216(sp)
    80005d8a:	e9ca                	sd	s2,208(sp)
    80005d8c:	e5ce                	sd	s3,200(sp)
    80005d8e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005d90:	08000613          	li	a2,128
    80005d94:	f3040593          	addi	a1,s0,-208
    80005d98:	4501                	li	a0,0
    80005d9a:	ffffd097          	auipc	ra,0xffffd
    80005d9e:	560080e7          	jalr	1376(ra) # 800032fa <argstr>
    80005da2:	18054163          	bltz	a0,80005f24 <sys_unlink+0x1a2>
  begin_op();
    80005da6:	fffff097          	auipc	ra,0xfffff
    80005daa:	b56080e7          	jalr	-1194(ra) # 800048fc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005dae:	fb040593          	addi	a1,s0,-80
    80005db2:	f3040513          	addi	a0,s0,-208
    80005db6:	fffff097          	auipc	ra,0xfffff
    80005dba:	948080e7          	jalr	-1720(ra) # 800046fe <nameiparent>
    80005dbe:	84aa                	mv	s1,a0
    80005dc0:	c979                	beqz	a0,80005e96 <sys_unlink+0x114>
  ilock(dp);
    80005dc2:	ffffe097          	auipc	ra,0xffffe
    80005dc6:	174080e7          	jalr	372(ra) # 80003f36 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005dca:	00003597          	auipc	a1,0x3
    80005dce:	93e58593          	addi	a1,a1,-1730 # 80008708 <syscalls+0x2c8>
    80005dd2:	fb040513          	addi	a0,s0,-80
    80005dd6:	ffffe097          	auipc	ra,0xffffe
    80005dda:	62a080e7          	jalr	1578(ra) # 80004400 <namecmp>
    80005dde:	14050a63          	beqz	a0,80005f32 <sys_unlink+0x1b0>
    80005de2:	00003597          	auipc	a1,0x3
    80005de6:	92e58593          	addi	a1,a1,-1746 # 80008710 <syscalls+0x2d0>
    80005dea:	fb040513          	addi	a0,s0,-80
    80005dee:	ffffe097          	auipc	ra,0xffffe
    80005df2:	612080e7          	jalr	1554(ra) # 80004400 <namecmp>
    80005df6:	12050e63          	beqz	a0,80005f32 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005dfa:	f2c40613          	addi	a2,s0,-212
    80005dfe:	fb040593          	addi	a1,s0,-80
    80005e02:	8526                	mv	a0,s1
    80005e04:	ffffe097          	auipc	ra,0xffffe
    80005e08:	616080e7          	jalr	1558(ra) # 8000441a <dirlookup>
    80005e0c:	892a                	mv	s2,a0
    80005e0e:	12050263          	beqz	a0,80005f32 <sys_unlink+0x1b0>
  ilock(ip);
    80005e12:	ffffe097          	auipc	ra,0xffffe
    80005e16:	124080e7          	jalr	292(ra) # 80003f36 <ilock>
  if(ip->nlink < 1)
    80005e1a:	04a91783          	lh	a5,74(s2)
    80005e1e:	08f05263          	blez	a5,80005ea2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005e22:	04491703          	lh	a4,68(s2)
    80005e26:	4785                	li	a5,1
    80005e28:	08f70563          	beq	a4,a5,80005eb2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005e2c:	4641                	li	a2,16
    80005e2e:	4581                	li	a1,0
    80005e30:	fc040513          	addi	a0,s0,-64
    80005e34:	ffffb097          	auipc	ra,0xffffb
    80005e38:	e9e080e7          	jalr	-354(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e3c:	4741                	li	a4,16
    80005e3e:	f2c42683          	lw	a3,-212(s0)
    80005e42:	fc040613          	addi	a2,s0,-64
    80005e46:	4581                	li	a1,0
    80005e48:	8526                	mv	a0,s1
    80005e4a:	ffffe097          	auipc	ra,0xffffe
    80005e4e:	498080e7          	jalr	1176(ra) # 800042e2 <writei>
    80005e52:	47c1                	li	a5,16
    80005e54:	0af51563          	bne	a0,a5,80005efe <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005e58:	04491703          	lh	a4,68(s2)
    80005e5c:	4785                	li	a5,1
    80005e5e:	0af70863          	beq	a4,a5,80005f0e <sys_unlink+0x18c>
  iunlockput(dp);
    80005e62:	8526                	mv	a0,s1
    80005e64:	ffffe097          	auipc	ra,0xffffe
    80005e68:	334080e7          	jalr	820(ra) # 80004198 <iunlockput>
  ip->nlink--;
    80005e6c:	04a95783          	lhu	a5,74(s2)
    80005e70:	37fd                	addiw	a5,a5,-1
    80005e72:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005e76:	854a                	mv	a0,s2
    80005e78:	ffffe097          	auipc	ra,0xffffe
    80005e7c:	ff4080e7          	jalr	-12(ra) # 80003e6c <iupdate>
  iunlockput(ip);
    80005e80:	854a                	mv	a0,s2
    80005e82:	ffffe097          	auipc	ra,0xffffe
    80005e86:	316080e7          	jalr	790(ra) # 80004198 <iunlockput>
  end_op();
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	af2080e7          	jalr	-1294(ra) # 8000497c <end_op>
  return 0;
    80005e92:	4501                	li	a0,0
    80005e94:	a84d                	j	80005f46 <sys_unlink+0x1c4>
    end_op();
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	ae6080e7          	jalr	-1306(ra) # 8000497c <end_op>
    return -1;
    80005e9e:	557d                	li	a0,-1
    80005ea0:	a05d                	j	80005f46 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005ea2:	00003517          	auipc	a0,0x3
    80005ea6:	87650513          	addi	a0,a0,-1930 # 80008718 <syscalls+0x2d8>
    80005eaa:	ffffa097          	auipc	ra,0xffffa
    80005eae:	694080e7          	jalr	1684(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005eb2:	04c92703          	lw	a4,76(s2)
    80005eb6:	02000793          	li	a5,32
    80005eba:	f6e7f9e3          	bgeu	a5,a4,80005e2c <sys_unlink+0xaa>
    80005ebe:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ec2:	4741                	li	a4,16
    80005ec4:	86ce                	mv	a3,s3
    80005ec6:	f1840613          	addi	a2,s0,-232
    80005eca:	4581                	li	a1,0
    80005ecc:	854a                	mv	a0,s2
    80005ece:	ffffe097          	auipc	ra,0xffffe
    80005ed2:	31c080e7          	jalr	796(ra) # 800041ea <readi>
    80005ed6:	47c1                	li	a5,16
    80005ed8:	00f51b63          	bne	a0,a5,80005eee <sys_unlink+0x16c>
    if(de.inum != 0)
    80005edc:	f1845783          	lhu	a5,-232(s0)
    80005ee0:	e7a1                	bnez	a5,80005f28 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ee2:	29c1                	addiw	s3,s3,16
    80005ee4:	04c92783          	lw	a5,76(s2)
    80005ee8:	fcf9ede3          	bltu	s3,a5,80005ec2 <sys_unlink+0x140>
    80005eec:	b781                	j	80005e2c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005eee:	00003517          	auipc	a0,0x3
    80005ef2:	84250513          	addi	a0,a0,-1982 # 80008730 <syscalls+0x2f0>
    80005ef6:	ffffa097          	auipc	ra,0xffffa
    80005efa:	648080e7          	jalr	1608(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005efe:	00003517          	auipc	a0,0x3
    80005f02:	84a50513          	addi	a0,a0,-1974 # 80008748 <syscalls+0x308>
    80005f06:	ffffa097          	auipc	ra,0xffffa
    80005f0a:	638080e7          	jalr	1592(ra) # 8000053e <panic>
    dp->nlink--;
    80005f0e:	04a4d783          	lhu	a5,74(s1)
    80005f12:	37fd                	addiw	a5,a5,-1
    80005f14:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005f18:	8526                	mv	a0,s1
    80005f1a:	ffffe097          	auipc	ra,0xffffe
    80005f1e:	f52080e7          	jalr	-174(ra) # 80003e6c <iupdate>
    80005f22:	b781                	j	80005e62 <sys_unlink+0xe0>
    return -1;
    80005f24:	557d                	li	a0,-1
    80005f26:	a005                	j	80005f46 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005f28:	854a                	mv	a0,s2
    80005f2a:	ffffe097          	auipc	ra,0xffffe
    80005f2e:	26e080e7          	jalr	622(ra) # 80004198 <iunlockput>
  iunlockput(dp);
    80005f32:	8526                	mv	a0,s1
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	264080e7          	jalr	612(ra) # 80004198 <iunlockput>
  end_op();
    80005f3c:	fffff097          	auipc	ra,0xfffff
    80005f40:	a40080e7          	jalr	-1472(ra) # 8000497c <end_op>
  return -1;
    80005f44:	557d                	li	a0,-1
}
    80005f46:	70ae                	ld	ra,232(sp)
    80005f48:	740e                	ld	s0,224(sp)
    80005f4a:	64ee                	ld	s1,216(sp)
    80005f4c:	694e                	ld	s2,208(sp)
    80005f4e:	69ae                	ld	s3,200(sp)
    80005f50:	616d                	addi	sp,sp,240
    80005f52:	8082                	ret

0000000080005f54 <sys_open>:

uint64
sys_open(void)
{
    80005f54:	7131                	addi	sp,sp,-192
    80005f56:	fd06                	sd	ra,184(sp)
    80005f58:	f922                	sd	s0,176(sp)
    80005f5a:	f526                	sd	s1,168(sp)
    80005f5c:	f14a                	sd	s2,160(sp)
    80005f5e:	ed4e                	sd	s3,152(sp)
    80005f60:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005f62:	f4c40593          	addi	a1,s0,-180
    80005f66:	4505                	li	a0,1
    80005f68:	ffffd097          	auipc	ra,0xffffd
    80005f6c:	352080e7          	jalr	850(ra) # 800032ba <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f70:	08000613          	li	a2,128
    80005f74:	f5040593          	addi	a1,s0,-176
    80005f78:	4501                	li	a0,0
    80005f7a:	ffffd097          	auipc	ra,0xffffd
    80005f7e:	380080e7          	jalr	896(ra) # 800032fa <argstr>
    80005f82:	87aa                	mv	a5,a0
    return -1;
    80005f84:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f86:	0a07c963          	bltz	a5,80006038 <sys_open+0xe4>

  begin_op();
    80005f8a:	fffff097          	auipc	ra,0xfffff
    80005f8e:	972080e7          	jalr	-1678(ra) # 800048fc <begin_op>

  if(omode & O_CREATE){
    80005f92:	f4c42783          	lw	a5,-180(s0)
    80005f96:	2007f793          	andi	a5,a5,512
    80005f9a:	cfc5                	beqz	a5,80006052 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005f9c:	4681                	li	a3,0
    80005f9e:	4601                	li	a2,0
    80005fa0:	4589                	li	a1,2
    80005fa2:	f5040513          	addi	a0,s0,-176
    80005fa6:	00000097          	auipc	ra,0x0
    80005faa:	974080e7          	jalr	-1676(ra) # 8000591a <create>
    80005fae:	84aa                	mv	s1,a0
    if(ip == 0){
    80005fb0:	c959                	beqz	a0,80006046 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005fb2:	04449703          	lh	a4,68(s1)
    80005fb6:	478d                	li	a5,3
    80005fb8:	00f71763          	bne	a4,a5,80005fc6 <sys_open+0x72>
    80005fbc:	0464d703          	lhu	a4,70(s1)
    80005fc0:	47a5                	li	a5,9
    80005fc2:	0ce7ed63          	bltu	a5,a4,8000609c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005fc6:	fffff097          	auipc	ra,0xfffff
    80005fca:	d46080e7          	jalr	-698(ra) # 80004d0c <filealloc>
    80005fce:	89aa                	mv	s3,a0
    80005fd0:	10050363          	beqz	a0,800060d6 <sys_open+0x182>
    80005fd4:	00000097          	auipc	ra,0x0
    80005fd8:	904080e7          	jalr	-1788(ra) # 800058d8 <fdalloc>
    80005fdc:	892a                	mv	s2,a0
    80005fde:	0e054763          	bltz	a0,800060cc <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005fe2:	04449703          	lh	a4,68(s1)
    80005fe6:	478d                	li	a5,3
    80005fe8:	0cf70563          	beq	a4,a5,800060b2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005fec:	4789                	li	a5,2
    80005fee:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ff2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ff6:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ffa:	f4c42783          	lw	a5,-180(s0)
    80005ffe:	0017c713          	xori	a4,a5,1
    80006002:	8b05                	andi	a4,a4,1
    80006004:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006008:	0037f713          	andi	a4,a5,3
    8000600c:	00e03733          	snez	a4,a4
    80006010:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006014:	4007f793          	andi	a5,a5,1024
    80006018:	c791                	beqz	a5,80006024 <sys_open+0xd0>
    8000601a:	04449703          	lh	a4,68(s1)
    8000601e:	4789                	li	a5,2
    80006020:	0af70063          	beq	a4,a5,800060c0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006024:	8526                	mv	a0,s1
    80006026:	ffffe097          	auipc	ra,0xffffe
    8000602a:	fd2080e7          	jalr	-46(ra) # 80003ff8 <iunlock>
  end_op();
    8000602e:	fffff097          	auipc	ra,0xfffff
    80006032:	94e080e7          	jalr	-1714(ra) # 8000497c <end_op>

  return fd;
    80006036:	854a                	mv	a0,s2
}
    80006038:	70ea                	ld	ra,184(sp)
    8000603a:	744a                	ld	s0,176(sp)
    8000603c:	74aa                	ld	s1,168(sp)
    8000603e:	790a                	ld	s2,160(sp)
    80006040:	69ea                	ld	s3,152(sp)
    80006042:	6129                	addi	sp,sp,192
    80006044:	8082                	ret
      end_op();
    80006046:	fffff097          	auipc	ra,0xfffff
    8000604a:	936080e7          	jalr	-1738(ra) # 8000497c <end_op>
      return -1;
    8000604e:	557d                	li	a0,-1
    80006050:	b7e5                	j	80006038 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006052:	f5040513          	addi	a0,s0,-176
    80006056:	ffffe097          	auipc	ra,0xffffe
    8000605a:	68a080e7          	jalr	1674(ra) # 800046e0 <namei>
    8000605e:	84aa                	mv	s1,a0
    80006060:	c905                	beqz	a0,80006090 <sys_open+0x13c>
    ilock(ip);
    80006062:	ffffe097          	auipc	ra,0xffffe
    80006066:	ed4080e7          	jalr	-300(ra) # 80003f36 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000606a:	04449703          	lh	a4,68(s1)
    8000606e:	4785                	li	a5,1
    80006070:	f4f711e3          	bne	a4,a5,80005fb2 <sys_open+0x5e>
    80006074:	f4c42783          	lw	a5,-180(s0)
    80006078:	d7b9                	beqz	a5,80005fc6 <sys_open+0x72>
      iunlockput(ip);
    8000607a:	8526                	mv	a0,s1
    8000607c:	ffffe097          	auipc	ra,0xffffe
    80006080:	11c080e7          	jalr	284(ra) # 80004198 <iunlockput>
      end_op();
    80006084:	fffff097          	auipc	ra,0xfffff
    80006088:	8f8080e7          	jalr	-1800(ra) # 8000497c <end_op>
      return -1;
    8000608c:	557d                	li	a0,-1
    8000608e:	b76d                	j	80006038 <sys_open+0xe4>
      end_op();
    80006090:	fffff097          	auipc	ra,0xfffff
    80006094:	8ec080e7          	jalr	-1812(ra) # 8000497c <end_op>
      return -1;
    80006098:	557d                	li	a0,-1
    8000609a:	bf79                	j	80006038 <sys_open+0xe4>
    iunlockput(ip);
    8000609c:	8526                	mv	a0,s1
    8000609e:	ffffe097          	auipc	ra,0xffffe
    800060a2:	0fa080e7          	jalr	250(ra) # 80004198 <iunlockput>
    end_op();
    800060a6:	fffff097          	auipc	ra,0xfffff
    800060aa:	8d6080e7          	jalr	-1834(ra) # 8000497c <end_op>
    return -1;
    800060ae:	557d                	li	a0,-1
    800060b0:	b761                	j	80006038 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800060b2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800060b6:	04649783          	lh	a5,70(s1)
    800060ba:	02f99223          	sh	a5,36(s3)
    800060be:	bf25                	j	80005ff6 <sys_open+0xa2>
    itrunc(ip);
    800060c0:	8526                	mv	a0,s1
    800060c2:	ffffe097          	auipc	ra,0xffffe
    800060c6:	f82080e7          	jalr	-126(ra) # 80004044 <itrunc>
    800060ca:	bfa9                	j	80006024 <sys_open+0xd0>
      fileclose(f);
    800060cc:	854e                	mv	a0,s3
    800060ce:	fffff097          	auipc	ra,0xfffff
    800060d2:	cfa080e7          	jalr	-774(ra) # 80004dc8 <fileclose>
    iunlockput(ip);
    800060d6:	8526                	mv	a0,s1
    800060d8:	ffffe097          	auipc	ra,0xffffe
    800060dc:	0c0080e7          	jalr	192(ra) # 80004198 <iunlockput>
    end_op();
    800060e0:	fffff097          	auipc	ra,0xfffff
    800060e4:	89c080e7          	jalr	-1892(ra) # 8000497c <end_op>
    return -1;
    800060e8:	557d                	li	a0,-1
    800060ea:	b7b9                	j	80006038 <sys_open+0xe4>

00000000800060ec <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800060ec:	7175                	addi	sp,sp,-144
    800060ee:	e506                	sd	ra,136(sp)
    800060f0:	e122                	sd	s0,128(sp)
    800060f2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800060f4:	fffff097          	auipc	ra,0xfffff
    800060f8:	808080e7          	jalr	-2040(ra) # 800048fc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800060fc:	08000613          	li	a2,128
    80006100:	f7040593          	addi	a1,s0,-144
    80006104:	4501                	li	a0,0
    80006106:	ffffd097          	auipc	ra,0xffffd
    8000610a:	1f4080e7          	jalr	500(ra) # 800032fa <argstr>
    8000610e:	02054963          	bltz	a0,80006140 <sys_mkdir+0x54>
    80006112:	4681                	li	a3,0
    80006114:	4601                	li	a2,0
    80006116:	4585                	li	a1,1
    80006118:	f7040513          	addi	a0,s0,-144
    8000611c:	fffff097          	auipc	ra,0xfffff
    80006120:	7fe080e7          	jalr	2046(ra) # 8000591a <create>
    80006124:	cd11                	beqz	a0,80006140 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006126:	ffffe097          	auipc	ra,0xffffe
    8000612a:	072080e7          	jalr	114(ra) # 80004198 <iunlockput>
  end_op();
    8000612e:	fffff097          	auipc	ra,0xfffff
    80006132:	84e080e7          	jalr	-1970(ra) # 8000497c <end_op>
  return 0;
    80006136:	4501                	li	a0,0
}
    80006138:	60aa                	ld	ra,136(sp)
    8000613a:	640a                	ld	s0,128(sp)
    8000613c:	6149                	addi	sp,sp,144
    8000613e:	8082                	ret
    end_op();
    80006140:	fffff097          	auipc	ra,0xfffff
    80006144:	83c080e7          	jalr	-1988(ra) # 8000497c <end_op>
    return -1;
    80006148:	557d                	li	a0,-1
    8000614a:	b7fd                	j	80006138 <sys_mkdir+0x4c>

000000008000614c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000614c:	7135                	addi	sp,sp,-160
    8000614e:	ed06                	sd	ra,152(sp)
    80006150:	e922                	sd	s0,144(sp)
    80006152:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006154:	ffffe097          	auipc	ra,0xffffe
    80006158:	7a8080e7          	jalr	1960(ra) # 800048fc <begin_op>
  argint(1, &major);
    8000615c:	f6c40593          	addi	a1,s0,-148
    80006160:	4505                	li	a0,1
    80006162:	ffffd097          	auipc	ra,0xffffd
    80006166:	158080e7          	jalr	344(ra) # 800032ba <argint>
  argint(2, &minor);
    8000616a:	f6840593          	addi	a1,s0,-152
    8000616e:	4509                	li	a0,2
    80006170:	ffffd097          	auipc	ra,0xffffd
    80006174:	14a080e7          	jalr	330(ra) # 800032ba <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006178:	08000613          	li	a2,128
    8000617c:	f7040593          	addi	a1,s0,-144
    80006180:	4501                	li	a0,0
    80006182:	ffffd097          	auipc	ra,0xffffd
    80006186:	178080e7          	jalr	376(ra) # 800032fa <argstr>
    8000618a:	02054b63          	bltz	a0,800061c0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000618e:	f6841683          	lh	a3,-152(s0)
    80006192:	f6c41603          	lh	a2,-148(s0)
    80006196:	458d                	li	a1,3
    80006198:	f7040513          	addi	a0,s0,-144
    8000619c:	fffff097          	auipc	ra,0xfffff
    800061a0:	77e080e7          	jalr	1918(ra) # 8000591a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800061a4:	cd11                	beqz	a0,800061c0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800061a6:	ffffe097          	auipc	ra,0xffffe
    800061aa:	ff2080e7          	jalr	-14(ra) # 80004198 <iunlockput>
  end_op();
    800061ae:	ffffe097          	auipc	ra,0xffffe
    800061b2:	7ce080e7          	jalr	1998(ra) # 8000497c <end_op>
  return 0;
    800061b6:	4501                	li	a0,0
}
    800061b8:	60ea                	ld	ra,152(sp)
    800061ba:	644a                	ld	s0,144(sp)
    800061bc:	610d                	addi	sp,sp,160
    800061be:	8082                	ret
    end_op();
    800061c0:	ffffe097          	auipc	ra,0xffffe
    800061c4:	7bc080e7          	jalr	1980(ra) # 8000497c <end_op>
    return -1;
    800061c8:	557d                	li	a0,-1
    800061ca:	b7fd                	j	800061b8 <sys_mknod+0x6c>

00000000800061cc <sys_chdir>:

uint64
sys_chdir(void)
{
    800061cc:	7135                	addi	sp,sp,-160
    800061ce:	ed06                	sd	ra,152(sp)
    800061d0:	e922                	sd	s0,144(sp)
    800061d2:	e526                	sd	s1,136(sp)
    800061d4:	e14a                	sd	s2,128(sp)
    800061d6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800061d8:	ffffc097          	auipc	ra,0xffffc
    800061dc:	800080e7          	jalr	-2048(ra) # 800019d8 <myproc>
    800061e0:	892a                	mv	s2,a0
  
  begin_op();
    800061e2:	ffffe097          	auipc	ra,0xffffe
    800061e6:	71a080e7          	jalr	1818(ra) # 800048fc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800061ea:	08000613          	li	a2,128
    800061ee:	f6040593          	addi	a1,s0,-160
    800061f2:	4501                	li	a0,0
    800061f4:	ffffd097          	auipc	ra,0xffffd
    800061f8:	106080e7          	jalr	262(ra) # 800032fa <argstr>
    800061fc:	04054d63          	bltz	a0,80006256 <sys_chdir+0x8a>
    80006200:	f6040513          	addi	a0,s0,-160
    80006204:	ffffe097          	auipc	ra,0xffffe
    80006208:	4dc080e7          	jalr	1244(ra) # 800046e0 <namei>
    8000620c:	84aa                	mv	s1,a0
    8000620e:	c521                	beqz	a0,80006256 <sys_chdir+0x8a>
    end_op();
    return -1;
  }
  ilock(ip);
    80006210:	ffffe097          	auipc	ra,0xffffe
    80006214:	d26080e7          	jalr	-730(ra) # 80003f36 <ilock>
  if(ip->type != T_DIR){
    80006218:	04449703          	lh	a4,68(s1)
    8000621c:	4785                	li	a5,1
    8000621e:	04f71263          	bne	a4,a5,80006262 <sys_chdir+0x96>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006222:	8526                	mv	a0,s1
    80006224:	ffffe097          	auipc	ra,0xffffe
    80006228:	dd4080e7          	jalr	-556(ra) # 80003ff8 <iunlock>
  iput(p->cwd);
    8000622c:	6505                	lui	a0,0x1
    8000622e:	992a                	add	s2,s2,a0
    80006230:	84893503          	ld	a0,-1976(s2)
    80006234:	ffffe097          	auipc	ra,0xffffe
    80006238:	ebc080e7          	jalr	-324(ra) # 800040f0 <iput>
  end_op();
    8000623c:	ffffe097          	auipc	ra,0xffffe
    80006240:	740080e7          	jalr	1856(ra) # 8000497c <end_op>
  p->cwd = ip;
    80006244:	84993423          	sd	s1,-1976(s2)
  return 0;
    80006248:	4501                	li	a0,0
}
    8000624a:	60ea                	ld	ra,152(sp)
    8000624c:	644a                	ld	s0,144(sp)
    8000624e:	64aa                	ld	s1,136(sp)
    80006250:	690a                	ld	s2,128(sp)
    80006252:	610d                	addi	sp,sp,160
    80006254:	8082                	ret
    end_op();
    80006256:	ffffe097          	auipc	ra,0xffffe
    8000625a:	726080e7          	jalr	1830(ra) # 8000497c <end_op>
    return -1;
    8000625e:	557d                	li	a0,-1
    80006260:	b7ed                	j	8000624a <sys_chdir+0x7e>
    iunlockput(ip);
    80006262:	8526                	mv	a0,s1
    80006264:	ffffe097          	auipc	ra,0xffffe
    80006268:	f34080e7          	jalr	-204(ra) # 80004198 <iunlockput>
    end_op();
    8000626c:	ffffe097          	auipc	ra,0xffffe
    80006270:	710080e7          	jalr	1808(ra) # 8000497c <end_op>
    return -1;
    80006274:	557d                	li	a0,-1
    80006276:	bfd1                	j	8000624a <sys_chdir+0x7e>

0000000080006278 <sys_exec>:

uint64
sys_exec(void)
{
    80006278:	7145                	addi	sp,sp,-464
    8000627a:	e786                	sd	ra,456(sp)
    8000627c:	e3a2                	sd	s0,448(sp)
    8000627e:	ff26                	sd	s1,440(sp)
    80006280:	fb4a                	sd	s2,432(sp)
    80006282:	f74e                	sd	s3,424(sp)
    80006284:	f352                	sd	s4,416(sp)
    80006286:	ef56                	sd	s5,408(sp)
    80006288:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000628a:	e3840593          	addi	a1,s0,-456
    8000628e:	4505                	li	a0,1
    80006290:	ffffd097          	auipc	ra,0xffffd
    80006294:	04a080e7          	jalr	74(ra) # 800032da <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006298:	08000613          	li	a2,128
    8000629c:	f4040593          	addi	a1,s0,-192
    800062a0:	4501                	li	a0,0
    800062a2:	ffffd097          	auipc	ra,0xffffd
    800062a6:	058080e7          	jalr	88(ra) # 800032fa <argstr>
    800062aa:	87aa                	mv	a5,a0
    return -1;
    800062ac:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800062ae:	0c07c263          	bltz	a5,80006372 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800062b2:	10000613          	li	a2,256
    800062b6:	4581                	li	a1,0
    800062b8:	e4040513          	addi	a0,s0,-448
    800062bc:	ffffb097          	auipc	ra,0xffffb
    800062c0:	a16080e7          	jalr	-1514(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800062c4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800062c8:	89a6                	mv	s3,s1
    800062ca:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800062cc:	02000a13          	li	s4,32
    800062d0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800062d4:	00391793          	slli	a5,s2,0x3
    800062d8:	e3040593          	addi	a1,s0,-464
    800062dc:	e3843503          	ld	a0,-456(s0)
    800062e0:	953e                	add	a0,a0,a5
    800062e2:	ffffd097          	auipc	ra,0xffffd
    800062e6:	f34080e7          	jalr	-204(ra) # 80003216 <fetchaddr>
    800062ea:	02054a63          	bltz	a0,8000631e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800062ee:	e3043783          	ld	a5,-464(s0)
    800062f2:	c3b9                	beqz	a5,80006338 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800062f4:	ffffa097          	auipc	ra,0xffffa
    800062f8:	7f2080e7          	jalr	2034(ra) # 80000ae6 <kalloc>
    800062fc:	85aa                	mv	a1,a0
    800062fe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006302:	cd11                	beqz	a0,8000631e <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006304:	6605                	lui	a2,0x1
    80006306:	e3043503          	ld	a0,-464(s0)
    8000630a:	ffffd097          	auipc	ra,0xffffd
    8000630e:	f62080e7          	jalr	-158(ra) # 8000326c <fetchstr>
    80006312:	00054663          	bltz	a0,8000631e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006316:	0905                	addi	s2,s2,1
    80006318:	09a1                	addi	s3,s3,8
    8000631a:	fb491be3          	bne	s2,s4,800062d0 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000631e:	10048913          	addi	s2,s1,256
    80006322:	6088                	ld	a0,0(s1)
    80006324:	c531                	beqz	a0,80006370 <sys_exec+0xf8>
    kfree(argv[i]);
    80006326:	ffffa097          	auipc	ra,0xffffa
    8000632a:	6c4080e7          	jalr	1732(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000632e:	04a1                	addi	s1,s1,8
    80006330:	ff2499e3          	bne	s1,s2,80006322 <sys_exec+0xaa>
  return -1;
    80006334:	557d                	li	a0,-1
    80006336:	a835                	j	80006372 <sys_exec+0xfa>
      argv[i] = 0;
    80006338:	0a8e                	slli	s5,s5,0x3
    8000633a:	fc040793          	addi	a5,s0,-64
    8000633e:	9abe                	add	s5,s5,a5
    80006340:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006344:	e4040593          	addi	a1,s0,-448
    80006348:	f4040513          	addi	a0,s0,-192
    8000634c:	fffff097          	auipc	ra,0xfffff
    80006350:	0f6080e7          	jalr	246(ra) # 80005442 <exec>
    80006354:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006356:	10048993          	addi	s3,s1,256
    8000635a:	6088                	ld	a0,0(s1)
    8000635c:	c901                	beqz	a0,8000636c <sys_exec+0xf4>
    kfree(argv[i]);
    8000635e:	ffffa097          	auipc	ra,0xffffa
    80006362:	68c080e7          	jalr	1676(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006366:	04a1                	addi	s1,s1,8
    80006368:	ff3499e3          	bne	s1,s3,8000635a <sys_exec+0xe2>
  return ret;
    8000636c:	854a                	mv	a0,s2
    8000636e:	a011                	j	80006372 <sys_exec+0xfa>
  return -1;
    80006370:	557d                	li	a0,-1
}
    80006372:	60be                	ld	ra,456(sp)
    80006374:	641e                	ld	s0,448(sp)
    80006376:	74fa                	ld	s1,440(sp)
    80006378:	795a                	ld	s2,432(sp)
    8000637a:	79ba                	ld	s3,424(sp)
    8000637c:	7a1a                	ld	s4,416(sp)
    8000637e:	6afa                	ld	s5,408(sp)
    80006380:	6179                	addi	sp,sp,464
    80006382:	8082                	ret

0000000080006384 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006384:	7139                	addi	sp,sp,-64
    80006386:	fc06                	sd	ra,56(sp)
    80006388:	f822                	sd	s0,48(sp)
    8000638a:	f426                	sd	s1,40(sp)
    8000638c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000638e:	ffffb097          	auipc	ra,0xffffb
    80006392:	64a080e7          	jalr	1610(ra) # 800019d8 <myproc>
    80006396:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006398:	fd840593          	addi	a1,s0,-40
    8000639c:	4501                	li	a0,0
    8000639e:	ffffd097          	auipc	ra,0xffffd
    800063a2:	f3c080e7          	jalr	-196(ra) # 800032da <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800063a6:	fc840593          	addi	a1,s0,-56
    800063aa:	fd040513          	addi	a0,s0,-48
    800063ae:	fffff097          	auipc	ra,0xfffff
    800063b2:	d4a080e7          	jalr	-694(ra) # 800050f8 <pipealloc>
    return -1;
    800063b6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800063b8:	0c054963          	bltz	a0,8000648a <sys_pipe+0x106>
  fd0 = -1;
    800063bc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800063c0:	fd043503          	ld	a0,-48(s0)
    800063c4:	fffff097          	auipc	ra,0xfffff
    800063c8:	514080e7          	jalr	1300(ra) # 800058d8 <fdalloc>
    800063cc:	fca42223          	sw	a0,-60(s0)
    800063d0:	0a054063          	bltz	a0,80006470 <sys_pipe+0xec>
    800063d4:	fc843503          	ld	a0,-56(s0)
    800063d8:	fffff097          	auipc	ra,0xfffff
    800063dc:	500080e7          	jalr	1280(ra) # 800058d8 <fdalloc>
    800063e0:	fca42023          	sw	a0,-64(s0)
    800063e4:	06054c63          	bltz	a0,8000645c <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063e8:	4691                	li	a3,4
    800063ea:	fc440613          	addi	a2,s0,-60
    800063ee:	fd843583          	ld	a1,-40(s0)
    800063f2:	7c04b503          	ld	a0,1984(s1)
    800063f6:	ffffb097          	auipc	ra,0xffffb
    800063fa:	272080e7          	jalr	626(ra) # 80001668 <copyout>
    800063fe:	02054163          	bltz	a0,80006420 <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006402:	4691                	li	a3,4
    80006404:	fc040613          	addi	a2,s0,-64
    80006408:	fd843583          	ld	a1,-40(s0)
    8000640c:	0591                	addi	a1,a1,4
    8000640e:	7c04b503          	ld	a0,1984(s1)
    80006412:	ffffb097          	auipc	ra,0xffffb
    80006416:	256080e7          	jalr	598(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000641a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000641c:	06055763          	bgez	a0,8000648a <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    80006420:	fc442783          	lw	a5,-60(s0)
    80006424:	0f878793          	addi	a5,a5,248
    80006428:	078e                	slli	a5,a5,0x3
    8000642a:	97a6                	add	a5,a5,s1
    8000642c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006430:	fc042503          	lw	a0,-64(s0)
    80006434:	0f850513          	addi	a0,a0,248 # 10f8 <_entry-0x7fffef08>
    80006438:	050e                	slli	a0,a0,0x3
    8000643a:	94aa                	add	s1,s1,a0
    8000643c:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006440:	fd043503          	ld	a0,-48(s0)
    80006444:	fffff097          	auipc	ra,0xfffff
    80006448:	984080e7          	jalr	-1660(ra) # 80004dc8 <fileclose>
    fileclose(wf);
    8000644c:	fc843503          	ld	a0,-56(s0)
    80006450:	fffff097          	auipc	ra,0xfffff
    80006454:	978080e7          	jalr	-1672(ra) # 80004dc8 <fileclose>
    return -1;
    80006458:	57fd                	li	a5,-1
    8000645a:	a805                	j	8000648a <sys_pipe+0x106>
    if(fd0 >= 0)
    8000645c:	fc442783          	lw	a5,-60(s0)
    80006460:	0007c863          	bltz	a5,80006470 <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80006464:	0f878793          	addi	a5,a5,248
    80006468:	078e                	slli	a5,a5,0x3
    8000646a:	94be                	add	s1,s1,a5
    8000646c:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006470:	fd043503          	ld	a0,-48(s0)
    80006474:	fffff097          	auipc	ra,0xfffff
    80006478:	954080e7          	jalr	-1708(ra) # 80004dc8 <fileclose>
    fileclose(wf);
    8000647c:	fc843503          	ld	a0,-56(s0)
    80006480:	fffff097          	auipc	ra,0xfffff
    80006484:	948080e7          	jalr	-1720(ra) # 80004dc8 <fileclose>
    return -1;
    80006488:	57fd                	li	a5,-1
}
    8000648a:	853e                	mv	a0,a5
    8000648c:	70e2                	ld	ra,56(sp)
    8000648e:	7442                	ld	s0,48(sp)
    80006490:	74a2                	ld	s1,40(sp)
    80006492:	6121                	addi	sp,sp,64
    80006494:	8082                	ret
	...

00000000800064a0 <kernelvec>:
    800064a0:	7111                	addi	sp,sp,-256
    800064a2:	e006                	sd	ra,0(sp)
    800064a4:	e40a                	sd	sp,8(sp)
    800064a6:	e80e                	sd	gp,16(sp)
    800064a8:	ec12                	sd	tp,24(sp)
    800064aa:	f016                	sd	t0,32(sp)
    800064ac:	f41a                	sd	t1,40(sp)
    800064ae:	f81e                	sd	t2,48(sp)
    800064b0:	fc22                	sd	s0,56(sp)
    800064b2:	e0a6                	sd	s1,64(sp)
    800064b4:	e4aa                	sd	a0,72(sp)
    800064b6:	e8ae                	sd	a1,80(sp)
    800064b8:	ecb2                	sd	a2,88(sp)
    800064ba:	f0b6                	sd	a3,96(sp)
    800064bc:	f4ba                	sd	a4,104(sp)
    800064be:	f8be                	sd	a5,112(sp)
    800064c0:	fcc2                	sd	a6,120(sp)
    800064c2:	e146                	sd	a7,128(sp)
    800064c4:	e54a                	sd	s2,136(sp)
    800064c6:	e94e                	sd	s3,144(sp)
    800064c8:	ed52                	sd	s4,152(sp)
    800064ca:	f156                	sd	s5,160(sp)
    800064cc:	f55a                	sd	s6,168(sp)
    800064ce:	f95e                	sd	s7,176(sp)
    800064d0:	fd62                	sd	s8,184(sp)
    800064d2:	e1e6                	sd	s9,192(sp)
    800064d4:	e5ea                	sd	s10,200(sp)
    800064d6:	e9ee                	sd	s11,208(sp)
    800064d8:	edf2                	sd	t3,216(sp)
    800064da:	f1f6                	sd	t4,224(sp)
    800064dc:	f5fa                	sd	t5,232(sp)
    800064de:	f9fe                	sd	t6,240(sp)
    800064e0:	c03fc0ef          	jal	ra,800030e2 <kerneltrap>
    800064e4:	6082                	ld	ra,0(sp)
    800064e6:	6122                	ld	sp,8(sp)
    800064e8:	61c2                	ld	gp,16(sp)
    800064ea:	7282                	ld	t0,32(sp)
    800064ec:	7322                	ld	t1,40(sp)
    800064ee:	73c2                	ld	t2,48(sp)
    800064f0:	7462                	ld	s0,56(sp)
    800064f2:	6486                	ld	s1,64(sp)
    800064f4:	6526                	ld	a0,72(sp)
    800064f6:	65c6                	ld	a1,80(sp)
    800064f8:	6666                	ld	a2,88(sp)
    800064fa:	7686                	ld	a3,96(sp)
    800064fc:	7726                	ld	a4,104(sp)
    800064fe:	77c6                	ld	a5,112(sp)
    80006500:	7866                	ld	a6,120(sp)
    80006502:	688a                	ld	a7,128(sp)
    80006504:	692a                	ld	s2,136(sp)
    80006506:	69ca                	ld	s3,144(sp)
    80006508:	6a6a                	ld	s4,152(sp)
    8000650a:	7a8a                	ld	s5,160(sp)
    8000650c:	7b2a                	ld	s6,168(sp)
    8000650e:	7bca                	ld	s7,176(sp)
    80006510:	7c6a                	ld	s8,184(sp)
    80006512:	6c8e                	ld	s9,192(sp)
    80006514:	6d2e                	ld	s10,200(sp)
    80006516:	6dce                	ld	s11,208(sp)
    80006518:	6e6e                	ld	t3,216(sp)
    8000651a:	7e8e                	ld	t4,224(sp)
    8000651c:	7f2e                	ld	t5,232(sp)
    8000651e:	7fce                	ld	t6,240(sp)
    80006520:	6111                	addi	sp,sp,256
    80006522:	10200073          	sret
    80006526:	00000013          	nop
    8000652a:	00000013          	nop
    8000652e:	0001                	nop

0000000080006530 <timervec>:
    80006530:	34051573          	csrrw	a0,mscratch,a0
    80006534:	e10c                	sd	a1,0(a0)
    80006536:	e510                	sd	a2,8(a0)
    80006538:	e914                	sd	a3,16(a0)
    8000653a:	6d0c                	ld	a1,24(a0)
    8000653c:	7110                	ld	a2,32(a0)
    8000653e:	6194                	ld	a3,0(a1)
    80006540:	96b2                	add	a3,a3,a2
    80006542:	e194                	sd	a3,0(a1)
    80006544:	4589                	li	a1,2
    80006546:	14459073          	csrw	sip,a1
    8000654a:	6914                	ld	a3,16(a0)
    8000654c:	6510                	ld	a2,8(a0)
    8000654e:	610c                	ld	a1,0(a0)
    80006550:	34051573          	csrrw	a0,mscratch,a0
    80006554:	30200073          	mret
	...

000000008000655a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000655a:	1141                	addi	sp,sp,-16
    8000655c:	e422                	sd	s0,8(sp)
    8000655e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006560:	0c0007b7          	lui	a5,0xc000
    80006564:	4705                	li	a4,1
    80006566:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006568:	c3d8                	sw	a4,4(a5)
}
    8000656a:	6422                	ld	s0,8(sp)
    8000656c:	0141                	addi	sp,sp,16
    8000656e:	8082                	ret

0000000080006570 <plicinithart>:

void
plicinithart(void)
{
    80006570:	1141                	addi	sp,sp,-16
    80006572:	e406                	sd	ra,8(sp)
    80006574:	e022                	sd	s0,0(sp)
    80006576:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006578:	ffffb097          	auipc	ra,0xffffb
    8000657c:	434080e7          	jalr	1076(ra) # 800019ac <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006580:	0085171b          	slliw	a4,a0,0x8
    80006584:	0c0027b7          	lui	a5,0xc002
    80006588:	97ba                	add	a5,a5,a4
    8000658a:	40200713          	li	a4,1026
    8000658e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006592:	00d5151b          	slliw	a0,a0,0xd
    80006596:	0c2017b7          	lui	a5,0xc201
    8000659a:	953e                	add	a0,a0,a5
    8000659c:	00052023          	sw	zero,0(a0)
}
    800065a0:	60a2                	ld	ra,8(sp)
    800065a2:	6402                	ld	s0,0(sp)
    800065a4:	0141                	addi	sp,sp,16
    800065a6:	8082                	ret

00000000800065a8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800065a8:	1141                	addi	sp,sp,-16
    800065aa:	e406                	sd	ra,8(sp)
    800065ac:	e022                	sd	s0,0(sp)
    800065ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800065b0:	ffffb097          	auipc	ra,0xffffb
    800065b4:	3fc080e7          	jalr	1020(ra) # 800019ac <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800065b8:	00d5179b          	slliw	a5,a0,0xd
    800065bc:	0c201537          	lui	a0,0xc201
    800065c0:	953e                	add	a0,a0,a5
  return irq;
}
    800065c2:	4148                	lw	a0,4(a0)
    800065c4:	60a2                	ld	ra,8(sp)
    800065c6:	6402                	ld	s0,0(sp)
    800065c8:	0141                	addi	sp,sp,16
    800065ca:	8082                	ret

00000000800065cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800065cc:	1101                	addi	sp,sp,-32
    800065ce:	ec06                	sd	ra,24(sp)
    800065d0:	e822                	sd	s0,16(sp)
    800065d2:	e426                	sd	s1,8(sp)
    800065d4:	1000                	addi	s0,sp,32
    800065d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800065d8:	ffffb097          	auipc	ra,0xffffb
    800065dc:	3d4080e7          	jalr	980(ra) # 800019ac <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800065e0:	00d5151b          	slliw	a0,a0,0xd
    800065e4:	0c2017b7          	lui	a5,0xc201
    800065e8:	97aa                	add	a5,a5,a0
    800065ea:	c3c4                	sw	s1,4(a5)
}
    800065ec:	60e2                	ld	ra,24(sp)
    800065ee:	6442                	ld	s0,16(sp)
    800065f0:	64a2                	ld	s1,8(sp)
    800065f2:	6105                	addi	sp,sp,32
    800065f4:	8082                	ret

00000000800065f6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800065f6:	1141                	addi	sp,sp,-16
    800065f8:	e406                	sd	ra,8(sp)
    800065fa:	e022                	sd	s0,0(sp)
    800065fc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800065fe:	479d                	li	a5,7
    80006600:	04a7cc63          	blt	a5,a0,80006658 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006604:	00038797          	auipc	a5,0x38
    80006608:	c3c78793          	addi	a5,a5,-964 # 8003e240 <disk>
    8000660c:	97aa                	add	a5,a5,a0
    8000660e:	0187c783          	lbu	a5,24(a5)
    80006612:	ebb9                	bnez	a5,80006668 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006614:	00451613          	slli	a2,a0,0x4
    80006618:	00038797          	auipc	a5,0x38
    8000661c:	c2878793          	addi	a5,a5,-984 # 8003e240 <disk>
    80006620:	6394                	ld	a3,0(a5)
    80006622:	96b2                	add	a3,a3,a2
    80006624:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006628:	6398                	ld	a4,0(a5)
    8000662a:	9732                	add	a4,a4,a2
    8000662c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006630:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006634:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006638:	953e                	add	a0,a0,a5
    8000663a:	4785                	li	a5,1
    8000663c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006640:	00038517          	auipc	a0,0x38
    80006644:	c1850513          	addi	a0,a0,-1000 # 8003e258 <disk+0x18>
    80006648:	ffffc097          	auipc	ra,0xffffc
    8000664c:	b88080e7          	jalr	-1144(ra) # 800021d0 <wakeup>
}
    80006650:	60a2                	ld	ra,8(sp)
    80006652:	6402                	ld	s0,0(sp)
    80006654:	0141                	addi	sp,sp,16
    80006656:	8082                	ret
    panic("free_desc 1");
    80006658:	00002517          	auipc	a0,0x2
    8000665c:	10050513          	addi	a0,a0,256 # 80008758 <syscalls+0x318>
    80006660:	ffffa097          	auipc	ra,0xffffa
    80006664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006668:	00002517          	auipc	a0,0x2
    8000666c:	10050513          	addi	a0,a0,256 # 80008768 <syscalls+0x328>
    80006670:	ffffa097          	auipc	ra,0xffffa
    80006674:	ece080e7          	jalr	-306(ra) # 8000053e <panic>

0000000080006678 <virtio_disk_init>:
{
    80006678:	1101                	addi	sp,sp,-32
    8000667a:	ec06                	sd	ra,24(sp)
    8000667c:	e822                	sd	s0,16(sp)
    8000667e:	e426                	sd	s1,8(sp)
    80006680:	e04a                	sd	s2,0(sp)
    80006682:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006684:	00002597          	auipc	a1,0x2
    80006688:	0f458593          	addi	a1,a1,244 # 80008778 <syscalls+0x338>
    8000668c:	00038517          	auipc	a0,0x38
    80006690:	cdc50513          	addi	a0,a0,-804 # 8003e368 <disk+0x128>
    80006694:	ffffa097          	auipc	ra,0xffffa
    80006698:	4b2080e7          	jalr	1202(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000669c:	100017b7          	lui	a5,0x10001
    800066a0:	4398                	lw	a4,0(a5)
    800066a2:	2701                	sext.w	a4,a4
    800066a4:	747277b7          	lui	a5,0x74727
    800066a8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800066ac:	14f71c63          	bne	a4,a5,80006804 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800066b0:	100017b7          	lui	a5,0x10001
    800066b4:	43dc                	lw	a5,4(a5)
    800066b6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800066b8:	4709                	li	a4,2
    800066ba:	14e79563          	bne	a5,a4,80006804 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066be:	100017b7          	lui	a5,0x10001
    800066c2:	479c                	lw	a5,8(a5)
    800066c4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800066c6:	12e79f63          	bne	a5,a4,80006804 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800066ca:	100017b7          	lui	a5,0x10001
    800066ce:	47d8                	lw	a4,12(a5)
    800066d0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066d2:	554d47b7          	lui	a5,0x554d4
    800066d6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800066da:	12f71563          	bne	a4,a5,80006804 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800066de:	100017b7          	lui	a5,0x10001
    800066e2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800066e6:	4705                	li	a4,1
    800066e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800066ea:	470d                	li	a4,3
    800066ec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800066ee:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800066f0:	c7ffe737          	lui	a4,0xc7ffe
    800066f4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc03df>
    800066f8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800066fa:	2701                	sext.w	a4,a4
    800066fc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800066fe:	472d                	li	a4,11
    80006700:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006702:	5bbc                	lw	a5,112(a5)
    80006704:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006708:	8ba1                	andi	a5,a5,8
    8000670a:	10078563          	beqz	a5,80006814 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000670e:	100017b7          	lui	a5,0x10001
    80006712:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006716:	43fc                	lw	a5,68(a5)
    80006718:	2781                	sext.w	a5,a5
    8000671a:	10079563          	bnez	a5,80006824 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000671e:	100017b7          	lui	a5,0x10001
    80006722:	5bdc                	lw	a5,52(a5)
    80006724:	2781                	sext.w	a5,a5
  if(max == 0)
    80006726:	10078763          	beqz	a5,80006834 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000672a:	471d                	li	a4,7
    8000672c:	10f77c63          	bgeu	a4,a5,80006844 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006730:	ffffa097          	auipc	ra,0xffffa
    80006734:	3b6080e7          	jalr	950(ra) # 80000ae6 <kalloc>
    80006738:	00038497          	auipc	s1,0x38
    8000673c:	b0848493          	addi	s1,s1,-1272 # 8003e240 <disk>
    80006740:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006742:	ffffa097          	auipc	ra,0xffffa
    80006746:	3a4080e7          	jalr	932(ra) # 80000ae6 <kalloc>
    8000674a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000674c:	ffffa097          	auipc	ra,0xffffa
    80006750:	39a080e7          	jalr	922(ra) # 80000ae6 <kalloc>
    80006754:	87aa                	mv	a5,a0
    80006756:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006758:	6088                	ld	a0,0(s1)
    8000675a:	cd6d                	beqz	a0,80006854 <virtio_disk_init+0x1dc>
    8000675c:	00038717          	auipc	a4,0x38
    80006760:	aec73703          	ld	a4,-1300(a4) # 8003e248 <disk+0x8>
    80006764:	cb65                	beqz	a4,80006854 <virtio_disk_init+0x1dc>
    80006766:	c7fd                	beqz	a5,80006854 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006768:	6605                	lui	a2,0x1
    8000676a:	4581                	li	a1,0
    8000676c:	ffffa097          	auipc	ra,0xffffa
    80006770:	566080e7          	jalr	1382(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006774:	00038497          	auipc	s1,0x38
    80006778:	acc48493          	addi	s1,s1,-1332 # 8003e240 <disk>
    8000677c:	6605                	lui	a2,0x1
    8000677e:	4581                	li	a1,0
    80006780:	6488                	ld	a0,8(s1)
    80006782:	ffffa097          	auipc	ra,0xffffa
    80006786:	550080e7          	jalr	1360(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000678a:	6605                	lui	a2,0x1
    8000678c:	4581                	li	a1,0
    8000678e:	6888                	ld	a0,16(s1)
    80006790:	ffffa097          	auipc	ra,0xffffa
    80006794:	542080e7          	jalr	1346(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006798:	100017b7          	lui	a5,0x10001
    8000679c:	4721                	li	a4,8
    8000679e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800067a0:	4098                	lw	a4,0(s1)
    800067a2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800067a6:	40d8                	lw	a4,4(s1)
    800067a8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800067ac:	6498                	ld	a4,8(s1)
    800067ae:	0007069b          	sext.w	a3,a4
    800067b2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800067b6:	9701                	srai	a4,a4,0x20
    800067b8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800067bc:	6898                	ld	a4,16(s1)
    800067be:	0007069b          	sext.w	a3,a4
    800067c2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800067c6:	9701                	srai	a4,a4,0x20
    800067c8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800067cc:	4705                	li	a4,1
    800067ce:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800067d0:	00e48c23          	sb	a4,24(s1)
    800067d4:	00e48ca3          	sb	a4,25(s1)
    800067d8:	00e48d23          	sb	a4,26(s1)
    800067dc:	00e48da3          	sb	a4,27(s1)
    800067e0:	00e48e23          	sb	a4,28(s1)
    800067e4:	00e48ea3          	sb	a4,29(s1)
    800067e8:	00e48f23          	sb	a4,30(s1)
    800067ec:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800067f0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800067f4:	0727a823          	sw	s2,112(a5)
}
    800067f8:	60e2                	ld	ra,24(sp)
    800067fa:	6442                	ld	s0,16(sp)
    800067fc:	64a2                	ld	s1,8(sp)
    800067fe:	6902                	ld	s2,0(sp)
    80006800:	6105                	addi	sp,sp,32
    80006802:	8082                	ret
    panic("could not find virtio disk");
    80006804:	00002517          	auipc	a0,0x2
    80006808:	f8450513          	addi	a0,a0,-124 # 80008788 <syscalls+0x348>
    8000680c:	ffffa097          	auipc	ra,0xffffa
    80006810:	d32080e7          	jalr	-718(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006814:	00002517          	auipc	a0,0x2
    80006818:	f9450513          	addi	a0,a0,-108 # 800087a8 <syscalls+0x368>
    8000681c:	ffffa097          	auipc	ra,0xffffa
    80006820:	d22080e7          	jalr	-734(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006824:	00002517          	auipc	a0,0x2
    80006828:	fa450513          	addi	a0,a0,-92 # 800087c8 <syscalls+0x388>
    8000682c:	ffffa097          	auipc	ra,0xffffa
    80006830:	d12080e7          	jalr	-750(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006834:	00002517          	auipc	a0,0x2
    80006838:	fb450513          	addi	a0,a0,-76 # 800087e8 <syscalls+0x3a8>
    8000683c:	ffffa097          	auipc	ra,0xffffa
    80006840:	d02080e7          	jalr	-766(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006844:	00002517          	auipc	a0,0x2
    80006848:	fc450513          	addi	a0,a0,-60 # 80008808 <syscalls+0x3c8>
    8000684c:	ffffa097          	auipc	ra,0xffffa
    80006850:	cf2080e7          	jalr	-782(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006854:	00002517          	auipc	a0,0x2
    80006858:	fd450513          	addi	a0,a0,-44 # 80008828 <syscalls+0x3e8>
    8000685c:	ffffa097          	auipc	ra,0xffffa
    80006860:	ce2080e7          	jalr	-798(ra) # 8000053e <panic>

0000000080006864 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006864:	7119                	addi	sp,sp,-128
    80006866:	fc86                	sd	ra,120(sp)
    80006868:	f8a2                	sd	s0,112(sp)
    8000686a:	f4a6                	sd	s1,104(sp)
    8000686c:	f0ca                	sd	s2,96(sp)
    8000686e:	ecce                	sd	s3,88(sp)
    80006870:	e8d2                	sd	s4,80(sp)
    80006872:	e4d6                	sd	s5,72(sp)
    80006874:	e0da                	sd	s6,64(sp)
    80006876:	fc5e                	sd	s7,56(sp)
    80006878:	f862                	sd	s8,48(sp)
    8000687a:	f466                	sd	s9,40(sp)
    8000687c:	f06a                	sd	s10,32(sp)
    8000687e:	ec6e                	sd	s11,24(sp)
    80006880:	0100                	addi	s0,sp,128
    80006882:	8aaa                	mv	s5,a0
    80006884:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006886:	00c52d03          	lw	s10,12(a0)
    8000688a:	001d1d1b          	slliw	s10,s10,0x1
    8000688e:	1d02                	slli	s10,s10,0x20
    80006890:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006894:	00038517          	auipc	a0,0x38
    80006898:	ad450513          	addi	a0,a0,-1324 # 8003e368 <disk+0x128>
    8000689c:	ffffa097          	auipc	ra,0xffffa
    800068a0:	33a080e7          	jalr	826(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800068a4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800068a6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800068a8:	00038b97          	auipc	s7,0x38
    800068ac:	998b8b93          	addi	s7,s7,-1640 # 8003e240 <disk>
  for(int i = 0; i < 3; i++){
    800068b0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800068b2:	00038c97          	auipc	s9,0x38
    800068b6:	ab6c8c93          	addi	s9,s9,-1354 # 8003e368 <disk+0x128>
    800068ba:	a08d                	j	8000691c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800068bc:	00fb8733          	add	a4,s7,a5
    800068c0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800068c4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800068c6:	0207c563          	bltz	a5,800068f0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800068ca:	2905                	addiw	s2,s2,1
    800068cc:	0611                	addi	a2,a2,4
    800068ce:	05690c63          	beq	s2,s6,80006926 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800068d2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800068d4:	00038717          	auipc	a4,0x38
    800068d8:	96c70713          	addi	a4,a4,-1684 # 8003e240 <disk>
    800068dc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800068de:	01874683          	lbu	a3,24(a4)
    800068e2:	fee9                	bnez	a3,800068bc <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800068e4:	2785                	addiw	a5,a5,1
    800068e6:	0705                	addi	a4,a4,1
    800068e8:	fe979be3          	bne	a5,s1,800068de <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800068ec:	57fd                	li	a5,-1
    800068ee:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800068f0:	01205d63          	blez	s2,8000690a <virtio_disk_rw+0xa6>
    800068f4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800068f6:	000a2503          	lw	a0,0(s4)
    800068fa:	00000097          	auipc	ra,0x0
    800068fe:	cfc080e7          	jalr	-772(ra) # 800065f6 <free_desc>
      for(int j = 0; j < i; j++)
    80006902:	2d85                	addiw	s11,s11,1
    80006904:	0a11                	addi	s4,s4,4
    80006906:	ffb918e3          	bne	s2,s11,800068f6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000690a:	85e6                	mv	a1,s9
    8000690c:	00038517          	auipc	a0,0x38
    80006910:	94c50513          	addi	a0,a0,-1716 # 8003e258 <disk+0x18>
    80006914:	ffffc097          	auipc	ra,0xffffc
    80006918:	858080e7          	jalr	-1960(ra) # 8000216c <sleep>
  for(int i = 0; i < 3; i++){
    8000691c:	f8040a13          	addi	s4,s0,-128
{
    80006920:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006922:	894e                	mv	s2,s3
    80006924:	b77d                	j	800068d2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006926:	f8042583          	lw	a1,-128(s0)
    8000692a:	00a58793          	addi	a5,a1,10
    8000692e:	0792                	slli	a5,a5,0x4

  if(write)
    80006930:	00038617          	auipc	a2,0x38
    80006934:	91060613          	addi	a2,a2,-1776 # 8003e240 <disk>
    80006938:	00f60733          	add	a4,a2,a5
    8000693c:	018036b3          	snez	a3,s8
    80006940:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006942:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006946:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000694a:	f6078693          	addi	a3,a5,-160
    8000694e:	6218                	ld	a4,0(a2)
    80006950:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006952:	00878513          	addi	a0,a5,8
    80006956:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006958:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000695a:	6208                	ld	a0,0(a2)
    8000695c:	96aa                	add	a3,a3,a0
    8000695e:	4741                	li	a4,16
    80006960:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006962:	4705                	li	a4,1
    80006964:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006968:	f8442703          	lw	a4,-124(s0)
    8000696c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006970:	0712                	slli	a4,a4,0x4
    80006972:	953a                	add	a0,a0,a4
    80006974:	058a8693          	addi	a3,s5,88
    80006978:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000697a:	6208                	ld	a0,0(a2)
    8000697c:	972a                	add	a4,a4,a0
    8000697e:	40000693          	li	a3,1024
    80006982:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006984:	001c3c13          	seqz	s8,s8
    80006988:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000698a:	001c6c13          	ori	s8,s8,1
    8000698e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006992:	f8842603          	lw	a2,-120(s0)
    80006996:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000699a:	00038697          	auipc	a3,0x38
    8000699e:	8a668693          	addi	a3,a3,-1882 # 8003e240 <disk>
    800069a2:	00258713          	addi	a4,a1,2
    800069a6:	0712                	slli	a4,a4,0x4
    800069a8:	9736                	add	a4,a4,a3
    800069aa:	587d                	li	a6,-1
    800069ac:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800069b0:	0612                	slli	a2,a2,0x4
    800069b2:	9532                	add	a0,a0,a2
    800069b4:	f9078793          	addi	a5,a5,-112
    800069b8:	97b6                	add	a5,a5,a3
    800069ba:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800069bc:	629c                	ld	a5,0(a3)
    800069be:	97b2                	add	a5,a5,a2
    800069c0:	4605                	li	a2,1
    800069c2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800069c4:	4509                	li	a0,2
    800069c6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800069ca:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800069ce:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800069d2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800069d6:	6698                	ld	a4,8(a3)
    800069d8:	00275783          	lhu	a5,2(a4)
    800069dc:	8b9d                	andi	a5,a5,7
    800069de:	0786                	slli	a5,a5,0x1
    800069e0:	97ba                	add	a5,a5,a4
    800069e2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800069e6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800069ea:	6698                	ld	a4,8(a3)
    800069ec:	00275783          	lhu	a5,2(a4)
    800069f0:	2785                	addiw	a5,a5,1
    800069f2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800069f6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800069fa:	100017b7          	lui	a5,0x10001
    800069fe:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006a02:	004aa783          	lw	a5,4(s5)
    80006a06:	02c79163          	bne	a5,a2,80006a28 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006a0a:	00038917          	auipc	s2,0x38
    80006a0e:	95e90913          	addi	s2,s2,-1698 # 8003e368 <disk+0x128>
  while(b->disk == 1) {
    80006a12:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006a14:	85ca                	mv	a1,s2
    80006a16:	8556                	mv	a0,s5
    80006a18:	ffffb097          	auipc	ra,0xffffb
    80006a1c:	754080e7          	jalr	1876(ra) # 8000216c <sleep>
  while(b->disk == 1) {
    80006a20:	004aa783          	lw	a5,4(s5)
    80006a24:	fe9788e3          	beq	a5,s1,80006a14 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006a28:	f8042903          	lw	s2,-128(s0)
    80006a2c:	00290793          	addi	a5,s2,2
    80006a30:	00479713          	slli	a4,a5,0x4
    80006a34:	00038797          	auipc	a5,0x38
    80006a38:	80c78793          	addi	a5,a5,-2036 # 8003e240 <disk>
    80006a3c:	97ba                	add	a5,a5,a4
    80006a3e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006a42:	00037997          	auipc	s3,0x37
    80006a46:	7fe98993          	addi	s3,s3,2046 # 8003e240 <disk>
    80006a4a:	00491713          	slli	a4,s2,0x4
    80006a4e:	0009b783          	ld	a5,0(s3)
    80006a52:	97ba                	add	a5,a5,a4
    80006a54:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006a58:	854a                	mv	a0,s2
    80006a5a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006a5e:	00000097          	auipc	ra,0x0
    80006a62:	b98080e7          	jalr	-1128(ra) # 800065f6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006a66:	8885                	andi	s1,s1,1
    80006a68:	f0ed                	bnez	s1,80006a4a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006a6a:	00038517          	auipc	a0,0x38
    80006a6e:	8fe50513          	addi	a0,a0,-1794 # 8003e368 <disk+0x128>
    80006a72:	ffffa097          	auipc	ra,0xffffa
    80006a76:	218080e7          	jalr	536(ra) # 80000c8a <release>
}
    80006a7a:	70e6                	ld	ra,120(sp)
    80006a7c:	7446                	ld	s0,112(sp)
    80006a7e:	74a6                	ld	s1,104(sp)
    80006a80:	7906                	ld	s2,96(sp)
    80006a82:	69e6                	ld	s3,88(sp)
    80006a84:	6a46                	ld	s4,80(sp)
    80006a86:	6aa6                	ld	s5,72(sp)
    80006a88:	6b06                	ld	s6,64(sp)
    80006a8a:	7be2                	ld	s7,56(sp)
    80006a8c:	7c42                	ld	s8,48(sp)
    80006a8e:	7ca2                	ld	s9,40(sp)
    80006a90:	7d02                	ld	s10,32(sp)
    80006a92:	6de2                	ld	s11,24(sp)
    80006a94:	6109                	addi	sp,sp,128
    80006a96:	8082                	ret

0000000080006a98 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006a98:	1101                	addi	sp,sp,-32
    80006a9a:	ec06                	sd	ra,24(sp)
    80006a9c:	e822                	sd	s0,16(sp)
    80006a9e:	e426                	sd	s1,8(sp)
    80006aa0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006aa2:	00037497          	auipc	s1,0x37
    80006aa6:	79e48493          	addi	s1,s1,1950 # 8003e240 <disk>
    80006aaa:	00038517          	auipc	a0,0x38
    80006aae:	8be50513          	addi	a0,a0,-1858 # 8003e368 <disk+0x128>
    80006ab2:	ffffa097          	auipc	ra,0xffffa
    80006ab6:	124080e7          	jalr	292(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006aba:	10001737          	lui	a4,0x10001
    80006abe:	533c                	lw	a5,96(a4)
    80006ac0:	8b8d                	andi	a5,a5,3
    80006ac2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006ac4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006ac8:	689c                	ld	a5,16(s1)
    80006aca:	0204d703          	lhu	a4,32(s1)
    80006ace:	0027d783          	lhu	a5,2(a5)
    80006ad2:	04f70863          	beq	a4,a5,80006b22 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006ad6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006ada:	6898                	ld	a4,16(s1)
    80006adc:	0204d783          	lhu	a5,32(s1)
    80006ae0:	8b9d                	andi	a5,a5,7
    80006ae2:	078e                	slli	a5,a5,0x3
    80006ae4:	97ba                	add	a5,a5,a4
    80006ae6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006ae8:	00278713          	addi	a4,a5,2
    80006aec:	0712                	slli	a4,a4,0x4
    80006aee:	9726                	add	a4,a4,s1
    80006af0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006af4:	e721                	bnez	a4,80006b3c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006af6:	0789                	addi	a5,a5,2
    80006af8:	0792                	slli	a5,a5,0x4
    80006afa:	97a6                	add	a5,a5,s1
    80006afc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006afe:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006b02:	ffffb097          	auipc	ra,0xffffb
    80006b06:	6ce080e7          	jalr	1742(ra) # 800021d0 <wakeup>

    disk.used_idx += 1;
    80006b0a:	0204d783          	lhu	a5,32(s1)
    80006b0e:	2785                	addiw	a5,a5,1
    80006b10:	17c2                	slli	a5,a5,0x30
    80006b12:	93c1                	srli	a5,a5,0x30
    80006b14:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006b18:	6898                	ld	a4,16(s1)
    80006b1a:	00275703          	lhu	a4,2(a4)
    80006b1e:	faf71ce3          	bne	a4,a5,80006ad6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006b22:	00038517          	auipc	a0,0x38
    80006b26:	84650513          	addi	a0,a0,-1978 # 8003e368 <disk+0x128>
    80006b2a:	ffffa097          	auipc	ra,0xffffa
    80006b2e:	160080e7          	jalr	352(ra) # 80000c8a <release>
}
    80006b32:	60e2                	ld	ra,24(sp)
    80006b34:	6442                	ld	s0,16(sp)
    80006b36:	64a2                	ld	s1,8(sp)
    80006b38:	6105                	addi	sp,sp,32
    80006b3a:	8082                	ret
      panic("virtio_disk_intr status");
    80006b3c:	00002517          	auipc	a0,0x2
    80006b40:	d0450513          	addi	a0,a0,-764 # 80008840 <syscalls+0x400>
    80006b44:	ffffa097          	auipc	ra,0xffffa
    80006b48:	9fa080e7          	jalr	-1542(ra) # 8000053e <panic>
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
