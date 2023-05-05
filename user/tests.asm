
user/_tests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_func>:

#include "uthread.h"
#include "kernel/types.h"
#include "user/user.h"
void* thread_func(void* arg) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    int* arg_ptr = (int*) arg;
    printf("Thread %d started\n",  *arg_ptr);
   8:	410c                	lw	a1,0(a0)
   a:	00001517          	auipc	a0,0x1
   e:	bc650513          	addi	a0,a0,-1082 # bd0 <uthread_self+0x18>
  12:	00000097          	auipc	ra,0x0
  16:	6b6080e7          	jalr	1718(ra) # 6c8 <printf>
     uthread_exit();
  1a:	00001097          	auipc	ra,0x1
  1e:	8ba080e7          	jalr	-1862(ra) # 8d4 <uthread_exit>
    // printf("Thread %d resumed\n", arg_val);
    return (void*) 0;

}
  22:	4501                	li	a0,0
  24:	60a2                	ld	ra,8(sp)
  26:	6402                	ld	s0,0(sp)
  28:	0141                	addi	sp,sp,16
  2a:	8082                	ret

000000000000002c <main>:

int main() {
  2c:	1141                	addi	sp,sp,-16
  2e:	e406                	sd	ra,8(sp)
  30:	e022                	sd	s0,0(sp)
  32:	0800                	addi	s0,sp,16
    int arg1 = 1;
    int arg2 = 2;
    if (uthread_create((void (*)()) thread_func, arg1) == -1 ||
  34:	4585                	li	a1,1
  36:	00000517          	auipc	a0,0x0
  3a:	fca50513          	addi	a0,a0,-54 # 0 <thread_func>
  3e:	00001097          	auipc	ra,0x1
  42:	95a080e7          	jalr	-1702(ra) # 998 <uthread_create>
  46:	57fd                	li	a5,-1
  48:	02f50f63          	beq	a0,a5,86 <main+0x5a>
        uthread_create((void (*)()) thread_func, arg2) == -1) {
  4c:	4589                	li	a1,2
  4e:	00000517          	auipc	a0,0x0
  52:	fb250513          	addi	a0,a0,-78 # 0 <thread_func>
  56:	00001097          	auipc	ra,0x1
  5a:	942080e7          	jalr	-1726(ra) # 998 <uthread_create>
    if (uthread_create((void (*)()) thread_func, arg1) == -1 ||
  5e:	57fd                	li	a5,-1
  60:	02f50363          	beq	a0,a5,86 <main+0x5a>
        printf("Error creating thread\n");
        exit(1);
    }
    uthread_start_all();
  64:	00001097          	auipc	ra,0x1
  68:	a98080e7          	jalr	-1384(ra) # afc <uthread_start_all>
    printf("Main thread resumed\n");
  6c:	00001517          	auipc	a0,0x1
  70:	b9450513          	addi	a0,a0,-1132 # c00 <uthread_self+0x48>
  74:	00000097          	auipc	ra,0x0
  78:	654080e7          	jalr	1620(ra) # 6c8 <printf>
    return 0;
  7c:	4501                	li	a0,0
  7e:	60a2                	ld	ra,8(sp)
  80:	6402                	ld	s0,0(sp)
  82:	0141                	addi	sp,sp,16
  84:	8082                	ret
        printf("Error creating thread\n");
  86:	00001517          	auipc	a0,0x1
  8a:	b6250513          	addi	a0,a0,-1182 # be8 <uthread_self+0x30>
  8e:	00000097          	auipc	ra,0x0
  92:	63a080e7          	jalr	1594(ra) # 6c8 <printf>
        exit(1);
  96:	4505                	li	a0,1
  98:	00000097          	auipc	ra,0x0
  9c:	290080e7          	jalr	656(ra) # 328 <exit>

00000000000000a0 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e406                	sd	ra,8(sp)
  a4:	e022                	sd	s0,0(sp)
  a6:	0800                	addi	s0,sp,16
  extern int main();
  main();
  a8:	00000097          	auipc	ra,0x0
  ac:	f84080e7          	jalr	-124(ra) # 2c <main>
  exit(0);
  b0:	4501                	li	a0,0
  b2:	00000097          	auipc	ra,0x0
  b6:	276080e7          	jalr	630(ra) # 328 <exit>

00000000000000ba <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c0:	87aa                	mv	a5,a0
  c2:	0585                	addi	a1,a1,1
  c4:	0785                	addi	a5,a5,1
  c6:	fff5c703          	lbu	a4,-1(a1)
  ca:	fee78fa3          	sb	a4,-1(a5)
  ce:	fb75                	bnez	a4,c2 <strcpy+0x8>
    ;
  return os;
}
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	addi	sp,sp,16
  d4:	8082                	ret

00000000000000d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	cb91                	beqz	a5,f4 <strcmp+0x1e>
  e2:	0005c703          	lbu	a4,0(a1)
  e6:	00f71763          	bne	a4,a5,f4 <strcmp+0x1e>
    p++, q++;
  ea:	0505                	addi	a0,a0,1
  ec:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	fbe5                	bnez	a5,e2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f4:	0005c503          	lbu	a0,0(a1)
}
  f8:	40a7853b          	subw	a0,a5,a0
  fc:	6422                	ld	s0,8(sp)
  fe:	0141                	addi	sp,sp,16
 100:	8082                	ret

0000000000000102 <strlen>:

uint
strlen(const char *s)
{
 102:	1141                	addi	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 108:	00054783          	lbu	a5,0(a0)
 10c:	cf91                	beqz	a5,128 <strlen+0x26>
 10e:	0505                	addi	a0,a0,1
 110:	87aa                	mv	a5,a0
 112:	4685                	li	a3,1
 114:	9e89                	subw	a3,a3,a0
 116:	00f6853b          	addw	a0,a3,a5
 11a:	0785                	addi	a5,a5,1
 11c:	fff7c703          	lbu	a4,-1(a5)
 120:	fb7d                	bnez	a4,116 <strlen+0x14>
    ;
  return n;
}
 122:	6422                	ld	s0,8(sp)
 124:	0141                	addi	sp,sp,16
 126:	8082                	ret
  for(n = 0; s[n]; n++)
 128:	4501                	li	a0,0
 12a:	bfe5                	j	122 <strlen+0x20>

000000000000012c <memset>:

void*
memset(void *dst, int c, uint n)
{
 12c:	1141                	addi	sp,sp,-16
 12e:	e422                	sd	s0,8(sp)
 130:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 132:	ca19                	beqz	a2,148 <memset+0x1c>
 134:	87aa                	mv	a5,a0
 136:	1602                	slli	a2,a2,0x20
 138:	9201                	srli	a2,a2,0x20
 13a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 13e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 142:	0785                	addi	a5,a5,1
 144:	fee79de3          	bne	a5,a4,13e <memset+0x12>
  }
  return dst;
}
 148:	6422                	ld	s0,8(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret

000000000000014e <strchr>:

char*
strchr(const char *s, char c)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e422                	sd	s0,8(sp)
 152:	0800                	addi	s0,sp,16
  for(; *s; s++)
 154:	00054783          	lbu	a5,0(a0)
 158:	cb99                	beqz	a5,16e <strchr+0x20>
    if(*s == c)
 15a:	00f58763          	beq	a1,a5,168 <strchr+0x1a>
  for(; *s; s++)
 15e:	0505                	addi	a0,a0,1
 160:	00054783          	lbu	a5,0(a0)
 164:	fbfd                	bnez	a5,15a <strchr+0xc>
      return (char*)s;
  return 0;
 166:	4501                	li	a0,0
}
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret
  return 0;
 16e:	4501                	li	a0,0
 170:	bfe5                	j	168 <strchr+0x1a>

0000000000000172 <gets>:

char*
gets(char *buf, int max)
{
 172:	711d                	addi	sp,sp,-96
 174:	ec86                	sd	ra,88(sp)
 176:	e8a2                	sd	s0,80(sp)
 178:	e4a6                	sd	s1,72(sp)
 17a:	e0ca                	sd	s2,64(sp)
 17c:	fc4e                	sd	s3,56(sp)
 17e:	f852                	sd	s4,48(sp)
 180:	f456                	sd	s5,40(sp)
 182:	f05a                	sd	s6,32(sp)
 184:	ec5e                	sd	s7,24(sp)
 186:	1080                	addi	s0,sp,96
 188:	8baa                	mv	s7,a0
 18a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18c:	892a                	mv	s2,a0
 18e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 190:	4aa9                	li	s5,10
 192:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 194:	89a6                	mv	s3,s1
 196:	2485                	addiw	s1,s1,1
 198:	0344d863          	bge	s1,s4,1c8 <gets+0x56>
    cc = read(0, &c, 1);
 19c:	4605                	li	a2,1
 19e:	faf40593          	addi	a1,s0,-81
 1a2:	4501                	li	a0,0
 1a4:	00000097          	auipc	ra,0x0
 1a8:	19c080e7          	jalr	412(ra) # 340 <read>
    if(cc < 1)
 1ac:	00a05e63          	blez	a0,1c8 <gets+0x56>
    buf[i++] = c;
 1b0:	faf44783          	lbu	a5,-81(s0)
 1b4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b8:	01578763          	beq	a5,s5,1c6 <gets+0x54>
 1bc:	0905                	addi	s2,s2,1
 1be:	fd679be3          	bne	a5,s6,194 <gets+0x22>
  for(i=0; i+1 < max; ){
 1c2:	89a6                	mv	s3,s1
 1c4:	a011                	j	1c8 <gets+0x56>
 1c6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c8:	99de                	add	s3,s3,s7
 1ca:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ce:	855e                	mv	a0,s7
 1d0:	60e6                	ld	ra,88(sp)
 1d2:	6446                	ld	s0,80(sp)
 1d4:	64a6                	ld	s1,72(sp)
 1d6:	6906                	ld	s2,64(sp)
 1d8:	79e2                	ld	s3,56(sp)
 1da:	7a42                	ld	s4,48(sp)
 1dc:	7aa2                	ld	s5,40(sp)
 1de:	7b02                	ld	s6,32(sp)
 1e0:	6be2                	ld	s7,24(sp)
 1e2:	6125                	addi	sp,sp,96
 1e4:	8082                	ret

00000000000001e6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e6:	1101                	addi	sp,sp,-32
 1e8:	ec06                	sd	ra,24(sp)
 1ea:	e822                	sd	s0,16(sp)
 1ec:	e426                	sd	s1,8(sp)
 1ee:	e04a                	sd	s2,0(sp)
 1f0:	1000                	addi	s0,sp,32
 1f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f4:	4581                	li	a1,0
 1f6:	00000097          	auipc	ra,0x0
 1fa:	172080e7          	jalr	370(ra) # 368 <open>
  if(fd < 0)
 1fe:	02054563          	bltz	a0,228 <stat+0x42>
 202:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 204:	85ca                	mv	a1,s2
 206:	00000097          	auipc	ra,0x0
 20a:	17a080e7          	jalr	378(ra) # 380 <fstat>
 20e:	892a                	mv	s2,a0
  close(fd);
 210:	8526                	mv	a0,s1
 212:	00000097          	auipc	ra,0x0
 216:	13e080e7          	jalr	318(ra) # 350 <close>
  return r;
}
 21a:	854a                	mv	a0,s2
 21c:	60e2                	ld	ra,24(sp)
 21e:	6442                	ld	s0,16(sp)
 220:	64a2                	ld	s1,8(sp)
 222:	6902                	ld	s2,0(sp)
 224:	6105                	addi	sp,sp,32
 226:	8082                	ret
    return -1;
 228:	597d                	li	s2,-1
 22a:	bfc5                	j	21a <stat+0x34>

000000000000022c <atoi>:

int
atoi(const char *s)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 232:	00054603          	lbu	a2,0(a0)
 236:	fd06079b          	addiw	a5,a2,-48
 23a:	0ff7f793          	andi	a5,a5,255
 23e:	4725                	li	a4,9
 240:	02f76963          	bltu	a4,a5,272 <atoi+0x46>
 244:	86aa                	mv	a3,a0
  n = 0;
 246:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 248:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 24a:	0685                	addi	a3,a3,1
 24c:	0025179b          	slliw	a5,a0,0x2
 250:	9fa9                	addw	a5,a5,a0
 252:	0017979b          	slliw	a5,a5,0x1
 256:	9fb1                	addw	a5,a5,a2
 258:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25c:	0006c603          	lbu	a2,0(a3)
 260:	fd06071b          	addiw	a4,a2,-48
 264:	0ff77713          	andi	a4,a4,255
 268:	fee5f1e3          	bgeu	a1,a4,24a <atoi+0x1e>
  return n;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  n = 0;
 272:	4501                	li	a0,0
 274:	bfe5                	j	26c <atoi+0x40>

0000000000000276 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 27c:	02b57463          	bgeu	a0,a1,2a4 <memmove+0x2e>
    while(n-- > 0)
 280:	00c05f63          	blez	a2,29e <memmove+0x28>
 284:	1602                	slli	a2,a2,0x20
 286:	9201                	srli	a2,a2,0x20
 288:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 28c:	872a                	mv	a4,a0
      *dst++ = *src++;
 28e:	0585                	addi	a1,a1,1
 290:	0705                	addi	a4,a4,1
 292:	fff5c683          	lbu	a3,-1(a1)
 296:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29a:	fee79ae3          	bne	a5,a4,28e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
    dst += n;
 2a4:	00c50733          	add	a4,a0,a2
    src += n;
 2a8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2aa:	fec05ae3          	blez	a2,29e <memmove+0x28>
 2ae:	fff6079b          	addiw	a5,a2,-1
 2b2:	1782                	slli	a5,a5,0x20
 2b4:	9381                	srli	a5,a5,0x20
 2b6:	fff7c793          	not	a5,a5
 2ba:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2bc:	15fd                	addi	a1,a1,-1
 2be:	177d                	addi	a4,a4,-1
 2c0:	0005c683          	lbu	a3,0(a1)
 2c4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c8:	fee79ae3          	bne	a5,a4,2bc <memmove+0x46>
 2cc:	bfc9                	j	29e <memmove+0x28>

00000000000002ce <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d4:	ca05                	beqz	a2,304 <memcmp+0x36>
 2d6:	fff6069b          	addiw	a3,a2,-1
 2da:	1682                	slli	a3,a3,0x20
 2dc:	9281                	srli	a3,a3,0x20
 2de:	0685                	addi	a3,a3,1
 2e0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e2:	00054783          	lbu	a5,0(a0)
 2e6:	0005c703          	lbu	a4,0(a1)
 2ea:	00e79863          	bne	a5,a4,2fa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ee:	0505                	addi	a0,a0,1
    p2++;
 2f0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f2:	fed518e3          	bne	a0,a3,2e2 <memcmp+0x14>
  }
  return 0;
 2f6:	4501                	li	a0,0
 2f8:	a019                	j	2fe <memcmp+0x30>
      return *p1 - *p2;
 2fa:	40e7853b          	subw	a0,a5,a4
}
 2fe:	6422                	ld	s0,8(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
  return 0;
 304:	4501                	li	a0,0
 306:	bfe5                	j	2fe <memcmp+0x30>

0000000000000308 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 310:	00000097          	auipc	ra,0x0
 314:	f66080e7          	jalr	-154(ra) # 276 <memmove>
}
 318:	60a2                	ld	ra,8(sp)
 31a:	6402                	ld	s0,0(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret

0000000000000320 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 320:	4885                	li	a7,1
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <exit>:
.global exit
exit:
 li a7, SYS_exit
 328:	4889                	li	a7,2
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <wait>:
.global wait
wait:
 li a7, SYS_wait
 330:	488d                	li	a7,3
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 338:	4891                	li	a7,4
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <read>:
.global read
read:
 li a7, SYS_read
 340:	4895                	li	a7,5
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <write>:
.global write
write:
 li a7, SYS_write
 348:	48c1                	li	a7,16
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <close>:
.global close
close:
 li a7, SYS_close
 350:	48d5                	li	a7,21
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <kill>:
.global kill
kill:
 li a7, SYS_kill
 358:	4899                	li	a7,6
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <exec>:
.global exec
exec:
 li a7, SYS_exec
 360:	489d                	li	a7,7
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <open>:
.global open
open:
 li a7, SYS_open
 368:	48bd                	li	a7,15
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 370:	48c5                	li	a7,17
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 378:	48c9                	li	a7,18
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 380:	48a1                	li	a7,8
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <link>:
.global link
link:
 li a7, SYS_link
 388:	48cd                	li	a7,19
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 390:	48d1                	li	a7,20
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 398:	48a5                	li	a7,9
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a0:	48a9                	li	a7,10
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a8:	48ad                	li	a7,11
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b0:	48b1                	li	a7,12
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b8:	48b5                	li	a7,13
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c0:	48b9                	li	a7,14
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
 3c8:	48d9                	li	a7,22
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
 3d0:	48dd                	li	a7,23
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <kthread_kill>:
.global kthread_kill
kthread_kill:
 li a7, SYS_kthread_kill
 3d8:	48e1                	li	a7,24
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
 3e0:	48e5                	li	a7,25
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
 3e8:	48e9                	li	a7,26
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f0:	1101                	addi	sp,sp,-32
 3f2:	ec06                	sd	ra,24(sp)
 3f4:	e822                	sd	s0,16(sp)
 3f6:	1000                	addi	s0,sp,32
 3f8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3fc:	4605                	li	a2,1
 3fe:	fef40593          	addi	a1,s0,-17
 402:	00000097          	auipc	ra,0x0
 406:	f46080e7          	jalr	-186(ra) # 348 <write>
}
 40a:	60e2                	ld	ra,24(sp)
 40c:	6442                	ld	s0,16(sp)
 40e:	6105                	addi	sp,sp,32
 410:	8082                	ret

0000000000000412 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 412:	7139                	addi	sp,sp,-64
 414:	fc06                	sd	ra,56(sp)
 416:	f822                	sd	s0,48(sp)
 418:	f426                	sd	s1,40(sp)
 41a:	f04a                	sd	s2,32(sp)
 41c:	ec4e                	sd	s3,24(sp)
 41e:	0080                	addi	s0,sp,64
 420:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 422:	c299                	beqz	a3,428 <printint+0x16>
 424:	0805c863          	bltz	a1,4b4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 428:	2581                	sext.w	a1,a1
  neg = 0;
 42a:	4881                	li	a7,0
 42c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 430:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 432:	2601                	sext.w	a2,a2
 434:	00000517          	auipc	a0,0x0
 438:	7ec50513          	addi	a0,a0,2028 # c20 <digits>
 43c:	883a                	mv	a6,a4
 43e:	2705                	addiw	a4,a4,1
 440:	02c5f7bb          	remuw	a5,a1,a2
 444:	1782                	slli	a5,a5,0x20
 446:	9381                	srli	a5,a5,0x20
 448:	97aa                	add	a5,a5,a0
 44a:	0007c783          	lbu	a5,0(a5)
 44e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 452:	0005879b          	sext.w	a5,a1
 456:	02c5d5bb          	divuw	a1,a1,a2
 45a:	0685                	addi	a3,a3,1
 45c:	fec7f0e3          	bgeu	a5,a2,43c <printint+0x2a>
  if(neg)
 460:	00088b63          	beqz	a7,476 <printint+0x64>
    buf[i++] = '-';
 464:	fd040793          	addi	a5,s0,-48
 468:	973e                	add	a4,a4,a5
 46a:	02d00793          	li	a5,45
 46e:	fef70823          	sb	a5,-16(a4)
 472:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 476:	02e05863          	blez	a4,4a6 <printint+0x94>
 47a:	fc040793          	addi	a5,s0,-64
 47e:	00e78933          	add	s2,a5,a4
 482:	fff78993          	addi	s3,a5,-1
 486:	99ba                	add	s3,s3,a4
 488:	377d                	addiw	a4,a4,-1
 48a:	1702                	slli	a4,a4,0x20
 48c:	9301                	srli	a4,a4,0x20
 48e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 492:	fff94583          	lbu	a1,-1(s2)
 496:	8526                	mv	a0,s1
 498:	00000097          	auipc	ra,0x0
 49c:	f58080e7          	jalr	-168(ra) # 3f0 <putc>
  while(--i >= 0)
 4a0:	197d                	addi	s2,s2,-1
 4a2:	ff3918e3          	bne	s2,s3,492 <printint+0x80>
}
 4a6:	70e2                	ld	ra,56(sp)
 4a8:	7442                	ld	s0,48(sp)
 4aa:	74a2                	ld	s1,40(sp)
 4ac:	7902                	ld	s2,32(sp)
 4ae:	69e2                	ld	s3,24(sp)
 4b0:	6121                	addi	sp,sp,64
 4b2:	8082                	ret
    x = -xx;
 4b4:	40b005bb          	negw	a1,a1
    neg = 1;
 4b8:	4885                	li	a7,1
    x = -xx;
 4ba:	bf8d                	j	42c <printint+0x1a>

00000000000004bc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4bc:	7119                	addi	sp,sp,-128
 4be:	fc86                	sd	ra,120(sp)
 4c0:	f8a2                	sd	s0,112(sp)
 4c2:	f4a6                	sd	s1,104(sp)
 4c4:	f0ca                	sd	s2,96(sp)
 4c6:	ecce                	sd	s3,88(sp)
 4c8:	e8d2                	sd	s4,80(sp)
 4ca:	e4d6                	sd	s5,72(sp)
 4cc:	e0da                	sd	s6,64(sp)
 4ce:	fc5e                	sd	s7,56(sp)
 4d0:	f862                	sd	s8,48(sp)
 4d2:	f466                	sd	s9,40(sp)
 4d4:	f06a                	sd	s10,32(sp)
 4d6:	ec6e                	sd	s11,24(sp)
 4d8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4da:	0005c903          	lbu	s2,0(a1)
 4de:	18090f63          	beqz	s2,67c <vprintf+0x1c0>
 4e2:	8aaa                	mv	s5,a0
 4e4:	8b32                	mv	s6,a2
 4e6:	00158493          	addi	s1,a1,1
  state = 0;
 4ea:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ec:	02500a13          	li	s4,37
      if(c == 'd'){
 4f0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4f4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4f8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4fc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 500:	00000b97          	auipc	s7,0x0
 504:	720b8b93          	addi	s7,s7,1824 # c20 <digits>
 508:	a839                	j	526 <vprintf+0x6a>
        putc(fd, c);
 50a:	85ca                	mv	a1,s2
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	ee2080e7          	jalr	-286(ra) # 3f0 <putc>
 516:	a019                	j	51c <vprintf+0x60>
    } else if(state == '%'){
 518:	01498f63          	beq	s3,s4,536 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 51c:	0485                	addi	s1,s1,1
 51e:	fff4c903          	lbu	s2,-1(s1)
 522:	14090d63          	beqz	s2,67c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 526:	0009079b          	sext.w	a5,s2
    if(state == 0){
 52a:	fe0997e3          	bnez	s3,518 <vprintf+0x5c>
      if(c == '%'){
 52e:	fd479ee3          	bne	a5,s4,50a <vprintf+0x4e>
        state = '%';
 532:	89be                	mv	s3,a5
 534:	b7e5                	j	51c <vprintf+0x60>
      if(c == 'd'){
 536:	05878063          	beq	a5,s8,576 <vprintf+0xba>
      } else if(c == 'l') {
 53a:	05978c63          	beq	a5,s9,592 <vprintf+0xd6>
      } else if(c == 'x') {
 53e:	07a78863          	beq	a5,s10,5ae <vprintf+0xf2>
      } else if(c == 'p') {
 542:	09b78463          	beq	a5,s11,5ca <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 546:	07300713          	li	a4,115
 54a:	0ce78663          	beq	a5,a4,616 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 54e:	06300713          	li	a4,99
 552:	0ee78e63          	beq	a5,a4,64e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 556:	11478863          	beq	a5,s4,666 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 55a:	85d2                	mv	a1,s4
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	e92080e7          	jalr	-366(ra) # 3f0 <putc>
        putc(fd, c);
 566:	85ca                	mv	a1,s2
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	e86080e7          	jalr	-378(ra) # 3f0 <putc>
      }
      state = 0;
 572:	4981                	li	s3,0
 574:	b765                	j	51c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 576:	008b0913          	addi	s2,s6,8
 57a:	4685                	li	a3,1
 57c:	4629                	li	a2,10
 57e:	000b2583          	lw	a1,0(s6)
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	e8e080e7          	jalr	-370(ra) # 412 <printint>
 58c:	8b4a                	mv	s6,s2
      state = 0;
 58e:	4981                	li	s3,0
 590:	b771                	j	51c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 592:	008b0913          	addi	s2,s6,8
 596:	4681                	li	a3,0
 598:	4629                	li	a2,10
 59a:	000b2583          	lw	a1,0(s6)
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	e72080e7          	jalr	-398(ra) # 412 <printint>
 5a8:	8b4a                	mv	s6,s2
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	bf85                	j	51c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5ae:	008b0913          	addi	s2,s6,8
 5b2:	4681                	li	a3,0
 5b4:	4641                	li	a2,16
 5b6:	000b2583          	lw	a1,0(s6)
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	e56080e7          	jalr	-426(ra) # 412 <printint>
 5c4:	8b4a                	mv	s6,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bf91                	j	51c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5ca:	008b0793          	addi	a5,s6,8
 5ce:	f8f43423          	sd	a5,-120(s0)
 5d2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5d6:	03000593          	li	a1,48
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	e14080e7          	jalr	-492(ra) # 3f0 <putc>
  putc(fd, 'x');
 5e4:	85ea                	mv	a1,s10
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	e08080e7          	jalr	-504(ra) # 3f0 <putc>
 5f0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f2:	03c9d793          	srli	a5,s3,0x3c
 5f6:	97de                	add	a5,a5,s7
 5f8:	0007c583          	lbu	a1,0(a5)
 5fc:	8556                	mv	a0,s5
 5fe:	00000097          	auipc	ra,0x0
 602:	df2080e7          	jalr	-526(ra) # 3f0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 606:	0992                	slli	s3,s3,0x4
 608:	397d                	addiw	s2,s2,-1
 60a:	fe0914e3          	bnez	s2,5f2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 60e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 612:	4981                	li	s3,0
 614:	b721                	j	51c <vprintf+0x60>
        s = va_arg(ap, char*);
 616:	008b0993          	addi	s3,s6,8
 61a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 61e:	02090163          	beqz	s2,640 <vprintf+0x184>
        while(*s != 0){
 622:	00094583          	lbu	a1,0(s2)
 626:	c9a1                	beqz	a1,676 <vprintf+0x1ba>
          putc(fd, *s);
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	dc6080e7          	jalr	-570(ra) # 3f0 <putc>
          s++;
 632:	0905                	addi	s2,s2,1
        while(*s != 0){
 634:	00094583          	lbu	a1,0(s2)
 638:	f9e5                	bnez	a1,628 <vprintf+0x16c>
        s = va_arg(ap, char*);
 63a:	8b4e                	mv	s6,s3
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bdf9                	j	51c <vprintf+0x60>
          s = "(null)";
 640:	00000917          	auipc	s2,0x0
 644:	5d890913          	addi	s2,s2,1496 # c18 <uthread_self+0x60>
        while(*s != 0){
 648:	02800593          	li	a1,40
 64c:	bff1                	j	628 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 64e:	008b0913          	addi	s2,s6,8
 652:	000b4583          	lbu	a1,0(s6)
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	d98080e7          	jalr	-616(ra) # 3f0 <putc>
 660:	8b4a                	mv	s6,s2
      state = 0;
 662:	4981                	li	s3,0
 664:	bd65                	j	51c <vprintf+0x60>
        putc(fd, c);
 666:	85d2                	mv	a1,s4
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	d86080e7          	jalr	-634(ra) # 3f0 <putc>
      state = 0;
 672:	4981                	li	s3,0
 674:	b565                	j	51c <vprintf+0x60>
        s = va_arg(ap, char*);
 676:	8b4e                	mv	s6,s3
      state = 0;
 678:	4981                	li	s3,0
 67a:	b54d                	j	51c <vprintf+0x60>
    }
  }
}
 67c:	70e6                	ld	ra,120(sp)
 67e:	7446                	ld	s0,112(sp)
 680:	74a6                	ld	s1,104(sp)
 682:	7906                	ld	s2,96(sp)
 684:	69e6                	ld	s3,88(sp)
 686:	6a46                	ld	s4,80(sp)
 688:	6aa6                	ld	s5,72(sp)
 68a:	6b06                	ld	s6,64(sp)
 68c:	7be2                	ld	s7,56(sp)
 68e:	7c42                	ld	s8,48(sp)
 690:	7ca2                	ld	s9,40(sp)
 692:	7d02                	ld	s10,32(sp)
 694:	6de2                	ld	s11,24(sp)
 696:	6109                	addi	sp,sp,128
 698:	8082                	ret

000000000000069a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 69a:	715d                	addi	sp,sp,-80
 69c:	ec06                	sd	ra,24(sp)
 69e:	e822                	sd	s0,16(sp)
 6a0:	1000                	addi	s0,sp,32
 6a2:	e010                	sd	a2,0(s0)
 6a4:	e414                	sd	a3,8(s0)
 6a6:	e818                	sd	a4,16(s0)
 6a8:	ec1c                	sd	a5,24(s0)
 6aa:	03043023          	sd	a6,32(s0)
 6ae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6b2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b6:	8622                	mv	a2,s0
 6b8:	00000097          	auipc	ra,0x0
 6bc:	e04080e7          	jalr	-508(ra) # 4bc <vprintf>
}
 6c0:	60e2                	ld	ra,24(sp)
 6c2:	6442                	ld	s0,16(sp)
 6c4:	6161                	addi	sp,sp,80
 6c6:	8082                	ret

00000000000006c8 <printf>:

void
printf(const char *fmt, ...)
{
 6c8:	711d                	addi	sp,sp,-96
 6ca:	ec06                	sd	ra,24(sp)
 6cc:	e822                	sd	s0,16(sp)
 6ce:	1000                	addi	s0,sp,32
 6d0:	e40c                	sd	a1,8(s0)
 6d2:	e810                	sd	a2,16(s0)
 6d4:	ec14                	sd	a3,24(s0)
 6d6:	f018                	sd	a4,32(s0)
 6d8:	f41c                	sd	a5,40(s0)
 6da:	03043823          	sd	a6,48(s0)
 6de:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6e2:	00840613          	addi	a2,s0,8
 6e6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6ea:	85aa                	mv	a1,a0
 6ec:	4505                	li	a0,1
 6ee:	00000097          	auipc	ra,0x0
 6f2:	dce080e7          	jalr	-562(ra) # 4bc <vprintf>
}
 6f6:	60e2                	ld	ra,24(sp)
 6f8:	6442                	ld	s0,16(sp)
 6fa:	6125                	addi	sp,sp,96
 6fc:	8082                	ret

00000000000006fe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6fe:	1141                	addi	sp,sp,-16
 700:	e422                	sd	s0,8(sp)
 702:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 704:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 708:	00001797          	auipc	a5,0x1
 70c:	8f87b783          	ld	a5,-1800(a5) # 1000 <freep>
 710:	a805                	j	740 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 712:	4618                	lw	a4,8(a2)
 714:	9db9                	addw	a1,a1,a4
 716:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 71a:	6398                	ld	a4,0(a5)
 71c:	6318                	ld	a4,0(a4)
 71e:	fee53823          	sd	a4,-16(a0)
 722:	a091                	j	766 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 724:	ff852703          	lw	a4,-8(a0)
 728:	9e39                	addw	a2,a2,a4
 72a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 72c:	ff053703          	ld	a4,-16(a0)
 730:	e398                	sd	a4,0(a5)
 732:	a099                	j	778 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 734:	6398                	ld	a4,0(a5)
 736:	00e7e463          	bltu	a5,a4,73e <free+0x40>
 73a:	00e6ea63          	bltu	a3,a4,74e <free+0x50>
{
 73e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 740:	fed7fae3          	bgeu	a5,a3,734 <free+0x36>
 744:	6398                	ld	a4,0(a5)
 746:	00e6e463          	bltu	a3,a4,74e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74a:	fee7eae3          	bltu	a5,a4,73e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 74e:	ff852583          	lw	a1,-8(a0)
 752:	6390                	ld	a2,0(a5)
 754:	02059713          	slli	a4,a1,0x20
 758:	9301                	srli	a4,a4,0x20
 75a:	0712                	slli	a4,a4,0x4
 75c:	9736                	add	a4,a4,a3
 75e:	fae60ae3          	beq	a2,a4,712 <free+0x14>
    bp->s.ptr = p->s.ptr;
 762:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 766:	4790                	lw	a2,8(a5)
 768:	02061713          	slli	a4,a2,0x20
 76c:	9301                	srli	a4,a4,0x20
 76e:	0712                	slli	a4,a4,0x4
 770:	973e                	add	a4,a4,a5
 772:	fae689e3          	beq	a3,a4,724 <free+0x26>
  } else
    p->s.ptr = bp;
 776:	e394                	sd	a3,0(a5)
  freep = p;
 778:	00001717          	auipc	a4,0x1
 77c:	88f73423          	sd	a5,-1912(a4) # 1000 <freep>
}
 780:	6422                	ld	s0,8(sp)
 782:	0141                	addi	sp,sp,16
 784:	8082                	ret

0000000000000786 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 786:	7139                	addi	sp,sp,-64
 788:	fc06                	sd	ra,56(sp)
 78a:	f822                	sd	s0,48(sp)
 78c:	f426                	sd	s1,40(sp)
 78e:	f04a                	sd	s2,32(sp)
 790:	ec4e                	sd	s3,24(sp)
 792:	e852                	sd	s4,16(sp)
 794:	e456                	sd	s5,8(sp)
 796:	e05a                	sd	s6,0(sp)
 798:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79a:	02051493          	slli	s1,a0,0x20
 79e:	9081                	srli	s1,s1,0x20
 7a0:	04bd                	addi	s1,s1,15
 7a2:	8091                	srli	s1,s1,0x4
 7a4:	0014899b          	addiw	s3,s1,1
 7a8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7aa:	00001517          	auipc	a0,0x1
 7ae:	85653503          	ld	a0,-1962(a0) # 1000 <freep>
 7b2:	c515                	beqz	a0,7de <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b6:	4798                	lw	a4,8(a5)
 7b8:	02977f63          	bgeu	a4,s1,7f6 <malloc+0x70>
 7bc:	8a4e                	mv	s4,s3
 7be:	0009871b          	sext.w	a4,s3
 7c2:	6685                	lui	a3,0x1
 7c4:	00d77363          	bgeu	a4,a3,7ca <malloc+0x44>
 7c8:	6a05                	lui	s4,0x1
 7ca:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ce:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d2:	00001917          	auipc	s2,0x1
 7d6:	82e90913          	addi	s2,s2,-2002 # 1000 <freep>
  if(p == (char*)-1)
 7da:	5afd                	li	s5,-1
 7dc:	a88d                	j	84e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7de:	00001797          	auipc	a5,0x1
 7e2:	84278793          	addi	a5,a5,-1982 # 1020 <base>
 7e6:	00001717          	auipc	a4,0x1
 7ea:	80f73d23          	sd	a5,-2022(a4) # 1000 <freep>
 7ee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7f0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f4:	b7e1                	j	7bc <malloc+0x36>
      if(p->s.size == nunits)
 7f6:	02e48b63          	beq	s1,a4,82c <malloc+0xa6>
        p->s.size -= nunits;
 7fa:	4137073b          	subw	a4,a4,s3
 7fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 800:	1702                	slli	a4,a4,0x20
 802:	9301                	srli	a4,a4,0x20
 804:	0712                	slli	a4,a4,0x4
 806:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 808:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 80c:	00000717          	auipc	a4,0x0
 810:	7ea73a23          	sd	a0,2036(a4) # 1000 <freep>
      return (void*)(p + 1);
 814:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 818:	70e2                	ld	ra,56(sp)
 81a:	7442                	ld	s0,48(sp)
 81c:	74a2                	ld	s1,40(sp)
 81e:	7902                	ld	s2,32(sp)
 820:	69e2                	ld	s3,24(sp)
 822:	6a42                	ld	s4,16(sp)
 824:	6aa2                	ld	s5,8(sp)
 826:	6b02                	ld	s6,0(sp)
 828:	6121                	addi	sp,sp,64
 82a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 82c:	6398                	ld	a4,0(a5)
 82e:	e118                	sd	a4,0(a0)
 830:	bff1                	j	80c <malloc+0x86>
  hp->s.size = nu;
 832:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 836:	0541                	addi	a0,a0,16
 838:	00000097          	auipc	ra,0x0
 83c:	ec6080e7          	jalr	-314(ra) # 6fe <free>
  return freep;
 840:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 844:	d971                	beqz	a0,818 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 846:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 848:	4798                	lw	a4,8(a5)
 84a:	fa9776e3          	bgeu	a4,s1,7f6 <malloc+0x70>
    if(p == freep)
 84e:	00093703          	ld	a4,0(s2)
 852:	853e                	mv	a0,a5
 854:	fef719e3          	bne	a4,a5,846 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 858:	8552                	mv	a0,s4
 85a:	00000097          	auipc	ra,0x0
 85e:	b56080e7          	jalr	-1194(ra) # 3b0 <sbrk>
  if(p == (char*)-1)
 862:	fd5518e3          	bne	a0,s5,832 <malloc+0xac>
        return 0;
 866:	4501                	li	a0,0
 868:	bf45                	j	818 <malloc+0x92>

000000000000086a <uswtch>:
 86a:	00153023          	sd	ra,0(a0)
 86e:	00253423          	sd	sp,8(a0)
 872:	e900                	sd	s0,16(a0)
 874:	ed04                	sd	s1,24(a0)
 876:	03253023          	sd	s2,32(a0)
 87a:	03353423          	sd	s3,40(a0)
 87e:	03453823          	sd	s4,48(a0)
 882:	03553c23          	sd	s5,56(a0)
 886:	05653023          	sd	s6,64(a0)
 88a:	05753423          	sd	s7,72(a0)
 88e:	05853823          	sd	s8,80(a0)
 892:	05953c23          	sd	s9,88(a0)
 896:	07a53023          	sd	s10,96(a0)
 89a:	07b53423          	sd	s11,104(a0)
 89e:	0005b083          	ld	ra,0(a1)
 8a2:	0085b103          	ld	sp,8(a1)
 8a6:	6980                	ld	s0,16(a1)
 8a8:	6d84                	ld	s1,24(a1)
 8aa:	0205b903          	ld	s2,32(a1)
 8ae:	0285b983          	ld	s3,40(a1)
 8b2:	0305ba03          	ld	s4,48(a1)
 8b6:	0385ba83          	ld	s5,56(a1)
 8ba:	0405bb03          	ld	s6,64(a1)
 8be:	0485bb83          	ld	s7,72(a1)
 8c2:	0505bc03          	ld	s8,80(a1)
 8c6:	0585bc83          	ld	s9,88(a1)
 8ca:	0605bd03          	ld	s10,96(a1)
 8ce:	0685bd83          	ld	s11,104(a1)
 8d2:	8082                	ret

00000000000008d4 <uthread_exit>:
    curr_thread = next_thread;
    uswtch(curr_context, next_context);

}

void uthread_exit(){
 8d4:	1141                	addi	sp,sp,-16
 8d6:	e406                	sd	ra,8(sp)
 8d8:	e022                	sd	s0,0(sp)
 8da:	0800                	addi	s0,sp,16
    printf("in uthresd exit\n");
 8dc:	00000517          	auipc	a0,0x0
 8e0:	35c50513          	addi	a0,a0,860 # c38 <digits+0x18>
 8e4:	00000097          	auipc	ra,0x0
 8e8:	de4080e7          	jalr	-540(ra) # 6c8 <printf>
    // Change the state of the current thread to FREE
    curr_thread->state = FREE;
 8ec:	00000517          	auipc	a0,0x0
 8f0:	71c53503          	ld	a0,1820(a0) # 1008 <curr_thread>
 8f4:	6785                	lui	a5,0x1
 8f6:	97aa                	add	a5,a5,a0
 8f8:	fa07a223          	sw	zero,-92(a5) # fa4 <digits+0x384>
    // Find another runnable thread to switch to (make sure its not the current_thread)
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 8fc:	411c                	lw	a5,0(a0)
 8fe:	2785                	addiw	a5,a5,1
 900:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 902:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 904:	4585                	li	a1,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 906:	00000617          	auipc	a2,0x0
 90a:	79a60613          	addi	a2,a2,1946 # 10a0 <uthreads_arr>
 90e:	6805                	lui	a6,0x1
 910:	4889                	li	a7,2
 912:	a819                	j	928 <uthread_exit+0x54>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 914:	2785                	addiw	a5,a5,1
 916:	41f7d71b          	sraiw	a4,a5,0x1f
 91a:	01e7571b          	srliw	a4,a4,0x1e
 91e:	9fb9                	addw	a5,a5,a4
 920:	8b8d                	andi	a5,a5,3
 922:	9f99                	subw	a5,a5,a4
 924:	36fd                	addiw	a3,a3,-1
 926:	ca9d                	beqz	a3,95c <uthread_exit+0x88>
        if (uthreads_arr[i].state == RUNNABLE &&
 928:	00779713          	slli	a4,a5,0x7
 92c:	973e                	add	a4,a4,a5
 92e:	0716                	slli	a4,a4,0x5
 930:	9732                	add	a4,a4,a2
 932:	9742                	add	a4,a4,a6
 934:	fa472703          	lw	a4,-92(a4)
 938:	fd171ee3          	bne	a4,a7,914 <uthread_exit+0x40>
            uthreads_arr[i].priority > max_priority) {
 93c:	00779713          	slli	a4,a5,0x7
 940:	973e                	add	a4,a4,a5
 942:	0716                	slli	a4,a4,0x5
 944:	9732                	add	a4,a4,a2
 946:	9742                	add	a4,a4,a6
 948:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 94a:	fce375e3          	bgeu	t1,a4,914 <uthread_exit+0x40>
            next_thread = &uthreads_arr[i];
 94e:	00779593          	slli	a1,a5,0x7
 952:	95be                	add	a1,a1,a5
 954:	0596                	slli	a1,a1,0x5
 956:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 958:	833a                	mv	t1,a4
 95a:	bf6d                	j	914 <uthread_exit+0x40>
        }
    }
    if (next_thread == (struct uthread *) 1) {
 95c:	4785                	li	a5,1
 95e:	02f58863          	beq	a1,a5,98e <uthread_exit+0xba>
        exit(0);  // Exit the process if there are no more runnable threads
    }
    // Switch to the next thread
    struct context *curr_context = &curr_thread->context;
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 962:	6785                	lui	a5,0x1
 964:	00f58733          	add	a4,a1,a5
 968:	4685                	li	a3,1
 96a:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 96e:	00000717          	auipc	a4,0x0
 972:	68b73d23          	sd	a1,1690(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 976:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x388>
    uswtch(curr_context, next_context);
 97a:	95be                	add	a1,a1,a5
 97c:	953e                	add	a0,a0,a5
 97e:	00000097          	auipc	ra,0x0
 982:	eec080e7          	jalr	-276(ra) # 86a <uswtch>
}
 986:	60a2                	ld	ra,8(sp)
 988:	6402                	ld	s0,0(sp)
 98a:	0141                	addi	sp,sp,16
 98c:	8082                	ret
        exit(0);  // Exit the process if there are no more runnable threads
 98e:	4501                	li	a0,0
 990:	00000097          	auipc	ra,0x0
 994:	998080e7          	jalr	-1640(ra) # 328 <exit>

0000000000000998 <uthread_create>:
int uthread_create(void (*start_func)(), enum sched_priority priority) {
 998:	1141                	addi	sp,sp,-16
 99a:	e422                	sd	s0,8(sp)
 99c:	0800                	addi	s0,sp,16
    for (i = 0; i < MAX_UTHREADS; i++) {
 99e:	00001717          	auipc	a4,0x1
 9a2:	6a670713          	addi	a4,a4,1702 # 2044 <uthreads_arr+0xfa4>
 9a6:	4781                	li	a5,0
 9a8:	6605                	lui	a2,0x1
 9aa:	02060613          	addi	a2,a2,32 # 1020 <base>
 9ae:	4811                	li	a6,4
        if (uthreads_arr[i].state == FREE) {
 9b0:	4314                	lw	a3,0(a4)
 9b2:	c699                	beqz	a3,9c0 <uthread_create+0x28>
    for (i = 0; i < MAX_UTHREADS; i++) {
 9b4:	2785                	addiw	a5,a5,1
 9b6:	9732                	add	a4,a4,a2
 9b8:	ff079ce3          	bne	a5,a6,9b0 <uthread_create+0x18>
        return -1;
 9bc:	557d                	li	a0,-1
 9be:	a0b9                	j	a0c <uthread_create+0x74>
            curr_thread = &uthreads_arr[i];
 9c0:	00779713          	slli	a4,a5,0x7
 9c4:	973e                	add	a4,a4,a5
 9c6:	0716                	slli	a4,a4,0x5
 9c8:	00000697          	auipc	a3,0x0
 9cc:	6d868693          	addi	a3,a3,1752 # 10a0 <uthreads_arr>
 9d0:	9736                	add	a4,a4,a3
 9d2:	00000697          	auipc	a3,0x0
 9d6:	62e6bb23          	sd	a4,1590(a3) # 1008 <curr_thread>
    if (i >= MAX_UTHREADS) {
 9da:	468d                	li	a3,3
 9dc:	02f6cb63          	blt	a3,a5,a12 <uthread_create+0x7a>
    curr_thread->id = i; 
 9e0:	c31c                	sw	a5,0(a4)
    curr_thread->priority = priority;
 9e2:	6685                	lui	a3,0x1
 9e4:	00d707b3          	add	a5,a4,a3
 9e8:	cf8c                	sw	a1,24(a5)
    curr_thread->context.ra = (uint64) start_func;
 9ea:	faa7b423          	sd	a0,-88(a5)
    curr_thread->context.sp = (uint64) &curr_thread->ustack[STACK_SIZE];
 9ee:	fa468693          	addi	a3,a3,-92 # fa4 <digits+0x384>
 9f2:	9736                	add	a4,a4,a3
 9f4:	fae7b823          	sd	a4,-80(a5)
    curr_thread->ustack[STACK_SIZE - 1] = (uint64) uthread_exit; // Return address to uthread_exit
 9f8:	00000717          	auipc	a4,0x0
 9fc:	edc70713          	addi	a4,a4,-292 # 8d4 <uthread_exit>
 a00:	fae781a3          	sb	a4,-93(a5)
    curr_thread->state = RUNNABLE;
 a04:	4709                	li	a4,2
 a06:	fae7a223          	sw	a4,-92(a5)
     return 0;
 a0a:	4501                	li	a0,0
}
 a0c:	6422                	ld	s0,8(sp)
 a0e:	0141                	addi	sp,sp,16
 a10:	8082                	ret
        return -1;
 a12:	557d                	li	a0,-1
 a14:	bfe5                	j	a0c <uthread_create+0x74>

0000000000000a16 <uthread_yield>:
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 a16:	00000517          	auipc	a0,0x0
 a1a:	5f253503          	ld	a0,1522(a0) # 1008 <curr_thread>
 a1e:	411c                	lw	a5,0(a0)
 a20:	2785                	addiw	a5,a5,1
 a22:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 a24:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 a26:	4585                	li	a1,1
        if (uthreads_arr[i].state == RUNNABLE &&
 a28:	00000617          	auipc	a2,0x0
 a2c:	67860613          	addi	a2,a2,1656 # 10a0 <uthreads_arr>
 a30:	6805                	lui	a6,0x1
 a32:	4889                	li	a7,2
 a34:	a819                	j	a4a <uthread_yield+0x34>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 a36:	2785                	addiw	a5,a5,1
 a38:	41f7d71b          	sraiw	a4,a5,0x1f
 a3c:	01e7571b          	srliw	a4,a4,0x1e
 a40:	9fb9                	addw	a5,a5,a4
 a42:	8b8d                	andi	a5,a5,3
 a44:	9f99                	subw	a5,a5,a4
 a46:	36fd                	addiw	a3,a3,-1
 a48:	ca9d                	beqz	a3,a7e <uthread_yield+0x68>
        if (uthreads_arr[i].state == RUNNABLE &&
 a4a:	00779713          	slli	a4,a5,0x7
 a4e:	973e                	add	a4,a4,a5
 a50:	0716                	slli	a4,a4,0x5
 a52:	9732                	add	a4,a4,a2
 a54:	9742                	add	a4,a4,a6
 a56:	fa472703          	lw	a4,-92(a4)
 a5a:	fd171ee3          	bne	a4,a7,a36 <uthread_yield+0x20>
            uthreads_arr[i].priority > max_priority) {
 a5e:	00779713          	slli	a4,a5,0x7
 a62:	973e                	add	a4,a4,a5
 a64:	0716                	slli	a4,a4,0x5
 a66:	9732                	add	a4,a4,a2
 a68:	9742                	add	a4,a4,a6
 a6a:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 a6c:	fce375e3          	bgeu	t1,a4,a36 <uthread_yield+0x20>
            next_thread = &uthreads_arr[i];
 a70:	00779593          	slli	a1,a5,0x7
 a74:	95be                	add	a1,a1,a5
 a76:	0596                	slli	a1,a1,0x5
 a78:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 a7a:	833a                	mv	t1,a4
 a7c:	bf6d                	j	a36 <uthread_yield+0x20>
    if (next_thread == (struct uthread *) 1) {
 a7e:	4785                	li	a5,1
 a80:	04f58163          	beq	a1,a5,ac2 <uthread_yield+0xac>
void uthread_yield() {
 a84:	1141                	addi	sp,sp,-16
 a86:	e406                	sd	ra,8(sp)
 a88:	e022                	sd	s0,0(sp)
 a8a:	0800                	addi	s0,sp,16
    curr_thread->state = RUNNABLE;
 a8c:	6785                	lui	a5,0x1
 a8e:	00f50733          	add	a4,a0,a5
 a92:	4689                	li	a3,2
 a94:	fad72223          	sw	a3,-92(a4)
    next_thread->state = RUNNING;
 a98:	00f58733          	add	a4,a1,a5
 a9c:	4685                	li	a3,1
 a9e:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 aa2:	00000717          	auipc	a4,0x0
 aa6:	56b73323          	sd	a1,1382(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 aaa:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x388>
    uswtch(curr_context, next_context);
 aae:	95be                	add	a1,a1,a5
 ab0:	953e                	add	a0,a0,a5
 ab2:	00000097          	auipc	ra,0x0
 ab6:	db8080e7          	jalr	-584(ra) # 86a <uswtch>
}
 aba:	60a2                	ld	ra,8(sp)
 abc:	6402                	ld	s0,0(sp)
 abe:	0141                	addi	sp,sp,16
 ac0:	8082                	ret
 ac2:	8082                	ret

0000000000000ac4 <uthread_set_priority>:

enum sched_priority uthread_set_priority(enum sched_priority priority){
 ac4:	1141                	addi	sp,sp,-16
 ac6:	e422                	sd	s0,8(sp)
 ac8:	0800                	addi	s0,sp,16
    enum sched_priority to_return =curr_thread->priority;
 aca:	00000797          	auipc	a5,0x0
 ace:	53e7b783          	ld	a5,1342(a5) # 1008 <curr_thread>
 ad2:	6705                	lui	a4,0x1
 ad4:	97ba                	add	a5,a5,a4
 ad6:	4f98                	lw	a4,24(a5)
    curr_thread->priority=priority;
 ad8:	cf88                	sw	a0,24(a5)
    return to_return;
}
 ada:	853a                	mv	a0,a4
 adc:	6422                	ld	s0,8(sp)
 ade:	0141                	addi	sp,sp,16
 ae0:	8082                	ret

0000000000000ae2 <uthread_get_priority>:

enum sched_priority uthread_get_priority(){
 ae2:	1141                	addi	sp,sp,-16
 ae4:	e422                	sd	s0,8(sp)
 ae6:	0800                	addi	s0,sp,16
    return curr_thread->priority;
 ae8:	00000797          	auipc	a5,0x0
 aec:	5207b783          	ld	a5,1312(a5) # 1008 <curr_thread>
 af0:	6705                	lui	a4,0x1
 af2:	97ba                	add	a5,a5,a4
}
 af4:	4f88                	lw	a0,24(a5)
 af6:	6422                	ld	s0,8(sp)
 af8:	0141                	addi	sp,sp,16
 afa:	8082                	ret

0000000000000afc <uthread_start_all>:

int uthread_start_all(){
    if (started){
 afc:	00000797          	auipc	a5,0x0
 b00:	5147a783          	lw	a5,1300(a5) # 1010 <started>
 b04:	ebc5                	bnez	a5,bb4 <uthread_start_all+0xb8>
int uthread_start_all(){
 b06:	1141                	addi	sp,sp,-16
 b08:	e406                	sd	ra,8(sp)
 b0a:	e022                	sd	s0,0(sp)
 b0c:	0800                	addi	s0,sp,16
        return -1;
    }
    started=1;
 b0e:	4785                	li	a5,1
 b10:	00000717          	auipc	a4,0x0
 b14:	50f72023          	sw	a5,1280(a4) # 1010 <started>
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 b18:	00000797          	auipc	a5,0x0
 b1c:	4f07b783          	ld	a5,1264(a5) # 1008 <curr_thread>
 b20:	439c                	lw	a5,0(a5)
 b22:	2785                	addiw	a5,a5,1
 b24:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 b26:	4881                	li	a7,0
    struct uthread *next_thread = (struct uthread *) 1;
 b28:	4605                	li	a2,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 b2a:	00000597          	auipc	a1,0x0
 b2e:	57658593          	addi	a1,a1,1398 # 10a0 <uthreads_arr>
 b32:	6505                	lui	a0,0x1
 b34:	4809                	li	a6,2
 b36:	a819                	j	b4c <uthread_start_all+0x50>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 b38:	2785                	addiw	a5,a5,1
 b3a:	41f7d71b          	sraiw	a4,a5,0x1f
 b3e:	01e7571b          	srliw	a4,a4,0x1e
 b42:	9fb9                	addw	a5,a5,a4
 b44:	8b8d                	andi	a5,a5,3
 b46:	9f99                	subw	a5,a5,a4
 b48:	36fd                	addiw	a3,a3,-1
 b4a:	ca9d                	beqz	a3,b80 <uthread_start_all+0x84>
        if (uthreads_arr[i].state == RUNNABLE &&
 b4c:	00779713          	slli	a4,a5,0x7
 b50:	973e                	add	a4,a4,a5
 b52:	0716                	slli	a4,a4,0x5
 b54:	972e                	add	a4,a4,a1
 b56:	972a                	add	a4,a4,a0
 b58:	fa472703          	lw	a4,-92(a4)
 b5c:	fd071ee3          	bne	a4,a6,b38 <uthread_start_all+0x3c>
            uthreads_arr[i].priority > max_priority) {
 b60:	00779713          	slli	a4,a5,0x7
 b64:	973e                	add	a4,a4,a5
 b66:	0716                	slli	a4,a4,0x5
 b68:	972e                	add	a4,a4,a1
 b6a:	972a                	add	a4,a4,a0
 b6c:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 b6e:	fce8f5e3          	bgeu	a7,a4,b38 <uthread_start_all+0x3c>
            next_thread = &uthreads_arr[i];
 b72:	00779613          	slli	a2,a5,0x7
 b76:	963e                	add	a2,a2,a5
 b78:	0616                	slli	a2,a2,0x5
 b7a:	962e                	add	a2,a2,a1
            max_priority = uthreads_arr[i].priority;
 b7c:	88ba                	mv	a7,a4
 b7e:	bf6d                	j	b38 <uthread_start_all+0x3c>
        }
    }
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 b80:	6585                	lui	a1,0x1
 b82:	00b607b3          	add	a5,a2,a1
 b86:	4705                	li	a4,1
 b88:	fae7a223          	sw	a4,-92(a5)
    curr_thread = next_thread;
 b8c:	00000797          	auipc	a5,0x0
 b90:	46c7be23          	sd	a2,1148(a5) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 b94:	fa858593          	addi	a1,a1,-88 # fa8 <digits+0x388>
    uswtch(&garbageContext,next_context);
 b98:	95b2                	add	a1,a1,a2
 b9a:	00000517          	auipc	a0,0x0
 b9e:	49650513          	addi	a0,a0,1174 # 1030 <garbageContext>
 ba2:	00000097          	auipc	ra,0x0
 ba6:	cc8080e7          	jalr	-824(ra) # 86a <uswtch>

    return -1;
}
 baa:	557d                	li	a0,-1
 bac:	60a2                	ld	ra,8(sp)
 bae:	6402                	ld	s0,0(sp)
 bb0:	0141                	addi	sp,sp,16
 bb2:	8082                	ret
 bb4:	557d                	li	a0,-1
 bb6:	8082                	ret

0000000000000bb8 <uthread_self>:

struct uthread* uthread_self(){
 bb8:	1141                	addi	sp,sp,-16
 bba:	e422                	sd	s0,8(sp)
 bbc:	0800                	addi	s0,sp,16
    return curr_thread;
 bbe:	00000517          	auipc	a0,0x0
 bc2:	44a53503          	ld	a0,1098(a0) # 1008 <curr_thread>
 bc6:	6422                	ld	s0,8(sp)
 bc8:	0141                	addi	sp,sp,16
 bca:	8082                	ret
