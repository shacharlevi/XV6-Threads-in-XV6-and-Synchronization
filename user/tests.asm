
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
   e:	ba650513          	addi	a0,a0,-1114 # bb0 <uthread_self+0x20>
  12:	00000097          	auipc	ra,0x0
  16:	68e080e7          	jalr	1678(ra) # 6a0 <printf>
     uthread_exit();
  1a:	00001097          	auipc	ra,0x1
  1e:	892080e7          	jalr	-1902(ra) # 8ac <uthread_exit>
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
  42:	932080e7          	jalr	-1742(ra) # 970 <uthread_create>
  46:	57fd                	li	a5,-1
  48:	02f50f63          	beq	a0,a5,86 <main+0x5a>
        uthread_create((void (*)()) thread_func, arg2) == -1) {
  4c:	4589                	li	a1,2
  4e:	00000517          	auipc	a0,0x0
  52:	fb250513          	addi	a0,a0,-78 # 0 <thread_func>
  56:	00001097          	auipc	ra,0x1
  5a:	91a080e7          	jalr	-1766(ra) # 970 <uthread_create>
    if (uthread_create((void (*)()) thread_func, arg1) == -1 ||
  5e:	57fd                	li	a5,-1
  60:	02f50363          	beq	a0,a5,86 <main+0x5a>
        printf("Error creating thread\n");
        exit(1);
    }
    uthread_start_all();
  64:	00001097          	auipc	ra,0x1
  68:	a70080e7          	jalr	-1424(ra) # ad4 <uthread_start_all>
    printf("Main thread resumed\n");
  6c:	00001517          	auipc	a0,0x1
  70:	b7450513          	addi	a0,a0,-1164 # be0 <uthread_self+0x50>
  74:	00000097          	auipc	ra,0x0
  78:	62c080e7          	jalr	1580(ra) # 6a0 <printf>
    return 0;
  7c:	4501                	li	a0,0
  7e:	60a2                	ld	ra,8(sp)
  80:	6402                	ld	s0,0(sp)
  82:	0141                	addi	sp,sp,16
  84:	8082                	ret
        printf("Error creating thread\n");
  86:	00001517          	auipc	a0,0x1
  8a:	b4250513          	addi	a0,a0,-1214 # bc8 <uthread_self+0x38>
  8e:	00000097          	auipc	ra,0x0
  92:	612080e7          	jalr	1554(ra) # 6a0 <printf>
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

00000000000003c8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3c8:	1101                	addi	sp,sp,-32
 3ca:	ec06                	sd	ra,24(sp)
 3cc:	e822                	sd	s0,16(sp)
 3ce:	1000                	addi	s0,sp,32
 3d0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3d4:	4605                	li	a2,1
 3d6:	fef40593          	addi	a1,s0,-17
 3da:	00000097          	auipc	ra,0x0
 3de:	f6e080e7          	jalr	-146(ra) # 348 <write>
}
 3e2:	60e2                	ld	ra,24(sp)
 3e4:	6442                	ld	s0,16(sp)
 3e6:	6105                	addi	sp,sp,32
 3e8:	8082                	ret

00000000000003ea <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ea:	7139                	addi	sp,sp,-64
 3ec:	fc06                	sd	ra,56(sp)
 3ee:	f822                	sd	s0,48(sp)
 3f0:	f426                	sd	s1,40(sp)
 3f2:	f04a                	sd	s2,32(sp)
 3f4:	ec4e                	sd	s3,24(sp)
 3f6:	0080                	addi	s0,sp,64
 3f8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3fa:	c299                	beqz	a3,400 <printint+0x16>
 3fc:	0805c863          	bltz	a1,48c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 400:	2581                	sext.w	a1,a1
  neg = 0;
 402:	4881                	li	a7,0
 404:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 408:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 40a:	2601                	sext.w	a2,a2
 40c:	00000517          	auipc	a0,0x0
 410:	7f450513          	addi	a0,a0,2036 # c00 <digits>
 414:	883a                	mv	a6,a4
 416:	2705                	addiw	a4,a4,1
 418:	02c5f7bb          	remuw	a5,a1,a2
 41c:	1782                	slli	a5,a5,0x20
 41e:	9381                	srli	a5,a5,0x20
 420:	97aa                	add	a5,a5,a0
 422:	0007c783          	lbu	a5,0(a5)
 426:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 42a:	0005879b          	sext.w	a5,a1
 42e:	02c5d5bb          	divuw	a1,a1,a2
 432:	0685                	addi	a3,a3,1
 434:	fec7f0e3          	bgeu	a5,a2,414 <printint+0x2a>
  if(neg)
 438:	00088b63          	beqz	a7,44e <printint+0x64>
    buf[i++] = '-';
 43c:	fd040793          	addi	a5,s0,-48
 440:	973e                	add	a4,a4,a5
 442:	02d00793          	li	a5,45
 446:	fef70823          	sb	a5,-16(a4)
 44a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 44e:	02e05863          	blez	a4,47e <printint+0x94>
 452:	fc040793          	addi	a5,s0,-64
 456:	00e78933          	add	s2,a5,a4
 45a:	fff78993          	addi	s3,a5,-1
 45e:	99ba                	add	s3,s3,a4
 460:	377d                	addiw	a4,a4,-1
 462:	1702                	slli	a4,a4,0x20
 464:	9301                	srli	a4,a4,0x20
 466:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 46a:	fff94583          	lbu	a1,-1(s2)
 46e:	8526                	mv	a0,s1
 470:	00000097          	auipc	ra,0x0
 474:	f58080e7          	jalr	-168(ra) # 3c8 <putc>
  while(--i >= 0)
 478:	197d                	addi	s2,s2,-1
 47a:	ff3918e3          	bne	s2,s3,46a <printint+0x80>
}
 47e:	70e2                	ld	ra,56(sp)
 480:	7442                	ld	s0,48(sp)
 482:	74a2                	ld	s1,40(sp)
 484:	7902                	ld	s2,32(sp)
 486:	69e2                	ld	s3,24(sp)
 488:	6121                	addi	sp,sp,64
 48a:	8082                	ret
    x = -xx;
 48c:	40b005bb          	negw	a1,a1
    neg = 1;
 490:	4885                	li	a7,1
    x = -xx;
 492:	bf8d                	j	404 <printint+0x1a>

0000000000000494 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 494:	7119                	addi	sp,sp,-128
 496:	fc86                	sd	ra,120(sp)
 498:	f8a2                	sd	s0,112(sp)
 49a:	f4a6                	sd	s1,104(sp)
 49c:	f0ca                	sd	s2,96(sp)
 49e:	ecce                	sd	s3,88(sp)
 4a0:	e8d2                	sd	s4,80(sp)
 4a2:	e4d6                	sd	s5,72(sp)
 4a4:	e0da                	sd	s6,64(sp)
 4a6:	fc5e                	sd	s7,56(sp)
 4a8:	f862                	sd	s8,48(sp)
 4aa:	f466                	sd	s9,40(sp)
 4ac:	f06a                	sd	s10,32(sp)
 4ae:	ec6e                	sd	s11,24(sp)
 4b0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b2:	0005c903          	lbu	s2,0(a1)
 4b6:	18090f63          	beqz	s2,654 <vprintf+0x1c0>
 4ba:	8aaa                	mv	s5,a0
 4bc:	8b32                	mv	s6,a2
 4be:	00158493          	addi	s1,a1,1
  state = 0;
 4c2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4c4:	02500a13          	li	s4,37
      if(c == 'd'){
 4c8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4cc:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4d0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4d4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4d8:	00000b97          	auipc	s7,0x0
 4dc:	728b8b93          	addi	s7,s7,1832 # c00 <digits>
 4e0:	a839                	j	4fe <vprintf+0x6a>
        putc(fd, c);
 4e2:	85ca                	mv	a1,s2
 4e4:	8556                	mv	a0,s5
 4e6:	00000097          	auipc	ra,0x0
 4ea:	ee2080e7          	jalr	-286(ra) # 3c8 <putc>
 4ee:	a019                	j	4f4 <vprintf+0x60>
    } else if(state == '%'){
 4f0:	01498f63          	beq	s3,s4,50e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4f4:	0485                	addi	s1,s1,1
 4f6:	fff4c903          	lbu	s2,-1(s1)
 4fa:	14090d63          	beqz	s2,654 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4fe:	0009079b          	sext.w	a5,s2
    if(state == 0){
 502:	fe0997e3          	bnez	s3,4f0 <vprintf+0x5c>
      if(c == '%'){
 506:	fd479ee3          	bne	a5,s4,4e2 <vprintf+0x4e>
        state = '%';
 50a:	89be                	mv	s3,a5
 50c:	b7e5                	j	4f4 <vprintf+0x60>
      if(c == 'd'){
 50e:	05878063          	beq	a5,s8,54e <vprintf+0xba>
      } else if(c == 'l') {
 512:	05978c63          	beq	a5,s9,56a <vprintf+0xd6>
      } else if(c == 'x') {
 516:	07a78863          	beq	a5,s10,586 <vprintf+0xf2>
      } else if(c == 'p') {
 51a:	09b78463          	beq	a5,s11,5a2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 51e:	07300713          	li	a4,115
 522:	0ce78663          	beq	a5,a4,5ee <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 526:	06300713          	li	a4,99
 52a:	0ee78e63          	beq	a5,a4,626 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 52e:	11478863          	beq	a5,s4,63e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 532:	85d2                	mv	a1,s4
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	e92080e7          	jalr	-366(ra) # 3c8 <putc>
        putc(fd, c);
 53e:	85ca                	mv	a1,s2
 540:	8556                	mv	a0,s5
 542:	00000097          	auipc	ra,0x0
 546:	e86080e7          	jalr	-378(ra) # 3c8 <putc>
      }
      state = 0;
 54a:	4981                	li	s3,0
 54c:	b765                	j	4f4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 54e:	008b0913          	addi	s2,s6,8
 552:	4685                	li	a3,1
 554:	4629                	li	a2,10
 556:	000b2583          	lw	a1,0(s6)
 55a:	8556                	mv	a0,s5
 55c:	00000097          	auipc	ra,0x0
 560:	e8e080e7          	jalr	-370(ra) # 3ea <printint>
 564:	8b4a                	mv	s6,s2
      state = 0;
 566:	4981                	li	s3,0
 568:	b771                	j	4f4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 56a:	008b0913          	addi	s2,s6,8
 56e:	4681                	li	a3,0
 570:	4629                	li	a2,10
 572:	000b2583          	lw	a1,0(s6)
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e72080e7          	jalr	-398(ra) # 3ea <printint>
 580:	8b4a                	mv	s6,s2
      state = 0;
 582:	4981                	li	s3,0
 584:	bf85                	j	4f4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 586:	008b0913          	addi	s2,s6,8
 58a:	4681                	li	a3,0
 58c:	4641                	li	a2,16
 58e:	000b2583          	lw	a1,0(s6)
 592:	8556                	mv	a0,s5
 594:	00000097          	auipc	ra,0x0
 598:	e56080e7          	jalr	-426(ra) # 3ea <printint>
 59c:	8b4a                	mv	s6,s2
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	bf91                	j	4f4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5a2:	008b0793          	addi	a5,s6,8
 5a6:	f8f43423          	sd	a5,-120(s0)
 5aa:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5ae:	03000593          	li	a1,48
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	e14080e7          	jalr	-492(ra) # 3c8 <putc>
  putc(fd, 'x');
 5bc:	85ea                	mv	a1,s10
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	e08080e7          	jalr	-504(ra) # 3c8 <putc>
 5c8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ca:	03c9d793          	srli	a5,s3,0x3c
 5ce:	97de                	add	a5,a5,s7
 5d0:	0007c583          	lbu	a1,0(a5)
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	df2080e7          	jalr	-526(ra) # 3c8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5de:	0992                	slli	s3,s3,0x4
 5e0:	397d                	addiw	s2,s2,-1
 5e2:	fe0914e3          	bnez	s2,5ca <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5e6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b721                	j	4f4 <vprintf+0x60>
        s = va_arg(ap, char*);
 5ee:	008b0993          	addi	s3,s6,8
 5f2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5f6:	02090163          	beqz	s2,618 <vprintf+0x184>
        while(*s != 0){
 5fa:	00094583          	lbu	a1,0(s2)
 5fe:	c9a1                	beqz	a1,64e <vprintf+0x1ba>
          putc(fd, *s);
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	dc6080e7          	jalr	-570(ra) # 3c8 <putc>
          s++;
 60a:	0905                	addi	s2,s2,1
        while(*s != 0){
 60c:	00094583          	lbu	a1,0(s2)
 610:	f9e5                	bnez	a1,600 <vprintf+0x16c>
        s = va_arg(ap, char*);
 612:	8b4e                	mv	s6,s3
      state = 0;
 614:	4981                	li	s3,0
 616:	bdf9                	j	4f4 <vprintf+0x60>
          s = "(null)";
 618:	00000917          	auipc	s2,0x0
 61c:	5e090913          	addi	s2,s2,1504 # bf8 <uthread_self+0x68>
        while(*s != 0){
 620:	02800593          	li	a1,40
 624:	bff1                	j	600 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 626:	008b0913          	addi	s2,s6,8
 62a:	000b4583          	lbu	a1,0(s6)
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	d98080e7          	jalr	-616(ra) # 3c8 <putc>
 638:	8b4a                	mv	s6,s2
      state = 0;
 63a:	4981                	li	s3,0
 63c:	bd65                	j	4f4 <vprintf+0x60>
        putc(fd, c);
 63e:	85d2                	mv	a1,s4
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	d86080e7          	jalr	-634(ra) # 3c8 <putc>
      state = 0;
 64a:	4981                	li	s3,0
 64c:	b565                	j	4f4 <vprintf+0x60>
        s = va_arg(ap, char*);
 64e:	8b4e                	mv	s6,s3
      state = 0;
 650:	4981                	li	s3,0
 652:	b54d                	j	4f4 <vprintf+0x60>
    }
  }
}
 654:	70e6                	ld	ra,120(sp)
 656:	7446                	ld	s0,112(sp)
 658:	74a6                	ld	s1,104(sp)
 65a:	7906                	ld	s2,96(sp)
 65c:	69e6                	ld	s3,88(sp)
 65e:	6a46                	ld	s4,80(sp)
 660:	6aa6                	ld	s5,72(sp)
 662:	6b06                	ld	s6,64(sp)
 664:	7be2                	ld	s7,56(sp)
 666:	7c42                	ld	s8,48(sp)
 668:	7ca2                	ld	s9,40(sp)
 66a:	7d02                	ld	s10,32(sp)
 66c:	6de2                	ld	s11,24(sp)
 66e:	6109                	addi	sp,sp,128
 670:	8082                	ret

0000000000000672 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 672:	715d                	addi	sp,sp,-80
 674:	ec06                	sd	ra,24(sp)
 676:	e822                	sd	s0,16(sp)
 678:	1000                	addi	s0,sp,32
 67a:	e010                	sd	a2,0(s0)
 67c:	e414                	sd	a3,8(s0)
 67e:	e818                	sd	a4,16(s0)
 680:	ec1c                	sd	a5,24(s0)
 682:	03043023          	sd	a6,32(s0)
 686:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 68a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 68e:	8622                	mv	a2,s0
 690:	00000097          	auipc	ra,0x0
 694:	e04080e7          	jalr	-508(ra) # 494 <vprintf>
}
 698:	60e2                	ld	ra,24(sp)
 69a:	6442                	ld	s0,16(sp)
 69c:	6161                	addi	sp,sp,80
 69e:	8082                	ret

00000000000006a0 <printf>:

void
printf(const char *fmt, ...)
{
 6a0:	711d                	addi	sp,sp,-96
 6a2:	ec06                	sd	ra,24(sp)
 6a4:	e822                	sd	s0,16(sp)
 6a6:	1000                	addi	s0,sp,32
 6a8:	e40c                	sd	a1,8(s0)
 6aa:	e810                	sd	a2,16(s0)
 6ac:	ec14                	sd	a3,24(s0)
 6ae:	f018                	sd	a4,32(s0)
 6b0:	f41c                	sd	a5,40(s0)
 6b2:	03043823          	sd	a6,48(s0)
 6b6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ba:	00840613          	addi	a2,s0,8
 6be:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6c2:	85aa                	mv	a1,a0
 6c4:	4505                	li	a0,1
 6c6:	00000097          	auipc	ra,0x0
 6ca:	dce080e7          	jalr	-562(ra) # 494 <vprintf>
}
 6ce:	60e2                	ld	ra,24(sp)
 6d0:	6442                	ld	s0,16(sp)
 6d2:	6125                	addi	sp,sp,96
 6d4:	8082                	ret

00000000000006d6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d6:	1141                	addi	sp,sp,-16
 6d8:	e422                	sd	s0,8(sp)
 6da:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6dc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e0:	00001797          	auipc	a5,0x1
 6e4:	9207b783          	ld	a5,-1760(a5) # 1000 <freep>
 6e8:	a805                	j	718 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ea:	4618                	lw	a4,8(a2)
 6ec:	9db9                	addw	a1,a1,a4
 6ee:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f2:	6398                	ld	a4,0(a5)
 6f4:	6318                	ld	a4,0(a4)
 6f6:	fee53823          	sd	a4,-16(a0)
 6fa:	a091                	j	73e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6fc:	ff852703          	lw	a4,-8(a0)
 700:	9e39                	addw	a2,a2,a4
 702:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 704:	ff053703          	ld	a4,-16(a0)
 708:	e398                	sd	a4,0(a5)
 70a:	a099                	j	750 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 70c:	6398                	ld	a4,0(a5)
 70e:	00e7e463          	bltu	a5,a4,716 <free+0x40>
 712:	00e6ea63          	bltu	a3,a4,726 <free+0x50>
{
 716:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 718:	fed7fae3          	bgeu	a5,a3,70c <free+0x36>
 71c:	6398                	ld	a4,0(a5)
 71e:	00e6e463          	bltu	a3,a4,726 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 722:	fee7eae3          	bltu	a5,a4,716 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 726:	ff852583          	lw	a1,-8(a0)
 72a:	6390                	ld	a2,0(a5)
 72c:	02059713          	slli	a4,a1,0x20
 730:	9301                	srli	a4,a4,0x20
 732:	0712                	slli	a4,a4,0x4
 734:	9736                	add	a4,a4,a3
 736:	fae60ae3          	beq	a2,a4,6ea <free+0x14>
    bp->s.ptr = p->s.ptr;
 73a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 73e:	4790                	lw	a2,8(a5)
 740:	02061713          	slli	a4,a2,0x20
 744:	9301                	srli	a4,a4,0x20
 746:	0712                	slli	a4,a4,0x4
 748:	973e                	add	a4,a4,a5
 74a:	fae689e3          	beq	a3,a4,6fc <free+0x26>
  } else
    p->s.ptr = bp;
 74e:	e394                	sd	a3,0(a5)
  freep = p;
 750:	00001717          	auipc	a4,0x1
 754:	8af73823          	sd	a5,-1872(a4) # 1000 <freep>
}
 758:	6422                	ld	s0,8(sp)
 75a:	0141                	addi	sp,sp,16
 75c:	8082                	ret

000000000000075e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 75e:	7139                	addi	sp,sp,-64
 760:	fc06                	sd	ra,56(sp)
 762:	f822                	sd	s0,48(sp)
 764:	f426                	sd	s1,40(sp)
 766:	f04a                	sd	s2,32(sp)
 768:	ec4e                	sd	s3,24(sp)
 76a:	e852                	sd	s4,16(sp)
 76c:	e456                	sd	s5,8(sp)
 76e:	e05a                	sd	s6,0(sp)
 770:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 772:	02051493          	slli	s1,a0,0x20
 776:	9081                	srli	s1,s1,0x20
 778:	04bd                	addi	s1,s1,15
 77a:	8091                	srli	s1,s1,0x4
 77c:	0014899b          	addiw	s3,s1,1
 780:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 782:	00001517          	auipc	a0,0x1
 786:	87e53503          	ld	a0,-1922(a0) # 1000 <freep>
 78a:	c515                	beqz	a0,7b6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 78e:	4798                	lw	a4,8(a5)
 790:	02977f63          	bgeu	a4,s1,7ce <malloc+0x70>
 794:	8a4e                	mv	s4,s3
 796:	0009871b          	sext.w	a4,s3
 79a:	6685                	lui	a3,0x1
 79c:	00d77363          	bgeu	a4,a3,7a2 <malloc+0x44>
 7a0:	6a05                	lui	s4,0x1
 7a2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7a6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7aa:	00001917          	auipc	s2,0x1
 7ae:	85690913          	addi	s2,s2,-1962 # 1000 <freep>
  if(p == (char*)-1)
 7b2:	5afd                	li	s5,-1
 7b4:	a88d                	j	826 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7b6:	00001797          	auipc	a5,0x1
 7ba:	86a78793          	addi	a5,a5,-1942 # 1020 <base>
 7be:	00001717          	auipc	a4,0x1
 7c2:	84f73123          	sd	a5,-1982(a4) # 1000 <freep>
 7c6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7c8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7cc:	b7e1                	j	794 <malloc+0x36>
      if(p->s.size == nunits)
 7ce:	02e48b63          	beq	s1,a4,804 <malloc+0xa6>
        p->s.size -= nunits;
 7d2:	4137073b          	subw	a4,a4,s3
 7d6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7d8:	1702                	slli	a4,a4,0x20
 7da:	9301                	srli	a4,a4,0x20
 7dc:	0712                	slli	a4,a4,0x4
 7de:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7e0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7e4:	00001717          	auipc	a4,0x1
 7e8:	80a73e23          	sd	a0,-2020(a4) # 1000 <freep>
      return (void*)(p + 1);
 7ec:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7f0:	70e2                	ld	ra,56(sp)
 7f2:	7442                	ld	s0,48(sp)
 7f4:	74a2                	ld	s1,40(sp)
 7f6:	7902                	ld	s2,32(sp)
 7f8:	69e2                	ld	s3,24(sp)
 7fa:	6a42                	ld	s4,16(sp)
 7fc:	6aa2                	ld	s5,8(sp)
 7fe:	6b02                	ld	s6,0(sp)
 800:	6121                	addi	sp,sp,64
 802:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 804:	6398                	ld	a4,0(a5)
 806:	e118                	sd	a4,0(a0)
 808:	bff1                	j	7e4 <malloc+0x86>
  hp->s.size = nu;
 80a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 80e:	0541                	addi	a0,a0,16
 810:	00000097          	auipc	ra,0x0
 814:	ec6080e7          	jalr	-314(ra) # 6d6 <free>
  return freep;
 818:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 81c:	d971                	beqz	a0,7f0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 820:	4798                	lw	a4,8(a5)
 822:	fa9776e3          	bgeu	a4,s1,7ce <malloc+0x70>
    if(p == freep)
 826:	00093703          	ld	a4,0(s2)
 82a:	853e                	mv	a0,a5
 82c:	fef719e3          	bne	a4,a5,81e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 830:	8552                	mv	a0,s4
 832:	00000097          	auipc	ra,0x0
 836:	b7e080e7          	jalr	-1154(ra) # 3b0 <sbrk>
  if(p == (char*)-1)
 83a:	fd5518e3          	bne	a0,s5,80a <malloc+0xac>
        return 0;
 83e:	4501                	li	a0,0
 840:	bf45                	j	7f0 <malloc+0x92>

0000000000000842 <uswtch>:
 842:	00153023          	sd	ra,0(a0)
 846:	00253423          	sd	sp,8(a0)
 84a:	e900                	sd	s0,16(a0)
 84c:	ed04                	sd	s1,24(a0)
 84e:	03253023          	sd	s2,32(a0)
 852:	03353423          	sd	s3,40(a0)
 856:	03453823          	sd	s4,48(a0)
 85a:	03553c23          	sd	s5,56(a0)
 85e:	05653023          	sd	s6,64(a0)
 862:	05753423          	sd	s7,72(a0)
 866:	05853823          	sd	s8,80(a0)
 86a:	05953c23          	sd	s9,88(a0)
 86e:	07a53023          	sd	s10,96(a0)
 872:	07b53423          	sd	s11,104(a0)
 876:	0005b083          	ld	ra,0(a1)
 87a:	0085b103          	ld	sp,8(a1)
 87e:	6980                	ld	s0,16(a1)
 880:	6d84                	ld	s1,24(a1)
 882:	0205b903          	ld	s2,32(a1)
 886:	0285b983          	ld	s3,40(a1)
 88a:	0305ba03          	ld	s4,48(a1)
 88e:	0385ba83          	ld	s5,56(a1)
 892:	0405bb03          	ld	s6,64(a1)
 896:	0485bb83          	ld	s7,72(a1)
 89a:	0505bc03          	ld	s8,80(a1)
 89e:	0585bc83          	ld	s9,88(a1)
 8a2:	0605bd03          	ld	s10,96(a1)
 8a6:	0685bd83          	ld	s11,104(a1)
 8aa:	8082                	ret

00000000000008ac <uthread_exit>:
    curr_thread = next_thread;
    uswtch(curr_context, next_context);

}

void uthread_exit(){
 8ac:	1141                	addi	sp,sp,-16
 8ae:	e406                	sd	ra,8(sp)
 8b0:	e022                	sd	s0,0(sp)
 8b2:	0800                	addi	s0,sp,16
    printf("in uthresd exit\n");
 8b4:	00000517          	auipc	a0,0x0
 8b8:	36450513          	addi	a0,a0,868 # c18 <digits+0x18>
 8bc:	00000097          	auipc	ra,0x0
 8c0:	de4080e7          	jalr	-540(ra) # 6a0 <printf>
    // Change the state of the current thread to FREE
    curr_thread->state = FREE;
 8c4:	00000517          	auipc	a0,0x0
 8c8:	74453503          	ld	a0,1860(a0) # 1008 <curr_thread>
 8cc:	6785                	lui	a5,0x1
 8ce:	97aa                	add	a5,a5,a0
 8d0:	fa07a223          	sw	zero,-92(a5) # fa4 <digits+0x3a4>
    // Find another runnable thread to switch to (make sure its not the current_thread)
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 8d4:	411c                	lw	a5,0(a0)
 8d6:	2785                	addiw	a5,a5,1
 8d8:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 8da:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 8dc:	4585                	li	a1,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 8de:	00000617          	auipc	a2,0x0
 8e2:	7c260613          	addi	a2,a2,1986 # 10a0 <uthreads_arr>
 8e6:	6805                	lui	a6,0x1
 8e8:	4889                	li	a7,2
 8ea:	a819                	j	900 <uthread_exit+0x54>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 8ec:	2785                	addiw	a5,a5,1
 8ee:	41f7d71b          	sraiw	a4,a5,0x1f
 8f2:	01e7571b          	srliw	a4,a4,0x1e
 8f6:	9fb9                	addw	a5,a5,a4
 8f8:	8b8d                	andi	a5,a5,3
 8fa:	9f99                	subw	a5,a5,a4
 8fc:	36fd                	addiw	a3,a3,-1
 8fe:	ca9d                	beqz	a3,934 <uthread_exit+0x88>
        if (uthreads_arr[i].state == RUNNABLE &&
 900:	00779713          	slli	a4,a5,0x7
 904:	973e                	add	a4,a4,a5
 906:	0716                	slli	a4,a4,0x5
 908:	9732                	add	a4,a4,a2
 90a:	9742                	add	a4,a4,a6
 90c:	fa472703          	lw	a4,-92(a4)
 910:	fd171ee3          	bne	a4,a7,8ec <uthread_exit+0x40>
            uthreads_arr[i].priority > max_priority) {
 914:	00779713          	slli	a4,a5,0x7
 918:	973e                	add	a4,a4,a5
 91a:	0716                	slli	a4,a4,0x5
 91c:	9732                	add	a4,a4,a2
 91e:	9742                	add	a4,a4,a6
 920:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 922:	fce375e3          	bgeu	t1,a4,8ec <uthread_exit+0x40>
            next_thread = &uthreads_arr[i];
 926:	00779593          	slli	a1,a5,0x7
 92a:	95be                	add	a1,a1,a5
 92c:	0596                	slli	a1,a1,0x5
 92e:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 930:	833a                	mv	t1,a4
 932:	bf6d                	j	8ec <uthread_exit+0x40>
        }
    }
    if (next_thread == (struct uthread *) 1) {
 934:	4785                	li	a5,1
 936:	02f58863          	beq	a1,a5,966 <uthread_exit+0xba>
        exit(0);  // Exit the process if there are no more runnable threads
    }
    // Switch to the next thread
    struct context *curr_context = &curr_thread->context;
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 93a:	6785                	lui	a5,0x1
 93c:	00f58733          	add	a4,a1,a5
 940:	4685                	li	a3,1
 942:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 946:	00000717          	auipc	a4,0x0
 94a:	6cb73123          	sd	a1,1730(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 94e:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x3a8>
    uswtch(curr_context, next_context);
 952:	95be                	add	a1,a1,a5
 954:	953e                	add	a0,a0,a5
 956:	00000097          	auipc	ra,0x0
 95a:	eec080e7          	jalr	-276(ra) # 842 <uswtch>
}
 95e:	60a2                	ld	ra,8(sp)
 960:	6402                	ld	s0,0(sp)
 962:	0141                	addi	sp,sp,16
 964:	8082                	ret
        exit(0);  // Exit the process if there are no more runnable threads
 966:	4501                	li	a0,0
 968:	00000097          	auipc	ra,0x0
 96c:	9c0080e7          	jalr	-1600(ra) # 328 <exit>

0000000000000970 <uthread_create>:
int uthread_create(void (*start_func)(), enum sched_priority priority) {
 970:	1141                	addi	sp,sp,-16
 972:	e422                	sd	s0,8(sp)
 974:	0800                	addi	s0,sp,16
    for (i = 0; i < MAX_UTHREADS; i++) {
 976:	00001717          	auipc	a4,0x1
 97a:	6ce70713          	addi	a4,a4,1742 # 2044 <uthreads_arr+0xfa4>
 97e:	4781                	li	a5,0
 980:	6605                	lui	a2,0x1
 982:	02060613          	addi	a2,a2,32 # 1020 <base>
 986:	4811                	li	a6,4
        if (uthreads_arr[i].state == FREE) {
 988:	4314                	lw	a3,0(a4)
 98a:	c699                	beqz	a3,998 <uthread_create+0x28>
    for (i = 0; i < MAX_UTHREADS; i++) {
 98c:	2785                	addiw	a5,a5,1
 98e:	9732                	add	a4,a4,a2
 990:	ff079ce3          	bne	a5,a6,988 <uthread_create+0x18>
        return -1;
 994:	557d                	li	a0,-1
 996:	a0b9                	j	9e4 <uthread_create+0x74>
            curr_thread = &uthreads_arr[i];
 998:	00779713          	slli	a4,a5,0x7
 99c:	973e                	add	a4,a4,a5
 99e:	0716                	slli	a4,a4,0x5
 9a0:	00000697          	auipc	a3,0x0
 9a4:	70068693          	addi	a3,a3,1792 # 10a0 <uthreads_arr>
 9a8:	9736                	add	a4,a4,a3
 9aa:	00000697          	auipc	a3,0x0
 9ae:	64e6bf23          	sd	a4,1630(a3) # 1008 <curr_thread>
    if (i >= MAX_UTHREADS) {
 9b2:	468d                	li	a3,3
 9b4:	02f6cb63          	blt	a3,a5,9ea <uthread_create+0x7a>
    curr_thread->id = i; 
 9b8:	c31c                	sw	a5,0(a4)
    curr_thread->priority = priority;
 9ba:	6685                	lui	a3,0x1
 9bc:	00d707b3          	add	a5,a4,a3
 9c0:	cf8c                	sw	a1,24(a5)
    curr_thread->context.ra = (uint64) start_func;
 9c2:	faa7b423          	sd	a0,-88(a5)
    curr_thread->context.sp = (uint64) &curr_thread->ustack[STACK_SIZE];
 9c6:	fa468693          	addi	a3,a3,-92 # fa4 <digits+0x3a4>
 9ca:	9736                	add	a4,a4,a3
 9cc:	fae7b823          	sd	a4,-80(a5)
    curr_thread->ustack[STACK_SIZE - 1] = (uint64) uthread_exit; // Return address to uthread_exit
 9d0:	00000717          	auipc	a4,0x0
 9d4:	edc70713          	addi	a4,a4,-292 # 8ac <uthread_exit>
 9d8:	fae781a3          	sb	a4,-93(a5)
    curr_thread->state = RUNNABLE;
 9dc:	4709                	li	a4,2
 9de:	fae7a223          	sw	a4,-92(a5)
     return 0;
 9e2:	4501                	li	a0,0
}
 9e4:	6422                	ld	s0,8(sp)
 9e6:	0141                	addi	sp,sp,16
 9e8:	8082                	ret
        return -1;
 9ea:	557d                	li	a0,-1
 9ec:	bfe5                	j	9e4 <uthread_create+0x74>

00000000000009ee <uthread_yield>:
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 9ee:	00000517          	auipc	a0,0x0
 9f2:	61a53503          	ld	a0,1562(a0) # 1008 <curr_thread>
 9f6:	411c                	lw	a5,0(a0)
 9f8:	2785                	addiw	a5,a5,1
 9fa:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 9fc:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 9fe:	4585                	li	a1,1
        if (uthreads_arr[i].state == RUNNABLE &&
 a00:	00000617          	auipc	a2,0x0
 a04:	6a060613          	addi	a2,a2,1696 # 10a0 <uthreads_arr>
 a08:	6805                	lui	a6,0x1
 a0a:	4889                	li	a7,2
 a0c:	a819                	j	a22 <uthread_yield+0x34>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 a0e:	2785                	addiw	a5,a5,1
 a10:	41f7d71b          	sraiw	a4,a5,0x1f
 a14:	01e7571b          	srliw	a4,a4,0x1e
 a18:	9fb9                	addw	a5,a5,a4
 a1a:	8b8d                	andi	a5,a5,3
 a1c:	9f99                	subw	a5,a5,a4
 a1e:	36fd                	addiw	a3,a3,-1
 a20:	ca9d                	beqz	a3,a56 <uthread_yield+0x68>
        if (uthreads_arr[i].state == RUNNABLE &&
 a22:	00779713          	slli	a4,a5,0x7
 a26:	973e                	add	a4,a4,a5
 a28:	0716                	slli	a4,a4,0x5
 a2a:	9732                	add	a4,a4,a2
 a2c:	9742                	add	a4,a4,a6
 a2e:	fa472703          	lw	a4,-92(a4)
 a32:	fd171ee3          	bne	a4,a7,a0e <uthread_yield+0x20>
            uthreads_arr[i].priority > max_priority) {
 a36:	00779713          	slli	a4,a5,0x7
 a3a:	973e                	add	a4,a4,a5
 a3c:	0716                	slli	a4,a4,0x5
 a3e:	9732                	add	a4,a4,a2
 a40:	9742                	add	a4,a4,a6
 a42:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 a44:	fce375e3          	bgeu	t1,a4,a0e <uthread_yield+0x20>
            next_thread = &uthreads_arr[i];
 a48:	00779593          	slli	a1,a5,0x7
 a4c:	95be                	add	a1,a1,a5
 a4e:	0596                	slli	a1,a1,0x5
 a50:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 a52:	833a                	mv	t1,a4
 a54:	bf6d                	j	a0e <uthread_yield+0x20>
    if (next_thread == (struct uthread *) 1) {
 a56:	4785                	li	a5,1
 a58:	04f58163          	beq	a1,a5,a9a <uthread_yield+0xac>
void uthread_yield() {
 a5c:	1141                	addi	sp,sp,-16
 a5e:	e406                	sd	ra,8(sp)
 a60:	e022                	sd	s0,0(sp)
 a62:	0800                	addi	s0,sp,16
    curr_thread->state = RUNNABLE;
 a64:	6785                	lui	a5,0x1
 a66:	00f50733          	add	a4,a0,a5
 a6a:	4689                	li	a3,2
 a6c:	fad72223          	sw	a3,-92(a4)
    next_thread->state = RUNNING;
 a70:	00f58733          	add	a4,a1,a5
 a74:	4685                	li	a3,1
 a76:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 a7a:	00000717          	auipc	a4,0x0
 a7e:	58b73723          	sd	a1,1422(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 a82:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x3a8>
    uswtch(curr_context, next_context);
 a86:	95be                	add	a1,a1,a5
 a88:	953e                	add	a0,a0,a5
 a8a:	00000097          	auipc	ra,0x0
 a8e:	db8080e7          	jalr	-584(ra) # 842 <uswtch>
}
 a92:	60a2                	ld	ra,8(sp)
 a94:	6402                	ld	s0,0(sp)
 a96:	0141                	addi	sp,sp,16
 a98:	8082                	ret
 a9a:	8082                	ret

0000000000000a9c <uthread_set_priority>:

enum sched_priority uthread_set_priority(enum sched_priority priority){
 a9c:	1141                	addi	sp,sp,-16
 a9e:	e422                	sd	s0,8(sp)
 aa0:	0800                	addi	s0,sp,16
    enum sched_priority to_return =curr_thread->priority;
 aa2:	00000797          	auipc	a5,0x0
 aa6:	5667b783          	ld	a5,1382(a5) # 1008 <curr_thread>
 aaa:	6705                	lui	a4,0x1
 aac:	97ba                	add	a5,a5,a4
 aae:	4f98                	lw	a4,24(a5)
    curr_thread->priority=priority;
 ab0:	cf88                	sw	a0,24(a5)
    return to_return;
}
 ab2:	853a                	mv	a0,a4
 ab4:	6422                	ld	s0,8(sp)
 ab6:	0141                	addi	sp,sp,16
 ab8:	8082                	ret

0000000000000aba <uthread_get_priority>:

enum sched_priority uthread_get_priority(){
 aba:	1141                	addi	sp,sp,-16
 abc:	e422                	sd	s0,8(sp)
 abe:	0800                	addi	s0,sp,16
    return curr_thread->priority;
 ac0:	00000797          	auipc	a5,0x0
 ac4:	5487b783          	ld	a5,1352(a5) # 1008 <curr_thread>
 ac8:	6705                	lui	a4,0x1
 aca:	97ba                	add	a5,a5,a4
}
 acc:	4f88                	lw	a0,24(a5)
 ace:	6422                	ld	s0,8(sp)
 ad0:	0141                	addi	sp,sp,16
 ad2:	8082                	ret

0000000000000ad4 <uthread_start_all>:

int uthread_start_all(){
    if (started){
 ad4:	00000797          	auipc	a5,0x0
 ad8:	53c7a783          	lw	a5,1340(a5) # 1010 <started>
 adc:	ebc5                	bnez	a5,b8c <uthread_start_all+0xb8>
int uthread_start_all(){
 ade:	1141                	addi	sp,sp,-16
 ae0:	e406                	sd	ra,8(sp)
 ae2:	e022                	sd	s0,0(sp)
 ae4:	0800                	addi	s0,sp,16
        return -1;
    }
    started=1;
 ae6:	4785                	li	a5,1
 ae8:	00000717          	auipc	a4,0x0
 aec:	52f72423          	sw	a5,1320(a4) # 1010 <started>
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 af0:	00000797          	auipc	a5,0x0
 af4:	5187b783          	ld	a5,1304(a5) # 1008 <curr_thread>
 af8:	439c                	lw	a5,0(a5)
 afa:	2785                	addiw	a5,a5,1
 afc:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 afe:	4881                	li	a7,0
    struct uthread *next_thread = (struct uthread *) 1;
 b00:	4605                	li	a2,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 b02:	00000597          	auipc	a1,0x0
 b06:	59e58593          	addi	a1,a1,1438 # 10a0 <uthreads_arr>
 b0a:	6505                	lui	a0,0x1
 b0c:	4809                	li	a6,2
 b0e:	a819                	j	b24 <uthread_start_all+0x50>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 b10:	2785                	addiw	a5,a5,1
 b12:	41f7d71b          	sraiw	a4,a5,0x1f
 b16:	01e7571b          	srliw	a4,a4,0x1e
 b1a:	9fb9                	addw	a5,a5,a4
 b1c:	8b8d                	andi	a5,a5,3
 b1e:	9f99                	subw	a5,a5,a4
 b20:	36fd                	addiw	a3,a3,-1
 b22:	ca9d                	beqz	a3,b58 <uthread_start_all+0x84>
        if (uthreads_arr[i].state == RUNNABLE &&
 b24:	00779713          	slli	a4,a5,0x7
 b28:	973e                	add	a4,a4,a5
 b2a:	0716                	slli	a4,a4,0x5
 b2c:	972e                	add	a4,a4,a1
 b2e:	972a                	add	a4,a4,a0
 b30:	fa472703          	lw	a4,-92(a4)
 b34:	fd071ee3          	bne	a4,a6,b10 <uthread_start_all+0x3c>
            uthreads_arr[i].priority > max_priority) {
 b38:	00779713          	slli	a4,a5,0x7
 b3c:	973e                	add	a4,a4,a5
 b3e:	0716                	slli	a4,a4,0x5
 b40:	972e                	add	a4,a4,a1
 b42:	972a                	add	a4,a4,a0
 b44:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 b46:	fce8f5e3          	bgeu	a7,a4,b10 <uthread_start_all+0x3c>
            next_thread = &uthreads_arr[i];
 b4a:	00779613          	slli	a2,a5,0x7
 b4e:	963e                	add	a2,a2,a5
 b50:	0616                	slli	a2,a2,0x5
 b52:	962e                	add	a2,a2,a1
            max_priority = uthreads_arr[i].priority;
 b54:	88ba                	mv	a7,a4
 b56:	bf6d                	j	b10 <uthread_start_all+0x3c>
        }
    }
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 b58:	6585                	lui	a1,0x1
 b5a:	00b607b3          	add	a5,a2,a1
 b5e:	4705                	li	a4,1
 b60:	fae7a223          	sw	a4,-92(a5)
    curr_thread = next_thread;
 b64:	00000797          	auipc	a5,0x0
 b68:	4ac7b223          	sd	a2,1188(a5) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 b6c:	fa858593          	addi	a1,a1,-88 # fa8 <digits+0x3a8>
    uswtch(&garbageContext,next_context);
 b70:	95b2                	add	a1,a1,a2
 b72:	00000517          	auipc	a0,0x0
 b76:	4be50513          	addi	a0,a0,1214 # 1030 <garbageContext>
 b7a:	00000097          	auipc	ra,0x0
 b7e:	cc8080e7          	jalr	-824(ra) # 842 <uswtch>

    return -1;
}
 b82:	557d                	li	a0,-1
 b84:	60a2                	ld	ra,8(sp)
 b86:	6402                	ld	s0,0(sp)
 b88:	0141                	addi	sp,sp,16
 b8a:	8082                	ret
 b8c:	557d                	li	a0,-1
 b8e:	8082                	ret

0000000000000b90 <uthread_self>:

struct uthread* uthread_self(){
 b90:	1141                	addi	sp,sp,-16
 b92:	e422                	sd	s0,8(sp)
 b94:	0800                	addi	s0,sp,16
    return curr_thread;
 b96:	00000517          	auipc	a0,0x0
 b9a:	47253503          	ld	a0,1138(a0) # 1008 <curr_thread>
 b9e:	6422                	ld	s0,8(sp)
 ba0:	0141                	addi	sp,sp,16
 ba2:	8082                	ret
