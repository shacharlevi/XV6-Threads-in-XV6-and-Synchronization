
user/_tests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread1>:
#include <stdio.h>
#include "uthread.h"

void thread1() {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("This is thread 1\n");
   8:	00001517          	auipc	a0,0x1
   c:	b0850513          	addi	a0,a0,-1272 # b10 <uthread_yield+0xfc>
  10:	00000097          	auipc	ra,0x0
  14:	748080e7          	jalr	1864(ra) # 758 <printf>
}
  18:	60a2                	ld	ra,8(sp)
  1a:	6402                	ld	s0,0(sp)
  1c:	0141                	addi	sp,sp,16
  1e:	8082                	ret

0000000000000020 <thread2>:

void thread2() {
  20:	1141                	addi	sp,sp,-16
  22:	e406                	sd	ra,8(sp)
  24:	e022                	sd	s0,0(sp)
  26:	0800                	addi	s0,sp,16
    printf("This is thread 2\n");
  28:	00001517          	auipc	a0,0x1
  2c:	b0050513          	addi	a0,a0,-1280 # b28 <uthread_yield+0x114>
  30:	00000097          	auipc	ra,0x0
  34:	728080e7          	jalr	1832(ra) # 758 <printf>
}
  38:	60a2                	ld	ra,8(sp)
  3a:	6402                	ld	s0,0(sp)
  3c:	0141                	addi	sp,sp,16
  3e:	8082                	ret

0000000000000040 <main>:

int main() {
  40:	1101                	addi	sp,sp,-32
  42:	ec06                	sd	ra,24(sp)
  44:	e822                	sd	s0,16(sp)
  46:	e426                	sd	s1,8(sp)
  48:	1000                	addi	s0,sp,32
    int t1 = uthread_create(thread1, LOW);
  4a:	4581                	li	a1,0
  4c:	00000517          	auipc	a0,0x0
  50:	fb450513          	addi	a0,a0,-76 # 0 <thread1>
  54:	00001097          	auipc	ra,0x1
  58:	91c080e7          	jalr	-1764(ra) # 970 <uthread_create>
  5c:	84aa                	mv	s1,a0
    int t2 = uthread_create(thread2, HIGH);
  5e:	4589                	li	a1,2
  60:	00000517          	auipc	a0,0x0
  64:	fc050513          	addi	a0,a0,-64 # 20 <thread2>
  68:	00001097          	auipc	ra,0x1
  6c:	908080e7          	jalr	-1784(ra) # 970 <uthread_create>
    if (t1 < 0 || t2 < 0) {
  70:	0a04cc63          	bltz	s1,128 <main+0xe8>
  74:	0a054a63          	bltz	a0,128 <main+0xe8>
        printf("Error: failed to create user threads\n");
        return 1;
    }
    uthread_yield();
  78:	00001097          	auipc	ra,0x1
  7c:	99c080e7          	jalr	-1636(ra) # a14 <uthread_yield>
    printf("Switched to thread 1\n");
  80:	00001517          	auipc	a0,0x1
  84:	ae850513          	addi	a0,a0,-1304 # b68 <uthread_yield+0x154>
  88:	00000097          	auipc	ra,0x0
  8c:	6d0080e7          	jalr	1744(ra) # 758 <printf>
    uthread_yield();
  90:	00001097          	auipc	ra,0x1
  94:	984080e7          	jalr	-1660(ra) # a14 <uthread_yield>
    printf("Switched to thread 2\n");
  98:	00001517          	auipc	a0,0x1
  9c:	ae850513          	addi	a0,a0,-1304 # b80 <uthread_yield+0x16c>
  a0:	00000097          	auipc	ra,0x0
  a4:	6b8080e7          	jalr	1720(ra) # 758 <printf>
     uthread_yield();
  a8:	00001097          	auipc	ra,0x1
  ac:	96c080e7          	jalr	-1684(ra) # a14 <uthread_yield>
    printf("Switched back to thread 1\n");
  b0:	00001517          	auipc	a0,0x1
  b4:	ae850513          	addi	a0,a0,-1304 # b98 <uthread_yield+0x184>
  b8:	00000097          	auipc	ra,0x0
  bc:	6a0080e7          	jalr	1696(ra) # 758 <printf>
    uthread_exit();
  c0:	00001097          	auipc	ra,0x1
  c4:	8a4080e7          	jalr	-1884(ra) # 964 <uthread_exit>
    uthread_yield();
  c8:	00001097          	auipc	ra,0x1
  cc:	94c080e7          	jalr	-1716(ra) # a14 <uthread_yield>
    printf("Switched to thread 2\n");
  d0:	00001517          	auipc	a0,0x1
  d4:	ab050513          	addi	a0,a0,-1360 # b80 <uthread_yield+0x16c>
  d8:	00000097          	auipc	ra,0x0
  dc:	680080e7          	jalr	1664(ra) # 758 <printf>
    uthread_exit();
  e0:	00001097          	auipc	ra,0x1
  e4:	884080e7          	jalr	-1916(ra) # 964 <uthread_exit>
    if (uthread_create(thread1, HIGH) >= 0 || uthread_create(thread2,LOW) >= 0) {
  e8:	4589                	li	a1,2
  ea:	00000517          	auipc	a0,0x0
  ee:	f1650513          	addi	a0,a0,-234 # 0 <thread1>
  f2:	00001097          	auipc	ra,0x1
  f6:	87e080e7          	jalr	-1922(ra) # 970 <uthread_create>
  fa:	00055d63          	bgez	a0,114 <main+0xd4>
  fe:	4581                	li	a1,0
 100:	00000517          	auipc	a0,0x0
 104:	f2050513          	addi	a0,a0,-224 # 20 <thread2>
 108:	00001097          	auipc	ra,0x1
 10c:	868080e7          	jalr	-1944(ra) # 970 <uthread_create>
 110:	02054a63          	bltz	a0,144 <main+0x104>
        printf("Error: user threads were not properly terminated\n");
 114:	00001517          	auipc	a0,0x1
 118:	aa450513          	addi	a0,a0,-1372 # bb8 <uthread_yield+0x1a4>
 11c:	00000097          	auipc	ra,0x0
 120:	63c080e7          	jalr	1596(ra) # 758 <printf>
        return 1;
 124:	4505                	li	a0,1
 126:	a811                	j	13a <main+0xfa>
        printf("Error: failed to create user threads\n");
 128:	00001517          	auipc	a0,0x1
 12c:	a1850513          	addi	a0,a0,-1512 # b40 <uthread_yield+0x12c>
 130:	00000097          	auipc	ra,0x0
 134:	628080e7          	jalr	1576(ra) # 758 <printf>
        return 1;
 138:	4505                	li	a0,1
    }
    printf("All user threads terminated successfully\n");
    return 0;
}
 13a:	60e2                	ld	ra,24(sp)
 13c:	6442                	ld	s0,16(sp)
 13e:	64a2                	ld	s1,8(sp)
 140:	6105                	addi	sp,sp,32
 142:	8082                	ret
    printf("All user threads terminated successfully\n");
 144:	00001517          	auipc	a0,0x1
 148:	aac50513          	addi	a0,a0,-1364 # bf0 <uthread_yield+0x1dc>
 14c:	00000097          	auipc	ra,0x0
 150:	60c080e7          	jalr	1548(ra) # 758 <printf>
    return 0;
 154:	4501                	li	a0,0
 156:	b7d5                	j	13a <main+0xfa>

0000000000000158 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 158:	1141                	addi	sp,sp,-16
 15a:	e406                	sd	ra,8(sp)
 15c:	e022                	sd	s0,0(sp)
 15e:	0800                	addi	s0,sp,16
  extern int main();
  main();
 160:	00000097          	auipc	ra,0x0
 164:	ee0080e7          	jalr	-288(ra) # 40 <main>
  exit(0);
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	276080e7          	jalr	630(ra) # 3e0 <exit>

0000000000000172 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 172:	1141                	addi	sp,sp,-16
 174:	e422                	sd	s0,8(sp)
 176:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 178:	87aa                	mv	a5,a0
 17a:	0585                	addi	a1,a1,1
 17c:	0785                	addi	a5,a5,1
 17e:	fff5c703          	lbu	a4,-1(a1)
 182:	fee78fa3          	sb	a4,-1(a5)
 186:	fb75                	bnez	a4,17a <strcpy+0x8>
    ;
  return os;
}
 188:	6422                	ld	s0,8(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret

000000000000018e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e422                	sd	s0,8(sp)
 192:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	cb91                	beqz	a5,1ac <strcmp+0x1e>
 19a:	0005c703          	lbu	a4,0(a1)
 19e:	00f71763          	bne	a4,a5,1ac <strcmp+0x1e>
    p++, q++;
 1a2:	0505                	addi	a0,a0,1
 1a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	fbe5                	bnez	a5,19a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ac:	0005c503          	lbu	a0,0(a1)
}
 1b0:	40a7853b          	subw	a0,a5,a0
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strlen>:

uint
strlen(const char *s)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cf91                	beqz	a5,1e0 <strlen+0x26>
 1c6:	0505                	addi	a0,a0,1
 1c8:	87aa                	mv	a5,a0
 1ca:	4685                	li	a3,1
 1cc:	9e89                	subw	a3,a3,a0
 1ce:	00f6853b          	addw	a0,a3,a5
 1d2:	0785                	addi	a5,a5,1
 1d4:	fff7c703          	lbu	a4,-1(a5)
 1d8:	fb7d                	bnez	a4,1ce <strlen+0x14>
    ;
  return n;
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret
  for(n = 0; s[n]; n++)
 1e0:	4501                	li	a0,0
 1e2:	bfe5                	j	1da <strlen+0x20>

00000000000001e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ea:	ca19                	beqz	a2,200 <memset+0x1c>
 1ec:	87aa                	mv	a5,a0
 1ee:	1602                	slli	a2,a2,0x20
 1f0:	9201                	srli	a2,a2,0x20
 1f2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1fa:	0785                	addi	a5,a5,1
 1fc:	fee79de3          	bne	a5,a4,1f6 <memset+0x12>
  }
  return dst;
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret

0000000000000206 <strchr>:

char*
strchr(const char *s, char c)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 20c:	00054783          	lbu	a5,0(a0)
 210:	cb99                	beqz	a5,226 <strchr+0x20>
    if(*s == c)
 212:	00f58763          	beq	a1,a5,220 <strchr+0x1a>
  for(; *s; s++)
 216:	0505                	addi	a0,a0,1
 218:	00054783          	lbu	a5,0(a0)
 21c:	fbfd                	bnez	a5,212 <strchr+0xc>
      return (char*)s;
  return 0;
 21e:	4501                	li	a0,0
}
 220:	6422                	ld	s0,8(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret
  return 0;
 226:	4501                	li	a0,0
 228:	bfe5                	j	220 <strchr+0x1a>

000000000000022a <gets>:

char*
gets(char *buf, int max)
{
 22a:	711d                	addi	sp,sp,-96
 22c:	ec86                	sd	ra,88(sp)
 22e:	e8a2                	sd	s0,80(sp)
 230:	e4a6                	sd	s1,72(sp)
 232:	e0ca                	sd	s2,64(sp)
 234:	fc4e                	sd	s3,56(sp)
 236:	f852                	sd	s4,48(sp)
 238:	f456                	sd	s5,40(sp)
 23a:	f05a                	sd	s6,32(sp)
 23c:	ec5e                	sd	s7,24(sp)
 23e:	1080                	addi	s0,sp,96
 240:	8baa                	mv	s7,a0
 242:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 244:	892a                	mv	s2,a0
 246:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 248:	4aa9                	li	s5,10
 24a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 24c:	89a6                	mv	s3,s1
 24e:	2485                	addiw	s1,s1,1
 250:	0344d863          	bge	s1,s4,280 <gets+0x56>
    cc = read(0, &c, 1);
 254:	4605                	li	a2,1
 256:	faf40593          	addi	a1,s0,-81
 25a:	4501                	li	a0,0
 25c:	00000097          	auipc	ra,0x0
 260:	19c080e7          	jalr	412(ra) # 3f8 <read>
    if(cc < 1)
 264:	00a05e63          	blez	a0,280 <gets+0x56>
    buf[i++] = c;
 268:	faf44783          	lbu	a5,-81(s0)
 26c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 270:	01578763          	beq	a5,s5,27e <gets+0x54>
 274:	0905                	addi	s2,s2,1
 276:	fd679be3          	bne	a5,s6,24c <gets+0x22>
  for(i=0; i+1 < max; ){
 27a:	89a6                	mv	s3,s1
 27c:	a011                	j	280 <gets+0x56>
 27e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 280:	99de                	add	s3,s3,s7
 282:	00098023          	sb	zero,0(s3)
  return buf;
}
 286:	855e                	mv	a0,s7
 288:	60e6                	ld	ra,88(sp)
 28a:	6446                	ld	s0,80(sp)
 28c:	64a6                	ld	s1,72(sp)
 28e:	6906                	ld	s2,64(sp)
 290:	79e2                	ld	s3,56(sp)
 292:	7a42                	ld	s4,48(sp)
 294:	7aa2                	ld	s5,40(sp)
 296:	7b02                	ld	s6,32(sp)
 298:	6be2                	ld	s7,24(sp)
 29a:	6125                	addi	sp,sp,96
 29c:	8082                	ret

000000000000029e <stat>:

int
stat(const char *n, struct stat *st)
{
 29e:	1101                	addi	sp,sp,-32
 2a0:	ec06                	sd	ra,24(sp)
 2a2:	e822                	sd	s0,16(sp)
 2a4:	e426                	sd	s1,8(sp)
 2a6:	e04a                	sd	s2,0(sp)
 2a8:	1000                	addi	s0,sp,32
 2aa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ac:	4581                	li	a1,0
 2ae:	00000097          	auipc	ra,0x0
 2b2:	172080e7          	jalr	370(ra) # 420 <open>
  if(fd < 0)
 2b6:	02054563          	bltz	a0,2e0 <stat+0x42>
 2ba:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2bc:	85ca                	mv	a1,s2
 2be:	00000097          	auipc	ra,0x0
 2c2:	17a080e7          	jalr	378(ra) # 438 <fstat>
 2c6:	892a                	mv	s2,a0
  close(fd);
 2c8:	8526                	mv	a0,s1
 2ca:	00000097          	auipc	ra,0x0
 2ce:	13e080e7          	jalr	318(ra) # 408 <close>
  return r;
}
 2d2:	854a                	mv	a0,s2
 2d4:	60e2                	ld	ra,24(sp)
 2d6:	6442                	ld	s0,16(sp)
 2d8:	64a2                	ld	s1,8(sp)
 2da:	6902                	ld	s2,0(sp)
 2dc:	6105                	addi	sp,sp,32
 2de:	8082                	ret
    return -1;
 2e0:	597d                	li	s2,-1
 2e2:	bfc5                	j	2d2 <stat+0x34>

00000000000002e4 <atoi>:

int
atoi(const char *s)
{
 2e4:	1141                	addi	sp,sp,-16
 2e6:	e422                	sd	s0,8(sp)
 2e8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ea:	00054603          	lbu	a2,0(a0)
 2ee:	fd06079b          	addiw	a5,a2,-48
 2f2:	0ff7f793          	andi	a5,a5,255
 2f6:	4725                	li	a4,9
 2f8:	02f76963          	bltu	a4,a5,32a <atoi+0x46>
 2fc:	86aa                	mv	a3,a0
  n = 0;
 2fe:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 300:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 302:	0685                	addi	a3,a3,1
 304:	0025179b          	slliw	a5,a0,0x2
 308:	9fa9                	addw	a5,a5,a0
 30a:	0017979b          	slliw	a5,a5,0x1
 30e:	9fb1                	addw	a5,a5,a2
 310:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 314:	0006c603          	lbu	a2,0(a3)
 318:	fd06071b          	addiw	a4,a2,-48
 31c:	0ff77713          	andi	a4,a4,255
 320:	fee5f1e3          	bgeu	a1,a4,302 <atoi+0x1e>
  return n;
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret
  n = 0;
 32a:	4501                	li	a0,0
 32c:	bfe5                	j	324 <atoi+0x40>

000000000000032e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e422                	sd	s0,8(sp)
 332:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 334:	02b57463          	bgeu	a0,a1,35c <memmove+0x2e>
    while(n-- > 0)
 338:	00c05f63          	blez	a2,356 <memmove+0x28>
 33c:	1602                	slli	a2,a2,0x20
 33e:	9201                	srli	a2,a2,0x20
 340:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 344:	872a                	mv	a4,a0
      *dst++ = *src++;
 346:	0585                	addi	a1,a1,1
 348:	0705                	addi	a4,a4,1
 34a:	fff5c683          	lbu	a3,-1(a1)
 34e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 352:	fee79ae3          	bne	a5,a4,346 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret
    dst += n;
 35c:	00c50733          	add	a4,a0,a2
    src += n;
 360:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 362:	fec05ae3          	blez	a2,356 <memmove+0x28>
 366:	fff6079b          	addiw	a5,a2,-1
 36a:	1782                	slli	a5,a5,0x20
 36c:	9381                	srli	a5,a5,0x20
 36e:	fff7c793          	not	a5,a5
 372:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 374:	15fd                	addi	a1,a1,-1
 376:	177d                	addi	a4,a4,-1
 378:	0005c683          	lbu	a3,0(a1)
 37c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 380:	fee79ae3          	bne	a5,a4,374 <memmove+0x46>
 384:	bfc9                	j	356 <memmove+0x28>

0000000000000386 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e422                	sd	s0,8(sp)
 38a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 38c:	ca05                	beqz	a2,3bc <memcmp+0x36>
 38e:	fff6069b          	addiw	a3,a2,-1
 392:	1682                	slli	a3,a3,0x20
 394:	9281                	srli	a3,a3,0x20
 396:	0685                	addi	a3,a3,1
 398:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 39a:	00054783          	lbu	a5,0(a0)
 39e:	0005c703          	lbu	a4,0(a1)
 3a2:	00e79863          	bne	a5,a4,3b2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a6:	0505                	addi	a0,a0,1
    p2++;
 3a8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3aa:	fed518e3          	bne	a0,a3,39a <memcmp+0x14>
  }
  return 0;
 3ae:	4501                	li	a0,0
 3b0:	a019                	j	3b6 <memcmp+0x30>
      return *p1 - *p2;
 3b2:	40e7853b          	subw	a0,a5,a4
}
 3b6:	6422                	ld	s0,8(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret
  return 0;
 3bc:	4501                	li	a0,0
 3be:	bfe5                	j	3b6 <memcmp+0x30>

00000000000003c0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c8:	00000097          	auipc	ra,0x0
 3cc:	f66080e7          	jalr	-154(ra) # 32e <memmove>
}
 3d0:	60a2                	ld	ra,8(sp)
 3d2:	6402                	ld	s0,0(sp)
 3d4:	0141                	addi	sp,sp,16
 3d6:	8082                	ret

00000000000003d8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d8:	4885                	li	a7,1
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e0:	4889                	li	a7,2
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e8:	488d                	li	a7,3
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f0:	4891                	li	a7,4
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <read>:
.global read
read:
 li a7, SYS_read
 3f8:	4895                	li	a7,5
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <write>:
.global write
write:
 li a7, SYS_write
 400:	48c1                	li	a7,16
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <close>:
.global close
close:
 li a7, SYS_close
 408:	48d5                	li	a7,21
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <kill>:
.global kill
kill:
 li a7, SYS_kill
 410:	4899                	li	a7,6
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <exec>:
.global exec
exec:
 li a7, SYS_exec
 418:	489d                	li	a7,7
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <open>:
.global open
open:
 li a7, SYS_open
 420:	48bd                	li	a7,15
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 428:	48c5                	li	a7,17
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 430:	48c9                	li	a7,18
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 438:	48a1                	li	a7,8
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <link>:
.global link
link:
 li a7, SYS_link
 440:	48cd                	li	a7,19
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 448:	48d1                	li	a7,20
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 450:	48a5                	li	a7,9
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <dup>:
.global dup
dup:
 li a7, SYS_dup
 458:	48a9                	li	a7,10
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 460:	48ad                	li	a7,11
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 468:	48b1                	li	a7,12
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 470:	48b5                	li	a7,13
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 478:	48b9                	li	a7,14
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 480:	1101                	addi	sp,sp,-32
 482:	ec06                	sd	ra,24(sp)
 484:	e822                	sd	s0,16(sp)
 486:	1000                	addi	s0,sp,32
 488:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48c:	4605                	li	a2,1
 48e:	fef40593          	addi	a1,s0,-17
 492:	00000097          	auipc	ra,0x0
 496:	f6e080e7          	jalr	-146(ra) # 400 <write>
}
 49a:	60e2                	ld	ra,24(sp)
 49c:	6442                	ld	s0,16(sp)
 49e:	6105                	addi	sp,sp,32
 4a0:	8082                	ret

00000000000004a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a2:	7139                	addi	sp,sp,-64
 4a4:	fc06                	sd	ra,56(sp)
 4a6:	f822                	sd	s0,48(sp)
 4a8:	f426                	sd	s1,40(sp)
 4aa:	f04a                	sd	s2,32(sp)
 4ac:	ec4e                	sd	s3,24(sp)
 4ae:	0080                	addi	s0,sp,64
 4b0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b2:	c299                	beqz	a3,4b8 <printint+0x16>
 4b4:	0805c863          	bltz	a1,544 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4b8:	2581                	sext.w	a1,a1
  neg = 0;
 4ba:	4881                	li	a7,0
 4bc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4c0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c2:	2601                	sext.w	a2,a2
 4c4:	00000517          	auipc	a0,0x0
 4c8:	76450513          	addi	a0,a0,1892 # c28 <digits>
 4cc:	883a                	mv	a6,a4
 4ce:	2705                	addiw	a4,a4,1
 4d0:	02c5f7bb          	remuw	a5,a1,a2
 4d4:	1782                	slli	a5,a5,0x20
 4d6:	9381                	srli	a5,a5,0x20
 4d8:	97aa                	add	a5,a5,a0
 4da:	0007c783          	lbu	a5,0(a5)
 4de:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e2:	0005879b          	sext.w	a5,a1
 4e6:	02c5d5bb          	divuw	a1,a1,a2
 4ea:	0685                	addi	a3,a3,1
 4ec:	fec7f0e3          	bgeu	a5,a2,4cc <printint+0x2a>
  if(neg)
 4f0:	00088b63          	beqz	a7,506 <printint+0x64>
    buf[i++] = '-';
 4f4:	fd040793          	addi	a5,s0,-48
 4f8:	973e                	add	a4,a4,a5
 4fa:	02d00793          	li	a5,45
 4fe:	fef70823          	sb	a5,-16(a4)
 502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 506:	02e05863          	blez	a4,536 <printint+0x94>
 50a:	fc040793          	addi	a5,s0,-64
 50e:	00e78933          	add	s2,a5,a4
 512:	fff78993          	addi	s3,a5,-1
 516:	99ba                	add	s3,s3,a4
 518:	377d                	addiw	a4,a4,-1
 51a:	1702                	slli	a4,a4,0x20
 51c:	9301                	srli	a4,a4,0x20
 51e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 522:	fff94583          	lbu	a1,-1(s2)
 526:	8526                	mv	a0,s1
 528:	00000097          	auipc	ra,0x0
 52c:	f58080e7          	jalr	-168(ra) # 480 <putc>
  while(--i >= 0)
 530:	197d                	addi	s2,s2,-1
 532:	ff3918e3          	bne	s2,s3,522 <printint+0x80>
}
 536:	70e2                	ld	ra,56(sp)
 538:	7442                	ld	s0,48(sp)
 53a:	74a2                	ld	s1,40(sp)
 53c:	7902                	ld	s2,32(sp)
 53e:	69e2                	ld	s3,24(sp)
 540:	6121                	addi	sp,sp,64
 542:	8082                	ret
    x = -xx;
 544:	40b005bb          	negw	a1,a1
    neg = 1;
 548:	4885                	li	a7,1
    x = -xx;
 54a:	bf8d                	j	4bc <printint+0x1a>

000000000000054c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 54c:	7119                	addi	sp,sp,-128
 54e:	fc86                	sd	ra,120(sp)
 550:	f8a2                	sd	s0,112(sp)
 552:	f4a6                	sd	s1,104(sp)
 554:	f0ca                	sd	s2,96(sp)
 556:	ecce                	sd	s3,88(sp)
 558:	e8d2                	sd	s4,80(sp)
 55a:	e4d6                	sd	s5,72(sp)
 55c:	e0da                	sd	s6,64(sp)
 55e:	fc5e                	sd	s7,56(sp)
 560:	f862                	sd	s8,48(sp)
 562:	f466                	sd	s9,40(sp)
 564:	f06a                	sd	s10,32(sp)
 566:	ec6e                	sd	s11,24(sp)
 568:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 56a:	0005c903          	lbu	s2,0(a1)
 56e:	18090f63          	beqz	s2,70c <vprintf+0x1c0>
 572:	8aaa                	mv	s5,a0
 574:	8b32                	mv	s6,a2
 576:	00158493          	addi	s1,a1,1
  state = 0;
 57a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 57c:	02500a13          	li	s4,37
      if(c == 'd'){
 580:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 584:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 588:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 58c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 590:	00000b97          	auipc	s7,0x0
 594:	698b8b93          	addi	s7,s7,1688 # c28 <digits>
 598:	a839                	j	5b6 <vprintf+0x6a>
        putc(fd, c);
 59a:	85ca                	mv	a1,s2
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	ee2080e7          	jalr	-286(ra) # 480 <putc>
 5a6:	a019                	j	5ac <vprintf+0x60>
    } else if(state == '%'){
 5a8:	01498f63          	beq	s3,s4,5c6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5ac:	0485                	addi	s1,s1,1
 5ae:	fff4c903          	lbu	s2,-1(s1)
 5b2:	14090d63          	beqz	s2,70c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5b6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5ba:	fe0997e3          	bnez	s3,5a8 <vprintf+0x5c>
      if(c == '%'){
 5be:	fd479ee3          	bne	a5,s4,59a <vprintf+0x4e>
        state = '%';
 5c2:	89be                	mv	s3,a5
 5c4:	b7e5                	j	5ac <vprintf+0x60>
      if(c == 'd'){
 5c6:	05878063          	beq	a5,s8,606 <vprintf+0xba>
      } else if(c == 'l') {
 5ca:	05978c63          	beq	a5,s9,622 <vprintf+0xd6>
      } else if(c == 'x') {
 5ce:	07a78863          	beq	a5,s10,63e <vprintf+0xf2>
      } else if(c == 'p') {
 5d2:	09b78463          	beq	a5,s11,65a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5d6:	07300713          	li	a4,115
 5da:	0ce78663          	beq	a5,a4,6a6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5de:	06300713          	li	a4,99
 5e2:	0ee78e63          	beq	a5,a4,6de <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5e6:	11478863          	beq	a5,s4,6f6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ea:	85d2                	mv	a1,s4
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e92080e7          	jalr	-366(ra) # 480 <putc>
        putc(fd, c);
 5f6:	85ca                	mv	a1,s2
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e86080e7          	jalr	-378(ra) # 480 <putc>
      }
      state = 0;
 602:	4981                	li	s3,0
 604:	b765                	j	5ac <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 606:	008b0913          	addi	s2,s6,8
 60a:	4685                	li	a3,1
 60c:	4629                	li	a2,10
 60e:	000b2583          	lw	a1,0(s6)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	e8e080e7          	jalr	-370(ra) # 4a2 <printint>
 61c:	8b4a                	mv	s6,s2
      state = 0;
 61e:	4981                	li	s3,0
 620:	b771                	j	5ac <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 622:	008b0913          	addi	s2,s6,8
 626:	4681                	li	a3,0
 628:	4629                	li	a2,10
 62a:	000b2583          	lw	a1,0(s6)
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	e72080e7          	jalr	-398(ra) # 4a2 <printint>
 638:	8b4a                	mv	s6,s2
      state = 0;
 63a:	4981                	li	s3,0
 63c:	bf85                	j	5ac <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 63e:	008b0913          	addi	s2,s6,8
 642:	4681                	li	a3,0
 644:	4641                	li	a2,16
 646:	000b2583          	lw	a1,0(s6)
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	e56080e7          	jalr	-426(ra) # 4a2 <printint>
 654:	8b4a                	mv	s6,s2
      state = 0;
 656:	4981                	li	s3,0
 658:	bf91                	j	5ac <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 65a:	008b0793          	addi	a5,s6,8
 65e:	f8f43423          	sd	a5,-120(s0)
 662:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 666:	03000593          	li	a1,48
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	e14080e7          	jalr	-492(ra) # 480 <putc>
  putc(fd, 'x');
 674:	85ea                	mv	a1,s10
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	e08080e7          	jalr	-504(ra) # 480 <putc>
 680:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 682:	03c9d793          	srli	a5,s3,0x3c
 686:	97de                	add	a5,a5,s7
 688:	0007c583          	lbu	a1,0(a5)
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	df2080e7          	jalr	-526(ra) # 480 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 696:	0992                	slli	s3,s3,0x4
 698:	397d                	addiw	s2,s2,-1
 69a:	fe0914e3          	bnez	s2,682 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 69e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b721                	j	5ac <vprintf+0x60>
        s = va_arg(ap, char*);
 6a6:	008b0993          	addi	s3,s6,8
 6aa:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6ae:	02090163          	beqz	s2,6d0 <vprintf+0x184>
        while(*s != 0){
 6b2:	00094583          	lbu	a1,0(s2)
 6b6:	c9a1                	beqz	a1,706 <vprintf+0x1ba>
          putc(fd, *s);
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	dc6080e7          	jalr	-570(ra) # 480 <putc>
          s++;
 6c2:	0905                	addi	s2,s2,1
        while(*s != 0){
 6c4:	00094583          	lbu	a1,0(s2)
 6c8:	f9e5                	bnez	a1,6b8 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6ca:	8b4e                	mv	s6,s3
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	bdf9                	j	5ac <vprintf+0x60>
          s = "(null)";
 6d0:	00000917          	auipc	s2,0x0
 6d4:	55090913          	addi	s2,s2,1360 # c20 <uthread_yield+0x20c>
        while(*s != 0){
 6d8:	02800593          	li	a1,40
 6dc:	bff1                	j	6b8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6de:	008b0913          	addi	s2,s6,8
 6e2:	000b4583          	lbu	a1,0(s6)
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	d98080e7          	jalr	-616(ra) # 480 <putc>
 6f0:	8b4a                	mv	s6,s2
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	bd65                	j	5ac <vprintf+0x60>
        putc(fd, c);
 6f6:	85d2                	mv	a1,s4
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	d86080e7          	jalr	-634(ra) # 480 <putc>
      state = 0;
 702:	4981                	li	s3,0
 704:	b565                	j	5ac <vprintf+0x60>
        s = va_arg(ap, char*);
 706:	8b4e                	mv	s6,s3
      state = 0;
 708:	4981                	li	s3,0
 70a:	b54d                	j	5ac <vprintf+0x60>
    }
  }
}
 70c:	70e6                	ld	ra,120(sp)
 70e:	7446                	ld	s0,112(sp)
 710:	74a6                	ld	s1,104(sp)
 712:	7906                	ld	s2,96(sp)
 714:	69e6                	ld	s3,88(sp)
 716:	6a46                	ld	s4,80(sp)
 718:	6aa6                	ld	s5,72(sp)
 71a:	6b06                	ld	s6,64(sp)
 71c:	7be2                	ld	s7,56(sp)
 71e:	7c42                	ld	s8,48(sp)
 720:	7ca2                	ld	s9,40(sp)
 722:	7d02                	ld	s10,32(sp)
 724:	6de2                	ld	s11,24(sp)
 726:	6109                	addi	sp,sp,128
 728:	8082                	ret

000000000000072a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 72a:	715d                	addi	sp,sp,-80
 72c:	ec06                	sd	ra,24(sp)
 72e:	e822                	sd	s0,16(sp)
 730:	1000                	addi	s0,sp,32
 732:	e010                	sd	a2,0(s0)
 734:	e414                	sd	a3,8(s0)
 736:	e818                	sd	a4,16(s0)
 738:	ec1c                	sd	a5,24(s0)
 73a:	03043023          	sd	a6,32(s0)
 73e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 742:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 746:	8622                	mv	a2,s0
 748:	00000097          	auipc	ra,0x0
 74c:	e04080e7          	jalr	-508(ra) # 54c <vprintf>
}
 750:	60e2                	ld	ra,24(sp)
 752:	6442                	ld	s0,16(sp)
 754:	6161                	addi	sp,sp,80
 756:	8082                	ret

0000000000000758 <printf>:

void
printf(const char *fmt, ...)
{
 758:	711d                	addi	sp,sp,-96
 75a:	ec06                	sd	ra,24(sp)
 75c:	e822                	sd	s0,16(sp)
 75e:	1000                	addi	s0,sp,32
 760:	e40c                	sd	a1,8(s0)
 762:	e810                	sd	a2,16(s0)
 764:	ec14                	sd	a3,24(s0)
 766:	f018                	sd	a4,32(s0)
 768:	f41c                	sd	a5,40(s0)
 76a:	03043823          	sd	a6,48(s0)
 76e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 772:	00840613          	addi	a2,s0,8
 776:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 77a:	85aa                	mv	a1,a0
 77c:	4505                	li	a0,1
 77e:	00000097          	auipc	ra,0x0
 782:	dce080e7          	jalr	-562(ra) # 54c <vprintf>
}
 786:	60e2                	ld	ra,24(sp)
 788:	6442                	ld	s0,16(sp)
 78a:	6125                	addi	sp,sp,96
 78c:	8082                	ret

000000000000078e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78e:	1141                	addi	sp,sp,-16
 790:	e422                	sd	s0,8(sp)
 792:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 794:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 798:	00001797          	auipc	a5,0x1
 79c:	8687b783          	ld	a5,-1944(a5) # 1000 <freep>
 7a0:	a805                	j	7d0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a2:	4618                	lw	a4,8(a2)
 7a4:	9db9                	addw	a1,a1,a4
 7a6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7aa:	6398                	ld	a4,0(a5)
 7ac:	6318                	ld	a4,0(a4)
 7ae:	fee53823          	sd	a4,-16(a0)
 7b2:	a091                	j	7f6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7b4:	ff852703          	lw	a4,-8(a0)
 7b8:	9e39                	addw	a2,a2,a4
 7ba:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7bc:	ff053703          	ld	a4,-16(a0)
 7c0:	e398                	sd	a4,0(a5)
 7c2:	a099                	j	808 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c4:	6398                	ld	a4,0(a5)
 7c6:	00e7e463          	bltu	a5,a4,7ce <free+0x40>
 7ca:	00e6ea63          	bltu	a3,a4,7de <free+0x50>
{
 7ce:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d0:	fed7fae3          	bgeu	a5,a3,7c4 <free+0x36>
 7d4:	6398                	ld	a4,0(a5)
 7d6:	00e6e463          	bltu	a3,a4,7de <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7da:	fee7eae3          	bltu	a5,a4,7ce <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7de:	ff852583          	lw	a1,-8(a0)
 7e2:	6390                	ld	a2,0(a5)
 7e4:	02059713          	slli	a4,a1,0x20
 7e8:	9301                	srli	a4,a4,0x20
 7ea:	0712                	slli	a4,a4,0x4
 7ec:	9736                	add	a4,a4,a3
 7ee:	fae60ae3          	beq	a2,a4,7a2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7f2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7f6:	4790                	lw	a2,8(a5)
 7f8:	02061713          	slli	a4,a2,0x20
 7fc:	9301                	srli	a4,a4,0x20
 7fe:	0712                	slli	a4,a4,0x4
 800:	973e                	add	a4,a4,a5
 802:	fae689e3          	beq	a3,a4,7b4 <free+0x26>
  } else
    p->s.ptr = bp;
 806:	e394                	sd	a3,0(a5)
  freep = p;
 808:	00000717          	auipc	a4,0x0
 80c:	7ef73c23          	sd	a5,2040(a4) # 1000 <freep>
}
 810:	6422                	ld	s0,8(sp)
 812:	0141                	addi	sp,sp,16
 814:	8082                	ret

0000000000000816 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 816:	7139                	addi	sp,sp,-64
 818:	fc06                	sd	ra,56(sp)
 81a:	f822                	sd	s0,48(sp)
 81c:	f426                	sd	s1,40(sp)
 81e:	f04a                	sd	s2,32(sp)
 820:	ec4e                	sd	s3,24(sp)
 822:	e852                	sd	s4,16(sp)
 824:	e456                	sd	s5,8(sp)
 826:	e05a                	sd	s6,0(sp)
 828:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 82a:	02051493          	slli	s1,a0,0x20
 82e:	9081                	srli	s1,s1,0x20
 830:	04bd                	addi	s1,s1,15
 832:	8091                	srli	s1,s1,0x4
 834:	0014899b          	addiw	s3,s1,1
 838:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 83a:	00000517          	auipc	a0,0x0
 83e:	7c653503          	ld	a0,1990(a0) # 1000 <freep>
 842:	c515                	beqz	a0,86e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 844:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 846:	4798                	lw	a4,8(a5)
 848:	02977f63          	bgeu	a4,s1,886 <malloc+0x70>
 84c:	8a4e                	mv	s4,s3
 84e:	0009871b          	sext.w	a4,s3
 852:	6685                	lui	a3,0x1
 854:	00d77363          	bgeu	a4,a3,85a <malloc+0x44>
 858:	6a05                	lui	s4,0x1
 85a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 85e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 862:	00000917          	auipc	s2,0x0
 866:	79e90913          	addi	s2,s2,1950 # 1000 <freep>
  if(p == (char*)-1)
 86a:	5afd                	li	s5,-1
 86c:	a88d                	j	8de <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 86e:	00000797          	auipc	a5,0x0
 872:	7b278793          	addi	a5,a5,1970 # 1020 <base>
 876:	00000717          	auipc	a4,0x0
 87a:	78f73523          	sd	a5,1930(a4) # 1000 <freep>
 87e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 880:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 884:	b7e1                	j	84c <malloc+0x36>
      if(p->s.size == nunits)
 886:	02e48b63          	beq	s1,a4,8bc <malloc+0xa6>
        p->s.size -= nunits;
 88a:	4137073b          	subw	a4,a4,s3
 88e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 890:	1702                	slli	a4,a4,0x20
 892:	9301                	srli	a4,a4,0x20
 894:	0712                	slli	a4,a4,0x4
 896:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 898:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 89c:	00000717          	auipc	a4,0x0
 8a0:	76a73223          	sd	a0,1892(a4) # 1000 <freep>
      return (void*)(p + 1);
 8a4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a8:	70e2                	ld	ra,56(sp)
 8aa:	7442                	ld	s0,48(sp)
 8ac:	74a2                	ld	s1,40(sp)
 8ae:	7902                	ld	s2,32(sp)
 8b0:	69e2                	ld	s3,24(sp)
 8b2:	6a42                	ld	s4,16(sp)
 8b4:	6aa2                	ld	s5,8(sp)
 8b6:	6b02                	ld	s6,0(sp)
 8b8:	6121                	addi	sp,sp,64
 8ba:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8bc:	6398                	ld	a4,0(a5)
 8be:	e118                	sd	a4,0(a0)
 8c0:	bff1                	j	89c <malloc+0x86>
  hp->s.size = nu;
 8c2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c6:	0541                	addi	a0,a0,16
 8c8:	00000097          	auipc	ra,0x0
 8cc:	ec6080e7          	jalr	-314(ra) # 78e <free>
  return freep;
 8d0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d4:	d971                	beqz	a0,8a8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d8:	4798                	lw	a4,8(a5)
 8da:	fa9776e3          	bgeu	a4,s1,886 <malloc+0x70>
    if(p == freep)
 8de:	00093703          	ld	a4,0(s2)
 8e2:	853e                	mv	a0,a5
 8e4:	fef719e3          	bne	a4,a5,8d6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8e8:	8552                	mv	a0,s4
 8ea:	00000097          	auipc	ra,0x0
 8ee:	b7e080e7          	jalr	-1154(ra) # 468 <sbrk>
  if(p == (char*)-1)
 8f2:	fd5518e3          	bne	a0,s5,8c2 <malloc+0xac>
        return 0;
 8f6:	4501                	li	a0,0
 8f8:	bf45                	j	8a8 <malloc+0x92>

00000000000008fa <uswtch>:
 8fa:	00153023          	sd	ra,0(a0)
 8fe:	00253423          	sd	sp,8(a0)
 902:	e900                	sd	s0,16(a0)
 904:	ed04                	sd	s1,24(a0)
 906:	03253023          	sd	s2,32(a0)
 90a:	03353423          	sd	s3,40(a0)
 90e:	03453823          	sd	s4,48(a0)
 912:	03553c23          	sd	s5,56(a0)
 916:	05653023          	sd	s6,64(a0)
 91a:	05753423          	sd	s7,72(a0)
 91e:	05853823          	sd	s8,80(a0)
 922:	05953c23          	sd	s9,88(a0)
 926:	07a53023          	sd	s10,96(a0)
 92a:	07b53423          	sd	s11,104(a0)
 92e:	0005b083          	ld	ra,0(a1)
 932:	0085b103          	ld	sp,8(a1)
 936:	6980                	ld	s0,16(a1)
 938:	6d84                	ld	s1,24(a1)
 93a:	0205b903          	ld	s2,32(a1)
 93e:	0285b983          	ld	s3,40(a1)
 942:	0305ba03          	ld	s4,48(a1)
 946:	0385ba83          	ld	s5,56(a1)
 94a:	0405bb03          	ld	s6,64(a1)
 94e:	0485bb83          	ld	s7,72(a1)
 952:	0505bc03          	ld	s8,80(a1)
 956:	0585bc83          	ld	s9,88(a1)
 95a:	0605bd03          	ld	s10,96(a1)
 95e:	0685bd83          	ld	s11,104(a1)
 962:	8082                	ret

0000000000000964 <uthread_exit>:
    uswtch(curr_context, next_context);
         printf("after switch thread with ID: %d and prior:%d\n", curr_thread->id,curr_thread->priority);

}

void uthread_exit(){
 964:	1141                	addi	sp,sp,-16
 966:	e422                	sd	s0,8(sp)
 968:	0800                	addi	s0,sp,16

 96a:	6422                	ld	s0,8(sp)
 96c:	0141                	addi	sp,sp,16
 96e:	8082                	ret

0000000000000970 <uthread_create>:
int uthread_create(void (*start_func)(), enum sched_priority priority) {
 970:	862e                	mv	a2,a1
    for (i = 0; i < MAX_UTHREADS; i++) {
 972:	00001717          	auipc	a4,0x1
 976:	66270713          	addi	a4,a4,1634 # 1fd4 <uthreads_arr+0xfa4>
 97a:	4781                	li	a5,0
 97c:	6805                	lui	a6,0x1
 97e:	02080813          	addi	a6,a6,32 # 1020 <base>
 982:	4591                	li	a1,4
        if (uthreads_arr[i].state == FREE) {
 984:	4314                	lw	a3,0(a4)
 986:	c699                	beqz	a3,994 <uthread_create+0x24>
    for (i = 0; i < MAX_UTHREADS; i++) {
 988:	2785                	addiw	a5,a5,1
 98a:	9742                	add	a4,a4,a6
 98c:	feb79ce3          	bne	a5,a1,984 <uthread_create+0x14>
        return -1;
 990:	557d                	li	a0,-1
 992:	8082                	ret
            curr_thread = &uthreads_arr[i];
 994:	00779713          	slli	a4,a5,0x7
 998:	973e                	add	a4,a4,a5
 99a:	0716                	slli	a4,a4,0x5
 99c:	00000697          	auipc	a3,0x0
 9a0:	69468693          	addi	a3,a3,1684 # 1030 <uthreads_arr>
 9a4:	9736                	add	a4,a4,a3
 9a6:	00000697          	auipc	a3,0x0
 9aa:	66e6b123          	sd	a4,1634(a3) # 1008 <curr_thread>
    if (i >= MAX_UTHREADS) {
 9ae:	468d                	li	a3,3
 9b0:	06f6c063          	blt	a3,a5,a10 <uthread_create+0xa0>
int uthread_create(void (*start_func)(), enum sched_priority priority) {
 9b4:	1141                	addi	sp,sp,-16
 9b6:	e406                	sd	ra,8(sp)
 9b8:	e022                	sd	s0,0(sp)
 9ba:	0800                	addi	s0,sp,16
    curr_thread->id = next_tid++; 
 9bc:	00000797          	auipc	a5,0x0
 9c0:	65478793          	addi	a5,a5,1620 # 1010 <next_tid>
 9c4:	438c                	lw	a1,0(a5)
 9c6:	0015869b          	addiw	a3,a1,1
 9ca:	c394                	sw	a3,0(a5)
 9cc:	c30c                	sw	a1,0(a4)
    curr_thread->priority = priority;
 9ce:	6685                	lui	a3,0x1
 9d0:	00d707b3          	add	a5,a4,a3
 9d4:	cf90                	sw	a2,24(a5)
    curr_thread->context.ra = (uint64) start_func;
 9d6:	faa7b423          	sd	a0,-88(a5)
    curr_thread->context.sp = (uint64) &curr_thread->ustack[STACK_SIZE];
 9da:	fa468693          	addi	a3,a3,-92 # fa4 <digits+0x37c>
 9de:	9736                	add	a4,a4,a3
 9e0:	fae7b823          	sd	a4,-80(a5)
    curr_thread->ustack[STACK_SIZE - 1] = (uint64) uthread_exit; // Return address to uthread_exit
 9e4:	00000717          	auipc	a4,0x0
 9e8:	f8070713          	addi	a4,a4,-128 # 964 <uthread_exit>
 9ec:	fae781a3          	sb	a4,-93(a5)
    curr_thread->state = RUNNABLE;
 9f0:	4709                	li	a4,2
 9f2:	fae7a223          	sw	a4,-92(a5)
 printf("Created thread with ID: %d and prior:%d\n", curr_thread->id,curr_thread->priority);
 9f6:	00000517          	auipc	a0,0x0
 9fa:	24a50513          	addi	a0,a0,586 # c40 <digits+0x18>
 9fe:	00000097          	auipc	ra,0x0
 a02:	d5a080e7          	jalr	-678(ra) # 758 <printf>
     return 0;
 a06:	4501                	li	a0,0
}
 a08:	60a2                	ld	ra,8(sp)
 a0a:	6402                	ld	s0,0(sp)
 a0c:	0141                	addi	sp,sp,16
 a0e:	8082                	ret
        return -1;
 a10:	557d                	li	a0,-1
}
 a12:	8082                	ret

0000000000000a14 <uthread_yield>:
void uthread_yield() {
 a14:	7179                	addi	sp,sp,-48
 a16:	f406                	sd	ra,40(sp)
 a18:	f022                	sd	s0,32(sp)
 a1a:	ec26                	sd	s1,24(sp)
 a1c:	e84a                	sd	s2,16(sp)
 a1e:	e44e                	sd	s3,8(sp)
 a20:	1800                	addi	s0,sp,48
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 a22:	00000817          	auipc	a6,0x0
 a26:	5e683803          	ld	a6,1510(a6) # 1008 <curr_thread>
 a2a:	00082583          	lw	a1,0(a6)
 a2e:	0015879b          	addiw	a5,a1,1
 a32:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 a34:	4301                	li	t1,0
    struct uthread *next_thread = NULL;
 a36:	4481                	li	s1,0
        if (uthreads_arr[i].state == RUNNABLE &&
 a38:	00000617          	auipc	a2,0x0
 a3c:	5f860613          	addi	a2,a2,1528 # 1030 <uthreads_arr>
 a40:	6505                	lui	a0,0x1
 a42:	4889                	li	a7,2
 a44:	a819                	j	a5a <uthread_yield+0x46>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 a46:	2785                	addiw	a5,a5,1
 a48:	41f7d71b          	sraiw	a4,a5,0x1f
 a4c:	01e7571b          	srliw	a4,a4,0x1e
 a50:	9fb9                	addw	a5,a5,a4
 a52:	8b8d                	andi	a5,a5,3
 a54:	9f99                	subw	a5,a5,a4
 a56:	36fd                	addiw	a3,a3,-1
 a58:	ca9d                	beqz	a3,a8e <uthread_yield+0x7a>
        if (uthreads_arr[i].state == RUNNABLE &&
 a5a:	00779713          	slli	a4,a5,0x7
 a5e:	973e                	add	a4,a4,a5
 a60:	0716                	slli	a4,a4,0x5
 a62:	9732                	add	a4,a4,a2
 a64:	972a                	add	a4,a4,a0
 a66:	fa472703          	lw	a4,-92(a4)
 a6a:	fd171ee3          	bne	a4,a7,a46 <uthread_yield+0x32>
            uthreads_arr[i].priority > max_priority) {
 a6e:	00779713          	slli	a4,a5,0x7
 a72:	973e                	add	a4,a4,a5
 a74:	0716                	slli	a4,a4,0x5
 a76:	9732                	add	a4,a4,a2
 a78:	972a                	add	a4,a4,a0
 a7a:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 a7c:	fce375e3          	bgeu	t1,a4,a46 <uthread_yield+0x32>
            next_thread = &uthreads_arr[i];
 a80:	00779493          	slli	s1,a5,0x7
 a84:	94be                	add	s1,s1,a5
 a86:	0496                	slli	s1,s1,0x5
 a88:	94b2                	add	s1,s1,a2
            max_priority = uthreads_arr[i].priority;
 a8a:	833a                	mv	t1,a4
 a8c:	bf6d                	j	a46 <uthread_yield+0x32>
     printf("before switch thread with ID: %d and prior:%d\n", curr_thread->id,curr_thread->priority);
 a8e:	6785                	lui	a5,0x1
 a90:	983e                	add	a6,a6,a5
 a92:	01882603          	lw	a2,24(a6)
 a96:	00000517          	auipc	a0,0x0
 a9a:	1da50513          	addi	a0,a0,474 # c70 <digits+0x48>
 a9e:	00000097          	auipc	ra,0x0
 aa2:	cba080e7          	jalr	-838(ra) # 758 <printf>
    if (next_thread == NULL) {
 aa6:	c8b9                	beqz	s1,afc <uthread_yield+0xe8>
    struct context *curr_context = &curr_thread->context;
 aa8:	00000997          	auipc	s3,0x0
 aac:	56098993          	addi	s3,s3,1376 # 1008 <curr_thread>
 ab0:	0009b503          	ld	a0,0(s3)
    curr_thread->state = RUNNABLE;
 ab4:	6905                	lui	s2,0x1
 ab6:	012507b3          	add	a5,a0,s2
 aba:	4709                	li	a4,2
 abc:	fae7a223          	sw	a4,-92(a5) # fa4 <digits+0x37c>
    next_thread->state = RUNNING;
 ac0:	012487b3          	add	a5,s1,s2
 ac4:	4705                	li	a4,1
 ac6:	fae7a223          	sw	a4,-92(a5)
    curr_thread = next_thread;
 aca:	0099b023          	sd	s1,0(s3)
    struct context *next_context = &next_thread->context;
 ace:	fa890793          	addi	a5,s2,-88 # fa8 <digits+0x380>
    uswtch(curr_context, next_context);
 ad2:	00f485b3          	add	a1,s1,a5
 ad6:	953e                	add	a0,a0,a5
 ad8:	00000097          	auipc	ra,0x0
 adc:	e22080e7          	jalr	-478(ra) # 8fa <uswtch>
         printf("after switch thread with ID: %d and prior:%d\n", curr_thread->id,curr_thread->priority);
 ae0:	0009b783          	ld	a5,0(s3)
 ae4:	993e                	add	s2,s2,a5
 ae6:	01892603          	lw	a2,24(s2)
 aea:	438c                	lw	a1,0(a5)
 aec:	00000517          	auipc	a0,0x0
 af0:	1b450513          	addi	a0,a0,436 # ca0 <digits+0x78>
 af4:	00000097          	auipc	ra,0x0
 af8:	c64080e7          	jalr	-924(ra) # 758 <printf>
}
 afc:	70a2                	ld	ra,40(sp)
 afe:	7402                	ld	s0,32(sp)
 b00:	64e2                	ld	s1,24(sp)
 b02:	6942                	ld	s2,16(sp)
 b04:	69a2                	ld	s3,8(sp)
 b06:	6145                	addi	sp,sp,48
 b08:	8082                	ret
