
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	addi	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	addi	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	addi	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	addi	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
{
 11a:	715d                	addi	sp,sp,-80
 11c:	e486                	sd	ra,72(sp)
 11e:	e0a2                	sd	s0,64(sp)
 120:	fc26                	sd	s1,56(sp)
 122:	f84a                	sd	s2,48(sp)
 124:	f44e                	sd	s3,40(sp)
 126:	f052                	sd	s4,32(sp)
 128:	ec56                	sd	s5,24(sp)
 12a:	e85a                	sd	s6,16(sp)
 12c:	e45e                	sd	s7,8(sp)
 12e:	0880                	addi	s0,sp,80
 130:	89aa                	mv	s3,a0
 132:	8b2e                	mv	s6,a1
  m = 0;
 134:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 136:	3ff00b93          	li	s7,1023
 13a:	00001a97          	auipc	s5,0x1
 13e:	ee6a8a93          	addi	s5,s5,-282 # 1020 <buf>
 142:	a0a1                	j	18a <grep+0x70>
      p = q+1;
 144:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 148:	45a9                	li	a1,10
 14a:	854a                	mv	a0,s2
 14c:	00000097          	auipc	ra,0x0
 150:	200080e7          	jalr	512(ra) # 34c <strchr>
 154:	84aa                	mv	s1,a0
 156:	c905                	beqz	a0,186 <grep+0x6c>
      *q = 0;
 158:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 15c:	85ca                	mv	a1,s2
 15e:	854e                	mv	a0,s3
 160:	00000097          	auipc	ra,0x0
 164:	f6c080e7          	jalr	-148(ra) # cc <match>
 168:	dd71                	beqz	a0,144 <grep+0x2a>
        *q = '\n';
 16a:	47a9                	li	a5,10
 16c:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 170:	00148613          	addi	a2,s1,1
 174:	4126063b          	subw	a2,a2,s2
 178:	85ca                	mv	a1,s2
 17a:	4505                	li	a0,1
 17c:	00000097          	auipc	ra,0x0
 180:	3ca080e7          	jalr	970(ra) # 546 <write>
 184:	b7c1                	j	144 <grep+0x2a>
    if(m > 0){
 186:	03404563          	bgtz	s4,1b0 <grep+0x96>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 18a:	414b863b          	subw	a2,s7,s4
 18e:	014a85b3          	add	a1,s5,s4
 192:	855a                	mv	a0,s6
 194:	00000097          	auipc	ra,0x0
 198:	3aa080e7          	jalr	938(ra) # 53e <read>
 19c:	02a05663          	blez	a0,1c8 <grep+0xae>
    m += n;
 1a0:	00aa0a3b          	addw	s4,s4,a0
    buf[m] = '\0';
 1a4:	014a87b3          	add	a5,s5,s4
 1a8:	00078023          	sb	zero,0(a5)
    p = buf;
 1ac:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 1ae:	bf69                	j	148 <grep+0x2e>
      m -= p - buf;
 1b0:	415907b3          	sub	a5,s2,s5
 1b4:	40fa0a3b          	subw	s4,s4,a5
      memmove(buf, p, m);
 1b8:	8652                	mv	a2,s4
 1ba:	85ca                	mv	a1,s2
 1bc:	8556                	mv	a0,s5
 1be:	00000097          	auipc	ra,0x0
 1c2:	2b6080e7          	jalr	694(ra) # 474 <memmove>
 1c6:	b7d1                	j	18a <grep+0x70>
}
 1c8:	60a6                	ld	ra,72(sp)
 1ca:	6406                	ld	s0,64(sp)
 1cc:	74e2                	ld	s1,56(sp)
 1ce:	7942                	ld	s2,48(sp)
 1d0:	79a2                	ld	s3,40(sp)
 1d2:	7a02                	ld	s4,32(sp)
 1d4:	6ae2                	ld	s5,24(sp)
 1d6:	6b42                	ld	s6,16(sp)
 1d8:	6ba2                	ld	s7,8(sp)
 1da:	6161                	addi	sp,sp,80
 1dc:	8082                	ret

00000000000001de <main>:
{
 1de:	7139                	addi	sp,sp,-64
 1e0:	fc06                	sd	ra,56(sp)
 1e2:	f822                	sd	s0,48(sp)
 1e4:	f426                	sd	s1,40(sp)
 1e6:	f04a                	sd	s2,32(sp)
 1e8:	ec4e                	sd	s3,24(sp)
 1ea:	e852                	sd	s4,16(sp)
 1ec:	e456                	sd	s5,8(sp)
 1ee:	0080                	addi	s0,sp,64
  if(argc <= 1){
 1f0:	4785                	li	a5,1
 1f2:	04a7de63          	bge	a5,a0,24e <main+0x70>
  pattern = argv[1];
 1f6:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1fa:	4789                	li	a5,2
 1fc:	06a7d763          	bge	a5,a0,26a <main+0x8c>
 200:	01058913          	addi	s2,a1,16
 204:	ffd5099b          	addiw	s3,a0,-3
 208:	1982                	slli	s3,s3,0x20
 20a:	0209d993          	srli	s3,s3,0x20
 20e:	098e                	slli	s3,s3,0x3
 210:	05e1                	addi	a1,a1,24
 212:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], 0)) < 0){
 214:	4581                	li	a1,0
 216:	00093503          	ld	a0,0(s2)
 21a:	00000097          	auipc	ra,0x0
 21e:	34c080e7          	jalr	844(ra) # 566 <open>
 222:	84aa                	mv	s1,a0
 224:	04054e63          	bltz	a0,280 <main+0xa2>
    grep(pattern, fd);
 228:	85aa                	mv	a1,a0
 22a:	8552                	mv	a0,s4
 22c:	00000097          	auipc	ra,0x0
 230:	eee080e7          	jalr	-274(ra) # 11a <grep>
    close(fd);
 234:	8526                	mv	a0,s1
 236:	00000097          	auipc	ra,0x0
 23a:	318080e7          	jalr	792(ra) # 54e <close>
  for(i = 2; i < argc; i++){
 23e:	0921                	addi	s2,s2,8
 240:	fd391ae3          	bne	s2,s3,214 <main+0x36>
  exit(0);
 244:	4501                	li	a0,0
 246:	00000097          	auipc	ra,0x0
 24a:	2e0080e7          	jalr	736(ra) # 526 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 24e:	00001597          	auipc	a1,0x1
 252:	b8258593          	addi	a1,a1,-1150 # dd0 <uthread_self+0x1a>
 256:	4509                	li	a0,2
 258:	00000097          	auipc	ra,0x0
 25c:	640080e7          	jalr	1600(ra) # 898 <fprintf>
    exit(1);
 260:	4505                	li	a0,1
 262:	00000097          	auipc	ra,0x0
 266:	2c4080e7          	jalr	708(ra) # 526 <exit>
    grep(pattern, 0);
 26a:	4581                	li	a1,0
 26c:	8552                	mv	a0,s4
 26e:	00000097          	auipc	ra,0x0
 272:	eac080e7          	jalr	-340(ra) # 11a <grep>
    exit(0);
 276:	4501                	li	a0,0
 278:	00000097          	auipc	ra,0x0
 27c:	2ae080e7          	jalr	686(ra) # 526 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 280:	00093583          	ld	a1,0(s2)
 284:	00001517          	auipc	a0,0x1
 288:	b6c50513          	addi	a0,a0,-1172 # df0 <uthread_self+0x3a>
 28c:	00000097          	auipc	ra,0x0
 290:	63a080e7          	jalr	1594(ra) # 8c6 <printf>
      exit(1);
 294:	4505                	li	a0,1
 296:	00000097          	auipc	ra,0x0
 29a:	290080e7          	jalr	656(ra) # 526 <exit>

000000000000029e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e406                	sd	ra,8(sp)
 2a2:	e022                	sd	s0,0(sp)
 2a4:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2a6:	00000097          	auipc	ra,0x0
 2aa:	f38080e7          	jalr	-200(ra) # 1de <main>
  exit(0);
 2ae:	4501                	li	a0,0
 2b0:	00000097          	auipc	ra,0x0
 2b4:	276080e7          	jalr	630(ra) # 526 <exit>

00000000000002b8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2be:	87aa                	mv	a5,a0
 2c0:	0585                	addi	a1,a1,1
 2c2:	0785                	addi	a5,a5,1
 2c4:	fff5c703          	lbu	a4,-1(a1)
 2c8:	fee78fa3          	sb	a4,-1(a5)
 2cc:	fb75                	bnez	a4,2c0 <strcpy+0x8>
    ;
  return os;
}
 2ce:	6422                	ld	s0,8(sp)
 2d0:	0141                	addi	sp,sp,16
 2d2:	8082                	ret

00000000000002d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2da:	00054783          	lbu	a5,0(a0)
 2de:	cb91                	beqz	a5,2f2 <strcmp+0x1e>
 2e0:	0005c703          	lbu	a4,0(a1)
 2e4:	00f71763          	bne	a4,a5,2f2 <strcmp+0x1e>
    p++, q++;
 2e8:	0505                	addi	a0,a0,1
 2ea:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2ec:	00054783          	lbu	a5,0(a0)
 2f0:	fbe5                	bnez	a5,2e0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2f2:	0005c503          	lbu	a0,0(a1)
}
 2f6:	40a7853b          	subw	a0,a5,a0
 2fa:	6422                	ld	s0,8(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret

0000000000000300 <strlen>:

uint
strlen(const char *s)
{
 300:	1141                	addi	sp,sp,-16
 302:	e422                	sd	s0,8(sp)
 304:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 306:	00054783          	lbu	a5,0(a0)
 30a:	cf91                	beqz	a5,326 <strlen+0x26>
 30c:	0505                	addi	a0,a0,1
 30e:	87aa                	mv	a5,a0
 310:	4685                	li	a3,1
 312:	9e89                	subw	a3,a3,a0
 314:	00f6853b          	addw	a0,a3,a5
 318:	0785                	addi	a5,a5,1
 31a:	fff7c703          	lbu	a4,-1(a5)
 31e:	fb7d                	bnez	a4,314 <strlen+0x14>
    ;
  return n;
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  for(n = 0; s[n]; n++)
 326:	4501                	li	a0,0
 328:	bfe5                	j	320 <strlen+0x20>

000000000000032a <memset>:

void*
memset(void *dst, int c, uint n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 330:	ca19                	beqz	a2,346 <memset+0x1c>
 332:	87aa                	mv	a5,a0
 334:	1602                	slli	a2,a2,0x20
 336:	9201                	srli	a2,a2,0x20
 338:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 33c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 340:	0785                	addi	a5,a5,1
 342:	fee79de3          	bne	a5,a4,33c <memset+0x12>
  }
  return dst;
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret

000000000000034c <strchr>:

char*
strchr(const char *s, char c)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  for(; *s; s++)
 352:	00054783          	lbu	a5,0(a0)
 356:	cb99                	beqz	a5,36c <strchr+0x20>
    if(*s == c)
 358:	00f58763          	beq	a1,a5,366 <strchr+0x1a>
  for(; *s; s++)
 35c:	0505                	addi	a0,a0,1
 35e:	00054783          	lbu	a5,0(a0)
 362:	fbfd                	bnez	a5,358 <strchr+0xc>
      return (char*)s;
  return 0;
 364:	4501                	li	a0,0
}
 366:	6422                	ld	s0,8(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret
  return 0;
 36c:	4501                	li	a0,0
 36e:	bfe5                	j	366 <strchr+0x1a>

0000000000000370 <gets>:

char*
gets(char *buf, int max)
{
 370:	711d                	addi	sp,sp,-96
 372:	ec86                	sd	ra,88(sp)
 374:	e8a2                	sd	s0,80(sp)
 376:	e4a6                	sd	s1,72(sp)
 378:	e0ca                	sd	s2,64(sp)
 37a:	fc4e                	sd	s3,56(sp)
 37c:	f852                	sd	s4,48(sp)
 37e:	f456                	sd	s5,40(sp)
 380:	f05a                	sd	s6,32(sp)
 382:	ec5e                	sd	s7,24(sp)
 384:	1080                	addi	s0,sp,96
 386:	8baa                	mv	s7,a0
 388:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 38a:	892a                	mv	s2,a0
 38c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 38e:	4aa9                	li	s5,10
 390:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 392:	89a6                	mv	s3,s1
 394:	2485                	addiw	s1,s1,1
 396:	0344d863          	bge	s1,s4,3c6 <gets+0x56>
    cc = read(0, &c, 1);
 39a:	4605                	li	a2,1
 39c:	faf40593          	addi	a1,s0,-81
 3a0:	4501                	li	a0,0
 3a2:	00000097          	auipc	ra,0x0
 3a6:	19c080e7          	jalr	412(ra) # 53e <read>
    if(cc < 1)
 3aa:	00a05e63          	blez	a0,3c6 <gets+0x56>
    buf[i++] = c;
 3ae:	faf44783          	lbu	a5,-81(s0)
 3b2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3b6:	01578763          	beq	a5,s5,3c4 <gets+0x54>
 3ba:	0905                	addi	s2,s2,1
 3bc:	fd679be3          	bne	a5,s6,392 <gets+0x22>
  for(i=0; i+1 < max; ){
 3c0:	89a6                	mv	s3,s1
 3c2:	a011                	j	3c6 <gets+0x56>
 3c4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3c6:	99de                	add	s3,s3,s7
 3c8:	00098023          	sb	zero,0(s3)
  return buf;
}
 3cc:	855e                	mv	a0,s7
 3ce:	60e6                	ld	ra,88(sp)
 3d0:	6446                	ld	s0,80(sp)
 3d2:	64a6                	ld	s1,72(sp)
 3d4:	6906                	ld	s2,64(sp)
 3d6:	79e2                	ld	s3,56(sp)
 3d8:	7a42                	ld	s4,48(sp)
 3da:	7aa2                	ld	s5,40(sp)
 3dc:	7b02                	ld	s6,32(sp)
 3de:	6be2                	ld	s7,24(sp)
 3e0:	6125                	addi	sp,sp,96
 3e2:	8082                	ret

00000000000003e4 <stat>:

int
stat(const char *n, struct stat *st)
{
 3e4:	1101                	addi	sp,sp,-32
 3e6:	ec06                	sd	ra,24(sp)
 3e8:	e822                	sd	s0,16(sp)
 3ea:	e426                	sd	s1,8(sp)
 3ec:	e04a                	sd	s2,0(sp)
 3ee:	1000                	addi	s0,sp,32
 3f0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3f2:	4581                	li	a1,0
 3f4:	00000097          	auipc	ra,0x0
 3f8:	172080e7          	jalr	370(ra) # 566 <open>
  if(fd < 0)
 3fc:	02054563          	bltz	a0,426 <stat+0x42>
 400:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 402:	85ca                	mv	a1,s2
 404:	00000097          	auipc	ra,0x0
 408:	17a080e7          	jalr	378(ra) # 57e <fstat>
 40c:	892a                	mv	s2,a0
  close(fd);
 40e:	8526                	mv	a0,s1
 410:	00000097          	auipc	ra,0x0
 414:	13e080e7          	jalr	318(ra) # 54e <close>
  return r;
}
 418:	854a                	mv	a0,s2
 41a:	60e2                	ld	ra,24(sp)
 41c:	6442                	ld	s0,16(sp)
 41e:	64a2                	ld	s1,8(sp)
 420:	6902                	ld	s2,0(sp)
 422:	6105                	addi	sp,sp,32
 424:	8082                	ret
    return -1;
 426:	597d                	li	s2,-1
 428:	bfc5                	j	418 <stat+0x34>

000000000000042a <atoi>:

int
atoi(const char *s)
{
 42a:	1141                	addi	sp,sp,-16
 42c:	e422                	sd	s0,8(sp)
 42e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 430:	00054603          	lbu	a2,0(a0)
 434:	fd06079b          	addiw	a5,a2,-48
 438:	0ff7f793          	andi	a5,a5,255
 43c:	4725                	li	a4,9
 43e:	02f76963          	bltu	a4,a5,470 <atoi+0x46>
 442:	86aa                	mv	a3,a0
  n = 0;
 444:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 446:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 448:	0685                	addi	a3,a3,1
 44a:	0025179b          	slliw	a5,a0,0x2
 44e:	9fa9                	addw	a5,a5,a0
 450:	0017979b          	slliw	a5,a5,0x1
 454:	9fb1                	addw	a5,a5,a2
 456:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 45a:	0006c603          	lbu	a2,0(a3)
 45e:	fd06071b          	addiw	a4,a2,-48
 462:	0ff77713          	andi	a4,a4,255
 466:	fee5f1e3          	bgeu	a1,a4,448 <atoi+0x1e>
  return n;
}
 46a:	6422                	ld	s0,8(sp)
 46c:	0141                	addi	sp,sp,16
 46e:	8082                	ret
  n = 0;
 470:	4501                	li	a0,0
 472:	bfe5                	j	46a <atoi+0x40>

0000000000000474 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 474:	1141                	addi	sp,sp,-16
 476:	e422                	sd	s0,8(sp)
 478:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 47a:	02b57463          	bgeu	a0,a1,4a2 <memmove+0x2e>
    while(n-- > 0)
 47e:	00c05f63          	blez	a2,49c <memmove+0x28>
 482:	1602                	slli	a2,a2,0x20
 484:	9201                	srli	a2,a2,0x20
 486:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 48a:	872a                	mv	a4,a0
      *dst++ = *src++;
 48c:	0585                	addi	a1,a1,1
 48e:	0705                	addi	a4,a4,1
 490:	fff5c683          	lbu	a3,-1(a1)
 494:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 498:	fee79ae3          	bne	a5,a4,48c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 49c:	6422                	ld	s0,8(sp)
 49e:	0141                	addi	sp,sp,16
 4a0:	8082                	ret
    dst += n;
 4a2:	00c50733          	add	a4,a0,a2
    src += n;
 4a6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4a8:	fec05ae3          	blez	a2,49c <memmove+0x28>
 4ac:	fff6079b          	addiw	a5,a2,-1
 4b0:	1782                	slli	a5,a5,0x20
 4b2:	9381                	srli	a5,a5,0x20
 4b4:	fff7c793          	not	a5,a5
 4b8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4ba:	15fd                	addi	a1,a1,-1
 4bc:	177d                	addi	a4,a4,-1
 4be:	0005c683          	lbu	a3,0(a1)
 4c2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4c6:	fee79ae3          	bne	a5,a4,4ba <memmove+0x46>
 4ca:	bfc9                	j	49c <memmove+0x28>

00000000000004cc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4cc:	1141                	addi	sp,sp,-16
 4ce:	e422                	sd	s0,8(sp)
 4d0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4d2:	ca05                	beqz	a2,502 <memcmp+0x36>
 4d4:	fff6069b          	addiw	a3,a2,-1
 4d8:	1682                	slli	a3,a3,0x20
 4da:	9281                	srli	a3,a3,0x20
 4dc:	0685                	addi	a3,a3,1
 4de:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4e0:	00054783          	lbu	a5,0(a0)
 4e4:	0005c703          	lbu	a4,0(a1)
 4e8:	00e79863          	bne	a5,a4,4f8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4ec:	0505                	addi	a0,a0,1
    p2++;
 4ee:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4f0:	fed518e3          	bne	a0,a3,4e0 <memcmp+0x14>
  }
  return 0;
 4f4:	4501                	li	a0,0
 4f6:	a019                	j	4fc <memcmp+0x30>
      return *p1 - *p2;
 4f8:	40e7853b          	subw	a0,a5,a4
}
 4fc:	6422                	ld	s0,8(sp)
 4fe:	0141                	addi	sp,sp,16
 500:	8082                	ret
  return 0;
 502:	4501                	li	a0,0
 504:	bfe5                	j	4fc <memcmp+0x30>

0000000000000506 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 506:	1141                	addi	sp,sp,-16
 508:	e406                	sd	ra,8(sp)
 50a:	e022                	sd	s0,0(sp)
 50c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 50e:	00000097          	auipc	ra,0x0
 512:	f66080e7          	jalr	-154(ra) # 474 <memmove>
}
 516:	60a2                	ld	ra,8(sp)
 518:	6402                	ld	s0,0(sp)
 51a:	0141                	addi	sp,sp,16
 51c:	8082                	ret

000000000000051e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 51e:	4885                	li	a7,1
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <exit>:
.global exit
exit:
 li a7, SYS_exit
 526:	4889                	li	a7,2
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <wait>:
.global wait
wait:
 li a7, SYS_wait
 52e:	488d                	li	a7,3
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 536:	4891                	li	a7,4
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <read>:
.global read
read:
 li a7, SYS_read
 53e:	4895                	li	a7,5
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <write>:
.global write
write:
 li a7, SYS_write
 546:	48c1                	li	a7,16
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <close>:
.global close
close:
 li a7, SYS_close
 54e:	48d5                	li	a7,21
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <kill>:
.global kill
kill:
 li a7, SYS_kill
 556:	4899                	li	a7,6
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <exec>:
.global exec
exec:
 li a7, SYS_exec
 55e:	489d                	li	a7,7
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <open>:
.global open
open:
 li a7, SYS_open
 566:	48bd                	li	a7,15
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 56e:	48c5                	li	a7,17
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 576:	48c9                	li	a7,18
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 57e:	48a1                	li	a7,8
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <link>:
.global link
link:
 li a7, SYS_link
 586:	48cd                	li	a7,19
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 58e:	48d1                	li	a7,20
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 596:	48a5                	li	a7,9
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <dup>:
.global dup
dup:
 li a7, SYS_dup
 59e:	48a9                	li	a7,10
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5a6:	48ad                	li	a7,11
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5ae:	48b1                	li	a7,12
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5b6:	48b5                	li	a7,13
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5be:	48b9                	li	a7,14
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
 5c6:	48d9                	li	a7,22
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
 5ce:	48dd                	li	a7,23
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <kthread_kill>:
.global kthread_kill
kthread_kill:
 li a7, SYS_kthread_kill
 5d6:	48e1                	li	a7,24
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
 5de:	48e5                	li	a7,25
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
 5e6:	48e9                	li	a7,26
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5ee:	1101                	addi	sp,sp,-32
 5f0:	ec06                	sd	ra,24(sp)
 5f2:	e822                	sd	s0,16(sp)
 5f4:	1000                	addi	s0,sp,32
 5f6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5fa:	4605                	li	a2,1
 5fc:	fef40593          	addi	a1,s0,-17
 600:	00000097          	auipc	ra,0x0
 604:	f46080e7          	jalr	-186(ra) # 546 <write>
}
 608:	60e2                	ld	ra,24(sp)
 60a:	6442                	ld	s0,16(sp)
 60c:	6105                	addi	sp,sp,32
 60e:	8082                	ret

0000000000000610 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 610:	7139                	addi	sp,sp,-64
 612:	fc06                	sd	ra,56(sp)
 614:	f822                	sd	s0,48(sp)
 616:	f426                	sd	s1,40(sp)
 618:	f04a                	sd	s2,32(sp)
 61a:	ec4e                	sd	s3,24(sp)
 61c:	0080                	addi	s0,sp,64
 61e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 620:	c299                	beqz	a3,626 <printint+0x16>
 622:	0805c863          	bltz	a1,6b2 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 626:	2581                	sext.w	a1,a1
  neg = 0;
 628:	4881                	li	a7,0
 62a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 62e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 630:	2601                	sext.w	a2,a2
 632:	00000517          	auipc	a0,0x0
 636:	7de50513          	addi	a0,a0,2014 # e10 <digits>
 63a:	883a                	mv	a6,a4
 63c:	2705                	addiw	a4,a4,1
 63e:	02c5f7bb          	remuw	a5,a1,a2
 642:	1782                	slli	a5,a5,0x20
 644:	9381                	srli	a5,a5,0x20
 646:	97aa                	add	a5,a5,a0
 648:	0007c783          	lbu	a5,0(a5)
 64c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 650:	0005879b          	sext.w	a5,a1
 654:	02c5d5bb          	divuw	a1,a1,a2
 658:	0685                	addi	a3,a3,1
 65a:	fec7f0e3          	bgeu	a5,a2,63a <printint+0x2a>
  if(neg)
 65e:	00088b63          	beqz	a7,674 <printint+0x64>
    buf[i++] = '-';
 662:	fd040793          	addi	a5,s0,-48
 666:	973e                	add	a4,a4,a5
 668:	02d00793          	li	a5,45
 66c:	fef70823          	sb	a5,-16(a4)
 670:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 674:	02e05863          	blez	a4,6a4 <printint+0x94>
 678:	fc040793          	addi	a5,s0,-64
 67c:	00e78933          	add	s2,a5,a4
 680:	fff78993          	addi	s3,a5,-1
 684:	99ba                	add	s3,s3,a4
 686:	377d                	addiw	a4,a4,-1
 688:	1702                	slli	a4,a4,0x20
 68a:	9301                	srli	a4,a4,0x20
 68c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 690:	fff94583          	lbu	a1,-1(s2)
 694:	8526                	mv	a0,s1
 696:	00000097          	auipc	ra,0x0
 69a:	f58080e7          	jalr	-168(ra) # 5ee <putc>
  while(--i >= 0)
 69e:	197d                	addi	s2,s2,-1
 6a0:	ff3918e3          	bne	s2,s3,690 <printint+0x80>
}
 6a4:	70e2                	ld	ra,56(sp)
 6a6:	7442                	ld	s0,48(sp)
 6a8:	74a2                	ld	s1,40(sp)
 6aa:	7902                	ld	s2,32(sp)
 6ac:	69e2                	ld	s3,24(sp)
 6ae:	6121                	addi	sp,sp,64
 6b0:	8082                	ret
    x = -xx;
 6b2:	40b005bb          	negw	a1,a1
    neg = 1;
 6b6:	4885                	li	a7,1
    x = -xx;
 6b8:	bf8d                	j	62a <printint+0x1a>

00000000000006ba <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6ba:	7119                	addi	sp,sp,-128
 6bc:	fc86                	sd	ra,120(sp)
 6be:	f8a2                	sd	s0,112(sp)
 6c0:	f4a6                	sd	s1,104(sp)
 6c2:	f0ca                	sd	s2,96(sp)
 6c4:	ecce                	sd	s3,88(sp)
 6c6:	e8d2                	sd	s4,80(sp)
 6c8:	e4d6                	sd	s5,72(sp)
 6ca:	e0da                	sd	s6,64(sp)
 6cc:	fc5e                	sd	s7,56(sp)
 6ce:	f862                	sd	s8,48(sp)
 6d0:	f466                	sd	s9,40(sp)
 6d2:	f06a                	sd	s10,32(sp)
 6d4:	ec6e                	sd	s11,24(sp)
 6d6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6d8:	0005c903          	lbu	s2,0(a1)
 6dc:	18090f63          	beqz	s2,87a <vprintf+0x1c0>
 6e0:	8aaa                	mv	s5,a0
 6e2:	8b32                	mv	s6,a2
 6e4:	00158493          	addi	s1,a1,1
  state = 0;
 6e8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6ea:	02500a13          	li	s4,37
      if(c == 'd'){
 6ee:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 6f2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6f6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6fa:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6fe:	00000b97          	auipc	s7,0x0
 702:	712b8b93          	addi	s7,s7,1810 # e10 <digits>
 706:	a839                	j	724 <vprintf+0x6a>
        putc(fd, c);
 708:	85ca                	mv	a1,s2
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	ee2080e7          	jalr	-286(ra) # 5ee <putc>
 714:	a019                	j	71a <vprintf+0x60>
    } else if(state == '%'){
 716:	01498f63          	beq	s3,s4,734 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 71a:	0485                	addi	s1,s1,1
 71c:	fff4c903          	lbu	s2,-1(s1)
 720:	14090d63          	beqz	s2,87a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 724:	0009079b          	sext.w	a5,s2
    if(state == 0){
 728:	fe0997e3          	bnez	s3,716 <vprintf+0x5c>
      if(c == '%'){
 72c:	fd479ee3          	bne	a5,s4,708 <vprintf+0x4e>
        state = '%';
 730:	89be                	mv	s3,a5
 732:	b7e5                	j	71a <vprintf+0x60>
      if(c == 'd'){
 734:	05878063          	beq	a5,s8,774 <vprintf+0xba>
      } else if(c == 'l') {
 738:	05978c63          	beq	a5,s9,790 <vprintf+0xd6>
      } else if(c == 'x') {
 73c:	07a78863          	beq	a5,s10,7ac <vprintf+0xf2>
      } else if(c == 'p') {
 740:	09b78463          	beq	a5,s11,7c8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 744:	07300713          	li	a4,115
 748:	0ce78663          	beq	a5,a4,814 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 74c:	06300713          	li	a4,99
 750:	0ee78e63          	beq	a5,a4,84c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 754:	11478863          	beq	a5,s4,864 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 758:	85d2                	mv	a1,s4
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	e92080e7          	jalr	-366(ra) # 5ee <putc>
        putc(fd, c);
 764:	85ca                	mv	a1,s2
 766:	8556                	mv	a0,s5
 768:	00000097          	auipc	ra,0x0
 76c:	e86080e7          	jalr	-378(ra) # 5ee <putc>
      }
      state = 0;
 770:	4981                	li	s3,0
 772:	b765                	j	71a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 774:	008b0913          	addi	s2,s6,8
 778:	4685                	li	a3,1
 77a:	4629                	li	a2,10
 77c:	000b2583          	lw	a1,0(s6)
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	e8e080e7          	jalr	-370(ra) # 610 <printint>
 78a:	8b4a                	mv	s6,s2
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b771                	j	71a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 790:	008b0913          	addi	s2,s6,8
 794:	4681                	li	a3,0
 796:	4629                	li	a2,10
 798:	000b2583          	lw	a1,0(s6)
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	e72080e7          	jalr	-398(ra) # 610 <printint>
 7a6:	8b4a                	mv	s6,s2
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bf85                	j	71a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7ac:	008b0913          	addi	s2,s6,8
 7b0:	4681                	li	a3,0
 7b2:	4641                	li	a2,16
 7b4:	000b2583          	lw	a1,0(s6)
 7b8:	8556                	mv	a0,s5
 7ba:	00000097          	auipc	ra,0x0
 7be:	e56080e7          	jalr	-426(ra) # 610 <printint>
 7c2:	8b4a                	mv	s6,s2
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	bf91                	j	71a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7c8:	008b0793          	addi	a5,s6,8
 7cc:	f8f43423          	sd	a5,-120(s0)
 7d0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7d4:	03000593          	li	a1,48
 7d8:	8556                	mv	a0,s5
 7da:	00000097          	auipc	ra,0x0
 7de:	e14080e7          	jalr	-492(ra) # 5ee <putc>
  putc(fd, 'x');
 7e2:	85ea                	mv	a1,s10
 7e4:	8556                	mv	a0,s5
 7e6:	00000097          	auipc	ra,0x0
 7ea:	e08080e7          	jalr	-504(ra) # 5ee <putc>
 7ee:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f0:	03c9d793          	srli	a5,s3,0x3c
 7f4:	97de                	add	a5,a5,s7
 7f6:	0007c583          	lbu	a1,0(a5)
 7fa:	8556                	mv	a0,s5
 7fc:	00000097          	auipc	ra,0x0
 800:	df2080e7          	jalr	-526(ra) # 5ee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 804:	0992                	slli	s3,s3,0x4
 806:	397d                	addiw	s2,s2,-1
 808:	fe0914e3          	bnez	s2,7f0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 80c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 810:	4981                	li	s3,0
 812:	b721                	j	71a <vprintf+0x60>
        s = va_arg(ap, char*);
 814:	008b0993          	addi	s3,s6,8
 818:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 81c:	02090163          	beqz	s2,83e <vprintf+0x184>
        while(*s != 0){
 820:	00094583          	lbu	a1,0(s2)
 824:	c9a1                	beqz	a1,874 <vprintf+0x1ba>
          putc(fd, *s);
 826:	8556                	mv	a0,s5
 828:	00000097          	auipc	ra,0x0
 82c:	dc6080e7          	jalr	-570(ra) # 5ee <putc>
          s++;
 830:	0905                	addi	s2,s2,1
        while(*s != 0){
 832:	00094583          	lbu	a1,0(s2)
 836:	f9e5                	bnez	a1,826 <vprintf+0x16c>
        s = va_arg(ap, char*);
 838:	8b4e                	mv	s6,s3
      state = 0;
 83a:	4981                	li	s3,0
 83c:	bdf9                	j	71a <vprintf+0x60>
          s = "(null)";
 83e:	00000917          	auipc	s2,0x0
 842:	5ca90913          	addi	s2,s2,1482 # e08 <uthread_self+0x52>
        while(*s != 0){
 846:	02800593          	li	a1,40
 84a:	bff1                	j	826 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 84c:	008b0913          	addi	s2,s6,8
 850:	000b4583          	lbu	a1,0(s6)
 854:	8556                	mv	a0,s5
 856:	00000097          	auipc	ra,0x0
 85a:	d98080e7          	jalr	-616(ra) # 5ee <putc>
 85e:	8b4a                	mv	s6,s2
      state = 0;
 860:	4981                	li	s3,0
 862:	bd65                	j	71a <vprintf+0x60>
        putc(fd, c);
 864:	85d2                	mv	a1,s4
 866:	8556                	mv	a0,s5
 868:	00000097          	auipc	ra,0x0
 86c:	d86080e7          	jalr	-634(ra) # 5ee <putc>
      state = 0;
 870:	4981                	li	s3,0
 872:	b565                	j	71a <vprintf+0x60>
        s = va_arg(ap, char*);
 874:	8b4e                	mv	s6,s3
      state = 0;
 876:	4981                	li	s3,0
 878:	b54d                	j	71a <vprintf+0x60>
    }
  }
}
 87a:	70e6                	ld	ra,120(sp)
 87c:	7446                	ld	s0,112(sp)
 87e:	74a6                	ld	s1,104(sp)
 880:	7906                	ld	s2,96(sp)
 882:	69e6                	ld	s3,88(sp)
 884:	6a46                	ld	s4,80(sp)
 886:	6aa6                	ld	s5,72(sp)
 888:	6b06                	ld	s6,64(sp)
 88a:	7be2                	ld	s7,56(sp)
 88c:	7c42                	ld	s8,48(sp)
 88e:	7ca2                	ld	s9,40(sp)
 890:	7d02                	ld	s10,32(sp)
 892:	6de2                	ld	s11,24(sp)
 894:	6109                	addi	sp,sp,128
 896:	8082                	ret

0000000000000898 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 898:	715d                	addi	sp,sp,-80
 89a:	ec06                	sd	ra,24(sp)
 89c:	e822                	sd	s0,16(sp)
 89e:	1000                	addi	s0,sp,32
 8a0:	e010                	sd	a2,0(s0)
 8a2:	e414                	sd	a3,8(s0)
 8a4:	e818                	sd	a4,16(s0)
 8a6:	ec1c                	sd	a5,24(s0)
 8a8:	03043023          	sd	a6,32(s0)
 8ac:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8b0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8b4:	8622                	mv	a2,s0
 8b6:	00000097          	auipc	ra,0x0
 8ba:	e04080e7          	jalr	-508(ra) # 6ba <vprintf>
}
 8be:	60e2                	ld	ra,24(sp)
 8c0:	6442                	ld	s0,16(sp)
 8c2:	6161                	addi	sp,sp,80
 8c4:	8082                	ret

00000000000008c6 <printf>:

void
printf(const char *fmt, ...)
{
 8c6:	711d                	addi	sp,sp,-96
 8c8:	ec06                	sd	ra,24(sp)
 8ca:	e822                	sd	s0,16(sp)
 8cc:	1000                	addi	s0,sp,32
 8ce:	e40c                	sd	a1,8(s0)
 8d0:	e810                	sd	a2,16(s0)
 8d2:	ec14                	sd	a3,24(s0)
 8d4:	f018                	sd	a4,32(s0)
 8d6:	f41c                	sd	a5,40(s0)
 8d8:	03043823          	sd	a6,48(s0)
 8dc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e0:	00840613          	addi	a2,s0,8
 8e4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8e8:	85aa                	mv	a1,a0
 8ea:	4505                	li	a0,1
 8ec:	00000097          	auipc	ra,0x0
 8f0:	dce080e7          	jalr	-562(ra) # 6ba <vprintf>
}
 8f4:	60e2                	ld	ra,24(sp)
 8f6:	6442                	ld	s0,16(sp)
 8f8:	6125                	addi	sp,sp,96
 8fa:	8082                	ret

00000000000008fc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8fc:	1141                	addi	sp,sp,-16
 8fe:	e422                	sd	s0,8(sp)
 900:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 902:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 906:	00000797          	auipc	a5,0x0
 90a:	6fa7b783          	ld	a5,1786(a5) # 1000 <freep>
 90e:	a805                	j	93e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 910:	4618                	lw	a4,8(a2)
 912:	9db9                	addw	a1,a1,a4
 914:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 918:	6398                	ld	a4,0(a5)
 91a:	6318                	ld	a4,0(a4)
 91c:	fee53823          	sd	a4,-16(a0)
 920:	a091                	j	964 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 922:	ff852703          	lw	a4,-8(a0)
 926:	9e39                	addw	a2,a2,a4
 928:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 92a:	ff053703          	ld	a4,-16(a0)
 92e:	e398                	sd	a4,0(a5)
 930:	a099                	j	976 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 932:	6398                	ld	a4,0(a5)
 934:	00e7e463          	bltu	a5,a4,93c <free+0x40>
 938:	00e6ea63          	bltu	a3,a4,94c <free+0x50>
{
 93c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93e:	fed7fae3          	bgeu	a5,a3,932 <free+0x36>
 942:	6398                	ld	a4,0(a5)
 944:	00e6e463          	bltu	a3,a4,94c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 948:	fee7eae3          	bltu	a5,a4,93c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 94c:	ff852583          	lw	a1,-8(a0)
 950:	6390                	ld	a2,0(a5)
 952:	02059713          	slli	a4,a1,0x20
 956:	9301                	srli	a4,a4,0x20
 958:	0712                	slli	a4,a4,0x4
 95a:	9736                	add	a4,a4,a3
 95c:	fae60ae3          	beq	a2,a4,910 <free+0x14>
    bp->s.ptr = p->s.ptr;
 960:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 964:	4790                	lw	a2,8(a5)
 966:	02061713          	slli	a4,a2,0x20
 96a:	9301                	srli	a4,a4,0x20
 96c:	0712                	slli	a4,a4,0x4
 96e:	973e                	add	a4,a4,a5
 970:	fae689e3          	beq	a3,a4,922 <free+0x26>
  } else
    p->s.ptr = bp;
 974:	e394                	sd	a3,0(a5)
  freep = p;
 976:	00000717          	auipc	a4,0x0
 97a:	68f73523          	sd	a5,1674(a4) # 1000 <freep>
}
 97e:	6422                	ld	s0,8(sp)
 980:	0141                	addi	sp,sp,16
 982:	8082                	ret

0000000000000984 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 984:	7139                	addi	sp,sp,-64
 986:	fc06                	sd	ra,56(sp)
 988:	f822                	sd	s0,48(sp)
 98a:	f426                	sd	s1,40(sp)
 98c:	f04a                	sd	s2,32(sp)
 98e:	ec4e                	sd	s3,24(sp)
 990:	e852                	sd	s4,16(sp)
 992:	e456                	sd	s5,8(sp)
 994:	e05a                	sd	s6,0(sp)
 996:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 998:	02051493          	slli	s1,a0,0x20
 99c:	9081                	srli	s1,s1,0x20
 99e:	04bd                	addi	s1,s1,15
 9a0:	8091                	srli	s1,s1,0x4
 9a2:	0014899b          	addiw	s3,s1,1
 9a6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9a8:	00000517          	auipc	a0,0x0
 9ac:	65853503          	ld	a0,1624(a0) # 1000 <freep>
 9b0:	c515                	beqz	a0,9dc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b4:	4798                	lw	a4,8(a5)
 9b6:	02977f63          	bgeu	a4,s1,9f4 <malloc+0x70>
 9ba:	8a4e                	mv	s4,s3
 9bc:	0009871b          	sext.w	a4,s3
 9c0:	6685                	lui	a3,0x1
 9c2:	00d77363          	bgeu	a4,a3,9c8 <malloc+0x44>
 9c6:	6a05                	lui	s4,0x1
 9c8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9cc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9d0:	00000917          	auipc	s2,0x0
 9d4:	63090913          	addi	s2,s2,1584 # 1000 <freep>
  if(p == (char*)-1)
 9d8:	5afd                	li	s5,-1
 9da:	a88d                	j	a4c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 9dc:	00001797          	auipc	a5,0x1
 9e0:	a4478793          	addi	a5,a5,-1468 # 1420 <base>
 9e4:	00000717          	auipc	a4,0x0
 9e8:	60f73e23          	sd	a5,1564(a4) # 1000 <freep>
 9ec:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9ee:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9f2:	b7e1                	j	9ba <malloc+0x36>
      if(p->s.size == nunits)
 9f4:	02e48b63          	beq	s1,a4,a2a <malloc+0xa6>
        p->s.size -= nunits;
 9f8:	4137073b          	subw	a4,a4,s3
 9fc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9fe:	1702                	slli	a4,a4,0x20
 a00:	9301                	srli	a4,a4,0x20
 a02:	0712                	slli	a4,a4,0x4
 a04:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a06:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a0a:	00000717          	auipc	a4,0x0
 a0e:	5ea73b23          	sd	a0,1526(a4) # 1000 <freep>
      return (void*)(p + 1);
 a12:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a16:	70e2                	ld	ra,56(sp)
 a18:	7442                	ld	s0,48(sp)
 a1a:	74a2                	ld	s1,40(sp)
 a1c:	7902                	ld	s2,32(sp)
 a1e:	69e2                	ld	s3,24(sp)
 a20:	6a42                	ld	s4,16(sp)
 a22:	6aa2                	ld	s5,8(sp)
 a24:	6b02                	ld	s6,0(sp)
 a26:	6121                	addi	sp,sp,64
 a28:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a2a:	6398                	ld	a4,0(a5)
 a2c:	e118                	sd	a4,0(a0)
 a2e:	bff1                	j	a0a <malloc+0x86>
  hp->s.size = nu;
 a30:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a34:	0541                	addi	a0,a0,16
 a36:	00000097          	auipc	ra,0x0
 a3a:	ec6080e7          	jalr	-314(ra) # 8fc <free>
  return freep;
 a3e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a42:	d971                	beqz	a0,a16 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a44:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a46:	4798                	lw	a4,8(a5)
 a48:	fa9776e3          	bgeu	a4,s1,9f4 <malloc+0x70>
    if(p == freep)
 a4c:	00093703          	ld	a4,0(s2)
 a50:	853e                	mv	a0,a5
 a52:	fef719e3          	bne	a4,a5,a44 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a56:	8552                	mv	a0,s4
 a58:	00000097          	auipc	ra,0x0
 a5c:	b56080e7          	jalr	-1194(ra) # 5ae <sbrk>
  if(p == (char*)-1)
 a60:	fd5518e3          	bne	a0,s5,a30 <malloc+0xac>
        return 0;
 a64:	4501                	li	a0,0
 a66:	bf45                	j	a16 <malloc+0x92>

0000000000000a68 <uswtch>:
 a68:	00153023          	sd	ra,0(a0)
 a6c:	00253423          	sd	sp,8(a0)
 a70:	e900                	sd	s0,16(a0)
 a72:	ed04                	sd	s1,24(a0)
 a74:	03253023          	sd	s2,32(a0)
 a78:	03353423          	sd	s3,40(a0)
 a7c:	03453823          	sd	s4,48(a0)
 a80:	03553c23          	sd	s5,56(a0)
 a84:	05653023          	sd	s6,64(a0)
 a88:	05753423          	sd	s7,72(a0)
 a8c:	05853823          	sd	s8,80(a0)
 a90:	05953c23          	sd	s9,88(a0)
 a94:	07a53023          	sd	s10,96(a0)
 a98:	07b53423          	sd	s11,104(a0)
 a9c:	0005b083          	ld	ra,0(a1)
 aa0:	0085b103          	ld	sp,8(a1)
 aa4:	6980                	ld	s0,16(a1)
 aa6:	6d84                	ld	s1,24(a1)
 aa8:	0205b903          	ld	s2,32(a1)
 aac:	0285b983          	ld	s3,40(a1)
 ab0:	0305ba03          	ld	s4,48(a1)
 ab4:	0385ba83          	ld	s5,56(a1)
 ab8:	0405bb03          	ld	s6,64(a1)
 abc:	0485bb83          	ld	s7,72(a1)
 ac0:	0505bc03          	ld	s8,80(a1)
 ac4:	0585bc83          	ld	s9,88(a1)
 ac8:	0605bd03          	ld	s10,96(a1)
 acc:	0685bd83          	ld	s11,104(a1)
 ad0:	8082                	ret

0000000000000ad2 <uthread_exit>:
    curr_thread = next_thread;
    uswtch(curr_context, next_context);

}

void uthread_exit(){
 ad2:	1141                	addi	sp,sp,-16
 ad4:	e406                	sd	ra,8(sp)
 ad6:	e022                	sd	s0,0(sp)
 ad8:	0800                	addi	s0,sp,16
    printf("in uthresd exit\n");
 ada:	00000517          	auipc	a0,0x0
 ade:	34e50513          	addi	a0,a0,846 # e28 <digits+0x18>
 ae2:	00000097          	auipc	ra,0x0
 ae6:	de4080e7          	jalr	-540(ra) # 8c6 <printf>
    // Change the state of the current thread to FREE
    curr_thread->state = FREE;
 aea:	00000517          	auipc	a0,0x0
 aee:	51e53503          	ld	a0,1310(a0) # 1008 <curr_thread>
 af2:	6785                	lui	a5,0x1
 af4:	97aa                	add	a5,a5,a0
 af6:	fa07a223          	sw	zero,-92(a5) # fa4 <digits+0x194>
    // Find another runnable thread to switch to (make sure its not the current_thread)
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 afa:	411c                	lw	a5,0(a0)
 afc:	2785                	addiw	a5,a5,1
 afe:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 b00:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 b02:	4585                	li	a1,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 b04:	00001617          	auipc	a2,0x1
 b08:	99c60613          	addi	a2,a2,-1636 # 14a0 <uthreads_arr>
 b0c:	6805                	lui	a6,0x1
 b0e:	4889                	li	a7,2
 b10:	a819                	j	b26 <uthread_exit+0x54>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 b12:	2785                	addiw	a5,a5,1
 b14:	41f7d71b          	sraiw	a4,a5,0x1f
 b18:	01e7571b          	srliw	a4,a4,0x1e
 b1c:	9fb9                	addw	a5,a5,a4
 b1e:	8b8d                	andi	a5,a5,3
 b20:	9f99                	subw	a5,a5,a4
 b22:	36fd                	addiw	a3,a3,-1
 b24:	ca9d                	beqz	a3,b5a <uthread_exit+0x88>
        if (uthreads_arr[i].state == RUNNABLE &&
 b26:	00779713          	slli	a4,a5,0x7
 b2a:	973e                	add	a4,a4,a5
 b2c:	0716                	slli	a4,a4,0x5
 b2e:	9732                	add	a4,a4,a2
 b30:	9742                	add	a4,a4,a6
 b32:	fa472703          	lw	a4,-92(a4)
 b36:	fd171ee3          	bne	a4,a7,b12 <uthread_exit+0x40>
            uthreads_arr[i].priority > max_priority) {
 b3a:	00779713          	slli	a4,a5,0x7
 b3e:	973e                	add	a4,a4,a5
 b40:	0716                	slli	a4,a4,0x5
 b42:	9732                	add	a4,a4,a2
 b44:	9742                	add	a4,a4,a6
 b46:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 b48:	fce375e3          	bgeu	t1,a4,b12 <uthread_exit+0x40>
            next_thread = &uthreads_arr[i];
 b4c:	00779593          	slli	a1,a5,0x7
 b50:	95be                	add	a1,a1,a5
 b52:	0596                	slli	a1,a1,0x5
 b54:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 b56:	833a                	mv	t1,a4
 b58:	bf6d                	j	b12 <uthread_exit+0x40>
        }
    }
    if (next_thread == (struct uthread *) 1) {
 b5a:	4785                	li	a5,1
 b5c:	02f58863          	beq	a1,a5,b8c <uthread_exit+0xba>
        exit(0);  // Exit the process if there are no more runnable threads
    }
    // Switch to the next thread
    struct context *curr_context = &curr_thread->context;
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 b60:	6785                	lui	a5,0x1
 b62:	00f58733          	add	a4,a1,a5
 b66:	4685                	li	a3,1
 b68:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 b6c:	00000717          	auipc	a4,0x0
 b70:	48b73e23          	sd	a1,1180(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 b74:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x198>
    uswtch(curr_context, next_context);
 b78:	95be                	add	a1,a1,a5
 b7a:	953e                	add	a0,a0,a5
 b7c:	00000097          	auipc	ra,0x0
 b80:	eec080e7          	jalr	-276(ra) # a68 <uswtch>
}
 b84:	60a2                	ld	ra,8(sp)
 b86:	6402                	ld	s0,0(sp)
 b88:	0141                	addi	sp,sp,16
 b8a:	8082                	ret
        exit(0);  // Exit the process if there are no more runnable threads
 b8c:	4501                	li	a0,0
 b8e:	00000097          	auipc	ra,0x0
 b92:	998080e7          	jalr	-1640(ra) # 526 <exit>

0000000000000b96 <uthread_create>:
int uthread_create(void (*start_func)(), enum sched_priority priority) {
 b96:	1141                	addi	sp,sp,-16
 b98:	e422                	sd	s0,8(sp)
 b9a:	0800                	addi	s0,sp,16
    for (i = 0; i < MAX_UTHREADS; i++) {
 b9c:	00002717          	auipc	a4,0x2
 ba0:	8a870713          	addi	a4,a4,-1880 # 2444 <uthreads_arr+0xfa4>
 ba4:	4781                	li	a5,0
 ba6:	6605                	lui	a2,0x1
 ba8:	02060613          	addi	a2,a2,32 # 1020 <buf>
 bac:	4811                	li	a6,4
        if (uthreads_arr[i].state == FREE) {
 bae:	4314                	lw	a3,0(a4)
 bb0:	c699                	beqz	a3,bbe <uthread_create+0x28>
    for (i = 0; i < MAX_UTHREADS; i++) {
 bb2:	2785                	addiw	a5,a5,1
 bb4:	9732                	add	a4,a4,a2
 bb6:	ff079ce3          	bne	a5,a6,bae <uthread_create+0x18>
        return -1;
 bba:	557d                	li	a0,-1
 bbc:	a0b9                	j	c0a <uthread_create+0x74>
            curr_thread = &uthreads_arr[i];
 bbe:	00779713          	slli	a4,a5,0x7
 bc2:	973e                	add	a4,a4,a5
 bc4:	0716                	slli	a4,a4,0x5
 bc6:	00001697          	auipc	a3,0x1
 bca:	8da68693          	addi	a3,a3,-1830 # 14a0 <uthreads_arr>
 bce:	9736                	add	a4,a4,a3
 bd0:	00000697          	auipc	a3,0x0
 bd4:	42e6bc23          	sd	a4,1080(a3) # 1008 <curr_thread>
    if (i >= MAX_UTHREADS) {
 bd8:	468d                	li	a3,3
 bda:	02f6cb63          	blt	a3,a5,c10 <uthread_create+0x7a>
    curr_thread->id = i; 
 bde:	c31c                	sw	a5,0(a4)
    curr_thread->priority = priority;
 be0:	6685                	lui	a3,0x1
 be2:	00d707b3          	add	a5,a4,a3
 be6:	cf8c                	sw	a1,24(a5)
    curr_thread->context.ra = (uint64) start_func;
 be8:	faa7b423          	sd	a0,-88(a5)
    curr_thread->context.sp = (uint64) &curr_thread->ustack[STACK_SIZE];
 bec:	fa468693          	addi	a3,a3,-92 # fa4 <digits+0x194>
 bf0:	9736                	add	a4,a4,a3
 bf2:	fae7b823          	sd	a4,-80(a5)
    curr_thread->ustack[STACK_SIZE - 1] = (uint64) uthread_exit; // Return address to uthread_exit
 bf6:	00000717          	auipc	a4,0x0
 bfa:	edc70713          	addi	a4,a4,-292 # ad2 <uthread_exit>
 bfe:	fae781a3          	sb	a4,-93(a5)
    curr_thread->state = RUNNABLE;
 c02:	4709                	li	a4,2
 c04:	fae7a223          	sw	a4,-92(a5)
     return 0;
 c08:	4501                	li	a0,0
}
 c0a:	6422                	ld	s0,8(sp)
 c0c:	0141                	addi	sp,sp,16
 c0e:	8082                	ret
        return -1;
 c10:	557d                	li	a0,-1
 c12:	bfe5                	j	c0a <uthread_create+0x74>

0000000000000c14 <uthread_yield>:
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 c14:	00000517          	auipc	a0,0x0
 c18:	3f453503          	ld	a0,1012(a0) # 1008 <curr_thread>
 c1c:	411c                	lw	a5,0(a0)
 c1e:	2785                	addiw	a5,a5,1
 c20:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 c22:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
 c24:	4585                	li	a1,1
        if (uthreads_arr[i].state == RUNNABLE &&
 c26:	00001617          	auipc	a2,0x1
 c2a:	87a60613          	addi	a2,a2,-1926 # 14a0 <uthreads_arr>
 c2e:	6805                	lui	a6,0x1
 c30:	4889                	li	a7,2
 c32:	a819                	j	c48 <uthread_yield+0x34>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
 c34:	2785                	addiw	a5,a5,1
 c36:	41f7d71b          	sraiw	a4,a5,0x1f
 c3a:	01e7571b          	srliw	a4,a4,0x1e
 c3e:	9fb9                	addw	a5,a5,a4
 c40:	8b8d                	andi	a5,a5,3
 c42:	9f99                	subw	a5,a5,a4
 c44:	36fd                	addiw	a3,a3,-1
 c46:	ca9d                	beqz	a3,c7c <uthread_yield+0x68>
        if (uthreads_arr[i].state == RUNNABLE &&
 c48:	00779713          	slli	a4,a5,0x7
 c4c:	973e                	add	a4,a4,a5
 c4e:	0716                	slli	a4,a4,0x5
 c50:	9732                	add	a4,a4,a2
 c52:	9742                	add	a4,a4,a6
 c54:	fa472703          	lw	a4,-92(a4)
 c58:	fd171ee3          	bne	a4,a7,c34 <uthread_yield+0x20>
            uthreads_arr[i].priority > max_priority) {
 c5c:	00779713          	slli	a4,a5,0x7
 c60:	973e                	add	a4,a4,a5
 c62:	0716                	slli	a4,a4,0x5
 c64:	9732                	add	a4,a4,a2
 c66:	9742                	add	a4,a4,a6
 c68:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 c6a:	fce375e3          	bgeu	t1,a4,c34 <uthread_yield+0x20>
            next_thread = &uthreads_arr[i];
 c6e:	00779593          	slli	a1,a5,0x7
 c72:	95be                	add	a1,a1,a5
 c74:	0596                	slli	a1,a1,0x5
 c76:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
 c78:	833a                	mv	t1,a4
 c7a:	bf6d                	j	c34 <uthread_yield+0x20>
    if (next_thread == (struct uthread *) 1) {
 c7c:	4785                	li	a5,1
 c7e:	04f58163          	beq	a1,a5,cc0 <uthread_yield+0xac>
void uthread_yield() {
 c82:	1141                	addi	sp,sp,-16
 c84:	e406                	sd	ra,8(sp)
 c86:	e022                	sd	s0,0(sp)
 c88:	0800                	addi	s0,sp,16
    curr_thread->state = RUNNABLE;
 c8a:	6785                	lui	a5,0x1
 c8c:	00f50733          	add	a4,a0,a5
 c90:	4689                	li	a3,2
 c92:	fad72223          	sw	a3,-92(a4)
    next_thread->state = RUNNING;
 c96:	00f58733          	add	a4,a1,a5
 c9a:	4685                	li	a3,1
 c9c:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
 ca0:	00000717          	auipc	a4,0x0
 ca4:	36b73423          	sd	a1,872(a4) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 ca8:	fa878793          	addi	a5,a5,-88 # fa8 <digits+0x198>
    uswtch(curr_context, next_context);
 cac:	95be                	add	a1,a1,a5
 cae:	953e                	add	a0,a0,a5
 cb0:	00000097          	auipc	ra,0x0
 cb4:	db8080e7          	jalr	-584(ra) # a68 <uswtch>
}
 cb8:	60a2                	ld	ra,8(sp)
 cba:	6402                	ld	s0,0(sp)
 cbc:	0141                	addi	sp,sp,16
 cbe:	8082                	ret
 cc0:	8082                	ret

0000000000000cc2 <uthread_set_priority>:

enum sched_priority uthread_set_priority(enum sched_priority priority){
 cc2:	1141                	addi	sp,sp,-16
 cc4:	e422                	sd	s0,8(sp)
 cc6:	0800                	addi	s0,sp,16
    enum sched_priority to_return =curr_thread->priority;
 cc8:	00000797          	auipc	a5,0x0
 ccc:	3407b783          	ld	a5,832(a5) # 1008 <curr_thread>
 cd0:	6705                	lui	a4,0x1
 cd2:	97ba                	add	a5,a5,a4
 cd4:	4f98                	lw	a4,24(a5)
    curr_thread->priority=priority;
 cd6:	cf88                	sw	a0,24(a5)
    return to_return;
}
 cd8:	853a                	mv	a0,a4
 cda:	6422                	ld	s0,8(sp)
 cdc:	0141                	addi	sp,sp,16
 cde:	8082                	ret

0000000000000ce0 <uthread_get_priority>:

enum sched_priority uthread_get_priority(){
 ce0:	1141                	addi	sp,sp,-16
 ce2:	e422                	sd	s0,8(sp)
 ce4:	0800                	addi	s0,sp,16
    return curr_thread->priority;
 ce6:	00000797          	auipc	a5,0x0
 cea:	3227b783          	ld	a5,802(a5) # 1008 <curr_thread>
 cee:	6705                	lui	a4,0x1
 cf0:	97ba                	add	a5,a5,a4
}
 cf2:	4f88                	lw	a0,24(a5)
 cf4:	6422                	ld	s0,8(sp)
 cf6:	0141                	addi	sp,sp,16
 cf8:	8082                	ret

0000000000000cfa <uthread_start_all>:

int uthread_start_all(){
    if (started){
 cfa:	00000797          	auipc	a5,0x0
 cfe:	3167a783          	lw	a5,790(a5) # 1010 <started>
 d02:	ebc5                	bnez	a5,db2 <uthread_start_all+0xb8>
int uthread_start_all(){
 d04:	1141                	addi	sp,sp,-16
 d06:	e406                	sd	ra,8(sp)
 d08:	e022                	sd	s0,0(sp)
 d0a:	0800                	addi	s0,sp,16
        return -1;
    }
    started=1;
 d0c:	4785                	li	a5,1
 d0e:	00000717          	auipc	a4,0x0
 d12:	30f72123          	sw	a5,770(a4) # 1010 <started>
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 d16:	00000797          	auipc	a5,0x0
 d1a:	2f27b783          	ld	a5,754(a5) # 1008 <curr_thread>
 d1e:	439c                	lw	a5,0(a5)
 d20:	2785                	addiw	a5,a5,1
 d22:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
 d24:	4881                	li	a7,0
    struct uthread *next_thread = (struct uthread *) 1;
 d26:	4605                	li	a2,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
 d28:	00000597          	auipc	a1,0x0
 d2c:	77858593          	addi	a1,a1,1912 # 14a0 <uthreads_arr>
 d30:	6505                	lui	a0,0x1
 d32:	4809                	li	a6,2
 d34:	a819                	j	d4a <uthread_start_all+0x50>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
 d36:	2785                	addiw	a5,a5,1
 d38:	41f7d71b          	sraiw	a4,a5,0x1f
 d3c:	01e7571b          	srliw	a4,a4,0x1e
 d40:	9fb9                	addw	a5,a5,a4
 d42:	8b8d                	andi	a5,a5,3
 d44:	9f99                	subw	a5,a5,a4
 d46:	36fd                	addiw	a3,a3,-1
 d48:	ca9d                	beqz	a3,d7e <uthread_start_all+0x84>
        if (uthreads_arr[i].state == RUNNABLE &&
 d4a:	00779713          	slli	a4,a5,0x7
 d4e:	973e                	add	a4,a4,a5
 d50:	0716                	slli	a4,a4,0x5
 d52:	972e                	add	a4,a4,a1
 d54:	972a                	add	a4,a4,a0
 d56:	fa472703          	lw	a4,-92(a4)
 d5a:	fd071ee3          	bne	a4,a6,d36 <uthread_start_all+0x3c>
            uthreads_arr[i].priority > max_priority) {
 d5e:	00779713          	slli	a4,a5,0x7
 d62:	973e                	add	a4,a4,a5
 d64:	0716                	slli	a4,a4,0x5
 d66:	972e                	add	a4,a4,a1
 d68:	972a                	add	a4,a4,a0
 d6a:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
 d6c:	fce8f5e3          	bgeu	a7,a4,d36 <uthread_start_all+0x3c>
            next_thread = &uthreads_arr[i];
 d70:	00779613          	slli	a2,a5,0x7
 d74:	963e                	add	a2,a2,a5
 d76:	0616                	slli	a2,a2,0x5
 d78:	962e                	add	a2,a2,a1
            max_priority = uthreads_arr[i].priority;
 d7a:	88ba                	mv	a7,a4
 d7c:	bf6d                	j	d36 <uthread_start_all+0x3c>
        }
    }
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
 d7e:	6585                	lui	a1,0x1
 d80:	00b607b3          	add	a5,a2,a1
 d84:	4705                	li	a4,1
 d86:	fae7a223          	sw	a4,-92(a5)
    curr_thread = next_thread;
 d8a:	00000797          	auipc	a5,0x0
 d8e:	26c7bf23          	sd	a2,638(a5) # 1008 <curr_thread>
    struct context *next_context = &next_thread->context;
 d92:	fa858593          	addi	a1,a1,-88 # fa8 <digits+0x198>
    uswtch(&garbageContext,next_context);
 d96:	95b2                	add	a1,a1,a2
 d98:	00000517          	auipc	a0,0x0
 d9c:	69850513          	addi	a0,a0,1688 # 1430 <garbageContext>
 da0:	00000097          	auipc	ra,0x0
 da4:	cc8080e7          	jalr	-824(ra) # a68 <uswtch>

    return -1;
}
 da8:	557d                	li	a0,-1
 daa:	60a2                	ld	ra,8(sp)
 dac:	6402                	ld	s0,0(sp)
 dae:	0141                	addi	sp,sp,16
 db0:	8082                	ret
 db2:	557d                	li	a0,-1
 db4:	8082                	ret

0000000000000db6 <uthread_self>:

struct uthread* uthread_self(){
 db6:	1141                	addi	sp,sp,-16
 db8:	e422                	sd	s0,8(sp)
 dba:	0800                	addi	s0,sp,16
    return curr_thread;
 dbc:	00000517          	auipc	a0,0x0
 dc0:	24c53503          	ld	a0,588(a0) # 1008 <curr_thread>
 dc4:	6422                	ld	s0,8(sp)
 dc6:	0141                	addi	sp,sp,16
 dc8:	8082                	ret
