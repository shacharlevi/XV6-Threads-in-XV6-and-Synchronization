
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	32a080e7          	jalr	810(ra) # 33a <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	2fe080e7          	jalr	766(ra) # 33a <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	2dc080e7          	jalr	732(ra) # 33a <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	fba98993          	addi	s3,s3,-70 # 1020 <buf.0>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	438080e7          	jalr	1080(ra) # 4ae <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	2ba080e7          	jalr	698(ra) # 33a <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	2ac080e7          	jalr	684(ra) # 33a <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	2bc080e7          	jalr	700(ra) # 364 <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	d9010113          	addi	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	24913c23          	sd	s1,600(sp)
  c4:	25213823          	sd	s2,592(sp)
  c8:	25313423          	sd	s3,584(sp)
  cc:	25413023          	sd	s4,576(sp)
  d0:	23513c23          	sd	s5,568(sp)
  d4:	1c80                	addi	s0,sp,624
  d6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  d8:	4581                	li	a1,0
  da:	00000097          	auipc	ra,0x0
  de:	4c6080e7          	jalr	1222(ra) # 5a0 <open>
  e2:	08054163          	bltz	a0,164 <ls+0xb0>
  e6:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  e8:	d9840593          	addi	a1,s0,-616
  ec:	00000097          	auipc	ra,0x0
  f0:	4cc080e7          	jalr	1228(ra) # 5b8 <fstat>
  f4:	08054363          	bltz	a0,17a <ls+0xc6>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  f8:	da041783          	lh	a5,-608(s0)
  fc:	0007869b          	sext.w	a3,a5
 100:	4705                	li	a4,1
 102:	08e68c63          	beq	a3,a4,19a <ls+0xe6>
 106:	37f9                	addiw	a5,a5,-2
 108:	17c2                	slli	a5,a5,0x30
 10a:	93c1                	srli	a5,a5,0x30
 10c:	02f76663          	bltu	a4,a5,138 <ls+0x84>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 110:	854a                	mv	a0,s2
 112:	00000097          	auipc	ra,0x0
 116:	eee080e7          	jalr	-274(ra) # 0 <fmtname>
 11a:	85aa                	mv	a1,a0
 11c:	da843703          	ld	a4,-600(s0)
 120:	d9c42683          	lw	a3,-612(s0)
 124:	da041603          	lh	a2,-608(s0)
 128:	00001517          	auipc	a0,0x1
 12c:	d1850513          	addi	a0,a0,-744 # e40 <uthread_self+0x50>
 130:	00000097          	auipc	ra,0x0
 134:	7d0080e7          	jalr	2000(ra) # 900 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 138:	8526                	mv	a0,s1
 13a:	00000097          	auipc	ra,0x0
 13e:	44e080e7          	jalr	1102(ra) # 588 <close>
}
 142:	26813083          	ld	ra,616(sp)
 146:	26013403          	ld	s0,608(sp)
 14a:	25813483          	ld	s1,600(sp)
 14e:	25013903          	ld	s2,592(sp)
 152:	24813983          	ld	s3,584(sp)
 156:	24013a03          	ld	s4,576(sp)
 15a:	23813a83          	ld	s5,568(sp)
 15e:	27010113          	addi	sp,sp,624
 162:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 164:	864a                	mv	a2,s2
 166:	00001597          	auipc	a1,0x1
 16a:	caa58593          	addi	a1,a1,-854 # e10 <uthread_self+0x20>
 16e:	4509                	li	a0,2
 170:	00000097          	auipc	ra,0x0
 174:	762080e7          	jalr	1890(ra) # 8d2 <fprintf>
    return;
 178:	b7e9                	j	142 <ls+0x8e>
    fprintf(2, "ls: cannot stat %s\n", path);
 17a:	864a                	mv	a2,s2
 17c:	00001597          	auipc	a1,0x1
 180:	cac58593          	addi	a1,a1,-852 # e28 <uthread_self+0x38>
 184:	4509                	li	a0,2
 186:	00000097          	auipc	ra,0x0
 18a:	74c080e7          	jalr	1868(ra) # 8d2 <fprintf>
    close(fd);
 18e:	8526                	mv	a0,s1
 190:	00000097          	auipc	ra,0x0
 194:	3f8080e7          	jalr	1016(ra) # 588 <close>
    return;
 198:	b76d                	j	142 <ls+0x8e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 19a:	854a                	mv	a0,s2
 19c:	00000097          	auipc	ra,0x0
 1a0:	19e080e7          	jalr	414(ra) # 33a <strlen>
 1a4:	2541                	addiw	a0,a0,16
 1a6:	20000793          	li	a5,512
 1aa:	00a7fb63          	bgeu	a5,a0,1c0 <ls+0x10c>
      printf("ls: path too long\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	ca250513          	addi	a0,a0,-862 # e50 <uthread_self+0x60>
 1b6:	00000097          	auipc	ra,0x0
 1ba:	74a080e7          	jalr	1866(ra) # 900 <printf>
      break;
 1be:	bfad                	j	138 <ls+0x84>
    strcpy(buf, path);
 1c0:	85ca                	mv	a1,s2
 1c2:	dc040513          	addi	a0,s0,-576
 1c6:	00000097          	auipc	ra,0x0
 1ca:	12c080e7          	jalr	300(ra) # 2f2 <strcpy>
    p = buf+strlen(buf);
 1ce:	dc040513          	addi	a0,s0,-576
 1d2:	00000097          	auipc	ra,0x0
 1d6:	168080e7          	jalr	360(ra) # 33a <strlen>
 1da:	02051913          	slli	s2,a0,0x20
 1de:	02095913          	srli	s2,s2,0x20
 1e2:	dc040793          	addi	a5,s0,-576
 1e6:	993e                	add	s2,s2,a5
    *p++ = '/';
 1e8:	00190993          	addi	s3,s2,1
 1ec:	02f00793          	li	a5,47
 1f0:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 1f4:	00001a17          	auipc	s4,0x1
 1f8:	c74a0a13          	addi	s4,s4,-908 # e68 <uthread_self+0x78>
        printf("ls: cannot stat %s\n", buf);
 1fc:	00001a97          	auipc	s5,0x1
 200:	c2ca8a93          	addi	s5,s5,-980 # e28 <uthread_self+0x38>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 204:	a801                	j	214 <ls+0x160>
        printf("ls: cannot stat %s\n", buf);
 206:	dc040593          	addi	a1,s0,-576
 20a:	8556                	mv	a0,s5
 20c:	00000097          	auipc	ra,0x0
 210:	6f4080e7          	jalr	1780(ra) # 900 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 214:	4641                	li	a2,16
 216:	db040593          	addi	a1,s0,-592
 21a:	8526                	mv	a0,s1
 21c:	00000097          	auipc	ra,0x0
 220:	35c080e7          	jalr	860(ra) # 578 <read>
 224:	47c1                	li	a5,16
 226:	f0f519e3          	bne	a0,a5,138 <ls+0x84>
      if(de.inum == 0)
 22a:	db045783          	lhu	a5,-592(s0)
 22e:	d3fd                	beqz	a5,214 <ls+0x160>
      memmove(p, de.name, DIRSIZ);
 230:	4639                	li	a2,14
 232:	db240593          	addi	a1,s0,-590
 236:	854e                	mv	a0,s3
 238:	00000097          	auipc	ra,0x0
 23c:	276080e7          	jalr	630(ra) # 4ae <memmove>
      p[DIRSIZ] = 0;
 240:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 244:	d9840593          	addi	a1,s0,-616
 248:	dc040513          	addi	a0,s0,-576
 24c:	00000097          	auipc	ra,0x0
 250:	1d2080e7          	jalr	466(ra) # 41e <stat>
 254:	fa0549e3          	bltz	a0,206 <ls+0x152>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 258:	dc040513          	addi	a0,s0,-576
 25c:	00000097          	auipc	ra,0x0
 260:	da4080e7          	jalr	-604(ra) # 0 <fmtname>
 264:	85aa                	mv	a1,a0
 266:	da843703          	ld	a4,-600(s0)
 26a:	d9c42683          	lw	a3,-612(s0)
 26e:	da041603          	lh	a2,-608(s0)
 272:	8552                	mv	a0,s4
 274:	00000097          	auipc	ra,0x0
 278:	68c080e7          	jalr	1676(ra) # 900 <printf>
 27c:	bf61                	j	214 <ls+0x160>

000000000000027e <main>:

int
main(int argc, char *argv[])
{
 27e:	1101                	addi	sp,sp,-32
 280:	ec06                	sd	ra,24(sp)
 282:	e822                	sd	s0,16(sp)
 284:	e426                	sd	s1,8(sp)
 286:	e04a                	sd	s2,0(sp)
 288:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 28a:	4785                	li	a5,1
 28c:	02a7d963          	bge	a5,a0,2be <main+0x40>
 290:	00858493          	addi	s1,a1,8
 294:	ffe5091b          	addiw	s2,a0,-2
 298:	1902                	slli	s2,s2,0x20
 29a:	02095913          	srli	s2,s2,0x20
 29e:	090e                	slli	s2,s2,0x3
 2a0:	05c1                	addi	a1,a1,16
 2a2:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 2a4:	6088                	ld	a0,0(s1)
 2a6:	00000097          	auipc	ra,0x0
 2aa:	e0e080e7          	jalr	-498(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 2ae:	04a1                	addi	s1,s1,8
 2b0:	ff249ae3          	bne	s1,s2,2a4 <main+0x26>
  exit(0);
 2b4:	4501                	li	a0,0
 2b6:	00000097          	auipc	ra,0x0
 2ba:	2aa080e7          	jalr	682(ra) # 560 <exit>
    ls(".");
 2be:	00001517          	auipc	a0,0x1
 2c2:	bba50513          	addi	a0,a0,-1094 # e78 <uthread_self+0x88>
 2c6:	00000097          	auipc	ra,0x0
 2ca:	dee080e7          	jalr	-530(ra) # b4 <ls>
    exit(0);
 2ce:	4501                	li	a0,0
 2d0:	00000097          	auipc	ra,0x0
 2d4:	290080e7          	jalr	656(ra) # 560 <exit>

00000000000002d8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e406                	sd	ra,8(sp)
 2dc:	e022                	sd	s0,0(sp)
 2de:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2e0:	00000097          	auipc	ra,0x0
 2e4:	f9e080e7          	jalr	-98(ra) # 27e <main>
  exit(0);
 2e8:	4501                	li	a0,0
 2ea:	00000097          	auipc	ra,0x0
 2ee:	276080e7          	jalr	630(ra) # 560 <exit>

00000000000002f2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2f8:	87aa                	mv	a5,a0
 2fa:	0585                	addi	a1,a1,1
 2fc:	0785                	addi	a5,a5,1
 2fe:	fff5c703          	lbu	a4,-1(a1)
 302:	fee78fa3          	sb	a4,-1(a5)
 306:	fb75                	bnez	a4,2fa <strcpy+0x8>
    ;
  return os;
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret

000000000000030e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 314:	00054783          	lbu	a5,0(a0)
 318:	cb91                	beqz	a5,32c <strcmp+0x1e>
 31a:	0005c703          	lbu	a4,0(a1)
 31e:	00f71763          	bne	a4,a5,32c <strcmp+0x1e>
    p++, q++;
 322:	0505                	addi	a0,a0,1
 324:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 326:	00054783          	lbu	a5,0(a0)
 32a:	fbe5                	bnez	a5,31a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 32c:	0005c503          	lbu	a0,0(a1)
}
 330:	40a7853b          	subw	a0,a5,a0
 334:	6422                	ld	s0,8(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <strlen>:

uint
strlen(const char *s)
{
 33a:	1141                	addi	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 340:	00054783          	lbu	a5,0(a0)
 344:	cf91                	beqz	a5,360 <strlen+0x26>
 346:	0505                	addi	a0,a0,1
 348:	87aa                	mv	a5,a0
 34a:	4685                	li	a3,1
 34c:	9e89                	subw	a3,a3,a0
 34e:	00f6853b          	addw	a0,a3,a5
 352:	0785                	addi	a5,a5,1
 354:	fff7c703          	lbu	a4,-1(a5)
 358:	fb7d                	bnez	a4,34e <strlen+0x14>
    ;
  return n;
}
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
  for(n = 0; s[n]; n++)
 360:	4501                	li	a0,0
 362:	bfe5                	j	35a <strlen+0x20>

0000000000000364 <memset>:

void*
memset(void *dst, int c, uint n)
{
 364:	1141                	addi	sp,sp,-16
 366:	e422                	sd	s0,8(sp)
 368:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 36a:	ca19                	beqz	a2,380 <memset+0x1c>
 36c:	87aa                	mv	a5,a0
 36e:	1602                	slli	a2,a2,0x20
 370:	9201                	srli	a2,a2,0x20
 372:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 376:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 37a:	0785                	addi	a5,a5,1
 37c:	fee79de3          	bne	a5,a4,376 <memset+0x12>
  }
  return dst;
}
 380:	6422                	ld	s0,8(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret

0000000000000386 <strchr>:

char*
strchr(const char *s, char c)
{
 386:	1141                	addi	sp,sp,-16
 388:	e422                	sd	s0,8(sp)
 38a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 38c:	00054783          	lbu	a5,0(a0)
 390:	cb99                	beqz	a5,3a6 <strchr+0x20>
    if(*s == c)
 392:	00f58763          	beq	a1,a5,3a0 <strchr+0x1a>
  for(; *s; s++)
 396:	0505                	addi	a0,a0,1
 398:	00054783          	lbu	a5,0(a0)
 39c:	fbfd                	bnez	a5,392 <strchr+0xc>
      return (char*)s;
  return 0;
 39e:	4501                	li	a0,0
}
 3a0:	6422                	ld	s0,8(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret
  return 0;
 3a6:	4501                	li	a0,0
 3a8:	bfe5                	j	3a0 <strchr+0x1a>

00000000000003aa <gets>:

char*
gets(char *buf, int max)
{
 3aa:	711d                	addi	sp,sp,-96
 3ac:	ec86                	sd	ra,88(sp)
 3ae:	e8a2                	sd	s0,80(sp)
 3b0:	e4a6                	sd	s1,72(sp)
 3b2:	e0ca                	sd	s2,64(sp)
 3b4:	fc4e                	sd	s3,56(sp)
 3b6:	f852                	sd	s4,48(sp)
 3b8:	f456                	sd	s5,40(sp)
 3ba:	f05a                	sd	s6,32(sp)
 3bc:	ec5e                	sd	s7,24(sp)
 3be:	1080                	addi	s0,sp,96
 3c0:	8baa                	mv	s7,a0
 3c2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c4:	892a                	mv	s2,a0
 3c6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3c8:	4aa9                	li	s5,10
 3ca:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3cc:	89a6                	mv	s3,s1
 3ce:	2485                	addiw	s1,s1,1
 3d0:	0344d863          	bge	s1,s4,400 <gets+0x56>
    cc = read(0, &c, 1);
 3d4:	4605                	li	a2,1
 3d6:	faf40593          	addi	a1,s0,-81
 3da:	4501                	li	a0,0
 3dc:	00000097          	auipc	ra,0x0
 3e0:	19c080e7          	jalr	412(ra) # 578 <read>
    if(cc < 1)
 3e4:	00a05e63          	blez	a0,400 <gets+0x56>
    buf[i++] = c;
 3e8:	faf44783          	lbu	a5,-81(s0)
 3ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3f0:	01578763          	beq	a5,s5,3fe <gets+0x54>
 3f4:	0905                	addi	s2,s2,1
 3f6:	fd679be3          	bne	a5,s6,3cc <gets+0x22>
  for(i=0; i+1 < max; ){
 3fa:	89a6                	mv	s3,s1
 3fc:	a011                	j	400 <gets+0x56>
 3fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 400:	99de                	add	s3,s3,s7
 402:	00098023          	sb	zero,0(s3)
  return buf;
}
 406:	855e                	mv	a0,s7
 408:	60e6                	ld	ra,88(sp)
 40a:	6446                	ld	s0,80(sp)
 40c:	64a6                	ld	s1,72(sp)
 40e:	6906                	ld	s2,64(sp)
 410:	79e2                	ld	s3,56(sp)
 412:	7a42                	ld	s4,48(sp)
 414:	7aa2                	ld	s5,40(sp)
 416:	7b02                	ld	s6,32(sp)
 418:	6be2                	ld	s7,24(sp)
 41a:	6125                	addi	sp,sp,96
 41c:	8082                	ret

000000000000041e <stat>:

int
stat(const char *n, struct stat *st)
{
 41e:	1101                	addi	sp,sp,-32
 420:	ec06                	sd	ra,24(sp)
 422:	e822                	sd	s0,16(sp)
 424:	e426                	sd	s1,8(sp)
 426:	e04a                	sd	s2,0(sp)
 428:	1000                	addi	s0,sp,32
 42a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 42c:	4581                	li	a1,0
 42e:	00000097          	auipc	ra,0x0
 432:	172080e7          	jalr	370(ra) # 5a0 <open>
  if(fd < 0)
 436:	02054563          	bltz	a0,460 <stat+0x42>
 43a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 43c:	85ca                	mv	a1,s2
 43e:	00000097          	auipc	ra,0x0
 442:	17a080e7          	jalr	378(ra) # 5b8 <fstat>
 446:	892a                	mv	s2,a0
  close(fd);
 448:	8526                	mv	a0,s1
 44a:	00000097          	auipc	ra,0x0
 44e:	13e080e7          	jalr	318(ra) # 588 <close>
  return r;
}
 452:	854a                	mv	a0,s2
 454:	60e2                	ld	ra,24(sp)
 456:	6442                	ld	s0,16(sp)
 458:	64a2                	ld	s1,8(sp)
 45a:	6902                	ld	s2,0(sp)
 45c:	6105                	addi	sp,sp,32
 45e:	8082                	ret
    return -1;
 460:	597d                	li	s2,-1
 462:	bfc5                	j	452 <stat+0x34>

0000000000000464 <atoi>:

int
atoi(const char *s)
{
 464:	1141                	addi	sp,sp,-16
 466:	e422                	sd	s0,8(sp)
 468:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 46a:	00054603          	lbu	a2,0(a0)
 46e:	fd06079b          	addiw	a5,a2,-48
 472:	0ff7f793          	andi	a5,a5,255
 476:	4725                	li	a4,9
 478:	02f76963          	bltu	a4,a5,4aa <atoi+0x46>
 47c:	86aa                	mv	a3,a0
  n = 0;
 47e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 480:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 482:	0685                	addi	a3,a3,1
 484:	0025179b          	slliw	a5,a0,0x2
 488:	9fa9                	addw	a5,a5,a0
 48a:	0017979b          	slliw	a5,a5,0x1
 48e:	9fb1                	addw	a5,a5,a2
 490:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 494:	0006c603          	lbu	a2,0(a3)
 498:	fd06071b          	addiw	a4,a2,-48
 49c:	0ff77713          	andi	a4,a4,255
 4a0:	fee5f1e3          	bgeu	a1,a4,482 <atoi+0x1e>
  return n;
}
 4a4:	6422                	ld	s0,8(sp)
 4a6:	0141                	addi	sp,sp,16
 4a8:	8082                	ret
  n = 0;
 4aa:	4501                	li	a0,0
 4ac:	bfe5                	j	4a4 <atoi+0x40>

00000000000004ae <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4ae:	1141                	addi	sp,sp,-16
 4b0:	e422                	sd	s0,8(sp)
 4b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4b4:	02b57463          	bgeu	a0,a1,4dc <memmove+0x2e>
    while(n-- > 0)
 4b8:	00c05f63          	blez	a2,4d6 <memmove+0x28>
 4bc:	1602                	slli	a2,a2,0x20
 4be:	9201                	srli	a2,a2,0x20
 4c0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 4c6:	0585                	addi	a1,a1,1
 4c8:	0705                	addi	a4,a4,1
 4ca:	fff5c683          	lbu	a3,-1(a1)
 4ce:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4d2:	fee79ae3          	bne	a5,a4,4c6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4d6:	6422                	ld	s0,8(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret
    dst += n;
 4dc:	00c50733          	add	a4,a0,a2
    src += n;
 4e0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4e2:	fec05ae3          	blez	a2,4d6 <memmove+0x28>
 4e6:	fff6079b          	addiw	a5,a2,-1
 4ea:	1782                	slli	a5,a5,0x20
 4ec:	9381                	srli	a5,a5,0x20
 4ee:	fff7c793          	not	a5,a5
 4f2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4f4:	15fd                	addi	a1,a1,-1
 4f6:	177d                	addi	a4,a4,-1
 4f8:	0005c683          	lbu	a3,0(a1)
 4fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 500:	fee79ae3          	bne	a5,a4,4f4 <memmove+0x46>
 504:	bfc9                	j	4d6 <memmove+0x28>

0000000000000506 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 506:	1141                	addi	sp,sp,-16
 508:	e422                	sd	s0,8(sp)
 50a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 50c:	ca05                	beqz	a2,53c <memcmp+0x36>
 50e:	fff6069b          	addiw	a3,a2,-1
 512:	1682                	slli	a3,a3,0x20
 514:	9281                	srli	a3,a3,0x20
 516:	0685                	addi	a3,a3,1
 518:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 51a:	00054783          	lbu	a5,0(a0)
 51e:	0005c703          	lbu	a4,0(a1)
 522:	00e79863          	bne	a5,a4,532 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 526:	0505                	addi	a0,a0,1
    p2++;
 528:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 52a:	fed518e3          	bne	a0,a3,51a <memcmp+0x14>
  }
  return 0;
 52e:	4501                	li	a0,0
 530:	a019                	j	536 <memcmp+0x30>
      return *p1 - *p2;
 532:	40e7853b          	subw	a0,a5,a4
}
 536:	6422                	ld	s0,8(sp)
 538:	0141                	addi	sp,sp,16
 53a:	8082                	ret
  return 0;
 53c:	4501                	li	a0,0
 53e:	bfe5                	j	536 <memcmp+0x30>

0000000000000540 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 540:	1141                	addi	sp,sp,-16
 542:	e406                	sd	ra,8(sp)
 544:	e022                	sd	s0,0(sp)
 546:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 548:	00000097          	auipc	ra,0x0
 54c:	f66080e7          	jalr	-154(ra) # 4ae <memmove>
}
 550:	60a2                	ld	ra,8(sp)
 552:	6402                	ld	s0,0(sp)
 554:	0141                	addi	sp,sp,16
 556:	8082                	ret

0000000000000558 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 558:	4885                	li	a7,1
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <exit>:
.global exit
exit:
 li a7, SYS_exit
 560:	4889                	li	a7,2
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <wait>:
.global wait
wait:
 li a7, SYS_wait
 568:	488d                	li	a7,3
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 570:	4891                	li	a7,4
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <read>:
.global read
read:
 li a7, SYS_read
 578:	4895                	li	a7,5
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <write>:
.global write
write:
 li a7, SYS_write
 580:	48c1                	li	a7,16
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <close>:
.global close
close:
 li a7, SYS_close
 588:	48d5                	li	a7,21
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <kill>:
.global kill
kill:
 li a7, SYS_kill
 590:	4899                	li	a7,6
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <exec>:
.global exec
exec:
 li a7, SYS_exec
 598:	489d                	li	a7,7
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <open>:
.global open
open:
 li a7, SYS_open
 5a0:	48bd                	li	a7,15
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5a8:	48c5                	li	a7,17
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5b0:	48c9                	li	a7,18
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5b8:	48a1                	li	a7,8
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <link>:
.global link
link:
 li a7, SYS_link
 5c0:	48cd                	li	a7,19
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5c8:	48d1                	li	a7,20
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5d0:	48a5                	li	a7,9
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5d8:	48a9                	li	a7,10
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5e0:	48ad                	li	a7,11
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5e8:	48b1                	li	a7,12
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5f0:	48b5                	li	a7,13
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5f8:	48b9                	li	a7,14
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
 600:	48d9                	li	a7,22
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
 608:	48dd                	li	a7,23
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <kthread_kill>:
.global kthread_kill
kthread_kill:
 li a7, SYS_kthread_kill
 610:	48e1                	li	a7,24
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
 618:	48e5                	li	a7,25
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
 620:	48e9                	li	a7,26
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 628:	1101                	addi	sp,sp,-32
 62a:	ec06                	sd	ra,24(sp)
 62c:	e822                	sd	s0,16(sp)
 62e:	1000                	addi	s0,sp,32
 630:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 634:	4605                	li	a2,1
 636:	fef40593          	addi	a1,s0,-17
 63a:	00000097          	auipc	ra,0x0
 63e:	f46080e7          	jalr	-186(ra) # 580 <write>
}
 642:	60e2                	ld	ra,24(sp)
 644:	6442                	ld	s0,16(sp)
 646:	6105                	addi	sp,sp,32
 648:	8082                	ret

000000000000064a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 64a:	7139                	addi	sp,sp,-64
 64c:	fc06                	sd	ra,56(sp)
 64e:	f822                	sd	s0,48(sp)
 650:	f426                	sd	s1,40(sp)
 652:	f04a                	sd	s2,32(sp)
 654:	ec4e                	sd	s3,24(sp)
 656:	0080                	addi	s0,sp,64
 658:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 65a:	c299                	beqz	a3,660 <printint+0x16>
 65c:	0805c863          	bltz	a1,6ec <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 660:	2581                	sext.w	a1,a1
  neg = 0;
 662:	4881                	li	a7,0
 664:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 668:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 66a:	2601                	sext.w	a2,a2
 66c:	00001517          	auipc	a0,0x1
 670:	81c50513          	addi	a0,a0,-2020 # e88 <digits>
 674:	883a                	mv	a6,a4
 676:	2705                	addiw	a4,a4,1
 678:	02c5f7bb          	remuw	a5,a1,a2
 67c:	1782                	slli	a5,a5,0x20
 67e:	9381                	srli	a5,a5,0x20
 680:	97aa                	add	a5,a5,a0
 682:	0007c783          	lbu	a5,0(a5)
 686:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 68a:	0005879b          	sext.w	a5,a1
 68e:	02c5d5bb          	divuw	a1,a1,a2
 692:	0685                	addi	a3,a3,1
 694:	fec7f0e3          	bgeu	a5,a2,674 <printint+0x2a>
  if(neg)
 698:	00088b63          	beqz	a7,6ae <printint+0x64>
    buf[i++] = '-';
 69c:	fd040793          	addi	a5,s0,-48
 6a0:	973e                	add	a4,a4,a5
 6a2:	02d00793          	li	a5,45
 6a6:	fef70823          	sb	a5,-16(a4)
 6aa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6ae:	02e05863          	blez	a4,6de <printint+0x94>
 6b2:	fc040793          	addi	a5,s0,-64
 6b6:	00e78933          	add	s2,a5,a4
 6ba:	fff78993          	addi	s3,a5,-1
 6be:	99ba                	add	s3,s3,a4
 6c0:	377d                	addiw	a4,a4,-1
 6c2:	1702                	slli	a4,a4,0x20
 6c4:	9301                	srli	a4,a4,0x20
 6c6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6ca:	fff94583          	lbu	a1,-1(s2)
 6ce:	8526                	mv	a0,s1
 6d0:	00000097          	auipc	ra,0x0
 6d4:	f58080e7          	jalr	-168(ra) # 628 <putc>
  while(--i >= 0)
 6d8:	197d                	addi	s2,s2,-1
 6da:	ff3918e3          	bne	s2,s3,6ca <printint+0x80>
}
 6de:	70e2                	ld	ra,56(sp)
 6e0:	7442                	ld	s0,48(sp)
 6e2:	74a2                	ld	s1,40(sp)
 6e4:	7902                	ld	s2,32(sp)
 6e6:	69e2                	ld	s3,24(sp)
 6e8:	6121                	addi	sp,sp,64
 6ea:	8082                	ret
    x = -xx;
 6ec:	40b005bb          	negw	a1,a1
    neg = 1;
 6f0:	4885                	li	a7,1
    x = -xx;
 6f2:	bf8d                	j	664 <printint+0x1a>

00000000000006f4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6f4:	7119                	addi	sp,sp,-128
 6f6:	fc86                	sd	ra,120(sp)
 6f8:	f8a2                	sd	s0,112(sp)
 6fa:	f4a6                	sd	s1,104(sp)
 6fc:	f0ca                	sd	s2,96(sp)
 6fe:	ecce                	sd	s3,88(sp)
 700:	e8d2                	sd	s4,80(sp)
 702:	e4d6                	sd	s5,72(sp)
 704:	e0da                	sd	s6,64(sp)
 706:	fc5e                	sd	s7,56(sp)
 708:	f862                	sd	s8,48(sp)
 70a:	f466                	sd	s9,40(sp)
 70c:	f06a                	sd	s10,32(sp)
 70e:	ec6e                	sd	s11,24(sp)
 710:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 712:	0005c903          	lbu	s2,0(a1)
 716:	18090f63          	beqz	s2,8b4 <vprintf+0x1c0>
 71a:	8aaa                	mv	s5,a0
 71c:	8b32                	mv	s6,a2
 71e:	00158493          	addi	s1,a1,1
  state = 0;
 722:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 724:	02500a13          	li	s4,37
      if(c == 'd'){
 728:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 72c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 730:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 734:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 738:	00000b97          	auipc	s7,0x0
 73c:	750b8b93          	addi	s7,s7,1872 # e88 <digits>
 740:	a839                	j	75e <vprintf+0x6a>
        putc(fd, c);
 742:	85ca                	mv	a1,s2
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	ee2080e7          	jalr	-286(ra) # 628 <putc>
 74e:	a019                	j	754 <vprintf+0x60>
    } else if(state == '%'){
 750:	01498f63          	beq	s3,s4,76e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 754:	0485                	addi	s1,s1,1
 756:	fff4c903          	lbu	s2,-1(s1)
 75a:	14090d63          	beqz	s2,8b4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 75e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 762:	fe0997e3          	bnez	s3,750 <vprintf+0x5c>
      if(c == '%'){
 766:	fd479ee3          	bne	a5,s4,742 <vprintf+0x4e>
        state = '%';
 76a:	89be                	mv	s3,a5
 76c:	b7e5                	j	754 <vprintf+0x60>
      if(c == 'd'){
 76e:	05878063          	beq	a5,s8,7ae <vprintf+0xba>
      } else if(c == 'l') {
 772:	05978c63          	beq	a5,s9,7ca <vprintf+0xd6>
      } else if(c == 'x') {
 776:	07a78863          	beq	a5,s10,7e6 <vprintf+0xf2>
      } else if(c == 'p') {
 77a:	09b78463          	beq	a5,s11,802 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 77e:	07300713          	li	a4,115
 782:	0ce78663          	beq	a5,a4,84e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 786:	06300713          	li	a4,99
 78a:	0ee78e63          	beq	a5,a4,886 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 78e:	11478863          	beq	a5,s4,89e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 792:	85d2                	mv	a1,s4
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	e92080e7          	jalr	-366(ra) # 628 <putc>
        putc(fd, c);
 79e:	85ca                	mv	a1,s2
 7a0:	8556                	mv	a0,s5
 7a2:	00000097          	auipc	ra,0x0
 7a6:	e86080e7          	jalr	-378(ra) # 628 <putc>
      }
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b765                	j	754 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7ae:	008b0913          	addi	s2,s6,8
 7b2:	4685                	li	a3,1
 7b4:	4629                	li	a2,10
 7b6:	000b2583          	lw	a1,0(s6)
 7ba:	8556                	mv	a0,s5
 7bc:	00000097          	auipc	ra,0x0
 7c0:	e8e080e7          	jalr	-370(ra) # 64a <printint>
 7c4:	8b4a                	mv	s6,s2
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	b771                	j	754 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ca:	008b0913          	addi	s2,s6,8
 7ce:	4681                	li	a3,0
 7d0:	4629                	li	a2,10
 7d2:	000b2583          	lw	a1,0(s6)
 7d6:	8556                	mv	a0,s5
 7d8:	00000097          	auipc	ra,0x0
 7dc:	e72080e7          	jalr	-398(ra) # 64a <printint>
 7e0:	8b4a                	mv	s6,s2
      state = 0;
 7e2:	4981                	li	s3,0
 7e4:	bf85                	j	754 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7e6:	008b0913          	addi	s2,s6,8
 7ea:	4681                	li	a3,0
 7ec:	4641                	li	a2,16
 7ee:	000b2583          	lw	a1,0(s6)
 7f2:	8556                	mv	a0,s5
 7f4:	00000097          	auipc	ra,0x0
 7f8:	e56080e7          	jalr	-426(ra) # 64a <printint>
 7fc:	8b4a                	mv	s6,s2
      state = 0;
 7fe:	4981                	li	s3,0
 800:	bf91                	j	754 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 802:	008b0793          	addi	a5,s6,8
 806:	f8f43423          	sd	a5,-120(s0)
 80a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 80e:	03000593          	li	a1,48
 812:	8556                	mv	a0,s5
 814:	00000097          	auipc	ra,0x0
 818:	e14080e7          	jalr	-492(ra) # 628 <putc>
  putc(fd, 'x');
 81c:	85ea                	mv	a1,s10
 81e:	8556                	mv	a0,s5
 820:	00000097          	auipc	ra,0x0
 824:	e08080e7          	jalr	-504(ra) # 628 <putc>
 828:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 82a:	03c9d793          	srli	a5,s3,0x3c
 82e:	97de                	add	a5,a5,s7
 830:	0007c583          	lbu	a1,0(a5)
 834:	8556                	mv	a0,s5
 836:	00000097          	auipc	ra,0x0
 83a:	df2080e7          	jalr	-526(ra) # 628 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 83e:	0992                	slli	s3,s3,0x4
 840:	397d                	addiw	s2,s2,-1
 842:	fe0914e3          	bnez	s2,82a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 846:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 84a:	4981                	li	s3,0
 84c:	b721                	j	754 <vprintf+0x60>
        s = va_arg(ap, char*);
 84e:	008b0993          	addi	s3,s6,8
 852:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 856:	02090163          	beqz	s2,878 <vprintf+0x184>
        while(*s != 0){
 85a:	00094583          	lbu	a1,0(s2)
 85e:	c9a1                	beqz	a1,8ae <vprintf+0x1ba>
          putc(fd, *s);
 860:	8556                	mv	a0,s5
 862:	00000097          	auipc	ra,0x0
 866:	dc6080e7          	jalr	-570(ra) # 628 <putc>
          s++;
 86a:	0905                	addi	s2,s2,1
        while(*s != 0){
 86c:	00094583          	lbu	a1,0(s2)
 870:	f9e5                	bnez	a1,860 <vprintf+0x16c>
        s = va_arg(ap, char*);
 872:	8b4e                	mv	s6,s3
      state = 0;
 874:	4981                	li	s3,0
 876:	bdf9                	j	754 <vprintf+0x60>
          s = "(null)";
 878:	00000917          	auipc	s2,0x0
 87c:	60890913          	addi	s2,s2,1544 # e80 <uthread_self+0x90>
        while(*s != 0){
 880:	02800593          	li	a1,40
 884:	bff1                	j	860 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 886:	008b0913          	addi	s2,s6,8
 88a:	000b4583          	lbu	a1,0(s6)
 88e:	8556                	mv	a0,s5
 890:	00000097          	auipc	ra,0x0
 894:	d98080e7          	jalr	-616(ra) # 628 <putc>
 898:	8b4a                	mv	s6,s2
      state = 0;
 89a:	4981                	li	s3,0
 89c:	bd65                	j	754 <vprintf+0x60>
        putc(fd, c);
 89e:	85d2                	mv	a1,s4
 8a0:	8556                	mv	a0,s5
 8a2:	00000097          	auipc	ra,0x0
 8a6:	d86080e7          	jalr	-634(ra) # 628 <putc>
      state = 0;
 8aa:	4981                	li	s3,0
 8ac:	b565                	j	754 <vprintf+0x60>
        s = va_arg(ap, char*);
 8ae:	8b4e                	mv	s6,s3
      state = 0;
 8b0:	4981                	li	s3,0
 8b2:	b54d                	j	754 <vprintf+0x60>
    }
  }
}
 8b4:	70e6                	ld	ra,120(sp)
 8b6:	7446                	ld	s0,112(sp)
 8b8:	74a6                	ld	s1,104(sp)
 8ba:	7906                	ld	s2,96(sp)
 8bc:	69e6                	ld	s3,88(sp)
 8be:	6a46                	ld	s4,80(sp)
 8c0:	6aa6                	ld	s5,72(sp)
 8c2:	6b06                	ld	s6,64(sp)
 8c4:	7be2                	ld	s7,56(sp)
 8c6:	7c42                	ld	s8,48(sp)
 8c8:	7ca2                	ld	s9,40(sp)
 8ca:	7d02                	ld	s10,32(sp)
 8cc:	6de2                	ld	s11,24(sp)
 8ce:	6109                	addi	sp,sp,128
 8d0:	8082                	ret

00000000000008d2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8d2:	715d                	addi	sp,sp,-80
 8d4:	ec06                	sd	ra,24(sp)
 8d6:	e822                	sd	s0,16(sp)
 8d8:	1000                	addi	s0,sp,32
 8da:	e010                	sd	a2,0(s0)
 8dc:	e414                	sd	a3,8(s0)
 8de:	e818                	sd	a4,16(s0)
 8e0:	ec1c                	sd	a5,24(s0)
 8e2:	03043023          	sd	a6,32(s0)
 8e6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8ea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8ee:	8622                	mv	a2,s0
 8f0:	00000097          	auipc	ra,0x0
 8f4:	e04080e7          	jalr	-508(ra) # 6f4 <vprintf>
}
 8f8:	60e2                	ld	ra,24(sp)
 8fa:	6442                	ld	s0,16(sp)
 8fc:	6161                	addi	sp,sp,80
 8fe:	8082                	ret

0000000000000900 <printf>:

void
printf(const char *fmt, ...)
{
 900:	711d                	addi	sp,sp,-96
 902:	ec06                	sd	ra,24(sp)
 904:	e822                	sd	s0,16(sp)
 906:	1000                	addi	s0,sp,32
 908:	e40c                	sd	a1,8(s0)
 90a:	e810                	sd	a2,16(s0)
 90c:	ec14                	sd	a3,24(s0)
 90e:	f018                	sd	a4,32(s0)
 910:	f41c                	sd	a5,40(s0)
 912:	03043823          	sd	a6,48(s0)
 916:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 91a:	00840613          	addi	a2,s0,8
 91e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 922:	85aa                	mv	a1,a0
 924:	4505                	li	a0,1
 926:	00000097          	auipc	ra,0x0
 92a:	dce080e7          	jalr	-562(ra) # 6f4 <vprintf>
}
 92e:	60e2                	ld	ra,24(sp)
 930:	6442                	ld	s0,16(sp)
 932:	6125                	addi	sp,sp,96
 934:	8082                	ret

0000000000000936 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 936:	1141                	addi	sp,sp,-16
 938:	e422                	sd	s0,8(sp)
 93a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 93c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 940:	00000797          	auipc	a5,0x0
 944:	6c07b783          	ld	a5,1728(a5) # 1000 <freep>
 948:	a805                	j	978 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 94a:	4618                	lw	a4,8(a2)
 94c:	9db9                	addw	a1,a1,a4
 94e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 952:	6398                	ld	a4,0(a5)
 954:	6318                	ld	a4,0(a4)
 956:	fee53823          	sd	a4,-16(a0)
 95a:	a091                	j	99e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 95c:	ff852703          	lw	a4,-8(a0)
 960:	9e39                	addw	a2,a2,a4
 962:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 964:	ff053703          	ld	a4,-16(a0)
 968:	e398                	sd	a4,0(a5)
 96a:	a099                	j	9b0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 96c:	6398                	ld	a4,0(a5)
 96e:	00e7e463          	bltu	a5,a4,976 <free+0x40>
 972:	00e6ea63          	bltu	a3,a4,986 <free+0x50>
{
 976:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 978:	fed7fae3          	bgeu	a5,a3,96c <free+0x36>
 97c:	6398                	ld	a4,0(a5)
 97e:	00e6e463          	bltu	a3,a4,986 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 982:	fee7eae3          	bltu	a5,a4,976 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 986:	ff852583          	lw	a1,-8(a0)
 98a:	6390                	ld	a2,0(a5)
 98c:	02059713          	slli	a4,a1,0x20
 990:	9301                	srli	a4,a4,0x20
 992:	0712                	slli	a4,a4,0x4
 994:	9736                	add	a4,a4,a3
 996:	fae60ae3          	beq	a2,a4,94a <free+0x14>
    bp->s.ptr = p->s.ptr;
 99a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 99e:	4790                	lw	a2,8(a5)
 9a0:	02061713          	slli	a4,a2,0x20
 9a4:	9301                	srli	a4,a4,0x20
 9a6:	0712                	slli	a4,a4,0x4
 9a8:	973e                	add	a4,a4,a5
 9aa:	fae689e3          	beq	a3,a4,95c <free+0x26>
  } else
    p->s.ptr = bp;
 9ae:	e394                	sd	a3,0(a5)
  freep = p;
 9b0:	00000717          	auipc	a4,0x0
 9b4:	64f73823          	sd	a5,1616(a4) # 1000 <freep>
}
 9b8:	6422                	ld	s0,8(sp)
 9ba:	0141                	addi	sp,sp,16
 9bc:	8082                	ret

00000000000009be <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9be:	7139                	addi	sp,sp,-64
 9c0:	fc06                	sd	ra,56(sp)
 9c2:	f822                	sd	s0,48(sp)
 9c4:	f426                	sd	s1,40(sp)
 9c6:	f04a                	sd	s2,32(sp)
 9c8:	ec4e                	sd	s3,24(sp)
 9ca:	e852                	sd	s4,16(sp)
 9cc:	e456                	sd	s5,8(sp)
 9ce:	e05a                	sd	s6,0(sp)
 9d0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9d2:	02051493          	slli	s1,a0,0x20
 9d6:	9081                	srli	s1,s1,0x20
 9d8:	04bd                	addi	s1,s1,15
 9da:	8091                	srli	s1,s1,0x4
 9dc:	0014899b          	addiw	s3,s1,1
 9e0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9e2:	00000517          	auipc	a0,0x0
 9e6:	61e53503          	ld	a0,1566(a0) # 1000 <freep>
 9ea:	c515                	beqz	a0,a16 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ee:	4798                	lw	a4,8(a5)
 9f0:	02977f63          	bgeu	a4,s1,a2e <malloc+0x70>
 9f4:	8a4e                	mv	s4,s3
 9f6:	0009871b          	sext.w	a4,s3
 9fa:	6685                	lui	a3,0x1
 9fc:	00d77363          	bgeu	a4,a3,a02 <malloc+0x44>
 a00:	6a05                	lui	s4,0x1
 a02:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a06:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a0a:	00000917          	auipc	s2,0x0
 a0e:	5f690913          	addi	s2,s2,1526 # 1000 <freep>
  if(p == (char*)-1)
 a12:	5afd                	li	s5,-1
 a14:	a88d                	j	a86 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a16:	00000797          	auipc	a5,0x0
 a1a:	61a78793          	addi	a5,a5,1562 # 1030 <base>
 a1e:	00000717          	auipc	a4,0x0
 a22:	5ef73123          	sd	a5,1506(a4) # 1000 <freep>
 a26:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a28:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a2c:	b7e1                	j	9f4 <malloc+0x36>
      if(p->s.size == nunits)
 a2e:	02e48b63          	beq	s1,a4,a64 <malloc+0xa6>
        p->s.size -= nunits;
 a32:	4137073b          	subw	a4,a4,s3
 a36:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a38:	1702                	slli	a4,a4,0x20
 a3a:	9301                	srli	a4,a4,0x20
 a3c:	0712                	slli	a4,a4,0x4
 a3e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a40:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a44:	00000717          	auipc	a4,0x0
 a48:	5aa73e23          	sd	a0,1468(a4) # 1000 <freep>
      return (void*)(p + 1);
 a4c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a50:	70e2                	ld	ra,56(sp)
 a52:	7442                	ld	s0,48(sp)
 a54:	74a2                	ld	s1,40(sp)
 a56:	7902                	ld	s2,32(sp)
 a58:	69e2                	ld	s3,24(sp)
 a5a:	6a42                	ld	s4,16(sp)
 a5c:	6aa2                	ld	s5,8(sp)
 a5e:	6b02                	ld	s6,0(sp)
 a60:	6121                	addi	sp,sp,64
 a62:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a64:	6398                	ld	a4,0(a5)
 a66:	e118                	sd	a4,0(a0)
 a68:	bff1                	j	a44 <malloc+0x86>
  hp->s.size = nu;
 a6a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a6e:	0541                	addi	a0,a0,16
 a70:	00000097          	auipc	ra,0x0
 a74:	ec6080e7          	jalr	-314(ra) # 936 <free>
  return freep;
 a78:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a7c:	d971                	beqz	a0,a50 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a7e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a80:	4798                	lw	a4,8(a5)
 a82:	fa9776e3          	bgeu	a4,s1,a2e <malloc+0x70>
    if(p == freep)
 a86:	00093703          	ld	a4,0(s2)
 a8a:	853e                	mv	a0,a5
 a8c:	fef719e3          	bne	a4,a5,a7e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a90:	8552                	mv	a0,s4
 a92:	00000097          	auipc	ra,0x0
 a96:	b56080e7          	jalr	-1194(ra) # 5e8 <sbrk>
  if(p == (char*)-1)
 a9a:	fd5518e3          	bne	a0,s5,a6a <malloc+0xac>
        return 0;
 a9e:	4501                	li	a0,0
 aa0:	bf45                	j	a50 <malloc+0x92>

0000000000000aa2 <uswtch>:
 aa2:	00153023          	sd	ra,0(a0)
 aa6:	00253423          	sd	sp,8(a0)
 aaa:	e900                	sd	s0,16(a0)
 aac:	ed04                	sd	s1,24(a0)
 aae:	03253023          	sd	s2,32(a0)
 ab2:	03353423          	sd	s3,40(a0)
 ab6:	03453823          	sd	s4,48(a0)
 aba:	03553c23          	sd	s5,56(a0)
 abe:	05653023          	sd	s6,64(a0)
 ac2:	05753423          	sd	s7,72(a0)
 ac6:	05853823          	sd	s8,80(a0)
 aca:	05953c23          	sd	s9,88(a0)
 ace:	07a53023          	sd	s10,96(a0)
 ad2:	07b53423          	sd	s11,104(a0)
 ad6:	0005b083          	ld	ra,0(a1)
 ada:	0085b103          	ld	sp,8(a1)
 ade:	6980                	ld	s0,16(a1)
 ae0:	6d84                	ld	s1,24(a1)
 ae2:	0205b903          	ld	s2,32(a1)
 ae6:	0285b983          	ld	s3,40(a1)
 aea:	0305ba03          	ld	s4,48(a1)
 aee:	0385ba83          	ld	s5,56(a1)
 af2:	0405bb03          	ld	s6,64(a1)
 af6:	0485bb83          	ld	s7,72(a1)
 afa:	0505bc03          	ld	s8,80(a1)
 afe:	0585bc83          	ld	s9,88(a1)
 b02:	0605bd03          	ld	s10,96(a1)
 b06:	0685bd83          	ld	s11,104(a1)
 b0a:	8082                	ret

0000000000000b0c <uthread_exit>:
    curr_thread = next_thread;
    uswtch(curr_context, next_context);

}

void uthread_exit(){
 b0c:	1141                	addi	sp,sp,-16
 b0e:	e406                	sd	ra,8(sp)
 b10:	e022                	sd	s0,0(sp)
 b12:	0800                	addi	s0,sp,16
    printf("in uthresd exit\n");
 b14:	00000517          	auipc	a0,0x0
 b18:	38c50513          	addi	a0,a0,908 # ea0 <digits+0x18>
 b1c:	00000097          	auipc	ra,0x0
 b20:	de4080e7          	jalr	-540(ra) # 900 <printf>
    // Change the state of the current thread to FREE
    curr_thread->state = FREE;
 b24:	00000517          	auipc	a0,0x0
 b28:	4e453503          	ld	a0,1252(a0) # 1008 <curr_thread>
 b2c:	6785                	lui	a5,0x1
 b2e:	97aa                	add	a5,a5,a0
 b30:	fa07a223          	sw	zero,-92(a5) # fa4 <digits+0x11c>
    // Find another runnable thread to switch to (make sure its not the current_thread)
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 b34:	411c                	lw	a5,0(a0)
 b36:	2785                	addiw	a5,a5,1
 b38:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 b3a:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 b3c:	4585                	li	a1,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 b3e:	00000617          	auipc	a2,0x0
 b42:	57260613          	addi	a2,a2,1394 # 10b0 <uthreads_arr>
 b46:	6805                	lui	a6,0x1
 b48:	4889                	li	a7,2
 b4a:	a819                	j	b60 <uthread_exit+0x54>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 b4c:	2785                	addiw	a5,a5,1
 b4e:	41f7d71b          	sraiw	a4,a5,0x1f
 b52:	01e7571b          	srliw	a4,a4,0x1e
 b56:	9fb9                	addw	a5,a5,a4
 b58:	8b8d                	andi	a5,a5,3
 b5a:	9f99                	subw	a5,a5,a4
 b5c:	36fd                	addiw	a3,a3,-1
 b5e:	ca9d                	beqz	a3,b94 <uthread_exit+0x88>
        if (uthreads_arr[i].state == RUNNABLE &&
 b60:	00779713          	slli	a4,a5,0x7
 b64:	973e                	add	a4,a4,a5
 b66:	0716                	slli	a4,a4,0x5
 b68:	9732                	add	a4,a4,a2
 b6a:	9742                	add	a4,a4,a6
 b6c:	fa472703          	lw	a4,-92(a4)
 b70:	fd171ee3          	bne	a4,a7,b4c <uthread_exit+0x40>
            uthreads_arr[i].priority > max_priority) {
 b74:	00779713          	slli	a4,a5,0x7
 b78:	973e                	add	a4,a4,a5
 b7a:	0716                	slli	a4,a4,0x5
 b7c:	9732                	add	a4,a4,a2
 b7e:	9742                	add	a4,a4,a6
 b80:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 b82:	fce375e3          	bgeu	t1,a4,b4c <uthread_exit+0x40>
            next_thread = &uthreads_arr[i];
 b86:	00779593          	slli	a1,a5,0x7
 b8a:	95be                	add	a1,a1,a5
 b8c:	0596                	slli	a1,a1,0x5
 b8e:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 b90:	833a                	mv	t1,a4
 b92:	bf6d                	j	b4c <uthread_exit+0x40>
        }
    }
    if (next_thread == (struct uthread *) 1) {
 b94:	4785                	li	a5,1
 b96:	02f58863          	beq	a1,a5,bc6 <uthread_exit+0xba>
        exit(0);  // Exit the process if there are no more runnable threads
    }
    // Switch to the next thread
    struct context *curr_context = &curr_thread->context;
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 b9a:	6785                	lui	a5,0x1
 b9c:	00f58733          	add	a4,a1,a5
 ba0:	4685                	li	a3,1
 ba2:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 ba6:	00000717          	auipc	a4,0x0
 baa:	46b73123          	sd	a1,1122(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 bae:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x120>
    uswtch(curr_context, next_context);
 bb2:	95be                	add	a1,a1,a5
 bb4:	953e                	add	a0,a0,a5
 bb6:	00000097          	auipc	ra,0x0
 bba:	eec080e7          	jalr	-276(ra) # aa2 <uswtch>
}
 bbe:	60a2                	ld	ra,8(sp)
 bc0:	6402                	ld	s0,0(sp)
 bc2:	0141                	addi	sp,sp,16
 bc4:	8082                	ret
        exit(0);  // Exit the process if there are no more runnable threads
 bc6:	4501                	li	a0,0
 bc8:	00000097          	auipc	ra,0x0
 bcc:	998080e7          	jalr	-1640(ra) # 560 <exit>

0000000000000bd0 <uthread_create>:
int uthread_create(void (*start_func)(), enum sched_priority priority) {
 bd0:	1141                	addi	sp,sp,-16
 bd2:	e422                	sd	s0,8(sp)
 bd4:	0800                	addi	s0,sp,16
    for (i = 0; i < MAX_UTHREADS; i++) {
 bd6:	00001717          	auipc	a4,0x1
 bda:	47e70713          	addi	a4,a4,1150 # 2054 <uthreads_arr+0xfa4>
 bde:	4781                	li	a5,0
 be0:	6605                	lui	a2,0x1
 be2:	02060613          	addi	a2,a2,32 # 1020 <buf.0>
 be6:	4811                	li	a6,4
        if (uthreads_arr[i].state == FREE) {
 be8:	4314                	lw	a3,0(a4)
 bea:	c699                	beqz	a3,bf8 <uthread_create+0x28>
    for (i = 0; i < MAX_UTHREADS; i++) {
 bec:	2785                	addiw	a5,a5,1
 bee:	9732                	add	a4,a4,a2
 bf0:	ff079ce3          	bne	a5,a6,be8 <uthread_create+0x18>
        return -1;
 bf4:	557d                	li	a0,-1
 bf6:	a0b9                	j	c44 <uthread_create+0x74>
            curr_thread = &uthreads_arr[i];
 bf8:	00779713          	slli	a4,a5,0x7
 bfc:	973e                	add	a4,a4,a5
 bfe:	0716                	slli	a4,a4,0x5
 c00:	00000697          	auipc	a3,0x0
 c04:	4b068693          	addi	a3,a3,1200 # 10b0 <uthreads_arr>
 c08:	9736                	add	a4,a4,a3
 c0a:	00000697          	auipc	a3,0x0
 c0e:	3ee6bf23          	sd	a4,1022(a3) # 1008 <curr_thread>
    if (i >= MAX_UTHREADS) {
 c12:	468d                	li	a3,3
 c14:	02f6cb63          	blt	a3,a5,c4a <uthread_create+0x7a>
    curr_thread->id = i; 
 c18:	c31c                	sw	a5,0(a4)
    curr_thread->priority = priority;
 c1a:	6685                	lui	a3,0x1
 c1c:	00d707b3          	add	a5,a4,a3
 c20:	cf8c                	sw	a1,24(a5)
    curr_thread->context.ra = (uint64) start_func;
 c22:	faa7b423          	sd	a0,-88(a5)
    curr_thread->context.sp = (uint64) &curr_thread->ustack[STACK_SIZE];
 c26:	fa468693          	addi	a3,a3,-92 # fa4 <digits+0x11c>
 c2a:	9736                	add	a4,a4,a3
 c2c:	fae7b823          	sd	a4,-80(a5)
    curr_thread->ustack[STACK_SIZE - 1] = (uint64) uthread_exit; // Return address to uthread_exit
 c30:	00000717          	auipc	a4,0x0
 c34:	edc70713          	addi	a4,a4,-292 # b0c <uthread_exit>
 c38:	fae781a3          	sb	a4,-93(a5)
    curr_thread->state = RUNNABLE;
 c3c:	4709                	li	a4,2
 c3e:	fae7a223          	sw	a4,-92(a5)
     return 0;
 c42:	4501                	li	a0,0
}
 c44:	6422                	ld	s0,8(sp)
 c46:	0141                	addi	sp,sp,16
 c48:	8082                	ret
        return -1;
 c4a:	557d                	li	a0,-1
 c4c:	bfe5                	j	c44 <uthread_create+0x74>

0000000000000c4e <uthread_yield>:
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 c4e:	00000517          	auipc	a0,0x0
 c52:	3ba53503          	ld	a0,954(a0) # 1008 <curr_thread>
 c56:	411c                	lw	a5,0(a0)
 c58:	2785                	addiw	a5,a5,1
 c5a:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 c5c:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 c5e:	4585                	li	a1,1
        if (uthreads_arr[i].state == RUNNABLE &&
 c60:	00000617          	auipc	a2,0x0
 c64:	45060613          	addi	a2,a2,1104 # 10b0 <uthreads_arr>
 c68:	6805                	lui	a6,0x1
 c6a:	4889                	li	a7,2
 c6c:	a819                	j	c82 <uthread_yield+0x34>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 c6e:	2785                	addiw	a5,a5,1
 c70:	41f7d71b          	sraiw	a4,a5,0x1f
 c74:	01e7571b          	srliw	a4,a4,0x1e
 c78:	9fb9                	addw	a5,a5,a4
 c7a:	8b8d                	andi	a5,a5,3
 c7c:	9f99                	subw	a5,a5,a4
 c7e:	36fd                	addiw	a3,a3,-1
 c80:	ca9d                	beqz	a3,cb6 <uthread_yield+0x68>
        if (uthreads_arr[i].state == RUNNABLE &&
 c82:	00779713          	slli	a4,a5,0x7
 c86:	973e                	add	a4,a4,a5
 c88:	0716                	slli	a4,a4,0x5
 c8a:	9732                	add	a4,a4,a2
 c8c:	9742                	add	a4,a4,a6
 c8e:	fa472703          	lw	a4,-92(a4)
 c92:	fd171ee3          	bne	a4,a7,c6e <uthread_yield+0x20>
            uthreads_arr[i].priority > max_priority) {
 c96:	00779713          	slli	a4,a5,0x7
 c9a:	973e                	add	a4,a4,a5
 c9c:	0716                	slli	a4,a4,0x5
 c9e:	9732                	add	a4,a4,a2
 ca0:	9742                	add	a4,a4,a6
 ca2:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 ca4:	fce375e3          	bgeu	t1,a4,c6e <uthread_yield+0x20>
            next_thread = &uthreads_arr[i];
 ca8:	00779593          	slli	a1,a5,0x7
 cac:	95be                	add	a1,a1,a5
 cae:	0596                	slli	a1,a1,0x5
 cb0:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 cb2:	833a                	mv	t1,a4
 cb4:	bf6d                	j	c6e <uthread_yield+0x20>
    if (next_thread == (struct uthread *) 1) {
 cb6:	4785                	li	a5,1
 cb8:	04f58163          	beq	a1,a5,cfa <uthread_yield+0xac>
void uthread_yield() {
 cbc:	1141                	addi	sp,sp,-16
 cbe:	e406                	sd	ra,8(sp)
 cc0:	e022                	sd	s0,0(sp)
 cc2:	0800                	addi	s0,sp,16
    curr_thread->state = RUNNABLE;
 cc4:	6785                	lui	a5,0x1
 cc6:	00f50733          	add	a4,a0,a5
 cca:	4689                	li	a3,2
 ccc:	fad72223          	sw	a3,-92(a4)
    next_thread->state = RUNNING;
 cd0:	00f58733          	add	a4,a1,a5
 cd4:	4685                	li	a3,1
 cd6:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 cda:	00000717          	auipc	a4,0x0
 cde:	32b73723          	sd	a1,814(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 ce2:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x120>
    uswtch(curr_context, next_context);
 ce6:	95be                	add	a1,a1,a5
 ce8:	953e                	add	a0,a0,a5
 cea:	00000097          	auipc	ra,0x0
 cee:	db8080e7          	jalr	-584(ra) # aa2 <uswtch>
}
 cf2:	60a2                	ld	ra,8(sp)
 cf4:	6402                	ld	s0,0(sp)
 cf6:	0141                	addi	sp,sp,16
 cf8:	8082                	ret
 cfa:	8082                	ret

0000000000000cfc <uthread_set_priority>:

enum sched_priority uthread_set_priority(enum sched_priority priority){
 cfc:	1141                	addi	sp,sp,-16
 cfe:	e422                	sd	s0,8(sp)
 d00:	0800                	addi	s0,sp,16
    enum sched_priority to_return =curr_thread->priority;
 d02:	00000797          	auipc	a5,0x0
 d06:	3067b783          	ld	a5,774(a5) # 1008 <curr_thread>
 d0a:	6705                	lui	a4,0x1
 d0c:	97ba                	add	a5,a5,a4
 d0e:	4f98                	lw	a4,24(a5)
    curr_thread->priority=priority;
 d10:	cf88                	sw	a0,24(a5)
    return to_return;
}
 d12:	853a                	mv	a0,a4
 d14:	6422                	ld	s0,8(sp)
 d16:	0141                	addi	sp,sp,16
 d18:	8082                	ret

0000000000000d1a <uthread_get_priority>:

enum sched_priority uthread_get_priority(){
 d1a:	1141                	addi	sp,sp,-16
 d1c:	e422                	sd	s0,8(sp)
 d1e:	0800                	addi	s0,sp,16
    return curr_thread->priority;
 d20:	00000797          	auipc	a5,0x0
 d24:	2e87b783          	ld	a5,744(a5) # 1008 <curr_thread>
 d28:	6705                	lui	a4,0x1
 d2a:	97ba                	add	a5,a5,a4
}
 d2c:	4f88                	lw	a0,24(a5)
 d2e:	6422                	ld	s0,8(sp)
 d30:	0141                	addi	sp,sp,16
 d32:	8082                	ret

0000000000000d34 <uthread_start_all>:

int uthread_start_all(){
    if (started){
 d34:	00000797          	auipc	a5,0x0
 d38:	2dc7a783          	lw	a5,732(a5) # 1010 <started>
 d3c:	ebc5                	bnez	a5,dec <uthread_start_all+0xb8>
int uthread_start_all(){
 d3e:	1141                	addi	sp,sp,-16
 d40:	e406                	sd	ra,8(sp)
 d42:	e022                	sd	s0,0(sp)
 d44:	0800                	addi	s0,sp,16
        return -1;
    }
    started=1;
 d46:	4785                	li	a5,1
 d48:	00000717          	auipc	a4,0x0
 d4c:	2cf72423          	sw	a5,712(a4) # 1010 <started>
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 d50:	00000797          	auipc	a5,0x0
 d54:	2b87b783          	ld	a5,696(a5) # 1008 <curr_thread>
 d58:	439c                	lw	a5,0(a5)
 d5a:	2785                	addiw	a5,a5,1
 d5c:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 d5e:	4881                	li	a7,0
    struct uthread *next_thread = (struct uthread *) 1;
 d60:	4605                	li	a2,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 d62:	00000597          	auipc	a1,0x0
 d66:	34e58593          	addi	a1,a1,846 # 10b0 <uthreads_arr>
 d6a:	6505                	lui	a0,0x1
 d6c:	4809                	li	a6,2
 d6e:	a819                	j	d84 <uthread_start_all+0x50>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 d70:	2785                	addiw	a5,a5,1
 d72:	41f7d71b          	sraiw	a4,a5,0x1f
 d76:	01e7571b          	srliw	a4,a4,0x1e
 d7a:	9fb9                	addw	a5,a5,a4
 d7c:	8b8d                	andi	a5,a5,3
 d7e:	9f99                	subw	a5,a5,a4
 d80:	36fd                	addiw	a3,a3,-1
 d82:	ca9d                	beqz	a3,db8 <uthread_start_all+0x84>
        if (uthreads_arr[i].state == RUNNABLE &&
 d84:	00779713          	slli	a4,a5,0x7
 d88:	973e                	add	a4,a4,a5
 d8a:	0716                	slli	a4,a4,0x5
 d8c:	972e                	add	a4,a4,a1
 d8e:	972a                	add	a4,a4,a0
 d90:	fa472703          	lw	a4,-92(a4)
 d94:	fd071ee3          	bne	a4,a6,d70 <uthread_start_all+0x3c>
            uthreads_arr[i].priority > max_priority) {
 d98:	00779713          	slli	a4,a5,0x7
 d9c:	973e                	add	a4,a4,a5
 d9e:	0716                	slli	a4,a4,0x5
 da0:	972e                	add	a4,a4,a1
 da2:	972a                	add	a4,a4,a0
 da4:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 da6:	fce8f5e3          	bgeu	a7,a4,d70 <uthread_start_all+0x3c>
            next_thread = &uthreads_arr[i];
 daa:	00779613          	slli	a2,a5,0x7
 dae:	963e                	add	a2,a2,a5
 db0:	0616                	slli	a2,a2,0x5
 db2:	962e                	add	a2,a2,a1
            max_priority = uthreads_arr[i].priority;
 db4:	88ba                	mv	a7,a4
 db6:	bf6d                	j	d70 <uthread_start_all+0x3c>
        }
    }
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 db8:	6585                	lui	a1,0x1
 dba:	00b607b3          	add	a5,a2,a1
 dbe:	4705                	li	a4,1
 dc0:	fae7a223          	sw	a4,-92(a5)
    curr_thread = next_thread;
 dc4:	00000797          	auipc	a5,0x0
 dc8:	24c7b223          	sd	a2,580(a5) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 dcc:	fa858593          	addi	a1,a1,-88 # fa8 <digits+0x120>
    uswtch(&garbageContext,next_context);
 dd0:	95b2                	add	a1,a1,a2
 dd2:	00000517          	auipc	a0,0x0
 dd6:	26e50513          	addi	a0,a0,622 # 1040 <garbageContext>
 dda:	00000097          	auipc	ra,0x0
 dde:	cc8080e7          	jalr	-824(ra) # aa2 <uswtch>

    return -1;
}
 de2:	557d                	li	a0,-1
 de4:	60a2                	ld	ra,8(sp)
 de6:	6402                	ld	s0,0(sp)
 de8:	0141                	addi	sp,sp,16
 dea:	8082                	ret
 dec:	557d                	li	a0,-1
 dee:	8082                	ret

0000000000000df0 <uthread_self>:

struct uthread* uthread_self(){
 df0:	1141                	addi	sp,sp,-16
 df2:	e422                	sd	s0,8(sp)
 df4:	0800                	addi	s0,sp,16
    return curr_thread;
 df6:	00000517          	auipc	a0,0x0
 dfa:	21253503          	ld	a0,530(a0) # 1008 <curr_thread>
 dfe:	6422                	ld	s0,8(sp)
 e00:	0141                	addi	sp,sp,16
 e02:	8082                	ret
