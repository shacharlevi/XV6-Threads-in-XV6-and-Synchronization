
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7dd63          	bge	a5,a0,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	1902                	slli	s2,s2,0x20
  1c:	02095913          	srli	s2,s2,0x20
  20:	090e                	slli	s2,s2,0x3
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1c8080e7          	jalr	456(ra) # 1f0 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2ec080e7          	jalr	748(ra) # 31c <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2ac080e7          	jalr	684(ra) # 2ec <exit>
    fprintf(2, "usage: kill pid...\n");
  48:	00001597          	auipc	a1,0x1
  4c:	b1858593          	addi	a1,a1,-1256 # b60 <uthread_self+0x1c>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	5e4080e7          	jalr	1508(ra) # 636 <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	290080e7          	jalr	656(ra) # 2ec <exit>

0000000000000064 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  64:	1141                	addi	sp,sp,-16
  66:	e406                	sd	ra,8(sp)
  68:	e022                	sd	s0,0(sp)
  6a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <main>
  exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	276080e7          	jalr	630(ra) # 2ec <exit>

000000000000007e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7e:	1141                	addi	sp,sp,-16
  80:	e422                	sd	s0,8(sp)
  82:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  84:	87aa                	mv	a5,a0
  86:	0585                	addi	a1,a1,1
  88:	0785                	addi	a5,a5,1
  8a:	fff5c703          	lbu	a4,-1(a1)
  8e:	fee78fa3          	sb	a4,-1(a5)
  92:	fb75                	bnez	a4,86 <strcpy+0x8>
    ;
  return os;
}
  94:	6422                	ld	s0,8(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret

000000000000009a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a0:	00054783          	lbu	a5,0(a0)
  a4:	cb91                	beqz	a5,b8 <strcmp+0x1e>
  a6:	0005c703          	lbu	a4,0(a1)
  aa:	00f71763          	bne	a4,a5,b8 <strcmp+0x1e>
    p++, q++;
  ae:	0505                	addi	a0,a0,1
  b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	fbe5                	bnez	a5,a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b8:	0005c503          	lbu	a0,0(a1)
}
  bc:	40a7853b          	subw	a0,a5,a0
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <strlen>:

uint
strlen(const char *s)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e422                	sd	s0,8(sp)
  ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	cf91                	beqz	a5,ec <strlen+0x26>
  d2:	0505                	addi	a0,a0,1
  d4:	87aa                	mv	a5,a0
  d6:	4685                	li	a3,1
  d8:	9e89                	subw	a3,a3,a0
  da:	00f6853b          	addw	a0,a3,a5
  de:	0785                	addi	a5,a5,1
  e0:	fff7c703          	lbu	a4,-1(a5)
  e4:	fb7d                	bnez	a4,da <strlen+0x14>
    ;
  return n;
}
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret
  for(n = 0; s[n]; n++)
  ec:	4501                	li	a0,0
  ee:	bfe5                	j	e6 <strlen+0x20>

00000000000000f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f6:	ca19                	beqz	a2,10c <memset+0x1c>
  f8:	87aa                	mv	a5,a0
  fa:	1602                	slli	a2,a2,0x20
  fc:	9201                	srli	a2,a2,0x20
  fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 102:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 106:	0785                	addi	a5,a5,1
 108:	fee79de3          	bne	a5,a4,102 <memset+0x12>
  }
  return dst;
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strchr>:

char*
strchr(const char *s, char c)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  for(; *s; s++)
 118:	00054783          	lbu	a5,0(a0)
 11c:	cb99                	beqz	a5,132 <strchr+0x20>
    if(*s == c)
 11e:	00f58763          	beq	a1,a5,12c <strchr+0x1a>
  for(; *s; s++)
 122:	0505                	addi	a0,a0,1
 124:	00054783          	lbu	a5,0(a0)
 128:	fbfd                	bnez	a5,11e <strchr+0xc>
      return (char*)s;
  return 0;
 12a:	4501                	li	a0,0
}
 12c:	6422                	ld	s0,8(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret
  return 0;
 132:	4501                	li	a0,0
 134:	bfe5                	j	12c <strchr+0x1a>

0000000000000136 <gets>:

char*
gets(char *buf, int max)
{
 136:	711d                	addi	sp,sp,-96
 138:	ec86                	sd	ra,88(sp)
 13a:	e8a2                	sd	s0,80(sp)
 13c:	e4a6                	sd	s1,72(sp)
 13e:	e0ca                	sd	s2,64(sp)
 140:	fc4e                	sd	s3,56(sp)
 142:	f852                	sd	s4,48(sp)
 144:	f456                	sd	s5,40(sp)
 146:	f05a                	sd	s6,32(sp)
 148:	ec5e                	sd	s7,24(sp)
 14a:	1080                	addi	s0,sp,96
 14c:	8baa                	mv	s7,a0
 14e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 150:	892a                	mv	s2,a0
 152:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 154:	4aa9                	li	s5,10
 156:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 158:	89a6                	mv	s3,s1
 15a:	2485                	addiw	s1,s1,1
 15c:	0344d863          	bge	s1,s4,18c <gets+0x56>
    cc = read(0, &c, 1);
 160:	4605                	li	a2,1
 162:	faf40593          	addi	a1,s0,-81
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	19c080e7          	jalr	412(ra) # 304 <read>
    if(cc < 1)
 170:	00a05e63          	blez	a0,18c <gets+0x56>
    buf[i++] = c;
 174:	faf44783          	lbu	a5,-81(s0)
 178:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17c:	01578763          	beq	a5,s5,18a <gets+0x54>
 180:	0905                	addi	s2,s2,1
 182:	fd679be3          	bne	a5,s6,158 <gets+0x22>
  for(i=0; i+1 < max; ){
 186:	89a6                	mv	s3,s1
 188:	a011                	j	18c <gets+0x56>
 18a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18c:	99de                	add	s3,s3,s7
 18e:	00098023          	sb	zero,0(s3)
  return buf;
}
 192:	855e                	mv	a0,s7
 194:	60e6                	ld	ra,88(sp)
 196:	6446                	ld	s0,80(sp)
 198:	64a6                	ld	s1,72(sp)
 19a:	6906                	ld	s2,64(sp)
 19c:	79e2                	ld	s3,56(sp)
 19e:	7a42                	ld	s4,48(sp)
 1a0:	7aa2                	ld	s5,40(sp)
 1a2:	7b02                	ld	s6,32(sp)
 1a4:	6be2                	ld	s7,24(sp)
 1a6:	6125                	addi	sp,sp,96
 1a8:	8082                	ret

00000000000001aa <stat>:

int
stat(const char *n, struct stat *st)
{
 1aa:	1101                	addi	sp,sp,-32
 1ac:	ec06                	sd	ra,24(sp)
 1ae:	e822                	sd	s0,16(sp)
 1b0:	e426                	sd	s1,8(sp)
 1b2:	e04a                	sd	s2,0(sp)
 1b4:	1000                	addi	s0,sp,32
 1b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b8:	4581                	li	a1,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	172080e7          	jalr	370(ra) # 32c <open>
  if(fd < 0)
 1c2:	02054563          	bltz	a0,1ec <stat+0x42>
 1c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	17a080e7          	jalr	378(ra) # 344 <fstat>
 1d2:	892a                	mv	s2,a0
  close(fd);
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	13e080e7          	jalr	318(ra) # 314 <close>
  return r;
}
 1de:	854a                	mv	a0,s2
 1e0:	60e2                	ld	ra,24(sp)
 1e2:	6442                	ld	s0,16(sp)
 1e4:	64a2                	ld	s1,8(sp)
 1e6:	6902                	ld	s2,0(sp)
 1e8:	6105                	addi	sp,sp,32
 1ea:	8082                	ret
    return -1;
 1ec:	597d                	li	s2,-1
 1ee:	bfc5                	j	1de <stat+0x34>

00000000000001f0 <atoi>:

int
atoi(const char *s)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f6:	00054603          	lbu	a2,0(a0)
 1fa:	fd06079b          	addiw	a5,a2,-48
 1fe:	0ff7f793          	andi	a5,a5,255
 202:	4725                	li	a4,9
 204:	02f76963          	bltu	a4,a5,236 <atoi+0x46>
 208:	86aa                	mv	a3,a0
  n = 0;
 20a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 20c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 20e:	0685                	addi	a3,a3,1
 210:	0025179b          	slliw	a5,a0,0x2
 214:	9fa9                	addw	a5,a5,a0
 216:	0017979b          	slliw	a5,a5,0x1
 21a:	9fb1                	addw	a5,a5,a2
 21c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 220:	0006c603          	lbu	a2,0(a3)
 224:	fd06071b          	addiw	a4,a2,-48
 228:	0ff77713          	andi	a4,a4,255
 22c:	fee5f1e3          	bgeu	a1,a4,20e <atoi+0x1e>
  return n;
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
  n = 0;
 236:	4501                	li	a0,0
 238:	bfe5                	j	230 <atoi+0x40>

000000000000023a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 240:	02b57463          	bgeu	a0,a1,268 <memmove+0x2e>
    while(n-- > 0)
 244:	00c05f63          	blez	a2,262 <memmove+0x28>
 248:	1602                	slli	a2,a2,0x20
 24a:	9201                	srli	a2,a2,0x20
 24c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 250:	872a                	mv	a4,a0
      *dst++ = *src++;
 252:	0585                	addi	a1,a1,1
 254:	0705                	addi	a4,a4,1
 256:	fff5c683          	lbu	a3,-1(a1)
 25a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 25e:	fee79ae3          	bne	a5,a4,252 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
    dst += n;
 268:	00c50733          	add	a4,a0,a2
    src += n;
 26c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 26e:	fec05ae3          	blez	a2,262 <memmove+0x28>
 272:	fff6079b          	addiw	a5,a2,-1
 276:	1782                	slli	a5,a5,0x20
 278:	9381                	srli	a5,a5,0x20
 27a:	fff7c793          	not	a5,a5
 27e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 280:	15fd                	addi	a1,a1,-1
 282:	177d                	addi	a4,a4,-1
 284:	0005c683          	lbu	a3,0(a1)
 288:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 28c:	fee79ae3          	bne	a5,a4,280 <memmove+0x46>
 290:	bfc9                	j	262 <memmove+0x28>

0000000000000292 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 292:	1141                	addi	sp,sp,-16
 294:	e422                	sd	s0,8(sp)
 296:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 298:	ca05                	beqz	a2,2c8 <memcmp+0x36>
 29a:	fff6069b          	addiw	a3,a2,-1
 29e:	1682                	slli	a3,a3,0x20
 2a0:	9281                	srli	a3,a3,0x20
 2a2:	0685                	addi	a3,a3,1
 2a4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	0005c703          	lbu	a4,0(a1)
 2ae:	00e79863          	bne	a5,a4,2be <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b2:	0505                	addi	a0,a0,1
    p2++;
 2b4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b6:	fed518e3          	bne	a0,a3,2a6 <memcmp+0x14>
  }
  return 0;
 2ba:	4501                	li	a0,0
 2bc:	a019                	j	2c2 <memcmp+0x30>
      return *p1 - *p2;
 2be:	40e7853b          	subw	a0,a5,a4
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
  return 0;
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <memcmp+0x30>

00000000000002cc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e406                	sd	ra,8(sp)
 2d0:	e022                	sd	s0,0(sp)
 2d2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d4:	00000097          	auipc	ra,0x0
 2d8:	f66080e7          	jalr	-154(ra) # 23a <memmove>
}
 2dc:	60a2                	ld	ra,8(sp)
 2de:	6402                	ld	s0,0(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret

00000000000002e4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e4:	4885                	li	a7,1
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ec:	4889                	li	a7,2
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f4:	488d                	li	a7,3
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fc:	4891                	li	a7,4
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <read>:
.global read
read:
 li a7, SYS_read
 304:	4895                	li	a7,5
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <write>:
.global write
write:
 li a7, SYS_write
 30c:	48c1                	li	a7,16
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <close>:
.global close
close:
 li a7, SYS_close
 314:	48d5                	li	a7,21
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <kill>:
.global kill
kill:
 li a7, SYS_kill
 31c:	4899                	li	a7,6
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <exec>:
.global exec
exec:
 li a7, SYS_exec
 324:	489d                	li	a7,7
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <open>:
.global open
open:
 li a7, SYS_open
 32c:	48bd                	li	a7,15
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 334:	48c5                	li	a7,17
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33c:	48c9                	li	a7,18
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 344:	48a1                	li	a7,8
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <link>:
.global link
link:
 li a7, SYS_link
 34c:	48cd                	li	a7,19
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 354:	48d1                	li	a7,20
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35c:	48a5                	li	a7,9
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <dup>:
.global dup
dup:
 li a7, SYS_dup
 364:	48a9                	li	a7,10
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36c:	48ad                	li	a7,11
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 374:	48b1                	li	a7,12
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 37c:	48b5                	li	a7,13
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 384:	48b9                	li	a7,14
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 38c:	1101                	addi	sp,sp,-32
 38e:	ec06                	sd	ra,24(sp)
 390:	e822                	sd	s0,16(sp)
 392:	1000                	addi	s0,sp,32
 394:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 398:	4605                	li	a2,1
 39a:	fef40593          	addi	a1,s0,-17
 39e:	00000097          	auipc	ra,0x0
 3a2:	f6e080e7          	jalr	-146(ra) # 30c <write>
}
 3a6:	60e2                	ld	ra,24(sp)
 3a8:	6442                	ld	s0,16(sp)
 3aa:	6105                	addi	sp,sp,32
 3ac:	8082                	ret

00000000000003ae <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ae:	7139                	addi	sp,sp,-64
 3b0:	fc06                	sd	ra,56(sp)
 3b2:	f822                	sd	s0,48(sp)
 3b4:	f426                	sd	s1,40(sp)
 3b6:	f04a                	sd	s2,32(sp)
 3b8:	ec4e                	sd	s3,24(sp)
 3ba:	0080                	addi	s0,sp,64
 3bc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3be:	c299                	beqz	a3,3c4 <printint+0x16>
 3c0:	0805c863          	bltz	a1,450 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3c4:	2581                	sext.w	a1,a1
  neg = 0;
 3c6:	4881                	li	a7,0
 3c8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3cc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ce:	2601                	sext.w	a2,a2
 3d0:	00000517          	auipc	a0,0x0
 3d4:	7b050513          	addi	a0,a0,1968 # b80 <digits>
 3d8:	883a                	mv	a6,a4
 3da:	2705                	addiw	a4,a4,1
 3dc:	02c5f7bb          	remuw	a5,a1,a2
 3e0:	1782                	slli	a5,a5,0x20
 3e2:	9381                	srli	a5,a5,0x20
 3e4:	97aa                	add	a5,a5,a0
 3e6:	0007c783          	lbu	a5,0(a5)
 3ea:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3ee:	0005879b          	sext.w	a5,a1
 3f2:	02c5d5bb          	divuw	a1,a1,a2
 3f6:	0685                	addi	a3,a3,1
 3f8:	fec7f0e3          	bgeu	a5,a2,3d8 <printint+0x2a>
  if(neg)
 3fc:	00088b63          	beqz	a7,412 <printint+0x64>
    buf[i++] = '-';
 400:	fd040793          	addi	a5,s0,-48
 404:	973e                	add	a4,a4,a5
 406:	02d00793          	li	a5,45
 40a:	fef70823          	sb	a5,-16(a4)
 40e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 412:	02e05863          	blez	a4,442 <printint+0x94>
 416:	fc040793          	addi	a5,s0,-64
 41a:	00e78933          	add	s2,a5,a4
 41e:	fff78993          	addi	s3,a5,-1
 422:	99ba                	add	s3,s3,a4
 424:	377d                	addiw	a4,a4,-1
 426:	1702                	slli	a4,a4,0x20
 428:	9301                	srli	a4,a4,0x20
 42a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 42e:	fff94583          	lbu	a1,-1(s2)
 432:	8526                	mv	a0,s1
 434:	00000097          	auipc	ra,0x0
 438:	f58080e7          	jalr	-168(ra) # 38c <putc>
  while(--i >= 0)
 43c:	197d                	addi	s2,s2,-1
 43e:	ff3918e3          	bne	s2,s3,42e <printint+0x80>
}
 442:	70e2                	ld	ra,56(sp)
 444:	7442                	ld	s0,48(sp)
 446:	74a2                	ld	s1,40(sp)
 448:	7902                	ld	s2,32(sp)
 44a:	69e2                	ld	s3,24(sp)
 44c:	6121                	addi	sp,sp,64
 44e:	8082                	ret
    x = -xx;
 450:	40b005bb          	negw	a1,a1
    neg = 1;
 454:	4885                	li	a7,1
    x = -xx;
 456:	bf8d                	j	3c8 <printint+0x1a>

0000000000000458 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 458:	7119                	addi	sp,sp,-128
 45a:	fc86                	sd	ra,120(sp)
 45c:	f8a2                	sd	s0,112(sp)
 45e:	f4a6                	sd	s1,104(sp)
 460:	f0ca                	sd	s2,96(sp)
 462:	ecce                	sd	s3,88(sp)
 464:	e8d2                	sd	s4,80(sp)
 466:	e4d6                	sd	s5,72(sp)
 468:	e0da                	sd	s6,64(sp)
 46a:	fc5e                	sd	s7,56(sp)
 46c:	f862                	sd	s8,48(sp)
 46e:	f466                	sd	s9,40(sp)
 470:	f06a                	sd	s10,32(sp)
 472:	ec6e                	sd	s11,24(sp)
 474:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 476:	0005c903          	lbu	s2,0(a1)
 47a:	18090f63          	beqz	s2,618 <vprintf+0x1c0>
 47e:	8aaa                	mv	s5,a0
 480:	8b32                	mv	s6,a2
 482:	00158493          	addi	s1,a1,1
  state = 0;
 486:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 488:	02500a13          	li	s4,37
      if(c == 'd'){
 48c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 490:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 494:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 498:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 49c:	00000b97          	auipc	s7,0x0
 4a0:	6e4b8b93          	addi	s7,s7,1764 # b80 <digits>
 4a4:	a839                	j	4c2 <vprintf+0x6a>
        putc(fd, c);
 4a6:	85ca                	mv	a1,s2
 4a8:	8556                	mv	a0,s5
 4aa:	00000097          	auipc	ra,0x0
 4ae:	ee2080e7          	jalr	-286(ra) # 38c <putc>
 4b2:	a019                	j	4b8 <vprintf+0x60>
    } else if(state == '%'){
 4b4:	01498f63          	beq	s3,s4,4d2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4b8:	0485                	addi	s1,s1,1
 4ba:	fff4c903          	lbu	s2,-1(s1)
 4be:	14090d63          	beqz	s2,618 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4c2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4c6:	fe0997e3          	bnez	s3,4b4 <vprintf+0x5c>
      if(c == '%'){
 4ca:	fd479ee3          	bne	a5,s4,4a6 <vprintf+0x4e>
        state = '%';
 4ce:	89be                	mv	s3,a5
 4d0:	b7e5                	j	4b8 <vprintf+0x60>
      if(c == 'd'){
 4d2:	05878063          	beq	a5,s8,512 <vprintf+0xba>
      } else if(c == 'l') {
 4d6:	05978c63          	beq	a5,s9,52e <vprintf+0xd6>
      } else if(c == 'x') {
 4da:	07a78863          	beq	a5,s10,54a <vprintf+0xf2>
      } else if(c == 'p') {
 4de:	09b78463          	beq	a5,s11,566 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4e2:	07300713          	li	a4,115
 4e6:	0ce78663          	beq	a5,a4,5b2 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4ea:	06300713          	li	a4,99
 4ee:	0ee78e63          	beq	a5,a4,5ea <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4f2:	11478863          	beq	a5,s4,602 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4f6:	85d2                	mv	a1,s4
 4f8:	8556                	mv	a0,s5
 4fa:	00000097          	auipc	ra,0x0
 4fe:	e92080e7          	jalr	-366(ra) # 38c <putc>
        putc(fd, c);
 502:	85ca                	mv	a1,s2
 504:	8556                	mv	a0,s5
 506:	00000097          	auipc	ra,0x0
 50a:	e86080e7          	jalr	-378(ra) # 38c <putc>
      }
      state = 0;
 50e:	4981                	li	s3,0
 510:	b765                	j	4b8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 512:	008b0913          	addi	s2,s6,8
 516:	4685                	li	a3,1
 518:	4629                	li	a2,10
 51a:	000b2583          	lw	a1,0(s6)
 51e:	8556                	mv	a0,s5
 520:	00000097          	auipc	ra,0x0
 524:	e8e080e7          	jalr	-370(ra) # 3ae <printint>
 528:	8b4a                	mv	s6,s2
      state = 0;
 52a:	4981                	li	s3,0
 52c:	b771                	j	4b8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 52e:	008b0913          	addi	s2,s6,8
 532:	4681                	li	a3,0
 534:	4629                	li	a2,10
 536:	000b2583          	lw	a1,0(s6)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	e72080e7          	jalr	-398(ra) # 3ae <printint>
 544:	8b4a                	mv	s6,s2
      state = 0;
 546:	4981                	li	s3,0
 548:	bf85                	j	4b8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 54a:	008b0913          	addi	s2,s6,8
 54e:	4681                	li	a3,0
 550:	4641                	li	a2,16
 552:	000b2583          	lw	a1,0(s6)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	e56080e7          	jalr	-426(ra) # 3ae <printint>
 560:	8b4a                	mv	s6,s2
      state = 0;
 562:	4981                	li	s3,0
 564:	bf91                	j	4b8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 566:	008b0793          	addi	a5,s6,8
 56a:	f8f43423          	sd	a5,-120(s0)
 56e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 572:	03000593          	li	a1,48
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e14080e7          	jalr	-492(ra) # 38c <putc>
  putc(fd, 'x');
 580:	85ea                	mv	a1,s10
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	e08080e7          	jalr	-504(ra) # 38c <putc>
 58c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 58e:	03c9d793          	srli	a5,s3,0x3c
 592:	97de                	add	a5,a5,s7
 594:	0007c583          	lbu	a1,0(a5)
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	df2080e7          	jalr	-526(ra) # 38c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5a2:	0992                	slli	s3,s3,0x4
 5a4:	397d                	addiw	s2,s2,-1
 5a6:	fe0914e3          	bnez	s2,58e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5aa:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	b721                	j	4b8 <vprintf+0x60>
        s = va_arg(ap, char*);
 5b2:	008b0993          	addi	s3,s6,8
 5b6:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5ba:	02090163          	beqz	s2,5dc <vprintf+0x184>
        while(*s != 0){
 5be:	00094583          	lbu	a1,0(s2)
 5c2:	c9a1                	beqz	a1,612 <vprintf+0x1ba>
          putc(fd, *s);
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	dc6080e7          	jalr	-570(ra) # 38c <putc>
          s++;
 5ce:	0905                	addi	s2,s2,1
        while(*s != 0){
 5d0:	00094583          	lbu	a1,0(s2)
 5d4:	f9e5                	bnez	a1,5c4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5d6:	8b4e                	mv	s6,s3
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	bdf9                	j	4b8 <vprintf+0x60>
          s = "(null)";
 5dc:	00000917          	auipc	s2,0x0
 5e0:	59c90913          	addi	s2,s2,1436 # b78 <uthread_self+0x34>
        while(*s != 0){
 5e4:	02800593          	li	a1,40
 5e8:	bff1                	j	5c4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5ea:	008b0913          	addi	s2,s6,8
 5ee:	000b4583          	lbu	a1,0(s6)
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	d98080e7          	jalr	-616(ra) # 38c <putc>
 5fc:	8b4a                	mv	s6,s2
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bd65                	j	4b8 <vprintf+0x60>
        putc(fd, c);
 602:	85d2                	mv	a1,s4
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	d86080e7          	jalr	-634(ra) # 38c <putc>
      state = 0;
 60e:	4981                	li	s3,0
 610:	b565                	j	4b8 <vprintf+0x60>
        s = va_arg(ap, char*);
 612:	8b4e                	mv	s6,s3
      state = 0;
 614:	4981                	li	s3,0
 616:	b54d                	j	4b8 <vprintf+0x60>
    }
  }
}
 618:	70e6                	ld	ra,120(sp)
 61a:	7446                	ld	s0,112(sp)
 61c:	74a6                	ld	s1,104(sp)
 61e:	7906                	ld	s2,96(sp)
 620:	69e6                	ld	s3,88(sp)
 622:	6a46                	ld	s4,80(sp)
 624:	6aa6                	ld	s5,72(sp)
 626:	6b06                	ld	s6,64(sp)
 628:	7be2                	ld	s7,56(sp)
 62a:	7c42                	ld	s8,48(sp)
 62c:	7ca2                	ld	s9,40(sp)
 62e:	7d02                	ld	s10,32(sp)
 630:	6de2                	ld	s11,24(sp)
 632:	6109                	addi	sp,sp,128
 634:	8082                	ret

0000000000000636 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 636:	715d                	addi	sp,sp,-80
 638:	ec06                	sd	ra,24(sp)
 63a:	e822                	sd	s0,16(sp)
 63c:	1000                	addi	s0,sp,32
 63e:	e010                	sd	a2,0(s0)
 640:	e414                	sd	a3,8(s0)
 642:	e818                	sd	a4,16(s0)
 644:	ec1c                	sd	a5,24(s0)
 646:	03043023          	sd	a6,32(s0)
 64a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 64e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 652:	8622                	mv	a2,s0
 654:	00000097          	auipc	ra,0x0
 658:	e04080e7          	jalr	-508(ra) # 458 <vprintf>
}
 65c:	60e2                	ld	ra,24(sp)
 65e:	6442                	ld	s0,16(sp)
 660:	6161                	addi	sp,sp,80
 662:	8082                	ret

0000000000000664 <printf>:

void
printf(const char *fmt, ...)
{
 664:	711d                	addi	sp,sp,-96
 666:	ec06                	sd	ra,24(sp)
 668:	e822                	sd	s0,16(sp)
 66a:	1000                	addi	s0,sp,32
 66c:	e40c                	sd	a1,8(s0)
 66e:	e810                	sd	a2,16(s0)
 670:	ec14                	sd	a3,24(s0)
 672:	f018                	sd	a4,32(s0)
 674:	f41c                	sd	a5,40(s0)
 676:	03043823          	sd	a6,48(s0)
 67a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 67e:	00840613          	addi	a2,s0,8
 682:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 686:	85aa                	mv	a1,a0
 688:	4505                	li	a0,1
 68a:	00000097          	auipc	ra,0x0
 68e:	dce080e7          	jalr	-562(ra) # 458 <vprintf>
}
 692:	60e2                	ld	ra,24(sp)
 694:	6442                	ld	s0,16(sp)
 696:	6125                	addi	sp,sp,96
 698:	8082                	ret

000000000000069a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 69a:	1141                	addi	sp,sp,-16
 69c:	e422                	sd	s0,8(sp)
 69e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6a0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a4:	00001797          	auipc	a5,0x1
 6a8:	95c7b783          	ld	a5,-1700(a5) # 1000 <freep>
 6ac:	a805                	j	6dc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ae:	4618                	lw	a4,8(a2)
 6b0:	9db9                	addw	a1,a1,a4
 6b2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6b6:	6398                	ld	a4,0(a5)
 6b8:	6318                	ld	a4,0(a4)
 6ba:	fee53823          	sd	a4,-16(a0)
 6be:	a091                	j	702 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6c0:	ff852703          	lw	a4,-8(a0)
 6c4:	9e39                	addw	a2,a2,a4
 6c6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6c8:	ff053703          	ld	a4,-16(a0)
 6cc:	e398                	sd	a4,0(a5)
 6ce:	a099                	j	714 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d0:	6398                	ld	a4,0(a5)
 6d2:	00e7e463          	bltu	a5,a4,6da <free+0x40>
 6d6:	00e6ea63          	bltu	a3,a4,6ea <free+0x50>
{
 6da:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6dc:	fed7fae3          	bgeu	a5,a3,6d0 <free+0x36>
 6e0:	6398                	ld	a4,0(a5)
 6e2:	00e6e463          	bltu	a3,a4,6ea <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e6:	fee7eae3          	bltu	a5,a4,6da <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6ea:	ff852583          	lw	a1,-8(a0)
 6ee:	6390                	ld	a2,0(a5)
 6f0:	02059713          	slli	a4,a1,0x20
 6f4:	9301                	srli	a4,a4,0x20
 6f6:	0712                	slli	a4,a4,0x4
 6f8:	9736                	add	a4,a4,a3
 6fa:	fae60ae3          	beq	a2,a4,6ae <free+0x14>
    bp->s.ptr = p->s.ptr;
 6fe:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 702:	4790                	lw	a2,8(a5)
 704:	02061713          	slli	a4,a2,0x20
 708:	9301                	srli	a4,a4,0x20
 70a:	0712                	slli	a4,a4,0x4
 70c:	973e                	add	a4,a4,a5
 70e:	fae689e3          	beq	a3,a4,6c0 <free+0x26>
  } else
    p->s.ptr = bp;
 712:	e394                	sd	a3,0(a5)
  freep = p;
 714:	00001717          	auipc	a4,0x1
 718:	8ef73623          	sd	a5,-1812(a4) # 1000 <freep>
}
 71c:	6422                	ld	s0,8(sp)
 71e:	0141                	addi	sp,sp,16
 720:	8082                	ret

0000000000000722 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 722:	7139                	addi	sp,sp,-64
 724:	fc06                	sd	ra,56(sp)
 726:	f822                	sd	s0,48(sp)
 728:	f426                	sd	s1,40(sp)
 72a:	f04a                	sd	s2,32(sp)
 72c:	ec4e                	sd	s3,24(sp)
 72e:	e852                	sd	s4,16(sp)
 730:	e456                	sd	s5,8(sp)
 732:	e05a                	sd	s6,0(sp)
 734:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 736:	02051493          	slli	s1,a0,0x20
 73a:	9081                	srli	s1,s1,0x20
 73c:	04bd                	addi	s1,s1,15
 73e:	8091                	srli	s1,s1,0x4
 740:	0014899b          	addiw	s3,s1,1
 744:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 746:	00001517          	auipc	a0,0x1
 74a:	8ba53503          	ld	a0,-1862(a0) # 1000 <freep>
 74e:	c515                	beqz	a0,77a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 750:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 752:	4798                	lw	a4,8(a5)
 754:	02977f63          	bgeu	a4,s1,792 <malloc+0x70>
 758:	8a4e                	mv	s4,s3
 75a:	0009871b          	sext.w	a4,s3
 75e:	6685                	lui	a3,0x1
 760:	00d77363          	bgeu	a4,a3,766 <malloc+0x44>
 764:	6a05                	lui	s4,0x1
 766:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 76a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 76e:	00001917          	auipc	s2,0x1
 772:	89290913          	addi	s2,s2,-1902 # 1000 <freep>
  if(p == (char*)-1)
 776:	5afd                	li	s5,-1
 778:	a88d                	j	7ea <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 77a:	00001797          	auipc	a5,0x1
 77e:	8a678793          	addi	a5,a5,-1882 # 1020 <base>
 782:	00001717          	auipc	a4,0x1
 786:	86f73f23          	sd	a5,-1922(a4) # 1000 <freep>
 78a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 78c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 790:	b7e1                	j	758 <malloc+0x36>
      if(p->s.size == nunits)
 792:	02e48b63          	beq	s1,a4,7c8 <malloc+0xa6>
        p->s.size -= nunits;
 796:	4137073b          	subw	a4,a4,s3
 79a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 79c:	1702                	slli	a4,a4,0x20
 79e:	9301                	srli	a4,a4,0x20
 7a0:	0712                	slli	a4,a4,0x4
 7a2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7a4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7a8:	00001717          	auipc	a4,0x1
 7ac:	84a73c23          	sd	a0,-1960(a4) # 1000 <freep>
      return (void*)(p + 1);
 7b0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7b4:	70e2                	ld	ra,56(sp)
 7b6:	7442                	ld	s0,48(sp)
 7b8:	74a2                	ld	s1,40(sp)
 7ba:	7902                	ld	s2,32(sp)
 7bc:	69e2                	ld	s3,24(sp)
 7be:	6a42                	ld	s4,16(sp)
 7c0:	6aa2                	ld	s5,8(sp)
 7c2:	6b02                	ld	s6,0(sp)
 7c4:	6121                	addi	sp,sp,64
 7c6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7c8:	6398                	ld	a4,0(a5)
 7ca:	e118                	sd	a4,0(a0)
 7cc:	bff1                	j	7a8 <malloc+0x86>
  hp->s.size = nu;
 7ce:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7d2:	0541                	addi	a0,a0,16
 7d4:	00000097          	auipc	ra,0x0
 7d8:	ec6080e7          	jalr	-314(ra) # 69a <free>
  return freep;
 7dc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7e0:	d971                	beqz	a0,7b4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e4:	4798                	lw	a4,8(a5)
 7e6:	fa9776e3          	bgeu	a4,s1,792 <malloc+0x70>
    if(p == freep)
 7ea:	00093703          	ld	a4,0(s2)
 7ee:	853e                	mv	a0,a5
 7f0:	fef719e3          	bne	a4,a5,7e2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7f4:	8552                	mv	a0,s4
 7f6:	00000097          	auipc	ra,0x0
 7fa:	b7e080e7          	jalr	-1154(ra) # 374 <sbrk>
  if(p == (char*)-1)
 7fe:	fd5518e3          	bne	a0,s5,7ce <malloc+0xac>
        return 0;
 802:	4501                	li	a0,0
 804:	bf45                	j	7b4 <malloc+0x92>

0000000000000806 <uswtch>:
 806:	00153023          	sd	ra,0(a0)
 80a:	00253423          	sd	sp,8(a0)
 80e:	e900                	sd	s0,16(a0)
 810:	ed04                	sd	s1,24(a0)
 812:	03253023          	sd	s2,32(a0)
 816:	03353423          	sd	s3,40(a0)
 81a:	03453823          	sd	s4,48(a0)
 81e:	03553c23          	sd	s5,56(a0)
 822:	05653023          	sd	s6,64(a0)
 826:	05753423          	sd	s7,72(a0)
 82a:	05853823          	sd	s8,80(a0)
 82e:	05953c23          	sd	s9,88(a0)
 832:	07a53023          	sd	s10,96(a0)
 836:	07b53423          	sd	s11,104(a0)
 83a:	0005b083          	ld	ra,0(a1)
 83e:	0085b103          	ld	sp,8(a1)
 842:	6980                	ld	s0,16(a1)
 844:	6d84                	ld	s1,24(a1)
 846:	0205b903          	ld	s2,32(a1)
 84a:	0285b983          	ld	s3,40(a1)
 84e:	0305ba03          	ld	s4,48(a1)
 852:	0385ba83          	ld	s5,56(a1)
 856:	0405bb03          	ld	s6,64(a1)
 85a:	0485bb83          	ld	s7,72(a1)
 85e:	0505bc03          	ld	s8,80(a1)
 862:	0585bc83          	ld	s9,88(a1)
 866:	0605bd03          	ld	s10,96(a1)
 86a:	0685bd83          	ld	s11,104(a1)
 86e:	8082                	ret

0000000000000870 <uthread_exit>:
    curr_thread = next_thread;
    uswtch(curr_context, next_context);

}

void uthread_exit(){
 870:	1141                	addi	sp,sp,-16
 872:	e406                	sd	ra,8(sp)
 874:	e022                	sd	s0,0(sp)
 876:	0800                	addi	s0,sp,16
    // Change the state of the current thread to FREE
    curr_thread->state = FREE;
 878:	00000517          	auipc	a0,0x0
 87c:	79053503          	ld	a0,1936(a0) # 1008 <curr_thread>
 880:	6785                	lui	a5,0x1
 882:	97aa                	add	a5,a5,a0
 884:	fa07a223          	sw	zero,-92(a5) # fa4 <digits+0x424>
    // Find another runnable thread to switch to (make sure its not the current_thread)
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 888:	411c                	lw	a5,0(a0)
 88a:	2785                	addiw	a5,a5,1
 88c:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 88e:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 890:	4585                	li	a1,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 892:	00001617          	auipc	a2,0x1
 896:	80e60613          	addi	a2,a2,-2034 # 10a0 <uthreads_arr>
 89a:	6805                	lui	a6,0x1
 89c:	4889                	li	a7,2
 89e:	a819                	j	8b4 <uthread_exit+0x44>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 8a0:	2785                	addiw	a5,a5,1
 8a2:	41f7d71b          	sraiw	a4,a5,0x1f
 8a6:	01e7571b          	srliw	a4,a4,0x1e
 8aa:	9fb9                	addw	a5,a5,a4
 8ac:	8b8d                	andi	a5,a5,3
 8ae:	9f99                	subw	a5,a5,a4
 8b0:	36fd                	addiw	a3,a3,-1
 8b2:	ca9d                	beqz	a3,8e8 <uthread_exit+0x78>
        if (uthreads_arr[i].state == RUNNABLE &&
 8b4:	00779713          	slli	a4,a5,0x7
 8b8:	973e                	add	a4,a4,a5
 8ba:	0716                	slli	a4,a4,0x5
 8bc:	9732                	add	a4,a4,a2
 8be:	9742                	add	a4,a4,a6
 8c0:	fa472703          	lw	a4,-92(a4)
 8c4:	fd171ee3          	bne	a4,a7,8a0 <uthread_exit+0x30>
            uthreads_arr[i].priority > max_priority) {
 8c8:	00779713          	slli	a4,a5,0x7
 8cc:	973e                	add	a4,a4,a5
 8ce:	0716                	slli	a4,a4,0x5
 8d0:	9732                	add	a4,a4,a2
 8d2:	9742                	add	a4,a4,a6
 8d4:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 8d6:	fce375e3          	bgeu	t1,a4,8a0 <uthread_exit+0x30>
            next_thread = &uthreads_arr[i];
 8da:	00779593          	slli	a1,a5,0x7
 8de:	95be                	add	a1,a1,a5
 8e0:	0596                	slli	a1,a1,0x5
 8e2:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 8e4:	833a                	mv	t1,a4
 8e6:	bf6d                	j	8a0 <uthread_exit+0x30>
        }
    }
    if (next_thread == (struct uthread *) 1) {
 8e8:	4785                	li	a5,1
 8ea:	02f58863          	beq	a1,a5,91a <uthread_exit+0xaa>
        exit(0);  // Exit the process if there are no more runnable threads
    }
    // Switch to the next thread
    struct context *curr_context = &curr_thread->context;
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 8ee:	6785                	lui	a5,0x1
 8f0:	00f58733          	add	a4,a1,a5
 8f4:	4685                	li	a3,1
 8f6:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 8fa:	00000717          	auipc	a4,0x0
 8fe:	70b73723          	sd	a1,1806(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 902:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x428>
    uswtch(curr_context, next_context);
 906:	95be                	add	a1,a1,a5
 908:	953e                	add	a0,a0,a5
 90a:	00000097          	auipc	ra,0x0
 90e:	efc080e7          	jalr	-260(ra) # 806 <uswtch>
}
 912:	60a2                	ld	ra,8(sp)
 914:	6402                	ld	s0,0(sp)
 916:	0141                	addi	sp,sp,16
 918:	8082                	ret
        exit(0);  // Exit the process if there are no more runnable threads
 91a:	4501                	li	a0,0
 91c:	00000097          	auipc	ra,0x0
 920:	9d0080e7          	jalr	-1584(ra) # 2ec <exit>

0000000000000924 <uthread_create>:
int uthread_create(void (*start_func)(), enum sched_priority priority) {
 924:	1141                	addi	sp,sp,-16
 926:	e422                	sd	s0,8(sp)
 928:	0800                	addi	s0,sp,16
    for (i = 0; i < MAX_UTHREADS; i++) {
 92a:	00001717          	auipc	a4,0x1
 92e:	71a70713          	addi	a4,a4,1818 # 2044 <uthreads_arr+0xfa4>
 932:	4781                	li	a5,0
 934:	6605                	lui	a2,0x1
 936:	02060613          	addi	a2,a2,32 # 1020 <base>
 93a:	4811                	li	a6,4
        if (uthreads_arr[i].state == FREE) {
 93c:	4314                	lw	a3,0(a4)
 93e:	c699                	beqz	a3,94c <uthread_create+0x28>
    for (i = 0; i < MAX_UTHREADS; i++) {
 940:	2785                	addiw	a5,a5,1
 942:	9732                	add	a4,a4,a2
 944:	ff079ce3          	bne	a5,a6,93c <uthread_create+0x18>
        return -1;
 948:	557d                	li	a0,-1
 94a:	a0b9                	j	998 <uthread_create+0x74>
            curr_thread = &uthreads_arr[i];
 94c:	00779713          	slli	a4,a5,0x7
 950:	973e                	add	a4,a4,a5
 952:	0716                	slli	a4,a4,0x5
 954:	00000697          	auipc	a3,0x0
 958:	74c68693          	addi	a3,a3,1868 # 10a0 <uthreads_arr>
 95c:	9736                	add	a4,a4,a3
 95e:	00000697          	auipc	a3,0x0
 962:	6ae6b523          	sd	a4,1706(a3) # 1008 <curr_thread>
    if (i >= MAX_UTHREADS) {
 966:	468d                	li	a3,3
 968:	02f6cb63          	blt	a3,a5,99e <uthread_create+0x7a>
    curr_thread->id = i; 
 96c:	c31c                	sw	a5,0(a4)
    curr_thread->priority = priority;
 96e:	6685                	lui	a3,0x1
 970:	00d707b3          	add	a5,a4,a3
 974:	cf8c                	sw	a1,24(a5)
    curr_thread->context.ra = (uint64) start_func;
 976:	faa7b423          	sd	a0,-88(a5)
    curr_thread->context.sp = (uint64) &curr_thread->ustack[STACK_SIZE];
 97a:	fa468693          	addi	a3,a3,-92 # fa4 <digits+0x424>
 97e:	9736                	add	a4,a4,a3
 980:	fae7b823          	sd	a4,-80(a5)
    curr_thread->ustack[STACK_SIZE - 1] = (uint64) uthread_exit; // Return address to uthread_exit
 984:	00000717          	auipc	a4,0x0
 988:	eec70713          	addi	a4,a4,-276 # 870 <uthread_exit>
 98c:	fae781a3          	sb	a4,-93(a5)
    curr_thread->state = RUNNABLE;
 990:	4709                	li	a4,2
 992:	fae7a223          	sw	a4,-92(a5)
     return 0;
 996:	4501                	li	a0,0
}
 998:	6422                	ld	s0,8(sp)
 99a:	0141                	addi	sp,sp,16
 99c:	8082                	ret
        return -1;
 99e:	557d                	li	a0,-1
 9a0:	bfe5                	j	998 <uthread_create+0x74>

00000000000009a2 <uthread_yield>:
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 9a2:	00000517          	auipc	a0,0x0
 9a6:	66653503          	ld	a0,1638(a0) # 1008 <curr_thread>
 9aa:	411c                	lw	a5,0(a0)
 9ac:	2785                	addiw	a5,a5,1
 9ae:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 9b0:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 9b2:	4585                	li	a1,1
        if (uthreads_arr[i].state == RUNNABLE &&
 9b4:	00000617          	auipc	a2,0x0
 9b8:	6ec60613          	addi	a2,a2,1772 # 10a0 <uthreads_arr>
 9bc:	6805                	lui	a6,0x1
 9be:	4889                	li	a7,2
 9c0:	a819                	j	9d6 <uthread_yield+0x34>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 9c2:	2785                	addiw	a5,a5,1
 9c4:	41f7d71b          	sraiw	a4,a5,0x1f
 9c8:	01e7571b          	srliw	a4,a4,0x1e
 9cc:	9fb9                	addw	a5,a5,a4
 9ce:	8b8d                	andi	a5,a5,3
 9d0:	9f99                	subw	a5,a5,a4
 9d2:	36fd                	addiw	a3,a3,-1
 9d4:	ca9d                	beqz	a3,a0a <uthread_yield+0x68>
        if (uthreads_arr[i].state == RUNNABLE &&
 9d6:	00779713          	slli	a4,a5,0x7
 9da:	973e                	add	a4,a4,a5
 9dc:	0716                	slli	a4,a4,0x5
 9de:	9732                	add	a4,a4,a2
 9e0:	9742                	add	a4,a4,a6
 9e2:	fa472703          	lw	a4,-92(a4)
 9e6:	fd171ee3          	bne	a4,a7,9c2 <uthread_yield+0x20>
            uthreads_arr[i].priority > max_priority) {
 9ea:	00779713          	slli	a4,a5,0x7
 9ee:	973e                	add	a4,a4,a5
 9f0:	0716                	slli	a4,a4,0x5
 9f2:	9732                	add	a4,a4,a2
 9f4:	9742                	add	a4,a4,a6
 9f6:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 9f8:	fce375e3          	bgeu	t1,a4,9c2 <uthread_yield+0x20>
            next_thread = &uthreads_arr[i];
 9fc:	00779593          	slli	a1,a5,0x7
 a00:	95be                	add	a1,a1,a5
 a02:	0596                	slli	a1,a1,0x5
 a04:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 a06:	833a                	mv	t1,a4
 a08:	bf6d                	j	9c2 <uthread_yield+0x20>
    if (next_thread == (struct uthread *) 1) {
 a0a:	4785                	li	a5,1
 a0c:	04f58163          	beq	a1,a5,a4e <uthread_yield+0xac>
void uthread_yield() {
 a10:	1141                	addi	sp,sp,-16
 a12:	e406                	sd	ra,8(sp)
 a14:	e022                	sd	s0,0(sp)
 a16:	0800                	addi	s0,sp,16
    curr_thread->state = RUNNABLE;
 a18:	6785                	lui	a5,0x1
 a1a:	00f50733          	add	a4,a0,a5
 a1e:	4689                	li	a3,2
 a20:	fad72223          	sw	a3,-92(a4)
    next_thread->state = RUNNING;
 a24:	00f58733          	add	a4,a1,a5
 a28:	4685                	li	a3,1
 a2a:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 a2e:	00000717          	auipc	a4,0x0
 a32:	5cb73d23          	sd	a1,1498(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 a36:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x428>
    uswtch(curr_context, next_context);
 a3a:	95be                	add	a1,a1,a5
 a3c:	953e                	add	a0,a0,a5
 a3e:	00000097          	auipc	ra,0x0
 a42:	dc8080e7          	jalr	-568(ra) # 806 <uswtch>
}
 a46:	60a2                	ld	ra,8(sp)
 a48:	6402                	ld	s0,0(sp)
 a4a:	0141                	addi	sp,sp,16
 a4c:	8082                	ret
 a4e:	8082                	ret

0000000000000a50 <uthread_set_priority>:

enum sched_priority uthread_set_priority(enum sched_priority priority){
 a50:	1141                	addi	sp,sp,-16
 a52:	e422                	sd	s0,8(sp)
 a54:	0800                	addi	s0,sp,16
    enum sched_priority to_return =curr_thread->priority;
 a56:	00000797          	auipc	a5,0x0
 a5a:	5b27b783          	ld	a5,1458(a5) # 1008 <curr_thread>
 a5e:	6705                	lui	a4,0x1
 a60:	97ba                	add	a5,a5,a4
 a62:	4f98                	lw	a4,24(a5)
    curr_thread->priority=priority;
 a64:	cf88                	sw	a0,24(a5)
    return to_return;
}
 a66:	853a                	mv	a0,a4
 a68:	6422                	ld	s0,8(sp)
 a6a:	0141                	addi	sp,sp,16
 a6c:	8082                	ret

0000000000000a6e <uthread_get_priority>:

enum sched_priority uthread_get_priority(){
 a6e:	1141                	addi	sp,sp,-16
 a70:	e422                	sd	s0,8(sp)
 a72:	0800                	addi	s0,sp,16
    return curr_thread->priority;
 a74:	00000797          	auipc	a5,0x0
 a78:	5947b783          	ld	a5,1428(a5) # 1008 <curr_thread>
 a7c:	6705                	lui	a4,0x1
 a7e:	97ba                	add	a5,a5,a4
}
 a80:	4f88                	lw	a0,24(a5)
 a82:	6422                	ld	s0,8(sp)
 a84:	0141                	addi	sp,sp,16
 a86:	8082                	ret

0000000000000a88 <uthread_start_all>:

int uthread_start_all(){
    if (started){
 a88:	00000797          	auipc	a5,0x0
 a8c:	5887a783          	lw	a5,1416(a5) # 1010 <started>
 a90:	ebc5                	bnez	a5,b40 <uthread_start_all+0xb8>
int uthread_start_all(){
 a92:	1141                	addi	sp,sp,-16
 a94:	e406                	sd	ra,8(sp)
 a96:	e022                	sd	s0,0(sp)
 a98:	0800                	addi	s0,sp,16
        return -1;
    }
    started=1;
 a9a:	4785                	li	a5,1
 a9c:	00000717          	auipc	a4,0x0
 aa0:	56f72a23          	sw	a5,1396(a4) # 1010 <started>
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 aa4:	00000797          	auipc	a5,0x0
 aa8:	5647b783          	ld	a5,1380(a5) # 1008 <curr_thread>
 aac:	439c                	lw	a5,0(a5)
 aae:	2785                	addiw	a5,a5,1
 ab0:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 ab2:	4881                	li	a7,0
    struct uthread *next_thread = (struct uthread *) 1;
 ab4:	4605                	li	a2,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 ab6:	00000597          	auipc	a1,0x0
 aba:	5ea58593          	addi	a1,a1,1514 # 10a0 <uthreads_arr>
 abe:	6505                	lui	a0,0x1
 ac0:	4809                	li	a6,2
 ac2:	a819                	j	ad8 <uthread_start_all+0x50>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 ac4:	2785                	addiw	a5,a5,1
 ac6:	41f7d71b          	sraiw	a4,a5,0x1f
 aca:	01e7571b          	srliw	a4,a4,0x1e
 ace:	9fb9                	addw	a5,a5,a4
 ad0:	8b8d                	andi	a5,a5,3
 ad2:	9f99                	subw	a5,a5,a4
 ad4:	36fd                	addiw	a3,a3,-1
 ad6:	ca9d                	beqz	a3,b0c <uthread_start_all+0x84>
        if (uthreads_arr[i].state == RUNNABLE &&
 ad8:	00779713          	slli	a4,a5,0x7
 adc:	973e                	add	a4,a4,a5
 ade:	0716                	slli	a4,a4,0x5
 ae0:	972e                	add	a4,a4,a1
 ae2:	972a                	add	a4,a4,a0
 ae4:	fa472703          	lw	a4,-92(a4)
 ae8:	fd071ee3          	bne	a4,a6,ac4 <uthread_start_all+0x3c>
            uthreads_arr[i].priority > max_priority) {
 aec:	00779713          	slli	a4,a5,0x7
 af0:	973e                	add	a4,a4,a5
 af2:	0716                	slli	a4,a4,0x5
 af4:	972e                	add	a4,a4,a1
 af6:	972a                	add	a4,a4,a0
 af8:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 afa:	fce8f5e3          	bgeu	a7,a4,ac4 <uthread_start_all+0x3c>
            next_thread = &uthreads_arr[i];
 afe:	00779613          	slli	a2,a5,0x7
 b02:	963e                	add	a2,a2,a5
 b04:	0616                	slli	a2,a2,0x5
 b06:	962e                	add	a2,a2,a1
            max_priority = uthreads_arr[i].priority;
 b08:	88ba                	mv	a7,a4
 b0a:	bf6d                	j	ac4 <uthread_start_all+0x3c>
        }
    }
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 b0c:	6585                	lui	a1,0x1
 b0e:	00b607b3          	add	a5,a2,a1
 b12:	4705                	li	a4,1
 b14:	fae7a223          	sw	a4,-92(a5)
    curr_thread = next_thread;
 b18:	00000797          	auipc	a5,0x0
 b1c:	4ec7b823          	sd	a2,1264(a5) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 b20:	fa858593          	addi	a1,a1,-88 # fa8 <digits+0x428>
    uswtch(&garbageContext,next_context);
 b24:	95b2                	add	a1,a1,a2
 b26:	00000517          	auipc	a0,0x0
 b2a:	50a50513          	addi	a0,a0,1290 # 1030 <garbageContext>
 b2e:	00000097          	auipc	ra,0x0
 b32:	cd8080e7          	jalr	-808(ra) # 806 <uswtch>

    return -1;
}
 b36:	557d                	li	a0,-1
 b38:	60a2                	ld	ra,8(sp)
 b3a:	6402                	ld	s0,0(sp)
 b3c:	0141                	addi	sp,sp,16
 b3e:	8082                	ret
 b40:	557d                	li	a0,-1
 b42:	8082                	ret

0000000000000b44 <uthread_self>:

struct uthread* uthread_self(){
 b44:	1141                	addi	sp,sp,-16
 b46:	e422                	sd	s0,8(sp)
 b48:	0800                	addi	s0,sp,16
    return curr_thread;
 b4a:	00000517          	auipc	a0,0x0
 b4e:	4be53503          	ld	a0,1214(a0) # 1008 <curr_thread>
 b52:	6422                	ld	s0,8(sp)
 b54:	0141                	addi	sp,sp,16
 b56:	8082                	ret
