
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
    int arg_val = *arg_ptr;
    printf("Thread %d started\n", arg_val);
   8:	410c                	lw	a1,0(a0)
   a:	00001517          	auipc	a0,0x1
   e:	b7650513          	addi	a0,a0,-1162 # b80 <uthread_start_all+0xc4>
  12:	00000097          	auipc	ra,0x0
  16:	686080e7          	jalr	1670(ra) # 698 <printf>
    // uthread_exit();
    // printf("Thread %d resumed\n", arg_val);
    return (void*) 0;

}
  1a:	4501                	li	a0,0
  1c:	60a2                	ld	ra,8(sp)
  1e:	6402                	ld	s0,0(sp)
  20:	0141                	addi	sp,sp,16
  22:	8082                	ret

0000000000000024 <main>:

int main() {
  24:	1141                	addi	sp,sp,-16
  26:	e406                	sd	ra,8(sp)
  28:	e022                	sd	s0,0(sp)
  2a:	0800                	addi	s0,sp,16
    int arg1 = 1;
    int arg2 = 2;
    if (uthread_create((void (*)()) thread_func, arg1) == -1 ||
  2c:	4585                	li	a1,1
  2e:	00000517          	auipc	a0,0x0
  32:	fd250513          	addi	a0,a0,-46 # 0 <thread_func>
  36:	00001097          	auipc	ra,0x1
  3a:	922080e7          	jalr	-1758(ra) # 958 <uthread_create>
  3e:	57fd                	li	a5,-1
  40:	02f50f63          	beq	a0,a5,7e <main+0x5a>
        uthread_create((void (*)()) thread_func, arg2) == -1) {
  44:	4589                	li	a1,2
  46:	00000517          	auipc	a0,0x0
  4a:	fba50513          	addi	a0,a0,-70 # 0 <thread_func>
  4e:	00001097          	auipc	ra,0x1
  52:	90a080e7          	jalr	-1782(ra) # 958 <uthread_create>
    if (uthread_create((void (*)()) thread_func, arg1) == -1 ||
  56:	57fd                	li	a5,-1
  58:	02f50363          	beq	a0,a5,7e <main+0x5a>
        printf("Error creating thread\n");
        exit(1);
    }
    uthread_start_all();
  5c:	00001097          	auipc	ra,0x1
  60:	a60080e7          	jalr	-1440(ra) # abc <uthread_start_all>
    printf("Main thread resumed\n");
  64:	00001517          	auipc	a0,0x1
  68:	b4c50513          	addi	a0,a0,-1204 # bb0 <uthread_start_all+0xf4>
  6c:	00000097          	auipc	ra,0x0
  70:	62c080e7          	jalr	1580(ra) # 698 <printf>
    return 0;
  74:	4501                	li	a0,0
  76:	60a2                	ld	ra,8(sp)
  78:	6402                	ld	s0,0(sp)
  7a:	0141                	addi	sp,sp,16
  7c:	8082                	ret
        printf("Error creating thread\n");
  7e:	00001517          	auipc	a0,0x1
  82:	b1a50513          	addi	a0,a0,-1254 # b98 <uthread_start_all+0xdc>
  86:	00000097          	auipc	ra,0x0
  8a:	612080e7          	jalr	1554(ra) # 698 <printf>
        exit(1);
  8e:	4505                	li	a0,1
  90:	00000097          	auipc	ra,0x0
  94:	290080e7          	jalr	656(ra) # 320 <exit>

0000000000000098 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  98:	1141                	addi	sp,sp,-16
  9a:	e406                	sd	ra,8(sp)
  9c:	e022                	sd	s0,0(sp)
  9e:	0800                	addi	s0,sp,16
  extern int main();
  main();
  a0:	00000097          	auipc	ra,0x0
  a4:	f84080e7          	jalr	-124(ra) # 24 <main>
  exit(0);
  a8:	4501                	li	a0,0
  aa:	00000097          	auipc	ra,0x0
  ae:	276080e7          	jalr	630(ra) # 320 <exit>

00000000000000b2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  b2:	1141                	addi	sp,sp,-16
  b4:	e422                	sd	s0,8(sp)
  b6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  b8:	87aa                	mv	a5,a0
  ba:	0585                	addi	a1,a1,1
  bc:	0785                	addi	a5,a5,1
  be:	fff5c703          	lbu	a4,-1(a1)
  c2:	fee78fa3          	sb	a4,-1(a5)
  c6:	fb75                	bnez	a4,ba <strcpy+0x8>
    ;
  return os;
}
  c8:	6422                	ld	s0,8(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret

00000000000000ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e422                	sd	s0,8(sp)
  d2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  d4:	00054783          	lbu	a5,0(a0)
  d8:	cb91                	beqz	a5,ec <strcmp+0x1e>
  da:	0005c703          	lbu	a4,0(a1)
  de:	00f71763          	bne	a4,a5,ec <strcmp+0x1e>
    p++, q++;
  e2:	0505                	addi	a0,a0,1
  e4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  e6:	00054783          	lbu	a5,0(a0)
  ea:	fbe5                	bnez	a5,da <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ec:	0005c503          	lbu	a0,0(a1)
}
  f0:	40a7853b          	subw	a0,a5,a0
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret

00000000000000fa <strlen>:

uint
strlen(const char *s)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e422                	sd	s0,8(sp)
  fe:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 100:	00054783          	lbu	a5,0(a0)
 104:	cf91                	beqz	a5,120 <strlen+0x26>
 106:	0505                	addi	a0,a0,1
 108:	87aa                	mv	a5,a0
 10a:	4685                	li	a3,1
 10c:	9e89                	subw	a3,a3,a0
 10e:	00f6853b          	addw	a0,a3,a5
 112:	0785                	addi	a5,a5,1
 114:	fff7c703          	lbu	a4,-1(a5)
 118:	fb7d                	bnez	a4,10e <strlen+0x14>
    ;
  return n;
}
 11a:	6422                	ld	s0,8(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret
  for(n = 0; s[n]; n++)
 120:	4501                	li	a0,0
 122:	bfe5                	j	11a <strlen+0x20>

0000000000000124 <memset>:

void*
memset(void *dst, int c, uint n)
{
 124:	1141                	addi	sp,sp,-16
 126:	e422                	sd	s0,8(sp)
 128:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 12a:	ca19                	beqz	a2,140 <memset+0x1c>
 12c:	87aa                	mv	a5,a0
 12e:	1602                	slli	a2,a2,0x20
 130:	9201                	srli	a2,a2,0x20
 132:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 136:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 13a:	0785                	addi	a5,a5,1
 13c:	fee79de3          	bne	a5,a4,136 <memset+0x12>
  }
  return dst;
}
 140:	6422                	ld	s0,8(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret

0000000000000146 <strchr>:

char*
strchr(const char *s, char c)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 14c:	00054783          	lbu	a5,0(a0)
 150:	cb99                	beqz	a5,166 <strchr+0x20>
    if(*s == c)
 152:	00f58763          	beq	a1,a5,160 <strchr+0x1a>
  for(; *s; s++)
 156:	0505                	addi	a0,a0,1
 158:	00054783          	lbu	a5,0(a0)
 15c:	fbfd                	bnez	a5,152 <strchr+0xc>
      return (char*)s;
  return 0;
 15e:	4501                	li	a0,0
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret
  return 0;
 166:	4501                	li	a0,0
 168:	bfe5                	j	160 <strchr+0x1a>

000000000000016a <gets>:

char*
gets(char *buf, int max)
{
 16a:	711d                	addi	sp,sp,-96
 16c:	ec86                	sd	ra,88(sp)
 16e:	e8a2                	sd	s0,80(sp)
 170:	e4a6                	sd	s1,72(sp)
 172:	e0ca                	sd	s2,64(sp)
 174:	fc4e                	sd	s3,56(sp)
 176:	f852                	sd	s4,48(sp)
 178:	f456                	sd	s5,40(sp)
 17a:	f05a                	sd	s6,32(sp)
 17c:	ec5e                	sd	s7,24(sp)
 17e:	1080                	addi	s0,sp,96
 180:	8baa                	mv	s7,a0
 182:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 184:	892a                	mv	s2,a0
 186:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 188:	4aa9                	li	s5,10
 18a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 18c:	89a6                	mv	s3,s1
 18e:	2485                	addiw	s1,s1,1
 190:	0344d863          	bge	s1,s4,1c0 <gets+0x56>
    cc = read(0, &c, 1);
 194:	4605                	li	a2,1
 196:	faf40593          	addi	a1,s0,-81
 19a:	4501                	li	a0,0
 19c:	00000097          	auipc	ra,0x0
 1a0:	19c080e7          	jalr	412(ra) # 338 <read>
    if(cc < 1)
 1a4:	00a05e63          	blez	a0,1c0 <gets+0x56>
    buf[i++] = c;
 1a8:	faf44783          	lbu	a5,-81(s0)
 1ac:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b0:	01578763          	beq	a5,s5,1be <gets+0x54>
 1b4:	0905                	addi	s2,s2,1
 1b6:	fd679be3          	bne	a5,s6,18c <gets+0x22>
  for(i=0; i+1 < max; ){
 1ba:	89a6                	mv	s3,s1
 1bc:	a011                	j	1c0 <gets+0x56>
 1be:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c0:	99de                	add	s3,s3,s7
 1c2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1c6:	855e                	mv	a0,s7
 1c8:	60e6                	ld	ra,88(sp)
 1ca:	6446                	ld	s0,80(sp)
 1cc:	64a6                	ld	s1,72(sp)
 1ce:	6906                	ld	s2,64(sp)
 1d0:	79e2                	ld	s3,56(sp)
 1d2:	7a42                	ld	s4,48(sp)
 1d4:	7aa2                	ld	s5,40(sp)
 1d6:	7b02                	ld	s6,32(sp)
 1d8:	6be2                	ld	s7,24(sp)
 1da:	6125                	addi	sp,sp,96
 1dc:	8082                	ret

00000000000001de <stat>:

int
stat(const char *n, struct stat *st)
{
 1de:	1101                	addi	sp,sp,-32
 1e0:	ec06                	sd	ra,24(sp)
 1e2:	e822                	sd	s0,16(sp)
 1e4:	e426                	sd	s1,8(sp)
 1e6:	e04a                	sd	s2,0(sp)
 1e8:	1000                	addi	s0,sp,32
 1ea:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ec:	4581                	li	a1,0
 1ee:	00000097          	auipc	ra,0x0
 1f2:	172080e7          	jalr	370(ra) # 360 <open>
  if(fd < 0)
 1f6:	02054563          	bltz	a0,220 <stat+0x42>
 1fa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fc:	85ca                	mv	a1,s2
 1fe:	00000097          	auipc	ra,0x0
 202:	17a080e7          	jalr	378(ra) # 378 <fstat>
 206:	892a                	mv	s2,a0
  close(fd);
 208:	8526                	mv	a0,s1
 20a:	00000097          	auipc	ra,0x0
 20e:	13e080e7          	jalr	318(ra) # 348 <close>
  return r;
}
 212:	854a                	mv	a0,s2
 214:	60e2                	ld	ra,24(sp)
 216:	6442                	ld	s0,16(sp)
 218:	64a2                	ld	s1,8(sp)
 21a:	6902                	ld	s2,0(sp)
 21c:	6105                	addi	sp,sp,32
 21e:	8082                	ret
    return -1;
 220:	597d                	li	s2,-1
 222:	bfc5                	j	212 <stat+0x34>

0000000000000224 <atoi>:

int
atoi(const char *s)
{
 224:	1141                	addi	sp,sp,-16
 226:	e422                	sd	s0,8(sp)
 228:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 22a:	00054603          	lbu	a2,0(a0)
 22e:	fd06079b          	addiw	a5,a2,-48
 232:	0ff7f793          	andi	a5,a5,255
 236:	4725                	li	a4,9
 238:	02f76963          	bltu	a4,a5,26a <atoi+0x46>
 23c:	86aa                	mv	a3,a0
  n = 0;
 23e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 240:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 242:	0685                	addi	a3,a3,1
 244:	0025179b          	slliw	a5,a0,0x2
 248:	9fa9                	addw	a5,a5,a0
 24a:	0017979b          	slliw	a5,a5,0x1
 24e:	9fb1                	addw	a5,a5,a2
 250:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 254:	0006c603          	lbu	a2,0(a3)
 258:	fd06071b          	addiw	a4,a2,-48
 25c:	0ff77713          	andi	a4,a4,255
 260:	fee5f1e3          	bgeu	a1,a4,242 <atoi+0x1e>
  return n;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret
  n = 0;
 26a:	4501                	li	a0,0
 26c:	bfe5                	j	264 <atoi+0x40>

000000000000026e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 274:	02b57463          	bgeu	a0,a1,29c <memmove+0x2e>
    while(n-- > 0)
 278:	00c05f63          	blez	a2,296 <memmove+0x28>
 27c:	1602                	slli	a2,a2,0x20
 27e:	9201                	srli	a2,a2,0x20
 280:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 284:	872a                	mv	a4,a0
      *dst++ = *src++;
 286:	0585                	addi	a1,a1,1
 288:	0705                	addi	a4,a4,1
 28a:	fff5c683          	lbu	a3,-1(a1)
 28e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 292:	fee79ae3          	bne	a5,a4,286 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
    dst += n;
 29c:	00c50733          	add	a4,a0,a2
    src += n;
 2a0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2a2:	fec05ae3          	blez	a2,296 <memmove+0x28>
 2a6:	fff6079b          	addiw	a5,a2,-1
 2aa:	1782                	slli	a5,a5,0x20
 2ac:	9381                	srli	a5,a5,0x20
 2ae:	fff7c793          	not	a5,a5
 2b2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b4:	15fd                	addi	a1,a1,-1
 2b6:	177d                	addi	a4,a4,-1
 2b8:	0005c683          	lbu	a3,0(a1)
 2bc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c0:	fee79ae3          	bne	a5,a4,2b4 <memmove+0x46>
 2c4:	bfc9                	j	296 <memmove+0x28>

00000000000002c6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2cc:	ca05                	beqz	a2,2fc <memcmp+0x36>
 2ce:	fff6069b          	addiw	a3,a2,-1
 2d2:	1682                	slli	a3,a3,0x20
 2d4:	9281                	srli	a3,a3,0x20
 2d6:	0685                	addi	a3,a3,1
 2d8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2da:	00054783          	lbu	a5,0(a0)
 2de:	0005c703          	lbu	a4,0(a1)
 2e2:	00e79863          	bne	a5,a4,2f2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2e6:	0505                	addi	a0,a0,1
    p2++;
 2e8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ea:	fed518e3          	bne	a0,a3,2da <memcmp+0x14>
  }
  return 0;
 2ee:	4501                	li	a0,0
 2f0:	a019                	j	2f6 <memcmp+0x30>
      return *p1 - *p2;
 2f2:	40e7853b          	subw	a0,a5,a4
}
 2f6:	6422                	ld	s0,8(sp)
 2f8:	0141                	addi	sp,sp,16
 2fa:	8082                	ret
  return 0;
 2fc:	4501                	li	a0,0
 2fe:	bfe5                	j	2f6 <memcmp+0x30>

0000000000000300 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 300:	1141                	addi	sp,sp,-16
 302:	e406                	sd	ra,8(sp)
 304:	e022                	sd	s0,0(sp)
 306:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 308:	00000097          	auipc	ra,0x0
 30c:	f66080e7          	jalr	-154(ra) # 26e <memmove>
}
 310:	60a2                	ld	ra,8(sp)
 312:	6402                	ld	s0,0(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret

0000000000000318 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 318:	4885                	li	a7,1
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <exit>:
.global exit
exit:
 li a7, SYS_exit
 320:	4889                	li	a7,2
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <wait>:
.global wait
wait:
 li a7, SYS_wait
 328:	488d                	li	a7,3
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 330:	4891                	li	a7,4
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <read>:
.global read
read:
 li a7, SYS_read
 338:	4895                	li	a7,5
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <write>:
.global write
write:
 li a7, SYS_write
 340:	48c1                	li	a7,16
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <close>:
.global close
close:
 li a7, SYS_close
 348:	48d5                	li	a7,21
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <kill>:
.global kill
kill:
 li a7, SYS_kill
 350:	4899                	li	a7,6
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exec>:
.global exec
exec:
 li a7, SYS_exec
 358:	489d                	li	a7,7
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <open>:
.global open
open:
 li a7, SYS_open
 360:	48bd                	li	a7,15
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 368:	48c5                	li	a7,17
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 370:	48c9                	li	a7,18
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 378:	48a1                	li	a7,8
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <link>:
.global link
link:
 li a7, SYS_link
 380:	48cd                	li	a7,19
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 388:	48d1                	li	a7,20
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 390:	48a5                	li	a7,9
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <dup>:
.global dup
dup:
 li a7, SYS_dup
 398:	48a9                	li	a7,10
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a0:	48ad                	li	a7,11
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3a8:	48b1                	li	a7,12
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b0:	48b5                	li	a7,13
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b8:	48b9                	li	a7,14
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3c0:	1101                	addi	sp,sp,-32
 3c2:	ec06                	sd	ra,24(sp)
 3c4:	e822                	sd	s0,16(sp)
 3c6:	1000                	addi	s0,sp,32
 3c8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3cc:	4605                	li	a2,1
 3ce:	fef40593          	addi	a1,s0,-17
 3d2:	00000097          	auipc	ra,0x0
 3d6:	f6e080e7          	jalr	-146(ra) # 340 <write>
}
 3da:	60e2                	ld	ra,24(sp)
 3dc:	6442                	ld	s0,16(sp)
 3de:	6105                	addi	sp,sp,32
 3e0:	8082                	ret

00000000000003e2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3e2:	7139                	addi	sp,sp,-64
 3e4:	fc06                	sd	ra,56(sp)
 3e6:	f822                	sd	s0,48(sp)
 3e8:	f426                	sd	s1,40(sp)
 3ea:	f04a                	sd	s2,32(sp)
 3ec:	ec4e                	sd	s3,24(sp)
 3ee:	0080                	addi	s0,sp,64
 3f0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3f2:	c299                	beqz	a3,3f8 <printint+0x16>
 3f4:	0805c863          	bltz	a1,484 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3f8:	2581                	sext.w	a1,a1
  neg = 0;
 3fa:	4881                	li	a7,0
 3fc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 400:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 402:	2601                	sext.w	a2,a2
 404:	00000517          	auipc	a0,0x0
 408:	7cc50513          	addi	a0,a0,1996 # bd0 <digits>
 40c:	883a                	mv	a6,a4
 40e:	2705                	addiw	a4,a4,1
 410:	02c5f7bb          	remuw	a5,a1,a2
 414:	1782                	slli	a5,a5,0x20
 416:	9381                	srli	a5,a5,0x20
 418:	97aa                	add	a5,a5,a0
 41a:	0007c783          	lbu	a5,0(a5)
 41e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 422:	0005879b          	sext.w	a5,a1
 426:	02c5d5bb          	divuw	a1,a1,a2
 42a:	0685                	addi	a3,a3,1
 42c:	fec7f0e3          	bgeu	a5,a2,40c <printint+0x2a>
  if(neg)
 430:	00088b63          	beqz	a7,446 <printint+0x64>
    buf[i++] = '-';
 434:	fd040793          	addi	a5,s0,-48
 438:	973e                	add	a4,a4,a5
 43a:	02d00793          	li	a5,45
 43e:	fef70823          	sb	a5,-16(a4)
 442:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 446:	02e05863          	blez	a4,476 <printint+0x94>
 44a:	fc040793          	addi	a5,s0,-64
 44e:	00e78933          	add	s2,a5,a4
 452:	fff78993          	addi	s3,a5,-1
 456:	99ba                	add	s3,s3,a4
 458:	377d                	addiw	a4,a4,-1
 45a:	1702                	slli	a4,a4,0x20
 45c:	9301                	srli	a4,a4,0x20
 45e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 462:	fff94583          	lbu	a1,-1(s2)
 466:	8526                	mv	a0,s1
 468:	00000097          	auipc	ra,0x0
 46c:	f58080e7          	jalr	-168(ra) # 3c0 <putc>
  while(--i >= 0)
 470:	197d                	addi	s2,s2,-1
 472:	ff3918e3          	bne	s2,s3,462 <printint+0x80>
}
 476:	70e2                	ld	ra,56(sp)
 478:	7442                	ld	s0,48(sp)
 47a:	74a2                	ld	s1,40(sp)
 47c:	7902                	ld	s2,32(sp)
 47e:	69e2                	ld	s3,24(sp)
 480:	6121                	addi	sp,sp,64
 482:	8082                	ret
    x = -xx;
 484:	40b005bb          	negw	a1,a1
    neg = 1;
 488:	4885                	li	a7,1
    x = -xx;
 48a:	bf8d                	j	3fc <printint+0x1a>

000000000000048c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 48c:	7119                	addi	sp,sp,-128
 48e:	fc86                	sd	ra,120(sp)
 490:	f8a2                	sd	s0,112(sp)
 492:	f4a6                	sd	s1,104(sp)
 494:	f0ca                	sd	s2,96(sp)
 496:	ecce                	sd	s3,88(sp)
 498:	e8d2                	sd	s4,80(sp)
 49a:	e4d6                	sd	s5,72(sp)
 49c:	e0da                	sd	s6,64(sp)
 49e:	fc5e                	sd	s7,56(sp)
 4a0:	f862                	sd	s8,48(sp)
 4a2:	f466                	sd	s9,40(sp)
 4a4:	f06a                	sd	s10,32(sp)
 4a6:	ec6e                	sd	s11,24(sp)
 4a8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4aa:	0005c903          	lbu	s2,0(a1)
 4ae:	18090f63          	beqz	s2,64c <vprintf+0x1c0>
 4b2:	8aaa                	mv	s5,a0
 4b4:	8b32                	mv	s6,a2
 4b6:	00158493          	addi	s1,a1,1
  state = 0;
 4ba:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4bc:	02500a13          	li	s4,37
      if(c == 'd'){
 4c0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4c4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4c8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4cc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4d0:	00000b97          	auipc	s7,0x0
 4d4:	700b8b93          	addi	s7,s7,1792 # bd0 <digits>
 4d8:	a839                	j	4f6 <vprintf+0x6a>
        putc(fd, c);
 4da:	85ca                	mv	a1,s2
 4dc:	8556                	mv	a0,s5
 4de:	00000097          	auipc	ra,0x0
 4e2:	ee2080e7          	jalr	-286(ra) # 3c0 <putc>
 4e6:	a019                	j	4ec <vprintf+0x60>
    } else if(state == '%'){
 4e8:	01498f63          	beq	s3,s4,506 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4ec:	0485                	addi	s1,s1,1
 4ee:	fff4c903          	lbu	s2,-1(s1)
 4f2:	14090d63          	beqz	s2,64c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4f6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4fa:	fe0997e3          	bnez	s3,4e8 <vprintf+0x5c>
      if(c == '%'){
 4fe:	fd479ee3          	bne	a5,s4,4da <vprintf+0x4e>
        state = '%';
 502:	89be                	mv	s3,a5
 504:	b7e5                	j	4ec <vprintf+0x60>
      if(c == 'd'){
 506:	05878063          	beq	a5,s8,546 <vprintf+0xba>
      } else if(c == 'l') {
 50a:	05978c63          	beq	a5,s9,562 <vprintf+0xd6>
      } else if(c == 'x') {
 50e:	07a78863          	beq	a5,s10,57e <vprintf+0xf2>
      } else if(c == 'p') {
 512:	09b78463          	beq	a5,s11,59a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 516:	07300713          	li	a4,115
 51a:	0ce78663          	beq	a5,a4,5e6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 51e:	06300713          	li	a4,99
 522:	0ee78e63          	beq	a5,a4,61e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 526:	11478863          	beq	a5,s4,636 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 52a:	85d2                	mv	a1,s4
 52c:	8556                	mv	a0,s5
 52e:	00000097          	auipc	ra,0x0
 532:	e92080e7          	jalr	-366(ra) # 3c0 <putc>
        putc(fd, c);
 536:	85ca                	mv	a1,s2
 538:	8556                	mv	a0,s5
 53a:	00000097          	auipc	ra,0x0
 53e:	e86080e7          	jalr	-378(ra) # 3c0 <putc>
      }
      state = 0;
 542:	4981                	li	s3,0
 544:	b765                	j	4ec <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 546:	008b0913          	addi	s2,s6,8
 54a:	4685                	li	a3,1
 54c:	4629                	li	a2,10
 54e:	000b2583          	lw	a1,0(s6)
 552:	8556                	mv	a0,s5
 554:	00000097          	auipc	ra,0x0
 558:	e8e080e7          	jalr	-370(ra) # 3e2 <printint>
 55c:	8b4a                	mv	s6,s2
      state = 0;
 55e:	4981                	li	s3,0
 560:	b771                	j	4ec <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 562:	008b0913          	addi	s2,s6,8
 566:	4681                	li	a3,0
 568:	4629                	li	a2,10
 56a:	000b2583          	lw	a1,0(s6)
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	e72080e7          	jalr	-398(ra) # 3e2 <printint>
 578:	8b4a                	mv	s6,s2
      state = 0;
 57a:	4981                	li	s3,0
 57c:	bf85                	j	4ec <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 57e:	008b0913          	addi	s2,s6,8
 582:	4681                	li	a3,0
 584:	4641                	li	a2,16
 586:	000b2583          	lw	a1,0(s6)
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	e56080e7          	jalr	-426(ra) # 3e2 <printint>
 594:	8b4a                	mv	s6,s2
      state = 0;
 596:	4981                	li	s3,0
 598:	bf91                	j	4ec <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 59a:	008b0793          	addi	a5,s6,8
 59e:	f8f43423          	sd	a5,-120(s0)
 5a2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5a6:	03000593          	li	a1,48
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	e14080e7          	jalr	-492(ra) # 3c0 <putc>
  putc(fd, 'x');
 5b4:	85ea                	mv	a1,s10
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	e08080e7          	jalr	-504(ra) # 3c0 <putc>
 5c0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5c2:	03c9d793          	srli	a5,s3,0x3c
 5c6:	97de                	add	a5,a5,s7
 5c8:	0007c583          	lbu	a1,0(a5)
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	df2080e7          	jalr	-526(ra) # 3c0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5d6:	0992                	slli	s3,s3,0x4
 5d8:	397d                	addiw	s2,s2,-1
 5da:	fe0914e3          	bnez	s2,5c2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5de:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	b721                	j	4ec <vprintf+0x60>
        s = va_arg(ap, char*);
 5e6:	008b0993          	addi	s3,s6,8
 5ea:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5ee:	02090163          	beqz	s2,610 <vprintf+0x184>
        while(*s != 0){
 5f2:	00094583          	lbu	a1,0(s2)
 5f6:	c9a1                	beqz	a1,646 <vprintf+0x1ba>
          putc(fd, *s);
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	dc6080e7          	jalr	-570(ra) # 3c0 <putc>
          s++;
 602:	0905                	addi	s2,s2,1
        while(*s != 0){
 604:	00094583          	lbu	a1,0(s2)
 608:	f9e5                	bnez	a1,5f8 <vprintf+0x16c>
        s = va_arg(ap, char*);
 60a:	8b4e                	mv	s6,s3
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bdf9                	j	4ec <vprintf+0x60>
          s = "(null)";
 610:	00000917          	auipc	s2,0x0
 614:	5b890913          	addi	s2,s2,1464 # bc8 <uthread_start_all+0x10c>
        while(*s != 0){
 618:	02800593          	li	a1,40
 61c:	bff1                	j	5f8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 61e:	008b0913          	addi	s2,s6,8
 622:	000b4583          	lbu	a1,0(s6)
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	d98080e7          	jalr	-616(ra) # 3c0 <putc>
 630:	8b4a                	mv	s6,s2
      state = 0;
 632:	4981                	li	s3,0
 634:	bd65                	j	4ec <vprintf+0x60>
        putc(fd, c);
 636:	85d2                	mv	a1,s4
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	d86080e7          	jalr	-634(ra) # 3c0 <putc>
      state = 0;
 642:	4981                	li	s3,0
 644:	b565                	j	4ec <vprintf+0x60>
        s = va_arg(ap, char*);
 646:	8b4e                	mv	s6,s3
      state = 0;
 648:	4981                	li	s3,0
 64a:	b54d                	j	4ec <vprintf+0x60>
    }
  }
}
 64c:	70e6                	ld	ra,120(sp)
 64e:	7446                	ld	s0,112(sp)
 650:	74a6                	ld	s1,104(sp)
 652:	7906                	ld	s2,96(sp)
 654:	69e6                	ld	s3,88(sp)
 656:	6a46                	ld	s4,80(sp)
 658:	6aa6                	ld	s5,72(sp)
 65a:	6b06                	ld	s6,64(sp)
 65c:	7be2                	ld	s7,56(sp)
 65e:	7c42                	ld	s8,48(sp)
 660:	7ca2                	ld	s9,40(sp)
 662:	7d02                	ld	s10,32(sp)
 664:	6de2                	ld	s11,24(sp)
 666:	6109                	addi	sp,sp,128
 668:	8082                	ret

000000000000066a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 66a:	715d                	addi	sp,sp,-80
 66c:	ec06                	sd	ra,24(sp)
 66e:	e822                	sd	s0,16(sp)
 670:	1000                	addi	s0,sp,32
 672:	e010                	sd	a2,0(s0)
 674:	e414                	sd	a3,8(s0)
 676:	e818                	sd	a4,16(s0)
 678:	ec1c                	sd	a5,24(s0)
 67a:	03043023          	sd	a6,32(s0)
 67e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 682:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 686:	8622                	mv	a2,s0
 688:	00000097          	auipc	ra,0x0
 68c:	e04080e7          	jalr	-508(ra) # 48c <vprintf>
}
 690:	60e2                	ld	ra,24(sp)
 692:	6442                	ld	s0,16(sp)
 694:	6161                	addi	sp,sp,80
 696:	8082                	ret

0000000000000698 <printf>:

void
printf(const char *fmt, ...)
{
 698:	711d                	addi	sp,sp,-96
 69a:	ec06                	sd	ra,24(sp)
 69c:	e822                	sd	s0,16(sp)
 69e:	1000                	addi	s0,sp,32
 6a0:	e40c                	sd	a1,8(s0)
 6a2:	e810                	sd	a2,16(s0)
 6a4:	ec14                	sd	a3,24(s0)
 6a6:	f018                	sd	a4,32(s0)
 6a8:	f41c                	sd	a5,40(s0)
 6aa:	03043823          	sd	a6,48(s0)
 6ae:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6b2:	00840613          	addi	a2,s0,8
 6b6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6ba:	85aa                	mv	a1,a0
 6bc:	4505                	li	a0,1
 6be:	00000097          	auipc	ra,0x0
 6c2:	dce080e7          	jalr	-562(ra) # 48c <vprintf>
}
 6c6:	60e2                	ld	ra,24(sp)
 6c8:	6442                	ld	s0,16(sp)
 6ca:	6125                	addi	sp,sp,96
 6cc:	8082                	ret

00000000000006ce <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ce:	1141                	addi	sp,sp,-16
 6d0:	e422                	sd	s0,8(sp)
 6d2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6d4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d8:	00001797          	auipc	a5,0x1
 6dc:	9287b783          	ld	a5,-1752(a5) # 1000 <freep>
 6e0:	a805                	j	710 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6e2:	4618                	lw	a4,8(a2)
 6e4:	9db9                	addw	a1,a1,a4
 6e6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ea:	6398                	ld	a4,0(a5)
 6ec:	6318                	ld	a4,0(a4)
 6ee:	fee53823          	sd	a4,-16(a0)
 6f2:	a091                	j	736 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6f4:	ff852703          	lw	a4,-8(a0)
 6f8:	9e39                	addw	a2,a2,a4
 6fa:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6fc:	ff053703          	ld	a4,-16(a0)
 700:	e398                	sd	a4,0(a5)
 702:	a099                	j	748 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 704:	6398                	ld	a4,0(a5)
 706:	00e7e463          	bltu	a5,a4,70e <free+0x40>
 70a:	00e6ea63          	bltu	a3,a4,71e <free+0x50>
{
 70e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 710:	fed7fae3          	bgeu	a5,a3,704 <free+0x36>
 714:	6398                	ld	a4,0(a5)
 716:	00e6e463          	bltu	a3,a4,71e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 71a:	fee7eae3          	bltu	a5,a4,70e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 71e:	ff852583          	lw	a1,-8(a0)
 722:	6390                	ld	a2,0(a5)
 724:	02059713          	slli	a4,a1,0x20
 728:	9301                	srli	a4,a4,0x20
 72a:	0712                	slli	a4,a4,0x4
 72c:	9736                	add	a4,a4,a3
 72e:	fae60ae3          	beq	a2,a4,6e2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 732:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 736:	4790                	lw	a2,8(a5)
 738:	02061713          	slli	a4,a2,0x20
 73c:	9301                	srli	a4,a4,0x20
 73e:	0712                	slli	a4,a4,0x4
 740:	973e                	add	a4,a4,a5
 742:	fae689e3          	beq	a3,a4,6f4 <free+0x26>
  } else
    p->s.ptr = bp;
 746:	e394                	sd	a3,0(a5)
  freep = p;
 748:	00001717          	auipc	a4,0x1
 74c:	8af73c23          	sd	a5,-1864(a4) # 1000 <freep>
}
 750:	6422                	ld	s0,8(sp)
 752:	0141                	addi	sp,sp,16
 754:	8082                	ret

0000000000000756 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 756:	7139                	addi	sp,sp,-64
 758:	fc06                	sd	ra,56(sp)
 75a:	f822                	sd	s0,48(sp)
 75c:	f426                	sd	s1,40(sp)
 75e:	f04a                	sd	s2,32(sp)
 760:	ec4e                	sd	s3,24(sp)
 762:	e852                	sd	s4,16(sp)
 764:	e456                	sd	s5,8(sp)
 766:	e05a                	sd	s6,0(sp)
 768:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 76a:	02051493          	slli	s1,a0,0x20
 76e:	9081                	srli	s1,s1,0x20
 770:	04bd                	addi	s1,s1,15
 772:	8091                	srli	s1,s1,0x4
 774:	0014899b          	addiw	s3,s1,1
 778:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 77a:	00001517          	auipc	a0,0x1
 77e:	88653503          	ld	a0,-1914(a0) # 1000 <freep>
 782:	c515                	beqz	a0,7ae <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 784:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 786:	4798                	lw	a4,8(a5)
 788:	02977f63          	bgeu	a4,s1,7c6 <malloc+0x70>
 78c:	8a4e                	mv	s4,s3
 78e:	0009871b          	sext.w	a4,s3
 792:	6685                	lui	a3,0x1
 794:	00d77363          	bgeu	a4,a3,79a <malloc+0x44>
 798:	6a05                	lui	s4,0x1
 79a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 79e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7a2:	00001917          	auipc	s2,0x1
 7a6:	85e90913          	addi	s2,s2,-1954 # 1000 <freep>
  if(p == (char*)-1)
 7aa:	5afd                	li	s5,-1
 7ac:	a88d                	j	81e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7ae:	00001797          	auipc	a5,0x1
 7b2:	87278793          	addi	a5,a5,-1934 # 1020 <base>
 7b6:	00001717          	auipc	a4,0x1
 7ba:	84f73523          	sd	a5,-1974(a4) # 1000 <freep>
 7be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7c4:	b7e1                	j	78c <malloc+0x36>
      if(p->s.size == nunits)
 7c6:	02e48b63          	beq	s1,a4,7fc <malloc+0xa6>
        p->s.size -= nunits;
 7ca:	4137073b          	subw	a4,a4,s3
 7ce:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7d0:	1702                	slli	a4,a4,0x20
 7d2:	9301                	srli	a4,a4,0x20
 7d4:	0712                	slli	a4,a4,0x4
 7d6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7d8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7dc:	00001717          	auipc	a4,0x1
 7e0:	82a73223          	sd	a0,-2012(a4) # 1000 <freep>
      return (void*)(p + 1);
 7e4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7e8:	70e2                	ld	ra,56(sp)
 7ea:	7442                	ld	s0,48(sp)
 7ec:	74a2                	ld	s1,40(sp)
 7ee:	7902                	ld	s2,32(sp)
 7f0:	69e2                	ld	s3,24(sp)
 7f2:	6a42                	ld	s4,16(sp)
 7f4:	6aa2                	ld	s5,8(sp)
 7f6:	6b02                	ld	s6,0(sp)
 7f8:	6121                	addi	sp,sp,64
 7fa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7fc:	6398                	ld	a4,0(a5)
 7fe:	e118                	sd	a4,0(a0)
 800:	bff1                	j	7dc <malloc+0x86>
  hp->s.size = nu;
 802:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 806:	0541                	addi	a0,a0,16
 808:	00000097          	auipc	ra,0x0
 80c:	ec6080e7          	jalr	-314(ra) # 6ce <free>
  return freep;
 810:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 814:	d971                	beqz	a0,7e8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 816:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 818:	4798                	lw	a4,8(a5)
 81a:	fa9776e3          	bgeu	a4,s1,7c6 <malloc+0x70>
    if(p == freep)
 81e:	00093703          	ld	a4,0(s2)
 822:	853e                	mv	a0,a5
 824:	fef719e3          	bne	a4,a5,816 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 828:	8552                	mv	a0,s4
 82a:	00000097          	auipc	ra,0x0
 82e:	b7e080e7          	jalr	-1154(ra) # 3a8 <sbrk>
  if(p == (char*)-1)
 832:	fd5518e3          	bne	a0,s5,802 <malloc+0xac>
        return 0;
 836:	4501                	li	a0,0
 838:	bf45                	j	7e8 <malloc+0x92>

000000000000083a <uswtch>:
 83a:	00153023          	sd	ra,0(a0)
 83e:	00253423          	sd	sp,8(a0)
 842:	e900                	sd	s0,16(a0)
 844:	ed04                	sd	s1,24(a0)
 846:	03253023          	sd	s2,32(a0)
 84a:	03353423          	sd	s3,40(a0)
 84e:	03453823          	sd	s4,48(a0)
 852:	03553c23          	sd	s5,56(a0)
 856:	05653023          	sd	s6,64(a0)
 85a:	05753423          	sd	s7,72(a0)
 85e:	05853823          	sd	s8,80(a0)
 862:	05953c23          	sd	s9,88(a0)
 866:	07a53023          	sd	s10,96(a0)
 86a:	07b53423          	sd	s11,104(a0)
 86e:	0005b083          	ld	ra,0(a1)
 872:	0085b103          	ld	sp,8(a1)
 876:	6980                	ld	s0,16(a1)
 878:	6d84                	ld	s1,24(a1)
 87a:	0205b903          	ld	s2,32(a1)
 87e:	0285b983          	ld	s3,40(a1)
 882:	0305ba03          	ld	s4,48(a1)
 886:	0385ba83          	ld	s5,56(a1)
 88a:	0405bb03          	ld	s6,64(a1)
 88e:	0485bb83          	ld	s7,72(a1)
 892:	0505bc03          	ld	s8,80(a1)
 896:	0585bc83          	ld	s9,88(a1)
 89a:	0605bd03          	ld	s10,96(a1)
 89e:	0685bd83          	ld	s11,104(a1)
 8a2:	8082                	ret

00000000000008a4 <uthread_exit>:
    curr_thread = next_thread;
    uswtch(curr_context, next_context);

}

void uthread_exit(){
 8a4:	1141                	addi	sp,sp,-16
 8a6:	e406                	sd	ra,8(sp)
 8a8:	e022                	sd	s0,0(sp)
 8aa:	0800                	addi	s0,sp,16
    // Change the state of the current thread to FREE
    curr_thread->state = FREE;
 8ac:	00000517          	auipc	a0,0x0
 8b0:	75c53503          	ld	a0,1884(a0) # 1008 <curr_thread>
 8b4:	6785                	lui	a5,0x1
 8b6:	97aa                	add	a5,a5,a0
 8b8:	fa07a223          	sw	zero,-92(a5) # fa4 <digits+0x3d4>
    // Find another runnable thread to switch to (make sure its not the current_thread)
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 8bc:	411c                	lw	a5,0(a0)
 8be:	2785                	addiw	a5,a5,1
 8c0:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 8c2:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 8c4:	4585                	li	a1,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 8c6:	00000617          	auipc	a2,0x0
 8ca:	7da60613          	addi	a2,a2,2010 # 10a0 <uthreads_arr>
 8ce:	6805                	lui	a6,0x1
 8d0:	4889                	li	a7,2
 8d2:	a819                	j	8e8 <uthread_exit+0x44>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 8d4:	2785                	addiw	a5,a5,1
 8d6:	41f7d71b          	sraiw	a4,a5,0x1f
 8da:	01e7571b          	srliw	a4,a4,0x1e
 8de:	9fb9                	addw	a5,a5,a4
 8e0:	8b8d                	andi	a5,a5,3
 8e2:	9f99                	subw	a5,a5,a4
 8e4:	36fd                	addiw	a3,a3,-1
 8e6:	ca9d                	beqz	a3,91c <uthread_exit+0x78>
        if (uthreads_arr[i].state == RUNNABLE &&
 8e8:	00779713          	slli	a4,a5,0x7
 8ec:	973e                	add	a4,a4,a5
 8ee:	0716                	slli	a4,a4,0x5
 8f0:	9732                	add	a4,a4,a2
 8f2:	9742                	add	a4,a4,a6
 8f4:	fa472703          	lw	a4,-92(a4)
 8f8:	fd171ee3          	bne	a4,a7,8d4 <uthread_exit+0x30>
            uthreads_arr[i].priority > max_priority) {
 8fc:	00779713          	slli	a4,a5,0x7
 900:	973e                	add	a4,a4,a5
 902:	0716                	slli	a4,a4,0x5
 904:	9732                	add	a4,a4,a2
 906:	9742                	add	a4,a4,a6
 908:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 90a:	fce375e3          	bgeu	t1,a4,8d4 <uthread_exit+0x30>
            next_thread = &uthreads_arr[i];
 90e:	00779593          	slli	a1,a5,0x7
 912:	95be                	add	a1,a1,a5
 914:	0596                	slli	a1,a1,0x5
 916:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 918:	833a                	mv	t1,a4
 91a:	bf6d                	j	8d4 <uthread_exit+0x30>
        }
    }
    if (next_thread == (struct uthread *) 1) {
 91c:	4785                	li	a5,1
 91e:	02f58863          	beq	a1,a5,94e <uthread_exit+0xaa>
        exit(0);  // Exit the process if there are no more runnable threads
    }
    // Switch to the next thread
    struct context *curr_context = &curr_thread->context;
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 922:	6785                	lui	a5,0x1
 924:	00f58733          	add	a4,a1,a5
 928:	4685                	li	a3,1
 92a:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 92e:	00000717          	auipc	a4,0x0
 932:	6cb73d23          	sd	a1,1754(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 936:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x3d8>
    uswtch(curr_context, next_context);
 93a:	95be                	add	a1,a1,a5
 93c:	953e                	add	a0,a0,a5
 93e:	00000097          	auipc	ra,0x0
 942:	efc080e7          	jalr	-260(ra) # 83a <uswtch>
}
 946:	60a2                	ld	ra,8(sp)
 948:	6402                	ld	s0,0(sp)
 94a:	0141                	addi	sp,sp,16
 94c:	8082                	ret
        exit(0);  // Exit the process if there are no more runnable threads
 94e:	4501                	li	a0,0
 950:	00000097          	auipc	ra,0x0
 954:	9d0080e7          	jalr	-1584(ra) # 320 <exit>

0000000000000958 <uthread_create>:
int uthread_create(void (*start_func)(), enum sched_priority priority) {
 958:	1141                	addi	sp,sp,-16
 95a:	e422                	sd	s0,8(sp)
 95c:	0800                	addi	s0,sp,16
    for (i = 0; i < MAX_UTHREADS; i++) {
 95e:	00001717          	auipc	a4,0x1
 962:	6e670713          	addi	a4,a4,1766 # 2044 <uthreads_arr+0xfa4>
 966:	4781                	li	a5,0
 968:	6605                	lui	a2,0x1
 96a:	02060613          	addi	a2,a2,32 # 1020 <base>
 96e:	4811                	li	a6,4
        if (uthreads_arr[i].state == FREE) {
 970:	4314                	lw	a3,0(a4)
 972:	c699                	beqz	a3,980 <uthread_create+0x28>
    for (i = 0; i < MAX_UTHREADS; i++) {
 974:	2785                	addiw	a5,a5,1
 976:	9732                	add	a4,a4,a2
 978:	ff079ce3          	bne	a5,a6,970 <uthread_create+0x18>
        return -1;
 97c:	557d                	li	a0,-1
 97e:	a0b9                	j	9cc <uthread_create+0x74>
            curr_thread = &uthreads_arr[i];
 980:	00779713          	slli	a4,a5,0x7
 984:	973e                	add	a4,a4,a5
 986:	0716                	slli	a4,a4,0x5
 988:	00000697          	auipc	a3,0x0
 98c:	71868693          	addi	a3,a3,1816 # 10a0 <uthreads_arr>
 990:	9736                	add	a4,a4,a3
 992:	00000697          	auipc	a3,0x0
 996:	66e6bb23          	sd	a4,1654(a3) # 1008 <curr_thread>
    if (i >= MAX_UTHREADS) {
 99a:	468d                	li	a3,3
 99c:	02f6cb63          	blt	a3,a5,9d2 <uthread_create+0x7a>
    curr_thread->id = i; 
 9a0:	c31c                	sw	a5,0(a4)
    curr_thread->priority = priority;
 9a2:	6685                	lui	a3,0x1
 9a4:	00d707b3          	add	a5,a4,a3
 9a8:	cf8c                	sw	a1,24(a5)
    curr_thread->context.ra = (uint64) start_func;
 9aa:	faa7b423          	sd	a0,-88(a5)
    curr_thread->context.sp = (uint64) &curr_thread->ustack[STACK_SIZE];
 9ae:	fa468693          	addi	a3,a3,-92 # fa4 <digits+0x3d4>
 9b2:	9736                	add	a4,a4,a3
 9b4:	fae7b823          	sd	a4,-80(a5)
    curr_thread->ustack[STACK_SIZE - 1] = (uint64) uthread_exit; // Return address to uthread_exit
 9b8:	00000717          	auipc	a4,0x0
 9bc:	eec70713          	addi	a4,a4,-276 # 8a4 <uthread_exit>
 9c0:	fae781a3          	sb	a4,-93(a5)
    curr_thread->state = RUNNABLE;
 9c4:	4709                	li	a4,2
 9c6:	fae7a223          	sw	a4,-92(a5)
     return 0;
 9ca:	4501                	li	a0,0
}
 9cc:	6422                	ld	s0,8(sp)
 9ce:	0141                	addi	sp,sp,16
 9d0:	8082                	ret
        return -1;
 9d2:	557d                	li	a0,-1
 9d4:	bfe5                	j	9cc <uthread_create+0x74>

00000000000009d6 <uthread_yield>:
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 9d6:	00000517          	auipc	a0,0x0
 9da:	63253503          	ld	a0,1586(a0) # 1008 <curr_thread>
 9de:	411c                	lw	a5,0(a0)
 9e0:	2785                	addiw	a5,a5,1
 9e2:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 9e4:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 9e6:	4585                	li	a1,1
        if (uthreads_arr[i].state == RUNNABLE &&
 9e8:	00000617          	auipc	a2,0x0
 9ec:	6b860613          	addi	a2,a2,1720 # 10a0 <uthreads_arr>
 9f0:	6805                	lui	a6,0x1
 9f2:	4889                	li	a7,2
 9f4:	a819                	j	a0a <uthread_yield+0x34>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 9f6:	2785                	addiw	a5,a5,1
 9f8:	41f7d71b          	sraiw	a4,a5,0x1f
 9fc:	01e7571b          	srliw	a4,a4,0x1e
 a00:	9fb9                	addw	a5,a5,a4
 a02:	8b8d                	andi	a5,a5,3
 a04:	9f99                	subw	a5,a5,a4
 a06:	36fd                	addiw	a3,a3,-1
 a08:	ca9d                	beqz	a3,a3e <uthread_yield+0x68>
        if (uthreads_arr[i].state == RUNNABLE &&
 a0a:	00779713          	slli	a4,a5,0x7
 a0e:	973e                	add	a4,a4,a5
 a10:	0716                	slli	a4,a4,0x5
 a12:	9732                	add	a4,a4,a2
 a14:	9742                	add	a4,a4,a6
 a16:	fa472703          	lw	a4,-92(a4)
 a1a:	fd171ee3          	bne	a4,a7,9f6 <uthread_yield+0x20>
            uthreads_arr[i].priority > max_priority) {
 a1e:	00779713          	slli	a4,a5,0x7
 a22:	973e                	add	a4,a4,a5
 a24:	0716                	slli	a4,a4,0x5
 a26:	9732                	add	a4,a4,a2
 a28:	9742                	add	a4,a4,a6
 a2a:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 a2c:	fce375e3          	bgeu	t1,a4,9f6 <uthread_yield+0x20>
            next_thread = &uthreads_arr[i];
 a30:	00779593          	slli	a1,a5,0x7
 a34:	95be                	add	a1,a1,a5
 a36:	0596                	slli	a1,a1,0x5
 a38:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 a3a:	833a                	mv	t1,a4
 a3c:	bf6d                	j	9f6 <uthread_yield+0x20>
    if (next_thread == (struct uthread *) 1) {
 a3e:	4785                	li	a5,1
 a40:	04f58163          	beq	a1,a5,a82 <uthread_yield+0xac>
void uthread_yield() {
 a44:	1141                	addi	sp,sp,-16
 a46:	e406                	sd	ra,8(sp)
 a48:	e022                	sd	s0,0(sp)
 a4a:	0800                	addi	s0,sp,16
    curr_thread->state = RUNNABLE;
 a4c:	6785                	lui	a5,0x1
 a4e:	00f50733          	add	a4,a0,a5
 a52:	4689                	li	a3,2
 a54:	fad72223          	sw	a3,-92(a4)
    next_thread->state = RUNNING;
 a58:	00f58733          	add	a4,a1,a5
 a5c:	4685                	li	a3,1
 a5e:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 a62:	00000717          	auipc	a4,0x0
 a66:	5ab73323          	sd	a1,1446(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 a6a:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x3d8>
    uswtch(curr_context, next_context);
 a6e:	95be                	add	a1,a1,a5
 a70:	953e                	add	a0,a0,a5
 a72:	00000097          	auipc	ra,0x0
 a76:	dc8080e7          	jalr	-568(ra) # 83a <uswtch>
}
 a7a:	60a2                	ld	ra,8(sp)
 a7c:	6402                	ld	s0,0(sp)
 a7e:	0141                	addi	sp,sp,16
 a80:	8082                	ret
 a82:	8082                	ret

0000000000000a84 <uthread_set_priority>:

enum sched_priority uthread_set_priority(enum sched_priority priority){
 a84:	1141                	addi	sp,sp,-16
 a86:	e422                	sd	s0,8(sp)
 a88:	0800                	addi	s0,sp,16
    enum sched_priority to_return =curr_thread->priority;
 a8a:	00000797          	auipc	a5,0x0
 a8e:	57e7b783          	ld	a5,1406(a5) # 1008 <curr_thread>
 a92:	6705                	lui	a4,0x1
 a94:	97ba                	add	a5,a5,a4
 a96:	4f98                	lw	a4,24(a5)
    curr_thread->priority=priority;
 a98:	cf88                	sw	a0,24(a5)
    return to_return;
}
 a9a:	853a                	mv	a0,a4
 a9c:	6422                	ld	s0,8(sp)
 a9e:	0141                	addi	sp,sp,16
 aa0:	8082                	ret

0000000000000aa2 <uthread_get_priority>:

enum sched_priority uthread_get_priority(){
 aa2:	1141                	addi	sp,sp,-16
 aa4:	e422                	sd	s0,8(sp)
 aa6:	0800                	addi	s0,sp,16
    return curr_thread->priority;
 aa8:	00000797          	auipc	a5,0x0
 aac:	5607b783          	ld	a5,1376(a5) # 1008 <curr_thread>
 ab0:	6705                	lui	a4,0x1
 ab2:	97ba                	add	a5,a5,a4
}
 ab4:	4f88                	lw	a0,24(a5)
 ab6:	6422                	ld	s0,8(sp)
 ab8:	0141                	addi	sp,sp,16
 aba:	8082                	ret

0000000000000abc <uthread_start_all>:

int uthread_start_all(){
    if (started){
 abc:	00000797          	auipc	a5,0x0
 ac0:	5547a783          	lw	a5,1364(a5) # 1010 <started>
 ac4:	ebc5                	bnez	a5,b74 <uthread_start_all+0xb8>
int uthread_start_all(){
 ac6:	1141                	addi	sp,sp,-16
 ac8:	e406                	sd	ra,8(sp)
 aca:	e022                	sd	s0,0(sp)
 acc:	0800                	addi	s0,sp,16
        return -1;
    }
    started=1;
 ace:	4785                	li	a5,1
 ad0:	00000717          	auipc	a4,0x0
 ad4:	54f72023          	sw	a5,1344(a4) # 1010 <started>
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 ad8:	00000797          	auipc	a5,0x0
 adc:	5307b783          	ld	a5,1328(a5) # 1008 <curr_thread>
 ae0:	439c                	lw	a5,0(a5)
 ae2:	2785                	addiw	a5,a5,1
 ae4:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 ae6:	4881                	li	a7,0
    struct uthread *next_thread = (struct uthread *) 1;
 ae8:	4605                	li	a2,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 aea:	00000597          	auipc	a1,0x0
 aee:	5b658593          	addi	a1,a1,1462 # 10a0 <uthreads_arr>
 af2:	6505                	lui	a0,0x1
 af4:	4809                	li	a6,2
 af6:	a819                	j	b0c <uthread_start_all+0x50>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 af8:	2785                	addiw	a5,a5,1
 afa:	41f7d71b          	sraiw	a4,a5,0x1f
 afe:	01e7571b          	srliw	a4,a4,0x1e
 b02:	9fb9                	addw	a5,a5,a4
 b04:	8b8d                	andi	a5,a5,3
 b06:	9f99                	subw	a5,a5,a4
 b08:	36fd                	addiw	a3,a3,-1
 b0a:	ca9d                	beqz	a3,b40 <uthread_start_all+0x84>
        if (uthreads_arr[i].state == RUNNABLE &&
 b0c:	00779713          	slli	a4,a5,0x7
 b10:	973e                	add	a4,a4,a5
 b12:	0716                	slli	a4,a4,0x5
 b14:	972e                	add	a4,a4,a1
 b16:	972a                	add	a4,a4,a0
 b18:	fa472703          	lw	a4,-92(a4)
 b1c:	fd071ee3          	bne	a4,a6,af8 <uthread_start_all+0x3c>
            uthreads_arr[i].priority > max_priority) {
 b20:	00779713          	slli	a4,a5,0x7
 b24:	973e                	add	a4,a4,a5
 b26:	0716                	slli	a4,a4,0x5
 b28:	972e                	add	a4,a4,a1
 b2a:	972a                	add	a4,a4,a0
 b2c:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 b2e:	fce8f5e3          	bgeu	a7,a4,af8 <uthread_start_all+0x3c>
            next_thread = &uthreads_arr[i];
 b32:	00779613          	slli	a2,a5,0x7
 b36:	963e                	add	a2,a2,a5
 b38:	0616                	slli	a2,a2,0x5
 b3a:	962e                	add	a2,a2,a1
            max_priority = uthreads_arr[i].priority;
 b3c:	88ba                	mv	a7,a4
 b3e:	bf6d                	j	af8 <uthread_start_all+0x3c>
        }
    }
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 b40:	6585                	lui	a1,0x1
 b42:	00b607b3          	add	a5,a2,a1
 b46:	4705                	li	a4,1
 b48:	fae7a223          	sw	a4,-92(a5)
    curr_thread = next_thread;
 b4c:	00000797          	auipc	a5,0x0
 b50:	4ac7be23          	sd	a2,1212(a5) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 b54:	fa858593          	addi	a1,a1,-88 # fa8 <digits+0x3d8>
    uswtch(&garbageContext,next_context);
 b58:	95b2                	add	a1,a1,a2
 b5a:	00000517          	auipc	a0,0x0
 b5e:	4d650513          	addi	a0,a0,1238 # 1030 <garbageContext>
 b62:	00000097          	auipc	ra,0x0
 b66:	cd8080e7          	jalr	-808(ra) # 83a <uswtch>
    return -1;
 b6a:	557d                	li	a0,-1
 b6c:	60a2                	ld	ra,8(sp)
 b6e:	6402                	ld	s0,0(sp)
 b70:	0141                	addi	sp,sp,16
 b72:	8082                	ret
 b74:	557d                	li	a0,-1
 b76:	8082                	ret
