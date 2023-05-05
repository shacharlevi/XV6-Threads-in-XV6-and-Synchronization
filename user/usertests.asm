
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	e7a080e7          	jalr	-390(ra) # 5e8a <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	e68080e7          	jalr	-408(ra) # 5e8a <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	6d250513          	addi	a0,a0,1746 # 6710 <uthread_self+0x36>
      46:	00006097          	auipc	ra,0x6
      4a:	1a4080e7          	jalr	420(ra) # 61ea <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	dfa080e7          	jalr	-518(ra) # 5e4a <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	0000a797          	auipc	a5,0xa
      5c:	54078793          	addi	a5,a5,1344 # a598 <uninit>
      60:	0000d697          	auipc	a3,0xd
      64:	c4868693          	addi	a3,a3,-952 # cca8 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	6b050513          	addi	a0,a0,1712 # 6730 <uthread_self+0x56>
      88:	00006097          	auipc	ra,0x6
      8c:	162080e7          	jalr	354(ra) # 61ea <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00006097          	auipc	ra,0x6
      96:	db8080e7          	jalr	-584(ra) # 5e4a <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	6a050513          	addi	a0,a0,1696 # 6748 <uthread_self+0x6e>
      b0:	00006097          	auipc	ra,0x6
      b4:	dda080e7          	jalr	-550(ra) # 5e8a <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00006097          	auipc	ra,0x6
      c0:	db6080e7          	jalr	-586(ra) # 5e72 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	6a250513          	addi	a0,a0,1698 # 6768 <uthread_self+0x8e>
      ce:	00006097          	auipc	ra,0x6
      d2:	dbc080e7          	jalr	-580(ra) # 5e8a <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	66a50513          	addi	a0,a0,1642 # 6750 <uthread_self+0x76>
      ee:	00006097          	auipc	ra,0x6
      f2:	0fc080e7          	jalr	252(ra) # 61ea <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00006097          	auipc	ra,0x6
      fc:	d52080e7          	jalr	-686(ra) # 5e4a <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	67650513          	addi	a0,a0,1654 # 6778 <uthread_self+0x9e>
     10a:	00006097          	auipc	ra,0x6
     10e:	0e0080e7          	jalr	224(ra) # 61ea <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00006097          	auipc	ra,0x6
     118:	d36080e7          	jalr	-714(ra) # 5e4a <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	67450513          	addi	a0,a0,1652 # 67a0 <uthread_self+0xc6>
     134:	00006097          	auipc	ra,0x6
     138:	d66080e7          	jalr	-666(ra) # 5e9a <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	66050513          	addi	a0,a0,1632 # 67a0 <uthread_self+0xc6>
     148:	00006097          	auipc	ra,0x6
     14c:	d42080e7          	jalr	-702(ra) # 5e8a <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	65c58593          	addi	a1,a1,1628 # 67b0 <uthread_self+0xd6>
     15c:	00006097          	auipc	ra,0x6
     160:	d0e080e7          	jalr	-754(ra) # 5e6a <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	63850513          	addi	a0,a0,1592 # 67a0 <uthread_self+0xc6>
     170:	00006097          	auipc	ra,0x6
     174:	d1a080e7          	jalr	-742(ra) # 5e8a <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	63c58593          	addi	a1,a1,1596 # 67b8 <uthread_self+0xde>
     184:	8526                	mv	a0,s1
     186:	00006097          	auipc	ra,0x6
     18a:	ce4080e7          	jalr	-796(ra) # 5e6a <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	60c50513          	addi	a0,a0,1548 # 67a0 <uthread_self+0xc6>
     19c:	00006097          	auipc	ra,0x6
     1a0:	cfe080e7          	jalr	-770(ra) # 5e9a <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00006097          	auipc	ra,0x6
     1aa:	ccc080e7          	jalr	-820(ra) # 5e72 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00006097          	auipc	ra,0x6
     1b4:	cc2080e7          	jalr	-830(ra) # 5e72 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	5f650513          	addi	a0,a0,1526 # 67c0 <uthread_self+0xe6>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	018080e7          	jalr	24(ra) # 61ea <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00006097          	auipc	ra,0x6
     1e0:	c6e080e7          	jalr	-914(ra) # 5e4a <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00006097          	auipc	ra,0x6
     214:	c7a080e7          	jalr	-902(ra) # 5e8a <open>
    close(fd);
     218:	00006097          	auipc	ra,0x6
     21c:	c5a080e7          	jalr	-934(ra) # 5e72 <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	andi	s1,s1,255
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00006097          	auipc	ra,0x6
     24a:	c54080e7          	jalr	-940(ra) # 5e9a <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	andi	s1,s1,255
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	56c50513          	addi	a0,a0,1388 # 67e8 <uthread_self+0x10e>
     284:	00006097          	auipc	ra,0x6
     288:	c16080e7          	jalr	-1002(ra) # 5e9a <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	558a8a93          	addi	s5,s5,1368 # 67e8 <uthread_self+0x10e>
      int cc = write(fd, buf, sz);
     298:	0000da17          	auipc	s4,0xd
     29c:	a10a0a13          	addi	s4,s4,-1520 # cca8 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <fourteen+0x17f>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00006097          	auipc	ra,0x6
     2b0:	bde080e7          	jalr	-1058(ra) # 5e8a <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00006097          	auipc	ra,0x6
     2c2:	bac080e7          	jalr	-1108(ra) # 5e6a <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00006097          	auipc	ra,0x6
     2d6:	b98080e7          	jalr	-1128(ra) # 5e6a <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00006097          	auipc	ra,0x6
     2e4:	b92080e7          	jalr	-1134(ra) # 5e72 <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00006097          	auipc	ra,0x6
     2ee:	bb0080e7          	jalr	-1104(ra) # 5e9a <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	4e650513          	addi	a0,a0,1254 # 67f8 <uthread_self+0x11e>
     31a:	00006097          	auipc	ra,0x6
     31e:	ed0080e7          	jalr	-304(ra) # 61ea <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00006097          	auipc	ra,0x6
     328:	b26080e7          	jalr	-1242(ra) # 5e4a <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	4e250513          	addi	a0,a0,1250 # 6818 <uthread_self+0x13e>
     33e:	00006097          	auipc	ra,0x6
     342:	eac080e7          	jalr	-340(ra) # 61ea <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00006097          	auipc	ra,0x6
     34c:	b02080e7          	jalr	-1278(ra) # 5e4a <exit>

0000000000000350 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     350:	7179                	addi	sp,sp,-48
     352:	f406                	sd	ra,40(sp)
     354:	f022                	sd	s0,32(sp)
     356:	ec26                	sd	s1,24(sp)
     358:	e84a                	sd	s2,16(sp)
     35a:	e44e                	sd	s3,8(sp)
     35c:	e052                	sd	s4,0(sp)
     35e:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
     360:	00006517          	auipc	a0,0x6
     364:	4d050513          	addi	a0,a0,1232 # 6830 <uthread_self+0x156>
     368:	00006097          	auipc	ra,0x6
     36c:	b32080e7          	jalr	-1230(ra) # 5e9a <unlink>
     370:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     374:	00006997          	auipc	s3,0x6
     378:	4bc98993          	addi	s3,s3,1212 # 6830 <uthread_self+0x156>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     37c:	5a7d                	li	s4,-1
     37e:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     382:	20100593          	li	a1,513
     386:	854e                	mv	a0,s3
     388:	00006097          	auipc	ra,0x6
     38c:	b02080e7          	jalr	-1278(ra) # 5e8a <open>
     390:	84aa                	mv	s1,a0
    if(fd < 0){
     392:	06054b63          	bltz	a0,408 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
     396:	4605                	li	a2,1
     398:	85d2                	mv	a1,s4
     39a:	00006097          	auipc	ra,0x6
     39e:	ad0080e7          	jalr	-1328(ra) # 5e6a <write>
    close(fd);
     3a2:	8526                	mv	a0,s1
     3a4:	00006097          	auipc	ra,0x6
     3a8:	ace080e7          	jalr	-1330(ra) # 5e72 <close>
    unlink("junk");
     3ac:	854e                	mv	a0,s3
     3ae:	00006097          	auipc	ra,0x6
     3b2:	aec080e7          	jalr	-1300(ra) # 5e9a <unlink>
  for(int i = 0; i < assumed_free; i++){
     3b6:	397d                	addiw	s2,s2,-1
     3b8:	fc0915e3          	bnez	s2,382 <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     3bc:	20100593          	li	a1,513
     3c0:	00006517          	auipc	a0,0x6
     3c4:	47050513          	addi	a0,a0,1136 # 6830 <uthread_self+0x156>
     3c8:	00006097          	auipc	ra,0x6
     3cc:	ac2080e7          	jalr	-1342(ra) # 5e8a <open>
     3d0:	84aa                	mv	s1,a0
  if(fd < 0){
     3d2:	04054863          	bltz	a0,422 <badwrite+0xd2>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     3d6:	4605                	li	a2,1
     3d8:	00006597          	auipc	a1,0x6
     3dc:	3e058593          	addi	a1,a1,992 # 67b8 <uthread_self+0xde>
     3e0:	00006097          	auipc	ra,0x6
     3e4:	a8a080e7          	jalr	-1398(ra) # 5e6a <write>
     3e8:	4785                	li	a5,1
     3ea:	04f50963          	beq	a0,a5,43c <badwrite+0xec>
    printf("write failed\n");
     3ee:	00006517          	auipc	a0,0x6
     3f2:	46250513          	addi	a0,a0,1122 # 6850 <uthread_self+0x176>
     3f6:	00006097          	auipc	ra,0x6
     3fa:	df4080e7          	jalr	-524(ra) # 61ea <printf>
    exit(1);
     3fe:	4505                	li	a0,1
     400:	00006097          	auipc	ra,0x6
     404:	a4a080e7          	jalr	-1462(ra) # 5e4a <exit>
      printf("open junk failed\n");
     408:	00006517          	auipc	a0,0x6
     40c:	43050513          	addi	a0,a0,1072 # 6838 <uthread_self+0x15e>
     410:	00006097          	auipc	ra,0x6
     414:	dda080e7          	jalr	-550(ra) # 61ea <printf>
      exit(1);
     418:	4505                	li	a0,1
     41a:	00006097          	auipc	ra,0x6
     41e:	a30080e7          	jalr	-1488(ra) # 5e4a <exit>
    printf("open junk failed\n");
     422:	00006517          	auipc	a0,0x6
     426:	41650513          	addi	a0,a0,1046 # 6838 <uthread_self+0x15e>
     42a:	00006097          	auipc	ra,0x6
     42e:	dc0080e7          	jalr	-576(ra) # 61ea <printf>
    exit(1);
     432:	4505                	li	a0,1
     434:	00006097          	auipc	ra,0x6
     438:	a16080e7          	jalr	-1514(ra) # 5e4a <exit>
  }
  close(fd);
     43c:	8526                	mv	a0,s1
     43e:	00006097          	auipc	ra,0x6
     442:	a34080e7          	jalr	-1484(ra) # 5e72 <close>
  unlink("junk");
     446:	00006517          	auipc	a0,0x6
     44a:	3ea50513          	addi	a0,a0,1002 # 6830 <uthread_self+0x156>
     44e:	00006097          	auipc	ra,0x6
     452:	a4c080e7          	jalr	-1460(ra) # 5e9a <unlink>

  exit(0);
     456:	4501                	li	a0,0
     458:	00006097          	auipc	ra,0x6
     45c:	9f2080e7          	jalr	-1550(ra) # 5e4a <exit>

0000000000000460 <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     460:	715d                	addi	sp,sp,-80
     462:	e486                	sd	ra,72(sp)
     464:	e0a2                	sd	s0,64(sp)
     466:	fc26                	sd	s1,56(sp)
     468:	f84a                	sd	s2,48(sp)
     46a:	f44e                	sd	s3,40(sp)
     46c:	0880                	addi	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     46e:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     470:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     474:	40000993          	li	s3,1024
    name[0] = 'z';
     478:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     47c:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     480:	41f4d79b          	sraiw	a5,s1,0x1f
     484:	01b7d71b          	srliw	a4,a5,0x1b
     488:	009707bb          	addw	a5,a4,s1
     48c:	4057d69b          	sraiw	a3,a5,0x5
     490:	0306869b          	addiw	a3,a3,48
     494:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     498:	8bfd                	andi	a5,a5,31
     49a:	9f99                	subw	a5,a5,a4
     49c:	0307879b          	addiw	a5,a5,48
     4a0:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     4a4:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     4a8:	fb040513          	addi	a0,s0,-80
     4ac:	00006097          	auipc	ra,0x6
     4b0:	9ee080e7          	jalr	-1554(ra) # 5e9a <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     4b4:	60200593          	li	a1,1538
     4b8:	fb040513          	addi	a0,s0,-80
     4bc:	00006097          	auipc	ra,0x6
     4c0:	9ce080e7          	jalr	-1586(ra) # 5e8a <open>
    if(fd < 0){
     4c4:	00054963          	bltz	a0,4d6 <outofinodes+0x76>
      // failure is eventually expected.
      break;
    }
    close(fd);
     4c8:	00006097          	auipc	ra,0x6
     4cc:	9aa080e7          	jalr	-1622(ra) # 5e72 <close>
  for(int i = 0; i < nzz; i++){
     4d0:	2485                	addiw	s1,s1,1
     4d2:	fb3493e3          	bne	s1,s3,478 <outofinodes+0x18>
     4d6:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     4d8:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     4dc:	40000993          	li	s3,1024
    name[0] = 'z';
     4e0:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     4e4:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     4e8:	41f4d79b          	sraiw	a5,s1,0x1f
     4ec:	01b7d71b          	srliw	a4,a5,0x1b
     4f0:	009707bb          	addw	a5,a4,s1
     4f4:	4057d69b          	sraiw	a3,a5,0x5
     4f8:	0306869b          	addiw	a3,a3,48
     4fc:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     500:	8bfd                	andi	a5,a5,31
     502:	9f99                	subw	a5,a5,a4
     504:	0307879b          	addiw	a5,a5,48
     508:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     50c:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     510:	fb040513          	addi	a0,s0,-80
     514:	00006097          	auipc	ra,0x6
     518:	986080e7          	jalr	-1658(ra) # 5e9a <unlink>
  for(int i = 0; i < nzz; i++){
     51c:	2485                	addiw	s1,s1,1
     51e:	fd3491e3          	bne	s1,s3,4e0 <outofinodes+0x80>
  }
}
     522:	60a6                	ld	ra,72(sp)
     524:	6406                	ld	s0,64(sp)
     526:	74e2                	ld	s1,56(sp)
     528:	7942                	ld	s2,48(sp)
     52a:	79a2                	ld	s3,40(sp)
     52c:	6161                	addi	sp,sp,80
     52e:	8082                	ret

0000000000000530 <copyin>:
{
     530:	711d                	addi	sp,sp,-96
     532:	ec86                	sd	ra,88(sp)
     534:	e8a2                	sd	s0,80(sp)
     536:	e4a6                	sd	s1,72(sp)
     538:	e0ca                	sd	s2,64(sp)
     53a:	fc4e                	sd	s3,56(sp)
     53c:	f852                	sd	s4,48(sp)
     53e:	f456                	sd	s5,40(sp)
     540:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     542:	4785                	li	a5,1
     544:	07fe                	slli	a5,a5,0x1f
     546:	faf43823          	sd	a5,-80(s0)
     54a:	57fd                	li	a5,-1
     54c:	faf43c23          	sd	a5,-72(s0)
    printf("in copyin\n");
     550:	00006517          	auipc	a0,0x6
     554:	31050513          	addi	a0,a0,784 # 6860 <uthread_self+0x186>
     558:	00006097          	auipc	ra,0x6
     55c:	c92080e7          	jalr	-878(ra) # 61ea <printf>
  for(int ai = 0; ai < 2; ai++){
     560:	fb040913          	addi	s2,s0,-80
    printf("222in copyin\n");
     564:	00006a97          	auipc	s5,0x6
     568:	30ca8a93          	addi	s5,s5,780 # 6870 <uthread_self+0x196>
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     56c:	00006a17          	auipc	s4,0x6
     570:	314a0a13          	addi	s4,s4,788 # 6880 <uthread_self+0x1a6>
    uint64 addr = addrs[ai];
     574:	00093983          	ld	s3,0(s2)
    printf("222in copyin\n");
     578:	8556                	mv	a0,s5
     57a:	00006097          	auipc	ra,0x6
     57e:	c70080e7          	jalr	-912(ra) # 61ea <printf>
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     582:	20100593          	li	a1,513
     586:	8552                	mv	a0,s4
     588:	00006097          	auipc	ra,0x6
     58c:	902080e7          	jalr	-1790(ra) # 5e8a <open>
     590:	84aa                	mv	s1,a0
    if(fd < 0){
     592:	08054963          	bltz	a0,624 <copyin+0xf4>
    int n = write(fd, (void*)addr, 8192);
     596:	6609                	lui	a2,0x2
     598:	85ce                	mv	a1,s3
     59a:	00006097          	auipc	ra,0x6
     59e:	8d0080e7          	jalr	-1840(ra) # 5e6a <write>
    if(n >= 0){
     5a2:	08055e63          	bgez	a0,63e <copyin+0x10e>
    close(fd);
     5a6:	8526                	mv	a0,s1
     5a8:	00006097          	auipc	ra,0x6
     5ac:	8ca080e7          	jalr	-1846(ra) # 5e72 <close>
    unlink("copyin1");
     5b0:	8552                	mv	a0,s4
     5b2:	00006097          	auipc	ra,0x6
     5b6:	8e8080e7          	jalr	-1816(ra) # 5e9a <unlink>
    n = write(1, (char*)addr, 8192);
     5ba:	6609                	lui	a2,0x2
     5bc:	85ce                	mv	a1,s3
     5be:	4505                	li	a0,1
     5c0:	00006097          	auipc	ra,0x6
     5c4:	8aa080e7          	jalr	-1878(ra) # 5e6a <write>
    if(n > 0){
     5c8:	08a04a63          	bgtz	a0,65c <copyin+0x12c>
    if(pipe(fds) < 0){
     5cc:	fa840513          	addi	a0,s0,-88
     5d0:	00006097          	auipc	ra,0x6
     5d4:	88a080e7          	jalr	-1910(ra) # 5e5a <pipe>
     5d8:	0a054163          	bltz	a0,67a <copyin+0x14a>
    n = write(fds[1], (char*)addr, 8192);
     5dc:	6609                	lui	a2,0x2
     5de:	85ce                	mv	a1,s3
     5e0:	fac42503          	lw	a0,-84(s0)
     5e4:	00006097          	auipc	ra,0x6
     5e8:	886080e7          	jalr	-1914(ra) # 5e6a <write>
    if(n > 0){
     5ec:	0aa04463          	bgtz	a0,694 <copyin+0x164>
    close(fds[0]);
     5f0:	fa842503          	lw	a0,-88(s0)
     5f4:	00006097          	auipc	ra,0x6
     5f8:	87e080e7          	jalr	-1922(ra) # 5e72 <close>
    close(fds[1]);
     5fc:	fac42503          	lw	a0,-84(s0)
     600:	00006097          	auipc	ra,0x6
     604:	872080e7          	jalr	-1934(ra) # 5e72 <close>
  for(int ai = 0; ai < 2; ai++){
     608:	0921                	addi	s2,s2,8
     60a:	fc040793          	addi	a5,s0,-64
     60e:	f6f913e3          	bne	s2,a5,574 <copyin+0x44>
}
     612:	60e6                	ld	ra,88(sp)
     614:	6446                	ld	s0,80(sp)
     616:	64a6                	ld	s1,72(sp)
     618:	6906                	ld	s2,64(sp)
     61a:	79e2                	ld	s3,56(sp)
     61c:	7a42                	ld	s4,48(sp)
     61e:	7aa2                	ld	s5,40(sp)
     620:	6125                	addi	sp,sp,96
     622:	8082                	ret
      printf("open(copyin1) failed\n");
     624:	00006517          	auipc	a0,0x6
     628:	26450513          	addi	a0,a0,612 # 6888 <uthread_self+0x1ae>
     62c:	00006097          	auipc	ra,0x6
     630:	bbe080e7          	jalr	-1090(ra) # 61ea <printf>
      exit(1);
     634:	4505                	li	a0,1
     636:	00006097          	auipc	ra,0x6
     63a:	814080e7          	jalr	-2028(ra) # 5e4a <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     63e:	862a                	mv	a2,a0
     640:	85ce                	mv	a1,s3
     642:	00006517          	auipc	a0,0x6
     646:	25e50513          	addi	a0,a0,606 # 68a0 <uthread_self+0x1c6>
     64a:	00006097          	auipc	ra,0x6
     64e:	ba0080e7          	jalr	-1120(ra) # 61ea <printf>
      exit(1);
     652:	4505                	li	a0,1
     654:	00005097          	auipc	ra,0x5
     658:	7f6080e7          	jalr	2038(ra) # 5e4a <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     65c:	862a                	mv	a2,a0
     65e:	85ce                	mv	a1,s3
     660:	00006517          	auipc	a0,0x6
     664:	27050513          	addi	a0,a0,624 # 68d0 <uthread_self+0x1f6>
     668:	00006097          	auipc	ra,0x6
     66c:	b82080e7          	jalr	-1150(ra) # 61ea <printf>
      exit(1);
     670:	4505                	li	a0,1
     672:	00005097          	auipc	ra,0x5
     676:	7d8080e7          	jalr	2008(ra) # 5e4a <exit>
      printf("pipe() failed\n");
     67a:	00006517          	auipc	a0,0x6
     67e:	28650513          	addi	a0,a0,646 # 6900 <uthread_self+0x226>
     682:	00006097          	auipc	ra,0x6
     686:	b68080e7          	jalr	-1176(ra) # 61ea <printf>
      exit(1);
     68a:	4505                	li	a0,1
     68c:	00005097          	auipc	ra,0x5
     690:	7be080e7          	jalr	1982(ra) # 5e4a <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     694:	862a                	mv	a2,a0
     696:	85ce                	mv	a1,s3
     698:	00006517          	auipc	a0,0x6
     69c:	27850513          	addi	a0,a0,632 # 6910 <uthread_self+0x236>
     6a0:	00006097          	auipc	ra,0x6
     6a4:	b4a080e7          	jalr	-1206(ra) # 61ea <printf>
      exit(1);
     6a8:	4505                	li	a0,1
     6aa:	00005097          	auipc	ra,0x5
     6ae:	7a0080e7          	jalr	1952(ra) # 5e4a <exit>

00000000000006b2 <copyout>:
{
     6b2:	711d                	addi	sp,sp,-96
     6b4:	ec86                	sd	ra,88(sp)
     6b6:	e8a2                	sd	s0,80(sp)
     6b8:	e4a6                	sd	s1,72(sp)
     6ba:	e0ca                	sd	s2,64(sp)
     6bc:	fc4e                	sd	s3,56(sp)
     6be:	f852                	sd	s4,48(sp)
     6c0:	f456                	sd	s5,40(sp)
     6c2:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     6c4:	4785                	li	a5,1
     6c6:	07fe                	slli	a5,a5,0x1f
     6c8:	faf43823          	sd	a5,-80(s0)
     6cc:	57fd                	li	a5,-1
     6ce:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     6d2:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     6d6:	00006a17          	auipc	s4,0x6
     6da:	26aa0a13          	addi	s4,s4,618 # 6940 <uthread_self+0x266>
    n = write(fds[1], "x", 1);
     6de:	00006a97          	auipc	s5,0x6
     6e2:	0daa8a93          	addi	s5,s5,218 # 67b8 <uthread_self+0xde>
    uint64 addr = addrs[ai];
     6e6:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     6ea:	4581                	li	a1,0
     6ec:	8552                	mv	a0,s4
     6ee:	00005097          	auipc	ra,0x5
     6f2:	79c080e7          	jalr	1948(ra) # 5e8a <open>
     6f6:	84aa                	mv	s1,a0
    if(fd < 0){
     6f8:	08054663          	bltz	a0,784 <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     6fc:	6609                	lui	a2,0x2
     6fe:	85ce                	mv	a1,s3
     700:	00005097          	auipc	ra,0x5
     704:	762080e7          	jalr	1890(ra) # 5e62 <read>
    if(n > 0){
     708:	08a04b63          	bgtz	a0,79e <copyout+0xec>
    close(fd);
     70c:	8526                	mv	a0,s1
     70e:	00005097          	auipc	ra,0x5
     712:	764080e7          	jalr	1892(ra) # 5e72 <close>
    if(pipe(fds) < 0){
     716:	fa840513          	addi	a0,s0,-88
     71a:	00005097          	auipc	ra,0x5
     71e:	740080e7          	jalr	1856(ra) # 5e5a <pipe>
     722:	08054d63          	bltz	a0,7bc <copyout+0x10a>
    n = write(fds[1], "x", 1);
     726:	4605                	li	a2,1
     728:	85d6                	mv	a1,s5
     72a:	fac42503          	lw	a0,-84(s0)
     72e:	00005097          	auipc	ra,0x5
     732:	73c080e7          	jalr	1852(ra) # 5e6a <write>
    if(n != 1){
     736:	4785                	li	a5,1
     738:	08f51f63          	bne	a0,a5,7d6 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     73c:	6609                	lui	a2,0x2
     73e:	85ce                	mv	a1,s3
     740:	fa842503          	lw	a0,-88(s0)
     744:	00005097          	auipc	ra,0x5
     748:	71e080e7          	jalr	1822(ra) # 5e62 <read>
    if(n > 0){
     74c:	0aa04263          	bgtz	a0,7f0 <copyout+0x13e>
    close(fds[0]);
     750:	fa842503          	lw	a0,-88(s0)
     754:	00005097          	auipc	ra,0x5
     758:	71e080e7          	jalr	1822(ra) # 5e72 <close>
    close(fds[1]);
     75c:	fac42503          	lw	a0,-84(s0)
     760:	00005097          	auipc	ra,0x5
     764:	712080e7          	jalr	1810(ra) # 5e72 <close>
  for(int ai = 0; ai < 2; ai++){
     768:	0921                	addi	s2,s2,8
     76a:	fc040793          	addi	a5,s0,-64
     76e:	f6f91ce3          	bne	s2,a5,6e6 <copyout+0x34>
}
     772:	60e6                	ld	ra,88(sp)
     774:	6446                	ld	s0,80(sp)
     776:	64a6                	ld	s1,72(sp)
     778:	6906                	ld	s2,64(sp)
     77a:	79e2                	ld	s3,56(sp)
     77c:	7a42                	ld	s4,48(sp)
     77e:	7aa2                	ld	s5,40(sp)
     780:	6125                	addi	sp,sp,96
     782:	8082                	ret
      printf("open(README) failed\n");
     784:	00006517          	auipc	a0,0x6
     788:	1c450513          	addi	a0,a0,452 # 6948 <uthread_self+0x26e>
     78c:	00006097          	auipc	ra,0x6
     790:	a5e080e7          	jalr	-1442(ra) # 61ea <printf>
      exit(1);
     794:	4505                	li	a0,1
     796:	00005097          	auipc	ra,0x5
     79a:	6b4080e7          	jalr	1716(ra) # 5e4a <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     79e:	862a                	mv	a2,a0
     7a0:	85ce                	mv	a1,s3
     7a2:	00006517          	auipc	a0,0x6
     7a6:	1be50513          	addi	a0,a0,446 # 6960 <uthread_self+0x286>
     7aa:	00006097          	auipc	ra,0x6
     7ae:	a40080e7          	jalr	-1472(ra) # 61ea <printf>
      exit(1);
     7b2:	4505                	li	a0,1
     7b4:	00005097          	auipc	ra,0x5
     7b8:	696080e7          	jalr	1686(ra) # 5e4a <exit>
      printf("pipe() failed\n");
     7bc:	00006517          	auipc	a0,0x6
     7c0:	14450513          	addi	a0,a0,324 # 6900 <uthread_self+0x226>
     7c4:	00006097          	auipc	ra,0x6
     7c8:	a26080e7          	jalr	-1498(ra) # 61ea <printf>
      exit(1);
     7cc:	4505                	li	a0,1
     7ce:	00005097          	auipc	ra,0x5
     7d2:	67c080e7          	jalr	1660(ra) # 5e4a <exit>
      printf("pipe write failed\n");
     7d6:	00006517          	auipc	a0,0x6
     7da:	1ba50513          	addi	a0,a0,442 # 6990 <uthread_self+0x2b6>
     7de:	00006097          	auipc	ra,0x6
     7e2:	a0c080e7          	jalr	-1524(ra) # 61ea <printf>
      exit(1);
     7e6:	4505                	li	a0,1
     7e8:	00005097          	auipc	ra,0x5
     7ec:	662080e7          	jalr	1634(ra) # 5e4a <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     7f0:	862a                	mv	a2,a0
     7f2:	85ce                	mv	a1,s3
     7f4:	00006517          	auipc	a0,0x6
     7f8:	1b450513          	addi	a0,a0,436 # 69a8 <uthread_self+0x2ce>
     7fc:	00006097          	auipc	ra,0x6
     800:	9ee080e7          	jalr	-1554(ra) # 61ea <printf>
      exit(1);
     804:	4505                	li	a0,1
     806:	00005097          	auipc	ra,0x5
     80a:	644080e7          	jalr	1604(ra) # 5e4a <exit>

000000000000080e <truncate1>:
{
     80e:	711d                	addi	sp,sp,-96
     810:	ec86                	sd	ra,88(sp)
     812:	e8a2                	sd	s0,80(sp)
     814:	e4a6                	sd	s1,72(sp)
     816:	e0ca                	sd	s2,64(sp)
     818:	fc4e                	sd	s3,56(sp)
     81a:	f852                	sd	s4,48(sp)
     81c:	f456                	sd	s5,40(sp)
     81e:	1080                	addi	s0,sp,96
     820:	8aaa                	mv	s5,a0
  unlink("truncfile");
     822:	00006517          	auipc	a0,0x6
     826:	f7e50513          	addi	a0,a0,-130 # 67a0 <uthread_self+0xc6>
     82a:	00005097          	auipc	ra,0x5
     82e:	670080e7          	jalr	1648(ra) # 5e9a <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     832:	60100593          	li	a1,1537
     836:	00006517          	auipc	a0,0x6
     83a:	f6a50513          	addi	a0,a0,-150 # 67a0 <uthread_self+0xc6>
     83e:	00005097          	auipc	ra,0x5
     842:	64c080e7          	jalr	1612(ra) # 5e8a <open>
     846:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     848:	4611                	li	a2,4
     84a:	00006597          	auipc	a1,0x6
     84e:	f6658593          	addi	a1,a1,-154 # 67b0 <uthread_self+0xd6>
     852:	00005097          	auipc	ra,0x5
     856:	618080e7          	jalr	1560(ra) # 5e6a <write>
  close(fd1);
     85a:	8526                	mv	a0,s1
     85c:	00005097          	auipc	ra,0x5
     860:	616080e7          	jalr	1558(ra) # 5e72 <close>
  int fd2 = open("truncfile", O_RDONLY);
     864:	4581                	li	a1,0
     866:	00006517          	auipc	a0,0x6
     86a:	f3a50513          	addi	a0,a0,-198 # 67a0 <uthread_self+0xc6>
     86e:	00005097          	auipc	ra,0x5
     872:	61c080e7          	jalr	1564(ra) # 5e8a <open>
     876:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     878:	02000613          	li	a2,32
     87c:	fa040593          	addi	a1,s0,-96
     880:	00005097          	auipc	ra,0x5
     884:	5e2080e7          	jalr	1506(ra) # 5e62 <read>
  if(n != 4){
     888:	4791                	li	a5,4
     88a:	0cf51e63          	bne	a0,a5,966 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     88e:	40100593          	li	a1,1025
     892:	00006517          	auipc	a0,0x6
     896:	f0e50513          	addi	a0,a0,-242 # 67a0 <uthread_self+0xc6>
     89a:	00005097          	auipc	ra,0x5
     89e:	5f0080e7          	jalr	1520(ra) # 5e8a <open>
     8a2:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     8a4:	4581                	li	a1,0
     8a6:	00006517          	auipc	a0,0x6
     8aa:	efa50513          	addi	a0,a0,-262 # 67a0 <uthread_self+0xc6>
     8ae:	00005097          	auipc	ra,0x5
     8b2:	5dc080e7          	jalr	1500(ra) # 5e8a <open>
     8b6:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     8b8:	02000613          	li	a2,32
     8bc:	fa040593          	addi	a1,s0,-96
     8c0:	00005097          	auipc	ra,0x5
     8c4:	5a2080e7          	jalr	1442(ra) # 5e62 <read>
     8c8:	8a2a                	mv	s4,a0
  if(n != 0){
     8ca:	ed4d                	bnez	a0,984 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     8cc:	02000613          	li	a2,32
     8d0:	fa040593          	addi	a1,s0,-96
     8d4:	8526                	mv	a0,s1
     8d6:	00005097          	auipc	ra,0x5
     8da:	58c080e7          	jalr	1420(ra) # 5e62 <read>
     8de:	8a2a                	mv	s4,a0
  if(n != 0){
     8e0:	e971                	bnez	a0,9b4 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     8e2:	4619                	li	a2,6
     8e4:	00006597          	auipc	a1,0x6
     8e8:	15458593          	addi	a1,a1,340 # 6a38 <uthread_self+0x35e>
     8ec:	854e                	mv	a0,s3
     8ee:	00005097          	auipc	ra,0x5
     8f2:	57c080e7          	jalr	1404(ra) # 5e6a <write>
  n = read(fd3, buf, sizeof(buf));
     8f6:	02000613          	li	a2,32
     8fa:	fa040593          	addi	a1,s0,-96
     8fe:	854a                	mv	a0,s2
     900:	00005097          	auipc	ra,0x5
     904:	562080e7          	jalr	1378(ra) # 5e62 <read>
  if(n != 6){
     908:	4799                	li	a5,6
     90a:	0cf51d63          	bne	a0,a5,9e4 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     90e:	02000613          	li	a2,32
     912:	fa040593          	addi	a1,s0,-96
     916:	8526                	mv	a0,s1
     918:	00005097          	auipc	ra,0x5
     91c:	54a080e7          	jalr	1354(ra) # 5e62 <read>
  if(n != 2){
     920:	4789                	li	a5,2
     922:	0ef51063          	bne	a0,a5,a02 <truncate1+0x1f4>
  unlink("truncfile");
     926:	00006517          	auipc	a0,0x6
     92a:	e7a50513          	addi	a0,a0,-390 # 67a0 <uthread_self+0xc6>
     92e:	00005097          	auipc	ra,0x5
     932:	56c080e7          	jalr	1388(ra) # 5e9a <unlink>
  close(fd1);
     936:	854e                	mv	a0,s3
     938:	00005097          	auipc	ra,0x5
     93c:	53a080e7          	jalr	1338(ra) # 5e72 <close>
  close(fd2);
     940:	8526                	mv	a0,s1
     942:	00005097          	auipc	ra,0x5
     946:	530080e7          	jalr	1328(ra) # 5e72 <close>
  close(fd3);
     94a:	854a                	mv	a0,s2
     94c:	00005097          	auipc	ra,0x5
     950:	526080e7          	jalr	1318(ra) # 5e72 <close>
}
     954:	60e6                	ld	ra,88(sp)
     956:	6446                	ld	s0,80(sp)
     958:	64a6                	ld	s1,72(sp)
     95a:	6906                	ld	s2,64(sp)
     95c:	79e2                	ld	s3,56(sp)
     95e:	7a42                	ld	s4,48(sp)
     960:	7aa2                	ld	s5,40(sp)
     962:	6125                	addi	sp,sp,96
     964:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     966:	862a                	mv	a2,a0
     968:	85d6                	mv	a1,s5
     96a:	00006517          	auipc	a0,0x6
     96e:	06e50513          	addi	a0,a0,110 # 69d8 <uthread_self+0x2fe>
     972:	00006097          	auipc	ra,0x6
     976:	878080e7          	jalr	-1928(ra) # 61ea <printf>
    exit(1);
     97a:	4505                	li	a0,1
     97c:	00005097          	auipc	ra,0x5
     980:	4ce080e7          	jalr	1230(ra) # 5e4a <exit>
    printf("aaa fd3=%d\n", fd3);
     984:	85ca                	mv	a1,s2
     986:	00006517          	auipc	a0,0x6
     98a:	07250513          	addi	a0,a0,114 # 69f8 <uthread_self+0x31e>
     98e:	00006097          	auipc	ra,0x6
     992:	85c080e7          	jalr	-1956(ra) # 61ea <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     996:	8652                	mv	a2,s4
     998:	85d6                	mv	a1,s5
     99a:	00006517          	auipc	a0,0x6
     99e:	06e50513          	addi	a0,a0,110 # 6a08 <uthread_self+0x32e>
     9a2:	00006097          	auipc	ra,0x6
     9a6:	848080e7          	jalr	-1976(ra) # 61ea <printf>
    exit(1);
     9aa:	4505                	li	a0,1
     9ac:	00005097          	auipc	ra,0x5
     9b0:	49e080e7          	jalr	1182(ra) # 5e4a <exit>
    printf("bbb fd2=%d\n", fd2);
     9b4:	85a6                	mv	a1,s1
     9b6:	00006517          	auipc	a0,0x6
     9ba:	07250513          	addi	a0,a0,114 # 6a28 <uthread_self+0x34e>
     9be:	00006097          	auipc	ra,0x6
     9c2:	82c080e7          	jalr	-2004(ra) # 61ea <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9c6:	8652                	mv	a2,s4
     9c8:	85d6                	mv	a1,s5
     9ca:	00006517          	auipc	a0,0x6
     9ce:	03e50513          	addi	a0,a0,62 # 6a08 <uthread_self+0x32e>
     9d2:	00006097          	auipc	ra,0x6
     9d6:	818080e7          	jalr	-2024(ra) # 61ea <printf>
    exit(1);
     9da:	4505                	li	a0,1
     9dc:	00005097          	auipc	ra,0x5
     9e0:	46e080e7          	jalr	1134(ra) # 5e4a <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     9e4:	862a                	mv	a2,a0
     9e6:	85d6                	mv	a1,s5
     9e8:	00006517          	auipc	a0,0x6
     9ec:	05850513          	addi	a0,a0,88 # 6a40 <uthread_self+0x366>
     9f0:	00005097          	auipc	ra,0x5
     9f4:	7fa080e7          	jalr	2042(ra) # 61ea <printf>
    exit(1);
     9f8:	4505                	li	a0,1
     9fa:	00005097          	auipc	ra,0x5
     9fe:	450080e7          	jalr	1104(ra) # 5e4a <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     a02:	862a                	mv	a2,a0
     a04:	85d6                	mv	a1,s5
     a06:	00006517          	auipc	a0,0x6
     a0a:	05a50513          	addi	a0,a0,90 # 6a60 <uthread_self+0x386>
     a0e:	00005097          	auipc	ra,0x5
     a12:	7dc080e7          	jalr	2012(ra) # 61ea <printf>
    exit(1);
     a16:	4505                	li	a0,1
     a18:	00005097          	auipc	ra,0x5
     a1c:	432080e7          	jalr	1074(ra) # 5e4a <exit>

0000000000000a20 <writetest>:
{
     a20:	7139                	addi	sp,sp,-64
     a22:	fc06                	sd	ra,56(sp)
     a24:	f822                	sd	s0,48(sp)
     a26:	f426                	sd	s1,40(sp)
     a28:	f04a                	sd	s2,32(sp)
     a2a:	ec4e                	sd	s3,24(sp)
     a2c:	e852                	sd	s4,16(sp)
     a2e:	e456                	sd	s5,8(sp)
     a30:	e05a                	sd	s6,0(sp)
     a32:	0080                	addi	s0,sp,64
     a34:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     a36:	20200593          	li	a1,514
     a3a:	00006517          	auipc	a0,0x6
     a3e:	04650513          	addi	a0,a0,70 # 6a80 <uthread_self+0x3a6>
     a42:	00005097          	auipc	ra,0x5
     a46:	448080e7          	jalr	1096(ra) # 5e8a <open>
  if(fd < 0){
     a4a:	0a054d63          	bltz	a0,b04 <writetest+0xe4>
     a4e:	892a                	mv	s2,a0
     a50:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a52:	00006997          	auipc	s3,0x6
     a56:	05698993          	addi	s3,s3,86 # 6aa8 <uthread_self+0x3ce>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a5a:	00006a97          	auipc	s5,0x6
     a5e:	086a8a93          	addi	s5,s5,134 # 6ae0 <uthread_self+0x406>
  for(i = 0; i < N; i++){
     a62:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a66:	4629                	li	a2,10
     a68:	85ce                	mv	a1,s3
     a6a:	854a                	mv	a0,s2
     a6c:	00005097          	auipc	ra,0x5
     a70:	3fe080e7          	jalr	1022(ra) # 5e6a <write>
     a74:	47a9                	li	a5,10
     a76:	0af51563          	bne	a0,a5,b20 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a7a:	4629                	li	a2,10
     a7c:	85d6                	mv	a1,s5
     a7e:	854a                	mv	a0,s2
     a80:	00005097          	auipc	ra,0x5
     a84:	3ea080e7          	jalr	1002(ra) # 5e6a <write>
     a88:	47a9                	li	a5,10
     a8a:	0af51a63          	bne	a0,a5,b3e <writetest+0x11e>
  for(i = 0; i < N; i++){
     a8e:	2485                	addiw	s1,s1,1
     a90:	fd449be3          	bne	s1,s4,a66 <writetest+0x46>
  close(fd);
     a94:	854a                	mv	a0,s2
     a96:	00005097          	auipc	ra,0x5
     a9a:	3dc080e7          	jalr	988(ra) # 5e72 <close>
  fd = open("small", O_RDONLY);
     a9e:	4581                	li	a1,0
     aa0:	00006517          	auipc	a0,0x6
     aa4:	fe050513          	addi	a0,a0,-32 # 6a80 <uthread_self+0x3a6>
     aa8:	00005097          	auipc	ra,0x5
     aac:	3e2080e7          	jalr	994(ra) # 5e8a <open>
     ab0:	84aa                	mv	s1,a0
  if(fd < 0){
     ab2:	0a054563          	bltz	a0,b5c <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     ab6:	7d000613          	li	a2,2000
     aba:	0000c597          	auipc	a1,0xc
     abe:	1ee58593          	addi	a1,a1,494 # cca8 <buf>
     ac2:	00005097          	auipc	ra,0x5
     ac6:	3a0080e7          	jalr	928(ra) # 5e62 <read>
  if(i != N*SZ*2){
     aca:	7d000793          	li	a5,2000
     ace:	0af51563          	bne	a0,a5,b78 <writetest+0x158>
  close(fd);
     ad2:	8526                	mv	a0,s1
     ad4:	00005097          	auipc	ra,0x5
     ad8:	39e080e7          	jalr	926(ra) # 5e72 <close>
  if(unlink("small") < 0){
     adc:	00006517          	auipc	a0,0x6
     ae0:	fa450513          	addi	a0,a0,-92 # 6a80 <uthread_self+0x3a6>
     ae4:	00005097          	auipc	ra,0x5
     ae8:	3b6080e7          	jalr	950(ra) # 5e9a <unlink>
     aec:	0a054463          	bltz	a0,b94 <writetest+0x174>
}
     af0:	70e2                	ld	ra,56(sp)
     af2:	7442                	ld	s0,48(sp)
     af4:	74a2                	ld	s1,40(sp)
     af6:	7902                	ld	s2,32(sp)
     af8:	69e2                	ld	s3,24(sp)
     afa:	6a42                	ld	s4,16(sp)
     afc:	6aa2                	ld	s5,8(sp)
     afe:	6b02                	ld	s6,0(sp)
     b00:	6121                	addi	sp,sp,64
     b02:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     b04:	85da                	mv	a1,s6
     b06:	00006517          	auipc	a0,0x6
     b0a:	f8250513          	addi	a0,a0,-126 # 6a88 <uthread_self+0x3ae>
     b0e:	00005097          	auipc	ra,0x5
     b12:	6dc080e7          	jalr	1756(ra) # 61ea <printf>
    exit(1);
     b16:	4505                	li	a0,1
     b18:	00005097          	auipc	ra,0x5
     b1c:	332080e7          	jalr	818(ra) # 5e4a <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     b20:	8626                	mv	a2,s1
     b22:	85da                	mv	a1,s6
     b24:	00006517          	auipc	a0,0x6
     b28:	f9450513          	addi	a0,a0,-108 # 6ab8 <uthread_self+0x3de>
     b2c:	00005097          	auipc	ra,0x5
     b30:	6be080e7          	jalr	1726(ra) # 61ea <printf>
      exit(1);
     b34:	4505                	li	a0,1
     b36:	00005097          	auipc	ra,0x5
     b3a:	314080e7          	jalr	788(ra) # 5e4a <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     b3e:	8626                	mv	a2,s1
     b40:	85da                	mv	a1,s6
     b42:	00006517          	auipc	a0,0x6
     b46:	fae50513          	addi	a0,a0,-82 # 6af0 <uthread_self+0x416>
     b4a:	00005097          	auipc	ra,0x5
     b4e:	6a0080e7          	jalr	1696(ra) # 61ea <printf>
      exit(1);
     b52:	4505                	li	a0,1
     b54:	00005097          	auipc	ra,0x5
     b58:	2f6080e7          	jalr	758(ra) # 5e4a <exit>
    printf("%s: error: open small failed!\n", s);
     b5c:	85da                	mv	a1,s6
     b5e:	00006517          	auipc	a0,0x6
     b62:	fba50513          	addi	a0,a0,-70 # 6b18 <uthread_self+0x43e>
     b66:	00005097          	auipc	ra,0x5
     b6a:	684080e7          	jalr	1668(ra) # 61ea <printf>
    exit(1);
     b6e:	4505                	li	a0,1
     b70:	00005097          	auipc	ra,0x5
     b74:	2da080e7          	jalr	730(ra) # 5e4a <exit>
    printf("%s: read failed\n", s);
     b78:	85da                	mv	a1,s6
     b7a:	00006517          	auipc	a0,0x6
     b7e:	fbe50513          	addi	a0,a0,-66 # 6b38 <uthread_self+0x45e>
     b82:	00005097          	auipc	ra,0x5
     b86:	668080e7          	jalr	1640(ra) # 61ea <printf>
    exit(1);
     b8a:	4505                	li	a0,1
     b8c:	00005097          	auipc	ra,0x5
     b90:	2be080e7          	jalr	702(ra) # 5e4a <exit>
    printf("%s: unlink small failed\n", s);
     b94:	85da                	mv	a1,s6
     b96:	00006517          	auipc	a0,0x6
     b9a:	fba50513          	addi	a0,a0,-70 # 6b50 <uthread_self+0x476>
     b9e:	00005097          	auipc	ra,0x5
     ba2:	64c080e7          	jalr	1612(ra) # 61ea <printf>
    exit(1);
     ba6:	4505                	li	a0,1
     ba8:	00005097          	auipc	ra,0x5
     bac:	2a2080e7          	jalr	674(ra) # 5e4a <exit>

0000000000000bb0 <writebig>:
{
     bb0:	7139                	addi	sp,sp,-64
     bb2:	fc06                	sd	ra,56(sp)
     bb4:	f822                	sd	s0,48(sp)
     bb6:	f426                	sd	s1,40(sp)
     bb8:	f04a                	sd	s2,32(sp)
     bba:	ec4e                	sd	s3,24(sp)
     bbc:	e852                	sd	s4,16(sp)
     bbe:	e456                	sd	s5,8(sp)
     bc0:	0080                	addi	s0,sp,64
     bc2:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     bc4:	20200593          	li	a1,514
     bc8:	00006517          	auipc	a0,0x6
     bcc:	fa850513          	addi	a0,a0,-88 # 6b70 <uthread_self+0x496>
     bd0:	00005097          	auipc	ra,0x5
     bd4:	2ba080e7          	jalr	698(ra) # 5e8a <open>
     bd8:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     bda:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     bdc:	0000c917          	auipc	s2,0xc
     be0:	0cc90913          	addi	s2,s2,204 # cca8 <buf>
  for(i = 0; i < MAXFILE; i++){
     be4:	10c00a13          	li	s4,268
  if(fd < 0){
     be8:	06054c63          	bltz	a0,c60 <writebig+0xb0>
    ((int*)buf)[0] = i;
     bec:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     bf0:	40000613          	li	a2,1024
     bf4:	85ca                	mv	a1,s2
     bf6:	854e                	mv	a0,s3
     bf8:	00005097          	auipc	ra,0x5
     bfc:	272080e7          	jalr	626(ra) # 5e6a <write>
     c00:	40000793          	li	a5,1024
     c04:	06f51c63          	bne	a0,a5,c7c <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     c08:	2485                	addiw	s1,s1,1
     c0a:	ff4491e3          	bne	s1,s4,bec <writebig+0x3c>
  close(fd);
     c0e:	854e                	mv	a0,s3
     c10:	00005097          	auipc	ra,0x5
     c14:	262080e7          	jalr	610(ra) # 5e72 <close>
  fd = open("big", O_RDONLY);
     c18:	4581                	li	a1,0
     c1a:	00006517          	auipc	a0,0x6
     c1e:	f5650513          	addi	a0,a0,-170 # 6b70 <uthread_self+0x496>
     c22:	00005097          	auipc	ra,0x5
     c26:	268080e7          	jalr	616(ra) # 5e8a <open>
     c2a:	89aa                	mv	s3,a0
  n = 0;
     c2c:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     c2e:	0000c917          	auipc	s2,0xc
     c32:	07a90913          	addi	s2,s2,122 # cca8 <buf>
  if(fd < 0){
     c36:	06054263          	bltz	a0,c9a <writebig+0xea>
    i = read(fd, buf, BSIZE);
     c3a:	40000613          	li	a2,1024
     c3e:	85ca                	mv	a1,s2
     c40:	854e                	mv	a0,s3
     c42:	00005097          	auipc	ra,0x5
     c46:	220080e7          	jalr	544(ra) # 5e62 <read>
    if(i == 0){
     c4a:	c535                	beqz	a0,cb6 <writebig+0x106>
    } else if(i != BSIZE){
     c4c:	40000793          	li	a5,1024
     c50:	0af51f63          	bne	a0,a5,d0e <writebig+0x15e>
    if(((int*)buf)[0] != n){
     c54:	00092683          	lw	a3,0(s2)
     c58:	0c969a63          	bne	a3,s1,d2c <writebig+0x17c>
    n++;
     c5c:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     c5e:	bff1                	j	c3a <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     c60:	85d6                	mv	a1,s5
     c62:	00006517          	auipc	a0,0x6
     c66:	f1650513          	addi	a0,a0,-234 # 6b78 <uthread_self+0x49e>
     c6a:	00005097          	auipc	ra,0x5
     c6e:	580080e7          	jalr	1408(ra) # 61ea <printf>
    exit(1);
     c72:	4505                	li	a0,1
     c74:	00005097          	auipc	ra,0x5
     c78:	1d6080e7          	jalr	470(ra) # 5e4a <exit>
      printf("%s: error: write big file failed\n", s, i);
     c7c:	8626                	mv	a2,s1
     c7e:	85d6                	mv	a1,s5
     c80:	00006517          	auipc	a0,0x6
     c84:	f1850513          	addi	a0,a0,-232 # 6b98 <uthread_self+0x4be>
     c88:	00005097          	auipc	ra,0x5
     c8c:	562080e7          	jalr	1378(ra) # 61ea <printf>
      exit(1);
     c90:	4505                	li	a0,1
     c92:	00005097          	auipc	ra,0x5
     c96:	1b8080e7          	jalr	440(ra) # 5e4a <exit>
    printf("%s: error: open big failed!\n", s);
     c9a:	85d6                	mv	a1,s5
     c9c:	00006517          	auipc	a0,0x6
     ca0:	f2450513          	addi	a0,a0,-220 # 6bc0 <uthread_self+0x4e6>
     ca4:	00005097          	auipc	ra,0x5
     ca8:	546080e7          	jalr	1350(ra) # 61ea <printf>
    exit(1);
     cac:	4505                	li	a0,1
     cae:	00005097          	auipc	ra,0x5
     cb2:	19c080e7          	jalr	412(ra) # 5e4a <exit>
      if(n == MAXFILE - 1){
     cb6:	10b00793          	li	a5,267
     cba:	02f48a63          	beq	s1,a5,cee <writebig+0x13e>
  close(fd);
     cbe:	854e                	mv	a0,s3
     cc0:	00005097          	auipc	ra,0x5
     cc4:	1b2080e7          	jalr	434(ra) # 5e72 <close>
  if(unlink("big") < 0){
     cc8:	00006517          	auipc	a0,0x6
     ccc:	ea850513          	addi	a0,a0,-344 # 6b70 <uthread_self+0x496>
     cd0:	00005097          	auipc	ra,0x5
     cd4:	1ca080e7          	jalr	458(ra) # 5e9a <unlink>
     cd8:	06054963          	bltz	a0,d4a <writebig+0x19a>
}
     cdc:	70e2                	ld	ra,56(sp)
     cde:	7442                	ld	s0,48(sp)
     ce0:	74a2                	ld	s1,40(sp)
     ce2:	7902                	ld	s2,32(sp)
     ce4:	69e2                	ld	s3,24(sp)
     ce6:	6a42                	ld	s4,16(sp)
     ce8:	6aa2                	ld	s5,8(sp)
     cea:	6121                	addi	sp,sp,64
     cec:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     cee:	10b00613          	li	a2,267
     cf2:	85d6                	mv	a1,s5
     cf4:	00006517          	auipc	a0,0x6
     cf8:	eec50513          	addi	a0,a0,-276 # 6be0 <uthread_self+0x506>
     cfc:	00005097          	auipc	ra,0x5
     d00:	4ee080e7          	jalr	1262(ra) # 61ea <printf>
        exit(1);
     d04:	4505                	li	a0,1
     d06:	00005097          	auipc	ra,0x5
     d0a:	144080e7          	jalr	324(ra) # 5e4a <exit>
      printf("%s: read failed %d\n", s, i);
     d0e:	862a                	mv	a2,a0
     d10:	85d6                	mv	a1,s5
     d12:	00006517          	auipc	a0,0x6
     d16:	ef650513          	addi	a0,a0,-266 # 6c08 <uthread_self+0x52e>
     d1a:	00005097          	auipc	ra,0x5
     d1e:	4d0080e7          	jalr	1232(ra) # 61ea <printf>
      exit(1);
     d22:	4505                	li	a0,1
     d24:	00005097          	auipc	ra,0x5
     d28:	126080e7          	jalr	294(ra) # 5e4a <exit>
      printf("%s: read content of block %d is %d\n", s,
     d2c:	8626                	mv	a2,s1
     d2e:	85d6                	mv	a1,s5
     d30:	00006517          	auipc	a0,0x6
     d34:	ef050513          	addi	a0,a0,-272 # 6c20 <uthread_self+0x546>
     d38:	00005097          	auipc	ra,0x5
     d3c:	4b2080e7          	jalr	1202(ra) # 61ea <printf>
      exit(1);
     d40:	4505                	li	a0,1
     d42:	00005097          	auipc	ra,0x5
     d46:	108080e7          	jalr	264(ra) # 5e4a <exit>
    printf("%s: unlink big failed\n", s);
     d4a:	85d6                	mv	a1,s5
     d4c:	00006517          	auipc	a0,0x6
     d50:	efc50513          	addi	a0,a0,-260 # 6c48 <uthread_self+0x56e>
     d54:	00005097          	auipc	ra,0x5
     d58:	496080e7          	jalr	1174(ra) # 61ea <printf>
    exit(1);
     d5c:	4505                	li	a0,1
     d5e:	00005097          	auipc	ra,0x5
     d62:	0ec080e7          	jalr	236(ra) # 5e4a <exit>

0000000000000d66 <unlinkread>:
{
     d66:	7179                	addi	sp,sp,-48
     d68:	f406                	sd	ra,40(sp)
     d6a:	f022                	sd	s0,32(sp)
     d6c:	ec26                	sd	s1,24(sp)
     d6e:	e84a                	sd	s2,16(sp)
     d70:	e44e                	sd	s3,8(sp)
     d72:	1800                	addi	s0,sp,48
     d74:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     d76:	20200593          	li	a1,514
     d7a:	00006517          	auipc	a0,0x6
     d7e:	ee650513          	addi	a0,a0,-282 # 6c60 <uthread_self+0x586>
     d82:	00005097          	auipc	ra,0x5
     d86:	108080e7          	jalr	264(ra) # 5e8a <open>
  if(fd < 0){
     d8a:	0e054563          	bltz	a0,e74 <unlinkread+0x10e>
     d8e:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     d90:	4615                	li	a2,5
     d92:	00006597          	auipc	a1,0x6
     d96:	efe58593          	addi	a1,a1,-258 # 6c90 <uthread_self+0x5b6>
     d9a:	00005097          	auipc	ra,0x5
     d9e:	0d0080e7          	jalr	208(ra) # 5e6a <write>
  close(fd);
     da2:	8526                	mv	a0,s1
     da4:	00005097          	auipc	ra,0x5
     da8:	0ce080e7          	jalr	206(ra) # 5e72 <close>
  fd = open("unlinkread", O_RDWR);
     dac:	4589                	li	a1,2
     dae:	00006517          	auipc	a0,0x6
     db2:	eb250513          	addi	a0,a0,-334 # 6c60 <uthread_self+0x586>
     db6:	00005097          	auipc	ra,0x5
     dba:	0d4080e7          	jalr	212(ra) # 5e8a <open>
     dbe:	84aa                	mv	s1,a0
  if(fd < 0){
     dc0:	0c054863          	bltz	a0,e90 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     dc4:	00006517          	auipc	a0,0x6
     dc8:	e9c50513          	addi	a0,a0,-356 # 6c60 <uthread_self+0x586>
     dcc:	00005097          	auipc	ra,0x5
     dd0:	0ce080e7          	jalr	206(ra) # 5e9a <unlink>
     dd4:	ed61                	bnez	a0,eac <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     dd6:	20200593          	li	a1,514
     dda:	00006517          	auipc	a0,0x6
     dde:	e8650513          	addi	a0,a0,-378 # 6c60 <uthread_self+0x586>
     de2:	00005097          	auipc	ra,0x5
     de6:	0a8080e7          	jalr	168(ra) # 5e8a <open>
     dea:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     dec:	460d                	li	a2,3
     dee:	00006597          	auipc	a1,0x6
     df2:	eea58593          	addi	a1,a1,-278 # 6cd8 <uthread_self+0x5fe>
     df6:	00005097          	auipc	ra,0x5
     dfa:	074080e7          	jalr	116(ra) # 5e6a <write>
  close(fd1);
     dfe:	854a                	mv	a0,s2
     e00:	00005097          	auipc	ra,0x5
     e04:	072080e7          	jalr	114(ra) # 5e72 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     e08:	660d                	lui	a2,0x3
     e0a:	0000c597          	auipc	a1,0xc
     e0e:	e9e58593          	addi	a1,a1,-354 # cca8 <buf>
     e12:	8526                	mv	a0,s1
     e14:	00005097          	auipc	ra,0x5
     e18:	04e080e7          	jalr	78(ra) # 5e62 <read>
     e1c:	4795                	li	a5,5
     e1e:	0af51563          	bne	a0,a5,ec8 <unlinkread+0x162>
  if(buf[0] != 'h'){
     e22:	0000c717          	auipc	a4,0xc
     e26:	e8674703          	lbu	a4,-378(a4) # cca8 <buf>
     e2a:	06800793          	li	a5,104
     e2e:	0af71b63          	bne	a4,a5,ee4 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     e32:	4629                	li	a2,10
     e34:	0000c597          	auipc	a1,0xc
     e38:	e7458593          	addi	a1,a1,-396 # cca8 <buf>
     e3c:	8526                	mv	a0,s1
     e3e:	00005097          	auipc	ra,0x5
     e42:	02c080e7          	jalr	44(ra) # 5e6a <write>
     e46:	47a9                	li	a5,10
     e48:	0af51c63          	bne	a0,a5,f00 <unlinkread+0x19a>
  close(fd);
     e4c:	8526                	mv	a0,s1
     e4e:	00005097          	auipc	ra,0x5
     e52:	024080e7          	jalr	36(ra) # 5e72 <close>
  unlink("unlinkread");
     e56:	00006517          	auipc	a0,0x6
     e5a:	e0a50513          	addi	a0,a0,-502 # 6c60 <uthread_self+0x586>
     e5e:	00005097          	auipc	ra,0x5
     e62:	03c080e7          	jalr	60(ra) # 5e9a <unlink>
}
     e66:	70a2                	ld	ra,40(sp)
     e68:	7402                	ld	s0,32(sp)
     e6a:	64e2                	ld	s1,24(sp)
     e6c:	6942                	ld	s2,16(sp)
     e6e:	69a2                	ld	s3,8(sp)
     e70:	6145                	addi	sp,sp,48
     e72:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     e74:	85ce                	mv	a1,s3
     e76:	00006517          	auipc	a0,0x6
     e7a:	dfa50513          	addi	a0,a0,-518 # 6c70 <uthread_self+0x596>
     e7e:	00005097          	auipc	ra,0x5
     e82:	36c080e7          	jalr	876(ra) # 61ea <printf>
    exit(1);
     e86:	4505                	li	a0,1
     e88:	00005097          	auipc	ra,0x5
     e8c:	fc2080e7          	jalr	-62(ra) # 5e4a <exit>
    printf("%s: open unlinkread failed\n", s);
     e90:	85ce                	mv	a1,s3
     e92:	00006517          	auipc	a0,0x6
     e96:	e0650513          	addi	a0,a0,-506 # 6c98 <uthread_self+0x5be>
     e9a:	00005097          	auipc	ra,0x5
     e9e:	350080e7          	jalr	848(ra) # 61ea <printf>
    exit(1);
     ea2:	4505                	li	a0,1
     ea4:	00005097          	auipc	ra,0x5
     ea8:	fa6080e7          	jalr	-90(ra) # 5e4a <exit>
    printf("%s: unlink unlinkread failed\n", s);
     eac:	85ce                	mv	a1,s3
     eae:	00006517          	auipc	a0,0x6
     eb2:	e0a50513          	addi	a0,a0,-502 # 6cb8 <uthread_self+0x5de>
     eb6:	00005097          	auipc	ra,0x5
     eba:	334080e7          	jalr	820(ra) # 61ea <printf>
    exit(1);
     ebe:	4505                	li	a0,1
     ec0:	00005097          	auipc	ra,0x5
     ec4:	f8a080e7          	jalr	-118(ra) # 5e4a <exit>
    printf("%s: unlinkread read failed", s);
     ec8:	85ce                	mv	a1,s3
     eca:	00006517          	auipc	a0,0x6
     ece:	e1650513          	addi	a0,a0,-490 # 6ce0 <uthread_self+0x606>
     ed2:	00005097          	auipc	ra,0x5
     ed6:	318080e7          	jalr	792(ra) # 61ea <printf>
    exit(1);
     eda:	4505                	li	a0,1
     edc:	00005097          	auipc	ra,0x5
     ee0:	f6e080e7          	jalr	-146(ra) # 5e4a <exit>
    printf("%s: unlinkread wrong data\n", s);
     ee4:	85ce                	mv	a1,s3
     ee6:	00006517          	auipc	a0,0x6
     eea:	e1a50513          	addi	a0,a0,-486 # 6d00 <uthread_self+0x626>
     eee:	00005097          	auipc	ra,0x5
     ef2:	2fc080e7          	jalr	764(ra) # 61ea <printf>
    exit(1);
     ef6:	4505                	li	a0,1
     ef8:	00005097          	auipc	ra,0x5
     efc:	f52080e7          	jalr	-174(ra) # 5e4a <exit>
    printf("%s: unlinkread write failed\n", s);
     f00:	85ce                	mv	a1,s3
     f02:	00006517          	auipc	a0,0x6
     f06:	e1e50513          	addi	a0,a0,-482 # 6d20 <uthread_self+0x646>
     f0a:	00005097          	auipc	ra,0x5
     f0e:	2e0080e7          	jalr	736(ra) # 61ea <printf>
    exit(1);
     f12:	4505                	li	a0,1
     f14:	00005097          	auipc	ra,0x5
     f18:	f36080e7          	jalr	-202(ra) # 5e4a <exit>

0000000000000f1c <linktest>:
{
     f1c:	1101                	addi	sp,sp,-32
     f1e:	ec06                	sd	ra,24(sp)
     f20:	e822                	sd	s0,16(sp)
     f22:	e426                	sd	s1,8(sp)
     f24:	e04a                	sd	s2,0(sp)
     f26:	1000                	addi	s0,sp,32
     f28:	892a                	mv	s2,a0
  unlink("lf1");
     f2a:	00006517          	auipc	a0,0x6
     f2e:	e1650513          	addi	a0,a0,-490 # 6d40 <uthread_self+0x666>
     f32:	00005097          	auipc	ra,0x5
     f36:	f68080e7          	jalr	-152(ra) # 5e9a <unlink>
  unlink("lf2");
     f3a:	00006517          	auipc	a0,0x6
     f3e:	e0e50513          	addi	a0,a0,-498 # 6d48 <uthread_self+0x66e>
     f42:	00005097          	auipc	ra,0x5
     f46:	f58080e7          	jalr	-168(ra) # 5e9a <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     f4a:	20200593          	li	a1,514
     f4e:	00006517          	auipc	a0,0x6
     f52:	df250513          	addi	a0,a0,-526 # 6d40 <uthread_self+0x666>
     f56:	00005097          	auipc	ra,0x5
     f5a:	f34080e7          	jalr	-204(ra) # 5e8a <open>
  if(fd < 0){
     f5e:	10054763          	bltz	a0,106c <linktest+0x150>
     f62:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     f64:	4615                	li	a2,5
     f66:	00006597          	auipc	a1,0x6
     f6a:	d2a58593          	addi	a1,a1,-726 # 6c90 <uthread_self+0x5b6>
     f6e:	00005097          	auipc	ra,0x5
     f72:	efc080e7          	jalr	-260(ra) # 5e6a <write>
     f76:	4795                	li	a5,5
     f78:	10f51863          	bne	a0,a5,1088 <linktest+0x16c>
  close(fd);
     f7c:	8526                	mv	a0,s1
     f7e:	00005097          	auipc	ra,0x5
     f82:	ef4080e7          	jalr	-268(ra) # 5e72 <close>
  if(link("lf1", "lf2") < 0){
     f86:	00006597          	auipc	a1,0x6
     f8a:	dc258593          	addi	a1,a1,-574 # 6d48 <uthread_self+0x66e>
     f8e:	00006517          	auipc	a0,0x6
     f92:	db250513          	addi	a0,a0,-590 # 6d40 <uthread_self+0x666>
     f96:	00005097          	auipc	ra,0x5
     f9a:	f14080e7          	jalr	-236(ra) # 5eaa <link>
     f9e:	10054363          	bltz	a0,10a4 <linktest+0x188>
  unlink("lf1");
     fa2:	00006517          	auipc	a0,0x6
     fa6:	d9e50513          	addi	a0,a0,-610 # 6d40 <uthread_self+0x666>
     faa:	00005097          	auipc	ra,0x5
     fae:	ef0080e7          	jalr	-272(ra) # 5e9a <unlink>
  if(open("lf1", 0) >= 0){
     fb2:	4581                	li	a1,0
     fb4:	00006517          	auipc	a0,0x6
     fb8:	d8c50513          	addi	a0,a0,-628 # 6d40 <uthread_self+0x666>
     fbc:	00005097          	auipc	ra,0x5
     fc0:	ece080e7          	jalr	-306(ra) # 5e8a <open>
     fc4:	0e055e63          	bgez	a0,10c0 <linktest+0x1a4>
  fd = open("lf2", 0);
     fc8:	4581                	li	a1,0
     fca:	00006517          	auipc	a0,0x6
     fce:	d7e50513          	addi	a0,a0,-642 # 6d48 <uthread_self+0x66e>
     fd2:	00005097          	auipc	ra,0x5
     fd6:	eb8080e7          	jalr	-328(ra) # 5e8a <open>
     fda:	84aa                	mv	s1,a0
  if(fd < 0){
     fdc:	10054063          	bltz	a0,10dc <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     fe0:	660d                	lui	a2,0x3
     fe2:	0000c597          	auipc	a1,0xc
     fe6:	cc658593          	addi	a1,a1,-826 # cca8 <buf>
     fea:	00005097          	auipc	ra,0x5
     fee:	e78080e7          	jalr	-392(ra) # 5e62 <read>
     ff2:	4795                	li	a5,5
     ff4:	10f51263          	bne	a0,a5,10f8 <linktest+0x1dc>
  close(fd);
     ff8:	8526                	mv	a0,s1
     ffa:	00005097          	auipc	ra,0x5
     ffe:	e78080e7          	jalr	-392(ra) # 5e72 <close>
  if(link("lf2", "lf2") >= 0){
    1002:	00006597          	auipc	a1,0x6
    1006:	d4658593          	addi	a1,a1,-698 # 6d48 <uthread_self+0x66e>
    100a:	852e                	mv	a0,a1
    100c:	00005097          	auipc	ra,0x5
    1010:	e9e080e7          	jalr	-354(ra) # 5eaa <link>
    1014:	10055063          	bgez	a0,1114 <linktest+0x1f8>
  unlink("lf2");
    1018:	00006517          	auipc	a0,0x6
    101c:	d3050513          	addi	a0,a0,-720 # 6d48 <uthread_self+0x66e>
    1020:	00005097          	auipc	ra,0x5
    1024:	e7a080e7          	jalr	-390(ra) # 5e9a <unlink>
  if(link("lf2", "lf1") >= 0){
    1028:	00006597          	auipc	a1,0x6
    102c:	d1858593          	addi	a1,a1,-744 # 6d40 <uthread_self+0x666>
    1030:	00006517          	auipc	a0,0x6
    1034:	d1850513          	addi	a0,a0,-744 # 6d48 <uthread_self+0x66e>
    1038:	00005097          	auipc	ra,0x5
    103c:	e72080e7          	jalr	-398(ra) # 5eaa <link>
    1040:	0e055863          	bgez	a0,1130 <linktest+0x214>
  if(link(".", "lf1") >= 0){
    1044:	00006597          	auipc	a1,0x6
    1048:	cfc58593          	addi	a1,a1,-772 # 6d40 <uthread_self+0x666>
    104c:	00006517          	auipc	a0,0x6
    1050:	e0450513          	addi	a0,a0,-508 # 6e50 <uthread_self+0x776>
    1054:	00005097          	auipc	ra,0x5
    1058:	e56080e7          	jalr	-426(ra) # 5eaa <link>
    105c:	0e055863          	bgez	a0,114c <linktest+0x230>
}
    1060:	60e2                	ld	ra,24(sp)
    1062:	6442                	ld	s0,16(sp)
    1064:	64a2                	ld	s1,8(sp)
    1066:	6902                	ld	s2,0(sp)
    1068:	6105                	addi	sp,sp,32
    106a:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    106c:	85ca                	mv	a1,s2
    106e:	00006517          	auipc	a0,0x6
    1072:	ce250513          	addi	a0,a0,-798 # 6d50 <uthread_self+0x676>
    1076:	00005097          	auipc	ra,0x5
    107a:	174080e7          	jalr	372(ra) # 61ea <printf>
    exit(1);
    107e:	4505                	li	a0,1
    1080:	00005097          	auipc	ra,0x5
    1084:	dca080e7          	jalr	-566(ra) # 5e4a <exit>
    printf("%s: write lf1 failed\n", s);
    1088:	85ca                	mv	a1,s2
    108a:	00006517          	auipc	a0,0x6
    108e:	cde50513          	addi	a0,a0,-802 # 6d68 <uthread_self+0x68e>
    1092:	00005097          	auipc	ra,0x5
    1096:	158080e7          	jalr	344(ra) # 61ea <printf>
    exit(1);
    109a:	4505                	li	a0,1
    109c:	00005097          	auipc	ra,0x5
    10a0:	dae080e7          	jalr	-594(ra) # 5e4a <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    10a4:	85ca                	mv	a1,s2
    10a6:	00006517          	auipc	a0,0x6
    10aa:	cda50513          	addi	a0,a0,-806 # 6d80 <uthread_self+0x6a6>
    10ae:	00005097          	auipc	ra,0x5
    10b2:	13c080e7          	jalr	316(ra) # 61ea <printf>
    exit(1);
    10b6:	4505                	li	a0,1
    10b8:	00005097          	auipc	ra,0x5
    10bc:	d92080e7          	jalr	-622(ra) # 5e4a <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    10c0:	85ca                	mv	a1,s2
    10c2:	00006517          	auipc	a0,0x6
    10c6:	cde50513          	addi	a0,a0,-802 # 6da0 <uthread_self+0x6c6>
    10ca:	00005097          	auipc	ra,0x5
    10ce:	120080e7          	jalr	288(ra) # 61ea <printf>
    exit(1);
    10d2:	4505                	li	a0,1
    10d4:	00005097          	auipc	ra,0x5
    10d8:	d76080e7          	jalr	-650(ra) # 5e4a <exit>
    printf("%s: open lf2 failed\n", s);
    10dc:	85ca                	mv	a1,s2
    10de:	00006517          	auipc	a0,0x6
    10e2:	cf250513          	addi	a0,a0,-782 # 6dd0 <uthread_self+0x6f6>
    10e6:	00005097          	auipc	ra,0x5
    10ea:	104080e7          	jalr	260(ra) # 61ea <printf>
    exit(1);
    10ee:	4505                	li	a0,1
    10f0:	00005097          	auipc	ra,0x5
    10f4:	d5a080e7          	jalr	-678(ra) # 5e4a <exit>
    printf("%s: read lf2 failed\n", s);
    10f8:	85ca                	mv	a1,s2
    10fa:	00006517          	auipc	a0,0x6
    10fe:	cee50513          	addi	a0,a0,-786 # 6de8 <uthread_self+0x70e>
    1102:	00005097          	auipc	ra,0x5
    1106:	0e8080e7          	jalr	232(ra) # 61ea <printf>
    exit(1);
    110a:	4505                	li	a0,1
    110c:	00005097          	auipc	ra,0x5
    1110:	d3e080e7          	jalr	-706(ra) # 5e4a <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    1114:	85ca                	mv	a1,s2
    1116:	00006517          	auipc	a0,0x6
    111a:	cea50513          	addi	a0,a0,-790 # 6e00 <uthread_self+0x726>
    111e:	00005097          	auipc	ra,0x5
    1122:	0cc080e7          	jalr	204(ra) # 61ea <printf>
    exit(1);
    1126:	4505                	li	a0,1
    1128:	00005097          	auipc	ra,0x5
    112c:	d22080e7          	jalr	-734(ra) # 5e4a <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    1130:	85ca                	mv	a1,s2
    1132:	00006517          	auipc	a0,0x6
    1136:	cf650513          	addi	a0,a0,-778 # 6e28 <uthread_self+0x74e>
    113a:	00005097          	auipc	ra,0x5
    113e:	0b0080e7          	jalr	176(ra) # 61ea <printf>
    exit(1);
    1142:	4505                	li	a0,1
    1144:	00005097          	auipc	ra,0x5
    1148:	d06080e7          	jalr	-762(ra) # 5e4a <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    114c:	85ca                	mv	a1,s2
    114e:	00006517          	auipc	a0,0x6
    1152:	d0a50513          	addi	a0,a0,-758 # 6e58 <uthread_self+0x77e>
    1156:	00005097          	auipc	ra,0x5
    115a:	094080e7          	jalr	148(ra) # 61ea <printf>
    exit(1);
    115e:	4505                	li	a0,1
    1160:	00005097          	auipc	ra,0x5
    1164:	cea080e7          	jalr	-790(ra) # 5e4a <exit>

0000000000001168 <validatetest>:
{
    1168:	7139                	addi	sp,sp,-64
    116a:	fc06                	sd	ra,56(sp)
    116c:	f822                	sd	s0,48(sp)
    116e:	f426                	sd	s1,40(sp)
    1170:	f04a                	sd	s2,32(sp)
    1172:	ec4e                	sd	s3,24(sp)
    1174:	e852                	sd	s4,16(sp)
    1176:	e456                	sd	s5,8(sp)
    1178:	e05a                	sd	s6,0(sp)
    117a:	0080                	addi	s0,sp,64
    117c:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    117e:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    1180:	00006997          	auipc	s3,0x6
    1184:	cf898993          	addi	s3,s3,-776 # 6e78 <uthread_self+0x79e>
    1188:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    118a:	6a85                	lui	s5,0x1
    118c:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1190:	85a6                	mv	a1,s1
    1192:	854e                	mv	a0,s3
    1194:	00005097          	auipc	ra,0x5
    1198:	d16080e7          	jalr	-746(ra) # 5eaa <link>
    119c:	01251f63          	bne	a0,s2,11ba <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    11a0:	94d6                	add	s1,s1,s5
    11a2:	ff4497e3          	bne	s1,s4,1190 <validatetest+0x28>
}
    11a6:	70e2                	ld	ra,56(sp)
    11a8:	7442                	ld	s0,48(sp)
    11aa:	74a2                	ld	s1,40(sp)
    11ac:	7902                	ld	s2,32(sp)
    11ae:	69e2                	ld	s3,24(sp)
    11b0:	6a42                	ld	s4,16(sp)
    11b2:	6aa2                	ld	s5,8(sp)
    11b4:	6b02                	ld	s6,0(sp)
    11b6:	6121                	addi	sp,sp,64
    11b8:	8082                	ret
      printf("%s: link should not succeed\n", s);
    11ba:	85da                	mv	a1,s6
    11bc:	00006517          	auipc	a0,0x6
    11c0:	ccc50513          	addi	a0,a0,-820 # 6e88 <uthread_self+0x7ae>
    11c4:	00005097          	auipc	ra,0x5
    11c8:	026080e7          	jalr	38(ra) # 61ea <printf>
      exit(1);
    11cc:	4505                	li	a0,1
    11ce:	00005097          	auipc	ra,0x5
    11d2:	c7c080e7          	jalr	-900(ra) # 5e4a <exit>

00000000000011d6 <bigdir>:
{
    11d6:	715d                	addi	sp,sp,-80
    11d8:	e486                	sd	ra,72(sp)
    11da:	e0a2                	sd	s0,64(sp)
    11dc:	fc26                	sd	s1,56(sp)
    11de:	f84a                	sd	s2,48(sp)
    11e0:	f44e                	sd	s3,40(sp)
    11e2:	f052                	sd	s4,32(sp)
    11e4:	ec56                	sd	s5,24(sp)
    11e6:	e85a                	sd	s6,16(sp)
    11e8:	0880                	addi	s0,sp,80
    11ea:	89aa                	mv	s3,a0
  unlink("bd");
    11ec:	00006517          	auipc	a0,0x6
    11f0:	cbc50513          	addi	a0,a0,-836 # 6ea8 <uthread_self+0x7ce>
    11f4:	00005097          	auipc	ra,0x5
    11f8:	ca6080e7          	jalr	-858(ra) # 5e9a <unlink>
  fd = open("bd", O_CREATE);
    11fc:	20000593          	li	a1,512
    1200:	00006517          	auipc	a0,0x6
    1204:	ca850513          	addi	a0,a0,-856 # 6ea8 <uthread_self+0x7ce>
    1208:	00005097          	auipc	ra,0x5
    120c:	c82080e7          	jalr	-894(ra) # 5e8a <open>
  if(fd < 0){
    1210:	0c054963          	bltz	a0,12e2 <bigdir+0x10c>
  close(fd);
    1214:	00005097          	auipc	ra,0x5
    1218:	c5e080e7          	jalr	-930(ra) # 5e72 <close>
  for(i = 0; i < N; i++){
    121c:	4901                	li	s2,0
    name[0] = 'x';
    121e:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    1222:	00006a17          	auipc	s4,0x6
    1226:	c86a0a13          	addi	s4,s4,-890 # 6ea8 <uthread_self+0x7ce>
  for(i = 0; i < N; i++){
    122a:	1f400b13          	li	s6,500
    name[0] = 'x';
    122e:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    1232:	41f9579b          	sraiw	a5,s2,0x1f
    1236:	01a7d71b          	srliw	a4,a5,0x1a
    123a:	012707bb          	addw	a5,a4,s2
    123e:	4067d69b          	sraiw	a3,a5,0x6
    1242:	0306869b          	addiw	a3,a3,48
    1246:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    124a:	03f7f793          	andi	a5,a5,63
    124e:	9f99                	subw	a5,a5,a4
    1250:	0307879b          	addiw	a5,a5,48
    1254:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1258:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    125c:	fb040593          	addi	a1,s0,-80
    1260:	8552                	mv	a0,s4
    1262:	00005097          	auipc	ra,0x5
    1266:	c48080e7          	jalr	-952(ra) # 5eaa <link>
    126a:	84aa                	mv	s1,a0
    126c:	e949                	bnez	a0,12fe <bigdir+0x128>
  for(i = 0; i < N; i++){
    126e:	2905                	addiw	s2,s2,1
    1270:	fb691fe3          	bne	s2,s6,122e <bigdir+0x58>
  unlink("bd");
    1274:	00006517          	auipc	a0,0x6
    1278:	c3450513          	addi	a0,a0,-972 # 6ea8 <uthread_self+0x7ce>
    127c:	00005097          	auipc	ra,0x5
    1280:	c1e080e7          	jalr	-994(ra) # 5e9a <unlink>
    name[0] = 'x';
    1284:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1288:	1f400a13          	li	s4,500
    name[0] = 'x';
    128c:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1290:	41f4d79b          	sraiw	a5,s1,0x1f
    1294:	01a7d71b          	srliw	a4,a5,0x1a
    1298:	009707bb          	addw	a5,a4,s1
    129c:	4067d69b          	sraiw	a3,a5,0x6
    12a0:	0306869b          	addiw	a3,a3,48
    12a4:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    12a8:	03f7f793          	andi	a5,a5,63
    12ac:	9f99                	subw	a5,a5,a4
    12ae:	0307879b          	addiw	a5,a5,48
    12b2:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    12b6:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    12ba:	fb040513          	addi	a0,s0,-80
    12be:	00005097          	auipc	ra,0x5
    12c2:	bdc080e7          	jalr	-1060(ra) # 5e9a <unlink>
    12c6:	ed21                	bnez	a0,131e <bigdir+0x148>
  for(i = 0; i < N; i++){
    12c8:	2485                	addiw	s1,s1,1
    12ca:	fd4491e3          	bne	s1,s4,128c <bigdir+0xb6>
}
    12ce:	60a6                	ld	ra,72(sp)
    12d0:	6406                	ld	s0,64(sp)
    12d2:	74e2                	ld	s1,56(sp)
    12d4:	7942                	ld	s2,48(sp)
    12d6:	79a2                	ld	s3,40(sp)
    12d8:	7a02                	ld	s4,32(sp)
    12da:	6ae2                	ld	s5,24(sp)
    12dc:	6b42                	ld	s6,16(sp)
    12de:	6161                	addi	sp,sp,80
    12e0:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    12e2:	85ce                	mv	a1,s3
    12e4:	00006517          	auipc	a0,0x6
    12e8:	bcc50513          	addi	a0,a0,-1076 # 6eb0 <uthread_self+0x7d6>
    12ec:	00005097          	auipc	ra,0x5
    12f0:	efe080e7          	jalr	-258(ra) # 61ea <printf>
    exit(1);
    12f4:	4505                	li	a0,1
    12f6:	00005097          	auipc	ra,0x5
    12fa:	b54080e7          	jalr	-1196(ra) # 5e4a <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    12fe:	fb040613          	addi	a2,s0,-80
    1302:	85ce                	mv	a1,s3
    1304:	00006517          	auipc	a0,0x6
    1308:	bcc50513          	addi	a0,a0,-1076 # 6ed0 <uthread_self+0x7f6>
    130c:	00005097          	auipc	ra,0x5
    1310:	ede080e7          	jalr	-290(ra) # 61ea <printf>
      exit(1);
    1314:	4505                	li	a0,1
    1316:	00005097          	auipc	ra,0x5
    131a:	b34080e7          	jalr	-1228(ra) # 5e4a <exit>
      printf("%s: bigdir unlink failed", s);
    131e:	85ce                	mv	a1,s3
    1320:	00006517          	auipc	a0,0x6
    1324:	bd050513          	addi	a0,a0,-1072 # 6ef0 <uthread_self+0x816>
    1328:	00005097          	auipc	ra,0x5
    132c:	ec2080e7          	jalr	-318(ra) # 61ea <printf>
      exit(1);
    1330:	4505                	li	a0,1
    1332:	00005097          	auipc	ra,0x5
    1336:	b18080e7          	jalr	-1256(ra) # 5e4a <exit>

000000000000133a <pgbug>:
{
    133a:	7179                	addi	sp,sp,-48
    133c:	f406                	sd	ra,40(sp)
    133e:	f022                	sd	s0,32(sp)
    1340:	ec26                	sd	s1,24(sp)
    1342:	1800                	addi	s0,sp,48
  argv[0] = 0;
    1344:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1348:	00008497          	auipc	s1,0x8
    134c:	cb848493          	addi	s1,s1,-840 # 9000 <big>
    1350:	fd840593          	addi	a1,s0,-40
    1354:	6088                	ld	a0,0(s1)
    1356:	00005097          	auipc	ra,0x5
    135a:	b2c080e7          	jalr	-1236(ra) # 5e82 <exec>
  pipe(big);
    135e:	6088                	ld	a0,0(s1)
    1360:	00005097          	auipc	ra,0x5
    1364:	afa080e7          	jalr	-1286(ra) # 5e5a <pipe>
  exit(0);
    1368:	4501                	li	a0,0
    136a:	00005097          	auipc	ra,0x5
    136e:	ae0080e7          	jalr	-1312(ra) # 5e4a <exit>

0000000000001372 <badarg>:
{
    1372:	7139                	addi	sp,sp,-64
    1374:	fc06                	sd	ra,56(sp)
    1376:	f822                	sd	s0,48(sp)
    1378:	f426                	sd	s1,40(sp)
    137a:	f04a                	sd	s2,32(sp)
    137c:	ec4e                	sd	s3,24(sp)
    137e:	0080                	addi	s0,sp,64
    1380:	64b1                	lui	s1,0xc
    1382:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1db8>
    argv[0] = (char*)0xffffffff;
    1386:	597d                	li	s2,-1
    1388:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    138c:	00005997          	auipc	s3,0x5
    1390:	3bc98993          	addi	s3,s3,956 # 6748 <uthread_self+0x6e>
    argv[0] = (char*)0xffffffff;
    1394:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1398:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    139c:	fc040593          	addi	a1,s0,-64
    13a0:	854e                	mv	a0,s3
    13a2:	00005097          	auipc	ra,0x5
    13a6:	ae0080e7          	jalr	-1312(ra) # 5e82 <exec>
  for(int i = 0; i < 50000; i++){
    13aa:	34fd                	addiw	s1,s1,-1
    13ac:	f4e5                	bnez	s1,1394 <badarg+0x22>
  exit(0);
    13ae:	4501                	li	a0,0
    13b0:	00005097          	auipc	ra,0x5
    13b4:	a9a080e7          	jalr	-1382(ra) # 5e4a <exit>

00000000000013b8 <copyinstr2>:
{
    13b8:	7155                	addi	sp,sp,-208
    13ba:	e586                	sd	ra,200(sp)
    13bc:	e1a2                	sd	s0,192(sp)
    13be:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    13c0:	f6840793          	addi	a5,s0,-152
    13c4:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    13c8:	07800713          	li	a4,120
    13cc:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    13d0:	0785                	addi	a5,a5,1
    13d2:	fed79de3          	bne	a5,a3,13cc <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    13d6:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    13da:	f6840513          	addi	a0,s0,-152
    13de:	00005097          	auipc	ra,0x5
    13e2:	abc080e7          	jalr	-1348(ra) # 5e9a <unlink>
  if(ret != -1){
    13e6:	57fd                	li	a5,-1
    13e8:	0ef51063          	bne	a0,a5,14c8 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    13ec:	20100593          	li	a1,513
    13f0:	f6840513          	addi	a0,s0,-152
    13f4:	00005097          	auipc	ra,0x5
    13f8:	a96080e7          	jalr	-1386(ra) # 5e8a <open>
  if(fd != -1){
    13fc:	57fd                	li	a5,-1
    13fe:	0ef51563          	bne	a0,a5,14e8 <copyinstr2+0x130>
  ret = link(b, b);
    1402:	f6840593          	addi	a1,s0,-152
    1406:	852e                	mv	a0,a1
    1408:	00005097          	auipc	ra,0x5
    140c:	aa2080e7          	jalr	-1374(ra) # 5eaa <link>
  if(ret != -1){
    1410:	57fd                	li	a5,-1
    1412:	0ef51b63          	bne	a0,a5,1508 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1416:	00007797          	auipc	a5,0x7
    141a:	d3278793          	addi	a5,a5,-718 # 8148 <uthread_self+0x1a6e>
    141e:	f4f43c23          	sd	a5,-168(s0)
    1422:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1426:	f5840593          	addi	a1,s0,-168
    142a:	f6840513          	addi	a0,s0,-152
    142e:	00005097          	auipc	ra,0x5
    1432:	a54080e7          	jalr	-1452(ra) # 5e82 <exec>
  if(ret != -1){
    1436:	57fd                	li	a5,-1
    1438:	0ef51963          	bne	a0,a5,152a <copyinstr2+0x172>
  int pid = fork();
    143c:	00005097          	auipc	ra,0x5
    1440:	a06080e7          	jalr	-1530(ra) # 5e42 <fork>
  if(pid < 0){
    1444:	10054363          	bltz	a0,154a <copyinstr2+0x192>
  if(pid == 0){
    1448:	12051463          	bnez	a0,1570 <copyinstr2+0x1b8>
    144c:	00008797          	auipc	a5,0x8
    1450:	14478793          	addi	a5,a5,324 # 9590 <big.0>
    1454:	00009697          	auipc	a3,0x9
    1458:	13c68693          	addi	a3,a3,316 # a590 <big.0+0x1000>
      big[i] = 'x';
    145c:	07800713          	li	a4,120
    1460:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1464:	0785                	addi	a5,a5,1
    1466:	fed79de3          	bne	a5,a3,1460 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    146a:	00009797          	auipc	a5,0x9
    146e:	12078323          	sb	zero,294(a5) # a590 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    1472:	00007797          	auipc	a5,0x7
    1476:	7ae78793          	addi	a5,a5,1966 # 8c20 <uthread_self+0x2546>
    147a:	6390                	ld	a2,0(a5)
    147c:	6794                	ld	a3,8(a5)
    147e:	6b98                	ld	a4,16(a5)
    1480:	6f9c                	ld	a5,24(a5)
    1482:	f2c43823          	sd	a2,-208(s0)
    1486:	f2d43c23          	sd	a3,-200(s0)
    148a:	f4e43023          	sd	a4,-192(s0)
    148e:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1492:	f3040593          	addi	a1,s0,-208
    1496:	00005517          	auipc	a0,0x5
    149a:	2b250513          	addi	a0,a0,690 # 6748 <uthread_self+0x6e>
    149e:	00005097          	auipc	ra,0x5
    14a2:	9e4080e7          	jalr	-1564(ra) # 5e82 <exec>
    if(ret != -1){
    14a6:	57fd                	li	a5,-1
    14a8:	0af50e63          	beq	a0,a5,1564 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    14ac:	55fd                	li	a1,-1
    14ae:	00006517          	auipc	a0,0x6
    14b2:	aea50513          	addi	a0,a0,-1302 # 6f98 <uthread_self+0x8be>
    14b6:	00005097          	auipc	ra,0x5
    14ba:	d34080e7          	jalr	-716(ra) # 61ea <printf>
      exit(1);
    14be:	4505                	li	a0,1
    14c0:	00005097          	auipc	ra,0x5
    14c4:	98a080e7          	jalr	-1654(ra) # 5e4a <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    14c8:	862a                	mv	a2,a0
    14ca:	f6840593          	addi	a1,s0,-152
    14ce:	00006517          	auipc	a0,0x6
    14d2:	a4250513          	addi	a0,a0,-1470 # 6f10 <uthread_self+0x836>
    14d6:	00005097          	auipc	ra,0x5
    14da:	d14080e7          	jalr	-748(ra) # 61ea <printf>
    exit(1);
    14de:	4505                	li	a0,1
    14e0:	00005097          	auipc	ra,0x5
    14e4:	96a080e7          	jalr	-1686(ra) # 5e4a <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    14e8:	862a                	mv	a2,a0
    14ea:	f6840593          	addi	a1,s0,-152
    14ee:	00006517          	auipc	a0,0x6
    14f2:	a4250513          	addi	a0,a0,-1470 # 6f30 <uthread_self+0x856>
    14f6:	00005097          	auipc	ra,0x5
    14fa:	cf4080e7          	jalr	-780(ra) # 61ea <printf>
    exit(1);
    14fe:	4505                	li	a0,1
    1500:	00005097          	auipc	ra,0x5
    1504:	94a080e7          	jalr	-1718(ra) # 5e4a <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1508:	86aa                	mv	a3,a0
    150a:	f6840613          	addi	a2,s0,-152
    150e:	85b2                	mv	a1,a2
    1510:	00006517          	auipc	a0,0x6
    1514:	a4050513          	addi	a0,a0,-1472 # 6f50 <uthread_self+0x876>
    1518:	00005097          	auipc	ra,0x5
    151c:	cd2080e7          	jalr	-814(ra) # 61ea <printf>
    exit(1);
    1520:	4505                	li	a0,1
    1522:	00005097          	auipc	ra,0x5
    1526:	928080e7          	jalr	-1752(ra) # 5e4a <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    152a:	567d                	li	a2,-1
    152c:	f6840593          	addi	a1,s0,-152
    1530:	00006517          	auipc	a0,0x6
    1534:	a4850513          	addi	a0,a0,-1464 # 6f78 <uthread_self+0x89e>
    1538:	00005097          	auipc	ra,0x5
    153c:	cb2080e7          	jalr	-846(ra) # 61ea <printf>
    exit(1);
    1540:	4505                	li	a0,1
    1542:	00005097          	auipc	ra,0x5
    1546:	908080e7          	jalr	-1784(ra) # 5e4a <exit>
    printf("fork failed\n");
    154a:	00006517          	auipc	a0,0x6
    154e:	eae50513          	addi	a0,a0,-338 # 73f8 <uthread_self+0xd1e>
    1552:	00005097          	auipc	ra,0x5
    1556:	c98080e7          	jalr	-872(ra) # 61ea <printf>
    exit(1);
    155a:	4505                	li	a0,1
    155c:	00005097          	auipc	ra,0x5
    1560:	8ee080e7          	jalr	-1810(ra) # 5e4a <exit>
    exit(747); // OK
    1564:	2eb00513          	li	a0,747
    1568:	00005097          	auipc	ra,0x5
    156c:	8e2080e7          	jalr	-1822(ra) # 5e4a <exit>
  int st = 0;
    1570:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1574:	f5440513          	addi	a0,s0,-172
    1578:	00005097          	auipc	ra,0x5
    157c:	8da080e7          	jalr	-1830(ra) # 5e52 <wait>
  if(st != 747){
    1580:	f5442703          	lw	a4,-172(s0)
    1584:	2eb00793          	li	a5,747
    1588:	00f71663          	bne	a4,a5,1594 <copyinstr2+0x1dc>
}
    158c:	60ae                	ld	ra,200(sp)
    158e:	640e                	ld	s0,192(sp)
    1590:	6169                	addi	sp,sp,208
    1592:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    1594:	00006517          	auipc	a0,0x6
    1598:	a2c50513          	addi	a0,a0,-1492 # 6fc0 <uthread_self+0x8e6>
    159c:	00005097          	auipc	ra,0x5
    15a0:	c4e080e7          	jalr	-946(ra) # 61ea <printf>
    exit(1);
    15a4:	4505                	li	a0,1
    15a6:	00005097          	auipc	ra,0x5
    15aa:	8a4080e7          	jalr	-1884(ra) # 5e4a <exit>

00000000000015ae <truncate3>:
{
    15ae:	7159                	addi	sp,sp,-112
    15b0:	f486                	sd	ra,104(sp)
    15b2:	f0a2                	sd	s0,96(sp)
    15b4:	eca6                	sd	s1,88(sp)
    15b6:	e8ca                	sd	s2,80(sp)
    15b8:	e4ce                	sd	s3,72(sp)
    15ba:	e0d2                	sd	s4,64(sp)
    15bc:	fc56                	sd	s5,56(sp)
    15be:	1880                	addi	s0,sp,112
    15c0:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    15c2:	60100593          	li	a1,1537
    15c6:	00005517          	auipc	a0,0x5
    15ca:	1da50513          	addi	a0,a0,474 # 67a0 <uthread_self+0xc6>
    15ce:	00005097          	auipc	ra,0x5
    15d2:	8bc080e7          	jalr	-1860(ra) # 5e8a <open>
    15d6:	00005097          	auipc	ra,0x5
    15da:	89c080e7          	jalr	-1892(ra) # 5e72 <close>
  pid = fork();
    15de:	00005097          	auipc	ra,0x5
    15e2:	864080e7          	jalr	-1948(ra) # 5e42 <fork>
  if(pid < 0){
    15e6:	08054063          	bltz	a0,1666 <truncate3+0xb8>
  if(pid == 0){
    15ea:	e969                	bnez	a0,16bc <truncate3+0x10e>
    15ec:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    15f0:	00005a17          	auipc	s4,0x5
    15f4:	1b0a0a13          	addi	s4,s4,432 # 67a0 <uthread_self+0xc6>
      int n = write(fd, "1234567890", 10);
    15f8:	00006a97          	auipc	s5,0x6
    15fc:	a28a8a93          	addi	s5,s5,-1496 # 7020 <uthread_self+0x946>
      int fd = open("truncfile", O_WRONLY);
    1600:	4585                	li	a1,1
    1602:	8552                	mv	a0,s4
    1604:	00005097          	auipc	ra,0x5
    1608:	886080e7          	jalr	-1914(ra) # 5e8a <open>
    160c:	84aa                	mv	s1,a0
      if(fd < 0){
    160e:	06054a63          	bltz	a0,1682 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1612:	4629                	li	a2,10
    1614:	85d6                	mv	a1,s5
    1616:	00005097          	auipc	ra,0x5
    161a:	854080e7          	jalr	-1964(ra) # 5e6a <write>
      if(n != 10){
    161e:	47a9                	li	a5,10
    1620:	06f51f63          	bne	a0,a5,169e <truncate3+0xf0>
      close(fd);
    1624:	8526                	mv	a0,s1
    1626:	00005097          	auipc	ra,0x5
    162a:	84c080e7          	jalr	-1972(ra) # 5e72 <close>
      fd = open("truncfile", O_RDONLY);
    162e:	4581                	li	a1,0
    1630:	8552                	mv	a0,s4
    1632:	00005097          	auipc	ra,0x5
    1636:	858080e7          	jalr	-1960(ra) # 5e8a <open>
    163a:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    163c:	02000613          	li	a2,32
    1640:	f9840593          	addi	a1,s0,-104
    1644:	00005097          	auipc	ra,0x5
    1648:	81e080e7          	jalr	-2018(ra) # 5e62 <read>
      close(fd);
    164c:	8526                	mv	a0,s1
    164e:	00005097          	auipc	ra,0x5
    1652:	824080e7          	jalr	-2012(ra) # 5e72 <close>
    for(int i = 0; i < 100; i++){
    1656:	39fd                	addiw	s3,s3,-1
    1658:	fa0994e3          	bnez	s3,1600 <truncate3+0x52>
    exit(0);
    165c:	4501                	li	a0,0
    165e:	00004097          	auipc	ra,0x4
    1662:	7ec080e7          	jalr	2028(ra) # 5e4a <exit>
    printf("%s: fork failed\n", s);
    1666:	85ca                	mv	a1,s2
    1668:	00006517          	auipc	a0,0x6
    166c:	98850513          	addi	a0,a0,-1656 # 6ff0 <uthread_self+0x916>
    1670:	00005097          	auipc	ra,0x5
    1674:	b7a080e7          	jalr	-1158(ra) # 61ea <printf>
    exit(1);
    1678:	4505                	li	a0,1
    167a:	00004097          	auipc	ra,0x4
    167e:	7d0080e7          	jalr	2000(ra) # 5e4a <exit>
        printf("%s: open failed\n", s);
    1682:	85ca                	mv	a1,s2
    1684:	00006517          	auipc	a0,0x6
    1688:	98450513          	addi	a0,a0,-1660 # 7008 <uthread_self+0x92e>
    168c:	00005097          	auipc	ra,0x5
    1690:	b5e080e7          	jalr	-1186(ra) # 61ea <printf>
        exit(1);
    1694:	4505                	li	a0,1
    1696:	00004097          	auipc	ra,0x4
    169a:	7b4080e7          	jalr	1972(ra) # 5e4a <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    169e:	862a                	mv	a2,a0
    16a0:	85ca                	mv	a1,s2
    16a2:	00006517          	auipc	a0,0x6
    16a6:	98e50513          	addi	a0,a0,-1650 # 7030 <uthread_self+0x956>
    16aa:	00005097          	auipc	ra,0x5
    16ae:	b40080e7          	jalr	-1216(ra) # 61ea <printf>
        exit(1);
    16b2:	4505                	li	a0,1
    16b4:	00004097          	auipc	ra,0x4
    16b8:	796080e7          	jalr	1942(ra) # 5e4a <exit>
    16bc:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    16c0:	00005a17          	auipc	s4,0x5
    16c4:	0e0a0a13          	addi	s4,s4,224 # 67a0 <uthread_self+0xc6>
    int n = write(fd, "xxx", 3);
    16c8:	00006a97          	auipc	s5,0x6
    16cc:	988a8a93          	addi	s5,s5,-1656 # 7050 <uthread_self+0x976>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    16d0:	60100593          	li	a1,1537
    16d4:	8552                	mv	a0,s4
    16d6:	00004097          	auipc	ra,0x4
    16da:	7b4080e7          	jalr	1972(ra) # 5e8a <open>
    16de:	84aa                	mv	s1,a0
    if(fd < 0){
    16e0:	04054763          	bltz	a0,172e <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    16e4:	460d                	li	a2,3
    16e6:	85d6                	mv	a1,s5
    16e8:	00004097          	auipc	ra,0x4
    16ec:	782080e7          	jalr	1922(ra) # 5e6a <write>
    if(n != 3){
    16f0:	478d                	li	a5,3
    16f2:	04f51c63          	bne	a0,a5,174a <truncate3+0x19c>
    close(fd);
    16f6:	8526                	mv	a0,s1
    16f8:	00004097          	auipc	ra,0x4
    16fc:	77a080e7          	jalr	1914(ra) # 5e72 <close>
  for(int i = 0; i < 150; i++){
    1700:	39fd                	addiw	s3,s3,-1
    1702:	fc0997e3          	bnez	s3,16d0 <truncate3+0x122>
  wait(&xstatus);
    1706:	fbc40513          	addi	a0,s0,-68
    170a:	00004097          	auipc	ra,0x4
    170e:	748080e7          	jalr	1864(ra) # 5e52 <wait>
  unlink("truncfile");
    1712:	00005517          	auipc	a0,0x5
    1716:	08e50513          	addi	a0,a0,142 # 67a0 <uthread_self+0xc6>
    171a:	00004097          	auipc	ra,0x4
    171e:	780080e7          	jalr	1920(ra) # 5e9a <unlink>
  exit(xstatus);
    1722:	fbc42503          	lw	a0,-68(s0)
    1726:	00004097          	auipc	ra,0x4
    172a:	724080e7          	jalr	1828(ra) # 5e4a <exit>
      printf("%s: open failed\n", s);
    172e:	85ca                	mv	a1,s2
    1730:	00006517          	auipc	a0,0x6
    1734:	8d850513          	addi	a0,a0,-1832 # 7008 <uthread_self+0x92e>
    1738:	00005097          	auipc	ra,0x5
    173c:	ab2080e7          	jalr	-1358(ra) # 61ea <printf>
      exit(1);
    1740:	4505                	li	a0,1
    1742:	00004097          	auipc	ra,0x4
    1746:	708080e7          	jalr	1800(ra) # 5e4a <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    174a:	862a                	mv	a2,a0
    174c:	85ca                	mv	a1,s2
    174e:	00006517          	auipc	a0,0x6
    1752:	90a50513          	addi	a0,a0,-1782 # 7058 <uthread_self+0x97e>
    1756:	00005097          	auipc	ra,0x5
    175a:	a94080e7          	jalr	-1388(ra) # 61ea <printf>
      exit(1);
    175e:	4505                	li	a0,1
    1760:	00004097          	auipc	ra,0x4
    1764:	6ea080e7          	jalr	1770(ra) # 5e4a <exit>

0000000000001768 <exectest>:
{
    1768:	715d                	addi	sp,sp,-80
    176a:	e486                	sd	ra,72(sp)
    176c:	e0a2                	sd	s0,64(sp)
    176e:	fc26                	sd	s1,56(sp)
    1770:	f84a                	sd	s2,48(sp)
    1772:	0880                	addi	s0,sp,80
    1774:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1776:	00005797          	auipc	a5,0x5
    177a:	fd278793          	addi	a5,a5,-46 # 6748 <uthread_self+0x6e>
    177e:	fcf43023          	sd	a5,-64(s0)
    1782:	00006797          	auipc	a5,0x6
    1786:	8f678793          	addi	a5,a5,-1802 # 7078 <uthread_self+0x99e>
    178a:	fcf43423          	sd	a5,-56(s0)
    178e:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1792:	00006517          	auipc	a0,0x6
    1796:	8ee50513          	addi	a0,a0,-1810 # 7080 <uthread_self+0x9a6>
    179a:	00004097          	auipc	ra,0x4
    179e:	700080e7          	jalr	1792(ra) # 5e9a <unlink>
  pid = fork();
    17a2:	00004097          	auipc	ra,0x4
    17a6:	6a0080e7          	jalr	1696(ra) # 5e42 <fork>
  if(pid < 0) {
    17aa:	04054663          	bltz	a0,17f6 <exectest+0x8e>
    17ae:	84aa                	mv	s1,a0
  if(pid == 0) {
    17b0:	e959                	bnez	a0,1846 <exectest+0xde>
    close(1);
    17b2:	4505                	li	a0,1
    17b4:	00004097          	auipc	ra,0x4
    17b8:	6be080e7          	jalr	1726(ra) # 5e72 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    17bc:	20100593          	li	a1,513
    17c0:	00006517          	auipc	a0,0x6
    17c4:	8c050513          	addi	a0,a0,-1856 # 7080 <uthread_self+0x9a6>
    17c8:	00004097          	auipc	ra,0x4
    17cc:	6c2080e7          	jalr	1730(ra) # 5e8a <open>
    if(fd < 0) {
    17d0:	04054163          	bltz	a0,1812 <exectest+0xaa>
    if(fd != 1) {
    17d4:	4785                	li	a5,1
    17d6:	04f50c63          	beq	a0,a5,182e <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    17da:	85ca                	mv	a1,s2
    17dc:	00006517          	auipc	a0,0x6
    17e0:	8c450513          	addi	a0,a0,-1852 # 70a0 <uthread_self+0x9c6>
    17e4:	00005097          	auipc	ra,0x5
    17e8:	a06080e7          	jalr	-1530(ra) # 61ea <printf>
      exit(1);
    17ec:	4505                	li	a0,1
    17ee:	00004097          	auipc	ra,0x4
    17f2:	65c080e7          	jalr	1628(ra) # 5e4a <exit>
     printf("%s: fork failed\n", s);
    17f6:	85ca                	mv	a1,s2
    17f8:	00005517          	auipc	a0,0x5
    17fc:	7f850513          	addi	a0,a0,2040 # 6ff0 <uthread_self+0x916>
    1800:	00005097          	auipc	ra,0x5
    1804:	9ea080e7          	jalr	-1558(ra) # 61ea <printf>
     exit(1);
    1808:	4505                	li	a0,1
    180a:	00004097          	auipc	ra,0x4
    180e:	640080e7          	jalr	1600(ra) # 5e4a <exit>
      printf("%s: create failed\n", s);
    1812:	85ca                	mv	a1,s2
    1814:	00006517          	auipc	a0,0x6
    1818:	87450513          	addi	a0,a0,-1932 # 7088 <uthread_self+0x9ae>
    181c:	00005097          	auipc	ra,0x5
    1820:	9ce080e7          	jalr	-1586(ra) # 61ea <printf>
      exit(1);
    1824:	4505                	li	a0,1
    1826:	00004097          	auipc	ra,0x4
    182a:	624080e7          	jalr	1572(ra) # 5e4a <exit>
    if(exec("echo", echoargv) < 0){
    182e:	fc040593          	addi	a1,s0,-64
    1832:	00005517          	auipc	a0,0x5
    1836:	f1650513          	addi	a0,a0,-234 # 6748 <uthread_self+0x6e>
    183a:	00004097          	auipc	ra,0x4
    183e:	648080e7          	jalr	1608(ra) # 5e82 <exec>
    1842:	02054163          	bltz	a0,1864 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1846:	fdc40513          	addi	a0,s0,-36
    184a:	00004097          	auipc	ra,0x4
    184e:	608080e7          	jalr	1544(ra) # 5e52 <wait>
    1852:	02951763          	bne	a0,s1,1880 <exectest+0x118>
  if(xstatus != 0)
    1856:	fdc42503          	lw	a0,-36(s0)
    185a:	cd0d                	beqz	a0,1894 <exectest+0x12c>
    exit(xstatus);
    185c:	00004097          	auipc	ra,0x4
    1860:	5ee080e7          	jalr	1518(ra) # 5e4a <exit>
      printf("%s: exec echo failed\n", s);
    1864:	85ca                	mv	a1,s2
    1866:	00006517          	auipc	a0,0x6
    186a:	84a50513          	addi	a0,a0,-1974 # 70b0 <uthread_self+0x9d6>
    186e:	00005097          	auipc	ra,0x5
    1872:	97c080e7          	jalr	-1668(ra) # 61ea <printf>
      exit(1);
    1876:	4505                	li	a0,1
    1878:	00004097          	auipc	ra,0x4
    187c:	5d2080e7          	jalr	1490(ra) # 5e4a <exit>
    printf("%s: wait failed!\n", s);
    1880:	85ca                	mv	a1,s2
    1882:	00006517          	auipc	a0,0x6
    1886:	84650513          	addi	a0,a0,-1978 # 70c8 <uthread_self+0x9ee>
    188a:	00005097          	auipc	ra,0x5
    188e:	960080e7          	jalr	-1696(ra) # 61ea <printf>
    1892:	b7d1                	j	1856 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    1894:	4581                	li	a1,0
    1896:	00005517          	auipc	a0,0x5
    189a:	7ea50513          	addi	a0,a0,2026 # 7080 <uthread_self+0x9a6>
    189e:	00004097          	auipc	ra,0x4
    18a2:	5ec080e7          	jalr	1516(ra) # 5e8a <open>
  if(fd < 0) {
    18a6:	02054a63          	bltz	a0,18da <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    18aa:	4609                	li	a2,2
    18ac:	fb840593          	addi	a1,s0,-72
    18b0:	00004097          	auipc	ra,0x4
    18b4:	5b2080e7          	jalr	1458(ra) # 5e62 <read>
    18b8:	4789                	li	a5,2
    18ba:	02f50e63          	beq	a0,a5,18f6 <exectest+0x18e>
    printf("%s: read failed\n", s);
    18be:	85ca                	mv	a1,s2
    18c0:	00005517          	auipc	a0,0x5
    18c4:	27850513          	addi	a0,a0,632 # 6b38 <uthread_self+0x45e>
    18c8:	00005097          	auipc	ra,0x5
    18cc:	922080e7          	jalr	-1758(ra) # 61ea <printf>
    exit(1);
    18d0:	4505                	li	a0,1
    18d2:	00004097          	auipc	ra,0x4
    18d6:	578080e7          	jalr	1400(ra) # 5e4a <exit>
    printf("%s: open failed\n", s);
    18da:	85ca                	mv	a1,s2
    18dc:	00005517          	auipc	a0,0x5
    18e0:	72c50513          	addi	a0,a0,1836 # 7008 <uthread_self+0x92e>
    18e4:	00005097          	auipc	ra,0x5
    18e8:	906080e7          	jalr	-1786(ra) # 61ea <printf>
    exit(1);
    18ec:	4505                	li	a0,1
    18ee:	00004097          	auipc	ra,0x4
    18f2:	55c080e7          	jalr	1372(ra) # 5e4a <exit>
  unlink("echo-ok");
    18f6:	00005517          	auipc	a0,0x5
    18fa:	78a50513          	addi	a0,a0,1930 # 7080 <uthread_self+0x9a6>
    18fe:	00004097          	auipc	ra,0x4
    1902:	59c080e7          	jalr	1436(ra) # 5e9a <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1906:	fb844703          	lbu	a4,-72(s0)
    190a:	04f00793          	li	a5,79
    190e:	00f71863          	bne	a4,a5,191e <exectest+0x1b6>
    1912:	fb944703          	lbu	a4,-71(s0)
    1916:	04b00793          	li	a5,75
    191a:	02f70063          	beq	a4,a5,193a <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    191e:	85ca                	mv	a1,s2
    1920:	00005517          	auipc	a0,0x5
    1924:	7c050513          	addi	a0,a0,1984 # 70e0 <uthread_self+0xa06>
    1928:	00005097          	auipc	ra,0x5
    192c:	8c2080e7          	jalr	-1854(ra) # 61ea <printf>
    exit(1);
    1930:	4505                	li	a0,1
    1932:	00004097          	auipc	ra,0x4
    1936:	518080e7          	jalr	1304(ra) # 5e4a <exit>
    exit(0);
    193a:	4501                	li	a0,0
    193c:	00004097          	auipc	ra,0x4
    1940:	50e080e7          	jalr	1294(ra) # 5e4a <exit>

0000000000001944 <pipe1>:
{
    1944:	711d                	addi	sp,sp,-96
    1946:	ec86                	sd	ra,88(sp)
    1948:	e8a2                	sd	s0,80(sp)
    194a:	e4a6                	sd	s1,72(sp)
    194c:	e0ca                	sd	s2,64(sp)
    194e:	fc4e                	sd	s3,56(sp)
    1950:	f852                	sd	s4,48(sp)
    1952:	f456                	sd	s5,40(sp)
    1954:	f05a                	sd	s6,32(sp)
    1956:	ec5e                	sd	s7,24(sp)
    1958:	1080                	addi	s0,sp,96
    195a:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    195c:	fa840513          	addi	a0,s0,-88
    1960:	00004097          	auipc	ra,0x4
    1964:	4fa080e7          	jalr	1274(ra) # 5e5a <pipe>
    1968:	ed25                	bnez	a0,19e0 <pipe1+0x9c>
    196a:	84aa                	mv	s1,a0
  pid = fork();
    196c:	00004097          	auipc	ra,0x4
    1970:	4d6080e7          	jalr	1238(ra) # 5e42 <fork>
    1974:	8a2a                	mv	s4,a0
  if(pid == 0){
    1976:	c159                	beqz	a0,19fc <pipe1+0xb8>
  } else if(pid > 0){
    1978:	16a05e63          	blez	a0,1af4 <pipe1+0x1b0>
    close(fds[1]);
    197c:	fac42503          	lw	a0,-84(s0)
    1980:	00004097          	auipc	ra,0x4
    1984:	4f2080e7          	jalr	1266(ra) # 5e72 <close>
    total = 0;
    1988:	8a26                	mv	s4,s1
    cc = 1;
    198a:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    198c:	0000ba97          	auipc	s5,0xb
    1990:	31ca8a93          	addi	s5,s5,796 # cca8 <buf>
      if(cc > sizeof(buf))
    1994:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1996:	864e                	mv	a2,s3
    1998:	85d6                	mv	a1,s5
    199a:	fa842503          	lw	a0,-88(s0)
    199e:	00004097          	auipc	ra,0x4
    19a2:	4c4080e7          	jalr	1220(ra) # 5e62 <read>
    19a6:	10a05263          	blez	a0,1aaa <pipe1+0x166>
      for(i = 0; i < n; i++){
    19aa:	0000b717          	auipc	a4,0xb
    19ae:	2fe70713          	addi	a4,a4,766 # cca8 <buf>
    19b2:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    19b6:	00074683          	lbu	a3,0(a4)
    19ba:	0ff4f793          	andi	a5,s1,255
    19be:	2485                	addiw	s1,s1,1
    19c0:	0cf69163          	bne	a3,a5,1a82 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    19c4:	0705                	addi	a4,a4,1
    19c6:	fec498e3          	bne	s1,a2,19b6 <pipe1+0x72>
      total += n;
    19ca:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    19ce:	0019979b          	slliw	a5,s3,0x1
    19d2:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    19d6:	013b7363          	bgeu	s6,s3,19dc <pipe1+0x98>
        cc = sizeof(buf);
    19da:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    19dc:	84b2                	mv	s1,a2
    19de:	bf65                	j	1996 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    19e0:	85ca                	mv	a1,s2
    19e2:	00005517          	auipc	a0,0x5
    19e6:	71650513          	addi	a0,a0,1814 # 70f8 <uthread_self+0xa1e>
    19ea:	00005097          	auipc	ra,0x5
    19ee:	800080e7          	jalr	-2048(ra) # 61ea <printf>
    exit(1);
    19f2:	4505                	li	a0,1
    19f4:	00004097          	auipc	ra,0x4
    19f8:	456080e7          	jalr	1110(ra) # 5e4a <exit>
    close(fds[0]);
    19fc:	fa842503          	lw	a0,-88(s0)
    1a00:	00004097          	auipc	ra,0x4
    1a04:	472080e7          	jalr	1138(ra) # 5e72 <close>
    for(n = 0; n < N; n++){
    1a08:	0000bb17          	auipc	s6,0xb
    1a0c:	2a0b0b13          	addi	s6,s6,672 # cca8 <buf>
    1a10:	416004bb          	negw	s1,s6
    1a14:	0ff4f493          	andi	s1,s1,255
    1a18:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1a1c:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1a1e:	6a85                	lui	s5,0x1
    1a20:	42da8a93          	addi	s5,s5,1069 # 142d <copyinstr2+0x75>
{
    1a24:	87da                	mv	a5,s6
        buf[i] = seq++;
    1a26:	0097873b          	addw	a4,a5,s1
    1a2a:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1a2e:	0785                	addi	a5,a5,1
    1a30:	fef99be3          	bne	s3,a5,1a26 <pipe1+0xe2>
        buf[i] = seq++;
    1a34:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1a38:	40900613          	li	a2,1033
    1a3c:	85de                	mv	a1,s7
    1a3e:	fac42503          	lw	a0,-84(s0)
    1a42:	00004097          	auipc	ra,0x4
    1a46:	428080e7          	jalr	1064(ra) # 5e6a <write>
    1a4a:	40900793          	li	a5,1033
    1a4e:	00f51c63          	bne	a0,a5,1a66 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1a52:	24a5                	addiw	s1,s1,9
    1a54:	0ff4f493          	andi	s1,s1,255
    1a58:	fd5a16e3          	bne	s4,s5,1a24 <pipe1+0xe0>
    exit(0);
    1a5c:	4501                	li	a0,0
    1a5e:	00004097          	auipc	ra,0x4
    1a62:	3ec080e7          	jalr	1004(ra) # 5e4a <exit>
        printf("%s: pipe1 oops 1\n", s);
    1a66:	85ca                	mv	a1,s2
    1a68:	00005517          	auipc	a0,0x5
    1a6c:	6a850513          	addi	a0,a0,1704 # 7110 <uthread_self+0xa36>
    1a70:	00004097          	auipc	ra,0x4
    1a74:	77a080e7          	jalr	1914(ra) # 61ea <printf>
        exit(1);
    1a78:	4505                	li	a0,1
    1a7a:	00004097          	auipc	ra,0x4
    1a7e:	3d0080e7          	jalr	976(ra) # 5e4a <exit>
          printf("%s: pipe1 oops 2\n", s);
    1a82:	85ca                	mv	a1,s2
    1a84:	00005517          	auipc	a0,0x5
    1a88:	6a450513          	addi	a0,a0,1700 # 7128 <uthread_self+0xa4e>
    1a8c:	00004097          	auipc	ra,0x4
    1a90:	75e080e7          	jalr	1886(ra) # 61ea <printf>
}
    1a94:	60e6                	ld	ra,88(sp)
    1a96:	6446                	ld	s0,80(sp)
    1a98:	64a6                	ld	s1,72(sp)
    1a9a:	6906                	ld	s2,64(sp)
    1a9c:	79e2                	ld	s3,56(sp)
    1a9e:	7a42                	ld	s4,48(sp)
    1aa0:	7aa2                	ld	s5,40(sp)
    1aa2:	7b02                	ld	s6,32(sp)
    1aa4:	6be2                	ld	s7,24(sp)
    1aa6:	6125                	addi	sp,sp,96
    1aa8:	8082                	ret
    if(total != N * SZ){
    1aaa:	6785                	lui	a5,0x1
    1aac:	42d78793          	addi	a5,a5,1069 # 142d <copyinstr2+0x75>
    1ab0:	02fa0063          	beq	s4,a5,1ad0 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1ab4:	85d2                	mv	a1,s4
    1ab6:	00005517          	auipc	a0,0x5
    1aba:	68a50513          	addi	a0,a0,1674 # 7140 <uthread_self+0xa66>
    1abe:	00004097          	auipc	ra,0x4
    1ac2:	72c080e7          	jalr	1836(ra) # 61ea <printf>
      exit(1);
    1ac6:	4505                	li	a0,1
    1ac8:	00004097          	auipc	ra,0x4
    1acc:	382080e7          	jalr	898(ra) # 5e4a <exit>
    close(fds[0]);
    1ad0:	fa842503          	lw	a0,-88(s0)
    1ad4:	00004097          	auipc	ra,0x4
    1ad8:	39e080e7          	jalr	926(ra) # 5e72 <close>
    wait(&xstatus);
    1adc:	fa440513          	addi	a0,s0,-92
    1ae0:	00004097          	auipc	ra,0x4
    1ae4:	372080e7          	jalr	882(ra) # 5e52 <wait>
    exit(xstatus);
    1ae8:	fa442503          	lw	a0,-92(s0)
    1aec:	00004097          	auipc	ra,0x4
    1af0:	35e080e7          	jalr	862(ra) # 5e4a <exit>
    printf("%s: fork() failed\n", s);
    1af4:	85ca                	mv	a1,s2
    1af6:	00005517          	auipc	a0,0x5
    1afa:	66a50513          	addi	a0,a0,1642 # 7160 <uthread_self+0xa86>
    1afe:	00004097          	auipc	ra,0x4
    1b02:	6ec080e7          	jalr	1772(ra) # 61ea <printf>
    exit(1);
    1b06:	4505                	li	a0,1
    1b08:	00004097          	auipc	ra,0x4
    1b0c:	342080e7          	jalr	834(ra) # 5e4a <exit>

0000000000001b10 <exitwait>:
{
    1b10:	7139                	addi	sp,sp,-64
    1b12:	fc06                	sd	ra,56(sp)
    1b14:	f822                	sd	s0,48(sp)
    1b16:	f426                	sd	s1,40(sp)
    1b18:	f04a                	sd	s2,32(sp)
    1b1a:	ec4e                	sd	s3,24(sp)
    1b1c:	e852                	sd	s4,16(sp)
    1b1e:	0080                	addi	s0,sp,64
    1b20:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1b22:	4901                	li	s2,0
    1b24:	06400993          	li	s3,100
    pid = fork();
    1b28:	00004097          	auipc	ra,0x4
    1b2c:	31a080e7          	jalr	794(ra) # 5e42 <fork>
    1b30:	84aa                	mv	s1,a0
    if(pid < 0){
    1b32:	02054a63          	bltz	a0,1b66 <exitwait+0x56>
    if(pid){
    1b36:	c151                	beqz	a0,1bba <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1b38:	fcc40513          	addi	a0,s0,-52
    1b3c:	00004097          	auipc	ra,0x4
    1b40:	316080e7          	jalr	790(ra) # 5e52 <wait>
    1b44:	02951f63          	bne	a0,s1,1b82 <exitwait+0x72>
      if(i != xstate) {
    1b48:	fcc42783          	lw	a5,-52(s0)
    1b4c:	05279963          	bne	a5,s2,1b9e <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1b50:	2905                	addiw	s2,s2,1
    1b52:	fd391be3          	bne	s2,s3,1b28 <exitwait+0x18>
}
    1b56:	70e2                	ld	ra,56(sp)
    1b58:	7442                	ld	s0,48(sp)
    1b5a:	74a2                	ld	s1,40(sp)
    1b5c:	7902                	ld	s2,32(sp)
    1b5e:	69e2                	ld	s3,24(sp)
    1b60:	6a42                	ld	s4,16(sp)
    1b62:	6121                	addi	sp,sp,64
    1b64:	8082                	ret
      printf("%s: fork failed\n", s);
    1b66:	85d2                	mv	a1,s4
    1b68:	00005517          	auipc	a0,0x5
    1b6c:	48850513          	addi	a0,a0,1160 # 6ff0 <uthread_self+0x916>
    1b70:	00004097          	auipc	ra,0x4
    1b74:	67a080e7          	jalr	1658(ra) # 61ea <printf>
      exit(1);
    1b78:	4505                	li	a0,1
    1b7a:	00004097          	auipc	ra,0x4
    1b7e:	2d0080e7          	jalr	720(ra) # 5e4a <exit>
        printf("%s: wait wrong pid\n", s);
    1b82:	85d2                	mv	a1,s4
    1b84:	00005517          	auipc	a0,0x5
    1b88:	5f450513          	addi	a0,a0,1524 # 7178 <uthread_self+0xa9e>
    1b8c:	00004097          	auipc	ra,0x4
    1b90:	65e080e7          	jalr	1630(ra) # 61ea <printf>
        exit(1);
    1b94:	4505                	li	a0,1
    1b96:	00004097          	auipc	ra,0x4
    1b9a:	2b4080e7          	jalr	692(ra) # 5e4a <exit>
        printf("%s: wait wrong exit status\n", s);
    1b9e:	85d2                	mv	a1,s4
    1ba0:	00005517          	auipc	a0,0x5
    1ba4:	5f050513          	addi	a0,a0,1520 # 7190 <uthread_self+0xab6>
    1ba8:	00004097          	auipc	ra,0x4
    1bac:	642080e7          	jalr	1602(ra) # 61ea <printf>
        exit(1);
    1bb0:	4505                	li	a0,1
    1bb2:	00004097          	auipc	ra,0x4
    1bb6:	298080e7          	jalr	664(ra) # 5e4a <exit>
      exit(i);
    1bba:	854a                	mv	a0,s2
    1bbc:	00004097          	auipc	ra,0x4
    1bc0:	28e080e7          	jalr	654(ra) # 5e4a <exit>

0000000000001bc4 <twochildren>:
{
    1bc4:	1101                	addi	sp,sp,-32
    1bc6:	ec06                	sd	ra,24(sp)
    1bc8:	e822                	sd	s0,16(sp)
    1bca:	e426                	sd	s1,8(sp)
    1bcc:	e04a                	sd	s2,0(sp)
    1bce:	1000                	addi	s0,sp,32
    1bd0:	892a                	mv	s2,a0
    1bd2:	3e800493          	li	s1,1000
    int pid1 = fork();
    1bd6:	00004097          	auipc	ra,0x4
    1bda:	26c080e7          	jalr	620(ra) # 5e42 <fork>
    if(pid1 < 0){
    1bde:	02054c63          	bltz	a0,1c16 <twochildren+0x52>
    if(pid1 == 0){
    1be2:	c921                	beqz	a0,1c32 <twochildren+0x6e>
      int pid2 = fork();
    1be4:	00004097          	auipc	ra,0x4
    1be8:	25e080e7          	jalr	606(ra) # 5e42 <fork>
      if(pid2 < 0){
    1bec:	04054763          	bltz	a0,1c3a <twochildren+0x76>
      if(pid2 == 0){
    1bf0:	c13d                	beqz	a0,1c56 <twochildren+0x92>
        wait(0);
    1bf2:	4501                	li	a0,0
    1bf4:	00004097          	auipc	ra,0x4
    1bf8:	25e080e7          	jalr	606(ra) # 5e52 <wait>
        wait(0);
    1bfc:	4501                	li	a0,0
    1bfe:	00004097          	auipc	ra,0x4
    1c02:	254080e7          	jalr	596(ra) # 5e52 <wait>
  for(int i = 0; i < 1000; i++){
    1c06:	34fd                	addiw	s1,s1,-1
    1c08:	f4f9                	bnez	s1,1bd6 <twochildren+0x12>
}
    1c0a:	60e2                	ld	ra,24(sp)
    1c0c:	6442                	ld	s0,16(sp)
    1c0e:	64a2                	ld	s1,8(sp)
    1c10:	6902                	ld	s2,0(sp)
    1c12:	6105                	addi	sp,sp,32
    1c14:	8082                	ret
      printf("%s: fork failed\n", s);
    1c16:	85ca                	mv	a1,s2
    1c18:	00005517          	auipc	a0,0x5
    1c1c:	3d850513          	addi	a0,a0,984 # 6ff0 <uthread_self+0x916>
    1c20:	00004097          	auipc	ra,0x4
    1c24:	5ca080e7          	jalr	1482(ra) # 61ea <printf>
      exit(1);
    1c28:	4505                	li	a0,1
    1c2a:	00004097          	auipc	ra,0x4
    1c2e:	220080e7          	jalr	544(ra) # 5e4a <exit>
      exit(0);
    1c32:	00004097          	auipc	ra,0x4
    1c36:	218080e7          	jalr	536(ra) # 5e4a <exit>
        printf("%s: fork failed\n", s);
    1c3a:	85ca                	mv	a1,s2
    1c3c:	00005517          	auipc	a0,0x5
    1c40:	3b450513          	addi	a0,a0,948 # 6ff0 <uthread_self+0x916>
    1c44:	00004097          	auipc	ra,0x4
    1c48:	5a6080e7          	jalr	1446(ra) # 61ea <printf>
        exit(1);
    1c4c:	4505                	li	a0,1
    1c4e:	00004097          	auipc	ra,0x4
    1c52:	1fc080e7          	jalr	508(ra) # 5e4a <exit>
        exit(0);
    1c56:	00004097          	auipc	ra,0x4
    1c5a:	1f4080e7          	jalr	500(ra) # 5e4a <exit>

0000000000001c5e <forkfork>:
{
    1c5e:	7179                	addi	sp,sp,-48
    1c60:	f406                	sd	ra,40(sp)
    1c62:	f022                	sd	s0,32(sp)
    1c64:	ec26                	sd	s1,24(sp)
    1c66:	1800                	addi	s0,sp,48
    1c68:	84aa                	mv	s1,a0
    int pid = fork();
    1c6a:	00004097          	auipc	ra,0x4
    1c6e:	1d8080e7          	jalr	472(ra) # 5e42 <fork>
    if(pid < 0){
    1c72:	04054163          	bltz	a0,1cb4 <forkfork+0x56>
    if(pid == 0){
    1c76:	cd29                	beqz	a0,1cd0 <forkfork+0x72>
    int pid = fork();
    1c78:	00004097          	auipc	ra,0x4
    1c7c:	1ca080e7          	jalr	458(ra) # 5e42 <fork>
    if(pid < 0){
    1c80:	02054a63          	bltz	a0,1cb4 <forkfork+0x56>
    if(pid == 0){
    1c84:	c531                	beqz	a0,1cd0 <forkfork+0x72>
    wait(&xstatus);
    1c86:	fdc40513          	addi	a0,s0,-36
    1c8a:	00004097          	auipc	ra,0x4
    1c8e:	1c8080e7          	jalr	456(ra) # 5e52 <wait>
    if(xstatus != 0) {
    1c92:	fdc42783          	lw	a5,-36(s0)
    1c96:	ebbd                	bnez	a5,1d0c <forkfork+0xae>
    wait(&xstatus);
    1c98:	fdc40513          	addi	a0,s0,-36
    1c9c:	00004097          	auipc	ra,0x4
    1ca0:	1b6080e7          	jalr	438(ra) # 5e52 <wait>
    if(xstatus != 0) {
    1ca4:	fdc42783          	lw	a5,-36(s0)
    1ca8:	e3b5                	bnez	a5,1d0c <forkfork+0xae>
}
    1caa:	70a2                	ld	ra,40(sp)
    1cac:	7402                	ld	s0,32(sp)
    1cae:	64e2                	ld	s1,24(sp)
    1cb0:	6145                	addi	sp,sp,48
    1cb2:	8082                	ret
      printf("%s: fork failed", s);
    1cb4:	85a6                	mv	a1,s1
    1cb6:	00005517          	auipc	a0,0x5
    1cba:	4fa50513          	addi	a0,a0,1274 # 71b0 <uthread_self+0xad6>
    1cbe:	00004097          	auipc	ra,0x4
    1cc2:	52c080e7          	jalr	1324(ra) # 61ea <printf>
      exit(1);
    1cc6:	4505                	li	a0,1
    1cc8:	00004097          	auipc	ra,0x4
    1ccc:	182080e7          	jalr	386(ra) # 5e4a <exit>
{
    1cd0:	0c800493          	li	s1,200
        int pid1 = fork();
    1cd4:	00004097          	auipc	ra,0x4
    1cd8:	16e080e7          	jalr	366(ra) # 5e42 <fork>
        if(pid1 < 0){
    1cdc:	00054f63          	bltz	a0,1cfa <forkfork+0x9c>
        if(pid1 == 0){
    1ce0:	c115                	beqz	a0,1d04 <forkfork+0xa6>
        wait(0);
    1ce2:	4501                	li	a0,0
    1ce4:	00004097          	auipc	ra,0x4
    1ce8:	16e080e7          	jalr	366(ra) # 5e52 <wait>
      for(int j = 0; j < 200; j++){
    1cec:	34fd                	addiw	s1,s1,-1
    1cee:	f0fd                	bnez	s1,1cd4 <forkfork+0x76>
      exit(0);
    1cf0:	4501                	li	a0,0
    1cf2:	00004097          	auipc	ra,0x4
    1cf6:	158080e7          	jalr	344(ra) # 5e4a <exit>
          exit(1);
    1cfa:	4505                	li	a0,1
    1cfc:	00004097          	auipc	ra,0x4
    1d00:	14e080e7          	jalr	334(ra) # 5e4a <exit>
          exit(0);
    1d04:	00004097          	auipc	ra,0x4
    1d08:	146080e7          	jalr	326(ra) # 5e4a <exit>
      printf("%s: fork in child failed", s);
    1d0c:	85a6                	mv	a1,s1
    1d0e:	00005517          	auipc	a0,0x5
    1d12:	4b250513          	addi	a0,a0,1202 # 71c0 <uthread_self+0xae6>
    1d16:	00004097          	auipc	ra,0x4
    1d1a:	4d4080e7          	jalr	1236(ra) # 61ea <printf>
      exit(1);
    1d1e:	4505                	li	a0,1
    1d20:	00004097          	auipc	ra,0x4
    1d24:	12a080e7          	jalr	298(ra) # 5e4a <exit>

0000000000001d28 <reparent2>:
{
    1d28:	1101                	addi	sp,sp,-32
    1d2a:	ec06                	sd	ra,24(sp)
    1d2c:	e822                	sd	s0,16(sp)
    1d2e:	e426                	sd	s1,8(sp)
    1d30:	1000                	addi	s0,sp,32
    1d32:	32000493          	li	s1,800
    int pid1 = fork();
    1d36:	00004097          	auipc	ra,0x4
    1d3a:	10c080e7          	jalr	268(ra) # 5e42 <fork>
    if(pid1 < 0){
    1d3e:	00054f63          	bltz	a0,1d5c <reparent2+0x34>
    if(pid1 == 0){
    1d42:	c915                	beqz	a0,1d76 <reparent2+0x4e>
    wait(0);
    1d44:	4501                	li	a0,0
    1d46:	00004097          	auipc	ra,0x4
    1d4a:	10c080e7          	jalr	268(ra) # 5e52 <wait>
  for(int i = 0; i < 800; i++){
    1d4e:	34fd                	addiw	s1,s1,-1
    1d50:	f0fd                	bnez	s1,1d36 <reparent2+0xe>
  exit(0);
    1d52:	4501                	li	a0,0
    1d54:	00004097          	auipc	ra,0x4
    1d58:	0f6080e7          	jalr	246(ra) # 5e4a <exit>
      printf("fork failed\n");
    1d5c:	00005517          	auipc	a0,0x5
    1d60:	69c50513          	addi	a0,a0,1692 # 73f8 <uthread_self+0xd1e>
    1d64:	00004097          	auipc	ra,0x4
    1d68:	486080e7          	jalr	1158(ra) # 61ea <printf>
      exit(1);
    1d6c:	4505                	li	a0,1
    1d6e:	00004097          	auipc	ra,0x4
    1d72:	0dc080e7          	jalr	220(ra) # 5e4a <exit>
      fork();
    1d76:	00004097          	auipc	ra,0x4
    1d7a:	0cc080e7          	jalr	204(ra) # 5e42 <fork>
      fork();
    1d7e:	00004097          	auipc	ra,0x4
    1d82:	0c4080e7          	jalr	196(ra) # 5e42 <fork>
      exit(0);
    1d86:	4501                	li	a0,0
    1d88:	00004097          	auipc	ra,0x4
    1d8c:	0c2080e7          	jalr	194(ra) # 5e4a <exit>

0000000000001d90 <createdelete>:
{
    1d90:	7175                	addi	sp,sp,-144
    1d92:	e506                	sd	ra,136(sp)
    1d94:	e122                	sd	s0,128(sp)
    1d96:	fca6                	sd	s1,120(sp)
    1d98:	f8ca                	sd	s2,112(sp)
    1d9a:	f4ce                	sd	s3,104(sp)
    1d9c:	f0d2                	sd	s4,96(sp)
    1d9e:	ecd6                	sd	s5,88(sp)
    1da0:	e8da                	sd	s6,80(sp)
    1da2:	e4de                	sd	s7,72(sp)
    1da4:	e0e2                	sd	s8,64(sp)
    1da6:	fc66                	sd	s9,56(sp)
    1da8:	0900                	addi	s0,sp,144
    1daa:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1dac:	4901                	li	s2,0
    1dae:	4991                	li	s3,4
    pid = fork();
    1db0:	00004097          	auipc	ra,0x4
    1db4:	092080e7          	jalr	146(ra) # 5e42 <fork>
    1db8:	84aa                	mv	s1,a0
    if(pid < 0){
    1dba:	02054f63          	bltz	a0,1df8 <createdelete+0x68>
    if(pid == 0){
    1dbe:	c939                	beqz	a0,1e14 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1dc0:	2905                	addiw	s2,s2,1
    1dc2:	ff3917e3          	bne	s2,s3,1db0 <createdelete+0x20>
    1dc6:	4491                	li	s1,4
    wait(&xstatus);
    1dc8:	f7c40513          	addi	a0,s0,-132
    1dcc:	00004097          	auipc	ra,0x4
    1dd0:	086080e7          	jalr	134(ra) # 5e52 <wait>
    if(xstatus != 0)
    1dd4:	f7c42903          	lw	s2,-132(s0)
    1dd8:	0e091263          	bnez	s2,1ebc <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1ddc:	34fd                	addiw	s1,s1,-1
    1dde:	f4ed                	bnez	s1,1dc8 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1de0:	f8040123          	sb	zero,-126(s0)
    1de4:	03000993          	li	s3,48
    1de8:	5a7d                	li	s4,-1
    1dea:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1dee:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1df0:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1df2:	07400a93          	li	s5,116
    1df6:	a29d                	j	1f5c <createdelete+0x1cc>
      printf("fork failed\n", s);
    1df8:	85e6                	mv	a1,s9
    1dfa:	00005517          	auipc	a0,0x5
    1dfe:	5fe50513          	addi	a0,a0,1534 # 73f8 <uthread_self+0xd1e>
    1e02:	00004097          	auipc	ra,0x4
    1e06:	3e8080e7          	jalr	1000(ra) # 61ea <printf>
      exit(1);
    1e0a:	4505                	li	a0,1
    1e0c:	00004097          	auipc	ra,0x4
    1e10:	03e080e7          	jalr	62(ra) # 5e4a <exit>
      name[0] = 'p' + pi;
    1e14:	0709091b          	addiw	s2,s2,112
    1e18:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1e1c:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1e20:	4951                	li	s2,20
    1e22:	a015                	j	1e46 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1e24:	85e6                	mv	a1,s9
    1e26:	00005517          	auipc	a0,0x5
    1e2a:	26250513          	addi	a0,a0,610 # 7088 <uthread_self+0x9ae>
    1e2e:	00004097          	auipc	ra,0x4
    1e32:	3bc080e7          	jalr	956(ra) # 61ea <printf>
          exit(1);
    1e36:	4505                	li	a0,1
    1e38:	00004097          	auipc	ra,0x4
    1e3c:	012080e7          	jalr	18(ra) # 5e4a <exit>
      for(i = 0; i < N; i++){
    1e40:	2485                	addiw	s1,s1,1
    1e42:	07248863          	beq	s1,s2,1eb2 <createdelete+0x122>
        name[1] = '0' + i;
    1e46:	0304879b          	addiw	a5,s1,48
    1e4a:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1e4e:	20200593          	li	a1,514
    1e52:	f8040513          	addi	a0,s0,-128
    1e56:	00004097          	auipc	ra,0x4
    1e5a:	034080e7          	jalr	52(ra) # 5e8a <open>
        if(fd < 0){
    1e5e:	fc0543e3          	bltz	a0,1e24 <createdelete+0x94>
        close(fd);
    1e62:	00004097          	auipc	ra,0x4
    1e66:	010080e7          	jalr	16(ra) # 5e72 <close>
        if(i > 0 && (i % 2 ) == 0){
    1e6a:	fc905be3          	blez	s1,1e40 <createdelete+0xb0>
    1e6e:	0014f793          	andi	a5,s1,1
    1e72:	f7f9                	bnez	a5,1e40 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1e74:	01f4d79b          	srliw	a5,s1,0x1f
    1e78:	9fa5                	addw	a5,a5,s1
    1e7a:	4017d79b          	sraiw	a5,a5,0x1
    1e7e:	0307879b          	addiw	a5,a5,48
    1e82:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1e86:	f8040513          	addi	a0,s0,-128
    1e8a:	00004097          	auipc	ra,0x4
    1e8e:	010080e7          	jalr	16(ra) # 5e9a <unlink>
    1e92:	fa0557e3          	bgez	a0,1e40 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1e96:	85e6                	mv	a1,s9
    1e98:	00005517          	auipc	a0,0x5
    1e9c:	34850513          	addi	a0,a0,840 # 71e0 <uthread_self+0xb06>
    1ea0:	00004097          	auipc	ra,0x4
    1ea4:	34a080e7          	jalr	842(ra) # 61ea <printf>
            exit(1);
    1ea8:	4505                	li	a0,1
    1eaa:	00004097          	auipc	ra,0x4
    1eae:	fa0080e7          	jalr	-96(ra) # 5e4a <exit>
      exit(0);
    1eb2:	4501                	li	a0,0
    1eb4:	00004097          	auipc	ra,0x4
    1eb8:	f96080e7          	jalr	-106(ra) # 5e4a <exit>
      exit(1);
    1ebc:	4505                	li	a0,1
    1ebe:	00004097          	auipc	ra,0x4
    1ec2:	f8c080e7          	jalr	-116(ra) # 5e4a <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1ec6:	f8040613          	addi	a2,s0,-128
    1eca:	85e6                	mv	a1,s9
    1ecc:	00005517          	auipc	a0,0x5
    1ed0:	32c50513          	addi	a0,a0,812 # 71f8 <uthread_self+0xb1e>
    1ed4:	00004097          	auipc	ra,0x4
    1ed8:	316080e7          	jalr	790(ra) # 61ea <printf>
        exit(1);
    1edc:	4505                	li	a0,1
    1ede:	00004097          	auipc	ra,0x4
    1ee2:	f6c080e7          	jalr	-148(ra) # 5e4a <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ee6:	054b7163          	bgeu	s6,s4,1f28 <createdelete+0x198>
      if(fd >= 0)
    1eea:	02055a63          	bgez	a0,1f1e <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1eee:	2485                	addiw	s1,s1,1
    1ef0:	0ff4f493          	andi	s1,s1,255
    1ef4:	05548c63          	beq	s1,s5,1f4c <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1ef8:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1efc:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1f00:	4581                	li	a1,0
    1f02:	f8040513          	addi	a0,s0,-128
    1f06:	00004097          	auipc	ra,0x4
    1f0a:	f84080e7          	jalr	-124(ra) # 5e8a <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1f0e:	00090463          	beqz	s2,1f16 <createdelete+0x186>
    1f12:	fd2bdae3          	bge	s7,s2,1ee6 <createdelete+0x156>
    1f16:	fa0548e3          	bltz	a0,1ec6 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1f1a:	014b7963          	bgeu	s6,s4,1f2c <createdelete+0x19c>
        close(fd);
    1f1e:	00004097          	auipc	ra,0x4
    1f22:	f54080e7          	jalr	-172(ra) # 5e72 <close>
    1f26:	b7e1                	j	1eee <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1f28:	fc0543e3          	bltz	a0,1eee <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1f2c:	f8040613          	addi	a2,s0,-128
    1f30:	85e6                	mv	a1,s9
    1f32:	00005517          	auipc	a0,0x5
    1f36:	2ee50513          	addi	a0,a0,750 # 7220 <uthread_self+0xb46>
    1f3a:	00004097          	auipc	ra,0x4
    1f3e:	2b0080e7          	jalr	688(ra) # 61ea <printf>
        exit(1);
    1f42:	4505                	li	a0,1
    1f44:	00004097          	auipc	ra,0x4
    1f48:	f06080e7          	jalr	-250(ra) # 5e4a <exit>
  for(i = 0; i < N; i++){
    1f4c:	2905                	addiw	s2,s2,1
    1f4e:	2a05                	addiw	s4,s4,1
    1f50:	2985                	addiw	s3,s3,1
    1f52:	0ff9f993          	andi	s3,s3,255
    1f56:	47d1                	li	a5,20
    1f58:	02f90a63          	beq	s2,a5,1f8c <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1f5c:	84e2                	mv	s1,s8
    1f5e:	bf69                	j	1ef8 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1f60:	2905                	addiw	s2,s2,1
    1f62:	0ff97913          	andi	s2,s2,255
    1f66:	2985                	addiw	s3,s3,1
    1f68:	0ff9f993          	andi	s3,s3,255
    1f6c:	03490863          	beq	s2,s4,1f9c <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1f70:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1f72:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1f76:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1f7a:	f8040513          	addi	a0,s0,-128
    1f7e:	00004097          	auipc	ra,0x4
    1f82:	f1c080e7          	jalr	-228(ra) # 5e9a <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1f86:	34fd                	addiw	s1,s1,-1
    1f88:	f4ed                	bnez	s1,1f72 <createdelete+0x1e2>
    1f8a:	bfd9                	j	1f60 <createdelete+0x1d0>
    1f8c:	03000993          	li	s3,48
    1f90:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1f94:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1f96:	08400a13          	li	s4,132
    1f9a:	bfd9                	j	1f70 <createdelete+0x1e0>
}
    1f9c:	60aa                	ld	ra,136(sp)
    1f9e:	640a                	ld	s0,128(sp)
    1fa0:	74e6                	ld	s1,120(sp)
    1fa2:	7946                	ld	s2,112(sp)
    1fa4:	79a6                	ld	s3,104(sp)
    1fa6:	7a06                	ld	s4,96(sp)
    1fa8:	6ae6                	ld	s5,88(sp)
    1faa:	6b46                	ld	s6,80(sp)
    1fac:	6ba6                	ld	s7,72(sp)
    1fae:	6c06                	ld	s8,64(sp)
    1fb0:	7ce2                	ld	s9,56(sp)
    1fb2:	6149                	addi	sp,sp,144
    1fb4:	8082                	ret

0000000000001fb6 <linkunlink>:
{
    1fb6:	711d                	addi	sp,sp,-96
    1fb8:	ec86                	sd	ra,88(sp)
    1fba:	e8a2                	sd	s0,80(sp)
    1fbc:	e4a6                	sd	s1,72(sp)
    1fbe:	e0ca                	sd	s2,64(sp)
    1fc0:	fc4e                	sd	s3,56(sp)
    1fc2:	f852                	sd	s4,48(sp)
    1fc4:	f456                	sd	s5,40(sp)
    1fc6:	f05a                	sd	s6,32(sp)
    1fc8:	ec5e                	sd	s7,24(sp)
    1fca:	e862                	sd	s8,16(sp)
    1fcc:	e466                	sd	s9,8(sp)
    1fce:	1080                	addi	s0,sp,96
    1fd0:	84aa                	mv	s1,a0
  unlink("x");
    1fd2:	00004517          	auipc	a0,0x4
    1fd6:	7e650513          	addi	a0,a0,2022 # 67b8 <uthread_self+0xde>
    1fda:	00004097          	auipc	ra,0x4
    1fde:	ec0080e7          	jalr	-320(ra) # 5e9a <unlink>
  pid = fork();
    1fe2:	00004097          	auipc	ra,0x4
    1fe6:	e60080e7          	jalr	-416(ra) # 5e42 <fork>
  if(pid < 0){
    1fea:	02054b63          	bltz	a0,2020 <linkunlink+0x6a>
    1fee:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1ff0:	4c85                	li	s9,1
    1ff2:	e119                	bnez	a0,1ff8 <linkunlink+0x42>
    1ff4:	06100c93          	li	s9,97
    1ff8:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1ffc:	41c659b7          	lui	s3,0x41c65
    2000:	e6d9899b          	addiw	s3,s3,-403
    2004:	690d                	lui	s2,0x3
    2006:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    200a:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    200c:	4b05                	li	s6,1
      unlink("x");
    200e:	00004a97          	auipc	s5,0x4
    2012:	7aaa8a93          	addi	s5,s5,1962 # 67b8 <uthread_self+0xde>
      link("cat", "x");
    2016:	00005b97          	auipc	s7,0x5
    201a:	232b8b93          	addi	s7,s7,562 # 7248 <uthread_self+0xb6e>
    201e:	a825                	j	2056 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    2020:	85a6                	mv	a1,s1
    2022:	00005517          	auipc	a0,0x5
    2026:	fce50513          	addi	a0,a0,-50 # 6ff0 <uthread_self+0x916>
    202a:	00004097          	auipc	ra,0x4
    202e:	1c0080e7          	jalr	448(ra) # 61ea <printf>
    exit(1);
    2032:	4505                	li	a0,1
    2034:	00004097          	auipc	ra,0x4
    2038:	e16080e7          	jalr	-490(ra) # 5e4a <exit>
      close(open("x", O_RDWR | O_CREATE));
    203c:	20200593          	li	a1,514
    2040:	8556                	mv	a0,s5
    2042:	00004097          	auipc	ra,0x4
    2046:	e48080e7          	jalr	-440(ra) # 5e8a <open>
    204a:	00004097          	auipc	ra,0x4
    204e:	e28080e7          	jalr	-472(ra) # 5e72 <close>
  for(i = 0; i < 100; i++){
    2052:	34fd                	addiw	s1,s1,-1
    2054:	c88d                	beqz	s1,2086 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    2056:	033c87bb          	mulw	a5,s9,s3
    205a:	012787bb          	addw	a5,a5,s2
    205e:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    2062:	0347f7bb          	remuw	a5,a5,s4
    2066:	dbf9                	beqz	a5,203c <linkunlink+0x86>
    } else if((x % 3) == 1){
    2068:	01678863          	beq	a5,s6,2078 <linkunlink+0xc2>
      unlink("x");
    206c:	8556                	mv	a0,s5
    206e:	00004097          	auipc	ra,0x4
    2072:	e2c080e7          	jalr	-468(ra) # 5e9a <unlink>
    2076:	bff1                	j	2052 <linkunlink+0x9c>
      link("cat", "x");
    2078:	85d6                	mv	a1,s5
    207a:	855e                	mv	a0,s7
    207c:	00004097          	auipc	ra,0x4
    2080:	e2e080e7          	jalr	-466(ra) # 5eaa <link>
    2084:	b7f9                	j	2052 <linkunlink+0x9c>
  if(pid)
    2086:	020c0463          	beqz	s8,20ae <linkunlink+0xf8>
    wait(0);
    208a:	4501                	li	a0,0
    208c:	00004097          	auipc	ra,0x4
    2090:	dc6080e7          	jalr	-570(ra) # 5e52 <wait>
}
    2094:	60e6                	ld	ra,88(sp)
    2096:	6446                	ld	s0,80(sp)
    2098:	64a6                	ld	s1,72(sp)
    209a:	6906                	ld	s2,64(sp)
    209c:	79e2                	ld	s3,56(sp)
    209e:	7a42                	ld	s4,48(sp)
    20a0:	7aa2                	ld	s5,40(sp)
    20a2:	7b02                	ld	s6,32(sp)
    20a4:	6be2                	ld	s7,24(sp)
    20a6:	6c42                	ld	s8,16(sp)
    20a8:	6ca2                	ld	s9,8(sp)
    20aa:	6125                	addi	sp,sp,96
    20ac:	8082                	ret
    exit(0);
    20ae:	4501                	li	a0,0
    20b0:	00004097          	auipc	ra,0x4
    20b4:	d9a080e7          	jalr	-614(ra) # 5e4a <exit>

00000000000020b8 <forktest>:
{
    20b8:	7179                	addi	sp,sp,-48
    20ba:	f406                	sd	ra,40(sp)
    20bc:	f022                	sd	s0,32(sp)
    20be:	ec26                	sd	s1,24(sp)
    20c0:	e84a                	sd	s2,16(sp)
    20c2:	e44e                	sd	s3,8(sp)
    20c4:	1800                	addi	s0,sp,48
    20c6:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    20c8:	4481                	li	s1,0
    20ca:	3e800913          	li	s2,1000
    pid = fork();
    20ce:	00004097          	auipc	ra,0x4
    20d2:	d74080e7          	jalr	-652(ra) # 5e42 <fork>
    if(pid < 0)
    20d6:	02054863          	bltz	a0,2106 <forktest+0x4e>
    if(pid == 0)
    20da:	c115                	beqz	a0,20fe <forktest+0x46>
  for(n=0; n<N; n++){
    20dc:	2485                	addiw	s1,s1,1
    20de:	ff2498e3          	bne	s1,s2,20ce <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    20e2:	85ce                	mv	a1,s3
    20e4:	00005517          	auipc	a0,0x5
    20e8:	18450513          	addi	a0,a0,388 # 7268 <uthread_self+0xb8e>
    20ec:	00004097          	auipc	ra,0x4
    20f0:	0fe080e7          	jalr	254(ra) # 61ea <printf>
    exit(1);
    20f4:	4505                	li	a0,1
    20f6:	00004097          	auipc	ra,0x4
    20fa:	d54080e7          	jalr	-684(ra) # 5e4a <exit>
      exit(0);
    20fe:	00004097          	auipc	ra,0x4
    2102:	d4c080e7          	jalr	-692(ra) # 5e4a <exit>
  if (n == 0) {
    2106:	cc9d                	beqz	s1,2144 <forktest+0x8c>
  if(n == N){
    2108:	3e800793          	li	a5,1000
    210c:	fcf48be3          	beq	s1,a5,20e2 <forktest+0x2a>
  for(; n > 0; n--){
    2110:	00905b63          	blez	s1,2126 <forktest+0x6e>
    if(wait(0) < 0){
    2114:	4501                	li	a0,0
    2116:	00004097          	auipc	ra,0x4
    211a:	d3c080e7          	jalr	-708(ra) # 5e52 <wait>
    211e:	04054163          	bltz	a0,2160 <forktest+0xa8>
  for(; n > 0; n--){
    2122:	34fd                	addiw	s1,s1,-1
    2124:	f8e5                	bnez	s1,2114 <forktest+0x5c>
  if(wait(0) != -1){
    2126:	4501                	li	a0,0
    2128:	00004097          	auipc	ra,0x4
    212c:	d2a080e7          	jalr	-726(ra) # 5e52 <wait>
    2130:	57fd                	li	a5,-1
    2132:	04f51563          	bne	a0,a5,217c <forktest+0xc4>
}
    2136:	70a2                	ld	ra,40(sp)
    2138:	7402                	ld	s0,32(sp)
    213a:	64e2                	ld	s1,24(sp)
    213c:	6942                	ld	s2,16(sp)
    213e:	69a2                	ld	s3,8(sp)
    2140:	6145                	addi	sp,sp,48
    2142:	8082                	ret
    printf("%s: no fork at all!\n", s);
    2144:	85ce                	mv	a1,s3
    2146:	00005517          	auipc	a0,0x5
    214a:	10a50513          	addi	a0,a0,266 # 7250 <uthread_self+0xb76>
    214e:	00004097          	auipc	ra,0x4
    2152:	09c080e7          	jalr	156(ra) # 61ea <printf>
    exit(1);
    2156:	4505                	li	a0,1
    2158:	00004097          	auipc	ra,0x4
    215c:	cf2080e7          	jalr	-782(ra) # 5e4a <exit>
      printf("%s: wait stopped early\n", s);
    2160:	85ce                	mv	a1,s3
    2162:	00005517          	auipc	a0,0x5
    2166:	12e50513          	addi	a0,a0,302 # 7290 <uthread_self+0xbb6>
    216a:	00004097          	auipc	ra,0x4
    216e:	080080e7          	jalr	128(ra) # 61ea <printf>
      exit(1);
    2172:	4505                	li	a0,1
    2174:	00004097          	auipc	ra,0x4
    2178:	cd6080e7          	jalr	-810(ra) # 5e4a <exit>
    printf("%s: wait got too many\n", s);
    217c:	85ce                	mv	a1,s3
    217e:	00005517          	auipc	a0,0x5
    2182:	12a50513          	addi	a0,a0,298 # 72a8 <uthread_self+0xbce>
    2186:	00004097          	auipc	ra,0x4
    218a:	064080e7          	jalr	100(ra) # 61ea <printf>
    exit(1);
    218e:	4505                	li	a0,1
    2190:	00004097          	auipc	ra,0x4
    2194:	cba080e7          	jalr	-838(ra) # 5e4a <exit>

0000000000002198 <kernmem>:
{
    2198:	715d                	addi	sp,sp,-80
    219a:	e486                	sd	ra,72(sp)
    219c:	e0a2                	sd	s0,64(sp)
    219e:	fc26                	sd	s1,56(sp)
    21a0:	f84a                	sd	s2,48(sp)
    21a2:	f44e                	sd	s3,40(sp)
    21a4:	f052                	sd	s4,32(sp)
    21a6:	ec56                	sd	s5,24(sp)
    21a8:	0880                	addi	s0,sp,80
    21aa:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    21ac:	4485                	li	s1,1
    21ae:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    21b0:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    21b2:	69b1                	lui	s3,0xc
    21b4:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1db8>
    21b8:	1003d937          	lui	s2,0x1003d
    21bc:	090e                	slli	s2,s2,0x3
    21be:	48090913          	addi	s2,s2,1152 # 1003d480 <uthreads_arr+0x1002d758>
    pid = fork();
    21c2:	00004097          	auipc	ra,0x4
    21c6:	c80080e7          	jalr	-896(ra) # 5e42 <fork>
    if(pid < 0){
    21ca:	02054963          	bltz	a0,21fc <kernmem+0x64>
    if(pid == 0){
    21ce:	c529                	beqz	a0,2218 <kernmem+0x80>
    wait(&xstatus);
    21d0:	fbc40513          	addi	a0,s0,-68
    21d4:	00004097          	auipc	ra,0x4
    21d8:	c7e080e7          	jalr	-898(ra) # 5e52 <wait>
    if(xstatus != -1)  // did kernel kill child?
    21dc:	fbc42783          	lw	a5,-68(s0)
    21e0:	05579d63          	bne	a5,s5,223a <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    21e4:	94ce                	add	s1,s1,s3
    21e6:	fd249ee3          	bne	s1,s2,21c2 <kernmem+0x2a>
}
    21ea:	60a6                	ld	ra,72(sp)
    21ec:	6406                	ld	s0,64(sp)
    21ee:	74e2                	ld	s1,56(sp)
    21f0:	7942                	ld	s2,48(sp)
    21f2:	79a2                	ld	s3,40(sp)
    21f4:	7a02                	ld	s4,32(sp)
    21f6:	6ae2                	ld	s5,24(sp)
    21f8:	6161                	addi	sp,sp,80
    21fa:	8082                	ret
      printf("%s: fork failed\n", s);
    21fc:	85d2                	mv	a1,s4
    21fe:	00005517          	auipc	a0,0x5
    2202:	df250513          	addi	a0,a0,-526 # 6ff0 <uthread_self+0x916>
    2206:	00004097          	auipc	ra,0x4
    220a:	fe4080e7          	jalr	-28(ra) # 61ea <printf>
      exit(1);
    220e:	4505                	li	a0,1
    2210:	00004097          	auipc	ra,0x4
    2214:	c3a080e7          	jalr	-966(ra) # 5e4a <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    2218:	0004c683          	lbu	a3,0(s1)
    221c:	8626                	mv	a2,s1
    221e:	85d2                	mv	a1,s4
    2220:	00005517          	auipc	a0,0x5
    2224:	0a050513          	addi	a0,a0,160 # 72c0 <uthread_self+0xbe6>
    2228:	00004097          	auipc	ra,0x4
    222c:	fc2080e7          	jalr	-62(ra) # 61ea <printf>
      exit(1);
    2230:	4505                	li	a0,1
    2232:	00004097          	auipc	ra,0x4
    2236:	c18080e7          	jalr	-1000(ra) # 5e4a <exit>
      exit(1);
    223a:	4505                	li	a0,1
    223c:	00004097          	auipc	ra,0x4
    2240:	c0e080e7          	jalr	-1010(ra) # 5e4a <exit>

0000000000002244 <MAXVAplus>:
{
    2244:	7179                	addi	sp,sp,-48
    2246:	f406                	sd	ra,40(sp)
    2248:	f022                	sd	s0,32(sp)
    224a:	ec26                	sd	s1,24(sp)
    224c:	e84a                	sd	s2,16(sp)
    224e:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    2250:	4785                	li	a5,1
    2252:	179a                	slli	a5,a5,0x26
    2254:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    2258:	fd843783          	ld	a5,-40(s0)
    225c:	cf85                	beqz	a5,2294 <MAXVAplus+0x50>
    225e:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    2260:	54fd                	li	s1,-1
    pid = fork();
    2262:	00004097          	auipc	ra,0x4
    2266:	be0080e7          	jalr	-1056(ra) # 5e42 <fork>
    if(pid < 0){
    226a:	02054b63          	bltz	a0,22a0 <MAXVAplus+0x5c>
    if(pid == 0){
    226e:	c539                	beqz	a0,22bc <MAXVAplus+0x78>
    wait(&xstatus);
    2270:	fd440513          	addi	a0,s0,-44
    2274:	00004097          	auipc	ra,0x4
    2278:	bde080e7          	jalr	-1058(ra) # 5e52 <wait>
    if(xstatus != -1)  // did kernel kill child?
    227c:	fd442783          	lw	a5,-44(s0)
    2280:	06979463          	bne	a5,s1,22e8 <MAXVAplus+0xa4>
  for( ; a != 0; a <<= 1){
    2284:	fd843783          	ld	a5,-40(s0)
    2288:	0786                	slli	a5,a5,0x1
    228a:	fcf43c23          	sd	a5,-40(s0)
    228e:	fd843783          	ld	a5,-40(s0)
    2292:	fbe1                	bnez	a5,2262 <MAXVAplus+0x1e>
}
    2294:	70a2                	ld	ra,40(sp)
    2296:	7402                	ld	s0,32(sp)
    2298:	64e2                	ld	s1,24(sp)
    229a:	6942                	ld	s2,16(sp)
    229c:	6145                	addi	sp,sp,48
    229e:	8082                	ret
      printf("%s: fork failed\n", s);
    22a0:	85ca                	mv	a1,s2
    22a2:	00005517          	auipc	a0,0x5
    22a6:	d4e50513          	addi	a0,a0,-690 # 6ff0 <uthread_self+0x916>
    22aa:	00004097          	auipc	ra,0x4
    22ae:	f40080e7          	jalr	-192(ra) # 61ea <printf>
      exit(1);
    22b2:	4505                	li	a0,1
    22b4:	00004097          	auipc	ra,0x4
    22b8:	b96080e7          	jalr	-1130(ra) # 5e4a <exit>
      *(char*)a = 99;
    22bc:	fd843783          	ld	a5,-40(s0)
    22c0:	06300713          	li	a4,99
    22c4:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    22c8:	fd843603          	ld	a2,-40(s0)
    22cc:	85ca                	mv	a1,s2
    22ce:	00005517          	auipc	a0,0x5
    22d2:	01250513          	addi	a0,a0,18 # 72e0 <uthread_self+0xc06>
    22d6:	00004097          	auipc	ra,0x4
    22da:	f14080e7          	jalr	-236(ra) # 61ea <printf>
      exit(1);
    22de:	4505                	li	a0,1
    22e0:	00004097          	auipc	ra,0x4
    22e4:	b6a080e7          	jalr	-1174(ra) # 5e4a <exit>
      exit(1);
    22e8:	4505                	li	a0,1
    22ea:	00004097          	auipc	ra,0x4
    22ee:	b60080e7          	jalr	-1184(ra) # 5e4a <exit>

00000000000022f2 <bigargtest>:
{
    22f2:	7179                	addi	sp,sp,-48
    22f4:	f406                	sd	ra,40(sp)
    22f6:	f022                	sd	s0,32(sp)
    22f8:	ec26                	sd	s1,24(sp)
    22fa:	1800                	addi	s0,sp,48
    22fc:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    22fe:	00005517          	auipc	a0,0x5
    2302:	ffa50513          	addi	a0,a0,-6 # 72f8 <uthread_self+0xc1e>
    2306:	00004097          	auipc	ra,0x4
    230a:	b94080e7          	jalr	-1132(ra) # 5e9a <unlink>
  pid = fork();
    230e:	00004097          	auipc	ra,0x4
    2312:	b34080e7          	jalr	-1228(ra) # 5e42 <fork>
  if(pid == 0){
    2316:	c121                	beqz	a0,2356 <bigargtest+0x64>
  } else if(pid < 0){
    2318:	0a054063          	bltz	a0,23b8 <bigargtest+0xc6>
  wait(&xstatus);
    231c:	fdc40513          	addi	a0,s0,-36
    2320:	00004097          	auipc	ra,0x4
    2324:	b32080e7          	jalr	-1230(ra) # 5e52 <wait>
  if(xstatus != 0)
    2328:	fdc42503          	lw	a0,-36(s0)
    232c:	e545                	bnez	a0,23d4 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    232e:	4581                	li	a1,0
    2330:	00005517          	auipc	a0,0x5
    2334:	fc850513          	addi	a0,a0,-56 # 72f8 <uthread_self+0xc1e>
    2338:	00004097          	auipc	ra,0x4
    233c:	b52080e7          	jalr	-1198(ra) # 5e8a <open>
  if(fd < 0){
    2340:	08054e63          	bltz	a0,23dc <bigargtest+0xea>
  close(fd);
    2344:	00004097          	auipc	ra,0x4
    2348:	b2e080e7          	jalr	-1234(ra) # 5e72 <close>
}
    234c:	70a2                	ld	ra,40(sp)
    234e:	7402                	ld	s0,32(sp)
    2350:	64e2                	ld	s1,24(sp)
    2352:	6145                	addi	sp,sp,48
    2354:	8082                	ret
    2356:	00007797          	auipc	a5,0x7
    235a:	13a78793          	addi	a5,a5,314 # 9490 <args.1>
    235e:	00007697          	auipc	a3,0x7
    2362:	22a68693          	addi	a3,a3,554 # 9588 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    2366:	00005717          	auipc	a4,0x5
    236a:	fa270713          	addi	a4,a4,-94 # 7308 <uthread_self+0xc2e>
    236e:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    2370:	07a1                	addi	a5,a5,8
    2372:	fed79ee3          	bne	a5,a3,236e <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    2376:	00007597          	auipc	a1,0x7
    237a:	11a58593          	addi	a1,a1,282 # 9490 <args.1>
    237e:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2382:	00004517          	auipc	a0,0x4
    2386:	3c650513          	addi	a0,a0,966 # 6748 <uthread_self+0x6e>
    238a:	00004097          	auipc	ra,0x4
    238e:	af8080e7          	jalr	-1288(ra) # 5e82 <exec>
    fd = open("bigarg-ok", O_CREATE);
    2392:	20000593          	li	a1,512
    2396:	00005517          	auipc	a0,0x5
    239a:	f6250513          	addi	a0,a0,-158 # 72f8 <uthread_self+0xc1e>
    239e:	00004097          	auipc	ra,0x4
    23a2:	aec080e7          	jalr	-1300(ra) # 5e8a <open>
    close(fd);
    23a6:	00004097          	auipc	ra,0x4
    23aa:	acc080e7          	jalr	-1332(ra) # 5e72 <close>
    exit(0);
    23ae:	4501                	li	a0,0
    23b0:	00004097          	auipc	ra,0x4
    23b4:	a9a080e7          	jalr	-1382(ra) # 5e4a <exit>
    printf("%s: bigargtest: fork failed\n", s);
    23b8:	85a6                	mv	a1,s1
    23ba:	00005517          	auipc	a0,0x5
    23be:	02e50513          	addi	a0,a0,46 # 73e8 <uthread_self+0xd0e>
    23c2:	00004097          	auipc	ra,0x4
    23c6:	e28080e7          	jalr	-472(ra) # 61ea <printf>
    exit(1);
    23ca:	4505                	li	a0,1
    23cc:	00004097          	auipc	ra,0x4
    23d0:	a7e080e7          	jalr	-1410(ra) # 5e4a <exit>
    exit(xstatus);
    23d4:	00004097          	auipc	ra,0x4
    23d8:	a76080e7          	jalr	-1418(ra) # 5e4a <exit>
    printf("%s: bigarg test failed!\n", s);
    23dc:	85a6                	mv	a1,s1
    23de:	00005517          	auipc	a0,0x5
    23e2:	02a50513          	addi	a0,a0,42 # 7408 <uthread_self+0xd2e>
    23e6:	00004097          	auipc	ra,0x4
    23ea:	e04080e7          	jalr	-508(ra) # 61ea <printf>
    exit(1);
    23ee:	4505                	li	a0,1
    23f0:	00004097          	auipc	ra,0x4
    23f4:	a5a080e7          	jalr	-1446(ra) # 5e4a <exit>

00000000000023f8 <stacktest>:
{
    23f8:	7179                	addi	sp,sp,-48
    23fa:	f406                	sd	ra,40(sp)
    23fc:	f022                	sd	s0,32(sp)
    23fe:	ec26                	sd	s1,24(sp)
    2400:	1800                	addi	s0,sp,48
    2402:	84aa                	mv	s1,a0
  pid = fork();
    2404:	00004097          	auipc	ra,0x4
    2408:	a3e080e7          	jalr	-1474(ra) # 5e42 <fork>
  if(pid == 0) {
    240c:	c115                	beqz	a0,2430 <stacktest+0x38>
  } else if(pid < 0){
    240e:	04054463          	bltz	a0,2456 <stacktest+0x5e>
  wait(&xstatus);
    2412:	fdc40513          	addi	a0,s0,-36
    2416:	00004097          	auipc	ra,0x4
    241a:	a3c080e7          	jalr	-1476(ra) # 5e52 <wait>
  if(xstatus == -1)  // kernel killed child?
    241e:	fdc42503          	lw	a0,-36(s0)
    2422:	57fd                	li	a5,-1
    2424:	04f50763          	beq	a0,a5,2472 <stacktest+0x7a>
    exit(xstatus);
    2428:	00004097          	auipc	ra,0x4
    242c:	a22080e7          	jalr	-1502(ra) # 5e4a <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    2430:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    2432:	77fd                	lui	a5,0xfffff
    2434:	97ba                	add	a5,a5,a4
    2436:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <uthreads_arr+0xfffffffffffef2d8>
    243a:	85a6                	mv	a1,s1
    243c:	00005517          	auipc	a0,0x5
    2440:	fec50513          	addi	a0,a0,-20 # 7428 <uthread_self+0xd4e>
    2444:	00004097          	auipc	ra,0x4
    2448:	da6080e7          	jalr	-602(ra) # 61ea <printf>
    exit(1);
    244c:	4505                	li	a0,1
    244e:	00004097          	auipc	ra,0x4
    2452:	9fc080e7          	jalr	-1540(ra) # 5e4a <exit>
    printf("%s: fork failed\n", s);
    2456:	85a6                	mv	a1,s1
    2458:	00005517          	auipc	a0,0x5
    245c:	b9850513          	addi	a0,a0,-1128 # 6ff0 <uthread_self+0x916>
    2460:	00004097          	auipc	ra,0x4
    2464:	d8a080e7          	jalr	-630(ra) # 61ea <printf>
    exit(1);
    2468:	4505                	li	a0,1
    246a:	00004097          	auipc	ra,0x4
    246e:	9e0080e7          	jalr	-1568(ra) # 5e4a <exit>
    exit(0);
    2472:	4501                	li	a0,0
    2474:	00004097          	auipc	ra,0x4
    2478:	9d6080e7          	jalr	-1578(ra) # 5e4a <exit>

000000000000247c <textwrite>:
{
    247c:	7179                	addi	sp,sp,-48
    247e:	f406                	sd	ra,40(sp)
    2480:	f022                	sd	s0,32(sp)
    2482:	ec26                	sd	s1,24(sp)
    2484:	1800                	addi	s0,sp,48
    2486:	84aa                	mv	s1,a0
  pid = fork();
    2488:	00004097          	auipc	ra,0x4
    248c:	9ba080e7          	jalr	-1606(ra) # 5e42 <fork>
  if(pid == 0) {
    2490:	c115                	beqz	a0,24b4 <textwrite+0x38>
  } else if(pid < 0){
    2492:	02054963          	bltz	a0,24c4 <textwrite+0x48>
  wait(&xstatus);
    2496:	fdc40513          	addi	a0,s0,-36
    249a:	00004097          	auipc	ra,0x4
    249e:	9b8080e7          	jalr	-1608(ra) # 5e52 <wait>
  if(xstatus == -1)  // kernel killed child?
    24a2:	fdc42503          	lw	a0,-36(s0)
    24a6:	57fd                	li	a5,-1
    24a8:	02f50c63          	beq	a0,a5,24e0 <textwrite+0x64>
    exit(xstatus);
    24ac:	00004097          	auipc	ra,0x4
    24b0:	99e080e7          	jalr	-1634(ra) # 5e4a <exit>
    *addr = 10;
    24b4:	47a9                	li	a5,10
    24b6:	00f02023          	sw	a5,0(zero) # 0 <copyinstr1>
    exit(1);
    24ba:	4505                	li	a0,1
    24bc:	00004097          	auipc	ra,0x4
    24c0:	98e080e7          	jalr	-1650(ra) # 5e4a <exit>
    printf("%s: fork failed\n", s);
    24c4:	85a6                	mv	a1,s1
    24c6:	00005517          	auipc	a0,0x5
    24ca:	b2a50513          	addi	a0,a0,-1238 # 6ff0 <uthread_self+0x916>
    24ce:	00004097          	auipc	ra,0x4
    24d2:	d1c080e7          	jalr	-740(ra) # 61ea <printf>
    exit(1);
    24d6:	4505                	li	a0,1
    24d8:	00004097          	auipc	ra,0x4
    24dc:	972080e7          	jalr	-1678(ra) # 5e4a <exit>
    exit(0);
    24e0:	4501                	li	a0,0
    24e2:	00004097          	auipc	ra,0x4
    24e6:	968080e7          	jalr	-1688(ra) # 5e4a <exit>

00000000000024ea <manywrites>:
{
    24ea:	711d                	addi	sp,sp,-96
    24ec:	ec86                	sd	ra,88(sp)
    24ee:	e8a2                	sd	s0,80(sp)
    24f0:	e4a6                	sd	s1,72(sp)
    24f2:	e0ca                	sd	s2,64(sp)
    24f4:	fc4e                	sd	s3,56(sp)
    24f6:	f852                	sd	s4,48(sp)
    24f8:	f456                	sd	s5,40(sp)
    24fa:	f05a                	sd	s6,32(sp)
    24fc:	ec5e                	sd	s7,24(sp)
    24fe:	1080                	addi	s0,sp,96
    2500:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    2502:	4981                	li	s3,0
    2504:	4911                	li	s2,4
    int pid = fork();
    2506:	00004097          	auipc	ra,0x4
    250a:	93c080e7          	jalr	-1732(ra) # 5e42 <fork>
    250e:	84aa                	mv	s1,a0
    if(pid < 0){
    2510:	02054963          	bltz	a0,2542 <manywrites+0x58>
    if(pid == 0){
    2514:	c521                	beqz	a0,255c <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    2516:	2985                	addiw	s3,s3,1
    2518:	ff2997e3          	bne	s3,s2,2506 <manywrites+0x1c>
    251c:	4491                	li	s1,4
    int st = 0;
    251e:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    2522:	fa840513          	addi	a0,s0,-88
    2526:	00004097          	auipc	ra,0x4
    252a:	92c080e7          	jalr	-1748(ra) # 5e52 <wait>
    if(st != 0)
    252e:	fa842503          	lw	a0,-88(s0)
    2532:	ed6d                	bnez	a0,262c <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    2534:	34fd                	addiw	s1,s1,-1
    2536:	f4e5                	bnez	s1,251e <manywrites+0x34>
  exit(0);
    2538:	4501                	li	a0,0
    253a:	00004097          	auipc	ra,0x4
    253e:	910080e7          	jalr	-1776(ra) # 5e4a <exit>
      printf("fork failed\n");
    2542:	00005517          	auipc	a0,0x5
    2546:	eb650513          	addi	a0,a0,-330 # 73f8 <uthread_self+0xd1e>
    254a:	00004097          	auipc	ra,0x4
    254e:	ca0080e7          	jalr	-864(ra) # 61ea <printf>
      exit(1);
    2552:	4505                	li	a0,1
    2554:	00004097          	auipc	ra,0x4
    2558:	8f6080e7          	jalr	-1802(ra) # 5e4a <exit>
      name[0] = 'b';
    255c:	06200793          	li	a5,98
    2560:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    2564:	0619879b          	addiw	a5,s3,97
    2568:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    256c:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    2570:	fa840513          	addi	a0,s0,-88
    2574:	00004097          	auipc	ra,0x4
    2578:	926080e7          	jalr	-1754(ra) # 5e9a <unlink>
    257c:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    257e:	0000ab17          	auipc	s6,0xa
    2582:	72ab0b13          	addi	s6,s6,1834 # cca8 <buf>
        for(int i = 0; i < ci+1; i++){
    2586:	8a26                	mv	s4,s1
    2588:	0209ce63          	bltz	s3,25c4 <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    258c:	20200593          	li	a1,514
    2590:	fa840513          	addi	a0,s0,-88
    2594:	00004097          	auipc	ra,0x4
    2598:	8f6080e7          	jalr	-1802(ra) # 5e8a <open>
    259c:	892a                	mv	s2,a0
          if(fd < 0){
    259e:	04054763          	bltz	a0,25ec <manywrites+0x102>
          int cc = write(fd, buf, sz);
    25a2:	660d                	lui	a2,0x3
    25a4:	85da                	mv	a1,s6
    25a6:	00004097          	auipc	ra,0x4
    25aa:	8c4080e7          	jalr	-1852(ra) # 5e6a <write>
          if(cc != sz){
    25ae:	678d                	lui	a5,0x3
    25b0:	04f51e63          	bne	a0,a5,260c <manywrites+0x122>
          close(fd);
    25b4:	854a                	mv	a0,s2
    25b6:	00004097          	auipc	ra,0x4
    25ba:	8bc080e7          	jalr	-1860(ra) # 5e72 <close>
        for(int i = 0; i < ci+1; i++){
    25be:	2a05                	addiw	s4,s4,1
    25c0:	fd49d6e3          	bge	s3,s4,258c <manywrites+0xa2>
        unlink(name);
    25c4:	fa840513          	addi	a0,s0,-88
    25c8:	00004097          	auipc	ra,0x4
    25cc:	8d2080e7          	jalr	-1838(ra) # 5e9a <unlink>
      for(int iters = 0; iters < howmany; iters++){
    25d0:	3bfd                	addiw	s7,s7,-1
    25d2:	fa0b9ae3          	bnez	s7,2586 <manywrites+0x9c>
      unlink(name);
    25d6:	fa840513          	addi	a0,s0,-88
    25da:	00004097          	auipc	ra,0x4
    25de:	8c0080e7          	jalr	-1856(ra) # 5e9a <unlink>
      exit(0);
    25e2:	4501                	li	a0,0
    25e4:	00004097          	auipc	ra,0x4
    25e8:	866080e7          	jalr	-1946(ra) # 5e4a <exit>
            printf("%s: cannot create %s\n", s, name);
    25ec:	fa840613          	addi	a2,s0,-88
    25f0:	85d6                	mv	a1,s5
    25f2:	00005517          	auipc	a0,0x5
    25f6:	e5e50513          	addi	a0,a0,-418 # 7450 <uthread_self+0xd76>
    25fa:	00004097          	auipc	ra,0x4
    25fe:	bf0080e7          	jalr	-1040(ra) # 61ea <printf>
            exit(1);
    2602:	4505                	li	a0,1
    2604:	00004097          	auipc	ra,0x4
    2608:	846080e7          	jalr	-1978(ra) # 5e4a <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    260c:	86aa                	mv	a3,a0
    260e:	660d                	lui	a2,0x3
    2610:	85d6                	mv	a1,s5
    2612:	00004517          	auipc	a0,0x4
    2616:	20650513          	addi	a0,a0,518 # 6818 <uthread_self+0x13e>
    261a:	00004097          	auipc	ra,0x4
    261e:	bd0080e7          	jalr	-1072(ra) # 61ea <printf>
            exit(1);
    2622:	4505                	li	a0,1
    2624:	00004097          	auipc	ra,0x4
    2628:	826080e7          	jalr	-2010(ra) # 5e4a <exit>
      exit(st);
    262c:	00004097          	auipc	ra,0x4
    2630:	81e080e7          	jalr	-2018(ra) # 5e4a <exit>

0000000000002634 <copyinstr3>:
{
    2634:	7179                	addi	sp,sp,-48
    2636:	f406                	sd	ra,40(sp)
    2638:	f022                	sd	s0,32(sp)
    263a:	ec26                	sd	s1,24(sp)
    263c:	1800                	addi	s0,sp,48
  sbrk(8192);
    263e:	6509                	lui	a0,0x2
    2640:	00004097          	auipc	ra,0x4
    2644:	892080e7          	jalr	-1902(ra) # 5ed2 <sbrk>
  uint64 top = (uint64) sbrk(0);
    2648:	4501                	li	a0,0
    264a:	00004097          	auipc	ra,0x4
    264e:	888080e7          	jalr	-1912(ra) # 5ed2 <sbrk>
  if((top % PGSIZE) != 0){
    2652:	03451793          	slli	a5,a0,0x34
    2656:	e3c9                	bnez	a5,26d8 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2658:	4501                	li	a0,0
    265a:	00004097          	auipc	ra,0x4
    265e:	878080e7          	jalr	-1928(ra) # 5ed2 <sbrk>
  if(top % PGSIZE){
    2662:	03451793          	slli	a5,a0,0x34
    2666:	e3d9                	bnez	a5,26ec <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2668:	fff50493          	addi	s1,a0,-1 # 1fff <linkunlink+0x49>
  *b = 'x';
    266c:	07800793          	li	a5,120
    2670:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2674:	8526                	mv	a0,s1
    2676:	00004097          	auipc	ra,0x4
    267a:	824080e7          	jalr	-2012(ra) # 5e9a <unlink>
  if(ret != -1){
    267e:	57fd                	li	a5,-1
    2680:	08f51363          	bne	a0,a5,2706 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2684:	20100593          	li	a1,513
    2688:	8526                	mv	a0,s1
    268a:	00004097          	auipc	ra,0x4
    268e:	800080e7          	jalr	-2048(ra) # 5e8a <open>
  if(fd != -1){
    2692:	57fd                	li	a5,-1
    2694:	08f51863          	bne	a0,a5,2724 <copyinstr3+0xf0>
  ret = link(b, b);
    2698:	85a6                	mv	a1,s1
    269a:	8526                	mv	a0,s1
    269c:	00004097          	auipc	ra,0x4
    26a0:	80e080e7          	jalr	-2034(ra) # 5eaa <link>
  if(ret != -1){
    26a4:	57fd                	li	a5,-1
    26a6:	08f51e63          	bne	a0,a5,2742 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    26aa:	00006797          	auipc	a5,0x6
    26ae:	a9e78793          	addi	a5,a5,-1378 # 8148 <uthread_self+0x1a6e>
    26b2:	fcf43823          	sd	a5,-48(s0)
    26b6:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    26ba:	fd040593          	addi	a1,s0,-48
    26be:	8526                	mv	a0,s1
    26c0:	00003097          	auipc	ra,0x3
    26c4:	7c2080e7          	jalr	1986(ra) # 5e82 <exec>
  if(ret != -1){
    26c8:	57fd                	li	a5,-1
    26ca:	08f51c63          	bne	a0,a5,2762 <copyinstr3+0x12e>
}
    26ce:	70a2                	ld	ra,40(sp)
    26d0:	7402                	ld	s0,32(sp)
    26d2:	64e2                	ld	s1,24(sp)
    26d4:	6145                	addi	sp,sp,48
    26d6:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    26d8:	0347d513          	srli	a0,a5,0x34
    26dc:	6785                	lui	a5,0x1
    26de:	40a7853b          	subw	a0,a5,a0
    26e2:	00003097          	auipc	ra,0x3
    26e6:	7f0080e7          	jalr	2032(ra) # 5ed2 <sbrk>
    26ea:	b7bd                	j	2658 <copyinstr3+0x24>
    printf("oops\n");
    26ec:	00005517          	auipc	a0,0x5
    26f0:	d7c50513          	addi	a0,a0,-644 # 7468 <uthread_self+0xd8e>
    26f4:	00004097          	auipc	ra,0x4
    26f8:	af6080e7          	jalr	-1290(ra) # 61ea <printf>
    exit(1);
    26fc:	4505                	li	a0,1
    26fe:	00003097          	auipc	ra,0x3
    2702:	74c080e7          	jalr	1868(ra) # 5e4a <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    2706:	862a                	mv	a2,a0
    2708:	85a6                	mv	a1,s1
    270a:	00005517          	auipc	a0,0x5
    270e:	80650513          	addi	a0,a0,-2042 # 6f10 <uthread_self+0x836>
    2712:	00004097          	auipc	ra,0x4
    2716:	ad8080e7          	jalr	-1320(ra) # 61ea <printf>
    exit(1);
    271a:	4505                	li	a0,1
    271c:	00003097          	auipc	ra,0x3
    2720:	72e080e7          	jalr	1838(ra) # 5e4a <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2724:	862a                	mv	a2,a0
    2726:	85a6                	mv	a1,s1
    2728:	00005517          	auipc	a0,0x5
    272c:	80850513          	addi	a0,a0,-2040 # 6f30 <uthread_self+0x856>
    2730:	00004097          	auipc	ra,0x4
    2734:	aba080e7          	jalr	-1350(ra) # 61ea <printf>
    exit(1);
    2738:	4505                	li	a0,1
    273a:	00003097          	auipc	ra,0x3
    273e:	710080e7          	jalr	1808(ra) # 5e4a <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2742:	86aa                	mv	a3,a0
    2744:	8626                	mv	a2,s1
    2746:	85a6                	mv	a1,s1
    2748:	00005517          	auipc	a0,0x5
    274c:	80850513          	addi	a0,a0,-2040 # 6f50 <uthread_self+0x876>
    2750:	00004097          	auipc	ra,0x4
    2754:	a9a080e7          	jalr	-1382(ra) # 61ea <printf>
    exit(1);
    2758:	4505                	li	a0,1
    275a:	00003097          	auipc	ra,0x3
    275e:	6f0080e7          	jalr	1776(ra) # 5e4a <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2762:	567d                	li	a2,-1
    2764:	85a6                	mv	a1,s1
    2766:	00005517          	auipc	a0,0x5
    276a:	81250513          	addi	a0,a0,-2030 # 6f78 <uthread_self+0x89e>
    276e:	00004097          	auipc	ra,0x4
    2772:	a7c080e7          	jalr	-1412(ra) # 61ea <printf>
    exit(1);
    2776:	4505                	li	a0,1
    2778:	00003097          	auipc	ra,0x3
    277c:	6d2080e7          	jalr	1746(ra) # 5e4a <exit>

0000000000002780 <rwsbrk>:
{
    2780:	1101                	addi	sp,sp,-32
    2782:	ec06                	sd	ra,24(sp)
    2784:	e822                	sd	s0,16(sp)
    2786:	e426                	sd	s1,8(sp)
    2788:	e04a                	sd	s2,0(sp)
    278a:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    278c:	6509                	lui	a0,0x2
    278e:	00003097          	auipc	ra,0x3
    2792:	744080e7          	jalr	1860(ra) # 5ed2 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2796:	57fd                	li	a5,-1
    2798:	06f50363          	beq	a0,a5,27fe <rwsbrk+0x7e>
    279c:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    279e:	7579                	lui	a0,0xffffe
    27a0:	00003097          	auipc	ra,0x3
    27a4:	732080e7          	jalr	1842(ra) # 5ed2 <sbrk>
    27a8:	57fd                	li	a5,-1
    27aa:	06f50763          	beq	a0,a5,2818 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    27ae:	20100593          	li	a1,513
    27b2:	00005517          	auipc	a0,0x5
    27b6:	cf650513          	addi	a0,a0,-778 # 74a8 <uthread_self+0xdce>
    27ba:	00003097          	auipc	ra,0x3
    27be:	6d0080e7          	jalr	1744(ra) # 5e8a <open>
    27c2:	892a                	mv	s2,a0
  if(fd < 0){
    27c4:	06054763          	bltz	a0,2832 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    27c8:	6505                	lui	a0,0x1
    27ca:	94aa                	add	s1,s1,a0
    27cc:	40000613          	li	a2,1024
    27d0:	85a6                	mv	a1,s1
    27d2:	854a                	mv	a0,s2
    27d4:	00003097          	auipc	ra,0x3
    27d8:	696080e7          	jalr	1686(ra) # 5e6a <write>
    27dc:	862a                	mv	a2,a0
  if(n >= 0){
    27de:	06054763          	bltz	a0,284c <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    27e2:	85a6                	mv	a1,s1
    27e4:	00005517          	auipc	a0,0x5
    27e8:	ce450513          	addi	a0,a0,-796 # 74c8 <uthread_self+0xdee>
    27ec:	00004097          	auipc	ra,0x4
    27f0:	9fe080e7          	jalr	-1538(ra) # 61ea <printf>
    exit(1);
    27f4:	4505                	li	a0,1
    27f6:	00003097          	auipc	ra,0x3
    27fa:	654080e7          	jalr	1620(ra) # 5e4a <exit>
    printf("sbrk(rwsbrk) failed\n");
    27fe:	00005517          	auipc	a0,0x5
    2802:	c7250513          	addi	a0,a0,-910 # 7470 <uthread_self+0xd96>
    2806:	00004097          	auipc	ra,0x4
    280a:	9e4080e7          	jalr	-1564(ra) # 61ea <printf>
    exit(1);
    280e:	4505                	li	a0,1
    2810:	00003097          	auipc	ra,0x3
    2814:	63a080e7          	jalr	1594(ra) # 5e4a <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    2818:	00005517          	auipc	a0,0x5
    281c:	c7050513          	addi	a0,a0,-912 # 7488 <uthread_self+0xdae>
    2820:	00004097          	auipc	ra,0x4
    2824:	9ca080e7          	jalr	-1590(ra) # 61ea <printf>
    exit(1);
    2828:	4505                	li	a0,1
    282a:	00003097          	auipc	ra,0x3
    282e:	620080e7          	jalr	1568(ra) # 5e4a <exit>
    printf("open(rwsbrk) failed\n");
    2832:	00005517          	auipc	a0,0x5
    2836:	c7e50513          	addi	a0,a0,-898 # 74b0 <uthread_self+0xdd6>
    283a:	00004097          	auipc	ra,0x4
    283e:	9b0080e7          	jalr	-1616(ra) # 61ea <printf>
    exit(1);
    2842:	4505                	li	a0,1
    2844:	00003097          	auipc	ra,0x3
    2848:	606080e7          	jalr	1542(ra) # 5e4a <exit>
  close(fd);
    284c:	854a                	mv	a0,s2
    284e:	00003097          	auipc	ra,0x3
    2852:	624080e7          	jalr	1572(ra) # 5e72 <close>
  unlink("rwsbrk");
    2856:	00005517          	auipc	a0,0x5
    285a:	c5250513          	addi	a0,a0,-942 # 74a8 <uthread_self+0xdce>
    285e:	00003097          	auipc	ra,0x3
    2862:	63c080e7          	jalr	1596(ra) # 5e9a <unlink>
  fd = open("README", O_RDONLY);
    2866:	4581                	li	a1,0
    2868:	00004517          	auipc	a0,0x4
    286c:	0d850513          	addi	a0,a0,216 # 6940 <uthread_self+0x266>
    2870:	00003097          	auipc	ra,0x3
    2874:	61a080e7          	jalr	1562(ra) # 5e8a <open>
    2878:	892a                	mv	s2,a0
  if(fd < 0){
    287a:	02054963          	bltz	a0,28ac <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    287e:	4629                	li	a2,10
    2880:	85a6                	mv	a1,s1
    2882:	00003097          	auipc	ra,0x3
    2886:	5e0080e7          	jalr	1504(ra) # 5e62 <read>
    288a:	862a                	mv	a2,a0
  if(n >= 0){
    288c:	02054d63          	bltz	a0,28c6 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2890:	85a6                	mv	a1,s1
    2892:	00005517          	auipc	a0,0x5
    2896:	c6650513          	addi	a0,a0,-922 # 74f8 <uthread_self+0xe1e>
    289a:	00004097          	auipc	ra,0x4
    289e:	950080e7          	jalr	-1712(ra) # 61ea <printf>
    exit(1);
    28a2:	4505                	li	a0,1
    28a4:	00003097          	auipc	ra,0x3
    28a8:	5a6080e7          	jalr	1446(ra) # 5e4a <exit>
    printf("open(rwsbrk) failed\n");
    28ac:	00005517          	auipc	a0,0x5
    28b0:	c0450513          	addi	a0,a0,-1020 # 74b0 <uthread_self+0xdd6>
    28b4:	00004097          	auipc	ra,0x4
    28b8:	936080e7          	jalr	-1738(ra) # 61ea <printf>
    exit(1);
    28bc:	4505                	li	a0,1
    28be:	00003097          	auipc	ra,0x3
    28c2:	58c080e7          	jalr	1420(ra) # 5e4a <exit>
  close(fd);
    28c6:	854a                	mv	a0,s2
    28c8:	00003097          	auipc	ra,0x3
    28cc:	5aa080e7          	jalr	1450(ra) # 5e72 <close>
  exit(0);
    28d0:	4501                	li	a0,0
    28d2:	00003097          	auipc	ra,0x3
    28d6:	578080e7          	jalr	1400(ra) # 5e4a <exit>

00000000000028da <sbrkbasic>:
{
    28da:	7139                	addi	sp,sp,-64
    28dc:	fc06                	sd	ra,56(sp)
    28de:	f822                	sd	s0,48(sp)
    28e0:	f426                	sd	s1,40(sp)
    28e2:	f04a                	sd	s2,32(sp)
    28e4:	ec4e                	sd	s3,24(sp)
    28e6:	e852                	sd	s4,16(sp)
    28e8:	0080                	addi	s0,sp,64
    28ea:	8a2a                	mv	s4,a0
  pid = fork();
    28ec:	00003097          	auipc	ra,0x3
    28f0:	556080e7          	jalr	1366(ra) # 5e42 <fork>
  if(pid < 0){
    28f4:	02054c63          	bltz	a0,292c <sbrkbasic+0x52>
  if(pid == 0){
    28f8:	ed21                	bnez	a0,2950 <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    28fa:	40000537          	lui	a0,0x40000
    28fe:	00003097          	auipc	ra,0x3
    2902:	5d4080e7          	jalr	1492(ra) # 5ed2 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    2906:	57fd                	li	a5,-1
    2908:	02f50f63          	beq	a0,a5,2946 <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    290c:	400007b7          	lui	a5,0x40000
    2910:	97aa                	add	a5,a5,a0
      *b = 99;
    2912:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    2916:	6705                	lui	a4,0x1
      *b = 99;
    2918:	00d50023          	sb	a3,0(a0) # 40000000 <uthreads_arr+0x3fff02d8>
    for(b = a; b < a+TOOMUCH; b += 4096){
    291c:	953a                	add	a0,a0,a4
    291e:	fef51de3          	bne	a0,a5,2918 <sbrkbasic+0x3e>
    exit(1);
    2922:	4505                	li	a0,1
    2924:	00003097          	auipc	ra,0x3
    2928:	526080e7          	jalr	1318(ra) # 5e4a <exit>
    printf("fork failed in sbrkbasic\n");
    292c:	00005517          	auipc	a0,0x5
    2930:	bf450513          	addi	a0,a0,-1036 # 7520 <uthread_self+0xe46>
    2934:	00004097          	auipc	ra,0x4
    2938:	8b6080e7          	jalr	-1866(ra) # 61ea <printf>
    exit(1);
    293c:	4505                	li	a0,1
    293e:	00003097          	auipc	ra,0x3
    2942:	50c080e7          	jalr	1292(ra) # 5e4a <exit>
      exit(0);
    2946:	4501                	li	a0,0
    2948:	00003097          	auipc	ra,0x3
    294c:	502080e7          	jalr	1282(ra) # 5e4a <exit>
  wait(&xstatus);
    2950:	fcc40513          	addi	a0,s0,-52
    2954:	00003097          	auipc	ra,0x3
    2958:	4fe080e7          	jalr	1278(ra) # 5e52 <wait>
  if(xstatus == 1){
    295c:	fcc42703          	lw	a4,-52(s0)
    2960:	4785                	li	a5,1
    2962:	00f70d63          	beq	a4,a5,297c <sbrkbasic+0xa2>
  a = sbrk(0);
    2966:	4501                	li	a0,0
    2968:	00003097          	auipc	ra,0x3
    296c:	56a080e7          	jalr	1386(ra) # 5ed2 <sbrk>
    2970:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2972:	4901                	li	s2,0
    2974:	6985                	lui	s3,0x1
    2976:	38898993          	addi	s3,s3,904 # 1388 <badarg+0x16>
    297a:	a005                	j	299a <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    297c:	85d2                	mv	a1,s4
    297e:	00005517          	auipc	a0,0x5
    2982:	bc250513          	addi	a0,a0,-1086 # 7540 <uthread_self+0xe66>
    2986:	00004097          	auipc	ra,0x4
    298a:	864080e7          	jalr	-1948(ra) # 61ea <printf>
    exit(1);
    298e:	4505                	li	a0,1
    2990:	00003097          	auipc	ra,0x3
    2994:	4ba080e7          	jalr	1210(ra) # 5e4a <exit>
    a = b + 1;
    2998:	84be                	mv	s1,a5
    b = sbrk(1);
    299a:	4505                	li	a0,1
    299c:	00003097          	auipc	ra,0x3
    29a0:	536080e7          	jalr	1334(ra) # 5ed2 <sbrk>
    if(b != a){
    29a4:	04951c63          	bne	a0,s1,29fc <sbrkbasic+0x122>
    *b = 1;
    29a8:	4785                	li	a5,1
    29aa:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    29ae:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    29b2:	2905                	addiw	s2,s2,1
    29b4:	ff3912e3          	bne	s2,s3,2998 <sbrkbasic+0xbe>
  pid = fork();
    29b8:	00003097          	auipc	ra,0x3
    29bc:	48a080e7          	jalr	1162(ra) # 5e42 <fork>
    29c0:	892a                	mv	s2,a0
  if(pid < 0){
    29c2:	04054e63          	bltz	a0,2a1e <sbrkbasic+0x144>
  c = sbrk(1);
    29c6:	4505                	li	a0,1
    29c8:	00003097          	auipc	ra,0x3
    29cc:	50a080e7          	jalr	1290(ra) # 5ed2 <sbrk>
  c = sbrk(1);
    29d0:	4505                	li	a0,1
    29d2:	00003097          	auipc	ra,0x3
    29d6:	500080e7          	jalr	1280(ra) # 5ed2 <sbrk>
  if(c != a + 1){
    29da:	0489                	addi	s1,s1,2
    29dc:	04a48f63          	beq	s1,a0,2a3a <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    29e0:	85d2                	mv	a1,s4
    29e2:	00005517          	auipc	a0,0x5
    29e6:	bbe50513          	addi	a0,a0,-1090 # 75a0 <uthread_self+0xec6>
    29ea:	00004097          	auipc	ra,0x4
    29ee:	800080e7          	jalr	-2048(ra) # 61ea <printf>
    exit(1);
    29f2:	4505                	li	a0,1
    29f4:	00003097          	auipc	ra,0x3
    29f8:	456080e7          	jalr	1110(ra) # 5e4a <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    29fc:	872a                	mv	a4,a0
    29fe:	86a6                	mv	a3,s1
    2a00:	864a                	mv	a2,s2
    2a02:	85d2                	mv	a1,s4
    2a04:	00005517          	auipc	a0,0x5
    2a08:	b5c50513          	addi	a0,a0,-1188 # 7560 <uthread_self+0xe86>
    2a0c:	00003097          	auipc	ra,0x3
    2a10:	7de080e7          	jalr	2014(ra) # 61ea <printf>
      exit(1);
    2a14:	4505                	li	a0,1
    2a16:	00003097          	auipc	ra,0x3
    2a1a:	434080e7          	jalr	1076(ra) # 5e4a <exit>
    printf("%s: sbrk test fork failed\n", s);
    2a1e:	85d2                	mv	a1,s4
    2a20:	00005517          	auipc	a0,0x5
    2a24:	b6050513          	addi	a0,a0,-1184 # 7580 <uthread_self+0xea6>
    2a28:	00003097          	auipc	ra,0x3
    2a2c:	7c2080e7          	jalr	1986(ra) # 61ea <printf>
    exit(1);
    2a30:	4505                	li	a0,1
    2a32:	00003097          	auipc	ra,0x3
    2a36:	418080e7          	jalr	1048(ra) # 5e4a <exit>
  if(pid == 0)
    2a3a:	00091763          	bnez	s2,2a48 <sbrkbasic+0x16e>
    exit(0);
    2a3e:	4501                	li	a0,0
    2a40:	00003097          	auipc	ra,0x3
    2a44:	40a080e7          	jalr	1034(ra) # 5e4a <exit>
  wait(&xstatus);
    2a48:	fcc40513          	addi	a0,s0,-52
    2a4c:	00003097          	auipc	ra,0x3
    2a50:	406080e7          	jalr	1030(ra) # 5e52 <wait>
  exit(xstatus);
    2a54:	fcc42503          	lw	a0,-52(s0)
    2a58:	00003097          	auipc	ra,0x3
    2a5c:	3f2080e7          	jalr	1010(ra) # 5e4a <exit>

0000000000002a60 <sbrkmuch>:
{
    2a60:	7179                	addi	sp,sp,-48
    2a62:	f406                	sd	ra,40(sp)
    2a64:	f022                	sd	s0,32(sp)
    2a66:	ec26                	sd	s1,24(sp)
    2a68:	e84a                	sd	s2,16(sp)
    2a6a:	e44e                	sd	s3,8(sp)
    2a6c:	e052                	sd	s4,0(sp)
    2a6e:	1800                	addi	s0,sp,48
    2a70:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2a72:	4501                	li	a0,0
    2a74:	00003097          	auipc	ra,0x3
    2a78:	45e080e7          	jalr	1118(ra) # 5ed2 <sbrk>
    2a7c:	892a                	mv	s2,a0
  a = sbrk(0);
    2a7e:	4501                	li	a0,0
    2a80:	00003097          	auipc	ra,0x3
    2a84:	452080e7          	jalr	1106(ra) # 5ed2 <sbrk>
    2a88:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2a8a:	06400537          	lui	a0,0x6400
    2a8e:	9d05                	subw	a0,a0,s1
    2a90:	00003097          	auipc	ra,0x3
    2a94:	442080e7          	jalr	1090(ra) # 5ed2 <sbrk>
  if (p != a) {
    2a98:	0ca49863          	bne	s1,a0,2b68 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2a9c:	4501                	li	a0,0
    2a9e:	00003097          	auipc	ra,0x3
    2aa2:	434080e7          	jalr	1076(ra) # 5ed2 <sbrk>
    2aa6:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2aa8:	00a4f963          	bgeu	s1,a0,2aba <sbrkmuch+0x5a>
    *pp = 1;
    2aac:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2aae:	6705                	lui	a4,0x1
    *pp = 1;
    2ab0:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2ab4:	94ba                	add	s1,s1,a4
    2ab6:	fef4ede3          	bltu	s1,a5,2ab0 <sbrkmuch+0x50>
  *lastaddr = 99;
    2aba:	064007b7          	lui	a5,0x6400
    2abe:	06300713          	li	a4,99
    2ac2:	fee78fa3          	sb	a4,-1(a5) # 63fffff <uthreads_arr+0x63f02d7>
  a = sbrk(0);
    2ac6:	4501                	li	a0,0
    2ac8:	00003097          	auipc	ra,0x3
    2acc:	40a080e7          	jalr	1034(ra) # 5ed2 <sbrk>
    2ad0:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2ad2:	757d                	lui	a0,0xfffff
    2ad4:	00003097          	auipc	ra,0x3
    2ad8:	3fe080e7          	jalr	1022(ra) # 5ed2 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2adc:	57fd                	li	a5,-1
    2ade:	0af50363          	beq	a0,a5,2b84 <sbrkmuch+0x124>
  c = sbrk(0);
    2ae2:	4501                	li	a0,0
    2ae4:	00003097          	auipc	ra,0x3
    2ae8:	3ee080e7          	jalr	1006(ra) # 5ed2 <sbrk>
  if(c != a - PGSIZE){
    2aec:	77fd                	lui	a5,0xfffff
    2aee:	97a6                	add	a5,a5,s1
    2af0:	0af51863          	bne	a0,a5,2ba0 <sbrkmuch+0x140>
  a = sbrk(0);
    2af4:	4501                	li	a0,0
    2af6:	00003097          	auipc	ra,0x3
    2afa:	3dc080e7          	jalr	988(ra) # 5ed2 <sbrk>
    2afe:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2b00:	6505                	lui	a0,0x1
    2b02:	00003097          	auipc	ra,0x3
    2b06:	3d0080e7          	jalr	976(ra) # 5ed2 <sbrk>
    2b0a:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2b0c:	0aa49a63          	bne	s1,a0,2bc0 <sbrkmuch+0x160>
    2b10:	4501                	li	a0,0
    2b12:	00003097          	auipc	ra,0x3
    2b16:	3c0080e7          	jalr	960(ra) # 5ed2 <sbrk>
    2b1a:	6785                	lui	a5,0x1
    2b1c:	97a6                	add	a5,a5,s1
    2b1e:	0af51163          	bne	a0,a5,2bc0 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    2b22:	064007b7          	lui	a5,0x6400
    2b26:	fff7c703          	lbu	a4,-1(a5) # 63fffff <uthreads_arr+0x63f02d7>
    2b2a:	06300793          	li	a5,99
    2b2e:	0af70963          	beq	a4,a5,2be0 <sbrkmuch+0x180>
  a = sbrk(0);
    2b32:	4501                	li	a0,0
    2b34:	00003097          	auipc	ra,0x3
    2b38:	39e080e7          	jalr	926(ra) # 5ed2 <sbrk>
    2b3c:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2b3e:	4501                	li	a0,0
    2b40:	00003097          	auipc	ra,0x3
    2b44:	392080e7          	jalr	914(ra) # 5ed2 <sbrk>
    2b48:	40a9053b          	subw	a0,s2,a0
    2b4c:	00003097          	auipc	ra,0x3
    2b50:	386080e7          	jalr	902(ra) # 5ed2 <sbrk>
  if(c != a){
    2b54:	0aa49463          	bne	s1,a0,2bfc <sbrkmuch+0x19c>
}
    2b58:	70a2                	ld	ra,40(sp)
    2b5a:	7402                	ld	s0,32(sp)
    2b5c:	64e2                	ld	s1,24(sp)
    2b5e:	6942                	ld	s2,16(sp)
    2b60:	69a2                	ld	s3,8(sp)
    2b62:	6a02                	ld	s4,0(sp)
    2b64:	6145                	addi	sp,sp,48
    2b66:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2b68:	85ce                	mv	a1,s3
    2b6a:	00005517          	auipc	a0,0x5
    2b6e:	a5650513          	addi	a0,a0,-1450 # 75c0 <uthread_self+0xee6>
    2b72:	00003097          	auipc	ra,0x3
    2b76:	678080e7          	jalr	1656(ra) # 61ea <printf>
    exit(1);
    2b7a:	4505                	li	a0,1
    2b7c:	00003097          	auipc	ra,0x3
    2b80:	2ce080e7          	jalr	718(ra) # 5e4a <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2b84:	85ce                	mv	a1,s3
    2b86:	00005517          	auipc	a0,0x5
    2b8a:	a8250513          	addi	a0,a0,-1406 # 7608 <uthread_self+0xf2e>
    2b8e:	00003097          	auipc	ra,0x3
    2b92:	65c080e7          	jalr	1628(ra) # 61ea <printf>
    exit(1);
    2b96:	4505                	li	a0,1
    2b98:	00003097          	auipc	ra,0x3
    2b9c:	2b2080e7          	jalr	690(ra) # 5e4a <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2ba0:	86aa                	mv	a3,a0
    2ba2:	8626                	mv	a2,s1
    2ba4:	85ce                	mv	a1,s3
    2ba6:	00005517          	auipc	a0,0x5
    2baa:	a8250513          	addi	a0,a0,-1406 # 7628 <uthread_self+0xf4e>
    2bae:	00003097          	auipc	ra,0x3
    2bb2:	63c080e7          	jalr	1596(ra) # 61ea <printf>
    exit(1);
    2bb6:	4505                	li	a0,1
    2bb8:	00003097          	auipc	ra,0x3
    2bbc:	292080e7          	jalr	658(ra) # 5e4a <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2bc0:	86d2                	mv	a3,s4
    2bc2:	8626                	mv	a2,s1
    2bc4:	85ce                	mv	a1,s3
    2bc6:	00005517          	auipc	a0,0x5
    2bca:	aa250513          	addi	a0,a0,-1374 # 7668 <uthread_self+0xf8e>
    2bce:	00003097          	auipc	ra,0x3
    2bd2:	61c080e7          	jalr	1564(ra) # 61ea <printf>
    exit(1);
    2bd6:	4505                	li	a0,1
    2bd8:	00003097          	auipc	ra,0x3
    2bdc:	272080e7          	jalr	626(ra) # 5e4a <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2be0:	85ce                	mv	a1,s3
    2be2:	00005517          	auipc	a0,0x5
    2be6:	ab650513          	addi	a0,a0,-1354 # 7698 <uthread_self+0xfbe>
    2bea:	00003097          	auipc	ra,0x3
    2bee:	600080e7          	jalr	1536(ra) # 61ea <printf>
    exit(1);
    2bf2:	4505                	li	a0,1
    2bf4:	00003097          	auipc	ra,0x3
    2bf8:	256080e7          	jalr	598(ra) # 5e4a <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2bfc:	86aa                	mv	a3,a0
    2bfe:	8626                	mv	a2,s1
    2c00:	85ce                	mv	a1,s3
    2c02:	00005517          	auipc	a0,0x5
    2c06:	ace50513          	addi	a0,a0,-1330 # 76d0 <uthread_self+0xff6>
    2c0a:	00003097          	auipc	ra,0x3
    2c0e:	5e0080e7          	jalr	1504(ra) # 61ea <printf>
    exit(1);
    2c12:	4505                	li	a0,1
    2c14:	00003097          	auipc	ra,0x3
    2c18:	236080e7          	jalr	566(ra) # 5e4a <exit>

0000000000002c1c <sbrkarg>:
{
    2c1c:	7179                	addi	sp,sp,-48
    2c1e:	f406                	sd	ra,40(sp)
    2c20:	f022                	sd	s0,32(sp)
    2c22:	ec26                	sd	s1,24(sp)
    2c24:	e84a                	sd	s2,16(sp)
    2c26:	e44e                	sd	s3,8(sp)
    2c28:	1800                	addi	s0,sp,48
    2c2a:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2c2c:	6505                	lui	a0,0x1
    2c2e:	00003097          	auipc	ra,0x3
    2c32:	2a4080e7          	jalr	676(ra) # 5ed2 <sbrk>
    2c36:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2c38:	20100593          	li	a1,513
    2c3c:	00005517          	auipc	a0,0x5
    2c40:	abc50513          	addi	a0,a0,-1348 # 76f8 <uthread_self+0x101e>
    2c44:	00003097          	auipc	ra,0x3
    2c48:	246080e7          	jalr	582(ra) # 5e8a <open>
    2c4c:	84aa                	mv	s1,a0
  unlink("sbrk");
    2c4e:	00005517          	auipc	a0,0x5
    2c52:	aaa50513          	addi	a0,a0,-1366 # 76f8 <uthread_self+0x101e>
    2c56:	00003097          	auipc	ra,0x3
    2c5a:	244080e7          	jalr	580(ra) # 5e9a <unlink>
  if(fd < 0)  {
    2c5e:	0404c163          	bltz	s1,2ca0 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2c62:	6605                	lui	a2,0x1
    2c64:	85ca                	mv	a1,s2
    2c66:	8526                	mv	a0,s1
    2c68:	00003097          	auipc	ra,0x3
    2c6c:	202080e7          	jalr	514(ra) # 5e6a <write>
    2c70:	04054663          	bltz	a0,2cbc <sbrkarg+0xa0>
  close(fd);
    2c74:	8526                	mv	a0,s1
    2c76:	00003097          	auipc	ra,0x3
    2c7a:	1fc080e7          	jalr	508(ra) # 5e72 <close>
  a = sbrk(PGSIZE);
    2c7e:	6505                	lui	a0,0x1
    2c80:	00003097          	auipc	ra,0x3
    2c84:	252080e7          	jalr	594(ra) # 5ed2 <sbrk>
  if(pipe((int *) a) != 0){
    2c88:	00003097          	auipc	ra,0x3
    2c8c:	1d2080e7          	jalr	466(ra) # 5e5a <pipe>
    2c90:	e521                	bnez	a0,2cd8 <sbrkarg+0xbc>
}
    2c92:	70a2                	ld	ra,40(sp)
    2c94:	7402                	ld	s0,32(sp)
    2c96:	64e2                	ld	s1,24(sp)
    2c98:	6942                	ld	s2,16(sp)
    2c9a:	69a2                	ld	s3,8(sp)
    2c9c:	6145                	addi	sp,sp,48
    2c9e:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2ca0:	85ce                	mv	a1,s3
    2ca2:	00005517          	auipc	a0,0x5
    2ca6:	a5e50513          	addi	a0,a0,-1442 # 7700 <uthread_self+0x1026>
    2caa:	00003097          	auipc	ra,0x3
    2cae:	540080e7          	jalr	1344(ra) # 61ea <printf>
    exit(1);
    2cb2:	4505                	li	a0,1
    2cb4:	00003097          	auipc	ra,0x3
    2cb8:	196080e7          	jalr	406(ra) # 5e4a <exit>
    printf("%s: write sbrk failed\n", s);
    2cbc:	85ce                	mv	a1,s3
    2cbe:	00005517          	auipc	a0,0x5
    2cc2:	a5a50513          	addi	a0,a0,-1446 # 7718 <uthread_self+0x103e>
    2cc6:	00003097          	auipc	ra,0x3
    2cca:	524080e7          	jalr	1316(ra) # 61ea <printf>
    exit(1);
    2cce:	4505                	li	a0,1
    2cd0:	00003097          	auipc	ra,0x3
    2cd4:	17a080e7          	jalr	378(ra) # 5e4a <exit>
    printf("%s: pipe() failed\n", s);
    2cd8:	85ce                	mv	a1,s3
    2cda:	00004517          	auipc	a0,0x4
    2cde:	41e50513          	addi	a0,a0,1054 # 70f8 <uthread_self+0xa1e>
    2ce2:	00003097          	auipc	ra,0x3
    2ce6:	508080e7          	jalr	1288(ra) # 61ea <printf>
    exit(1);
    2cea:	4505                	li	a0,1
    2cec:	00003097          	auipc	ra,0x3
    2cf0:	15e080e7          	jalr	350(ra) # 5e4a <exit>

0000000000002cf4 <argptest>:
{
    2cf4:	1101                	addi	sp,sp,-32
    2cf6:	ec06                	sd	ra,24(sp)
    2cf8:	e822                	sd	s0,16(sp)
    2cfa:	e426                	sd	s1,8(sp)
    2cfc:	e04a                	sd	s2,0(sp)
    2cfe:	1000                	addi	s0,sp,32
    2d00:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2d02:	4581                	li	a1,0
    2d04:	00005517          	auipc	a0,0x5
    2d08:	a2c50513          	addi	a0,a0,-1492 # 7730 <uthread_self+0x1056>
    2d0c:	00003097          	auipc	ra,0x3
    2d10:	17e080e7          	jalr	382(ra) # 5e8a <open>
  if (fd < 0) {
    2d14:	02054b63          	bltz	a0,2d4a <argptest+0x56>
    2d18:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2d1a:	4501                	li	a0,0
    2d1c:	00003097          	auipc	ra,0x3
    2d20:	1b6080e7          	jalr	438(ra) # 5ed2 <sbrk>
    2d24:	567d                	li	a2,-1
    2d26:	fff50593          	addi	a1,a0,-1
    2d2a:	8526                	mv	a0,s1
    2d2c:	00003097          	auipc	ra,0x3
    2d30:	136080e7          	jalr	310(ra) # 5e62 <read>
  close(fd);
    2d34:	8526                	mv	a0,s1
    2d36:	00003097          	auipc	ra,0x3
    2d3a:	13c080e7          	jalr	316(ra) # 5e72 <close>
}
    2d3e:	60e2                	ld	ra,24(sp)
    2d40:	6442                	ld	s0,16(sp)
    2d42:	64a2                	ld	s1,8(sp)
    2d44:	6902                	ld	s2,0(sp)
    2d46:	6105                	addi	sp,sp,32
    2d48:	8082                	ret
    printf("%s: open failed\n", s);
    2d4a:	85ca                	mv	a1,s2
    2d4c:	00004517          	auipc	a0,0x4
    2d50:	2bc50513          	addi	a0,a0,700 # 7008 <uthread_self+0x92e>
    2d54:	00003097          	auipc	ra,0x3
    2d58:	496080e7          	jalr	1174(ra) # 61ea <printf>
    exit(1);
    2d5c:	4505                	li	a0,1
    2d5e:	00003097          	auipc	ra,0x3
    2d62:	0ec080e7          	jalr	236(ra) # 5e4a <exit>

0000000000002d66 <sbrkbugs>:
{
    2d66:	1141                	addi	sp,sp,-16
    2d68:	e406                	sd	ra,8(sp)
    2d6a:	e022                	sd	s0,0(sp)
    2d6c:	0800                	addi	s0,sp,16
  int pid = fork();
    2d6e:	00003097          	auipc	ra,0x3
    2d72:	0d4080e7          	jalr	212(ra) # 5e42 <fork>
  if(pid < 0){
    2d76:	02054263          	bltz	a0,2d9a <sbrkbugs+0x34>
  if(pid == 0){
    2d7a:	ed0d                	bnez	a0,2db4 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2d7c:	00003097          	auipc	ra,0x3
    2d80:	156080e7          	jalr	342(ra) # 5ed2 <sbrk>
    sbrk(-sz);
    2d84:	40a0053b          	negw	a0,a0
    2d88:	00003097          	auipc	ra,0x3
    2d8c:	14a080e7          	jalr	330(ra) # 5ed2 <sbrk>
    exit(0);
    2d90:	4501                	li	a0,0
    2d92:	00003097          	auipc	ra,0x3
    2d96:	0b8080e7          	jalr	184(ra) # 5e4a <exit>
    printf("fork failed\n");
    2d9a:	00004517          	auipc	a0,0x4
    2d9e:	65e50513          	addi	a0,a0,1630 # 73f8 <uthread_self+0xd1e>
    2da2:	00003097          	auipc	ra,0x3
    2da6:	448080e7          	jalr	1096(ra) # 61ea <printf>
    exit(1);
    2daa:	4505                	li	a0,1
    2dac:	00003097          	auipc	ra,0x3
    2db0:	09e080e7          	jalr	158(ra) # 5e4a <exit>
  wait(0);
    2db4:	4501                	li	a0,0
    2db6:	00003097          	auipc	ra,0x3
    2dba:	09c080e7          	jalr	156(ra) # 5e52 <wait>
  pid = fork();
    2dbe:	00003097          	auipc	ra,0x3
    2dc2:	084080e7          	jalr	132(ra) # 5e42 <fork>
  if(pid < 0){
    2dc6:	02054563          	bltz	a0,2df0 <sbrkbugs+0x8a>
  if(pid == 0){
    2dca:	e121                	bnez	a0,2e0a <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2dcc:	00003097          	auipc	ra,0x3
    2dd0:	106080e7          	jalr	262(ra) # 5ed2 <sbrk>
    sbrk(-(sz - 3500));
    2dd4:	6785                	lui	a5,0x1
    2dd6:	dac7879b          	addiw	a5,a5,-596
    2dda:	40a7853b          	subw	a0,a5,a0
    2dde:	00003097          	auipc	ra,0x3
    2de2:	0f4080e7          	jalr	244(ra) # 5ed2 <sbrk>
    exit(0);
    2de6:	4501                	li	a0,0
    2de8:	00003097          	auipc	ra,0x3
    2dec:	062080e7          	jalr	98(ra) # 5e4a <exit>
    printf("fork failed\n");
    2df0:	00004517          	auipc	a0,0x4
    2df4:	60850513          	addi	a0,a0,1544 # 73f8 <uthread_self+0xd1e>
    2df8:	00003097          	auipc	ra,0x3
    2dfc:	3f2080e7          	jalr	1010(ra) # 61ea <printf>
    exit(1);
    2e00:	4505                	li	a0,1
    2e02:	00003097          	auipc	ra,0x3
    2e06:	048080e7          	jalr	72(ra) # 5e4a <exit>
  wait(0);
    2e0a:	4501                	li	a0,0
    2e0c:	00003097          	auipc	ra,0x3
    2e10:	046080e7          	jalr	70(ra) # 5e52 <wait>
  pid = fork();
    2e14:	00003097          	auipc	ra,0x3
    2e18:	02e080e7          	jalr	46(ra) # 5e42 <fork>
  if(pid < 0){
    2e1c:	02054a63          	bltz	a0,2e50 <sbrkbugs+0xea>
  if(pid == 0){
    2e20:	e529                	bnez	a0,2e6a <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2e22:	00003097          	auipc	ra,0x3
    2e26:	0b0080e7          	jalr	176(ra) # 5ed2 <sbrk>
    2e2a:	67ad                	lui	a5,0xb
    2e2c:	8007879b          	addiw	a5,a5,-2048
    2e30:	40a7853b          	subw	a0,a5,a0
    2e34:	00003097          	auipc	ra,0x3
    2e38:	09e080e7          	jalr	158(ra) # 5ed2 <sbrk>
    sbrk(-10);
    2e3c:	5559                	li	a0,-10
    2e3e:	00003097          	auipc	ra,0x3
    2e42:	094080e7          	jalr	148(ra) # 5ed2 <sbrk>
    exit(0);
    2e46:	4501                	li	a0,0
    2e48:	00003097          	auipc	ra,0x3
    2e4c:	002080e7          	jalr	2(ra) # 5e4a <exit>
    printf("fork failed\n");
    2e50:	00004517          	auipc	a0,0x4
    2e54:	5a850513          	addi	a0,a0,1448 # 73f8 <uthread_self+0xd1e>
    2e58:	00003097          	auipc	ra,0x3
    2e5c:	392080e7          	jalr	914(ra) # 61ea <printf>
    exit(1);
    2e60:	4505                	li	a0,1
    2e62:	00003097          	auipc	ra,0x3
    2e66:	fe8080e7          	jalr	-24(ra) # 5e4a <exit>
  wait(0);
    2e6a:	4501                	li	a0,0
    2e6c:	00003097          	auipc	ra,0x3
    2e70:	fe6080e7          	jalr	-26(ra) # 5e52 <wait>
  exit(0);
    2e74:	4501                	li	a0,0
    2e76:	00003097          	auipc	ra,0x3
    2e7a:	fd4080e7          	jalr	-44(ra) # 5e4a <exit>

0000000000002e7e <sbrklast>:
{
    2e7e:	7179                	addi	sp,sp,-48
    2e80:	f406                	sd	ra,40(sp)
    2e82:	f022                	sd	s0,32(sp)
    2e84:	ec26                	sd	s1,24(sp)
    2e86:	e84a                	sd	s2,16(sp)
    2e88:	e44e                	sd	s3,8(sp)
    2e8a:	e052                	sd	s4,0(sp)
    2e8c:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    2e8e:	4501                	li	a0,0
    2e90:	00003097          	auipc	ra,0x3
    2e94:	042080e7          	jalr	66(ra) # 5ed2 <sbrk>
  if((top % 4096) != 0)
    2e98:	03451793          	slli	a5,a0,0x34
    2e9c:	ebd9                	bnez	a5,2f32 <sbrklast+0xb4>
  sbrk(4096);
    2e9e:	6505                	lui	a0,0x1
    2ea0:	00003097          	auipc	ra,0x3
    2ea4:	032080e7          	jalr	50(ra) # 5ed2 <sbrk>
  sbrk(10);
    2ea8:	4529                	li	a0,10
    2eaa:	00003097          	auipc	ra,0x3
    2eae:	028080e7          	jalr	40(ra) # 5ed2 <sbrk>
  sbrk(-20);
    2eb2:	5531                	li	a0,-20
    2eb4:	00003097          	auipc	ra,0x3
    2eb8:	01e080e7          	jalr	30(ra) # 5ed2 <sbrk>
  top = (uint64) sbrk(0);
    2ebc:	4501                	li	a0,0
    2ebe:	00003097          	auipc	ra,0x3
    2ec2:	014080e7          	jalr	20(ra) # 5ed2 <sbrk>
    2ec6:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2ec8:	fc050913          	addi	s2,a0,-64 # fc0 <linktest+0xa4>
  p[0] = 'x';
    2ecc:	07800a13          	li	s4,120
    2ed0:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2ed4:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2ed8:	20200593          	li	a1,514
    2edc:	854a                	mv	a0,s2
    2ede:	00003097          	auipc	ra,0x3
    2ee2:	fac080e7          	jalr	-84(ra) # 5e8a <open>
    2ee6:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2ee8:	4605                	li	a2,1
    2eea:	85ca                	mv	a1,s2
    2eec:	00003097          	auipc	ra,0x3
    2ef0:	f7e080e7          	jalr	-130(ra) # 5e6a <write>
  close(fd);
    2ef4:	854e                	mv	a0,s3
    2ef6:	00003097          	auipc	ra,0x3
    2efa:	f7c080e7          	jalr	-132(ra) # 5e72 <close>
  fd = open(p, O_RDWR);
    2efe:	4589                	li	a1,2
    2f00:	854a                	mv	a0,s2
    2f02:	00003097          	auipc	ra,0x3
    2f06:	f88080e7          	jalr	-120(ra) # 5e8a <open>
  p[0] = '\0';
    2f0a:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2f0e:	4605                	li	a2,1
    2f10:	85ca                	mv	a1,s2
    2f12:	00003097          	auipc	ra,0x3
    2f16:	f50080e7          	jalr	-176(ra) # 5e62 <read>
  if(p[0] != 'x')
    2f1a:	fc04c783          	lbu	a5,-64(s1)
    2f1e:	03479463          	bne	a5,s4,2f46 <sbrklast+0xc8>
}
    2f22:	70a2                	ld	ra,40(sp)
    2f24:	7402                	ld	s0,32(sp)
    2f26:	64e2                	ld	s1,24(sp)
    2f28:	6942                	ld	s2,16(sp)
    2f2a:	69a2                	ld	s3,8(sp)
    2f2c:	6a02                	ld	s4,0(sp)
    2f2e:	6145                	addi	sp,sp,48
    2f30:	8082                	ret
    sbrk(4096 - (top % 4096));
    2f32:	0347d513          	srli	a0,a5,0x34
    2f36:	6785                	lui	a5,0x1
    2f38:	40a7853b          	subw	a0,a5,a0
    2f3c:	00003097          	auipc	ra,0x3
    2f40:	f96080e7          	jalr	-106(ra) # 5ed2 <sbrk>
    2f44:	bfa9                	j	2e9e <sbrklast+0x20>
    exit(1);
    2f46:	4505                	li	a0,1
    2f48:	00003097          	auipc	ra,0x3
    2f4c:	f02080e7          	jalr	-254(ra) # 5e4a <exit>

0000000000002f50 <sbrk8000>:
{
    2f50:	1141                	addi	sp,sp,-16
    2f52:	e406                	sd	ra,8(sp)
    2f54:	e022                	sd	s0,0(sp)
    2f56:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2f58:	80000537          	lui	a0,0x80000
    2f5c:	0511                	addi	a0,a0,4
    2f5e:	00003097          	auipc	ra,0x3
    2f62:	f74080e7          	jalr	-140(ra) # 5ed2 <sbrk>
  volatile char *top = sbrk(0);
    2f66:	4501                	li	a0,0
    2f68:	00003097          	auipc	ra,0x3
    2f6c:	f6a080e7          	jalr	-150(ra) # 5ed2 <sbrk>
  *(top-1) = *(top-1) + 1;
    2f70:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <uthreads_arr+0xffffffff7fff02d7>
    2f74:	0785                	addi	a5,a5,1
    2f76:	0ff7f793          	andi	a5,a5,255
    2f7a:	fef50fa3          	sb	a5,-1(a0)
}
    2f7e:	60a2                	ld	ra,8(sp)
    2f80:	6402                	ld	s0,0(sp)
    2f82:	0141                	addi	sp,sp,16
    2f84:	8082                	ret

0000000000002f86 <execout>:
{
    2f86:	715d                	addi	sp,sp,-80
    2f88:	e486                	sd	ra,72(sp)
    2f8a:	e0a2                	sd	s0,64(sp)
    2f8c:	fc26                	sd	s1,56(sp)
    2f8e:	f84a                	sd	s2,48(sp)
    2f90:	f44e                	sd	s3,40(sp)
    2f92:	f052                	sd	s4,32(sp)
    2f94:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2f96:	4901                	li	s2,0
    2f98:	49bd                	li	s3,15
    int pid = fork();
    2f9a:	00003097          	auipc	ra,0x3
    2f9e:	ea8080e7          	jalr	-344(ra) # 5e42 <fork>
    2fa2:	84aa                	mv	s1,a0
    if(pid < 0){
    2fa4:	02054063          	bltz	a0,2fc4 <execout+0x3e>
    } else if(pid == 0){
    2fa8:	c91d                	beqz	a0,2fde <execout+0x58>
      wait((int*)0);
    2faa:	4501                	li	a0,0
    2fac:	00003097          	auipc	ra,0x3
    2fb0:	ea6080e7          	jalr	-346(ra) # 5e52 <wait>
  for(int avail = 0; avail < 15; avail++){
    2fb4:	2905                	addiw	s2,s2,1
    2fb6:	ff3912e3          	bne	s2,s3,2f9a <execout+0x14>
  exit(0);
    2fba:	4501                	li	a0,0
    2fbc:	00003097          	auipc	ra,0x3
    2fc0:	e8e080e7          	jalr	-370(ra) # 5e4a <exit>
      printf("fork failed\n");
    2fc4:	00004517          	auipc	a0,0x4
    2fc8:	43450513          	addi	a0,a0,1076 # 73f8 <uthread_self+0xd1e>
    2fcc:	00003097          	auipc	ra,0x3
    2fd0:	21e080e7          	jalr	542(ra) # 61ea <printf>
      exit(1);
    2fd4:	4505                	li	a0,1
    2fd6:	00003097          	auipc	ra,0x3
    2fda:	e74080e7          	jalr	-396(ra) # 5e4a <exit>
        if(a == 0xffffffffffffffffLL)
    2fde:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2fe0:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2fe2:	6505                	lui	a0,0x1
    2fe4:	00003097          	auipc	ra,0x3
    2fe8:	eee080e7          	jalr	-274(ra) # 5ed2 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2fec:	01350763          	beq	a0,s3,2ffa <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2ff0:	6785                	lui	a5,0x1
    2ff2:	953e                	add	a0,a0,a5
    2ff4:	ff450fa3          	sb	s4,-1(a0) # fff <linktest+0xe3>
      while(1){
    2ff8:	b7ed                	j	2fe2 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2ffa:	01205a63          	blez	s2,300e <execout+0x88>
        sbrk(-4096);
    2ffe:	757d                	lui	a0,0xfffff
    3000:	00003097          	auipc	ra,0x3
    3004:	ed2080e7          	jalr	-302(ra) # 5ed2 <sbrk>
      for(int i = 0; i < avail; i++)
    3008:	2485                	addiw	s1,s1,1
    300a:	ff249ae3          	bne	s1,s2,2ffe <execout+0x78>
      close(1);
    300e:	4505                	li	a0,1
    3010:	00003097          	auipc	ra,0x3
    3014:	e62080e7          	jalr	-414(ra) # 5e72 <close>
      char *args[] = { "echo", "x", 0 };
    3018:	00003517          	auipc	a0,0x3
    301c:	73050513          	addi	a0,a0,1840 # 6748 <uthread_self+0x6e>
    3020:	faa43c23          	sd	a0,-72(s0)
    3024:	00003797          	auipc	a5,0x3
    3028:	79478793          	addi	a5,a5,1940 # 67b8 <uthread_self+0xde>
    302c:	fcf43023          	sd	a5,-64(s0)
    3030:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    3034:	fb840593          	addi	a1,s0,-72
    3038:	00003097          	auipc	ra,0x3
    303c:	e4a080e7          	jalr	-438(ra) # 5e82 <exec>
      exit(0);
    3040:	4501                	li	a0,0
    3042:	00003097          	auipc	ra,0x3
    3046:	e08080e7          	jalr	-504(ra) # 5e4a <exit>

000000000000304a <fourteen>:
{
    304a:	1101                	addi	sp,sp,-32
    304c:	ec06                	sd	ra,24(sp)
    304e:	e822                	sd	s0,16(sp)
    3050:	e426                	sd	s1,8(sp)
    3052:	1000                	addi	s0,sp,32
    3054:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    3056:	00005517          	auipc	a0,0x5
    305a:	8b250513          	addi	a0,a0,-1870 # 7908 <uthread_self+0x122e>
    305e:	00003097          	auipc	ra,0x3
    3062:	e54080e7          	jalr	-428(ra) # 5eb2 <mkdir>
    3066:	e165                	bnez	a0,3146 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    3068:	00004517          	auipc	a0,0x4
    306c:	6f850513          	addi	a0,a0,1784 # 7760 <uthread_self+0x1086>
    3070:	00003097          	auipc	ra,0x3
    3074:	e42080e7          	jalr	-446(ra) # 5eb2 <mkdir>
    3078:	e56d                	bnez	a0,3162 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    307a:	20000593          	li	a1,512
    307e:	00004517          	auipc	a0,0x4
    3082:	73a50513          	addi	a0,a0,1850 # 77b8 <uthread_self+0x10de>
    3086:	00003097          	auipc	ra,0x3
    308a:	e04080e7          	jalr	-508(ra) # 5e8a <open>
  if(fd < 0){
    308e:	0e054863          	bltz	a0,317e <fourteen+0x134>
  close(fd);
    3092:	00003097          	auipc	ra,0x3
    3096:	de0080e7          	jalr	-544(ra) # 5e72 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    309a:	4581                	li	a1,0
    309c:	00004517          	auipc	a0,0x4
    30a0:	79450513          	addi	a0,a0,1940 # 7830 <uthread_self+0x1156>
    30a4:	00003097          	auipc	ra,0x3
    30a8:	de6080e7          	jalr	-538(ra) # 5e8a <open>
  if(fd < 0){
    30ac:	0e054763          	bltz	a0,319a <fourteen+0x150>
  close(fd);
    30b0:	00003097          	auipc	ra,0x3
    30b4:	dc2080e7          	jalr	-574(ra) # 5e72 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    30b8:	00004517          	auipc	a0,0x4
    30bc:	7e850513          	addi	a0,a0,2024 # 78a0 <uthread_self+0x11c6>
    30c0:	00003097          	auipc	ra,0x3
    30c4:	df2080e7          	jalr	-526(ra) # 5eb2 <mkdir>
    30c8:	c57d                	beqz	a0,31b6 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    30ca:	00005517          	auipc	a0,0x5
    30ce:	82e50513          	addi	a0,a0,-2002 # 78f8 <uthread_self+0x121e>
    30d2:	00003097          	auipc	ra,0x3
    30d6:	de0080e7          	jalr	-544(ra) # 5eb2 <mkdir>
    30da:	cd65                	beqz	a0,31d2 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    30dc:	00005517          	auipc	a0,0x5
    30e0:	81c50513          	addi	a0,a0,-2020 # 78f8 <uthread_self+0x121e>
    30e4:	00003097          	auipc	ra,0x3
    30e8:	db6080e7          	jalr	-586(ra) # 5e9a <unlink>
  unlink("12345678901234/12345678901234");
    30ec:	00004517          	auipc	a0,0x4
    30f0:	7b450513          	addi	a0,a0,1972 # 78a0 <uthread_self+0x11c6>
    30f4:	00003097          	auipc	ra,0x3
    30f8:	da6080e7          	jalr	-602(ra) # 5e9a <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    30fc:	00004517          	auipc	a0,0x4
    3100:	73450513          	addi	a0,a0,1844 # 7830 <uthread_self+0x1156>
    3104:	00003097          	auipc	ra,0x3
    3108:	d96080e7          	jalr	-618(ra) # 5e9a <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    310c:	00004517          	auipc	a0,0x4
    3110:	6ac50513          	addi	a0,a0,1708 # 77b8 <uthread_self+0x10de>
    3114:	00003097          	auipc	ra,0x3
    3118:	d86080e7          	jalr	-634(ra) # 5e9a <unlink>
  unlink("12345678901234/123456789012345");
    311c:	00004517          	auipc	a0,0x4
    3120:	64450513          	addi	a0,a0,1604 # 7760 <uthread_self+0x1086>
    3124:	00003097          	auipc	ra,0x3
    3128:	d76080e7          	jalr	-650(ra) # 5e9a <unlink>
  unlink("12345678901234");
    312c:	00004517          	auipc	a0,0x4
    3130:	7dc50513          	addi	a0,a0,2012 # 7908 <uthread_self+0x122e>
    3134:	00003097          	auipc	ra,0x3
    3138:	d66080e7          	jalr	-666(ra) # 5e9a <unlink>
}
    313c:	60e2                	ld	ra,24(sp)
    313e:	6442                	ld	s0,16(sp)
    3140:	64a2                	ld	s1,8(sp)
    3142:	6105                	addi	sp,sp,32
    3144:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    3146:	85a6                	mv	a1,s1
    3148:	00004517          	auipc	a0,0x4
    314c:	5f050513          	addi	a0,a0,1520 # 7738 <uthread_self+0x105e>
    3150:	00003097          	auipc	ra,0x3
    3154:	09a080e7          	jalr	154(ra) # 61ea <printf>
    exit(1);
    3158:	4505                	li	a0,1
    315a:	00003097          	auipc	ra,0x3
    315e:	cf0080e7          	jalr	-784(ra) # 5e4a <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    3162:	85a6                	mv	a1,s1
    3164:	00004517          	auipc	a0,0x4
    3168:	61c50513          	addi	a0,a0,1564 # 7780 <uthread_self+0x10a6>
    316c:	00003097          	auipc	ra,0x3
    3170:	07e080e7          	jalr	126(ra) # 61ea <printf>
    exit(1);
    3174:	4505                	li	a0,1
    3176:	00003097          	auipc	ra,0x3
    317a:	cd4080e7          	jalr	-812(ra) # 5e4a <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    317e:	85a6                	mv	a1,s1
    3180:	00004517          	auipc	a0,0x4
    3184:	66850513          	addi	a0,a0,1640 # 77e8 <uthread_self+0x110e>
    3188:	00003097          	auipc	ra,0x3
    318c:	062080e7          	jalr	98(ra) # 61ea <printf>
    exit(1);
    3190:	4505                	li	a0,1
    3192:	00003097          	auipc	ra,0x3
    3196:	cb8080e7          	jalr	-840(ra) # 5e4a <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    319a:	85a6                	mv	a1,s1
    319c:	00004517          	auipc	a0,0x4
    31a0:	6c450513          	addi	a0,a0,1732 # 7860 <uthread_self+0x1186>
    31a4:	00003097          	auipc	ra,0x3
    31a8:	046080e7          	jalr	70(ra) # 61ea <printf>
    exit(1);
    31ac:	4505                	li	a0,1
    31ae:	00003097          	auipc	ra,0x3
    31b2:	c9c080e7          	jalr	-868(ra) # 5e4a <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    31b6:	85a6                	mv	a1,s1
    31b8:	00004517          	auipc	a0,0x4
    31bc:	70850513          	addi	a0,a0,1800 # 78c0 <uthread_self+0x11e6>
    31c0:	00003097          	auipc	ra,0x3
    31c4:	02a080e7          	jalr	42(ra) # 61ea <printf>
    exit(1);
    31c8:	4505                	li	a0,1
    31ca:	00003097          	auipc	ra,0x3
    31ce:	c80080e7          	jalr	-896(ra) # 5e4a <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    31d2:	85a6                	mv	a1,s1
    31d4:	00004517          	auipc	a0,0x4
    31d8:	74450513          	addi	a0,a0,1860 # 7918 <uthread_self+0x123e>
    31dc:	00003097          	auipc	ra,0x3
    31e0:	00e080e7          	jalr	14(ra) # 61ea <printf>
    exit(1);
    31e4:	4505                	li	a0,1
    31e6:	00003097          	auipc	ra,0x3
    31ea:	c64080e7          	jalr	-924(ra) # 5e4a <exit>

00000000000031ee <diskfull>:
{
    31ee:	b9010113          	addi	sp,sp,-1136
    31f2:	46113423          	sd	ra,1128(sp)
    31f6:	46813023          	sd	s0,1120(sp)
    31fa:	44913c23          	sd	s1,1112(sp)
    31fe:	45213823          	sd	s2,1104(sp)
    3202:	45313423          	sd	s3,1096(sp)
    3206:	45413023          	sd	s4,1088(sp)
    320a:	43513c23          	sd	s5,1080(sp)
    320e:	43613823          	sd	s6,1072(sp)
    3212:	43713423          	sd	s7,1064(sp)
    3216:	43813023          	sd	s8,1056(sp)
    321a:	47010413          	addi	s0,sp,1136
    321e:	8c2a                	mv	s8,a0
  unlink("diskfulldir");
    3220:	00004517          	auipc	a0,0x4
    3224:	73050513          	addi	a0,a0,1840 # 7950 <uthread_self+0x1276>
    3228:	00003097          	auipc	ra,0x3
    322c:	c72080e7          	jalr	-910(ra) # 5e9a <unlink>
  for(fi = 0; done == 0; fi++){
    3230:	4a01                	li	s4,0
    name[0] = 'b';
    3232:	06200b13          	li	s6,98
    name[1] = 'i';
    3236:	06900a93          	li	s5,105
    name[2] = 'g';
    323a:	06700993          	li	s3,103
    323e:	10c00b93          	li	s7,268
    3242:	aabd                	j	33c0 <diskfull+0x1d2>
      printf("%s: could not create file %s\n", s, name);
    3244:	b9040613          	addi	a2,s0,-1136
    3248:	85e2                	mv	a1,s8
    324a:	00004517          	auipc	a0,0x4
    324e:	71650513          	addi	a0,a0,1814 # 7960 <uthread_self+0x1286>
    3252:	00003097          	auipc	ra,0x3
    3256:	f98080e7          	jalr	-104(ra) # 61ea <printf>
      break;
    325a:	a821                	j	3272 <diskfull+0x84>
        close(fd);
    325c:	854a                	mv	a0,s2
    325e:	00003097          	auipc	ra,0x3
    3262:	c14080e7          	jalr	-1004(ra) # 5e72 <close>
    close(fd);
    3266:	854a                	mv	a0,s2
    3268:	00003097          	auipc	ra,0x3
    326c:	c0a080e7          	jalr	-1014(ra) # 5e72 <close>
  for(fi = 0; done == 0; fi++){
    3270:	2a05                	addiw	s4,s4,1
  for(int i = 0; i < nzz; i++){
    3272:	4481                	li	s1,0
    name[0] = 'z';
    3274:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    3278:	08000993          	li	s3,128
    name[0] = 'z';
    327c:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    3280:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    3284:	41f4d79b          	sraiw	a5,s1,0x1f
    3288:	01b7d71b          	srliw	a4,a5,0x1b
    328c:	009707bb          	addw	a5,a4,s1
    3290:	4057d69b          	sraiw	a3,a5,0x5
    3294:	0306869b          	addiw	a3,a3,48
    3298:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    329c:	8bfd                	andi	a5,a5,31
    329e:	9f99                	subw	a5,a5,a4
    32a0:	0307879b          	addiw	a5,a5,48
    32a4:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    32a8:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    32ac:	bb040513          	addi	a0,s0,-1104
    32b0:	00003097          	auipc	ra,0x3
    32b4:	bea080e7          	jalr	-1046(ra) # 5e9a <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    32b8:	60200593          	li	a1,1538
    32bc:	bb040513          	addi	a0,s0,-1104
    32c0:	00003097          	auipc	ra,0x3
    32c4:	bca080e7          	jalr	-1078(ra) # 5e8a <open>
    if(fd < 0)
    32c8:	00054963          	bltz	a0,32da <diskfull+0xec>
    close(fd);
    32cc:	00003097          	auipc	ra,0x3
    32d0:	ba6080e7          	jalr	-1114(ra) # 5e72 <close>
  for(int i = 0; i < nzz; i++){
    32d4:	2485                	addiw	s1,s1,1
    32d6:	fb3493e3          	bne	s1,s3,327c <diskfull+0x8e>
  if(mkdir("diskfulldir") == 0)
    32da:	00004517          	auipc	a0,0x4
    32de:	67650513          	addi	a0,a0,1654 # 7950 <uthread_self+0x1276>
    32e2:	00003097          	auipc	ra,0x3
    32e6:	bd0080e7          	jalr	-1072(ra) # 5eb2 <mkdir>
    32ea:	12050963          	beqz	a0,341c <diskfull+0x22e>
  unlink("diskfulldir");
    32ee:	00004517          	auipc	a0,0x4
    32f2:	66250513          	addi	a0,a0,1634 # 7950 <uthread_self+0x1276>
    32f6:	00003097          	auipc	ra,0x3
    32fa:	ba4080e7          	jalr	-1116(ra) # 5e9a <unlink>
  for(int i = 0; i < nzz; i++){
    32fe:	4481                	li	s1,0
    name[0] = 'z';
    3300:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    3304:	08000993          	li	s3,128
    name[0] = 'z';
    3308:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    330c:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    3310:	41f4d79b          	sraiw	a5,s1,0x1f
    3314:	01b7d71b          	srliw	a4,a5,0x1b
    3318:	009707bb          	addw	a5,a4,s1
    331c:	4057d69b          	sraiw	a3,a5,0x5
    3320:	0306869b          	addiw	a3,a3,48
    3324:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3328:	8bfd                	andi	a5,a5,31
    332a:	9f99                	subw	a5,a5,a4
    332c:	0307879b          	addiw	a5,a5,48
    3330:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3334:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3338:	bb040513          	addi	a0,s0,-1104
    333c:	00003097          	auipc	ra,0x3
    3340:	b5e080e7          	jalr	-1186(ra) # 5e9a <unlink>
  for(int i = 0; i < nzz; i++){
    3344:	2485                	addiw	s1,s1,1
    3346:	fd3491e3          	bne	s1,s3,3308 <diskfull+0x11a>
  for(int i = 0; i < fi; i++){
    334a:	03405e63          	blez	s4,3386 <diskfull+0x198>
    334e:	4481                	li	s1,0
    name[0] = 'b';
    3350:	06200a93          	li	s5,98
    name[1] = 'i';
    3354:	06900993          	li	s3,105
    name[2] = 'g';
    3358:	06700913          	li	s2,103
    name[0] = 'b';
    335c:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
    3360:	bb3408a3          	sb	s3,-1103(s0)
    name[2] = 'g';
    3364:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
    3368:	0304879b          	addiw	a5,s1,48
    336c:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3370:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3374:	bb040513          	addi	a0,s0,-1104
    3378:	00003097          	auipc	ra,0x3
    337c:	b22080e7          	jalr	-1246(ra) # 5e9a <unlink>
  for(int i = 0; i < fi; i++){
    3380:	2485                	addiw	s1,s1,1
    3382:	fd449de3          	bne	s1,s4,335c <diskfull+0x16e>
}
    3386:	46813083          	ld	ra,1128(sp)
    338a:	46013403          	ld	s0,1120(sp)
    338e:	45813483          	ld	s1,1112(sp)
    3392:	45013903          	ld	s2,1104(sp)
    3396:	44813983          	ld	s3,1096(sp)
    339a:	44013a03          	ld	s4,1088(sp)
    339e:	43813a83          	ld	s5,1080(sp)
    33a2:	43013b03          	ld	s6,1072(sp)
    33a6:	42813b83          	ld	s7,1064(sp)
    33aa:	42013c03          	ld	s8,1056(sp)
    33ae:	47010113          	addi	sp,sp,1136
    33b2:	8082                	ret
    close(fd);
    33b4:	854a                	mv	a0,s2
    33b6:	00003097          	auipc	ra,0x3
    33ba:	abc080e7          	jalr	-1348(ra) # 5e72 <close>
  for(fi = 0; done == 0; fi++){
    33be:	2a05                	addiw	s4,s4,1
    name[0] = 'b';
    33c0:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    33c4:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    33c8:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + fi;
    33cc:	030a079b          	addiw	a5,s4,48
    33d0:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    33d4:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    33d8:	b9040513          	addi	a0,s0,-1136
    33dc:	00003097          	auipc	ra,0x3
    33e0:	abe080e7          	jalr	-1346(ra) # 5e9a <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    33e4:	60200593          	li	a1,1538
    33e8:	b9040513          	addi	a0,s0,-1136
    33ec:	00003097          	auipc	ra,0x3
    33f0:	a9e080e7          	jalr	-1378(ra) # 5e8a <open>
    33f4:	892a                	mv	s2,a0
    if(fd < 0){
    33f6:	e40547e3          	bltz	a0,3244 <diskfull+0x56>
    33fa:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    33fc:	40000613          	li	a2,1024
    3400:	bb040593          	addi	a1,s0,-1104
    3404:	854a                	mv	a0,s2
    3406:	00003097          	auipc	ra,0x3
    340a:	a64080e7          	jalr	-1436(ra) # 5e6a <write>
    340e:	40000793          	li	a5,1024
    3412:	e4f515e3          	bne	a0,a5,325c <diskfull+0x6e>
    for(int i = 0; i < MAXFILE; i++){
    3416:	34fd                	addiw	s1,s1,-1
    3418:	f0f5                	bnez	s1,33fc <diskfull+0x20e>
    341a:	bf69                	j	33b4 <diskfull+0x1c6>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    341c:	00004517          	auipc	a0,0x4
    3420:	56450513          	addi	a0,a0,1380 # 7980 <uthread_self+0x12a6>
    3424:	00003097          	auipc	ra,0x3
    3428:	dc6080e7          	jalr	-570(ra) # 61ea <printf>
    342c:	b5c9                	j	32ee <diskfull+0x100>

000000000000342e <iputtest>:
{
    342e:	1101                	addi	sp,sp,-32
    3430:	ec06                	sd	ra,24(sp)
    3432:	e822                	sd	s0,16(sp)
    3434:	e426                	sd	s1,8(sp)
    3436:	1000                	addi	s0,sp,32
    3438:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    343a:	00004517          	auipc	a0,0x4
    343e:	57650513          	addi	a0,a0,1398 # 79b0 <uthread_self+0x12d6>
    3442:	00003097          	auipc	ra,0x3
    3446:	a70080e7          	jalr	-1424(ra) # 5eb2 <mkdir>
    344a:	04054563          	bltz	a0,3494 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    344e:	00004517          	auipc	a0,0x4
    3452:	56250513          	addi	a0,a0,1378 # 79b0 <uthread_self+0x12d6>
    3456:	00003097          	auipc	ra,0x3
    345a:	a64080e7          	jalr	-1436(ra) # 5eba <chdir>
    345e:	04054963          	bltz	a0,34b0 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    3462:	00004517          	auipc	a0,0x4
    3466:	58e50513          	addi	a0,a0,1422 # 79f0 <uthread_self+0x1316>
    346a:	00003097          	auipc	ra,0x3
    346e:	a30080e7          	jalr	-1488(ra) # 5e9a <unlink>
    3472:	04054d63          	bltz	a0,34cc <iputtest+0x9e>
  if(chdir("/") < 0){
    3476:	00004517          	auipc	a0,0x4
    347a:	5aa50513          	addi	a0,a0,1450 # 7a20 <uthread_self+0x1346>
    347e:	00003097          	auipc	ra,0x3
    3482:	a3c080e7          	jalr	-1476(ra) # 5eba <chdir>
    3486:	06054163          	bltz	a0,34e8 <iputtest+0xba>
}
    348a:	60e2                	ld	ra,24(sp)
    348c:	6442                	ld	s0,16(sp)
    348e:	64a2                	ld	s1,8(sp)
    3490:	6105                	addi	sp,sp,32
    3492:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3494:	85a6                	mv	a1,s1
    3496:	00004517          	auipc	a0,0x4
    349a:	52250513          	addi	a0,a0,1314 # 79b8 <uthread_self+0x12de>
    349e:	00003097          	auipc	ra,0x3
    34a2:	d4c080e7          	jalr	-692(ra) # 61ea <printf>
    exit(1);
    34a6:	4505                	li	a0,1
    34a8:	00003097          	auipc	ra,0x3
    34ac:	9a2080e7          	jalr	-1630(ra) # 5e4a <exit>
    printf("%s: chdir iputdir failed\n", s);
    34b0:	85a6                	mv	a1,s1
    34b2:	00004517          	auipc	a0,0x4
    34b6:	51e50513          	addi	a0,a0,1310 # 79d0 <uthread_self+0x12f6>
    34ba:	00003097          	auipc	ra,0x3
    34be:	d30080e7          	jalr	-720(ra) # 61ea <printf>
    exit(1);
    34c2:	4505                	li	a0,1
    34c4:	00003097          	auipc	ra,0x3
    34c8:	986080e7          	jalr	-1658(ra) # 5e4a <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    34cc:	85a6                	mv	a1,s1
    34ce:	00004517          	auipc	a0,0x4
    34d2:	53250513          	addi	a0,a0,1330 # 7a00 <uthread_self+0x1326>
    34d6:	00003097          	auipc	ra,0x3
    34da:	d14080e7          	jalr	-748(ra) # 61ea <printf>
    exit(1);
    34de:	4505                	li	a0,1
    34e0:	00003097          	auipc	ra,0x3
    34e4:	96a080e7          	jalr	-1686(ra) # 5e4a <exit>
    printf("%s: chdir / failed\n", s);
    34e8:	85a6                	mv	a1,s1
    34ea:	00004517          	auipc	a0,0x4
    34ee:	53e50513          	addi	a0,a0,1342 # 7a28 <uthread_self+0x134e>
    34f2:	00003097          	auipc	ra,0x3
    34f6:	cf8080e7          	jalr	-776(ra) # 61ea <printf>
    exit(1);
    34fa:	4505                	li	a0,1
    34fc:	00003097          	auipc	ra,0x3
    3500:	94e080e7          	jalr	-1714(ra) # 5e4a <exit>

0000000000003504 <exitiputtest>:
{
    3504:	7179                	addi	sp,sp,-48
    3506:	f406                	sd	ra,40(sp)
    3508:	f022                	sd	s0,32(sp)
    350a:	ec26                	sd	s1,24(sp)
    350c:	1800                	addi	s0,sp,48
    350e:	84aa                	mv	s1,a0
  pid = fork();
    3510:	00003097          	auipc	ra,0x3
    3514:	932080e7          	jalr	-1742(ra) # 5e42 <fork>
  if(pid < 0){
    3518:	04054663          	bltz	a0,3564 <exitiputtest+0x60>
  if(pid == 0){
    351c:	ed45                	bnez	a0,35d4 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    351e:	00004517          	auipc	a0,0x4
    3522:	49250513          	addi	a0,a0,1170 # 79b0 <uthread_self+0x12d6>
    3526:	00003097          	auipc	ra,0x3
    352a:	98c080e7          	jalr	-1652(ra) # 5eb2 <mkdir>
    352e:	04054963          	bltz	a0,3580 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    3532:	00004517          	auipc	a0,0x4
    3536:	47e50513          	addi	a0,a0,1150 # 79b0 <uthread_self+0x12d6>
    353a:	00003097          	auipc	ra,0x3
    353e:	980080e7          	jalr	-1664(ra) # 5eba <chdir>
    3542:	04054d63          	bltz	a0,359c <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    3546:	00004517          	auipc	a0,0x4
    354a:	4aa50513          	addi	a0,a0,1194 # 79f0 <uthread_self+0x1316>
    354e:	00003097          	auipc	ra,0x3
    3552:	94c080e7          	jalr	-1716(ra) # 5e9a <unlink>
    3556:	06054163          	bltz	a0,35b8 <exitiputtest+0xb4>
    exit(0);
    355a:	4501                	li	a0,0
    355c:	00003097          	auipc	ra,0x3
    3560:	8ee080e7          	jalr	-1810(ra) # 5e4a <exit>
    printf("%s: fork failed\n", s);
    3564:	85a6                	mv	a1,s1
    3566:	00004517          	auipc	a0,0x4
    356a:	a8a50513          	addi	a0,a0,-1398 # 6ff0 <uthread_self+0x916>
    356e:	00003097          	auipc	ra,0x3
    3572:	c7c080e7          	jalr	-900(ra) # 61ea <printf>
    exit(1);
    3576:	4505                	li	a0,1
    3578:	00003097          	auipc	ra,0x3
    357c:	8d2080e7          	jalr	-1838(ra) # 5e4a <exit>
      printf("%s: mkdir failed\n", s);
    3580:	85a6                	mv	a1,s1
    3582:	00004517          	auipc	a0,0x4
    3586:	43650513          	addi	a0,a0,1078 # 79b8 <uthread_self+0x12de>
    358a:	00003097          	auipc	ra,0x3
    358e:	c60080e7          	jalr	-928(ra) # 61ea <printf>
      exit(1);
    3592:	4505                	li	a0,1
    3594:	00003097          	auipc	ra,0x3
    3598:	8b6080e7          	jalr	-1866(ra) # 5e4a <exit>
      printf("%s: child chdir failed\n", s);
    359c:	85a6                	mv	a1,s1
    359e:	00004517          	auipc	a0,0x4
    35a2:	4a250513          	addi	a0,a0,1186 # 7a40 <uthread_self+0x1366>
    35a6:	00003097          	auipc	ra,0x3
    35aa:	c44080e7          	jalr	-956(ra) # 61ea <printf>
      exit(1);
    35ae:	4505                	li	a0,1
    35b0:	00003097          	auipc	ra,0x3
    35b4:	89a080e7          	jalr	-1894(ra) # 5e4a <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    35b8:	85a6                	mv	a1,s1
    35ba:	00004517          	auipc	a0,0x4
    35be:	44650513          	addi	a0,a0,1094 # 7a00 <uthread_self+0x1326>
    35c2:	00003097          	auipc	ra,0x3
    35c6:	c28080e7          	jalr	-984(ra) # 61ea <printf>
      exit(1);
    35ca:	4505                	li	a0,1
    35cc:	00003097          	auipc	ra,0x3
    35d0:	87e080e7          	jalr	-1922(ra) # 5e4a <exit>
  wait(&xstatus);
    35d4:	fdc40513          	addi	a0,s0,-36
    35d8:	00003097          	auipc	ra,0x3
    35dc:	87a080e7          	jalr	-1926(ra) # 5e52 <wait>
  exit(xstatus);
    35e0:	fdc42503          	lw	a0,-36(s0)
    35e4:	00003097          	auipc	ra,0x3
    35e8:	866080e7          	jalr	-1946(ra) # 5e4a <exit>

00000000000035ec <dirtest>:
{
    35ec:	1101                	addi	sp,sp,-32
    35ee:	ec06                	sd	ra,24(sp)
    35f0:	e822                	sd	s0,16(sp)
    35f2:	e426                	sd	s1,8(sp)
    35f4:	1000                	addi	s0,sp,32
    35f6:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    35f8:	00004517          	auipc	a0,0x4
    35fc:	46050513          	addi	a0,a0,1120 # 7a58 <uthread_self+0x137e>
    3600:	00003097          	auipc	ra,0x3
    3604:	8b2080e7          	jalr	-1870(ra) # 5eb2 <mkdir>
    3608:	04054563          	bltz	a0,3652 <dirtest+0x66>
  if(chdir("dir0") < 0){
    360c:	00004517          	auipc	a0,0x4
    3610:	44c50513          	addi	a0,a0,1100 # 7a58 <uthread_self+0x137e>
    3614:	00003097          	auipc	ra,0x3
    3618:	8a6080e7          	jalr	-1882(ra) # 5eba <chdir>
    361c:	04054963          	bltz	a0,366e <dirtest+0x82>
  if(chdir("..") < 0){
    3620:	00004517          	auipc	a0,0x4
    3624:	45850513          	addi	a0,a0,1112 # 7a78 <uthread_self+0x139e>
    3628:	00003097          	auipc	ra,0x3
    362c:	892080e7          	jalr	-1902(ra) # 5eba <chdir>
    3630:	04054d63          	bltz	a0,368a <dirtest+0x9e>
  if(unlink("dir0") < 0){
    3634:	00004517          	auipc	a0,0x4
    3638:	42450513          	addi	a0,a0,1060 # 7a58 <uthread_self+0x137e>
    363c:	00003097          	auipc	ra,0x3
    3640:	85e080e7          	jalr	-1954(ra) # 5e9a <unlink>
    3644:	06054163          	bltz	a0,36a6 <dirtest+0xba>
}
    3648:	60e2                	ld	ra,24(sp)
    364a:	6442                	ld	s0,16(sp)
    364c:	64a2                	ld	s1,8(sp)
    364e:	6105                	addi	sp,sp,32
    3650:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3652:	85a6                	mv	a1,s1
    3654:	00004517          	auipc	a0,0x4
    3658:	36450513          	addi	a0,a0,868 # 79b8 <uthread_self+0x12de>
    365c:	00003097          	auipc	ra,0x3
    3660:	b8e080e7          	jalr	-1138(ra) # 61ea <printf>
    exit(1);
    3664:	4505                	li	a0,1
    3666:	00002097          	auipc	ra,0x2
    366a:	7e4080e7          	jalr	2020(ra) # 5e4a <exit>
    printf("%s: chdir dir0 failed\n", s);
    366e:	85a6                	mv	a1,s1
    3670:	00004517          	auipc	a0,0x4
    3674:	3f050513          	addi	a0,a0,1008 # 7a60 <uthread_self+0x1386>
    3678:	00003097          	auipc	ra,0x3
    367c:	b72080e7          	jalr	-1166(ra) # 61ea <printf>
    exit(1);
    3680:	4505                	li	a0,1
    3682:	00002097          	auipc	ra,0x2
    3686:	7c8080e7          	jalr	1992(ra) # 5e4a <exit>
    printf("%s: chdir .. failed\n", s);
    368a:	85a6                	mv	a1,s1
    368c:	00004517          	auipc	a0,0x4
    3690:	3f450513          	addi	a0,a0,1012 # 7a80 <uthread_self+0x13a6>
    3694:	00003097          	auipc	ra,0x3
    3698:	b56080e7          	jalr	-1194(ra) # 61ea <printf>
    exit(1);
    369c:	4505                	li	a0,1
    369e:	00002097          	auipc	ra,0x2
    36a2:	7ac080e7          	jalr	1964(ra) # 5e4a <exit>
    printf("%s: unlink dir0 failed\n", s);
    36a6:	85a6                	mv	a1,s1
    36a8:	00004517          	auipc	a0,0x4
    36ac:	3f050513          	addi	a0,a0,1008 # 7a98 <uthread_self+0x13be>
    36b0:	00003097          	auipc	ra,0x3
    36b4:	b3a080e7          	jalr	-1222(ra) # 61ea <printf>
    exit(1);
    36b8:	4505                	li	a0,1
    36ba:	00002097          	auipc	ra,0x2
    36be:	790080e7          	jalr	1936(ra) # 5e4a <exit>

00000000000036c2 <subdir>:
{
    36c2:	1101                	addi	sp,sp,-32
    36c4:	ec06                	sd	ra,24(sp)
    36c6:	e822                	sd	s0,16(sp)
    36c8:	e426                	sd	s1,8(sp)
    36ca:	e04a                	sd	s2,0(sp)
    36cc:	1000                	addi	s0,sp,32
    36ce:	892a                	mv	s2,a0
  unlink("ff");
    36d0:	00004517          	auipc	a0,0x4
    36d4:	51050513          	addi	a0,a0,1296 # 7be0 <uthread_self+0x1506>
    36d8:	00002097          	auipc	ra,0x2
    36dc:	7c2080e7          	jalr	1986(ra) # 5e9a <unlink>
  if(mkdir("dd") != 0){
    36e0:	00004517          	auipc	a0,0x4
    36e4:	3d050513          	addi	a0,a0,976 # 7ab0 <uthread_self+0x13d6>
    36e8:	00002097          	auipc	ra,0x2
    36ec:	7ca080e7          	jalr	1994(ra) # 5eb2 <mkdir>
    36f0:	38051663          	bnez	a0,3a7c <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    36f4:	20200593          	li	a1,514
    36f8:	00004517          	auipc	a0,0x4
    36fc:	3d850513          	addi	a0,a0,984 # 7ad0 <uthread_self+0x13f6>
    3700:	00002097          	auipc	ra,0x2
    3704:	78a080e7          	jalr	1930(ra) # 5e8a <open>
    3708:	84aa                	mv	s1,a0
  if(fd < 0){
    370a:	38054763          	bltz	a0,3a98 <subdir+0x3d6>
  write(fd, "ff", 2);
    370e:	4609                	li	a2,2
    3710:	00004597          	auipc	a1,0x4
    3714:	4d058593          	addi	a1,a1,1232 # 7be0 <uthread_self+0x1506>
    3718:	00002097          	auipc	ra,0x2
    371c:	752080e7          	jalr	1874(ra) # 5e6a <write>
  close(fd);
    3720:	8526                	mv	a0,s1
    3722:	00002097          	auipc	ra,0x2
    3726:	750080e7          	jalr	1872(ra) # 5e72 <close>
  if(unlink("dd") >= 0){
    372a:	00004517          	auipc	a0,0x4
    372e:	38650513          	addi	a0,a0,902 # 7ab0 <uthread_self+0x13d6>
    3732:	00002097          	auipc	ra,0x2
    3736:	768080e7          	jalr	1896(ra) # 5e9a <unlink>
    373a:	36055d63          	bgez	a0,3ab4 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    373e:	00004517          	auipc	a0,0x4
    3742:	3ea50513          	addi	a0,a0,1002 # 7b28 <uthread_self+0x144e>
    3746:	00002097          	auipc	ra,0x2
    374a:	76c080e7          	jalr	1900(ra) # 5eb2 <mkdir>
    374e:	38051163          	bnez	a0,3ad0 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    3752:	20200593          	li	a1,514
    3756:	00004517          	auipc	a0,0x4
    375a:	3fa50513          	addi	a0,a0,1018 # 7b50 <uthread_self+0x1476>
    375e:	00002097          	auipc	ra,0x2
    3762:	72c080e7          	jalr	1836(ra) # 5e8a <open>
    3766:	84aa                	mv	s1,a0
  if(fd < 0){
    3768:	38054263          	bltz	a0,3aec <subdir+0x42a>
  write(fd, "FF", 2);
    376c:	4609                	li	a2,2
    376e:	00004597          	auipc	a1,0x4
    3772:	41258593          	addi	a1,a1,1042 # 7b80 <uthread_self+0x14a6>
    3776:	00002097          	auipc	ra,0x2
    377a:	6f4080e7          	jalr	1780(ra) # 5e6a <write>
  close(fd);
    377e:	8526                	mv	a0,s1
    3780:	00002097          	auipc	ra,0x2
    3784:	6f2080e7          	jalr	1778(ra) # 5e72 <close>
  fd = open("dd/dd/../ff", 0);
    3788:	4581                	li	a1,0
    378a:	00004517          	auipc	a0,0x4
    378e:	3fe50513          	addi	a0,a0,1022 # 7b88 <uthread_self+0x14ae>
    3792:	00002097          	auipc	ra,0x2
    3796:	6f8080e7          	jalr	1784(ra) # 5e8a <open>
    379a:	84aa                	mv	s1,a0
  if(fd < 0){
    379c:	36054663          	bltz	a0,3b08 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    37a0:	660d                	lui	a2,0x3
    37a2:	00009597          	auipc	a1,0x9
    37a6:	50658593          	addi	a1,a1,1286 # cca8 <buf>
    37aa:	00002097          	auipc	ra,0x2
    37ae:	6b8080e7          	jalr	1720(ra) # 5e62 <read>
  if(cc != 2 || buf[0] != 'f'){
    37b2:	4789                	li	a5,2
    37b4:	36f51863          	bne	a0,a5,3b24 <subdir+0x462>
    37b8:	00009717          	auipc	a4,0x9
    37bc:	4f074703          	lbu	a4,1264(a4) # cca8 <buf>
    37c0:	06600793          	li	a5,102
    37c4:	36f71063          	bne	a4,a5,3b24 <subdir+0x462>
  close(fd);
    37c8:	8526                	mv	a0,s1
    37ca:	00002097          	auipc	ra,0x2
    37ce:	6a8080e7          	jalr	1704(ra) # 5e72 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    37d2:	00004597          	auipc	a1,0x4
    37d6:	40658593          	addi	a1,a1,1030 # 7bd8 <uthread_self+0x14fe>
    37da:	00004517          	auipc	a0,0x4
    37de:	37650513          	addi	a0,a0,886 # 7b50 <uthread_self+0x1476>
    37e2:	00002097          	auipc	ra,0x2
    37e6:	6c8080e7          	jalr	1736(ra) # 5eaa <link>
    37ea:	34051b63          	bnez	a0,3b40 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    37ee:	00004517          	auipc	a0,0x4
    37f2:	36250513          	addi	a0,a0,866 # 7b50 <uthread_self+0x1476>
    37f6:	00002097          	auipc	ra,0x2
    37fa:	6a4080e7          	jalr	1700(ra) # 5e9a <unlink>
    37fe:	34051f63          	bnez	a0,3b5c <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3802:	4581                	li	a1,0
    3804:	00004517          	auipc	a0,0x4
    3808:	34c50513          	addi	a0,a0,844 # 7b50 <uthread_self+0x1476>
    380c:	00002097          	auipc	ra,0x2
    3810:	67e080e7          	jalr	1662(ra) # 5e8a <open>
    3814:	36055263          	bgez	a0,3b78 <subdir+0x4b6>
  if(chdir("dd") != 0){
    3818:	00004517          	auipc	a0,0x4
    381c:	29850513          	addi	a0,a0,664 # 7ab0 <uthread_self+0x13d6>
    3820:	00002097          	auipc	ra,0x2
    3824:	69a080e7          	jalr	1690(ra) # 5eba <chdir>
    3828:	36051663          	bnez	a0,3b94 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    382c:	00004517          	auipc	a0,0x4
    3830:	44450513          	addi	a0,a0,1092 # 7c70 <uthread_self+0x1596>
    3834:	00002097          	auipc	ra,0x2
    3838:	686080e7          	jalr	1670(ra) # 5eba <chdir>
    383c:	36051a63          	bnez	a0,3bb0 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    3840:	00004517          	auipc	a0,0x4
    3844:	46050513          	addi	a0,a0,1120 # 7ca0 <uthread_self+0x15c6>
    3848:	00002097          	auipc	ra,0x2
    384c:	672080e7          	jalr	1650(ra) # 5eba <chdir>
    3850:	36051e63          	bnez	a0,3bcc <subdir+0x50a>
  if(chdir("./..") != 0){
    3854:	00004517          	auipc	a0,0x4
    3858:	47c50513          	addi	a0,a0,1148 # 7cd0 <uthread_self+0x15f6>
    385c:	00002097          	auipc	ra,0x2
    3860:	65e080e7          	jalr	1630(ra) # 5eba <chdir>
    3864:	38051263          	bnez	a0,3be8 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    3868:	4581                	li	a1,0
    386a:	00004517          	auipc	a0,0x4
    386e:	36e50513          	addi	a0,a0,878 # 7bd8 <uthread_self+0x14fe>
    3872:	00002097          	auipc	ra,0x2
    3876:	618080e7          	jalr	1560(ra) # 5e8a <open>
    387a:	84aa                	mv	s1,a0
  if(fd < 0){
    387c:	38054463          	bltz	a0,3c04 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3880:	660d                	lui	a2,0x3
    3882:	00009597          	auipc	a1,0x9
    3886:	42658593          	addi	a1,a1,1062 # cca8 <buf>
    388a:	00002097          	auipc	ra,0x2
    388e:	5d8080e7          	jalr	1496(ra) # 5e62 <read>
    3892:	4789                	li	a5,2
    3894:	38f51663          	bne	a0,a5,3c20 <subdir+0x55e>
  close(fd);
    3898:	8526                	mv	a0,s1
    389a:	00002097          	auipc	ra,0x2
    389e:	5d8080e7          	jalr	1496(ra) # 5e72 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    38a2:	4581                	li	a1,0
    38a4:	00004517          	auipc	a0,0x4
    38a8:	2ac50513          	addi	a0,a0,684 # 7b50 <uthread_self+0x1476>
    38ac:	00002097          	auipc	ra,0x2
    38b0:	5de080e7          	jalr	1502(ra) # 5e8a <open>
    38b4:	38055463          	bgez	a0,3c3c <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    38b8:	20200593          	li	a1,514
    38bc:	00004517          	auipc	a0,0x4
    38c0:	4a450513          	addi	a0,a0,1188 # 7d60 <uthread_self+0x1686>
    38c4:	00002097          	auipc	ra,0x2
    38c8:	5c6080e7          	jalr	1478(ra) # 5e8a <open>
    38cc:	38055663          	bgez	a0,3c58 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    38d0:	20200593          	li	a1,514
    38d4:	00004517          	auipc	a0,0x4
    38d8:	4bc50513          	addi	a0,a0,1212 # 7d90 <uthread_self+0x16b6>
    38dc:	00002097          	auipc	ra,0x2
    38e0:	5ae080e7          	jalr	1454(ra) # 5e8a <open>
    38e4:	38055863          	bgez	a0,3c74 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    38e8:	20000593          	li	a1,512
    38ec:	00004517          	auipc	a0,0x4
    38f0:	1c450513          	addi	a0,a0,452 # 7ab0 <uthread_self+0x13d6>
    38f4:	00002097          	auipc	ra,0x2
    38f8:	596080e7          	jalr	1430(ra) # 5e8a <open>
    38fc:	38055a63          	bgez	a0,3c90 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3900:	4589                	li	a1,2
    3902:	00004517          	auipc	a0,0x4
    3906:	1ae50513          	addi	a0,a0,430 # 7ab0 <uthread_self+0x13d6>
    390a:	00002097          	auipc	ra,0x2
    390e:	580080e7          	jalr	1408(ra) # 5e8a <open>
    3912:	38055d63          	bgez	a0,3cac <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3916:	4585                	li	a1,1
    3918:	00004517          	auipc	a0,0x4
    391c:	19850513          	addi	a0,a0,408 # 7ab0 <uthread_self+0x13d6>
    3920:	00002097          	auipc	ra,0x2
    3924:	56a080e7          	jalr	1386(ra) # 5e8a <open>
    3928:	3a055063          	bgez	a0,3cc8 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    392c:	00004597          	auipc	a1,0x4
    3930:	4f458593          	addi	a1,a1,1268 # 7e20 <uthread_self+0x1746>
    3934:	00004517          	auipc	a0,0x4
    3938:	42c50513          	addi	a0,a0,1068 # 7d60 <uthread_self+0x1686>
    393c:	00002097          	auipc	ra,0x2
    3940:	56e080e7          	jalr	1390(ra) # 5eaa <link>
    3944:	3a050063          	beqz	a0,3ce4 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3948:	00004597          	auipc	a1,0x4
    394c:	4d858593          	addi	a1,a1,1240 # 7e20 <uthread_self+0x1746>
    3950:	00004517          	auipc	a0,0x4
    3954:	44050513          	addi	a0,a0,1088 # 7d90 <uthread_self+0x16b6>
    3958:	00002097          	auipc	ra,0x2
    395c:	552080e7          	jalr	1362(ra) # 5eaa <link>
    3960:	3a050063          	beqz	a0,3d00 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3964:	00004597          	auipc	a1,0x4
    3968:	27458593          	addi	a1,a1,628 # 7bd8 <uthread_self+0x14fe>
    396c:	00004517          	auipc	a0,0x4
    3970:	16450513          	addi	a0,a0,356 # 7ad0 <uthread_self+0x13f6>
    3974:	00002097          	auipc	ra,0x2
    3978:	536080e7          	jalr	1334(ra) # 5eaa <link>
    397c:	3a050063          	beqz	a0,3d1c <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3980:	00004517          	auipc	a0,0x4
    3984:	3e050513          	addi	a0,a0,992 # 7d60 <uthread_self+0x1686>
    3988:	00002097          	auipc	ra,0x2
    398c:	52a080e7          	jalr	1322(ra) # 5eb2 <mkdir>
    3990:	3a050463          	beqz	a0,3d38 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3994:	00004517          	auipc	a0,0x4
    3998:	3fc50513          	addi	a0,a0,1020 # 7d90 <uthread_self+0x16b6>
    399c:	00002097          	auipc	ra,0x2
    39a0:	516080e7          	jalr	1302(ra) # 5eb2 <mkdir>
    39a4:	3a050863          	beqz	a0,3d54 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    39a8:	00004517          	auipc	a0,0x4
    39ac:	23050513          	addi	a0,a0,560 # 7bd8 <uthread_self+0x14fe>
    39b0:	00002097          	auipc	ra,0x2
    39b4:	502080e7          	jalr	1282(ra) # 5eb2 <mkdir>
    39b8:	3a050c63          	beqz	a0,3d70 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    39bc:	00004517          	auipc	a0,0x4
    39c0:	3d450513          	addi	a0,a0,980 # 7d90 <uthread_self+0x16b6>
    39c4:	00002097          	auipc	ra,0x2
    39c8:	4d6080e7          	jalr	1238(ra) # 5e9a <unlink>
    39cc:	3c050063          	beqz	a0,3d8c <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    39d0:	00004517          	auipc	a0,0x4
    39d4:	39050513          	addi	a0,a0,912 # 7d60 <uthread_self+0x1686>
    39d8:	00002097          	auipc	ra,0x2
    39dc:	4c2080e7          	jalr	1218(ra) # 5e9a <unlink>
    39e0:	3c050463          	beqz	a0,3da8 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    39e4:	00004517          	auipc	a0,0x4
    39e8:	0ec50513          	addi	a0,a0,236 # 7ad0 <uthread_self+0x13f6>
    39ec:	00002097          	auipc	ra,0x2
    39f0:	4ce080e7          	jalr	1230(ra) # 5eba <chdir>
    39f4:	3c050863          	beqz	a0,3dc4 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    39f8:	00004517          	auipc	a0,0x4
    39fc:	57850513          	addi	a0,a0,1400 # 7f70 <uthread_self+0x1896>
    3a00:	00002097          	auipc	ra,0x2
    3a04:	4ba080e7          	jalr	1210(ra) # 5eba <chdir>
    3a08:	3c050c63          	beqz	a0,3de0 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3a0c:	00004517          	auipc	a0,0x4
    3a10:	1cc50513          	addi	a0,a0,460 # 7bd8 <uthread_self+0x14fe>
    3a14:	00002097          	auipc	ra,0x2
    3a18:	486080e7          	jalr	1158(ra) # 5e9a <unlink>
    3a1c:	3e051063          	bnez	a0,3dfc <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    3a20:	00004517          	auipc	a0,0x4
    3a24:	0b050513          	addi	a0,a0,176 # 7ad0 <uthread_self+0x13f6>
    3a28:	00002097          	auipc	ra,0x2
    3a2c:	472080e7          	jalr	1138(ra) # 5e9a <unlink>
    3a30:	3e051463          	bnez	a0,3e18 <subdir+0x756>
  if(unlink("dd") == 0){
    3a34:	00004517          	auipc	a0,0x4
    3a38:	07c50513          	addi	a0,a0,124 # 7ab0 <uthread_self+0x13d6>
    3a3c:	00002097          	auipc	ra,0x2
    3a40:	45e080e7          	jalr	1118(ra) # 5e9a <unlink>
    3a44:	3e050863          	beqz	a0,3e34 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3a48:	00004517          	auipc	a0,0x4
    3a4c:	59850513          	addi	a0,a0,1432 # 7fe0 <uthread_self+0x1906>
    3a50:	00002097          	auipc	ra,0x2
    3a54:	44a080e7          	jalr	1098(ra) # 5e9a <unlink>
    3a58:	3e054c63          	bltz	a0,3e50 <subdir+0x78e>
  if(unlink("dd") < 0){
    3a5c:	00004517          	auipc	a0,0x4
    3a60:	05450513          	addi	a0,a0,84 # 7ab0 <uthread_self+0x13d6>
    3a64:	00002097          	auipc	ra,0x2
    3a68:	436080e7          	jalr	1078(ra) # 5e9a <unlink>
    3a6c:	40054063          	bltz	a0,3e6c <subdir+0x7aa>
}
    3a70:	60e2                	ld	ra,24(sp)
    3a72:	6442                	ld	s0,16(sp)
    3a74:	64a2                	ld	s1,8(sp)
    3a76:	6902                	ld	s2,0(sp)
    3a78:	6105                	addi	sp,sp,32
    3a7a:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3a7c:	85ca                	mv	a1,s2
    3a7e:	00004517          	auipc	a0,0x4
    3a82:	03a50513          	addi	a0,a0,58 # 7ab8 <uthread_self+0x13de>
    3a86:	00002097          	auipc	ra,0x2
    3a8a:	764080e7          	jalr	1892(ra) # 61ea <printf>
    exit(1);
    3a8e:	4505                	li	a0,1
    3a90:	00002097          	auipc	ra,0x2
    3a94:	3ba080e7          	jalr	954(ra) # 5e4a <exit>
    printf("%s: create dd/ff failed\n", s);
    3a98:	85ca                	mv	a1,s2
    3a9a:	00004517          	auipc	a0,0x4
    3a9e:	03e50513          	addi	a0,a0,62 # 7ad8 <uthread_self+0x13fe>
    3aa2:	00002097          	auipc	ra,0x2
    3aa6:	748080e7          	jalr	1864(ra) # 61ea <printf>
    exit(1);
    3aaa:	4505                	li	a0,1
    3aac:	00002097          	auipc	ra,0x2
    3ab0:	39e080e7          	jalr	926(ra) # 5e4a <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3ab4:	85ca                	mv	a1,s2
    3ab6:	00004517          	auipc	a0,0x4
    3aba:	04250513          	addi	a0,a0,66 # 7af8 <uthread_self+0x141e>
    3abe:	00002097          	auipc	ra,0x2
    3ac2:	72c080e7          	jalr	1836(ra) # 61ea <printf>
    exit(1);
    3ac6:	4505                	li	a0,1
    3ac8:	00002097          	auipc	ra,0x2
    3acc:	382080e7          	jalr	898(ra) # 5e4a <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3ad0:	85ca                	mv	a1,s2
    3ad2:	00004517          	auipc	a0,0x4
    3ad6:	05e50513          	addi	a0,a0,94 # 7b30 <uthread_self+0x1456>
    3ada:	00002097          	auipc	ra,0x2
    3ade:	710080e7          	jalr	1808(ra) # 61ea <printf>
    exit(1);
    3ae2:	4505                	li	a0,1
    3ae4:	00002097          	auipc	ra,0x2
    3ae8:	366080e7          	jalr	870(ra) # 5e4a <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3aec:	85ca                	mv	a1,s2
    3aee:	00004517          	auipc	a0,0x4
    3af2:	07250513          	addi	a0,a0,114 # 7b60 <uthread_self+0x1486>
    3af6:	00002097          	auipc	ra,0x2
    3afa:	6f4080e7          	jalr	1780(ra) # 61ea <printf>
    exit(1);
    3afe:	4505                	li	a0,1
    3b00:	00002097          	auipc	ra,0x2
    3b04:	34a080e7          	jalr	842(ra) # 5e4a <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3b08:	85ca                	mv	a1,s2
    3b0a:	00004517          	auipc	a0,0x4
    3b0e:	08e50513          	addi	a0,a0,142 # 7b98 <uthread_self+0x14be>
    3b12:	00002097          	auipc	ra,0x2
    3b16:	6d8080e7          	jalr	1752(ra) # 61ea <printf>
    exit(1);
    3b1a:	4505                	li	a0,1
    3b1c:	00002097          	auipc	ra,0x2
    3b20:	32e080e7          	jalr	814(ra) # 5e4a <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3b24:	85ca                	mv	a1,s2
    3b26:	00004517          	auipc	a0,0x4
    3b2a:	09250513          	addi	a0,a0,146 # 7bb8 <uthread_self+0x14de>
    3b2e:	00002097          	auipc	ra,0x2
    3b32:	6bc080e7          	jalr	1724(ra) # 61ea <printf>
    exit(1);
    3b36:	4505                	li	a0,1
    3b38:	00002097          	auipc	ra,0x2
    3b3c:	312080e7          	jalr	786(ra) # 5e4a <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3b40:	85ca                	mv	a1,s2
    3b42:	00004517          	auipc	a0,0x4
    3b46:	0a650513          	addi	a0,a0,166 # 7be8 <uthread_self+0x150e>
    3b4a:	00002097          	auipc	ra,0x2
    3b4e:	6a0080e7          	jalr	1696(ra) # 61ea <printf>
    exit(1);
    3b52:	4505                	li	a0,1
    3b54:	00002097          	auipc	ra,0x2
    3b58:	2f6080e7          	jalr	758(ra) # 5e4a <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3b5c:	85ca                	mv	a1,s2
    3b5e:	00004517          	auipc	a0,0x4
    3b62:	0b250513          	addi	a0,a0,178 # 7c10 <uthread_self+0x1536>
    3b66:	00002097          	auipc	ra,0x2
    3b6a:	684080e7          	jalr	1668(ra) # 61ea <printf>
    exit(1);
    3b6e:	4505                	li	a0,1
    3b70:	00002097          	auipc	ra,0x2
    3b74:	2da080e7          	jalr	730(ra) # 5e4a <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3b78:	85ca                	mv	a1,s2
    3b7a:	00004517          	auipc	a0,0x4
    3b7e:	0b650513          	addi	a0,a0,182 # 7c30 <uthread_self+0x1556>
    3b82:	00002097          	auipc	ra,0x2
    3b86:	668080e7          	jalr	1640(ra) # 61ea <printf>
    exit(1);
    3b8a:	4505                	li	a0,1
    3b8c:	00002097          	auipc	ra,0x2
    3b90:	2be080e7          	jalr	702(ra) # 5e4a <exit>
    printf("%s: chdir dd failed\n", s);
    3b94:	85ca                	mv	a1,s2
    3b96:	00004517          	auipc	a0,0x4
    3b9a:	0c250513          	addi	a0,a0,194 # 7c58 <uthread_self+0x157e>
    3b9e:	00002097          	auipc	ra,0x2
    3ba2:	64c080e7          	jalr	1612(ra) # 61ea <printf>
    exit(1);
    3ba6:	4505                	li	a0,1
    3ba8:	00002097          	auipc	ra,0x2
    3bac:	2a2080e7          	jalr	674(ra) # 5e4a <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3bb0:	85ca                	mv	a1,s2
    3bb2:	00004517          	auipc	a0,0x4
    3bb6:	0ce50513          	addi	a0,a0,206 # 7c80 <uthread_self+0x15a6>
    3bba:	00002097          	auipc	ra,0x2
    3bbe:	630080e7          	jalr	1584(ra) # 61ea <printf>
    exit(1);
    3bc2:	4505                	li	a0,1
    3bc4:	00002097          	auipc	ra,0x2
    3bc8:	286080e7          	jalr	646(ra) # 5e4a <exit>
    printf("chdir dd/../../dd failed\n", s);
    3bcc:	85ca                	mv	a1,s2
    3bce:	00004517          	auipc	a0,0x4
    3bd2:	0e250513          	addi	a0,a0,226 # 7cb0 <uthread_self+0x15d6>
    3bd6:	00002097          	auipc	ra,0x2
    3bda:	614080e7          	jalr	1556(ra) # 61ea <printf>
    exit(1);
    3bde:	4505                	li	a0,1
    3be0:	00002097          	auipc	ra,0x2
    3be4:	26a080e7          	jalr	618(ra) # 5e4a <exit>
    printf("%s: chdir ./.. failed\n", s);
    3be8:	85ca                	mv	a1,s2
    3bea:	00004517          	auipc	a0,0x4
    3bee:	0ee50513          	addi	a0,a0,238 # 7cd8 <uthread_self+0x15fe>
    3bf2:	00002097          	auipc	ra,0x2
    3bf6:	5f8080e7          	jalr	1528(ra) # 61ea <printf>
    exit(1);
    3bfa:	4505                	li	a0,1
    3bfc:	00002097          	auipc	ra,0x2
    3c00:	24e080e7          	jalr	590(ra) # 5e4a <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3c04:	85ca                	mv	a1,s2
    3c06:	00004517          	auipc	a0,0x4
    3c0a:	0ea50513          	addi	a0,a0,234 # 7cf0 <uthread_self+0x1616>
    3c0e:	00002097          	auipc	ra,0x2
    3c12:	5dc080e7          	jalr	1500(ra) # 61ea <printf>
    exit(1);
    3c16:	4505                	li	a0,1
    3c18:	00002097          	auipc	ra,0x2
    3c1c:	232080e7          	jalr	562(ra) # 5e4a <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3c20:	85ca                	mv	a1,s2
    3c22:	00004517          	auipc	a0,0x4
    3c26:	0ee50513          	addi	a0,a0,238 # 7d10 <uthread_self+0x1636>
    3c2a:	00002097          	auipc	ra,0x2
    3c2e:	5c0080e7          	jalr	1472(ra) # 61ea <printf>
    exit(1);
    3c32:	4505                	li	a0,1
    3c34:	00002097          	auipc	ra,0x2
    3c38:	216080e7          	jalr	534(ra) # 5e4a <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3c3c:	85ca                	mv	a1,s2
    3c3e:	00004517          	auipc	a0,0x4
    3c42:	0f250513          	addi	a0,a0,242 # 7d30 <uthread_self+0x1656>
    3c46:	00002097          	auipc	ra,0x2
    3c4a:	5a4080e7          	jalr	1444(ra) # 61ea <printf>
    exit(1);
    3c4e:	4505                	li	a0,1
    3c50:	00002097          	auipc	ra,0x2
    3c54:	1fa080e7          	jalr	506(ra) # 5e4a <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3c58:	85ca                	mv	a1,s2
    3c5a:	00004517          	auipc	a0,0x4
    3c5e:	11650513          	addi	a0,a0,278 # 7d70 <uthread_self+0x1696>
    3c62:	00002097          	auipc	ra,0x2
    3c66:	588080e7          	jalr	1416(ra) # 61ea <printf>
    exit(1);
    3c6a:	4505                	li	a0,1
    3c6c:	00002097          	auipc	ra,0x2
    3c70:	1de080e7          	jalr	478(ra) # 5e4a <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3c74:	85ca                	mv	a1,s2
    3c76:	00004517          	auipc	a0,0x4
    3c7a:	12a50513          	addi	a0,a0,298 # 7da0 <uthread_self+0x16c6>
    3c7e:	00002097          	auipc	ra,0x2
    3c82:	56c080e7          	jalr	1388(ra) # 61ea <printf>
    exit(1);
    3c86:	4505                	li	a0,1
    3c88:	00002097          	auipc	ra,0x2
    3c8c:	1c2080e7          	jalr	450(ra) # 5e4a <exit>
    printf("%s: create dd succeeded!\n", s);
    3c90:	85ca                	mv	a1,s2
    3c92:	00004517          	auipc	a0,0x4
    3c96:	12e50513          	addi	a0,a0,302 # 7dc0 <uthread_self+0x16e6>
    3c9a:	00002097          	auipc	ra,0x2
    3c9e:	550080e7          	jalr	1360(ra) # 61ea <printf>
    exit(1);
    3ca2:	4505                	li	a0,1
    3ca4:	00002097          	auipc	ra,0x2
    3ca8:	1a6080e7          	jalr	422(ra) # 5e4a <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3cac:	85ca                	mv	a1,s2
    3cae:	00004517          	auipc	a0,0x4
    3cb2:	13250513          	addi	a0,a0,306 # 7de0 <uthread_self+0x1706>
    3cb6:	00002097          	auipc	ra,0x2
    3cba:	534080e7          	jalr	1332(ra) # 61ea <printf>
    exit(1);
    3cbe:	4505                	li	a0,1
    3cc0:	00002097          	auipc	ra,0x2
    3cc4:	18a080e7          	jalr	394(ra) # 5e4a <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3cc8:	85ca                	mv	a1,s2
    3cca:	00004517          	auipc	a0,0x4
    3cce:	13650513          	addi	a0,a0,310 # 7e00 <uthread_self+0x1726>
    3cd2:	00002097          	auipc	ra,0x2
    3cd6:	518080e7          	jalr	1304(ra) # 61ea <printf>
    exit(1);
    3cda:	4505                	li	a0,1
    3cdc:	00002097          	auipc	ra,0x2
    3ce0:	16e080e7          	jalr	366(ra) # 5e4a <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3ce4:	85ca                	mv	a1,s2
    3ce6:	00004517          	auipc	a0,0x4
    3cea:	14a50513          	addi	a0,a0,330 # 7e30 <uthread_self+0x1756>
    3cee:	00002097          	auipc	ra,0x2
    3cf2:	4fc080e7          	jalr	1276(ra) # 61ea <printf>
    exit(1);
    3cf6:	4505                	li	a0,1
    3cf8:	00002097          	auipc	ra,0x2
    3cfc:	152080e7          	jalr	338(ra) # 5e4a <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3d00:	85ca                	mv	a1,s2
    3d02:	00004517          	auipc	a0,0x4
    3d06:	15650513          	addi	a0,a0,342 # 7e58 <uthread_self+0x177e>
    3d0a:	00002097          	auipc	ra,0x2
    3d0e:	4e0080e7          	jalr	1248(ra) # 61ea <printf>
    exit(1);
    3d12:	4505                	li	a0,1
    3d14:	00002097          	auipc	ra,0x2
    3d18:	136080e7          	jalr	310(ra) # 5e4a <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3d1c:	85ca                	mv	a1,s2
    3d1e:	00004517          	auipc	a0,0x4
    3d22:	16250513          	addi	a0,a0,354 # 7e80 <uthread_self+0x17a6>
    3d26:	00002097          	auipc	ra,0x2
    3d2a:	4c4080e7          	jalr	1220(ra) # 61ea <printf>
    exit(1);
    3d2e:	4505                	li	a0,1
    3d30:	00002097          	auipc	ra,0x2
    3d34:	11a080e7          	jalr	282(ra) # 5e4a <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3d38:	85ca                	mv	a1,s2
    3d3a:	00004517          	auipc	a0,0x4
    3d3e:	16e50513          	addi	a0,a0,366 # 7ea8 <uthread_self+0x17ce>
    3d42:	00002097          	auipc	ra,0x2
    3d46:	4a8080e7          	jalr	1192(ra) # 61ea <printf>
    exit(1);
    3d4a:	4505                	li	a0,1
    3d4c:	00002097          	auipc	ra,0x2
    3d50:	0fe080e7          	jalr	254(ra) # 5e4a <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3d54:	85ca                	mv	a1,s2
    3d56:	00004517          	auipc	a0,0x4
    3d5a:	17250513          	addi	a0,a0,370 # 7ec8 <uthread_self+0x17ee>
    3d5e:	00002097          	auipc	ra,0x2
    3d62:	48c080e7          	jalr	1164(ra) # 61ea <printf>
    exit(1);
    3d66:	4505                	li	a0,1
    3d68:	00002097          	auipc	ra,0x2
    3d6c:	0e2080e7          	jalr	226(ra) # 5e4a <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3d70:	85ca                	mv	a1,s2
    3d72:	00004517          	auipc	a0,0x4
    3d76:	17650513          	addi	a0,a0,374 # 7ee8 <uthread_self+0x180e>
    3d7a:	00002097          	auipc	ra,0x2
    3d7e:	470080e7          	jalr	1136(ra) # 61ea <printf>
    exit(1);
    3d82:	4505                	li	a0,1
    3d84:	00002097          	auipc	ra,0x2
    3d88:	0c6080e7          	jalr	198(ra) # 5e4a <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3d8c:	85ca                	mv	a1,s2
    3d8e:	00004517          	auipc	a0,0x4
    3d92:	18250513          	addi	a0,a0,386 # 7f10 <uthread_self+0x1836>
    3d96:	00002097          	auipc	ra,0x2
    3d9a:	454080e7          	jalr	1108(ra) # 61ea <printf>
    exit(1);
    3d9e:	4505                	li	a0,1
    3da0:	00002097          	auipc	ra,0x2
    3da4:	0aa080e7          	jalr	170(ra) # 5e4a <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3da8:	85ca                	mv	a1,s2
    3daa:	00004517          	auipc	a0,0x4
    3dae:	18650513          	addi	a0,a0,390 # 7f30 <uthread_self+0x1856>
    3db2:	00002097          	auipc	ra,0x2
    3db6:	438080e7          	jalr	1080(ra) # 61ea <printf>
    exit(1);
    3dba:	4505                	li	a0,1
    3dbc:	00002097          	auipc	ra,0x2
    3dc0:	08e080e7          	jalr	142(ra) # 5e4a <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3dc4:	85ca                	mv	a1,s2
    3dc6:	00004517          	auipc	a0,0x4
    3dca:	18a50513          	addi	a0,a0,394 # 7f50 <uthread_self+0x1876>
    3dce:	00002097          	auipc	ra,0x2
    3dd2:	41c080e7          	jalr	1052(ra) # 61ea <printf>
    exit(1);
    3dd6:	4505                	li	a0,1
    3dd8:	00002097          	auipc	ra,0x2
    3ddc:	072080e7          	jalr	114(ra) # 5e4a <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3de0:	85ca                	mv	a1,s2
    3de2:	00004517          	auipc	a0,0x4
    3de6:	19650513          	addi	a0,a0,406 # 7f78 <uthread_self+0x189e>
    3dea:	00002097          	auipc	ra,0x2
    3dee:	400080e7          	jalr	1024(ra) # 61ea <printf>
    exit(1);
    3df2:	4505                	li	a0,1
    3df4:	00002097          	auipc	ra,0x2
    3df8:	056080e7          	jalr	86(ra) # 5e4a <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3dfc:	85ca                	mv	a1,s2
    3dfe:	00004517          	auipc	a0,0x4
    3e02:	e1250513          	addi	a0,a0,-494 # 7c10 <uthread_self+0x1536>
    3e06:	00002097          	auipc	ra,0x2
    3e0a:	3e4080e7          	jalr	996(ra) # 61ea <printf>
    exit(1);
    3e0e:	4505                	li	a0,1
    3e10:	00002097          	auipc	ra,0x2
    3e14:	03a080e7          	jalr	58(ra) # 5e4a <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3e18:	85ca                	mv	a1,s2
    3e1a:	00004517          	auipc	a0,0x4
    3e1e:	17e50513          	addi	a0,a0,382 # 7f98 <uthread_self+0x18be>
    3e22:	00002097          	auipc	ra,0x2
    3e26:	3c8080e7          	jalr	968(ra) # 61ea <printf>
    exit(1);
    3e2a:	4505                	li	a0,1
    3e2c:	00002097          	auipc	ra,0x2
    3e30:	01e080e7          	jalr	30(ra) # 5e4a <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3e34:	85ca                	mv	a1,s2
    3e36:	00004517          	auipc	a0,0x4
    3e3a:	18250513          	addi	a0,a0,386 # 7fb8 <uthread_self+0x18de>
    3e3e:	00002097          	auipc	ra,0x2
    3e42:	3ac080e7          	jalr	940(ra) # 61ea <printf>
    exit(1);
    3e46:	4505                	li	a0,1
    3e48:	00002097          	auipc	ra,0x2
    3e4c:	002080e7          	jalr	2(ra) # 5e4a <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3e50:	85ca                	mv	a1,s2
    3e52:	00004517          	auipc	a0,0x4
    3e56:	19650513          	addi	a0,a0,406 # 7fe8 <uthread_self+0x190e>
    3e5a:	00002097          	auipc	ra,0x2
    3e5e:	390080e7          	jalr	912(ra) # 61ea <printf>
    exit(1);
    3e62:	4505                	li	a0,1
    3e64:	00002097          	auipc	ra,0x2
    3e68:	fe6080e7          	jalr	-26(ra) # 5e4a <exit>
    printf("%s: unlink dd failed\n", s);
    3e6c:	85ca                	mv	a1,s2
    3e6e:	00004517          	auipc	a0,0x4
    3e72:	19a50513          	addi	a0,a0,410 # 8008 <uthread_self+0x192e>
    3e76:	00002097          	auipc	ra,0x2
    3e7a:	374080e7          	jalr	884(ra) # 61ea <printf>
    exit(1);
    3e7e:	4505                	li	a0,1
    3e80:	00002097          	auipc	ra,0x2
    3e84:	fca080e7          	jalr	-54(ra) # 5e4a <exit>

0000000000003e88 <rmdot>:
{
    3e88:	1101                	addi	sp,sp,-32
    3e8a:	ec06                	sd	ra,24(sp)
    3e8c:	e822                	sd	s0,16(sp)
    3e8e:	e426                	sd	s1,8(sp)
    3e90:	1000                	addi	s0,sp,32
    3e92:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3e94:	00004517          	auipc	a0,0x4
    3e98:	18c50513          	addi	a0,a0,396 # 8020 <uthread_self+0x1946>
    3e9c:	00002097          	auipc	ra,0x2
    3ea0:	016080e7          	jalr	22(ra) # 5eb2 <mkdir>
    3ea4:	e549                	bnez	a0,3f2e <rmdot+0xa6>
  if(chdir("dots") != 0){
    3ea6:	00004517          	auipc	a0,0x4
    3eaa:	17a50513          	addi	a0,a0,378 # 8020 <uthread_self+0x1946>
    3eae:	00002097          	auipc	ra,0x2
    3eb2:	00c080e7          	jalr	12(ra) # 5eba <chdir>
    3eb6:	e951                	bnez	a0,3f4a <rmdot+0xc2>
  if(unlink(".") == 0){
    3eb8:	00003517          	auipc	a0,0x3
    3ebc:	f9850513          	addi	a0,a0,-104 # 6e50 <uthread_self+0x776>
    3ec0:	00002097          	auipc	ra,0x2
    3ec4:	fda080e7          	jalr	-38(ra) # 5e9a <unlink>
    3ec8:	cd59                	beqz	a0,3f66 <rmdot+0xde>
  if(unlink("..") == 0){
    3eca:	00004517          	auipc	a0,0x4
    3ece:	bae50513          	addi	a0,a0,-1106 # 7a78 <uthread_self+0x139e>
    3ed2:	00002097          	auipc	ra,0x2
    3ed6:	fc8080e7          	jalr	-56(ra) # 5e9a <unlink>
    3eda:	c545                	beqz	a0,3f82 <rmdot+0xfa>
  if(chdir("/") != 0){
    3edc:	00004517          	auipc	a0,0x4
    3ee0:	b4450513          	addi	a0,a0,-1212 # 7a20 <uthread_self+0x1346>
    3ee4:	00002097          	auipc	ra,0x2
    3ee8:	fd6080e7          	jalr	-42(ra) # 5eba <chdir>
    3eec:	e94d                	bnez	a0,3f9e <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3eee:	00004517          	auipc	a0,0x4
    3ef2:	19a50513          	addi	a0,a0,410 # 8088 <uthread_self+0x19ae>
    3ef6:	00002097          	auipc	ra,0x2
    3efa:	fa4080e7          	jalr	-92(ra) # 5e9a <unlink>
    3efe:	cd55                	beqz	a0,3fba <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3f00:	00004517          	auipc	a0,0x4
    3f04:	1b050513          	addi	a0,a0,432 # 80b0 <uthread_self+0x19d6>
    3f08:	00002097          	auipc	ra,0x2
    3f0c:	f92080e7          	jalr	-110(ra) # 5e9a <unlink>
    3f10:	c179                	beqz	a0,3fd6 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3f12:	00004517          	auipc	a0,0x4
    3f16:	10e50513          	addi	a0,a0,270 # 8020 <uthread_self+0x1946>
    3f1a:	00002097          	auipc	ra,0x2
    3f1e:	f80080e7          	jalr	-128(ra) # 5e9a <unlink>
    3f22:	e961                	bnez	a0,3ff2 <rmdot+0x16a>
}
    3f24:	60e2                	ld	ra,24(sp)
    3f26:	6442                	ld	s0,16(sp)
    3f28:	64a2                	ld	s1,8(sp)
    3f2a:	6105                	addi	sp,sp,32
    3f2c:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3f2e:	85a6                	mv	a1,s1
    3f30:	00004517          	auipc	a0,0x4
    3f34:	0f850513          	addi	a0,a0,248 # 8028 <uthread_self+0x194e>
    3f38:	00002097          	auipc	ra,0x2
    3f3c:	2b2080e7          	jalr	690(ra) # 61ea <printf>
    exit(1);
    3f40:	4505                	li	a0,1
    3f42:	00002097          	auipc	ra,0x2
    3f46:	f08080e7          	jalr	-248(ra) # 5e4a <exit>
    printf("%s: chdir dots failed\n", s);
    3f4a:	85a6                	mv	a1,s1
    3f4c:	00004517          	auipc	a0,0x4
    3f50:	0f450513          	addi	a0,a0,244 # 8040 <uthread_self+0x1966>
    3f54:	00002097          	auipc	ra,0x2
    3f58:	296080e7          	jalr	662(ra) # 61ea <printf>
    exit(1);
    3f5c:	4505                	li	a0,1
    3f5e:	00002097          	auipc	ra,0x2
    3f62:	eec080e7          	jalr	-276(ra) # 5e4a <exit>
    printf("%s: rm . worked!\n", s);
    3f66:	85a6                	mv	a1,s1
    3f68:	00004517          	auipc	a0,0x4
    3f6c:	0f050513          	addi	a0,a0,240 # 8058 <uthread_self+0x197e>
    3f70:	00002097          	auipc	ra,0x2
    3f74:	27a080e7          	jalr	634(ra) # 61ea <printf>
    exit(1);
    3f78:	4505                	li	a0,1
    3f7a:	00002097          	auipc	ra,0x2
    3f7e:	ed0080e7          	jalr	-304(ra) # 5e4a <exit>
    printf("%s: rm .. worked!\n", s);
    3f82:	85a6                	mv	a1,s1
    3f84:	00004517          	auipc	a0,0x4
    3f88:	0ec50513          	addi	a0,a0,236 # 8070 <uthread_self+0x1996>
    3f8c:	00002097          	auipc	ra,0x2
    3f90:	25e080e7          	jalr	606(ra) # 61ea <printf>
    exit(1);
    3f94:	4505                	li	a0,1
    3f96:	00002097          	auipc	ra,0x2
    3f9a:	eb4080e7          	jalr	-332(ra) # 5e4a <exit>
    printf("%s: chdir / failed\n", s);
    3f9e:	85a6                	mv	a1,s1
    3fa0:	00004517          	auipc	a0,0x4
    3fa4:	a8850513          	addi	a0,a0,-1400 # 7a28 <uthread_self+0x134e>
    3fa8:	00002097          	auipc	ra,0x2
    3fac:	242080e7          	jalr	578(ra) # 61ea <printf>
    exit(1);
    3fb0:	4505                	li	a0,1
    3fb2:	00002097          	auipc	ra,0x2
    3fb6:	e98080e7          	jalr	-360(ra) # 5e4a <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3fba:	85a6                	mv	a1,s1
    3fbc:	00004517          	auipc	a0,0x4
    3fc0:	0d450513          	addi	a0,a0,212 # 8090 <uthread_self+0x19b6>
    3fc4:	00002097          	auipc	ra,0x2
    3fc8:	226080e7          	jalr	550(ra) # 61ea <printf>
    exit(1);
    3fcc:	4505                	li	a0,1
    3fce:	00002097          	auipc	ra,0x2
    3fd2:	e7c080e7          	jalr	-388(ra) # 5e4a <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3fd6:	85a6                	mv	a1,s1
    3fd8:	00004517          	auipc	a0,0x4
    3fdc:	0e050513          	addi	a0,a0,224 # 80b8 <uthread_self+0x19de>
    3fe0:	00002097          	auipc	ra,0x2
    3fe4:	20a080e7          	jalr	522(ra) # 61ea <printf>
    exit(1);
    3fe8:	4505                	li	a0,1
    3fea:	00002097          	auipc	ra,0x2
    3fee:	e60080e7          	jalr	-416(ra) # 5e4a <exit>
    printf("%s: unlink dots failed!\n", s);
    3ff2:	85a6                	mv	a1,s1
    3ff4:	00004517          	auipc	a0,0x4
    3ff8:	0e450513          	addi	a0,a0,228 # 80d8 <uthread_self+0x19fe>
    3ffc:	00002097          	auipc	ra,0x2
    4000:	1ee080e7          	jalr	494(ra) # 61ea <printf>
    exit(1);
    4004:	4505                	li	a0,1
    4006:	00002097          	auipc	ra,0x2
    400a:	e44080e7          	jalr	-444(ra) # 5e4a <exit>

000000000000400e <dirfile>:
{
    400e:	1101                	addi	sp,sp,-32
    4010:	ec06                	sd	ra,24(sp)
    4012:	e822                	sd	s0,16(sp)
    4014:	e426                	sd	s1,8(sp)
    4016:	e04a                	sd	s2,0(sp)
    4018:	1000                	addi	s0,sp,32
    401a:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    401c:	20000593          	li	a1,512
    4020:	00004517          	auipc	a0,0x4
    4024:	0d850513          	addi	a0,a0,216 # 80f8 <uthread_self+0x1a1e>
    4028:	00002097          	auipc	ra,0x2
    402c:	e62080e7          	jalr	-414(ra) # 5e8a <open>
  if(fd < 0){
    4030:	0e054d63          	bltz	a0,412a <dirfile+0x11c>
  close(fd);
    4034:	00002097          	auipc	ra,0x2
    4038:	e3e080e7          	jalr	-450(ra) # 5e72 <close>
  if(chdir("dirfile") == 0){
    403c:	00004517          	auipc	a0,0x4
    4040:	0bc50513          	addi	a0,a0,188 # 80f8 <uthread_self+0x1a1e>
    4044:	00002097          	auipc	ra,0x2
    4048:	e76080e7          	jalr	-394(ra) # 5eba <chdir>
    404c:	cd6d                	beqz	a0,4146 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    404e:	4581                	li	a1,0
    4050:	00004517          	auipc	a0,0x4
    4054:	0f050513          	addi	a0,a0,240 # 8140 <uthread_self+0x1a66>
    4058:	00002097          	auipc	ra,0x2
    405c:	e32080e7          	jalr	-462(ra) # 5e8a <open>
  if(fd >= 0){
    4060:	10055163          	bgez	a0,4162 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    4064:	20000593          	li	a1,512
    4068:	00004517          	auipc	a0,0x4
    406c:	0d850513          	addi	a0,a0,216 # 8140 <uthread_self+0x1a66>
    4070:	00002097          	auipc	ra,0x2
    4074:	e1a080e7          	jalr	-486(ra) # 5e8a <open>
  if(fd >= 0){
    4078:	10055363          	bgez	a0,417e <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    407c:	00004517          	auipc	a0,0x4
    4080:	0c450513          	addi	a0,a0,196 # 8140 <uthread_self+0x1a66>
    4084:	00002097          	auipc	ra,0x2
    4088:	e2e080e7          	jalr	-466(ra) # 5eb2 <mkdir>
    408c:	10050763          	beqz	a0,419a <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    4090:	00004517          	auipc	a0,0x4
    4094:	0b050513          	addi	a0,a0,176 # 8140 <uthread_self+0x1a66>
    4098:	00002097          	auipc	ra,0x2
    409c:	e02080e7          	jalr	-510(ra) # 5e9a <unlink>
    40a0:	10050b63          	beqz	a0,41b6 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    40a4:	00004597          	auipc	a1,0x4
    40a8:	09c58593          	addi	a1,a1,156 # 8140 <uthread_self+0x1a66>
    40ac:	00003517          	auipc	a0,0x3
    40b0:	89450513          	addi	a0,a0,-1900 # 6940 <uthread_self+0x266>
    40b4:	00002097          	auipc	ra,0x2
    40b8:	df6080e7          	jalr	-522(ra) # 5eaa <link>
    40bc:	10050b63          	beqz	a0,41d2 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    40c0:	00004517          	auipc	a0,0x4
    40c4:	03850513          	addi	a0,a0,56 # 80f8 <uthread_self+0x1a1e>
    40c8:	00002097          	auipc	ra,0x2
    40cc:	dd2080e7          	jalr	-558(ra) # 5e9a <unlink>
    40d0:	10051f63          	bnez	a0,41ee <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    40d4:	4589                	li	a1,2
    40d6:	00003517          	auipc	a0,0x3
    40da:	d7a50513          	addi	a0,a0,-646 # 6e50 <uthread_self+0x776>
    40de:	00002097          	auipc	ra,0x2
    40e2:	dac080e7          	jalr	-596(ra) # 5e8a <open>
  if(fd >= 0){
    40e6:	12055263          	bgez	a0,420a <dirfile+0x1fc>
  fd = open(".", 0);
    40ea:	4581                	li	a1,0
    40ec:	00003517          	auipc	a0,0x3
    40f0:	d6450513          	addi	a0,a0,-668 # 6e50 <uthread_self+0x776>
    40f4:	00002097          	auipc	ra,0x2
    40f8:	d96080e7          	jalr	-618(ra) # 5e8a <open>
    40fc:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    40fe:	4605                	li	a2,1
    4100:	00002597          	auipc	a1,0x2
    4104:	6b858593          	addi	a1,a1,1720 # 67b8 <uthread_self+0xde>
    4108:	00002097          	auipc	ra,0x2
    410c:	d62080e7          	jalr	-670(ra) # 5e6a <write>
    4110:	10a04b63          	bgtz	a0,4226 <dirfile+0x218>
  close(fd);
    4114:	8526                	mv	a0,s1
    4116:	00002097          	auipc	ra,0x2
    411a:	d5c080e7          	jalr	-676(ra) # 5e72 <close>
}
    411e:	60e2                	ld	ra,24(sp)
    4120:	6442                	ld	s0,16(sp)
    4122:	64a2                	ld	s1,8(sp)
    4124:	6902                	ld	s2,0(sp)
    4126:	6105                	addi	sp,sp,32
    4128:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    412a:	85ca                	mv	a1,s2
    412c:	00004517          	auipc	a0,0x4
    4130:	fd450513          	addi	a0,a0,-44 # 8100 <uthread_self+0x1a26>
    4134:	00002097          	auipc	ra,0x2
    4138:	0b6080e7          	jalr	182(ra) # 61ea <printf>
    exit(1);
    413c:	4505                	li	a0,1
    413e:	00002097          	auipc	ra,0x2
    4142:	d0c080e7          	jalr	-756(ra) # 5e4a <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    4146:	85ca                	mv	a1,s2
    4148:	00004517          	auipc	a0,0x4
    414c:	fd850513          	addi	a0,a0,-40 # 8120 <uthread_self+0x1a46>
    4150:	00002097          	auipc	ra,0x2
    4154:	09a080e7          	jalr	154(ra) # 61ea <printf>
    exit(1);
    4158:	4505                	li	a0,1
    415a:	00002097          	auipc	ra,0x2
    415e:	cf0080e7          	jalr	-784(ra) # 5e4a <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    4162:	85ca                	mv	a1,s2
    4164:	00004517          	auipc	a0,0x4
    4168:	fec50513          	addi	a0,a0,-20 # 8150 <uthread_self+0x1a76>
    416c:	00002097          	auipc	ra,0x2
    4170:	07e080e7          	jalr	126(ra) # 61ea <printf>
    exit(1);
    4174:	4505                	li	a0,1
    4176:	00002097          	auipc	ra,0x2
    417a:	cd4080e7          	jalr	-812(ra) # 5e4a <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    417e:	85ca                	mv	a1,s2
    4180:	00004517          	auipc	a0,0x4
    4184:	fd050513          	addi	a0,a0,-48 # 8150 <uthread_self+0x1a76>
    4188:	00002097          	auipc	ra,0x2
    418c:	062080e7          	jalr	98(ra) # 61ea <printf>
    exit(1);
    4190:	4505                	li	a0,1
    4192:	00002097          	auipc	ra,0x2
    4196:	cb8080e7          	jalr	-840(ra) # 5e4a <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    419a:	85ca                	mv	a1,s2
    419c:	00004517          	auipc	a0,0x4
    41a0:	fdc50513          	addi	a0,a0,-36 # 8178 <uthread_self+0x1a9e>
    41a4:	00002097          	auipc	ra,0x2
    41a8:	046080e7          	jalr	70(ra) # 61ea <printf>
    exit(1);
    41ac:	4505                	li	a0,1
    41ae:	00002097          	auipc	ra,0x2
    41b2:	c9c080e7          	jalr	-868(ra) # 5e4a <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    41b6:	85ca                	mv	a1,s2
    41b8:	00004517          	auipc	a0,0x4
    41bc:	fe850513          	addi	a0,a0,-24 # 81a0 <uthread_self+0x1ac6>
    41c0:	00002097          	auipc	ra,0x2
    41c4:	02a080e7          	jalr	42(ra) # 61ea <printf>
    exit(1);
    41c8:	4505                	li	a0,1
    41ca:	00002097          	auipc	ra,0x2
    41ce:	c80080e7          	jalr	-896(ra) # 5e4a <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    41d2:	85ca                	mv	a1,s2
    41d4:	00004517          	auipc	a0,0x4
    41d8:	ff450513          	addi	a0,a0,-12 # 81c8 <uthread_self+0x1aee>
    41dc:	00002097          	auipc	ra,0x2
    41e0:	00e080e7          	jalr	14(ra) # 61ea <printf>
    exit(1);
    41e4:	4505                	li	a0,1
    41e6:	00002097          	auipc	ra,0x2
    41ea:	c64080e7          	jalr	-924(ra) # 5e4a <exit>
    printf("%s: unlink dirfile failed!\n", s);
    41ee:	85ca                	mv	a1,s2
    41f0:	00004517          	auipc	a0,0x4
    41f4:	00050513          	mv	a0,a0
    41f8:	00002097          	auipc	ra,0x2
    41fc:	ff2080e7          	jalr	-14(ra) # 61ea <printf>
    exit(1);
    4200:	4505                	li	a0,1
    4202:	00002097          	auipc	ra,0x2
    4206:	c48080e7          	jalr	-952(ra) # 5e4a <exit>
    printf("%s: open . for writing succeeded!\n", s);
    420a:	85ca                	mv	a1,s2
    420c:	00004517          	auipc	a0,0x4
    4210:	00450513          	addi	a0,a0,4 # 8210 <uthread_self+0x1b36>
    4214:	00002097          	auipc	ra,0x2
    4218:	fd6080e7          	jalr	-42(ra) # 61ea <printf>
    exit(1);
    421c:	4505                	li	a0,1
    421e:	00002097          	auipc	ra,0x2
    4222:	c2c080e7          	jalr	-980(ra) # 5e4a <exit>
    printf("%s: write . succeeded!\n", s);
    4226:	85ca                	mv	a1,s2
    4228:	00004517          	auipc	a0,0x4
    422c:	01050513          	addi	a0,a0,16 # 8238 <uthread_self+0x1b5e>
    4230:	00002097          	auipc	ra,0x2
    4234:	fba080e7          	jalr	-70(ra) # 61ea <printf>
    exit(1);
    4238:	4505                	li	a0,1
    423a:	00002097          	auipc	ra,0x2
    423e:	c10080e7          	jalr	-1008(ra) # 5e4a <exit>

0000000000004242 <iref>:
{
    4242:	7139                	addi	sp,sp,-64
    4244:	fc06                	sd	ra,56(sp)
    4246:	f822                	sd	s0,48(sp)
    4248:	f426                	sd	s1,40(sp)
    424a:	f04a                	sd	s2,32(sp)
    424c:	ec4e                	sd	s3,24(sp)
    424e:	e852                	sd	s4,16(sp)
    4250:	e456                	sd	s5,8(sp)
    4252:	e05a                	sd	s6,0(sp)
    4254:	0080                	addi	s0,sp,64
    4256:	8b2a                	mv	s6,a0
    4258:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    425c:	00004a17          	auipc	s4,0x4
    4260:	ff4a0a13          	addi	s4,s4,-12 # 8250 <uthread_self+0x1b76>
    mkdir("");
    4264:	00004497          	auipc	s1,0x4
    4268:	af448493          	addi	s1,s1,-1292 # 7d58 <uthread_self+0x167e>
    link("README", "");
    426c:	00002a97          	auipc	s5,0x2
    4270:	6d4a8a93          	addi	s5,s5,1748 # 6940 <uthread_self+0x266>
    fd = open("xx", O_CREATE);
    4274:	00004997          	auipc	s3,0x4
    4278:	ed498993          	addi	s3,s3,-300 # 8148 <uthread_self+0x1a6e>
    427c:	a891                	j	42d0 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    427e:	85da                	mv	a1,s6
    4280:	00004517          	auipc	a0,0x4
    4284:	fd850513          	addi	a0,a0,-40 # 8258 <uthread_self+0x1b7e>
    4288:	00002097          	auipc	ra,0x2
    428c:	f62080e7          	jalr	-158(ra) # 61ea <printf>
      exit(1);
    4290:	4505                	li	a0,1
    4292:	00002097          	auipc	ra,0x2
    4296:	bb8080e7          	jalr	-1096(ra) # 5e4a <exit>
      printf("%s: chdir irefd failed\n", s);
    429a:	85da                	mv	a1,s6
    429c:	00004517          	auipc	a0,0x4
    42a0:	fd450513          	addi	a0,a0,-44 # 8270 <uthread_self+0x1b96>
    42a4:	00002097          	auipc	ra,0x2
    42a8:	f46080e7          	jalr	-186(ra) # 61ea <printf>
      exit(1);
    42ac:	4505                	li	a0,1
    42ae:	00002097          	auipc	ra,0x2
    42b2:	b9c080e7          	jalr	-1124(ra) # 5e4a <exit>
      close(fd);
    42b6:	00002097          	auipc	ra,0x2
    42ba:	bbc080e7          	jalr	-1092(ra) # 5e72 <close>
    42be:	a889                	j	4310 <iref+0xce>
    unlink("xx");
    42c0:	854e                	mv	a0,s3
    42c2:	00002097          	auipc	ra,0x2
    42c6:	bd8080e7          	jalr	-1064(ra) # 5e9a <unlink>
  for(i = 0; i < NINODE + 1; i++){
    42ca:	397d                	addiw	s2,s2,-1
    42cc:	06090063          	beqz	s2,432c <iref+0xea>
    if(mkdir("irefd") != 0){
    42d0:	8552                	mv	a0,s4
    42d2:	00002097          	auipc	ra,0x2
    42d6:	be0080e7          	jalr	-1056(ra) # 5eb2 <mkdir>
    42da:	f155                	bnez	a0,427e <iref+0x3c>
    if(chdir("irefd") != 0){
    42dc:	8552                	mv	a0,s4
    42de:	00002097          	auipc	ra,0x2
    42e2:	bdc080e7          	jalr	-1060(ra) # 5eba <chdir>
    42e6:	f955                	bnez	a0,429a <iref+0x58>
    mkdir("");
    42e8:	8526                	mv	a0,s1
    42ea:	00002097          	auipc	ra,0x2
    42ee:	bc8080e7          	jalr	-1080(ra) # 5eb2 <mkdir>
    link("README", "");
    42f2:	85a6                	mv	a1,s1
    42f4:	8556                	mv	a0,s5
    42f6:	00002097          	auipc	ra,0x2
    42fa:	bb4080e7          	jalr	-1100(ra) # 5eaa <link>
    fd = open("", O_CREATE);
    42fe:	20000593          	li	a1,512
    4302:	8526                	mv	a0,s1
    4304:	00002097          	auipc	ra,0x2
    4308:	b86080e7          	jalr	-1146(ra) # 5e8a <open>
    if(fd >= 0)
    430c:	fa0555e3          	bgez	a0,42b6 <iref+0x74>
    fd = open("xx", O_CREATE);
    4310:	20000593          	li	a1,512
    4314:	854e                	mv	a0,s3
    4316:	00002097          	auipc	ra,0x2
    431a:	b74080e7          	jalr	-1164(ra) # 5e8a <open>
    if(fd >= 0)
    431e:	fa0541e3          	bltz	a0,42c0 <iref+0x7e>
      close(fd);
    4322:	00002097          	auipc	ra,0x2
    4326:	b50080e7          	jalr	-1200(ra) # 5e72 <close>
    432a:	bf59                	j	42c0 <iref+0x7e>
    432c:	03300493          	li	s1,51
    chdir("..");
    4330:	00003997          	auipc	s3,0x3
    4334:	74898993          	addi	s3,s3,1864 # 7a78 <uthread_self+0x139e>
    unlink("irefd");
    4338:	00004917          	auipc	s2,0x4
    433c:	f1890913          	addi	s2,s2,-232 # 8250 <uthread_self+0x1b76>
    chdir("..");
    4340:	854e                	mv	a0,s3
    4342:	00002097          	auipc	ra,0x2
    4346:	b78080e7          	jalr	-1160(ra) # 5eba <chdir>
    unlink("irefd");
    434a:	854a                	mv	a0,s2
    434c:	00002097          	auipc	ra,0x2
    4350:	b4e080e7          	jalr	-1202(ra) # 5e9a <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4354:	34fd                	addiw	s1,s1,-1
    4356:	f4ed                	bnez	s1,4340 <iref+0xfe>
  chdir("/");
    4358:	00003517          	auipc	a0,0x3
    435c:	6c850513          	addi	a0,a0,1736 # 7a20 <uthread_self+0x1346>
    4360:	00002097          	auipc	ra,0x2
    4364:	b5a080e7          	jalr	-1190(ra) # 5eba <chdir>
}
    4368:	70e2                	ld	ra,56(sp)
    436a:	7442                	ld	s0,48(sp)
    436c:	74a2                	ld	s1,40(sp)
    436e:	7902                	ld	s2,32(sp)
    4370:	69e2                	ld	s3,24(sp)
    4372:	6a42                	ld	s4,16(sp)
    4374:	6aa2                	ld	s5,8(sp)
    4376:	6b02                	ld	s6,0(sp)
    4378:	6121                	addi	sp,sp,64
    437a:	8082                	ret

000000000000437c <openiputtest>:
{
    437c:	7179                	addi	sp,sp,-48
    437e:	f406                	sd	ra,40(sp)
    4380:	f022                	sd	s0,32(sp)
    4382:	ec26                	sd	s1,24(sp)
    4384:	1800                	addi	s0,sp,48
    4386:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    4388:	00004517          	auipc	a0,0x4
    438c:	f0050513          	addi	a0,a0,-256 # 8288 <uthread_self+0x1bae>
    4390:	00002097          	auipc	ra,0x2
    4394:	b22080e7          	jalr	-1246(ra) # 5eb2 <mkdir>
    4398:	04054263          	bltz	a0,43dc <openiputtest+0x60>
  pid = fork();
    439c:	00002097          	auipc	ra,0x2
    43a0:	aa6080e7          	jalr	-1370(ra) # 5e42 <fork>
  if(pid < 0){
    43a4:	04054a63          	bltz	a0,43f8 <openiputtest+0x7c>
  if(pid == 0){
    43a8:	e93d                	bnez	a0,441e <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    43aa:	4589                	li	a1,2
    43ac:	00004517          	auipc	a0,0x4
    43b0:	edc50513          	addi	a0,a0,-292 # 8288 <uthread_self+0x1bae>
    43b4:	00002097          	auipc	ra,0x2
    43b8:	ad6080e7          	jalr	-1322(ra) # 5e8a <open>
    if(fd >= 0){
    43bc:	04054c63          	bltz	a0,4414 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    43c0:	85a6                	mv	a1,s1
    43c2:	00004517          	auipc	a0,0x4
    43c6:	ee650513          	addi	a0,a0,-282 # 82a8 <uthread_self+0x1bce>
    43ca:	00002097          	auipc	ra,0x2
    43ce:	e20080e7          	jalr	-480(ra) # 61ea <printf>
      exit(1);
    43d2:	4505                	li	a0,1
    43d4:	00002097          	auipc	ra,0x2
    43d8:	a76080e7          	jalr	-1418(ra) # 5e4a <exit>
    printf("%s: mkdir oidir failed\n", s);
    43dc:	85a6                	mv	a1,s1
    43de:	00004517          	auipc	a0,0x4
    43e2:	eb250513          	addi	a0,a0,-334 # 8290 <uthread_self+0x1bb6>
    43e6:	00002097          	auipc	ra,0x2
    43ea:	e04080e7          	jalr	-508(ra) # 61ea <printf>
    exit(1);
    43ee:	4505                	li	a0,1
    43f0:	00002097          	auipc	ra,0x2
    43f4:	a5a080e7          	jalr	-1446(ra) # 5e4a <exit>
    printf("%s: fork failed\n", s);
    43f8:	85a6                	mv	a1,s1
    43fa:	00003517          	auipc	a0,0x3
    43fe:	bf650513          	addi	a0,a0,-1034 # 6ff0 <uthread_self+0x916>
    4402:	00002097          	auipc	ra,0x2
    4406:	de8080e7          	jalr	-536(ra) # 61ea <printf>
    exit(1);
    440a:	4505                	li	a0,1
    440c:	00002097          	auipc	ra,0x2
    4410:	a3e080e7          	jalr	-1474(ra) # 5e4a <exit>
    exit(0);
    4414:	4501                	li	a0,0
    4416:	00002097          	auipc	ra,0x2
    441a:	a34080e7          	jalr	-1484(ra) # 5e4a <exit>
  sleep(1);
    441e:	4505                	li	a0,1
    4420:	00002097          	auipc	ra,0x2
    4424:	aba080e7          	jalr	-1350(ra) # 5eda <sleep>
  if(unlink("oidir") != 0){
    4428:	00004517          	auipc	a0,0x4
    442c:	e6050513          	addi	a0,a0,-416 # 8288 <uthread_self+0x1bae>
    4430:	00002097          	auipc	ra,0x2
    4434:	a6a080e7          	jalr	-1430(ra) # 5e9a <unlink>
    4438:	cd19                	beqz	a0,4456 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    443a:	85a6                	mv	a1,s1
    443c:	00003517          	auipc	a0,0x3
    4440:	da450513          	addi	a0,a0,-604 # 71e0 <uthread_self+0xb06>
    4444:	00002097          	auipc	ra,0x2
    4448:	da6080e7          	jalr	-602(ra) # 61ea <printf>
    exit(1);
    444c:	4505                	li	a0,1
    444e:	00002097          	auipc	ra,0x2
    4452:	9fc080e7          	jalr	-1540(ra) # 5e4a <exit>
  wait(&xstatus);
    4456:	fdc40513          	addi	a0,s0,-36
    445a:	00002097          	auipc	ra,0x2
    445e:	9f8080e7          	jalr	-1544(ra) # 5e52 <wait>
  exit(xstatus);
    4462:	fdc42503          	lw	a0,-36(s0)
    4466:	00002097          	auipc	ra,0x2
    446a:	9e4080e7          	jalr	-1564(ra) # 5e4a <exit>

000000000000446e <forkforkfork>:
{
    446e:	1101                	addi	sp,sp,-32
    4470:	ec06                	sd	ra,24(sp)
    4472:	e822                	sd	s0,16(sp)
    4474:	e426                	sd	s1,8(sp)
    4476:	1000                	addi	s0,sp,32
    4478:	84aa                	mv	s1,a0
  unlink("stopforking");
    447a:	00004517          	auipc	a0,0x4
    447e:	e5650513          	addi	a0,a0,-426 # 82d0 <uthread_self+0x1bf6>
    4482:	00002097          	auipc	ra,0x2
    4486:	a18080e7          	jalr	-1512(ra) # 5e9a <unlink>
  int pid = fork();
    448a:	00002097          	auipc	ra,0x2
    448e:	9b8080e7          	jalr	-1608(ra) # 5e42 <fork>
  if(pid < 0){
    4492:	04054563          	bltz	a0,44dc <forkforkfork+0x6e>
  if(pid == 0){
    4496:	c12d                	beqz	a0,44f8 <forkforkfork+0x8a>
  sleep(20); // two seconds
    4498:	4551                	li	a0,20
    449a:	00002097          	auipc	ra,0x2
    449e:	a40080e7          	jalr	-1472(ra) # 5eda <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    44a2:	20200593          	li	a1,514
    44a6:	00004517          	auipc	a0,0x4
    44aa:	e2a50513          	addi	a0,a0,-470 # 82d0 <uthread_self+0x1bf6>
    44ae:	00002097          	auipc	ra,0x2
    44b2:	9dc080e7          	jalr	-1572(ra) # 5e8a <open>
    44b6:	00002097          	auipc	ra,0x2
    44ba:	9bc080e7          	jalr	-1604(ra) # 5e72 <close>
  wait(0);
    44be:	4501                	li	a0,0
    44c0:	00002097          	auipc	ra,0x2
    44c4:	992080e7          	jalr	-1646(ra) # 5e52 <wait>
  sleep(10); // one second
    44c8:	4529                	li	a0,10
    44ca:	00002097          	auipc	ra,0x2
    44ce:	a10080e7          	jalr	-1520(ra) # 5eda <sleep>
}
    44d2:	60e2                	ld	ra,24(sp)
    44d4:	6442                	ld	s0,16(sp)
    44d6:	64a2                	ld	s1,8(sp)
    44d8:	6105                	addi	sp,sp,32
    44da:	8082                	ret
    printf("%s: fork failed", s);
    44dc:	85a6                	mv	a1,s1
    44de:	00003517          	auipc	a0,0x3
    44e2:	cd250513          	addi	a0,a0,-814 # 71b0 <uthread_self+0xad6>
    44e6:	00002097          	auipc	ra,0x2
    44ea:	d04080e7          	jalr	-764(ra) # 61ea <printf>
    exit(1);
    44ee:	4505                	li	a0,1
    44f0:	00002097          	auipc	ra,0x2
    44f4:	95a080e7          	jalr	-1702(ra) # 5e4a <exit>
      int fd = open("stopforking", 0);
    44f8:	00004497          	auipc	s1,0x4
    44fc:	dd848493          	addi	s1,s1,-552 # 82d0 <uthread_self+0x1bf6>
    4500:	4581                	li	a1,0
    4502:	8526                	mv	a0,s1
    4504:	00002097          	auipc	ra,0x2
    4508:	986080e7          	jalr	-1658(ra) # 5e8a <open>
      if(fd >= 0){
    450c:	02055463          	bgez	a0,4534 <forkforkfork+0xc6>
      if(fork() < 0){
    4510:	00002097          	auipc	ra,0x2
    4514:	932080e7          	jalr	-1742(ra) # 5e42 <fork>
    4518:	fe0554e3          	bgez	a0,4500 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    451c:	20200593          	li	a1,514
    4520:	8526                	mv	a0,s1
    4522:	00002097          	auipc	ra,0x2
    4526:	968080e7          	jalr	-1688(ra) # 5e8a <open>
    452a:	00002097          	auipc	ra,0x2
    452e:	948080e7          	jalr	-1720(ra) # 5e72 <close>
    4532:	b7f9                	j	4500 <forkforkfork+0x92>
        exit(0);
    4534:	4501                	li	a0,0
    4536:	00002097          	auipc	ra,0x2
    453a:	914080e7          	jalr	-1772(ra) # 5e4a <exit>

000000000000453e <killstatus>:
{
    453e:	7139                	addi	sp,sp,-64
    4540:	fc06                	sd	ra,56(sp)
    4542:	f822                	sd	s0,48(sp)
    4544:	f426                	sd	s1,40(sp)
    4546:	f04a                	sd	s2,32(sp)
    4548:	ec4e                	sd	s3,24(sp)
    454a:	e852                	sd	s4,16(sp)
    454c:	0080                	addi	s0,sp,64
    454e:	8a2a                	mv	s4,a0
    4550:	06400913          	li	s2,100
    if(xst != -1) {
    4554:	59fd                	li	s3,-1
    int pid1 = fork();
    4556:	00002097          	auipc	ra,0x2
    455a:	8ec080e7          	jalr	-1812(ra) # 5e42 <fork>
    455e:	84aa                	mv	s1,a0
    if(pid1 < 0){
    4560:	02054f63          	bltz	a0,459e <killstatus+0x60>
    if(pid1 == 0){
    4564:	c939                	beqz	a0,45ba <killstatus+0x7c>
    sleep(1);
    4566:	4505                	li	a0,1
    4568:	00002097          	auipc	ra,0x2
    456c:	972080e7          	jalr	-1678(ra) # 5eda <sleep>
    kill(pid1);
    4570:	8526                	mv	a0,s1
    4572:	00002097          	auipc	ra,0x2
    4576:	908080e7          	jalr	-1784(ra) # 5e7a <kill>
    wait(&xst);
    457a:	fcc40513          	addi	a0,s0,-52
    457e:	00002097          	auipc	ra,0x2
    4582:	8d4080e7          	jalr	-1836(ra) # 5e52 <wait>
    if(xst != -1) {
    4586:	fcc42783          	lw	a5,-52(s0)
    458a:	03379d63          	bne	a5,s3,45c4 <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    458e:	397d                	addiw	s2,s2,-1
    4590:	fc0913e3          	bnez	s2,4556 <killstatus+0x18>
  exit(0);
    4594:	4501                	li	a0,0
    4596:	00002097          	auipc	ra,0x2
    459a:	8b4080e7          	jalr	-1868(ra) # 5e4a <exit>
      printf("%s: fork failed\n", s);
    459e:	85d2                	mv	a1,s4
    45a0:	00003517          	auipc	a0,0x3
    45a4:	a5050513          	addi	a0,a0,-1456 # 6ff0 <uthread_self+0x916>
    45a8:	00002097          	auipc	ra,0x2
    45ac:	c42080e7          	jalr	-958(ra) # 61ea <printf>
      exit(1);
    45b0:	4505                	li	a0,1
    45b2:	00002097          	auipc	ra,0x2
    45b6:	898080e7          	jalr	-1896(ra) # 5e4a <exit>
        getpid();
    45ba:	00002097          	auipc	ra,0x2
    45be:	910080e7          	jalr	-1776(ra) # 5eca <getpid>
      while(1) {
    45c2:	bfe5                	j	45ba <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    45c4:	85d2                	mv	a1,s4
    45c6:	00004517          	auipc	a0,0x4
    45ca:	d1a50513          	addi	a0,a0,-742 # 82e0 <uthread_self+0x1c06>
    45ce:	00002097          	auipc	ra,0x2
    45d2:	c1c080e7          	jalr	-996(ra) # 61ea <printf>
       exit(1);
    45d6:	4505                	li	a0,1
    45d8:	00002097          	auipc	ra,0x2
    45dc:	872080e7          	jalr	-1934(ra) # 5e4a <exit>

00000000000045e0 <preempt>:
{
    45e0:	7139                	addi	sp,sp,-64
    45e2:	fc06                	sd	ra,56(sp)
    45e4:	f822                	sd	s0,48(sp)
    45e6:	f426                	sd	s1,40(sp)
    45e8:	f04a                	sd	s2,32(sp)
    45ea:	ec4e                	sd	s3,24(sp)
    45ec:	e852                	sd	s4,16(sp)
    45ee:	0080                	addi	s0,sp,64
    45f0:	892a                	mv	s2,a0
  pid1 = fork();
    45f2:	00002097          	auipc	ra,0x2
    45f6:	850080e7          	jalr	-1968(ra) # 5e42 <fork>
  if(pid1 < 0) {
    45fa:	00054563          	bltz	a0,4604 <preempt+0x24>
    45fe:	84aa                	mv	s1,a0
  if(pid1 == 0)
    4600:	e105                	bnez	a0,4620 <preempt+0x40>
    for(;;)
    4602:	a001                	j	4602 <preempt+0x22>
    printf("%s: fork failed", s);
    4604:	85ca                	mv	a1,s2
    4606:	00003517          	auipc	a0,0x3
    460a:	baa50513          	addi	a0,a0,-1110 # 71b0 <uthread_self+0xad6>
    460e:	00002097          	auipc	ra,0x2
    4612:	bdc080e7          	jalr	-1060(ra) # 61ea <printf>
    exit(1);
    4616:	4505                	li	a0,1
    4618:	00002097          	auipc	ra,0x2
    461c:	832080e7          	jalr	-1998(ra) # 5e4a <exit>
  pid2 = fork();
    4620:	00002097          	auipc	ra,0x2
    4624:	822080e7          	jalr	-2014(ra) # 5e42 <fork>
    4628:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    462a:	00054463          	bltz	a0,4632 <preempt+0x52>
  if(pid2 == 0)
    462e:	e105                	bnez	a0,464e <preempt+0x6e>
    for(;;)
    4630:	a001                	j	4630 <preempt+0x50>
    printf("%s: fork failed\n", s);
    4632:	85ca                	mv	a1,s2
    4634:	00003517          	auipc	a0,0x3
    4638:	9bc50513          	addi	a0,a0,-1604 # 6ff0 <uthread_self+0x916>
    463c:	00002097          	auipc	ra,0x2
    4640:	bae080e7          	jalr	-1106(ra) # 61ea <printf>
    exit(1);
    4644:	4505                	li	a0,1
    4646:	00002097          	auipc	ra,0x2
    464a:	804080e7          	jalr	-2044(ra) # 5e4a <exit>
  pipe(pfds);
    464e:	fc840513          	addi	a0,s0,-56
    4652:	00002097          	auipc	ra,0x2
    4656:	808080e7          	jalr	-2040(ra) # 5e5a <pipe>
  pid3 = fork();
    465a:	00001097          	auipc	ra,0x1
    465e:	7e8080e7          	jalr	2024(ra) # 5e42 <fork>
    4662:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    4664:	02054e63          	bltz	a0,46a0 <preempt+0xc0>
  if(pid3 == 0){
    4668:	e525                	bnez	a0,46d0 <preempt+0xf0>
    close(pfds[0]);
    466a:	fc842503          	lw	a0,-56(s0)
    466e:	00002097          	auipc	ra,0x2
    4672:	804080e7          	jalr	-2044(ra) # 5e72 <close>
    if(write(pfds[1], "x", 1) != 1)
    4676:	4605                	li	a2,1
    4678:	00002597          	auipc	a1,0x2
    467c:	14058593          	addi	a1,a1,320 # 67b8 <uthread_self+0xde>
    4680:	fcc42503          	lw	a0,-52(s0)
    4684:	00001097          	auipc	ra,0x1
    4688:	7e6080e7          	jalr	2022(ra) # 5e6a <write>
    468c:	4785                	li	a5,1
    468e:	02f51763          	bne	a0,a5,46bc <preempt+0xdc>
    close(pfds[1]);
    4692:	fcc42503          	lw	a0,-52(s0)
    4696:	00001097          	auipc	ra,0x1
    469a:	7dc080e7          	jalr	2012(ra) # 5e72 <close>
    for(;;)
    469e:	a001                	j	469e <preempt+0xbe>
     printf("%s: fork failed\n", s);
    46a0:	85ca                	mv	a1,s2
    46a2:	00003517          	auipc	a0,0x3
    46a6:	94e50513          	addi	a0,a0,-1714 # 6ff0 <uthread_self+0x916>
    46aa:	00002097          	auipc	ra,0x2
    46ae:	b40080e7          	jalr	-1216(ra) # 61ea <printf>
     exit(1);
    46b2:	4505                	li	a0,1
    46b4:	00001097          	auipc	ra,0x1
    46b8:	796080e7          	jalr	1942(ra) # 5e4a <exit>
      printf("%s: preempt write error", s);
    46bc:	85ca                	mv	a1,s2
    46be:	00004517          	auipc	a0,0x4
    46c2:	c4250513          	addi	a0,a0,-958 # 8300 <uthread_self+0x1c26>
    46c6:	00002097          	auipc	ra,0x2
    46ca:	b24080e7          	jalr	-1244(ra) # 61ea <printf>
    46ce:	b7d1                	j	4692 <preempt+0xb2>
  close(pfds[1]);
    46d0:	fcc42503          	lw	a0,-52(s0)
    46d4:	00001097          	auipc	ra,0x1
    46d8:	79e080e7          	jalr	1950(ra) # 5e72 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    46dc:	660d                	lui	a2,0x3
    46de:	00008597          	auipc	a1,0x8
    46e2:	5ca58593          	addi	a1,a1,1482 # cca8 <buf>
    46e6:	fc842503          	lw	a0,-56(s0)
    46ea:	00001097          	auipc	ra,0x1
    46ee:	778080e7          	jalr	1912(ra) # 5e62 <read>
    46f2:	4785                	li	a5,1
    46f4:	02f50363          	beq	a0,a5,471a <preempt+0x13a>
    printf("%s: preempt read error", s);
    46f8:	85ca                	mv	a1,s2
    46fa:	00004517          	auipc	a0,0x4
    46fe:	c1e50513          	addi	a0,a0,-994 # 8318 <uthread_self+0x1c3e>
    4702:	00002097          	auipc	ra,0x2
    4706:	ae8080e7          	jalr	-1304(ra) # 61ea <printf>
}
    470a:	70e2                	ld	ra,56(sp)
    470c:	7442                	ld	s0,48(sp)
    470e:	74a2                	ld	s1,40(sp)
    4710:	7902                	ld	s2,32(sp)
    4712:	69e2                	ld	s3,24(sp)
    4714:	6a42                	ld	s4,16(sp)
    4716:	6121                	addi	sp,sp,64
    4718:	8082                	ret
  close(pfds[0]);
    471a:	fc842503          	lw	a0,-56(s0)
    471e:	00001097          	auipc	ra,0x1
    4722:	754080e7          	jalr	1876(ra) # 5e72 <close>
  printf("kill... ");
    4726:	00004517          	auipc	a0,0x4
    472a:	c0a50513          	addi	a0,a0,-1014 # 8330 <uthread_self+0x1c56>
    472e:	00002097          	auipc	ra,0x2
    4732:	abc080e7          	jalr	-1348(ra) # 61ea <printf>
  kill(pid1);
    4736:	8526                	mv	a0,s1
    4738:	00001097          	auipc	ra,0x1
    473c:	742080e7          	jalr	1858(ra) # 5e7a <kill>
  kill(pid2);
    4740:	854e                	mv	a0,s3
    4742:	00001097          	auipc	ra,0x1
    4746:	738080e7          	jalr	1848(ra) # 5e7a <kill>
  kill(pid3);
    474a:	8552                	mv	a0,s4
    474c:	00001097          	auipc	ra,0x1
    4750:	72e080e7          	jalr	1838(ra) # 5e7a <kill>
  printf("wait... ");
    4754:	00004517          	auipc	a0,0x4
    4758:	bec50513          	addi	a0,a0,-1044 # 8340 <uthread_self+0x1c66>
    475c:	00002097          	auipc	ra,0x2
    4760:	a8e080e7          	jalr	-1394(ra) # 61ea <printf>
  wait(0);
    4764:	4501                	li	a0,0
    4766:	00001097          	auipc	ra,0x1
    476a:	6ec080e7          	jalr	1772(ra) # 5e52 <wait>
  wait(0);
    476e:	4501                	li	a0,0
    4770:	00001097          	auipc	ra,0x1
    4774:	6e2080e7          	jalr	1762(ra) # 5e52 <wait>
  wait(0);
    4778:	4501                	li	a0,0
    477a:	00001097          	auipc	ra,0x1
    477e:	6d8080e7          	jalr	1752(ra) # 5e52 <wait>
    4782:	b761                	j	470a <preempt+0x12a>

0000000000004784 <reparent>:
{
    4784:	7179                	addi	sp,sp,-48
    4786:	f406                	sd	ra,40(sp)
    4788:	f022                	sd	s0,32(sp)
    478a:	ec26                	sd	s1,24(sp)
    478c:	e84a                	sd	s2,16(sp)
    478e:	e44e                	sd	s3,8(sp)
    4790:	e052                	sd	s4,0(sp)
    4792:	1800                	addi	s0,sp,48
    4794:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4796:	00001097          	auipc	ra,0x1
    479a:	734080e7          	jalr	1844(ra) # 5eca <getpid>
    479e:	8a2a                	mv	s4,a0
    47a0:	0c800913          	li	s2,200
    int pid = fork();
    47a4:	00001097          	auipc	ra,0x1
    47a8:	69e080e7          	jalr	1694(ra) # 5e42 <fork>
    47ac:	84aa                	mv	s1,a0
    if(pid < 0){
    47ae:	02054263          	bltz	a0,47d2 <reparent+0x4e>
    if(pid){
    47b2:	cd21                	beqz	a0,480a <reparent+0x86>
      if(wait(0) != pid){
    47b4:	4501                	li	a0,0
    47b6:	00001097          	auipc	ra,0x1
    47ba:	69c080e7          	jalr	1692(ra) # 5e52 <wait>
    47be:	02951863          	bne	a0,s1,47ee <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    47c2:	397d                	addiw	s2,s2,-1
    47c4:	fe0910e3          	bnez	s2,47a4 <reparent+0x20>
  exit(0);
    47c8:	4501                	li	a0,0
    47ca:	00001097          	auipc	ra,0x1
    47ce:	680080e7          	jalr	1664(ra) # 5e4a <exit>
      printf("%s: fork failed\n", s);
    47d2:	85ce                	mv	a1,s3
    47d4:	00003517          	auipc	a0,0x3
    47d8:	81c50513          	addi	a0,a0,-2020 # 6ff0 <uthread_self+0x916>
    47dc:	00002097          	auipc	ra,0x2
    47e0:	a0e080e7          	jalr	-1522(ra) # 61ea <printf>
      exit(1);
    47e4:	4505                	li	a0,1
    47e6:	00001097          	auipc	ra,0x1
    47ea:	664080e7          	jalr	1636(ra) # 5e4a <exit>
        printf("%s: wait wrong pid\n", s);
    47ee:	85ce                	mv	a1,s3
    47f0:	00003517          	auipc	a0,0x3
    47f4:	98850513          	addi	a0,a0,-1656 # 7178 <uthread_self+0xa9e>
    47f8:	00002097          	auipc	ra,0x2
    47fc:	9f2080e7          	jalr	-1550(ra) # 61ea <printf>
        exit(1);
    4800:	4505                	li	a0,1
    4802:	00001097          	auipc	ra,0x1
    4806:	648080e7          	jalr	1608(ra) # 5e4a <exit>
      int pid2 = fork();
    480a:	00001097          	auipc	ra,0x1
    480e:	638080e7          	jalr	1592(ra) # 5e42 <fork>
      if(pid2 < 0){
    4812:	00054763          	bltz	a0,4820 <reparent+0x9c>
      exit(0);
    4816:	4501                	li	a0,0
    4818:	00001097          	auipc	ra,0x1
    481c:	632080e7          	jalr	1586(ra) # 5e4a <exit>
        kill(master_pid);
    4820:	8552                	mv	a0,s4
    4822:	00001097          	auipc	ra,0x1
    4826:	658080e7          	jalr	1624(ra) # 5e7a <kill>
        exit(1);
    482a:	4505                	li	a0,1
    482c:	00001097          	auipc	ra,0x1
    4830:	61e080e7          	jalr	1566(ra) # 5e4a <exit>

0000000000004834 <sbrkfail>:
{
    4834:	7119                	addi	sp,sp,-128
    4836:	fc86                	sd	ra,120(sp)
    4838:	f8a2                	sd	s0,112(sp)
    483a:	f4a6                	sd	s1,104(sp)
    483c:	f0ca                	sd	s2,96(sp)
    483e:	ecce                	sd	s3,88(sp)
    4840:	e8d2                	sd	s4,80(sp)
    4842:	e4d6                	sd	s5,72(sp)
    4844:	0100                	addi	s0,sp,128
    4846:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    4848:	fb040513          	addi	a0,s0,-80
    484c:	00001097          	auipc	ra,0x1
    4850:	60e080e7          	jalr	1550(ra) # 5e5a <pipe>
    4854:	e901                	bnez	a0,4864 <sbrkfail+0x30>
    4856:	f8040493          	addi	s1,s0,-128
    485a:	fa840993          	addi	s3,s0,-88
    485e:	8926                	mv	s2,s1
    if(pids[i] != -1)
    4860:	5a7d                	li	s4,-1
    4862:	a085                	j	48c2 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    4864:	85d6                	mv	a1,s5
    4866:	00003517          	auipc	a0,0x3
    486a:	89250513          	addi	a0,a0,-1902 # 70f8 <uthread_self+0xa1e>
    486e:	00002097          	auipc	ra,0x2
    4872:	97c080e7          	jalr	-1668(ra) # 61ea <printf>
    exit(1);
    4876:	4505                	li	a0,1
    4878:	00001097          	auipc	ra,0x1
    487c:	5d2080e7          	jalr	1490(ra) # 5e4a <exit>
      sbrk(BIG - (uint64)sbrk(0));
    4880:	00001097          	auipc	ra,0x1
    4884:	652080e7          	jalr	1618(ra) # 5ed2 <sbrk>
    4888:	064007b7          	lui	a5,0x6400
    488c:	40a7853b          	subw	a0,a5,a0
    4890:	00001097          	auipc	ra,0x1
    4894:	642080e7          	jalr	1602(ra) # 5ed2 <sbrk>
      write(fds[1], "x", 1);
    4898:	4605                	li	a2,1
    489a:	00002597          	auipc	a1,0x2
    489e:	f1e58593          	addi	a1,a1,-226 # 67b8 <uthread_self+0xde>
    48a2:	fb442503          	lw	a0,-76(s0)
    48a6:	00001097          	auipc	ra,0x1
    48aa:	5c4080e7          	jalr	1476(ra) # 5e6a <write>
      for(;;) sleep(1000);
    48ae:	3e800513          	li	a0,1000
    48b2:	00001097          	auipc	ra,0x1
    48b6:	628080e7          	jalr	1576(ra) # 5eda <sleep>
    48ba:	bfd5                	j	48ae <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    48bc:	0911                	addi	s2,s2,4
    48be:	03390563          	beq	s2,s3,48e8 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    48c2:	00001097          	auipc	ra,0x1
    48c6:	580080e7          	jalr	1408(ra) # 5e42 <fork>
    48ca:	00a92023          	sw	a0,0(s2)
    48ce:	d94d                	beqz	a0,4880 <sbrkfail+0x4c>
    if(pids[i] != -1)
    48d0:	ff4506e3          	beq	a0,s4,48bc <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    48d4:	4605                	li	a2,1
    48d6:	faf40593          	addi	a1,s0,-81
    48da:	fb042503          	lw	a0,-80(s0)
    48de:	00001097          	auipc	ra,0x1
    48e2:	584080e7          	jalr	1412(ra) # 5e62 <read>
    48e6:	bfd9                	j	48bc <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    48e8:	6505                	lui	a0,0x1
    48ea:	00001097          	auipc	ra,0x1
    48ee:	5e8080e7          	jalr	1512(ra) # 5ed2 <sbrk>
    48f2:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    48f4:	597d                	li	s2,-1
    48f6:	a021                	j	48fe <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    48f8:	0491                	addi	s1,s1,4
    48fa:	01348f63          	beq	s1,s3,4918 <sbrkfail+0xe4>
    if(pids[i] == -1)
    48fe:	4088                	lw	a0,0(s1)
    4900:	ff250ce3          	beq	a0,s2,48f8 <sbrkfail+0xc4>
    kill(pids[i]);
    4904:	00001097          	auipc	ra,0x1
    4908:	576080e7          	jalr	1398(ra) # 5e7a <kill>
    wait(0);
    490c:	4501                	li	a0,0
    490e:	00001097          	auipc	ra,0x1
    4912:	544080e7          	jalr	1348(ra) # 5e52 <wait>
    4916:	b7cd                	j	48f8 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4918:	57fd                	li	a5,-1
    491a:	04fa0163          	beq	s4,a5,495c <sbrkfail+0x128>
  pid = fork();
    491e:	00001097          	auipc	ra,0x1
    4922:	524080e7          	jalr	1316(ra) # 5e42 <fork>
    4926:	84aa                	mv	s1,a0
  if(pid < 0){
    4928:	04054863          	bltz	a0,4978 <sbrkfail+0x144>
  if(pid == 0){
    492c:	c525                	beqz	a0,4994 <sbrkfail+0x160>
  wait(&xstatus);
    492e:	fbc40513          	addi	a0,s0,-68
    4932:	00001097          	auipc	ra,0x1
    4936:	520080e7          	jalr	1312(ra) # 5e52 <wait>
  if(xstatus != -1 && xstatus != 2)
    493a:	fbc42783          	lw	a5,-68(s0)
    493e:	577d                	li	a4,-1
    4940:	00e78563          	beq	a5,a4,494a <sbrkfail+0x116>
    4944:	4709                	li	a4,2
    4946:	08e79d63          	bne	a5,a4,49e0 <sbrkfail+0x1ac>
}
    494a:	70e6                	ld	ra,120(sp)
    494c:	7446                	ld	s0,112(sp)
    494e:	74a6                	ld	s1,104(sp)
    4950:	7906                	ld	s2,96(sp)
    4952:	69e6                	ld	s3,88(sp)
    4954:	6a46                	ld	s4,80(sp)
    4956:	6aa6                	ld	s5,72(sp)
    4958:	6109                	addi	sp,sp,128
    495a:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    495c:	85d6                	mv	a1,s5
    495e:	00004517          	auipc	a0,0x4
    4962:	9f250513          	addi	a0,a0,-1550 # 8350 <uthread_self+0x1c76>
    4966:	00002097          	auipc	ra,0x2
    496a:	884080e7          	jalr	-1916(ra) # 61ea <printf>
    exit(1);
    496e:	4505                	li	a0,1
    4970:	00001097          	auipc	ra,0x1
    4974:	4da080e7          	jalr	1242(ra) # 5e4a <exit>
    printf("%s: fork failed\n", s);
    4978:	85d6                	mv	a1,s5
    497a:	00002517          	auipc	a0,0x2
    497e:	67650513          	addi	a0,a0,1654 # 6ff0 <uthread_self+0x916>
    4982:	00002097          	auipc	ra,0x2
    4986:	868080e7          	jalr	-1944(ra) # 61ea <printf>
    exit(1);
    498a:	4505                	li	a0,1
    498c:	00001097          	auipc	ra,0x1
    4990:	4be080e7          	jalr	1214(ra) # 5e4a <exit>
    a = sbrk(0);
    4994:	4501                	li	a0,0
    4996:	00001097          	auipc	ra,0x1
    499a:	53c080e7          	jalr	1340(ra) # 5ed2 <sbrk>
    499e:	892a                	mv	s2,a0
    sbrk(10*BIG);
    49a0:	3e800537          	lui	a0,0x3e800
    49a4:	00001097          	auipc	ra,0x1
    49a8:	52e080e7          	jalr	1326(ra) # 5ed2 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    49ac:	87ca                	mv	a5,s2
    49ae:	3e800737          	lui	a4,0x3e800
    49b2:	993a                	add	s2,s2,a4
    49b4:	6705                	lui	a4,0x1
      n += *(a+i);
    49b6:	0007c683          	lbu	a3,0(a5) # 6400000 <uthreads_arr+0x63f02d8>
    49ba:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    49bc:	97ba                	add	a5,a5,a4
    49be:	ff279ce3          	bne	a5,s2,49b6 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    49c2:	8626                	mv	a2,s1
    49c4:	85d6                	mv	a1,s5
    49c6:	00004517          	auipc	a0,0x4
    49ca:	9aa50513          	addi	a0,a0,-1622 # 8370 <uthread_self+0x1c96>
    49ce:	00002097          	auipc	ra,0x2
    49d2:	81c080e7          	jalr	-2020(ra) # 61ea <printf>
    exit(1);
    49d6:	4505                	li	a0,1
    49d8:	00001097          	auipc	ra,0x1
    49dc:	472080e7          	jalr	1138(ra) # 5e4a <exit>
    exit(1);
    49e0:	4505                	li	a0,1
    49e2:	00001097          	auipc	ra,0x1
    49e6:	468080e7          	jalr	1128(ra) # 5e4a <exit>

00000000000049ea <mem>:
{
    49ea:	7139                	addi	sp,sp,-64
    49ec:	fc06                	sd	ra,56(sp)
    49ee:	f822                	sd	s0,48(sp)
    49f0:	f426                	sd	s1,40(sp)
    49f2:	f04a                	sd	s2,32(sp)
    49f4:	ec4e                	sd	s3,24(sp)
    49f6:	0080                	addi	s0,sp,64
    49f8:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    49fa:	00001097          	auipc	ra,0x1
    49fe:	448080e7          	jalr	1096(ra) # 5e42 <fork>
    m1 = 0;
    4a02:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4a04:	6909                	lui	s2,0x2
    4a06:	71190913          	addi	s2,s2,1809 # 2711 <copyinstr3+0xdd>
  if((pid = fork()) == 0){
    4a0a:	c115                	beqz	a0,4a2e <mem+0x44>
    wait(&xstatus);
    4a0c:	fcc40513          	addi	a0,s0,-52
    4a10:	00001097          	auipc	ra,0x1
    4a14:	442080e7          	jalr	1090(ra) # 5e52 <wait>
    if(xstatus == -1){
    4a18:	fcc42503          	lw	a0,-52(s0)
    4a1c:	57fd                	li	a5,-1
    4a1e:	06f50363          	beq	a0,a5,4a84 <mem+0x9a>
    exit(xstatus);
    4a22:	00001097          	auipc	ra,0x1
    4a26:	428080e7          	jalr	1064(ra) # 5e4a <exit>
      *(char**)m2 = m1;
    4a2a:	e104                	sd	s1,0(a0)
      m1 = m2;
    4a2c:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    4a2e:	854a                	mv	a0,s2
    4a30:	00002097          	auipc	ra,0x2
    4a34:	878080e7          	jalr	-1928(ra) # 62a8 <malloc>
    4a38:	f96d                	bnez	a0,4a2a <mem+0x40>
    while(m1){
    4a3a:	c881                	beqz	s1,4a4a <mem+0x60>
      m2 = *(char**)m1;
    4a3c:	8526                	mv	a0,s1
    4a3e:	6084                	ld	s1,0(s1)
      free(m1);
    4a40:	00001097          	auipc	ra,0x1
    4a44:	7e0080e7          	jalr	2016(ra) # 6220 <free>
    while(m1){
    4a48:	f8f5                	bnez	s1,4a3c <mem+0x52>
    m1 = malloc(1024*20);
    4a4a:	6515                	lui	a0,0x5
    4a4c:	00002097          	auipc	ra,0x2
    4a50:	85c080e7          	jalr	-1956(ra) # 62a8 <malloc>
    if(m1 == 0){
    4a54:	c911                	beqz	a0,4a68 <mem+0x7e>
    free(m1);
    4a56:	00001097          	auipc	ra,0x1
    4a5a:	7ca080e7          	jalr	1994(ra) # 6220 <free>
    exit(0);
    4a5e:	4501                	li	a0,0
    4a60:	00001097          	auipc	ra,0x1
    4a64:	3ea080e7          	jalr	1002(ra) # 5e4a <exit>
      printf("couldn't allocate mem?!!\n", s);
    4a68:	85ce                	mv	a1,s3
    4a6a:	00004517          	auipc	a0,0x4
    4a6e:	93650513          	addi	a0,a0,-1738 # 83a0 <uthread_self+0x1cc6>
    4a72:	00001097          	auipc	ra,0x1
    4a76:	778080e7          	jalr	1912(ra) # 61ea <printf>
      exit(1);
    4a7a:	4505                	li	a0,1
    4a7c:	00001097          	auipc	ra,0x1
    4a80:	3ce080e7          	jalr	974(ra) # 5e4a <exit>
      exit(0);
    4a84:	4501                	li	a0,0
    4a86:	00001097          	auipc	ra,0x1
    4a8a:	3c4080e7          	jalr	964(ra) # 5e4a <exit>

0000000000004a8e <sharedfd>:
{
    4a8e:	7159                	addi	sp,sp,-112
    4a90:	f486                	sd	ra,104(sp)
    4a92:	f0a2                	sd	s0,96(sp)
    4a94:	eca6                	sd	s1,88(sp)
    4a96:	e8ca                	sd	s2,80(sp)
    4a98:	e4ce                	sd	s3,72(sp)
    4a9a:	e0d2                	sd	s4,64(sp)
    4a9c:	fc56                	sd	s5,56(sp)
    4a9e:	f85a                	sd	s6,48(sp)
    4aa0:	f45e                	sd	s7,40(sp)
    4aa2:	1880                	addi	s0,sp,112
    4aa4:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4aa6:	00004517          	auipc	a0,0x4
    4aaa:	91a50513          	addi	a0,a0,-1766 # 83c0 <uthread_self+0x1ce6>
    4aae:	00001097          	auipc	ra,0x1
    4ab2:	3ec080e7          	jalr	1004(ra) # 5e9a <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4ab6:	20200593          	li	a1,514
    4aba:	00004517          	auipc	a0,0x4
    4abe:	90650513          	addi	a0,a0,-1786 # 83c0 <uthread_self+0x1ce6>
    4ac2:	00001097          	auipc	ra,0x1
    4ac6:	3c8080e7          	jalr	968(ra) # 5e8a <open>
  if(fd < 0){
    4aca:	04054a63          	bltz	a0,4b1e <sharedfd+0x90>
    4ace:	892a                	mv	s2,a0
  pid = fork();
    4ad0:	00001097          	auipc	ra,0x1
    4ad4:	372080e7          	jalr	882(ra) # 5e42 <fork>
    4ad8:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4ada:	06300593          	li	a1,99
    4ade:	c119                	beqz	a0,4ae4 <sharedfd+0x56>
    4ae0:	07000593          	li	a1,112
    4ae4:	4629                	li	a2,10
    4ae6:	fa040513          	addi	a0,s0,-96
    4aea:	00001097          	auipc	ra,0x1
    4aee:	164080e7          	jalr	356(ra) # 5c4e <memset>
    4af2:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    4af6:	4629                	li	a2,10
    4af8:	fa040593          	addi	a1,s0,-96
    4afc:	854a                	mv	a0,s2
    4afe:	00001097          	auipc	ra,0x1
    4b02:	36c080e7          	jalr	876(ra) # 5e6a <write>
    4b06:	47a9                	li	a5,10
    4b08:	02f51963          	bne	a0,a5,4b3a <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4b0c:	34fd                	addiw	s1,s1,-1
    4b0e:	f4e5                	bnez	s1,4af6 <sharedfd+0x68>
  if(pid == 0) {
    4b10:	04099363          	bnez	s3,4b56 <sharedfd+0xc8>
    exit(0);
    4b14:	4501                	li	a0,0
    4b16:	00001097          	auipc	ra,0x1
    4b1a:	334080e7          	jalr	820(ra) # 5e4a <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4b1e:	85d2                	mv	a1,s4
    4b20:	00004517          	auipc	a0,0x4
    4b24:	8b050513          	addi	a0,a0,-1872 # 83d0 <uthread_self+0x1cf6>
    4b28:	00001097          	auipc	ra,0x1
    4b2c:	6c2080e7          	jalr	1730(ra) # 61ea <printf>
    exit(1);
    4b30:	4505                	li	a0,1
    4b32:	00001097          	auipc	ra,0x1
    4b36:	318080e7          	jalr	792(ra) # 5e4a <exit>
      printf("%s: write sharedfd failed\n", s);
    4b3a:	85d2                	mv	a1,s4
    4b3c:	00004517          	auipc	a0,0x4
    4b40:	8bc50513          	addi	a0,a0,-1860 # 83f8 <uthread_self+0x1d1e>
    4b44:	00001097          	auipc	ra,0x1
    4b48:	6a6080e7          	jalr	1702(ra) # 61ea <printf>
      exit(1);
    4b4c:	4505                	li	a0,1
    4b4e:	00001097          	auipc	ra,0x1
    4b52:	2fc080e7          	jalr	764(ra) # 5e4a <exit>
    wait(&xstatus);
    4b56:	f9c40513          	addi	a0,s0,-100
    4b5a:	00001097          	auipc	ra,0x1
    4b5e:	2f8080e7          	jalr	760(ra) # 5e52 <wait>
    if(xstatus != 0)
    4b62:	f9c42983          	lw	s3,-100(s0)
    4b66:	00098763          	beqz	s3,4b74 <sharedfd+0xe6>
      exit(xstatus);
    4b6a:	854e                	mv	a0,s3
    4b6c:	00001097          	auipc	ra,0x1
    4b70:	2de080e7          	jalr	734(ra) # 5e4a <exit>
  close(fd);
    4b74:	854a                	mv	a0,s2
    4b76:	00001097          	auipc	ra,0x1
    4b7a:	2fc080e7          	jalr	764(ra) # 5e72 <close>
  fd = open("sharedfd", 0);
    4b7e:	4581                	li	a1,0
    4b80:	00004517          	auipc	a0,0x4
    4b84:	84050513          	addi	a0,a0,-1984 # 83c0 <uthread_self+0x1ce6>
    4b88:	00001097          	auipc	ra,0x1
    4b8c:	302080e7          	jalr	770(ra) # 5e8a <open>
    4b90:	8baa                	mv	s7,a0
  nc = np = 0;
    4b92:	8ace                	mv	s5,s3
  if(fd < 0){
    4b94:	02054563          	bltz	a0,4bbe <sharedfd+0x130>
    4b98:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4b9c:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4ba0:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4ba4:	4629                	li	a2,10
    4ba6:	fa040593          	addi	a1,s0,-96
    4baa:	855e                	mv	a0,s7
    4bac:	00001097          	auipc	ra,0x1
    4bb0:	2b6080e7          	jalr	694(ra) # 5e62 <read>
    4bb4:	02a05f63          	blez	a0,4bf2 <sharedfd+0x164>
    4bb8:	fa040793          	addi	a5,s0,-96
    4bbc:	a01d                	j	4be2 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4bbe:	85d2                	mv	a1,s4
    4bc0:	00004517          	auipc	a0,0x4
    4bc4:	85850513          	addi	a0,a0,-1960 # 8418 <uthread_self+0x1d3e>
    4bc8:	00001097          	auipc	ra,0x1
    4bcc:	622080e7          	jalr	1570(ra) # 61ea <printf>
    exit(1);
    4bd0:	4505                	li	a0,1
    4bd2:	00001097          	auipc	ra,0x1
    4bd6:	278080e7          	jalr	632(ra) # 5e4a <exit>
        nc++;
    4bda:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    4bdc:	0785                	addi	a5,a5,1
    4bde:	fd2783e3          	beq	a5,s2,4ba4 <sharedfd+0x116>
      if(buf[i] == 'c')
    4be2:	0007c703          	lbu	a4,0(a5)
    4be6:	fe970ae3          	beq	a4,s1,4bda <sharedfd+0x14c>
      if(buf[i] == 'p')
    4bea:	ff6719e3          	bne	a4,s6,4bdc <sharedfd+0x14e>
        np++;
    4bee:	2a85                	addiw	s5,s5,1
    4bf0:	b7f5                	j	4bdc <sharedfd+0x14e>
  close(fd);
    4bf2:	855e                	mv	a0,s7
    4bf4:	00001097          	auipc	ra,0x1
    4bf8:	27e080e7          	jalr	638(ra) # 5e72 <close>
  unlink("sharedfd");
    4bfc:	00003517          	auipc	a0,0x3
    4c00:	7c450513          	addi	a0,a0,1988 # 83c0 <uthread_self+0x1ce6>
    4c04:	00001097          	auipc	ra,0x1
    4c08:	296080e7          	jalr	662(ra) # 5e9a <unlink>
  if(nc == N*SZ && np == N*SZ){
    4c0c:	6789                	lui	a5,0x2
    4c0e:	71078793          	addi	a5,a5,1808 # 2710 <copyinstr3+0xdc>
    4c12:	00f99763          	bne	s3,a5,4c20 <sharedfd+0x192>
    4c16:	6789                	lui	a5,0x2
    4c18:	71078793          	addi	a5,a5,1808 # 2710 <copyinstr3+0xdc>
    4c1c:	02fa8063          	beq	s5,a5,4c3c <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4c20:	85d2                	mv	a1,s4
    4c22:	00004517          	auipc	a0,0x4
    4c26:	81e50513          	addi	a0,a0,-2018 # 8440 <uthread_self+0x1d66>
    4c2a:	00001097          	auipc	ra,0x1
    4c2e:	5c0080e7          	jalr	1472(ra) # 61ea <printf>
    exit(1);
    4c32:	4505                	li	a0,1
    4c34:	00001097          	auipc	ra,0x1
    4c38:	216080e7          	jalr	534(ra) # 5e4a <exit>
    exit(0);
    4c3c:	4501                	li	a0,0
    4c3e:	00001097          	auipc	ra,0x1
    4c42:	20c080e7          	jalr	524(ra) # 5e4a <exit>

0000000000004c46 <fourfiles>:
{
    4c46:	7171                	addi	sp,sp,-176
    4c48:	f506                	sd	ra,168(sp)
    4c4a:	f122                	sd	s0,160(sp)
    4c4c:	ed26                	sd	s1,152(sp)
    4c4e:	e94a                	sd	s2,144(sp)
    4c50:	e54e                	sd	s3,136(sp)
    4c52:	e152                	sd	s4,128(sp)
    4c54:	fcd6                	sd	s5,120(sp)
    4c56:	f8da                	sd	s6,112(sp)
    4c58:	f4de                	sd	s7,104(sp)
    4c5a:	f0e2                	sd	s8,96(sp)
    4c5c:	ece6                	sd	s9,88(sp)
    4c5e:	e8ea                	sd	s10,80(sp)
    4c60:	e4ee                	sd	s11,72(sp)
    4c62:	1900                	addi	s0,sp,176
    4c64:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    4c68:	00002797          	auipc	a5,0x2
    4c6c:	a8878793          	addi	a5,a5,-1400 # 66f0 <uthread_self+0x16>
    4c70:	f6f43823          	sd	a5,-144(s0)
    4c74:	00002797          	auipc	a5,0x2
    4c78:	a8478793          	addi	a5,a5,-1404 # 66f8 <uthread_self+0x1e>
    4c7c:	f6f43c23          	sd	a5,-136(s0)
    4c80:	00002797          	auipc	a5,0x2
    4c84:	a8078793          	addi	a5,a5,-1408 # 6700 <uthread_self+0x26>
    4c88:	f8f43023          	sd	a5,-128(s0)
    4c8c:	00002797          	auipc	a5,0x2
    4c90:	a7c78793          	addi	a5,a5,-1412 # 6708 <uthread_self+0x2e>
    4c94:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4c98:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4c9c:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    4c9e:	4481                	li	s1,0
    4ca0:	4a11                	li	s4,4
    fname = names[pi];
    4ca2:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4ca6:	854e                	mv	a0,s3
    4ca8:	00001097          	auipc	ra,0x1
    4cac:	1f2080e7          	jalr	498(ra) # 5e9a <unlink>
    pid = fork();
    4cb0:	00001097          	auipc	ra,0x1
    4cb4:	192080e7          	jalr	402(ra) # 5e42 <fork>
    if(pid < 0){
    4cb8:	04054463          	bltz	a0,4d00 <fourfiles+0xba>
    if(pid == 0){
    4cbc:	c12d                	beqz	a0,4d1e <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    4cbe:	2485                	addiw	s1,s1,1
    4cc0:	0921                	addi	s2,s2,8
    4cc2:	ff4490e3          	bne	s1,s4,4ca2 <fourfiles+0x5c>
    4cc6:	4491                	li	s1,4
    wait(&xstatus);
    4cc8:	f6c40513          	addi	a0,s0,-148
    4ccc:	00001097          	auipc	ra,0x1
    4cd0:	186080e7          	jalr	390(ra) # 5e52 <wait>
    if(xstatus != 0)
    4cd4:	f6c42b03          	lw	s6,-148(s0)
    4cd8:	0c0b1e63          	bnez	s6,4db4 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    4cdc:	34fd                	addiw	s1,s1,-1
    4cde:	f4ed                	bnez	s1,4cc8 <fourfiles+0x82>
    4ce0:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4ce4:	00008a17          	auipc	s4,0x8
    4ce8:	fc4a0a13          	addi	s4,s4,-60 # cca8 <buf>
    4cec:	00008a97          	auipc	s5,0x8
    4cf0:	fbda8a93          	addi	s5,s5,-67 # cca9 <buf+0x1>
    if(total != N*SZ){
    4cf4:	6d85                	lui	s11,0x1
    4cf6:	770d8d93          	addi	s11,s11,1904 # 1770 <exectest+0x8>
  for(i = 0; i < NCHILD; i++){
    4cfa:	03400d13          	li	s10,52
    4cfe:	aa1d                	j	4e34 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    4d00:	f5843583          	ld	a1,-168(s0)
    4d04:	00002517          	auipc	a0,0x2
    4d08:	6f450513          	addi	a0,a0,1780 # 73f8 <uthread_self+0xd1e>
    4d0c:	00001097          	auipc	ra,0x1
    4d10:	4de080e7          	jalr	1246(ra) # 61ea <printf>
      exit(1);
    4d14:	4505                	li	a0,1
    4d16:	00001097          	auipc	ra,0x1
    4d1a:	134080e7          	jalr	308(ra) # 5e4a <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4d1e:	20200593          	li	a1,514
    4d22:	854e                	mv	a0,s3
    4d24:	00001097          	auipc	ra,0x1
    4d28:	166080e7          	jalr	358(ra) # 5e8a <open>
    4d2c:	892a                	mv	s2,a0
      if(fd < 0){
    4d2e:	04054763          	bltz	a0,4d7c <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    4d32:	1f400613          	li	a2,500
    4d36:	0304859b          	addiw	a1,s1,48
    4d3a:	00008517          	auipc	a0,0x8
    4d3e:	f6e50513          	addi	a0,a0,-146 # cca8 <buf>
    4d42:	00001097          	auipc	ra,0x1
    4d46:	f0c080e7          	jalr	-244(ra) # 5c4e <memset>
    4d4a:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4d4c:	00008997          	auipc	s3,0x8
    4d50:	f5c98993          	addi	s3,s3,-164 # cca8 <buf>
    4d54:	1f400613          	li	a2,500
    4d58:	85ce                	mv	a1,s3
    4d5a:	854a                	mv	a0,s2
    4d5c:	00001097          	auipc	ra,0x1
    4d60:	10e080e7          	jalr	270(ra) # 5e6a <write>
    4d64:	85aa                	mv	a1,a0
    4d66:	1f400793          	li	a5,500
    4d6a:	02f51863          	bne	a0,a5,4d9a <fourfiles+0x154>
      for(i = 0; i < N; i++){
    4d6e:	34fd                	addiw	s1,s1,-1
    4d70:	f0f5                	bnez	s1,4d54 <fourfiles+0x10e>
      exit(0);
    4d72:	4501                	li	a0,0
    4d74:	00001097          	auipc	ra,0x1
    4d78:	0d6080e7          	jalr	214(ra) # 5e4a <exit>
        printf("create failed\n", s);
    4d7c:	f5843583          	ld	a1,-168(s0)
    4d80:	00004517          	auipc	a0,0x4
    4d84:	93850513          	addi	a0,a0,-1736 # 86b8 <uthread_self+0x1fde>
    4d88:	00001097          	auipc	ra,0x1
    4d8c:	462080e7          	jalr	1122(ra) # 61ea <printf>
        exit(1);
    4d90:	4505                	li	a0,1
    4d92:	00001097          	auipc	ra,0x1
    4d96:	0b8080e7          	jalr	184(ra) # 5e4a <exit>
          printf("write failed %d\n", n);
    4d9a:	00003517          	auipc	a0,0x3
    4d9e:	6be50513          	addi	a0,a0,1726 # 8458 <uthread_self+0x1d7e>
    4da2:	00001097          	auipc	ra,0x1
    4da6:	448080e7          	jalr	1096(ra) # 61ea <printf>
          exit(1);
    4daa:	4505                	li	a0,1
    4dac:	00001097          	auipc	ra,0x1
    4db0:	09e080e7          	jalr	158(ra) # 5e4a <exit>
      exit(xstatus);
    4db4:	855a                	mv	a0,s6
    4db6:	00001097          	auipc	ra,0x1
    4dba:	094080e7          	jalr	148(ra) # 5e4a <exit>
          printf("wrong char\n", s);
    4dbe:	f5843583          	ld	a1,-168(s0)
    4dc2:	00003517          	auipc	a0,0x3
    4dc6:	6ae50513          	addi	a0,a0,1710 # 8470 <uthread_self+0x1d96>
    4dca:	00001097          	auipc	ra,0x1
    4dce:	420080e7          	jalr	1056(ra) # 61ea <printf>
          exit(1);
    4dd2:	4505                	li	a0,1
    4dd4:	00001097          	auipc	ra,0x1
    4dd8:	076080e7          	jalr	118(ra) # 5e4a <exit>
      total += n;
    4ddc:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4de0:	660d                	lui	a2,0x3
    4de2:	85d2                	mv	a1,s4
    4de4:	854e                	mv	a0,s3
    4de6:	00001097          	auipc	ra,0x1
    4dea:	07c080e7          	jalr	124(ra) # 5e62 <read>
    4dee:	02a05363          	blez	a0,4e14 <fourfiles+0x1ce>
    4df2:	00008797          	auipc	a5,0x8
    4df6:	eb678793          	addi	a5,a5,-330 # cca8 <buf>
    4dfa:	fff5069b          	addiw	a3,a0,-1
    4dfe:	1682                	slli	a3,a3,0x20
    4e00:	9281                	srli	a3,a3,0x20
    4e02:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    4e04:	0007c703          	lbu	a4,0(a5)
    4e08:	fa971be3          	bne	a4,s1,4dbe <fourfiles+0x178>
      for(j = 0; j < n; j++){
    4e0c:	0785                	addi	a5,a5,1
    4e0e:	fed79be3          	bne	a5,a3,4e04 <fourfiles+0x1be>
    4e12:	b7e9                	j	4ddc <fourfiles+0x196>
    close(fd);
    4e14:	854e                	mv	a0,s3
    4e16:	00001097          	auipc	ra,0x1
    4e1a:	05c080e7          	jalr	92(ra) # 5e72 <close>
    if(total != N*SZ){
    4e1e:	03b91863          	bne	s2,s11,4e4e <fourfiles+0x208>
    unlink(fname);
    4e22:	8566                	mv	a0,s9
    4e24:	00001097          	auipc	ra,0x1
    4e28:	076080e7          	jalr	118(ra) # 5e9a <unlink>
  for(i = 0; i < NCHILD; i++){
    4e2c:	0c21                	addi	s8,s8,8
    4e2e:	2b85                	addiw	s7,s7,1
    4e30:	03ab8d63          	beq	s7,s10,4e6a <fourfiles+0x224>
    fname = names[i];
    4e34:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    4e38:	4581                	li	a1,0
    4e3a:	8566                	mv	a0,s9
    4e3c:	00001097          	auipc	ra,0x1
    4e40:	04e080e7          	jalr	78(ra) # 5e8a <open>
    4e44:	89aa                	mv	s3,a0
    total = 0;
    4e46:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    4e48:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4e4c:	bf51                	j	4de0 <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    4e4e:	85ca                	mv	a1,s2
    4e50:	00003517          	auipc	a0,0x3
    4e54:	63050513          	addi	a0,a0,1584 # 8480 <uthread_self+0x1da6>
    4e58:	00001097          	auipc	ra,0x1
    4e5c:	392080e7          	jalr	914(ra) # 61ea <printf>
      exit(1);
    4e60:	4505                	li	a0,1
    4e62:	00001097          	auipc	ra,0x1
    4e66:	fe8080e7          	jalr	-24(ra) # 5e4a <exit>
}
    4e6a:	70aa                	ld	ra,168(sp)
    4e6c:	740a                	ld	s0,160(sp)
    4e6e:	64ea                	ld	s1,152(sp)
    4e70:	694a                	ld	s2,144(sp)
    4e72:	69aa                	ld	s3,136(sp)
    4e74:	6a0a                	ld	s4,128(sp)
    4e76:	7ae6                	ld	s5,120(sp)
    4e78:	7b46                	ld	s6,112(sp)
    4e7a:	7ba6                	ld	s7,104(sp)
    4e7c:	7c06                	ld	s8,96(sp)
    4e7e:	6ce6                	ld	s9,88(sp)
    4e80:	6d46                	ld	s10,80(sp)
    4e82:	6da6                	ld	s11,72(sp)
    4e84:	614d                	addi	sp,sp,176
    4e86:	8082                	ret

0000000000004e88 <concreate>:
{
    4e88:	7135                	addi	sp,sp,-160
    4e8a:	ed06                	sd	ra,152(sp)
    4e8c:	e922                	sd	s0,144(sp)
    4e8e:	e526                	sd	s1,136(sp)
    4e90:	e14a                	sd	s2,128(sp)
    4e92:	fcce                	sd	s3,120(sp)
    4e94:	f8d2                	sd	s4,112(sp)
    4e96:	f4d6                	sd	s5,104(sp)
    4e98:	f0da                	sd	s6,96(sp)
    4e9a:	ecde                	sd	s7,88(sp)
    4e9c:	1100                	addi	s0,sp,160
    4e9e:	89aa                	mv	s3,a0
  file[0] = 'C';
    4ea0:	04300793          	li	a5,67
    4ea4:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4ea8:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4eac:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4eae:	4b0d                	li	s6,3
    4eb0:	4a85                	li	s5,1
      link("C0", file);
    4eb2:	00003b97          	auipc	s7,0x3
    4eb6:	5e6b8b93          	addi	s7,s7,1510 # 8498 <uthread_self+0x1dbe>
  for(i = 0; i < N; i++){
    4eba:	02800a13          	li	s4,40
    4ebe:	acc1                	j	518e <concreate+0x306>
      link("C0", file);
    4ec0:	fa840593          	addi	a1,s0,-88
    4ec4:	855e                	mv	a0,s7
    4ec6:	00001097          	auipc	ra,0x1
    4eca:	fe4080e7          	jalr	-28(ra) # 5eaa <link>
    if(pid == 0) {
    4ece:	a45d                	j	5174 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    4ed0:	4795                	li	a5,5
    4ed2:	02f9693b          	remw	s2,s2,a5
    4ed6:	4785                	li	a5,1
    4ed8:	02f90b63          	beq	s2,a5,4f0e <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4edc:	20200593          	li	a1,514
    4ee0:	fa840513          	addi	a0,s0,-88
    4ee4:	00001097          	auipc	ra,0x1
    4ee8:	fa6080e7          	jalr	-90(ra) # 5e8a <open>
      if(fd < 0){
    4eec:	26055b63          	bgez	a0,5162 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    4ef0:	fa840593          	addi	a1,s0,-88
    4ef4:	00003517          	auipc	a0,0x3
    4ef8:	5ac50513          	addi	a0,a0,1452 # 84a0 <uthread_self+0x1dc6>
    4efc:	00001097          	auipc	ra,0x1
    4f00:	2ee080e7          	jalr	750(ra) # 61ea <printf>
        exit(1);
    4f04:	4505                	li	a0,1
    4f06:	00001097          	auipc	ra,0x1
    4f0a:	f44080e7          	jalr	-188(ra) # 5e4a <exit>
      link("C0", file);
    4f0e:	fa840593          	addi	a1,s0,-88
    4f12:	00003517          	auipc	a0,0x3
    4f16:	58650513          	addi	a0,a0,1414 # 8498 <uthread_self+0x1dbe>
    4f1a:	00001097          	auipc	ra,0x1
    4f1e:	f90080e7          	jalr	-112(ra) # 5eaa <link>
      exit(0);
    4f22:	4501                	li	a0,0
    4f24:	00001097          	auipc	ra,0x1
    4f28:	f26080e7          	jalr	-218(ra) # 5e4a <exit>
        exit(1);
    4f2c:	4505                	li	a0,1
    4f2e:	00001097          	auipc	ra,0x1
    4f32:	f1c080e7          	jalr	-228(ra) # 5e4a <exit>
  memset(fa, 0, sizeof(fa));
    4f36:	02800613          	li	a2,40
    4f3a:	4581                	li	a1,0
    4f3c:	f8040513          	addi	a0,s0,-128
    4f40:	00001097          	auipc	ra,0x1
    4f44:	d0e080e7          	jalr	-754(ra) # 5c4e <memset>
  fd = open(".", 0);
    4f48:	4581                	li	a1,0
    4f4a:	00002517          	auipc	a0,0x2
    4f4e:	f0650513          	addi	a0,a0,-250 # 6e50 <uthread_self+0x776>
    4f52:	00001097          	auipc	ra,0x1
    4f56:	f38080e7          	jalr	-200(ra) # 5e8a <open>
    4f5a:	892a                	mv	s2,a0
  n = 0;
    4f5c:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4f5e:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4f62:	02700b13          	li	s6,39
      fa[i] = 1;
    4f66:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4f68:	4641                	li	a2,16
    4f6a:	f7040593          	addi	a1,s0,-144
    4f6e:	854a                	mv	a0,s2
    4f70:	00001097          	auipc	ra,0x1
    4f74:	ef2080e7          	jalr	-270(ra) # 5e62 <read>
    4f78:	08a05163          	blez	a0,4ffa <concreate+0x172>
    if(de.inum == 0)
    4f7c:	f7045783          	lhu	a5,-144(s0)
    4f80:	d7e5                	beqz	a5,4f68 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4f82:	f7244783          	lbu	a5,-142(s0)
    4f86:	ff4791e3          	bne	a5,s4,4f68 <concreate+0xe0>
    4f8a:	f7444783          	lbu	a5,-140(s0)
    4f8e:	ffe9                	bnez	a5,4f68 <concreate+0xe0>
      i = de.name[1] - '0';
    4f90:	f7344783          	lbu	a5,-141(s0)
    4f94:	fd07879b          	addiw	a5,a5,-48
    4f98:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4f9c:	00eb6f63          	bltu	s6,a4,4fba <concreate+0x132>
      if(fa[i]){
    4fa0:	fb040793          	addi	a5,s0,-80
    4fa4:	97ba                	add	a5,a5,a4
    4fa6:	fd07c783          	lbu	a5,-48(a5)
    4faa:	eb85                	bnez	a5,4fda <concreate+0x152>
      fa[i] = 1;
    4fac:	fb040793          	addi	a5,s0,-80
    4fb0:	973e                	add	a4,a4,a5
    4fb2:	fd770823          	sb	s7,-48(a4) # fd0 <linktest+0xb4>
      n++;
    4fb6:	2a85                	addiw	s5,s5,1
    4fb8:	bf45                	j	4f68 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4fba:	f7240613          	addi	a2,s0,-142
    4fbe:	85ce                	mv	a1,s3
    4fc0:	00003517          	auipc	a0,0x3
    4fc4:	50050513          	addi	a0,a0,1280 # 84c0 <uthread_self+0x1de6>
    4fc8:	00001097          	auipc	ra,0x1
    4fcc:	222080e7          	jalr	546(ra) # 61ea <printf>
        exit(1);
    4fd0:	4505                	li	a0,1
    4fd2:	00001097          	auipc	ra,0x1
    4fd6:	e78080e7          	jalr	-392(ra) # 5e4a <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4fda:	f7240613          	addi	a2,s0,-142
    4fde:	85ce                	mv	a1,s3
    4fe0:	00003517          	auipc	a0,0x3
    4fe4:	50050513          	addi	a0,a0,1280 # 84e0 <uthread_self+0x1e06>
    4fe8:	00001097          	auipc	ra,0x1
    4fec:	202080e7          	jalr	514(ra) # 61ea <printf>
        exit(1);
    4ff0:	4505                	li	a0,1
    4ff2:	00001097          	auipc	ra,0x1
    4ff6:	e58080e7          	jalr	-424(ra) # 5e4a <exit>
  close(fd);
    4ffa:	854a                	mv	a0,s2
    4ffc:	00001097          	auipc	ra,0x1
    5000:	e76080e7          	jalr	-394(ra) # 5e72 <close>
  if(n != N){
    5004:	02800793          	li	a5,40
    5008:	00fa9763          	bne	s5,a5,5016 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    500c:	4a8d                	li	s5,3
    500e:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    5010:	02800a13          	li	s4,40
    5014:	a8c9                	j	50e6 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    5016:	85ce                	mv	a1,s3
    5018:	00003517          	auipc	a0,0x3
    501c:	4f050513          	addi	a0,a0,1264 # 8508 <uthread_self+0x1e2e>
    5020:	00001097          	auipc	ra,0x1
    5024:	1ca080e7          	jalr	458(ra) # 61ea <printf>
    exit(1);
    5028:	4505                	li	a0,1
    502a:	00001097          	auipc	ra,0x1
    502e:	e20080e7          	jalr	-480(ra) # 5e4a <exit>
      printf("%s: fork failed\n", s);
    5032:	85ce                	mv	a1,s3
    5034:	00002517          	auipc	a0,0x2
    5038:	fbc50513          	addi	a0,a0,-68 # 6ff0 <uthread_self+0x916>
    503c:	00001097          	auipc	ra,0x1
    5040:	1ae080e7          	jalr	430(ra) # 61ea <printf>
      exit(1);
    5044:	4505                	li	a0,1
    5046:	00001097          	auipc	ra,0x1
    504a:	e04080e7          	jalr	-508(ra) # 5e4a <exit>
      close(open(file, 0));
    504e:	4581                	li	a1,0
    5050:	fa840513          	addi	a0,s0,-88
    5054:	00001097          	auipc	ra,0x1
    5058:	e36080e7          	jalr	-458(ra) # 5e8a <open>
    505c:	00001097          	auipc	ra,0x1
    5060:	e16080e7          	jalr	-490(ra) # 5e72 <close>
      close(open(file, 0));
    5064:	4581                	li	a1,0
    5066:	fa840513          	addi	a0,s0,-88
    506a:	00001097          	auipc	ra,0x1
    506e:	e20080e7          	jalr	-480(ra) # 5e8a <open>
    5072:	00001097          	auipc	ra,0x1
    5076:	e00080e7          	jalr	-512(ra) # 5e72 <close>
      close(open(file, 0));
    507a:	4581                	li	a1,0
    507c:	fa840513          	addi	a0,s0,-88
    5080:	00001097          	auipc	ra,0x1
    5084:	e0a080e7          	jalr	-502(ra) # 5e8a <open>
    5088:	00001097          	auipc	ra,0x1
    508c:	dea080e7          	jalr	-534(ra) # 5e72 <close>
      close(open(file, 0));
    5090:	4581                	li	a1,0
    5092:	fa840513          	addi	a0,s0,-88
    5096:	00001097          	auipc	ra,0x1
    509a:	df4080e7          	jalr	-524(ra) # 5e8a <open>
    509e:	00001097          	auipc	ra,0x1
    50a2:	dd4080e7          	jalr	-556(ra) # 5e72 <close>
      close(open(file, 0));
    50a6:	4581                	li	a1,0
    50a8:	fa840513          	addi	a0,s0,-88
    50ac:	00001097          	auipc	ra,0x1
    50b0:	dde080e7          	jalr	-546(ra) # 5e8a <open>
    50b4:	00001097          	auipc	ra,0x1
    50b8:	dbe080e7          	jalr	-578(ra) # 5e72 <close>
      close(open(file, 0));
    50bc:	4581                	li	a1,0
    50be:	fa840513          	addi	a0,s0,-88
    50c2:	00001097          	auipc	ra,0x1
    50c6:	dc8080e7          	jalr	-568(ra) # 5e8a <open>
    50ca:	00001097          	auipc	ra,0x1
    50ce:	da8080e7          	jalr	-600(ra) # 5e72 <close>
    if(pid == 0)
    50d2:	08090363          	beqz	s2,5158 <concreate+0x2d0>
      wait(0);
    50d6:	4501                	li	a0,0
    50d8:	00001097          	auipc	ra,0x1
    50dc:	d7a080e7          	jalr	-646(ra) # 5e52 <wait>
  for(i = 0; i < N; i++){
    50e0:	2485                	addiw	s1,s1,1
    50e2:	0f448563          	beq	s1,s4,51cc <concreate+0x344>
    file[1] = '0' + i;
    50e6:	0304879b          	addiw	a5,s1,48
    50ea:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    50ee:	00001097          	auipc	ra,0x1
    50f2:	d54080e7          	jalr	-684(ra) # 5e42 <fork>
    50f6:	892a                	mv	s2,a0
    if(pid < 0){
    50f8:	f2054de3          	bltz	a0,5032 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    50fc:	0354e73b          	remw	a4,s1,s5
    5100:	00a767b3          	or	a5,a4,a0
    5104:	2781                	sext.w	a5,a5
    5106:	d7a1                	beqz	a5,504e <concreate+0x1c6>
    5108:	01671363          	bne	a4,s6,510e <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    510c:	f129                	bnez	a0,504e <concreate+0x1c6>
      unlink(file);
    510e:	fa840513          	addi	a0,s0,-88
    5112:	00001097          	auipc	ra,0x1
    5116:	d88080e7          	jalr	-632(ra) # 5e9a <unlink>
      unlink(file);
    511a:	fa840513          	addi	a0,s0,-88
    511e:	00001097          	auipc	ra,0x1
    5122:	d7c080e7          	jalr	-644(ra) # 5e9a <unlink>
      unlink(file);
    5126:	fa840513          	addi	a0,s0,-88
    512a:	00001097          	auipc	ra,0x1
    512e:	d70080e7          	jalr	-656(ra) # 5e9a <unlink>
      unlink(file);
    5132:	fa840513          	addi	a0,s0,-88
    5136:	00001097          	auipc	ra,0x1
    513a:	d64080e7          	jalr	-668(ra) # 5e9a <unlink>
      unlink(file);
    513e:	fa840513          	addi	a0,s0,-88
    5142:	00001097          	auipc	ra,0x1
    5146:	d58080e7          	jalr	-680(ra) # 5e9a <unlink>
      unlink(file);
    514a:	fa840513          	addi	a0,s0,-88
    514e:	00001097          	auipc	ra,0x1
    5152:	d4c080e7          	jalr	-692(ra) # 5e9a <unlink>
    5156:	bfb5                	j	50d2 <concreate+0x24a>
      exit(0);
    5158:	4501                	li	a0,0
    515a:	00001097          	auipc	ra,0x1
    515e:	cf0080e7          	jalr	-784(ra) # 5e4a <exit>
      close(fd);
    5162:	00001097          	auipc	ra,0x1
    5166:	d10080e7          	jalr	-752(ra) # 5e72 <close>
    if(pid == 0) {
    516a:	bb65                	j	4f22 <concreate+0x9a>
      close(fd);
    516c:	00001097          	auipc	ra,0x1
    5170:	d06080e7          	jalr	-762(ra) # 5e72 <close>
      wait(&xstatus);
    5174:	f6c40513          	addi	a0,s0,-148
    5178:	00001097          	auipc	ra,0x1
    517c:	cda080e7          	jalr	-806(ra) # 5e52 <wait>
      if(xstatus != 0)
    5180:	f6c42483          	lw	s1,-148(s0)
    5184:	da0494e3          	bnez	s1,4f2c <concreate+0xa4>
  for(i = 0; i < N; i++){
    5188:	2905                	addiw	s2,s2,1
    518a:	db4906e3          	beq	s2,s4,4f36 <concreate+0xae>
    file[1] = '0' + i;
    518e:	0309079b          	addiw	a5,s2,48
    5192:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    5196:	fa840513          	addi	a0,s0,-88
    519a:	00001097          	auipc	ra,0x1
    519e:	d00080e7          	jalr	-768(ra) # 5e9a <unlink>
    pid = fork();
    51a2:	00001097          	auipc	ra,0x1
    51a6:	ca0080e7          	jalr	-864(ra) # 5e42 <fork>
    if(pid && (i % 3) == 1){
    51aa:	d20503e3          	beqz	a0,4ed0 <concreate+0x48>
    51ae:	036967bb          	remw	a5,s2,s6
    51b2:	d15787e3          	beq	a5,s5,4ec0 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    51b6:	20200593          	li	a1,514
    51ba:	fa840513          	addi	a0,s0,-88
    51be:	00001097          	auipc	ra,0x1
    51c2:	ccc080e7          	jalr	-820(ra) # 5e8a <open>
      if(fd < 0){
    51c6:	fa0553e3          	bgez	a0,516c <concreate+0x2e4>
    51ca:	b31d                	j	4ef0 <concreate+0x68>
}
    51cc:	60ea                	ld	ra,152(sp)
    51ce:	644a                	ld	s0,144(sp)
    51d0:	64aa                	ld	s1,136(sp)
    51d2:	690a                	ld	s2,128(sp)
    51d4:	79e6                	ld	s3,120(sp)
    51d6:	7a46                	ld	s4,112(sp)
    51d8:	7aa6                	ld	s5,104(sp)
    51da:	7b06                	ld	s6,96(sp)
    51dc:	6be6                	ld	s7,88(sp)
    51de:	610d                	addi	sp,sp,160
    51e0:	8082                	ret

00000000000051e2 <bigfile>:
{
    51e2:	7139                	addi	sp,sp,-64
    51e4:	fc06                	sd	ra,56(sp)
    51e6:	f822                	sd	s0,48(sp)
    51e8:	f426                	sd	s1,40(sp)
    51ea:	f04a                	sd	s2,32(sp)
    51ec:	ec4e                	sd	s3,24(sp)
    51ee:	e852                	sd	s4,16(sp)
    51f0:	e456                	sd	s5,8(sp)
    51f2:	0080                	addi	s0,sp,64
    51f4:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    51f6:	00003517          	auipc	a0,0x3
    51fa:	34a50513          	addi	a0,a0,842 # 8540 <uthread_self+0x1e66>
    51fe:	00001097          	auipc	ra,0x1
    5202:	c9c080e7          	jalr	-868(ra) # 5e9a <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    5206:	20200593          	li	a1,514
    520a:	00003517          	auipc	a0,0x3
    520e:	33650513          	addi	a0,a0,822 # 8540 <uthread_self+0x1e66>
    5212:	00001097          	auipc	ra,0x1
    5216:	c78080e7          	jalr	-904(ra) # 5e8a <open>
    521a:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    521c:	4481                	li	s1,0
    memset(buf, i, SZ);
    521e:	00008917          	auipc	s2,0x8
    5222:	a8a90913          	addi	s2,s2,-1398 # cca8 <buf>
  for(i = 0; i < N; i++){
    5226:	4a51                	li	s4,20
  if(fd < 0){
    5228:	0a054063          	bltz	a0,52c8 <bigfile+0xe6>
    memset(buf, i, SZ);
    522c:	25800613          	li	a2,600
    5230:	85a6                	mv	a1,s1
    5232:	854a                	mv	a0,s2
    5234:	00001097          	auipc	ra,0x1
    5238:	a1a080e7          	jalr	-1510(ra) # 5c4e <memset>
    if(write(fd, buf, SZ) != SZ){
    523c:	25800613          	li	a2,600
    5240:	85ca                	mv	a1,s2
    5242:	854e                	mv	a0,s3
    5244:	00001097          	auipc	ra,0x1
    5248:	c26080e7          	jalr	-986(ra) # 5e6a <write>
    524c:	25800793          	li	a5,600
    5250:	08f51a63          	bne	a0,a5,52e4 <bigfile+0x102>
  for(i = 0; i < N; i++){
    5254:	2485                	addiw	s1,s1,1
    5256:	fd449be3          	bne	s1,s4,522c <bigfile+0x4a>
  close(fd);
    525a:	854e                	mv	a0,s3
    525c:	00001097          	auipc	ra,0x1
    5260:	c16080e7          	jalr	-1002(ra) # 5e72 <close>
  fd = open("bigfile.dat", 0);
    5264:	4581                	li	a1,0
    5266:	00003517          	auipc	a0,0x3
    526a:	2da50513          	addi	a0,a0,730 # 8540 <uthread_self+0x1e66>
    526e:	00001097          	auipc	ra,0x1
    5272:	c1c080e7          	jalr	-996(ra) # 5e8a <open>
    5276:	8a2a                	mv	s4,a0
  total = 0;
    5278:	4981                	li	s3,0
  for(i = 0; ; i++){
    527a:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    527c:	00008917          	auipc	s2,0x8
    5280:	a2c90913          	addi	s2,s2,-1492 # cca8 <buf>
  if(fd < 0){
    5284:	06054e63          	bltz	a0,5300 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    5288:	12c00613          	li	a2,300
    528c:	85ca                	mv	a1,s2
    528e:	8552                	mv	a0,s4
    5290:	00001097          	auipc	ra,0x1
    5294:	bd2080e7          	jalr	-1070(ra) # 5e62 <read>
    if(cc < 0){
    5298:	08054263          	bltz	a0,531c <bigfile+0x13a>
    if(cc == 0)
    529c:	c971                	beqz	a0,5370 <bigfile+0x18e>
    if(cc != SZ/2){
    529e:	12c00793          	li	a5,300
    52a2:	08f51b63          	bne	a0,a5,5338 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    52a6:	01f4d79b          	srliw	a5,s1,0x1f
    52aa:	9fa5                	addw	a5,a5,s1
    52ac:	4017d79b          	sraiw	a5,a5,0x1
    52b0:	00094703          	lbu	a4,0(s2)
    52b4:	0af71063          	bne	a4,a5,5354 <bigfile+0x172>
    52b8:	12b94703          	lbu	a4,299(s2)
    52bc:	08f71c63          	bne	a4,a5,5354 <bigfile+0x172>
    total += cc;
    52c0:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    52c4:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    52c6:	b7c9                	j	5288 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    52c8:	85d6                	mv	a1,s5
    52ca:	00003517          	auipc	a0,0x3
    52ce:	28650513          	addi	a0,a0,646 # 8550 <uthread_self+0x1e76>
    52d2:	00001097          	auipc	ra,0x1
    52d6:	f18080e7          	jalr	-232(ra) # 61ea <printf>
    exit(1);
    52da:	4505                	li	a0,1
    52dc:	00001097          	auipc	ra,0x1
    52e0:	b6e080e7          	jalr	-1170(ra) # 5e4a <exit>
      printf("%s: write bigfile failed\n", s);
    52e4:	85d6                	mv	a1,s5
    52e6:	00003517          	auipc	a0,0x3
    52ea:	28a50513          	addi	a0,a0,650 # 8570 <uthread_self+0x1e96>
    52ee:	00001097          	auipc	ra,0x1
    52f2:	efc080e7          	jalr	-260(ra) # 61ea <printf>
      exit(1);
    52f6:	4505                	li	a0,1
    52f8:	00001097          	auipc	ra,0x1
    52fc:	b52080e7          	jalr	-1198(ra) # 5e4a <exit>
    printf("%s: cannot open bigfile\n", s);
    5300:	85d6                	mv	a1,s5
    5302:	00003517          	auipc	a0,0x3
    5306:	28e50513          	addi	a0,a0,654 # 8590 <uthread_self+0x1eb6>
    530a:	00001097          	auipc	ra,0x1
    530e:	ee0080e7          	jalr	-288(ra) # 61ea <printf>
    exit(1);
    5312:	4505                	li	a0,1
    5314:	00001097          	auipc	ra,0x1
    5318:	b36080e7          	jalr	-1226(ra) # 5e4a <exit>
      printf("%s: read bigfile failed\n", s);
    531c:	85d6                	mv	a1,s5
    531e:	00003517          	auipc	a0,0x3
    5322:	29250513          	addi	a0,a0,658 # 85b0 <uthread_self+0x1ed6>
    5326:	00001097          	auipc	ra,0x1
    532a:	ec4080e7          	jalr	-316(ra) # 61ea <printf>
      exit(1);
    532e:	4505                	li	a0,1
    5330:	00001097          	auipc	ra,0x1
    5334:	b1a080e7          	jalr	-1254(ra) # 5e4a <exit>
      printf("%s: short read bigfile\n", s);
    5338:	85d6                	mv	a1,s5
    533a:	00003517          	auipc	a0,0x3
    533e:	29650513          	addi	a0,a0,662 # 85d0 <uthread_self+0x1ef6>
    5342:	00001097          	auipc	ra,0x1
    5346:	ea8080e7          	jalr	-344(ra) # 61ea <printf>
      exit(1);
    534a:	4505                	li	a0,1
    534c:	00001097          	auipc	ra,0x1
    5350:	afe080e7          	jalr	-1282(ra) # 5e4a <exit>
      printf("%s: read bigfile wrong data\n", s);
    5354:	85d6                	mv	a1,s5
    5356:	00003517          	auipc	a0,0x3
    535a:	29250513          	addi	a0,a0,658 # 85e8 <uthread_self+0x1f0e>
    535e:	00001097          	auipc	ra,0x1
    5362:	e8c080e7          	jalr	-372(ra) # 61ea <printf>
      exit(1);
    5366:	4505                	li	a0,1
    5368:	00001097          	auipc	ra,0x1
    536c:	ae2080e7          	jalr	-1310(ra) # 5e4a <exit>
  close(fd);
    5370:	8552                	mv	a0,s4
    5372:	00001097          	auipc	ra,0x1
    5376:	b00080e7          	jalr	-1280(ra) # 5e72 <close>
  if(total != N*SZ){
    537a:	678d                	lui	a5,0x3
    537c:	ee078793          	addi	a5,a5,-288 # 2ee0 <sbrklast+0x62>
    5380:	02f99363          	bne	s3,a5,53a6 <bigfile+0x1c4>
  unlink("bigfile.dat");
    5384:	00003517          	auipc	a0,0x3
    5388:	1bc50513          	addi	a0,a0,444 # 8540 <uthread_self+0x1e66>
    538c:	00001097          	auipc	ra,0x1
    5390:	b0e080e7          	jalr	-1266(ra) # 5e9a <unlink>
}
    5394:	70e2                	ld	ra,56(sp)
    5396:	7442                	ld	s0,48(sp)
    5398:	74a2                	ld	s1,40(sp)
    539a:	7902                	ld	s2,32(sp)
    539c:	69e2                	ld	s3,24(sp)
    539e:	6a42                	ld	s4,16(sp)
    53a0:	6aa2                	ld	s5,8(sp)
    53a2:	6121                	addi	sp,sp,64
    53a4:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    53a6:	85d6                	mv	a1,s5
    53a8:	00003517          	auipc	a0,0x3
    53ac:	26050513          	addi	a0,a0,608 # 8608 <uthread_self+0x1f2e>
    53b0:	00001097          	auipc	ra,0x1
    53b4:	e3a080e7          	jalr	-454(ra) # 61ea <printf>
    exit(1);
    53b8:	4505                	li	a0,1
    53ba:	00001097          	auipc	ra,0x1
    53be:	a90080e7          	jalr	-1392(ra) # 5e4a <exit>

00000000000053c2 <uthread_a_start_func>:
void uthread_a_start_func(void){
    53c2:	1101                	addi	sp,sp,-32
    53c4:	ec06                	sd	ra,24(sp)
    53c6:	e822                	sd	s0,16(sp)
    53c8:	e426                	sd	s1,8(sp)
    53ca:	1000                	addi	s0,sp,32
  if(x != MEDIUM){
    53cc:	00004717          	auipc	a4,0x4
    53d0:	0a472703          	lw	a4,164(a4) # 9470 <x>
    53d4:	4785                	li	a5,1
    53d6:	00f70f63          	beq	a4,a5,53f4 <uthread_a_start_func+0x32>
    printf("sched policy failed\n");
    53da:	00003517          	auipc	a0,0x3
    53de:	24e50513          	addi	a0,a0,590 # 8628 <uthread_self+0x1f4e>
    53e2:	00001097          	auipc	ra,0x1
    53e6:	e08080e7          	jalr	-504(ra) # 61ea <printf>
    exit(1);
    53ea:	4505                	li	a0,1
    53ec:	00001097          	auipc	ra,0x1
    53f0:	a5e080e7          	jalr	-1442(ra) # 5e4a <exit>
  if(uthread_get_priority() != LOW){
    53f4:	00001097          	auipc	ra,0x1
    53f8:	210080e7          	jalr	528(ra) # 6604 <uthread_get_priority>
    53fc:	2501                	sext.w	a0,a0
    53fe:	44a9                	li	s1,10
    5400:	e90d                	bnez	a0,5432 <uthread_a_start_func+0x70>
    sleep(10); // simulate work
    5402:	4529                	li	a0,10
    5404:	00001097          	auipc	ra,0x1
    5408:	ad6080e7          	jalr	-1322(ra) # 5eda <sleep>
  for(int i=0; i<10; i++){
    540c:	34fd                	addiw	s1,s1,-1
    540e:	f8f5                	bnez	s1,5402 <uthread_a_start_func+0x40>
  uthread_exit();
    5410:	00001097          	auipc	ra,0x1
    5414:	fe6080e7          	jalr	-26(ra) # 63f6 <uthread_exit>
  printf("uthread_exit failed\n");
    5418:	00003517          	auipc	a0,0x3
    541c:	24850513          	addi	a0,a0,584 # 8660 <uthread_self+0x1f86>
    5420:	00001097          	auipc	ra,0x1
    5424:	dca080e7          	jalr	-566(ra) # 61ea <printf>
  exit(1);
    5428:	4505                	li	a0,1
    542a:	00001097          	auipc	ra,0x1
    542e:	a20080e7          	jalr	-1504(ra) # 5e4a <exit>
    printf("uthread_get_priority failed\n");
    5432:	00003517          	auipc	a0,0x3
    5436:	20e50513          	addi	a0,a0,526 # 8640 <uthread_self+0x1f66>
    543a:	00001097          	auipc	ra,0x1
    543e:	db0080e7          	jalr	-592(ra) # 61ea <printf>
    exit(1);
    5442:	4505                	li	a0,1
    5444:	00001097          	auipc	ra,0x1
    5448:	a06080e7          	jalr	-1530(ra) # 5e4a <exit>

000000000000544c <uthread_b_start_func>:
void uthread_b_start_func(void){
    544c:	1101                	addi	sp,sp,-32
    544e:	ec06                	sd	ra,24(sp)
    5450:	e822                	sd	s0,16(sp)
    5452:	e426                	sd	s1,8(sp)
    5454:	1000                	addi	s0,sp,32
    5456:	44a9                	li	s1,10
    sleep(10); // simulate work
    5458:	4529                	li	a0,10
    545a:	00001097          	auipc	ra,0x1
    545e:	a80080e7          	jalr	-1408(ra) # 5eda <sleep>
  for(int i=0; i<10; i++){
    5462:	34fd                	addiw	s1,s1,-1
    5464:	f8f5                	bnez	s1,5458 <uthread_b_start_func+0xc>
  x = uthread_get_priority();
    5466:	00001097          	auipc	ra,0x1
    546a:	19e080e7          	jalr	414(ra) # 6604 <uthread_get_priority>
    546e:	00004797          	auipc	a5,0x4
    5472:	00a7a123          	sw	a0,2(a5) # 9470 <x>
  uthread_exit();
    5476:	00001097          	auipc	ra,0x1
    547a:	f80080e7          	jalr	-128(ra) # 63f6 <uthread_exit>
  printf("uthread_exit failed\n");
    547e:	00003517          	auipc	a0,0x3
    5482:	1e250513          	addi	a0,a0,482 # 8660 <uthread_self+0x1f86>
    5486:	00001097          	auipc	ra,0x1
    548a:	d64080e7          	jalr	-668(ra) # 61ea <printf>
  exit(1);
    548e:	4505                	li	a0,1
    5490:	00001097          	auipc	ra,0x1
    5494:	9ba080e7          	jalr	-1606(ra) # 5e4a <exit>

0000000000005498 <ulttest>:
{
    5498:	1141                	addi	sp,sp,-16
    549a:	e406                	sd	ra,8(sp)
    549c:	e022                	sd	s0,0(sp)
    549e:	0800                	addi	s0,sp,16
  x = HIGH;
    54a0:	4789                	li	a5,2
    54a2:	00004717          	auipc	a4,0x4
    54a6:	fcf72723          	sw	a5,-50(a4) # 9470 <x>
  uthread_create(uthread_a_start_func, LOW);
    54aa:	4581                	li	a1,0
    54ac:	00000517          	auipc	a0,0x0
    54b0:	f1650513          	addi	a0,a0,-234 # 53c2 <uthread_a_start_func>
    54b4:	00001097          	auipc	ra,0x1
    54b8:	006080e7          	jalr	6(ra) # 64ba <uthread_create>
  uthread_create(uthread_b_start_func, MEDIUM);
    54bc:	4585                	li	a1,1
    54be:	00000517          	auipc	a0,0x0
    54c2:	f8e50513          	addi	a0,a0,-114 # 544c <uthread_b_start_func>
    54c6:	00001097          	auipc	ra,0x1
    54ca:	ff4080e7          	jalr	-12(ra) # 64ba <uthread_create>
  uthread_start_all();
    54ce:	00001097          	auipc	ra,0x1
    54d2:	150080e7          	jalr	336(ra) # 661e <uthread_start_all>
  printf("uthread_start_all failed\n");
    54d6:	00003517          	auipc	a0,0x3
    54da:	1a250513          	addi	a0,a0,418 # 8678 <uthread_self+0x1f9e>
    54de:	00001097          	auipc	ra,0x1
    54e2:	d0c080e7          	jalr	-756(ra) # 61ea <printf>
  exit(1);
    54e6:	4505                	li	a0,1
    54e8:	00001097          	auipc	ra,0x1
    54ec:	962080e7          	jalr	-1694(ra) # 5e4a <exit>

00000000000054f0 <kthread_start_func>:
void kthread_start_func(void){
    54f0:	1101                	addi	sp,sp,-32
    54f2:	ec06                	sd	ra,24(sp)
    54f4:	e822                	sd	s0,16(sp)
    54f6:	e426                	sd	s1,8(sp)
    54f8:	1000                	addi	s0,sp,32
    54fa:	44a9                	li	s1,10
    sleep(10); // simulate work
    54fc:	4529                	li	a0,10
    54fe:	00001097          	auipc	ra,0x1
    5502:	9dc080e7          	jalr	-1572(ra) # 5eda <sleep>
  for(int i=0; i<10; i++){
    5506:	34fd                	addiw	s1,s1,-1
    5508:	f8f5                	bnez	s1,54fc <kthread_start_func+0xc>
  kthread_exit(0);
    550a:	4501                	li	a0,0
    550c:	00001097          	auipc	ra,0x1
    5510:	9f6080e7          	jalr	-1546(ra) # 5f02 <kthread_exit>
  printf("kthread_exit failed\n");
    5514:	00003517          	auipc	a0,0x3
    5518:	18450513          	addi	a0,a0,388 # 8698 <uthread_self+0x1fbe>
    551c:	00001097          	auipc	ra,0x1
    5520:	cce080e7          	jalr	-818(ra) # 61ea <printf>
  exit(1);
    5524:	4505                	li	a0,1
    5526:	00001097          	auipc	ra,0x1
    552a:	924080e7          	jalr	-1756(ra) # 5e4a <exit>

000000000000552e <klttest>:
{
    552e:	7179                	addi	sp,sp,-48
    5530:	f406                	sd	ra,40(sp)
    5532:	f022                	sd	s0,32(sp)
    5534:	ec26                	sd	s1,24(sp)
    5536:	e84a                	sd	s2,16(sp)
    5538:	e44e                	sd	s3,8(sp)
    553a:	e052                	sd	s4,0(sp)
    553c:	1800                	addi	s0,sp,48
  uint64 stack_a = (uint64)malloc(STACK_SIZE);
    553e:	6485                	lui	s1,0x1
    5540:	fa048513          	addi	a0,s1,-96 # fa0 <linktest+0x84>
    5544:	00001097          	auipc	ra,0x1
    5548:	d64080e7          	jalr	-668(ra) # 62a8 <malloc>
    554c:	892a                	mv	s2,a0
  uint64 stack_b = (uint64)malloc(STACK_SIZE);
    554e:	fa048513          	addi	a0,s1,-96
    5552:	00001097          	auipc	ra,0x1
    5556:	d56080e7          	jalr	-682(ra) # 62a8 <malloc>
    555a:	89aa                	mv	s3,a0
  int kt_a = kthread_create((void *(*)())kthread_start_func,(void*) stack_a, STACK_SIZE);
    555c:	fa048613          	addi	a2,s1,-96
    5560:	85ca                	mv	a1,s2
    5562:	00000517          	auipc	a0,0x0
    5566:	f8e50513          	addi	a0,a0,-114 # 54f0 <kthread_start_func>
    556a:	00001097          	auipc	ra,0x1
    556e:	980080e7          	jalr	-1664(ra) # 5eea <kthread_create>
  if(kt_a <= 0){
    5572:	06a05063          	blez	a0,55d2 <klttest+0xa4>
    5576:	84aa                	mv	s1,a0
  int kt_b = kthread_create((void *(*)())kthread_start_func,(void*)  stack_b, STACK_SIZE);
    5578:	6605                	lui	a2,0x1
    557a:	fa060613          	addi	a2,a2,-96 # fa0 <linktest+0x84>
    557e:	85ce                	mv	a1,s3
    5580:	00000517          	auipc	a0,0x0
    5584:	f7050513          	addi	a0,a0,-144 # 54f0 <kthread_start_func>
    5588:	00001097          	auipc	ra,0x1
    558c:	962080e7          	jalr	-1694(ra) # 5eea <kthread_create>
    5590:	8a2a                	mv	s4,a0
  int joined = kthread_join(kt_a, 0);
    5592:	4581                	li	a1,0
    5594:	8526                	mv	a0,s1
    5596:	00001097          	auipc	ra,0x1
    559a:	974080e7          	jalr	-1676(ra) # 5f0a <kthread_join>
  if(joined != 0){
    559e:	e539                	bnez	a0,55ec <klttest+0xbe>
  joined = kthread_join(kt_b, 0);
    55a0:	4581                	li	a1,0
    55a2:	8552                	mv	a0,s4
    55a4:	00001097          	auipc	ra,0x1
    55a8:	966080e7          	jalr	-1690(ra) # 5f0a <kthread_join>
  if(joined != 0){
    55ac:	ed29                	bnez	a0,5606 <klttest+0xd8>
  free((void *)stack_a);
    55ae:	854a                	mv	a0,s2
    55b0:	00001097          	auipc	ra,0x1
    55b4:	c70080e7          	jalr	-912(ra) # 6220 <free>
  free((void *)stack_b);
    55b8:	854e                	mv	a0,s3
    55ba:	00001097          	auipc	ra,0x1
    55be:	c66080e7          	jalr	-922(ra) # 6220 <free>
}
    55c2:	70a2                	ld	ra,40(sp)
    55c4:	7402                	ld	s0,32(sp)
    55c6:	64e2                	ld	s1,24(sp)
    55c8:	6942                	ld	s2,16(sp)
    55ca:	69a2                	ld	s3,8(sp)
    55cc:	6a02                	ld	s4,0(sp)
    55ce:	6145                	addi	sp,sp,48
    55d0:	8082                	ret
    printf("kthread_create failed\n");
    55d2:	00003517          	auipc	a0,0x3
    55d6:	0de50513          	addi	a0,a0,222 # 86b0 <uthread_self+0x1fd6>
    55da:	00001097          	auipc	ra,0x1
    55de:	c10080e7          	jalr	-1008(ra) # 61ea <printf>
    exit(1);
    55e2:	4505                	li	a0,1
    55e4:	00001097          	auipc	ra,0x1
    55e8:	866080e7          	jalr	-1946(ra) # 5e4a <exit>
    printf("kthread_join failed\n");
    55ec:	00003517          	auipc	a0,0x3
    55f0:	0dc50513          	addi	a0,a0,220 # 86c8 <uthread_self+0x1fee>
    55f4:	00001097          	auipc	ra,0x1
    55f8:	bf6080e7          	jalr	-1034(ra) # 61ea <printf>
    exit(1);
    55fc:	4505                	li	a0,1
    55fe:	00001097          	auipc	ra,0x1
    5602:	84c080e7          	jalr	-1972(ra) # 5e4a <exit>
    printf("kthread_join failed\n");
    5606:	00003517          	auipc	a0,0x3
    560a:	0c250513          	addi	a0,a0,194 # 86c8 <uthread_self+0x1fee>
    560e:	00001097          	auipc	ra,0x1
    5612:	bdc080e7          	jalr	-1060(ra) # 61ea <printf>
    exit(1);
    5616:	4505                	li	a0,1
    5618:	00001097          	auipc	ra,0x1
    561c:	832080e7          	jalr	-1998(ra) # 5e4a <exit>

0000000000005620 <fsfull>:
{
    5620:	7171                	addi	sp,sp,-176
    5622:	f506                	sd	ra,168(sp)
    5624:	f122                	sd	s0,160(sp)
    5626:	ed26                	sd	s1,152(sp)
    5628:	e94a                	sd	s2,144(sp)
    562a:	e54e                	sd	s3,136(sp)
    562c:	e152                	sd	s4,128(sp)
    562e:	fcd6                	sd	s5,120(sp)
    5630:	f8da                	sd	s6,112(sp)
    5632:	f4de                	sd	s7,104(sp)
    5634:	f0e2                	sd	s8,96(sp)
    5636:	ece6                	sd	s9,88(sp)
    5638:	e8ea                	sd	s10,80(sp)
    563a:	e4ee                	sd	s11,72(sp)
    563c:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    563e:	00003517          	auipc	a0,0x3
    5642:	0a250513          	addi	a0,a0,162 # 86e0 <uthread_self+0x2006>
    5646:	00001097          	auipc	ra,0x1
    564a:	ba4080e7          	jalr	-1116(ra) # 61ea <printf>
  for(nfiles = 0; ; nfiles++){
    564e:	4481                	li	s1,0
    name[0] = 'f';
    5650:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    5654:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    5658:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    565c:	4b29                	li	s6,10
    printf("writing %s\n", name);
    565e:	00003c97          	auipc	s9,0x3
    5662:	092c8c93          	addi	s9,s9,146 # 86f0 <uthread_self+0x2016>
    int total = 0;
    5666:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    5668:	00007a17          	auipc	s4,0x7
    566c:	640a0a13          	addi	s4,s4,1600 # cca8 <buf>
    name[0] = 'f';
    5670:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    5674:	0384c7bb          	divw	a5,s1,s8
    5678:	0307879b          	addiw	a5,a5,48
    567c:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5680:	0384e7bb          	remw	a5,s1,s8
    5684:	0377c7bb          	divw	a5,a5,s7
    5688:	0307879b          	addiw	a5,a5,48
    568c:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5690:	0374e7bb          	remw	a5,s1,s7
    5694:	0367c7bb          	divw	a5,a5,s6
    5698:	0307879b          	addiw	a5,a5,48
    569c:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    56a0:	0364e7bb          	remw	a5,s1,s6
    56a4:	0307879b          	addiw	a5,a5,48
    56a8:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    56ac:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    56b0:	f5040593          	addi	a1,s0,-176
    56b4:	8566                	mv	a0,s9
    56b6:	00001097          	auipc	ra,0x1
    56ba:	b34080e7          	jalr	-1228(ra) # 61ea <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    56be:	20200593          	li	a1,514
    56c2:	f5040513          	addi	a0,s0,-176
    56c6:	00000097          	auipc	ra,0x0
    56ca:	7c4080e7          	jalr	1988(ra) # 5e8a <open>
    56ce:	892a                	mv	s2,a0
    if(fd < 0){
    56d0:	0a055663          	bgez	a0,577c <fsfull+0x15c>
      printf("open %s failed\n", name);
    56d4:	f5040593          	addi	a1,s0,-176
    56d8:	00003517          	auipc	a0,0x3
    56dc:	02850513          	addi	a0,a0,40 # 8700 <uthread_self+0x2026>
    56e0:	00001097          	auipc	ra,0x1
    56e4:	b0a080e7          	jalr	-1270(ra) # 61ea <printf>
  while(nfiles >= 0){
    56e8:	0604c363          	bltz	s1,574e <fsfull+0x12e>
    name[0] = 'f';
    56ec:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    56f0:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    56f4:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    56f8:	4929                	li	s2,10
  while(nfiles >= 0){
    56fa:	5afd                	li	s5,-1
    name[0] = 'f';
    56fc:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    5700:	0344c7bb          	divw	a5,s1,s4
    5704:	0307879b          	addiw	a5,a5,48
    5708:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    570c:	0344e7bb          	remw	a5,s1,s4
    5710:	0337c7bb          	divw	a5,a5,s3
    5714:	0307879b          	addiw	a5,a5,48
    5718:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    571c:	0334e7bb          	remw	a5,s1,s3
    5720:	0327c7bb          	divw	a5,a5,s2
    5724:	0307879b          	addiw	a5,a5,48
    5728:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    572c:	0324e7bb          	remw	a5,s1,s2
    5730:	0307879b          	addiw	a5,a5,48
    5734:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    5738:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    573c:	f5040513          	addi	a0,s0,-176
    5740:	00000097          	auipc	ra,0x0
    5744:	75a080e7          	jalr	1882(ra) # 5e9a <unlink>
    nfiles--;
    5748:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    574a:	fb5499e3          	bne	s1,s5,56fc <fsfull+0xdc>
  printf("fsfull test finished\n");
    574e:	00003517          	auipc	a0,0x3
    5752:	fd250513          	addi	a0,a0,-46 # 8720 <uthread_self+0x2046>
    5756:	00001097          	auipc	ra,0x1
    575a:	a94080e7          	jalr	-1388(ra) # 61ea <printf>
}
    575e:	70aa                	ld	ra,168(sp)
    5760:	740a                	ld	s0,160(sp)
    5762:	64ea                	ld	s1,152(sp)
    5764:	694a                	ld	s2,144(sp)
    5766:	69aa                	ld	s3,136(sp)
    5768:	6a0a                	ld	s4,128(sp)
    576a:	7ae6                	ld	s5,120(sp)
    576c:	7b46                	ld	s6,112(sp)
    576e:	7ba6                	ld	s7,104(sp)
    5770:	7c06                	ld	s8,96(sp)
    5772:	6ce6                	ld	s9,88(sp)
    5774:	6d46                	ld	s10,80(sp)
    5776:	6da6                	ld	s11,72(sp)
    5778:	614d                	addi	sp,sp,176
    577a:	8082                	ret
    int total = 0;
    577c:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    577e:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    5782:	40000613          	li	a2,1024
    5786:	85d2                	mv	a1,s4
    5788:	854a                	mv	a0,s2
    578a:	00000097          	auipc	ra,0x0
    578e:	6e0080e7          	jalr	1760(ra) # 5e6a <write>
      if(cc < BSIZE)
    5792:	00aad563          	bge	s5,a0,579c <fsfull+0x17c>
      total += cc;
    5796:	00a989bb          	addw	s3,s3,a0
    while(1){
    579a:	b7e5                	j	5782 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    579c:	85ce                	mv	a1,s3
    579e:	00003517          	auipc	a0,0x3
    57a2:	f7250513          	addi	a0,a0,-142 # 8710 <uthread_self+0x2036>
    57a6:	00001097          	auipc	ra,0x1
    57aa:	a44080e7          	jalr	-1468(ra) # 61ea <printf>
    close(fd);
    57ae:	854a                	mv	a0,s2
    57b0:	00000097          	auipc	ra,0x0
    57b4:	6c2080e7          	jalr	1730(ra) # 5e72 <close>
    if(total == 0)
    57b8:	f20988e3          	beqz	s3,56e8 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    57bc:	2485                	addiw	s1,s1,1
    57be:	bd4d                	j	5670 <fsfull+0x50>

00000000000057c0 <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    57c0:	7179                	addi	sp,sp,-48
    57c2:	f406                	sd	ra,40(sp)
    57c4:	f022                	sd	s0,32(sp)
    57c6:	ec26                	sd	s1,24(sp)
    57c8:	e84a                	sd	s2,16(sp)
    57ca:	1800                	addi	s0,sp,48
    57cc:	84aa                	mv	s1,a0
    57ce:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    57d0:	00003517          	auipc	a0,0x3
    57d4:	f6850513          	addi	a0,a0,-152 # 8738 <uthread_self+0x205e>
    57d8:	00001097          	auipc	ra,0x1
    57dc:	a12080e7          	jalr	-1518(ra) # 61ea <printf>
  if((pid = fork()) < 0) {
    57e0:	00000097          	auipc	ra,0x0
    57e4:	662080e7          	jalr	1634(ra) # 5e42 <fork>
    57e8:	02054e63          	bltz	a0,5824 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    57ec:	c929                	beqz	a0,583e <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    57ee:	fdc40513          	addi	a0,s0,-36
    57f2:	00000097          	auipc	ra,0x0
    57f6:	660080e7          	jalr	1632(ra) # 5e52 <wait>
    if(xstatus != 0) 
    57fa:	fdc42783          	lw	a5,-36(s0)
    57fe:	c7b9                	beqz	a5,584c <run+0x8c>
      printf("FAILED\n");
    5800:	00003517          	auipc	a0,0x3
    5804:	f6050513          	addi	a0,a0,-160 # 8760 <uthread_self+0x2086>
    5808:	00001097          	auipc	ra,0x1
    580c:	9e2080e7          	jalr	-1566(ra) # 61ea <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5810:	fdc42503          	lw	a0,-36(s0)
  }
}
    5814:	00153513          	seqz	a0,a0
    5818:	70a2                	ld	ra,40(sp)
    581a:	7402                	ld	s0,32(sp)
    581c:	64e2                	ld	s1,24(sp)
    581e:	6942                	ld	s2,16(sp)
    5820:	6145                	addi	sp,sp,48
    5822:	8082                	ret
    printf("runtest: fork error\n");
    5824:	00003517          	auipc	a0,0x3
    5828:	f2450513          	addi	a0,a0,-220 # 8748 <uthread_self+0x206e>
    582c:	00001097          	auipc	ra,0x1
    5830:	9be080e7          	jalr	-1602(ra) # 61ea <printf>
    exit(1);
    5834:	4505                	li	a0,1
    5836:	00000097          	auipc	ra,0x0
    583a:	614080e7          	jalr	1556(ra) # 5e4a <exit>
    f(s);
    583e:	854a                	mv	a0,s2
    5840:	9482                	jalr	s1
    exit(0);
    5842:	4501                	li	a0,0
    5844:	00000097          	auipc	ra,0x0
    5848:	606080e7          	jalr	1542(ra) # 5e4a <exit>
      printf("OK\n");
    584c:	00003517          	auipc	a0,0x3
    5850:	f1c50513          	addi	a0,a0,-228 # 8768 <uthread_self+0x208e>
    5854:	00001097          	auipc	ra,0x1
    5858:	996080e7          	jalr	-1642(ra) # 61ea <printf>
    585c:	bf55                	j	5810 <run+0x50>

000000000000585e <runtests>:

int
runtests(struct test *tests, char *justone) {
    585e:	1101                	addi	sp,sp,-32
    5860:	ec06                	sd	ra,24(sp)
    5862:	e822                	sd	s0,16(sp)
    5864:	e426                	sd	s1,8(sp)
    5866:	e04a                	sd	s2,0(sp)
    5868:	1000                	addi	s0,sp,32
    586a:	84aa                	mv	s1,a0
    586c:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++) {
    586e:	6508                	ld	a0,8(a0)
    5870:	ed09                	bnez	a0,588a <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    5872:	4501                	li	a0,0
    5874:	a82d                	j	58ae <runtests+0x50>
      if(!run(t->f, t->s)){
    5876:	648c                	ld	a1,8(s1)
    5878:	6088                	ld	a0,0(s1)
    587a:	00000097          	auipc	ra,0x0
    587e:	f46080e7          	jalr	-186(ra) # 57c0 <run>
    5882:	cd09                	beqz	a0,589c <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++) {
    5884:	04c1                	addi	s1,s1,16
    5886:	6488                	ld	a0,8(s1)
    5888:	c11d                	beqz	a0,58ae <runtests+0x50>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    588a:	fe0906e3          	beqz	s2,5876 <runtests+0x18>
    588e:	85ca                	mv	a1,s2
    5890:	00000097          	auipc	ra,0x0
    5894:	368080e7          	jalr	872(ra) # 5bf8 <strcmp>
    5898:	f575                	bnez	a0,5884 <runtests+0x26>
    589a:	bff1                	j	5876 <runtests+0x18>
        printf("SOME TESTS FAILED\n");
    589c:	00003517          	auipc	a0,0x3
    58a0:	ed450513          	addi	a0,a0,-300 # 8770 <uthread_self+0x2096>
    58a4:	00001097          	auipc	ra,0x1
    58a8:	946080e7          	jalr	-1722(ra) # 61ea <printf>
        return 1;
    58ac:	4505                	li	a0,1
}
    58ae:	60e2                	ld	ra,24(sp)
    58b0:	6442                	ld	s0,16(sp)
    58b2:	64a2                	ld	s1,8(sp)
    58b4:	6902                	ld	s2,0(sp)
    58b6:	6105                	addi	sp,sp,32
    58b8:	8082                	ret

00000000000058ba <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    58ba:	7139                	addi	sp,sp,-64
    58bc:	fc06                	sd	ra,56(sp)
    58be:	f822                	sd	s0,48(sp)
    58c0:	f426                	sd	s1,40(sp)
    58c2:	f04a                	sd	s2,32(sp)
    58c4:	ec4e                	sd	s3,24(sp)
    58c6:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    58c8:	fc840513          	addi	a0,s0,-56
    58cc:	00000097          	auipc	ra,0x0
    58d0:	58e080e7          	jalr	1422(ra) # 5e5a <pipe>
    58d4:	06054763          	bltz	a0,5942 <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    58d8:	00000097          	auipc	ra,0x0
    58dc:	56a080e7          	jalr	1386(ra) # 5e42 <fork>

  if(pid < 0){
    58e0:	06054e63          	bltz	a0,595c <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    58e4:	ed51                	bnez	a0,5980 <countfree+0xc6>
    close(fds[0]);
    58e6:	fc842503          	lw	a0,-56(s0)
    58ea:	00000097          	auipc	ra,0x0
    58ee:	588080e7          	jalr	1416(ra) # 5e72 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    58f2:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    58f4:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    58f6:	00001997          	auipc	s3,0x1
    58fa:	ec298993          	addi	s3,s3,-318 # 67b8 <uthread_self+0xde>
      uint64 a = (uint64) sbrk(4096);
    58fe:	6505                	lui	a0,0x1
    5900:	00000097          	auipc	ra,0x0
    5904:	5d2080e7          	jalr	1490(ra) # 5ed2 <sbrk>
      if(a == 0xffffffffffffffff){
    5908:	07250763          	beq	a0,s2,5976 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    590c:	6785                	lui	a5,0x1
    590e:	953e                	add	a0,a0,a5
    5910:	fe950fa3          	sb	s1,-1(a0) # fff <linktest+0xe3>
      if(write(fds[1], "x", 1) != 1){
    5914:	8626                	mv	a2,s1
    5916:	85ce                	mv	a1,s3
    5918:	fcc42503          	lw	a0,-52(s0)
    591c:	00000097          	auipc	ra,0x0
    5920:	54e080e7          	jalr	1358(ra) # 5e6a <write>
    5924:	fc950de3          	beq	a0,s1,58fe <countfree+0x44>
        printf("write() failed in countfree()\n");
    5928:	00003517          	auipc	a0,0x3
    592c:	ea050513          	addi	a0,a0,-352 # 87c8 <uthread_self+0x20ee>
    5930:	00001097          	auipc	ra,0x1
    5934:	8ba080e7          	jalr	-1862(ra) # 61ea <printf>
        exit(1);
    5938:	4505                	li	a0,1
    593a:	00000097          	auipc	ra,0x0
    593e:	510080e7          	jalr	1296(ra) # 5e4a <exit>
    printf("pipe() failed in countfree()\n");
    5942:	00003517          	auipc	a0,0x3
    5946:	e4650513          	addi	a0,a0,-442 # 8788 <uthread_self+0x20ae>
    594a:	00001097          	auipc	ra,0x1
    594e:	8a0080e7          	jalr	-1888(ra) # 61ea <printf>
    exit(1);
    5952:	4505                	li	a0,1
    5954:	00000097          	auipc	ra,0x0
    5958:	4f6080e7          	jalr	1270(ra) # 5e4a <exit>
    printf("fork failed in countfree()\n");
    595c:	00003517          	auipc	a0,0x3
    5960:	e4c50513          	addi	a0,a0,-436 # 87a8 <uthread_self+0x20ce>
    5964:	00001097          	auipc	ra,0x1
    5968:	886080e7          	jalr	-1914(ra) # 61ea <printf>
    exit(1);
    596c:	4505                	li	a0,1
    596e:	00000097          	auipc	ra,0x0
    5972:	4dc080e7          	jalr	1244(ra) # 5e4a <exit>
      }
    }

    exit(0);
    5976:	4501                	li	a0,0
    5978:	00000097          	auipc	ra,0x0
    597c:	4d2080e7          	jalr	1234(ra) # 5e4a <exit>
  }

  close(fds[1]);
    5980:	fcc42503          	lw	a0,-52(s0)
    5984:	00000097          	auipc	ra,0x0
    5988:	4ee080e7          	jalr	1262(ra) # 5e72 <close>

  int n = 0;
    598c:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    598e:	4605                	li	a2,1
    5990:	fc740593          	addi	a1,s0,-57
    5994:	fc842503          	lw	a0,-56(s0)
    5998:	00000097          	auipc	ra,0x0
    599c:	4ca080e7          	jalr	1226(ra) # 5e62 <read>
    if(cc < 0){
    59a0:	00054563          	bltz	a0,59aa <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    59a4:	c105                	beqz	a0,59c4 <countfree+0x10a>
      break;
    n += 1;
    59a6:	2485                	addiw	s1,s1,1
  while(1){
    59a8:	b7dd                	j	598e <countfree+0xd4>
      printf("read() failed in countfree()\n");
    59aa:	00003517          	auipc	a0,0x3
    59ae:	e3e50513          	addi	a0,a0,-450 # 87e8 <uthread_self+0x210e>
    59b2:	00001097          	auipc	ra,0x1
    59b6:	838080e7          	jalr	-1992(ra) # 61ea <printf>
      exit(1);
    59ba:	4505                	li	a0,1
    59bc:	00000097          	auipc	ra,0x0
    59c0:	48e080e7          	jalr	1166(ra) # 5e4a <exit>
  }

  close(fds[0]);
    59c4:	fc842503          	lw	a0,-56(s0)
    59c8:	00000097          	auipc	ra,0x0
    59cc:	4aa080e7          	jalr	1194(ra) # 5e72 <close>
  wait((int*)0);
    59d0:	4501                	li	a0,0
    59d2:	00000097          	auipc	ra,0x0
    59d6:	480080e7          	jalr	1152(ra) # 5e52 <wait>
  
  return n;
}
    59da:	8526                	mv	a0,s1
    59dc:	70e2                	ld	ra,56(sp)
    59de:	7442                	ld	s0,48(sp)
    59e0:	74a2                	ld	s1,40(sp)
    59e2:	7902                	ld	s2,32(sp)
    59e4:	69e2                	ld	s3,24(sp)
    59e6:	6121                	addi	sp,sp,64
    59e8:	8082                	ret

00000000000059ea <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    59ea:	711d                	addi	sp,sp,-96
    59ec:	ec86                	sd	ra,88(sp)
    59ee:	e8a2                	sd	s0,80(sp)
    59f0:	e4a6                	sd	s1,72(sp)
    59f2:	e0ca                	sd	s2,64(sp)
    59f4:	fc4e                	sd	s3,56(sp)
    59f6:	f852                	sd	s4,48(sp)
    59f8:	f456                	sd	s5,40(sp)
    59fa:	f05a                	sd	s6,32(sp)
    59fc:	ec5e                	sd	s7,24(sp)
    59fe:	e862                	sd	s8,16(sp)
    5a00:	e466                	sd	s9,8(sp)
    5a02:	e06a                	sd	s10,0(sp)
    5a04:	1080                	addi	s0,sp,96
    5a06:	8a2a                	mv	s4,a0
    5a08:	89ae                	mv	s3,a1
    5a0a:	8932                	mv	s2,a2
  do {
    printf("usertests starting\n");
    5a0c:	00003b97          	auipc	s7,0x3
    5a10:	dfcb8b93          	addi	s7,s7,-516 # 8808 <uthread_self+0x212e>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone)) {
    5a14:	00003b17          	auipc	s6,0x3
    5a18:	5fcb0b13          	addi	s6,s6,1532 # 9010 <quicktests>
      if(continuous != 2) {
    5a1c:	4a89                	li	s5,2
          return 1;
        }
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5a1e:	00003c97          	auipc	s9,0x3
    5a22:	e22c8c93          	addi	s9,s9,-478 # 8840 <uthread_self+0x2166>
      if (runtests(slowtests, justone)) {
    5a26:	00004c17          	auipc	s8,0x4
    5a2a:	9dac0c13          	addi	s8,s8,-1574 # 9400 <slowtests>
        printf("usertests slow tests starting\n");
    5a2e:	00003d17          	auipc	s10,0x3
    5a32:	df2d0d13          	addi	s10,s10,-526 # 8820 <uthread_self+0x2146>
    5a36:	a839                	j	5a54 <drivetests+0x6a>
    5a38:	856a                	mv	a0,s10
    5a3a:	00000097          	auipc	ra,0x0
    5a3e:	7b0080e7          	jalr	1968(ra) # 61ea <printf>
    5a42:	a081                	j	5a82 <drivetests+0x98>
    if((free1 = countfree()) < free0) {
    5a44:	00000097          	auipc	ra,0x0
    5a48:	e76080e7          	jalr	-394(ra) # 58ba <countfree>
    5a4c:	06954263          	blt	a0,s1,5ab0 <drivetests+0xc6>
      if(continuous != 2) {
        return 1;
      }
    }
  } while(continuous);
    5a50:	06098f63          	beqz	s3,5ace <drivetests+0xe4>
    printf("usertests starting\n");
    5a54:	855e                	mv	a0,s7
    5a56:	00000097          	auipc	ra,0x0
    5a5a:	794080e7          	jalr	1940(ra) # 61ea <printf>
    int free0 = countfree();
    5a5e:	00000097          	auipc	ra,0x0
    5a62:	e5c080e7          	jalr	-420(ra) # 58ba <countfree>
    5a66:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone)) {
    5a68:	85ca                	mv	a1,s2
    5a6a:	855a                	mv	a0,s6
    5a6c:	00000097          	auipc	ra,0x0
    5a70:	df2080e7          	jalr	-526(ra) # 585e <runtests>
    5a74:	c119                	beqz	a0,5a7a <drivetests+0x90>
      if(continuous != 2) {
    5a76:	05599863          	bne	s3,s5,5ac6 <drivetests+0xdc>
    if(!quick) {
    5a7a:	fc0a15e3          	bnez	s4,5a44 <drivetests+0x5a>
      if (justone == 0)
    5a7e:	fa090de3          	beqz	s2,5a38 <drivetests+0x4e>
      if (runtests(slowtests, justone)) {
    5a82:	85ca                	mv	a1,s2
    5a84:	8562                	mv	a0,s8
    5a86:	00000097          	auipc	ra,0x0
    5a8a:	dd8080e7          	jalr	-552(ra) # 585e <runtests>
    5a8e:	d95d                	beqz	a0,5a44 <drivetests+0x5a>
        if(continuous != 2) {
    5a90:	03599d63          	bne	s3,s5,5aca <drivetests+0xe0>
    if((free1 = countfree()) < free0) {
    5a94:	00000097          	auipc	ra,0x0
    5a98:	e26080e7          	jalr	-474(ra) # 58ba <countfree>
    5a9c:	fa955ae3          	bge	a0,s1,5a50 <drivetests+0x66>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5aa0:	8626                	mv	a2,s1
    5aa2:	85aa                	mv	a1,a0
    5aa4:	8566                	mv	a0,s9
    5aa6:	00000097          	auipc	ra,0x0
    5aaa:	744080e7          	jalr	1860(ra) # 61ea <printf>
      if(continuous != 2) {
    5aae:	b75d                	j	5a54 <drivetests+0x6a>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5ab0:	8626                	mv	a2,s1
    5ab2:	85aa                	mv	a1,a0
    5ab4:	8566                	mv	a0,s9
    5ab6:	00000097          	auipc	ra,0x0
    5aba:	734080e7          	jalr	1844(ra) # 61ea <printf>
      if(continuous != 2) {
    5abe:	f9598be3          	beq	s3,s5,5a54 <drivetests+0x6a>
        return 1;
    5ac2:	4505                	li	a0,1
    5ac4:	a031                	j	5ad0 <drivetests+0xe6>
        return 1;
    5ac6:	4505                	li	a0,1
    5ac8:	a021                	j	5ad0 <drivetests+0xe6>
          return 1;
    5aca:	4505                	li	a0,1
    5acc:	a011                	j	5ad0 <drivetests+0xe6>
  return 0;
    5ace:	854e                	mv	a0,s3
}
    5ad0:	60e6                	ld	ra,88(sp)
    5ad2:	6446                	ld	s0,80(sp)
    5ad4:	64a6                	ld	s1,72(sp)
    5ad6:	6906                	ld	s2,64(sp)
    5ad8:	79e2                	ld	s3,56(sp)
    5ada:	7a42                	ld	s4,48(sp)
    5adc:	7aa2                	ld	s5,40(sp)
    5ade:	7b02                	ld	s6,32(sp)
    5ae0:	6be2                	ld	s7,24(sp)
    5ae2:	6c42                	ld	s8,16(sp)
    5ae4:	6ca2                	ld	s9,8(sp)
    5ae6:	6d02                	ld	s10,0(sp)
    5ae8:	6125                	addi	sp,sp,96
    5aea:	8082                	ret

0000000000005aec <main>:

int
main(int argc, char *argv[])
{
    5aec:	1101                	addi	sp,sp,-32
    5aee:	ec06                	sd	ra,24(sp)
    5af0:	e822                	sd	s0,16(sp)
    5af2:	e426                	sd	s1,8(sp)
    5af4:	e04a                	sd	s2,0(sp)
    5af6:	1000                	addi	s0,sp,32
    5af8:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    5afa:	4789                	li	a5,2
    5afc:	02f50363          	beq	a0,a5,5b22 <main+0x36>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5b00:	4785                	li	a5,1
    5b02:	06a7cd63          	blt	a5,a0,5b7c <main+0x90>
  char *justone = 0;
    5b06:	4601                	li	a2,0
  int quick = 0;
    5b08:	4501                	li	a0,0
  int continuous = 0;
    5b0a:	4481                	li	s1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    5b0c:	85a6                	mv	a1,s1
    5b0e:	00000097          	auipc	ra,0x0
    5b12:	edc080e7          	jalr	-292(ra) # 59ea <drivetests>
    5b16:	c949                	beqz	a0,5ba8 <main+0xbc>
    exit(1);
    5b18:	4505                	li	a0,1
    5b1a:	00000097          	auipc	ra,0x0
    5b1e:	330080e7          	jalr	816(ra) # 5e4a <exit>
    5b22:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    5b24:	00003597          	auipc	a1,0x3
    5b28:	d4c58593          	addi	a1,a1,-692 # 8870 <uthread_self+0x2196>
    5b2c:	00893503          	ld	a0,8(s2)
    5b30:	00000097          	auipc	ra,0x0
    5b34:	0c8080e7          	jalr	200(ra) # 5bf8 <strcmp>
    5b38:	cd39                	beqz	a0,5b96 <main+0xaa>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5b3a:	00003597          	auipc	a1,0x3
    5b3e:	d8e58593          	addi	a1,a1,-626 # 88c8 <uthread_self+0x21ee>
    5b42:	00893503          	ld	a0,8(s2)
    5b46:	00000097          	auipc	ra,0x0
    5b4a:	0b2080e7          	jalr	178(ra) # 5bf8 <strcmp>
    5b4e:	c931                	beqz	a0,5ba2 <main+0xb6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5b50:	00003597          	auipc	a1,0x3
    5b54:	d7058593          	addi	a1,a1,-656 # 88c0 <uthread_self+0x21e6>
    5b58:	00893503          	ld	a0,8(s2)
    5b5c:	00000097          	auipc	ra,0x0
    5b60:	09c080e7          	jalr	156(ra) # 5bf8 <strcmp>
    5b64:	cd0d                	beqz	a0,5b9e <main+0xb2>
  } else if(argc == 2 && argv[1][0] != '-'){
    5b66:	00893603          	ld	a2,8(s2)
    5b6a:	00064703          	lbu	a4,0(a2)
    5b6e:	02d00793          	li	a5,45
    5b72:	00f70563          	beq	a4,a5,5b7c <main+0x90>
  int quick = 0;
    5b76:	4501                	li	a0,0
  int continuous = 0;
    5b78:	4481                	li	s1,0
    5b7a:	bf49                	j	5b0c <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    5b7c:	00003517          	auipc	a0,0x3
    5b80:	cfc50513          	addi	a0,a0,-772 # 8878 <uthread_self+0x219e>
    5b84:	00000097          	auipc	ra,0x0
    5b88:	666080e7          	jalr	1638(ra) # 61ea <printf>
    exit(1);
    5b8c:	4505                	li	a0,1
    5b8e:	00000097          	auipc	ra,0x0
    5b92:	2bc080e7          	jalr	700(ra) # 5e4a <exit>
  int continuous = 0;
    5b96:	84aa                	mv	s1,a0
  char *justone = 0;
    5b98:	4601                	li	a2,0
    quick = 1;
    5b9a:	4505                	li	a0,1
    5b9c:	bf85                	j	5b0c <main+0x20>
  char *justone = 0;
    5b9e:	4601                	li	a2,0
    5ba0:	b7b5                	j	5b0c <main+0x20>
    5ba2:	4601                	li	a2,0
    continuous = 1;
    5ba4:	4485                	li	s1,1
    5ba6:	b79d                	j	5b0c <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    5ba8:	00003517          	auipc	a0,0x3
    5bac:	d0050513          	addi	a0,a0,-768 # 88a8 <uthread_self+0x21ce>
    5bb0:	00000097          	auipc	ra,0x0
    5bb4:	63a080e7          	jalr	1594(ra) # 61ea <printf>
  exit(0);
    5bb8:	4501                	li	a0,0
    5bba:	00000097          	auipc	ra,0x0
    5bbe:	290080e7          	jalr	656(ra) # 5e4a <exit>

0000000000005bc2 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
    5bc2:	1141                	addi	sp,sp,-16
    5bc4:	e406                	sd	ra,8(sp)
    5bc6:	e022                	sd	s0,0(sp)
    5bc8:	0800                	addi	s0,sp,16
  extern int main();
  main();
    5bca:	00000097          	auipc	ra,0x0
    5bce:	f22080e7          	jalr	-222(ra) # 5aec <main>
  exit(0);
    5bd2:	4501                	li	a0,0
    5bd4:	00000097          	auipc	ra,0x0
    5bd8:	276080e7          	jalr	630(ra) # 5e4a <exit>

0000000000005bdc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    5bdc:	1141                	addi	sp,sp,-16
    5bde:	e422                	sd	s0,8(sp)
    5be0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5be2:	87aa                	mv	a5,a0
    5be4:	0585                	addi	a1,a1,1
    5be6:	0785                	addi	a5,a5,1
    5be8:	fff5c703          	lbu	a4,-1(a1)
    5bec:	fee78fa3          	sb	a4,-1(a5) # fff <linktest+0xe3>
    5bf0:	fb75                	bnez	a4,5be4 <strcpy+0x8>
    ;
  return os;
}
    5bf2:	6422                	ld	s0,8(sp)
    5bf4:	0141                	addi	sp,sp,16
    5bf6:	8082                	ret

0000000000005bf8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5bf8:	1141                	addi	sp,sp,-16
    5bfa:	e422                	sd	s0,8(sp)
    5bfc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    5bfe:	00054783          	lbu	a5,0(a0)
    5c02:	cb91                	beqz	a5,5c16 <strcmp+0x1e>
    5c04:	0005c703          	lbu	a4,0(a1)
    5c08:	00f71763          	bne	a4,a5,5c16 <strcmp+0x1e>
    p++, q++;
    5c0c:	0505                	addi	a0,a0,1
    5c0e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5c10:	00054783          	lbu	a5,0(a0)
    5c14:	fbe5                	bnez	a5,5c04 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5c16:	0005c503          	lbu	a0,0(a1)
}
    5c1a:	40a7853b          	subw	a0,a5,a0
    5c1e:	6422                	ld	s0,8(sp)
    5c20:	0141                	addi	sp,sp,16
    5c22:	8082                	ret

0000000000005c24 <strlen>:

uint
strlen(const char *s)
{
    5c24:	1141                	addi	sp,sp,-16
    5c26:	e422                	sd	s0,8(sp)
    5c28:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5c2a:	00054783          	lbu	a5,0(a0)
    5c2e:	cf91                	beqz	a5,5c4a <strlen+0x26>
    5c30:	0505                	addi	a0,a0,1
    5c32:	87aa                	mv	a5,a0
    5c34:	4685                	li	a3,1
    5c36:	9e89                	subw	a3,a3,a0
    5c38:	00f6853b          	addw	a0,a3,a5
    5c3c:	0785                	addi	a5,a5,1
    5c3e:	fff7c703          	lbu	a4,-1(a5)
    5c42:	fb7d                	bnez	a4,5c38 <strlen+0x14>
    ;
  return n;
}
    5c44:	6422                	ld	s0,8(sp)
    5c46:	0141                	addi	sp,sp,16
    5c48:	8082                	ret
  for(n = 0; s[n]; n++)
    5c4a:	4501                	li	a0,0
    5c4c:	bfe5                	j	5c44 <strlen+0x20>

0000000000005c4e <memset>:

void*
memset(void *dst, int c, uint n)
{
    5c4e:	1141                	addi	sp,sp,-16
    5c50:	e422                	sd	s0,8(sp)
    5c52:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    5c54:	ca19                	beqz	a2,5c6a <memset+0x1c>
    5c56:	87aa                	mv	a5,a0
    5c58:	1602                	slli	a2,a2,0x20
    5c5a:	9201                	srli	a2,a2,0x20
    5c5c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    5c60:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5c64:	0785                	addi	a5,a5,1
    5c66:	fee79de3          	bne	a5,a4,5c60 <memset+0x12>
  }
  return dst;
}
    5c6a:	6422                	ld	s0,8(sp)
    5c6c:	0141                	addi	sp,sp,16
    5c6e:	8082                	ret

0000000000005c70 <strchr>:

char*
strchr(const char *s, char c)
{
    5c70:	1141                	addi	sp,sp,-16
    5c72:	e422                	sd	s0,8(sp)
    5c74:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5c76:	00054783          	lbu	a5,0(a0)
    5c7a:	cb99                	beqz	a5,5c90 <strchr+0x20>
    if(*s == c)
    5c7c:	00f58763          	beq	a1,a5,5c8a <strchr+0x1a>
  for(; *s; s++)
    5c80:	0505                	addi	a0,a0,1
    5c82:	00054783          	lbu	a5,0(a0)
    5c86:	fbfd                	bnez	a5,5c7c <strchr+0xc>
      return (char*)s;
  return 0;
    5c88:	4501                	li	a0,0
}
    5c8a:	6422                	ld	s0,8(sp)
    5c8c:	0141                	addi	sp,sp,16
    5c8e:	8082                	ret
  return 0;
    5c90:	4501                	li	a0,0
    5c92:	bfe5                	j	5c8a <strchr+0x1a>

0000000000005c94 <gets>:

char*
gets(char *buf, int max)
{
    5c94:	711d                	addi	sp,sp,-96
    5c96:	ec86                	sd	ra,88(sp)
    5c98:	e8a2                	sd	s0,80(sp)
    5c9a:	e4a6                	sd	s1,72(sp)
    5c9c:	e0ca                	sd	s2,64(sp)
    5c9e:	fc4e                	sd	s3,56(sp)
    5ca0:	f852                	sd	s4,48(sp)
    5ca2:	f456                	sd	s5,40(sp)
    5ca4:	f05a                	sd	s6,32(sp)
    5ca6:	ec5e                	sd	s7,24(sp)
    5ca8:	1080                	addi	s0,sp,96
    5caa:	8baa                	mv	s7,a0
    5cac:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5cae:	892a                	mv	s2,a0
    5cb0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5cb2:	4aa9                	li	s5,10
    5cb4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5cb6:	89a6                	mv	s3,s1
    5cb8:	2485                	addiw	s1,s1,1
    5cba:	0344d863          	bge	s1,s4,5cea <gets+0x56>
    cc = read(0, &c, 1);
    5cbe:	4605                	li	a2,1
    5cc0:	faf40593          	addi	a1,s0,-81
    5cc4:	4501                	li	a0,0
    5cc6:	00000097          	auipc	ra,0x0
    5cca:	19c080e7          	jalr	412(ra) # 5e62 <read>
    if(cc < 1)
    5cce:	00a05e63          	blez	a0,5cea <gets+0x56>
    buf[i++] = c;
    5cd2:	faf44783          	lbu	a5,-81(s0)
    5cd6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5cda:	01578763          	beq	a5,s5,5ce8 <gets+0x54>
    5cde:	0905                	addi	s2,s2,1
    5ce0:	fd679be3          	bne	a5,s6,5cb6 <gets+0x22>
  for(i=0; i+1 < max; ){
    5ce4:	89a6                	mv	s3,s1
    5ce6:	a011                	j	5cea <gets+0x56>
    5ce8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5cea:	99de                	add	s3,s3,s7
    5cec:	00098023          	sb	zero,0(s3)
  return buf;
}
    5cf0:	855e                	mv	a0,s7
    5cf2:	60e6                	ld	ra,88(sp)
    5cf4:	6446                	ld	s0,80(sp)
    5cf6:	64a6                	ld	s1,72(sp)
    5cf8:	6906                	ld	s2,64(sp)
    5cfa:	79e2                	ld	s3,56(sp)
    5cfc:	7a42                	ld	s4,48(sp)
    5cfe:	7aa2                	ld	s5,40(sp)
    5d00:	7b02                	ld	s6,32(sp)
    5d02:	6be2                	ld	s7,24(sp)
    5d04:	6125                	addi	sp,sp,96
    5d06:	8082                	ret

0000000000005d08 <stat>:

int
stat(const char *n, struct stat *st)
{
    5d08:	1101                	addi	sp,sp,-32
    5d0a:	ec06                	sd	ra,24(sp)
    5d0c:	e822                	sd	s0,16(sp)
    5d0e:	e426                	sd	s1,8(sp)
    5d10:	e04a                	sd	s2,0(sp)
    5d12:	1000                	addi	s0,sp,32
    5d14:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5d16:	4581                	li	a1,0
    5d18:	00000097          	auipc	ra,0x0
    5d1c:	172080e7          	jalr	370(ra) # 5e8a <open>
  if(fd < 0)
    5d20:	02054563          	bltz	a0,5d4a <stat+0x42>
    5d24:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5d26:	85ca                	mv	a1,s2
    5d28:	00000097          	auipc	ra,0x0
    5d2c:	17a080e7          	jalr	378(ra) # 5ea2 <fstat>
    5d30:	892a                	mv	s2,a0
  close(fd);
    5d32:	8526                	mv	a0,s1
    5d34:	00000097          	auipc	ra,0x0
    5d38:	13e080e7          	jalr	318(ra) # 5e72 <close>
  return r;
}
    5d3c:	854a                	mv	a0,s2
    5d3e:	60e2                	ld	ra,24(sp)
    5d40:	6442                	ld	s0,16(sp)
    5d42:	64a2                	ld	s1,8(sp)
    5d44:	6902                	ld	s2,0(sp)
    5d46:	6105                	addi	sp,sp,32
    5d48:	8082                	ret
    return -1;
    5d4a:	597d                	li	s2,-1
    5d4c:	bfc5                	j	5d3c <stat+0x34>

0000000000005d4e <atoi>:

int
atoi(const char *s)
{
    5d4e:	1141                	addi	sp,sp,-16
    5d50:	e422                	sd	s0,8(sp)
    5d52:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5d54:	00054603          	lbu	a2,0(a0)
    5d58:	fd06079b          	addiw	a5,a2,-48
    5d5c:	0ff7f793          	andi	a5,a5,255
    5d60:	4725                	li	a4,9
    5d62:	02f76963          	bltu	a4,a5,5d94 <atoi+0x46>
    5d66:	86aa                	mv	a3,a0
  n = 0;
    5d68:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5d6a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5d6c:	0685                	addi	a3,a3,1
    5d6e:	0025179b          	slliw	a5,a0,0x2
    5d72:	9fa9                	addw	a5,a5,a0
    5d74:	0017979b          	slliw	a5,a5,0x1
    5d78:	9fb1                	addw	a5,a5,a2
    5d7a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5d7e:	0006c603          	lbu	a2,0(a3)
    5d82:	fd06071b          	addiw	a4,a2,-48
    5d86:	0ff77713          	andi	a4,a4,255
    5d8a:	fee5f1e3          	bgeu	a1,a4,5d6c <atoi+0x1e>
  return n;
}
    5d8e:	6422                	ld	s0,8(sp)
    5d90:	0141                	addi	sp,sp,16
    5d92:	8082                	ret
  n = 0;
    5d94:	4501                	li	a0,0
    5d96:	bfe5                	j	5d8e <atoi+0x40>

0000000000005d98 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5d98:	1141                	addi	sp,sp,-16
    5d9a:	e422                	sd	s0,8(sp)
    5d9c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5d9e:	02b57463          	bgeu	a0,a1,5dc6 <memmove+0x2e>
    while(n-- > 0)
    5da2:	00c05f63          	blez	a2,5dc0 <memmove+0x28>
    5da6:	1602                	slli	a2,a2,0x20
    5da8:	9201                	srli	a2,a2,0x20
    5daa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5dae:	872a                	mv	a4,a0
      *dst++ = *src++;
    5db0:	0585                	addi	a1,a1,1
    5db2:	0705                	addi	a4,a4,1
    5db4:	fff5c683          	lbu	a3,-1(a1)
    5db8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5dbc:	fee79ae3          	bne	a5,a4,5db0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5dc0:	6422                	ld	s0,8(sp)
    5dc2:	0141                	addi	sp,sp,16
    5dc4:	8082                	ret
    dst += n;
    5dc6:	00c50733          	add	a4,a0,a2
    src += n;
    5dca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5dcc:	fec05ae3          	blez	a2,5dc0 <memmove+0x28>
    5dd0:	fff6079b          	addiw	a5,a2,-1
    5dd4:	1782                	slli	a5,a5,0x20
    5dd6:	9381                	srli	a5,a5,0x20
    5dd8:	fff7c793          	not	a5,a5
    5ddc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5dde:	15fd                	addi	a1,a1,-1
    5de0:	177d                	addi	a4,a4,-1
    5de2:	0005c683          	lbu	a3,0(a1)
    5de6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5dea:	fee79ae3          	bne	a5,a4,5dde <memmove+0x46>
    5dee:	bfc9                	j	5dc0 <memmove+0x28>

0000000000005df0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5df0:	1141                	addi	sp,sp,-16
    5df2:	e422                	sd	s0,8(sp)
    5df4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5df6:	ca05                	beqz	a2,5e26 <memcmp+0x36>
    5df8:	fff6069b          	addiw	a3,a2,-1
    5dfc:	1682                	slli	a3,a3,0x20
    5dfe:	9281                	srli	a3,a3,0x20
    5e00:	0685                	addi	a3,a3,1
    5e02:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5e04:	00054783          	lbu	a5,0(a0)
    5e08:	0005c703          	lbu	a4,0(a1)
    5e0c:	00e79863          	bne	a5,a4,5e1c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    5e10:	0505                	addi	a0,a0,1
    p2++;
    5e12:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5e14:	fed518e3          	bne	a0,a3,5e04 <memcmp+0x14>
  }
  return 0;
    5e18:	4501                	li	a0,0
    5e1a:	a019                	j	5e20 <memcmp+0x30>
      return *p1 - *p2;
    5e1c:	40e7853b          	subw	a0,a5,a4
}
    5e20:	6422                	ld	s0,8(sp)
    5e22:	0141                	addi	sp,sp,16
    5e24:	8082                	ret
  return 0;
    5e26:	4501                	li	a0,0
    5e28:	bfe5                	j	5e20 <memcmp+0x30>

0000000000005e2a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5e2a:	1141                	addi	sp,sp,-16
    5e2c:	e406                	sd	ra,8(sp)
    5e2e:	e022                	sd	s0,0(sp)
    5e30:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5e32:	00000097          	auipc	ra,0x0
    5e36:	f66080e7          	jalr	-154(ra) # 5d98 <memmove>
}
    5e3a:	60a2                	ld	ra,8(sp)
    5e3c:	6402                	ld	s0,0(sp)
    5e3e:	0141                	addi	sp,sp,16
    5e40:	8082                	ret

0000000000005e42 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5e42:	4885                	li	a7,1
 ecall
    5e44:	00000073          	ecall
 ret
    5e48:	8082                	ret

0000000000005e4a <exit>:
.global exit
exit:
 li a7, SYS_exit
    5e4a:	4889                	li	a7,2
 ecall
    5e4c:	00000073          	ecall
 ret
    5e50:	8082                	ret

0000000000005e52 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5e52:	488d                	li	a7,3
 ecall
    5e54:	00000073          	ecall
 ret
    5e58:	8082                	ret

0000000000005e5a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5e5a:	4891                	li	a7,4
 ecall
    5e5c:	00000073          	ecall
 ret
    5e60:	8082                	ret

0000000000005e62 <read>:
.global read
read:
 li a7, SYS_read
    5e62:	4895                	li	a7,5
 ecall
    5e64:	00000073          	ecall
 ret
    5e68:	8082                	ret

0000000000005e6a <write>:
.global write
write:
 li a7, SYS_write
    5e6a:	48c1                	li	a7,16
 ecall
    5e6c:	00000073          	ecall
 ret
    5e70:	8082                	ret

0000000000005e72 <close>:
.global close
close:
 li a7, SYS_close
    5e72:	48d5                	li	a7,21
 ecall
    5e74:	00000073          	ecall
 ret
    5e78:	8082                	ret

0000000000005e7a <kill>:
.global kill
kill:
 li a7, SYS_kill
    5e7a:	4899                	li	a7,6
 ecall
    5e7c:	00000073          	ecall
 ret
    5e80:	8082                	ret

0000000000005e82 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5e82:	489d                	li	a7,7
 ecall
    5e84:	00000073          	ecall
 ret
    5e88:	8082                	ret

0000000000005e8a <open>:
.global open
open:
 li a7, SYS_open
    5e8a:	48bd                	li	a7,15
 ecall
    5e8c:	00000073          	ecall
 ret
    5e90:	8082                	ret

0000000000005e92 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5e92:	48c5                	li	a7,17
 ecall
    5e94:	00000073          	ecall
 ret
    5e98:	8082                	ret

0000000000005e9a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5e9a:	48c9                	li	a7,18
 ecall
    5e9c:	00000073          	ecall
 ret
    5ea0:	8082                	ret

0000000000005ea2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5ea2:	48a1                	li	a7,8
 ecall
    5ea4:	00000073          	ecall
 ret
    5ea8:	8082                	ret

0000000000005eaa <link>:
.global link
link:
 li a7, SYS_link
    5eaa:	48cd                	li	a7,19
 ecall
    5eac:	00000073          	ecall
 ret
    5eb0:	8082                	ret

0000000000005eb2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5eb2:	48d1                	li	a7,20
 ecall
    5eb4:	00000073          	ecall
 ret
    5eb8:	8082                	ret

0000000000005eba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5eba:	48a5                	li	a7,9
 ecall
    5ebc:	00000073          	ecall
 ret
    5ec0:	8082                	ret

0000000000005ec2 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5ec2:	48a9                	li	a7,10
 ecall
    5ec4:	00000073          	ecall
 ret
    5ec8:	8082                	ret

0000000000005eca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5eca:	48ad                	li	a7,11
 ecall
    5ecc:	00000073          	ecall
 ret
    5ed0:	8082                	ret

0000000000005ed2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5ed2:	48b1                	li	a7,12
 ecall
    5ed4:	00000073          	ecall
 ret
    5ed8:	8082                	ret

0000000000005eda <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5eda:	48b5                	li	a7,13
 ecall
    5edc:	00000073          	ecall
 ret
    5ee0:	8082                	ret

0000000000005ee2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5ee2:	48b9                	li	a7,14
 ecall
    5ee4:	00000073          	ecall
 ret
    5ee8:	8082                	ret

0000000000005eea <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
    5eea:	48d9                	li	a7,22
 ecall
    5eec:	00000073          	ecall
 ret
    5ef0:	8082                	ret

0000000000005ef2 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
    5ef2:	48dd                	li	a7,23
 ecall
    5ef4:	00000073          	ecall
 ret
    5ef8:	8082                	ret

0000000000005efa <kthread_kill>:
.global kthread_kill
kthread_kill:
 li a7, SYS_kthread_kill
    5efa:	48e1                	li	a7,24
 ecall
    5efc:	00000073          	ecall
 ret
    5f00:	8082                	ret

0000000000005f02 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
    5f02:	48e5                	li	a7,25
 ecall
    5f04:	00000073          	ecall
 ret
    5f08:	8082                	ret

0000000000005f0a <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
    5f0a:	48e9                	li	a7,26
 ecall
    5f0c:	00000073          	ecall
 ret
    5f10:	8082                	ret

0000000000005f12 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5f12:	1101                	addi	sp,sp,-32
    5f14:	ec06                	sd	ra,24(sp)
    5f16:	e822                	sd	s0,16(sp)
    5f18:	1000                	addi	s0,sp,32
    5f1a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5f1e:	4605                	li	a2,1
    5f20:	fef40593          	addi	a1,s0,-17
    5f24:	00000097          	auipc	ra,0x0
    5f28:	f46080e7          	jalr	-186(ra) # 5e6a <write>
}
    5f2c:	60e2                	ld	ra,24(sp)
    5f2e:	6442                	ld	s0,16(sp)
    5f30:	6105                	addi	sp,sp,32
    5f32:	8082                	ret

0000000000005f34 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5f34:	7139                	addi	sp,sp,-64
    5f36:	fc06                	sd	ra,56(sp)
    5f38:	f822                	sd	s0,48(sp)
    5f3a:	f426                	sd	s1,40(sp)
    5f3c:	f04a                	sd	s2,32(sp)
    5f3e:	ec4e                	sd	s3,24(sp)
    5f40:	0080                	addi	s0,sp,64
    5f42:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5f44:	c299                	beqz	a3,5f4a <printint+0x16>
    5f46:	0805c863          	bltz	a1,5fd6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5f4a:	2581                	sext.w	a1,a1
  neg = 0;
    5f4c:	4881                	li	a7,0
    5f4e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5f52:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5f54:	2601                	sext.w	a2,a2
    5f56:	00003517          	auipc	a0,0x3
    5f5a:	cf250513          	addi	a0,a0,-782 # 8c48 <digits>
    5f5e:	883a                	mv	a6,a4
    5f60:	2705                	addiw	a4,a4,1
    5f62:	02c5f7bb          	remuw	a5,a1,a2
    5f66:	1782                	slli	a5,a5,0x20
    5f68:	9381                	srli	a5,a5,0x20
    5f6a:	97aa                	add	a5,a5,a0
    5f6c:	0007c783          	lbu	a5,0(a5)
    5f70:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5f74:	0005879b          	sext.w	a5,a1
    5f78:	02c5d5bb          	divuw	a1,a1,a2
    5f7c:	0685                	addi	a3,a3,1
    5f7e:	fec7f0e3          	bgeu	a5,a2,5f5e <printint+0x2a>
  if(neg)
    5f82:	00088b63          	beqz	a7,5f98 <printint+0x64>
    buf[i++] = '-';
    5f86:	fd040793          	addi	a5,s0,-48
    5f8a:	973e                	add	a4,a4,a5
    5f8c:	02d00793          	li	a5,45
    5f90:	fef70823          	sb	a5,-16(a4)
    5f94:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5f98:	02e05863          	blez	a4,5fc8 <printint+0x94>
    5f9c:	fc040793          	addi	a5,s0,-64
    5fa0:	00e78933          	add	s2,a5,a4
    5fa4:	fff78993          	addi	s3,a5,-1
    5fa8:	99ba                	add	s3,s3,a4
    5faa:	377d                	addiw	a4,a4,-1
    5fac:	1702                	slli	a4,a4,0x20
    5fae:	9301                	srli	a4,a4,0x20
    5fb0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5fb4:	fff94583          	lbu	a1,-1(s2)
    5fb8:	8526                	mv	a0,s1
    5fba:	00000097          	auipc	ra,0x0
    5fbe:	f58080e7          	jalr	-168(ra) # 5f12 <putc>
  while(--i >= 0)
    5fc2:	197d                	addi	s2,s2,-1
    5fc4:	ff3918e3          	bne	s2,s3,5fb4 <printint+0x80>
}
    5fc8:	70e2                	ld	ra,56(sp)
    5fca:	7442                	ld	s0,48(sp)
    5fcc:	74a2                	ld	s1,40(sp)
    5fce:	7902                	ld	s2,32(sp)
    5fd0:	69e2                	ld	s3,24(sp)
    5fd2:	6121                	addi	sp,sp,64
    5fd4:	8082                	ret
    x = -xx;
    5fd6:	40b005bb          	negw	a1,a1
    neg = 1;
    5fda:	4885                	li	a7,1
    x = -xx;
    5fdc:	bf8d                	j	5f4e <printint+0x1a>

0000000000005fde <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5fde:	7119                	addi	sp,sp,-128
    5fe0:	fc86                	sd	ra,120(sp)
    5fe2:	f8a2                	sd	s0,112(sp)
    5fe4:	f4a6                	sd	s1,104(sp)
    5fe6:	f0ca                	sd	s2,96(sp)
    5fe8:	ecce                	sd	s3,88(sp)
    5fea:	e8d2                	sd	s4,80(sp)
    5fec:	e4d6                	sd	s5,72(sp)
    5fee:	e0da                	sd	s6,64(sp)
    5ff0:	fc5e                	sd	s7,56(sp)
    5ff2:	f862                	sd	s8,48(sp)
    5ff4:	f466                	sd	s9,40(sp)
    5ff6:	f06a                	sd	s10,32(sp)
    5ff8:	ec6e                	sd	s11,24(sp)
    5ffa:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5ffc:	0005c903          	lbu	s2,0(a1)
    6000:	18090f63          	beqz	s2,619e <vprintf+0x1c0>
    6004:	8aaa                	mv	s5,a0
    6006:	8b32                	mv	s6,a2
    6008:	00158493          	addi	s1,a1,1
  state = 0;
    600c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    600e:	02500a13          	li	s4,37
      if(c == 'd'){
    6012:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    6016:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    601a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    601e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    6022:	00003b97          	auipc	s7,0x3
    6026:	c26b8b93          	addi	s7,s7,-986 # 8c48 <digits>
    602a:	a839                	j	6048 <vprintf+0x6a>
        putc(fd, c);
    602c:	85ca                	mv	a1,s2
    602e:	8556                	mv	a0,s5
    6030:	00000097          	auipc	ra,0x0
    6034:	ee2080e7          	jalr	-286(ra) # 5f12 <putc>
    6038:	a019                	j	603e <vprintf+0x60>
    } else if(state == '%'){
    603a:	01498f63          	beq	s3,s4,6058 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    603e:	0485                	addi	s1,s1,1
    6040:	fff4c903          	lbu	s2,-1(s1)
    6044:	14090d63          	beqz	s2,619e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    6048:	0009079b          	sext.w	a5,s2
    if(state == 0){
    604c:	fe0997e3          	bnez	s3,603a <vprintf+0x5c>
      if(c == '%'){
    6050:	fd479ee3          	bne	a5,s4,602c <vprintf+0x4e>
        state = '%';
    6054:	89be                	mv	s3,a5
    6056:	b7e5                	j	603e <vprintf+0x60>
      if(c == 'd'){
    6058:	05878063          	beq	a5,s8,6098 <vprintf+0xba>
      } else if(c == 'l') {
    605c:	05978c63          	beq	a5,s9,60b4 <vprintf+0xd6>
      } else if(c == 'x') {
    6060:	07a78863          	beq	a5,s10,60d0 <vprintf+0xf2>
      } else if(c == 'p') {
    6064:	09b78463          	beq	a5,s11,60ec <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    6068:	07300713          	li	a4,115
    606c:	0ce78663          	beq	a5,a4,6138 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    6070:	06300713          	li	a4,99
    6074:	0ee78e63          	beq	a5,a4,6170 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    6078:	11478863          	beq	a5,s4,6188 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    607c:	85d2                	mv	a1,s4
    607e:	8556                	mv	a0,s5
    6080:	00000097          	auipc	ra,0x0
    6084:	e92080e7          	jalr	-366(ra) # 5f12 <putc>
        putc(fd, c);
    6088:	85ca                	mv	a1,s2
    608a:	8556                	mv	a0,s5
    608c:	00000097          	auipc	ra,0x0
    6090:	e86080e7          	jalr	-378(ra) # 5f12 <putc>
      }
      state = 0;
    6094:	4981                	li	s3,0
    6096:	b765                	j	603e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    6098:	008b0913          	addi	s2,s6,8
    609c:	4685                	li	a3,1
    609e:	4629                	li	a2,10
    60a0:	000b2583          	lw	a1,0(s6)
    60a4:	8556                	mv	a0,s5
    60a6:	00000097          	auipc	ra,0x0
    60aa:	e8e080e7          	jalr	-370(ra) # 5f34 <printint>
    60ae:	8b4a                	mv	s6,s2
      state = 0;
    60b0:	4981                	li	s3,0
    60b2:	b771                	j	603e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    60b4:	008b0913          	addi	s2,s6,8
    60b8:	4681                	li	a3,0
    60ba:	4629                	li	a2,10
    60bc:	000b2583          	lw	a1,0(s6)
    60c0:	8556                	mv	a0,s5
    60c2:	00000097          	auipc	ra,0x0
    60c6:	e72080e7          	jalr	-398(ra) # 5f34 <printint>
    60ca:	8b4a                	mv	s6,s2
      state = 0;
    60cc:	4981                	li	s3,0
    60ce:	bf85                	j	603e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    60d0:	008b0913          	addi	s2,s6,8
    60d4:	4681                	li	a3,0
    60d6:	4641                	li	a2,16
    60d8:	000b2583          	lw	a1,0(s6)
    60dc:	8556                	mv	a0,s5
    60de:	00000097          	auipc	ra,0x0
    60e2:	e56080e7          	jalr	-426(ra) # 5f34 <printint>
    60e6:	8b4a                	mv	s6,s2
      state = 0;
    60e8:	4981                	li	s3,0
    60ea:	bf91                	j	603e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    60ec:	008b0793          	addi	a5,s6,8
    60f0:	f8f43423          	sd	a5,-120(s0)
    60f4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    60f8:	03000593          	li	a1,48
    60fc:	8556                	mv	a0,s5
    60fe:	00000097          	auipc	ra,0x0
    6102:	e14080e7          	jalr	-492(ra) # 5f12 <putc>
  putc(fd, 'x');
    6106:	85ea                	mv	a1,s10
    6108:	8556                	mv	a0,s5
    610a:	00000097          	auipc	ra,0x0
    610e:	e08080e7          	jalr	-504(ra) # 5f12 <putc>
    6112:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    6114:	03c9d793          	srli	a5,s3,0x3c
    6118:	97de                	add	a5,a5,s7
    611a:	0007c583          	lbu	a1,0(a5)
    611e:	8556                	mv	a0,s5
    6120:	00000097          	auipc	ra,0x0
    6124:	df2080e7          	jalr	-526(ra) # 5f12 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    6128:	0992                	slli	s3,s3,0x4
    612a:	397d                	addiw	s2,s2,-1
    612c:	fe0914e3          	bnez	s2,6114 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    6130:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    6134:	4981                	li	s3,0
    6136:	b721                	j	603e <vprintf+0x60>
        s = va_arg(ap, char*);
    6138:	008b0993          	addi	s3,s6,8
    613c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    6140:	02090163          	beqz	s2,6162 <vprintf+0x184>
        while(*s != 0){
    6144:	00094583          	lbu	a1,0(s2)
    6148:	c9a1                	beqz	a1,6198 <vprintf+0x1ba>
          putc(fd, *s);
    614a:	8556                	mv	a0,s5
    614c:	00000097          	auipc	ra,0x0
    6150:	dc6080e7          	jalr	-570(ra) # 5f12 <putc>
          s++;
    6154:	0905                	addi	s2,s2,1
        while(*s != 0){
    6156:	00094583          	lbu	a1,0(s2)
    615a:	f9e5                	bnez	a1,614a <vprintf+0x16c>
        s = va_arg(ap, char*);
    615c:	8b4e                	mv	s6,s3
      state = 0;
    615e:	4981                	li	s3,0
    6160:	bdf9                	j	603e <vprintf+0x60>
          s = "(null)";
    6162:	00003917          	auipc	s2,0x3
    6166:	ade90913          	addi	s2,s2,-1314 # 8c40 <uthread_self+0x2566>
        while(*s != 0){
    616a:	02800593          	li	a1,40
    616e:	bff1                	j	614a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    6170:	008b0913          	addi	s2,s6,8
    6174:	000b4583          	lbu	a1,0(s6)
    6178:	8556                	mv	a0,s5
    617a:	00000097          	auipc	ra,0x0
    617e:	d98080e7          	jalr	-616(ra) # 5f12 <putc>
    6182:	8b4a                	mv	s6,s2
      state = 0;
    6184:	4981                	li	s3,0
    6186:	bd65                	j	603e <vprintf+0x60>
        putc(fd, c);
    6188:	85d2                	mv	a1,s4
    618a:	8556                	mv	a0,s5
    618c:	00000097          	auipc	ra,0x0
    6190:	d86080e7          	jalr	-634(ra) # 5f12 <putc>
      state = 0;
    6194:	4981                	li	s3,0
    6196:	b565                	j	603e <vprintf+0x60>
        s = va_arg(ap, char*);
    6198:	8b4e                	mv	s6,s3
      state = 0;
    619a:	4981                	li	s3,0
    619c:	b54d                	j	603e <vprintf+0x60>
    }
  }
}
    619e:	70e6                	ld	ra,120(sp)
    61a0:	7446                	ld	s0,112(sp)
    61a2:	74a6                	ld	s1,104(sp)
    61a4:	7906                	ld	s2,96(sp)
    61a6:	69e6                	ld	s3,88(sp)
    61a8:	6a46                	ld	s4,80(sp)
    61aa:	6aa6                	ld	s5,72(sp)
    61ac:	6b06                	ld	s6,64(sp)
    61ae:	7be2                	ld	s7,56(sp)
    61b0:	7c42                	ld	s8,48(sp)
    61b2:	7ca2                	ld	s9,40(sp)
    61b4:	7d02                	ld	s10,32(sp)
    61b6:	6de2                	ld	s11,24(sp)
    61b8:	6109                	addi	sp,sp,128
    61ba:	8082                	ret

00000000000061bc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    61bc:	715d                	addi	sp,sp,-80
    61be:	ec06                	sd	ra,24(sp)
    61c0:	e822                	sd	s0,16(sp)
    61c2:	1000                	addi	s0,sp,32
    61c4:	e010                	sd	a2,0(s0)
    61c6:	e414                	sd	a3,8(s0)
    61c8:	e818                	sd	a4,16(s0)
    61ca:	ec1c                	sd	a5,24(s0)
    61cc:	03043023          	sd	a6,32(s0)
    61d0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    61d4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    61d8:	8622                	mv	a2,s0
    61da:	00000097          	auipc	ra,0x0
    61de:	e04080e7          	jalr	-508(ra) # 5fde <vprintf>
}
    61e2:	60e2                	ld	ra,24(sp)
    61e4:	6442                	ld	s0,16(sp)
    61e6:	6161                	addi	sp,sp,80
    61e8:	8082                	ret

00000000000061ea <printf>:

void
printf(const char *fmt, ...)
{
    61ea:	711d                	addi	sp,sp,-96
    61ec:	ec06                	sd	ra,24(sp)
    61ee:	e822                	sd	s0,16(sp)
    61f0:	1000                	addi	s0,sp,32
    61f2:	e40c                	sd	a1,8(s0)
    61f4:	e810                	sd	a2,16(s0)
    61f6:	ec14                	sd	a3,24(s0)
    61f8:	f018                	sd	a4,32(s0)
    61fa:	f41c                	sd	a5,40(s0)
    61fc:	03043823          	sd	a6,48(s0)
    6200:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    6204:	00840613          	addi	a2,s0,8
    6208:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    620c:	85aa                	mv	a1,a0
    620e:	4505                	li	a0,1
    6210:	00000097          	auipc	ra,0x0
    6214:	dce080e7          	jalr	-562(ra) # 5fde <vprintf>
}
    6218:	60e2                	ld	ra,24(sp)
    621a:	6442                	ld	s0,16(sp)
    621c:	6125                	addi	sp,sp,96
    621e:	8082                	ret

0000000000006220 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    6220:	1141                	addi	sp,sp,-16
    6222:	e422                	sd	s0,8(sp)
    6224:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    6226:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    622a:	00003797          	auipc	a5,0x3
    622e:	24e7b783          	ld	a5,590(a5) # 9478 <freep>
    6232:	a805                	j	6262 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    6234:	4618                	lw	a4,8(a2)
    6236:	9db9                	addw	a1,a1,a4
    6238:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    623c:	6398                	ld	a4,0(a5)
    623e:	6318                	ld	a4,0(a4)
    6240:	fee53823          	sd	a4,-16(a0)
    6244:	a091                	j	6288 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    6246:	ff852703          	lw	a4,-8(a0)
    624a:	9e39                	addw	a2,a2,a4
    624c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    624e:	ff053703          	ld	a4,-16(a0)
    6252:	e398                	sd	a4,0(a5)
    6254:	a099                	j	629a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    6256:	6398                	ld	a4,0(a5)
    6258:	00e7e463          	bltu	a5,a4,6260 <free+0x40>
    625c:	00e6ea63          	bltu	a3,a4,6270 <free+0x50>
{
    6260:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    6262:	fed7fae3          	bgeu	a5,a3,6256 <free+0x36>
    6266:	6398                	ld	a4,0(a5)
    6268:	00e6e463          	bltu	a3,a4,6270 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    626c:	fee7eae3          	bltu	a5,a4,6260 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    6270:	ff852583          	lw	a1,-8(a0)
    6274:	6390                	ld	a2,0(a5)
    6276:	02059713          	slli	a4,a1,0x20
    627a:	9301                	srli	a4,a4,0x20
    627c:	0712                	slli	a4,a4,0x4
    627e:	9736                	add	a4,a4,a3
    6280:	fae60ae3          	beq	a2,a4,6234 <free+0x14>
    bp->s.ptr = p->s.ptr;
    6284:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    6288:	4790                	lw	a2,8(a5)
    628a:	02061713          	slli	a4,a2,0x20
    628e:	9301                	srli	a4,a4,0x20
    6290:	0712                	slli	a4,a4,0x4
    6292:	973e                	add	a4,a4,a5
    6294:	fae689e3          	beq	a3,a4,6246 <free+0x26>
  } else
    p->s.ptr = bp;
    6298:	e394                	sd	a3,0(a5)
  freep = p;
    629a:	00003717          	auipc	a4,0x3
    629e:	1cf73f23          	sd	a5,478(a4) # 9478 <freep>
}
    62a2:	6422                	ld	s0,8(sp)
    62a4:	0141                	addi	sp,sp,16
    62a6:	8082                	ret

00000000000062a8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    62a8:	7139                	addi	sp,sp,-64
    62aa:	fc06                	sd	ra,56(sp)
    62ac:	f822                	sd	s0,48(sp)
    62ae:	f426                	sd	s1,40(sp)
    62b0:	f04a                	sd	s2,32(sp)
    62b2:	ec4e                	sd	s3,24(sp)
    62b4:	e852                	sd	s4,16(sp)
    62b6:	e456                	sd	s5,8(sp)
    62b8:	e05a                	sd	s6,0(sp)
    62ba:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    62bc:	02051493          	slli	s1,a0,0x20
    62c0:	9081                	srli	s1,s1,0x20
    62c2:	04bd                	addi	s1,s1,15
    62c4:	8091                	srli	s1,s1,0x4
    62c6:	0014899b          	addiw	s3,s1,1
    62ca:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    62cc:	00003517          	auipc	a0,0x3
    62d0:	1ac53503          	ld	a0,428(a0) # 9478 <freep>
    62d4:	c515                	beqz	a0,6300 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    62d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    62d8:	4798                	lw	a4,8(a5)
    62da:	02977f63          	bgeu	a4,s1,6318 <malloc+0x70>
    62de:	8a4e                	mv	s4,s3
    62e0:	0009871b          	sext.w	a4,s3
    62e4:	6685                	lui	a3,0x1
    62e6:	00d77363          	bgeu	a4,a3,62ec <malloc+0x44>
    62ea:	6a05                	lui	s4,0x1
    62ec:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    62f0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    62f4:	00003917          	auipc	s2,0x3
    62f8:	18490913          	addi	s2,s2,388 # 9478 <freep>
  if(p == (char*)-1)
    62fc:	5afd                	li	s5,-1
    62fe:	a88d                	j	6370 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    6300:	0000a797          	auipc	a5,0xa
    6304:	9a878793          	addi	a5,a5,-1624 # fca8 <base>
    6308:	00003717          	auipc	a4,0x3
    630c:	16f73823          	sd	a5,368(a4) # 9478 <freep>
    6310:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    6312:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    6316:	b7e1                	j	62de <malloc+0x36>
      if(p->s.size == nunits)
    6318:	02e48b63          	beq	s1,a4,634e <malloc+0xa6>
        p->s.size -= nunits;
    631c:	4137073b          	subw	a4,a4,s3
    6320:	c798                	sw	a4,8(a5)
        p += p->s.size;
    6322:	1702                	slli	a4,a4,0x20
    6324:	9301                	srli	a4,a4,0x20
    6326:	0712                	slli	a4,a4,0x4
    6328:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    632a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    632e:	00003717          	auipc	a4,0x3
    6332:	14a73523          	sd	a0,330(a4) # 9478 <freep>
      return (void*)(p + 1);
    6336:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    633a:	70e2                	ld	ra,56(sp)
    633c:	7442                	ld	s0,48(sp)
    633e:	74a2                	ld	s1,40(sp)
    6340:	7902                	ld	s2,32(sp)
    6342:	69e2                	ld	s3,24(sp)
    6344:	6a42                	ld	s4,16(sp)
    6346:	6aa2                	ld	s5,8(sp)
    6348:	6b02                	ld	s6,0(sp)
    634a:	6121                	addi	sp,sp,64
    634c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    634e:	6398                	ld	a4,0(a5)
    6350:	e118                	sd	a4,0(a0)
    6352:	bff1                	j	632e <malloc+0x86>
  hp->s.size = nu;
    6354:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    6358:	0541                	addi	a0,a0,16
    635a:	00000097          	auipc	ra,0x0
    635e:	ec6080e7          	jalr	-314(ra) # 6220 <free>
  return freep;
    6362:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    6366:	d971                	beqz	a0,633a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    6368:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    636a:	4798                	lw	a4,8(a5)
    636c:	fa9776e3          	bgeu	a4,s1,6318 <malloc+0x70>
    if(p == freep)
    6370:	00093703          	ld	a4,0(s2)
    6374:	853e                	mv	a0,a5
    6376:	fef719e3          	bne	a4,a5,6368 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    637a:	8552                	mv	a0,s4
    637c:	00000097          	auipc	ra,0x0
    6380:	b56080e7          	jalr	-1194(ra) # 5ed2 <sbrk>
  if(p == (char*)-1)
    6384:	fd5518e3          	bne	a0,s5,6354 <malloc+0xac>
        return 0;
    6388:	4501                	li	a0,0
    638a:	bf45                	j	633a <malloc+0x92>

000000000000638c <uswtch>:
    638c:	00153023          	sd	ra,0(a0)
    6390:	00253423          	sd	sp,8(a0)
    6394:	e900                	sd	s0,16(a0)
    6396:	ed04                	sd	s1,24(a0)
    6398:	03253023          	sd	s2,32(a0)
    639c:	03353423          	sd	s3,40(a0)
    63a0:	03453823          	sd	s4,48(a0)
    63a4:	03553c23          	sd	s5,56(a0)
    63a8:	05653023          	sd	s6,64(a0)
    63ac:	05753423          	sd	s7,72(a0)
    63b0:	05853823          	sd	s8,80(a0)
    63b4:	05953c23          	sd	s9,88(a0)
    63b8:	07a53023          	sd	s10,96(a0)
    63bc:	07b53423          	sd	s11,104(a0)
    63c0:	0005b083          	ld	ra,0(a1)
    63c4:	0085b103          	ld	sp,8(a1)
    63c8:	6980                	ld	s0,16(a1)
    63ca:	6d84                	ld	s1,24(a1)
    63cc:	0205b903          	ld	s2,32(a1)
    63d0:	0285b983          	ld	s3,40(a1)
    63d4:	0305ba03          	ld	s4,48(a1)
    63d8:	0385ba83          	ld	s5,56(a1)
    63dc:	0405bb03          	ld	s6,64(a1)
    63e0:	0485bb83          	ld	s7,72(a1)
    63e4:	0505bc03          	ld	s8,80(a1)
    63e8:	0585bc83          	ld	s9,88(a1)
    63ec:	0605bd03          	ld	s10,96(a1)
    63f0:	0685bd83          	ld	s11,104(a1)
    63f4:	8082                	ret

00000000000063f6 <uthread_exit>:
    curr_thread = next_thread;
    uswtch(curr_context, next_context);

}

void uthread_exit(){
    63f6:	1141                	addi	sp,sp,-16
    63f8:	e406                	sd	ra,8(sp)
    63fa:	e022                	sd	s0,0(sp)
    63fc:	0800                	addi	s0,sp,16
    printf("in uthresd exit\n");
    63fe:	00003517          	auipc	a0,0x3
    6402:	86250513          	addi	a0,a0,-1950 # 8c60 <digits+0x18>
    6406:	00000097          	auipc	ra,0x0
    640a:	de4080e7          	jalr	-540(ra) # 61ea <printf>
    // Change the state of the current thread to FREE
    curr_thread->state = FREE;
    640e:	00003517          	auipc	a0,0x3
    6412:	07253503          	ld	a0,114(a0) # 9480 <curr_thread>
    6416:	6785                	lui	a5,0x1
    6418:	97aa                	add	a5,a5,a0
    641a:	fa07a223          	sw	zero,-92(a5) # fa4 <linktest+0x88>
    // Find another runnable thread to switch to (make sure its not the current_thread)
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
    641e:	411c                	lw	a5,0(a0)
    6420:	2785                	addiw	a5,a5,1
    6422:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
    6424:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
    6426:	4585                	li	a1,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
    6428:	0000a617          	auipc	a2,0xa
    642c:	90060613          	addi	a2,a2,-1792 # fd28 <uthreads_arr>
    6430:	6805                	lui	a6,0x1
    6432:	4889                	li	a7,2
    6434:	a819                	j	644a <uthread_exit+0x54>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
    6436:	2785                	addiw	a5,a5,1
    6438:	41f7d71b          	sraiw	a4,a5,0x1f
    643c:	01e7571b          	srliw	a4,a4,0x1e
    6440:	9fb9                	addw	a5,a5,a4
    6442:	8b8d                	andi	a5,a5,3
    6444:	9f99                	subw	a5,a5,a4
    6446:	36fd                	addiw	a3,a3,-1
    6448:	ca9d                	beqz	a3,647e <uthread_exit+0x88>
        if (uthreads_arr[i].state == RUNNABLE &&
    644a:	00779713          	slli	a4,a5,0x7
    644e:	973e                	add	a4,a4,a5
    6450:	0716                	slli	a4,a4,0x5
    6452:	9732                	add	a4,a4,a2
    6454:	9742                	add	a4,a4,a6
    6456:	fa472703          	lw	a4,-92(a4)
    645a:	fd171ee3          	bne	a4,a7,6436 <uthread_exit+0x40>
            uthreads_arr[i].priority > max_priority) {
    645e:	00779713          	slli	a4,a5,0x7
    6462:	973e                	add	a4,a4,a5
    6464:	0716                	slli	a4,a4,0x5
    6466:	9732                	add	a4,a4,a2
    6468:	9742                	add	a4,a4,a6
    646a:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
    646c:	fce375e3          	bgeu	t1,a4,6436 <uthread_exit+0x40>
            next_thread = &uthreads_arr[i];
    6470:	00779593          	slli	a1,a5,0x7
    6474:	95be                	add	a1,a1,a5
    6476:	0596                	slli	a1,a1,0x5
    6478:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
    647a:	833a                	mv	t1,a4
    647c:	bf6d                	j	6436 <uthread_exit+0x40>
        }
    }
    if (next_thread == (struct uthread *) 1) {
    647e:	4785                	li	a5,1
    6480:	02f58863          	beq	a1,a5,64b0 <uthread_exit+0xba>
        exit(0);  // Exit the process if there are no more runnable threads
    }
    // Switch to the next thread
    struct context *curr_context = &curr_thread->context;
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
    6484:	6785                	lui	a5,0x1
    6486:	00f58733          	add	a4,a1,a5
    648a:	4685                	li	a3,1
    648c:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
    6490:	00003717          	auipc	a4,0x3
    6494:	feb73823          	sd	a1,-16(a4) # 9480 <curr_thread>
    struct context *next_context = &next_thread->context;
    6498:	fa878793          	addi	a5,a5,-88 # fa8 <linktest+0x8c>
    uswtch(curr_context, next_context);
    649c:	95be                	add	a1,a1,a5
    649e:	953e                	add	a0,a0,a5
    64a0:	00000097          	auipc	ra,0x0
    64a4:	eec080e7          	jalr	-276(ra) # 638c <uswtch>
}
    64a8:	60a2                	ld	ra,8(sp)
    64aa:	6402                	ld	s0,0(sp)
    64ac:	0141                	addi	sp,sp,16
    64ae:	8082                	ret
        exit(0);  // Exit the process if there are no more runnable threads
    64b0:	4501                	li	a0,0
    64b2:	00000097          	auipc	ra,0x0
    64b6:	998080e7          	jalr	-1640(ra) # 5e4a <exit>

00000000000064ba <uthread_create>:
int uthread_create(void (*start_func)(), enum sched_priority priority) {
    64ba:	1141                	addi	sp,sp,-16
    64bc:	e422                	sd	s0,8(sp)
    64be:	0800                	addi	s0,sp,16
    for (i = 0; i < MAX_UTHREADS; i++) {
    64c0:	0000b717          	auipc	a4,0xb
    64c4:	80c70713          	addi	a4,a4,-2036 # 10ccc <uthreads_arr+0xfa4>
    64c8:	4781                	li	a5,0
    64ca:	6605                	lui	a2,0x1
    64cc:	02060613          	addi	a2,a2,32 # 1020 <linktest+0x104>
    64d0:	4811                	li	a6,4
        if (uthreads_arr[i].state == FREE) {
    64d2:	4314                	lw	a3,0(a4)
    64d4:	c699                	beqz	a3,64e2 <uthread_create+0x28>
    for (i = 0; i < MAX_UTHREADS; i++) {
    64d6:	2785                	addiw	a5,a5,1
    64d8:	9732                	add	a4,a4,a2
    64da:	ff079ce3          	bne	a5,a6,64d2 <uthread_create+0x18>
        return -1;
    64de:	557d                	li	a0,-1
    64e0:	a0b9                	j	652e <uthread_create+0x74>
            curr_thread = &uthreads_arr[i];
    64e2:	00779713          	slli	a4,a5,0x7
    64e6:	973e                	add	a4,a4,a5
    64e8:	0716                	slli	a4,a4,0x5
    64ea:	0000a697          	auipc	a3,0xa
    64ee:	83e68693          	addi	a3,a3,-1986 # fd28 <uthreads_arr>
    64f2:	9736                	add	a4,a4,a3
    64f4:	00003697          	auipc	a3,0x3
    64f8:	f8e6b623          	sd	a4,-116(a3) # 9480 <curr_thread>
    if (i >= MAX_UTHREADS) {
    64fc:	468d                	li	a3,3
    64fe:	02f6cb63          	blt	a3,a5,6534 <uthread_create+0x7a>
    curr_thread->id = i; 
    6502:	c31c                	sw	a5,0(a4)
    curr_thread->priority = priority;
    6504:	6685                	lui	a3,0x1
    6506:	00d707b3          	add	a5,a4,a3
    650a:	cf8c                	sw	a1,24(a5)
    curr_thread->context.ra = (uint64) start_func;
    650c:	faa7b423          	sd	a0,-88(a5)
    curr_thread->context.sp = (uint64) &curr_thread->ustack[STACK_SIZE];
    6510:	fa468693          	addi	a3,a3,-92 # fa4 <linktest+0x88>
    6514:	9736                	add	a4,a4,a3
    6516:	fae7b823          	sd	a4,-80(a5)
    curr_thread->ustack[STACK_SIZE - 1] = (uint64) uthread_exit; // Return address to uthread_exit
    651a:	00000717          	auipc	a4,0x0
    651e:	edc70713          	addi	a4,a4,-292 # 63f6 <uthread_exit>
    6522:	fae781a3          	sb	a4,-93(a5)
    curr_thread->state = RUNNABLE;
    6526:	4709                	li	a4,2
    6528:	fae7a223          	sw	a4,-92(a5)
     return 0;
    652c:	4501                	li	a0,0
}
    652e:	6422                	ld	s0,8(sp)
    6530:	0141                	addi	sp,sp,16
    6532:	8082                	ret
        return -1;
    6534:	557d                	li	a0,-1
    6536:	bfe5                	j	652e <uthread_create+0x74>

0000000000006538 <uthread_yield>:
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
    6538:	00003517          	auipc	a0,0x3
    653c:	f4853503          	ld	a0,-184(a0) # 9480 <curr_thread>
    6540:	411c                	lw	a5,0(a0)
    6542:	2785                	addiw	a5,a5,1
    6544:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
    6546:	4301                	li	t1,0
    struct uthread *next_thread = (struct uthread *) 1;
    6548:	4585                	li	a1,1
        if (uthreads_arr[i].state == RUNNABLE &&
    654a:	00009617          	auipc	a2,0x9
    654e:	7de60613          	addi	a2,a2,2014 # fd28 <uthreads_arr>
    6552:	6805                	lui	a6,0x1
    6554:	4889                	li	a7,2
    6556:	a819                	j	656c <uthread_yield+0x34>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS; count++, i=(i+1)%MAX_UTHREADS) {
    6558:	2785                	addiw	a5,a5,1
    655a:	41f7d71b          	sraiw	a4,a5,0x1f
    655e:	01e7571b          	srliw	a4,a4,0x1e
    6562:	9fb9                	addw	a5,a5,a4
    6564:	8b8d                	andi	a5,a5,3
    6566:	9f99                	subw	a5,a5,a4
    6568:	36fd                	addiw	a3,a3,-1
    656a:	ca9d                	beqz	a3,65a0 <uthread_yield+0x68>
        if (uthreads_arr[i].state == RUNNABLE &&
    656c:	00779713          	slli	a4,a5,0x7
    6570:	973e                	add	a4,a4,a5
    6572:	0716                	slli	a4,a4,0x5
    6574:	9732                	add	a4,a4,a2
    6576:	9742                	add	a4,a4,a6
    6578:	fa472703          	lw	a4,-92(a4)
    657c:	fd171ee3          	bne	a4,a7,6558 <uthread_yield+0x20>
            uthreads_arr[i].priority > max_priority) {
    6580:	00779713          	slli	a4,a5,0x7
    6584:	973e                	add	a4,a4,a5
    6586:	0716                	slli	a4,a4,0x5
    6588:	9732                	add	a4,a4,a2
    658a:	9742                	add	a4,a4,a6
    658c:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
    658e:	fce375e3          	bgeu	t1,a4,6558 <uthread_yield+0x20>
            next_thread = &uthreads_arr[i];
    6592:	00779593          	slli	a1,a5,0x7
    6596:	95be                	add	a1,a1,a5
    6598:	0596                	slli	a1,a1,0x5
    659a:	95b2                	add	a1,a1,a2
            max_priority = uthreads_arr[i].priority;
    659c:	833a                	mv	t1,a4
    659e:	bf6d                	j	6558 <uthread_yield+0x20>
    if (next_thread == (struct uthread *) 1) {
    65a0:	4785                	li	a5,1
    65a2:	04f58163          	beq	a1,a5,65e4 <uthread_yield+0xac>
void uthread_yield() {
    65a6:	1141                	addi	sp,sp,-16
    65a8:	e406                	sd	ra,8(sp)
    65aa:	e022                	sd	s0,0(sp)
    65ac:	0800                	addi	s0,sp,16
    curr_thread->state = RUNNABLE;
    65ae:	6785                	lui	a5,0x1
    65b0:	00f50733          	add	a4,a0,a5
    65b4:	4689                	li	a3,2
    65b6:	fad72223          	sw	a3,-92(a4)
    next_thread->state = RUNNING;
    65ba:	00f58733          	add	a4,a1,a5
    65be:	4685                	li	a3,1
    65c0:	fad72223          	sw	a3,-92(a4)
    curr_thread = next_thread;
    65c4:	00003717          	auipc	a4,0x3
    65c8:	eab73e23          	sd	a1,-324(a4) # 9480 <curr_thread>
    struct context *next_context = &next_thread->context;
    65cc:	fa878793          	addi	a5,a5,-88 # fa8 <linktest+0x8c>
    uswtch(curr_context, next_context);
    65d0:	95be                	add	a1,a1,a5
    65d2:	953e                	add	a0,a0,a5
    65d4:	00000097          	auipc	ra,0x0
    65d8:	db8080e7          	jalr	-584(ra) # 638c <uswtch>
}
    65dc:	60a2                	ld	ra,8(sp)
    65de:	6402                	ld	s0,0(sp)
    65e0:	0141                	addi	sp,sp,16
    65e2:	8082                	ret
    65e4:	8082                	ret

00000000000065e6 <uthread_set_priority>:

enum sched_priority uthread_set_priority(enum sched_priority priority){
    65e6:	1141                	addi	sp,sp,-16
    65e8:	e422                	sd	s0,8(sp)
    65ea:	0800                	addi	s0,sp,16
    enum sched_priority to_return =curr_thread->priority;
    65ec:	00003797          	auipc	a5,0x3
    65f0:	e947b783          	ld	a5,-364(a5) # 9480 <curr_thread>
    65f4:	6705                	lui	a4,0x1
    65f6:	97ba                	add	a5,a5,a4
    65f8:	4f98                	lw	a4,24(a5)
    curr_thread->priority=priority;
    65fa:	cf88                	sw	a0,24(a5)
    return to_return;
}
    65fc:	853a                	mv	a0,a4
    65fe:	6422                	ld	s0,8(sp)
    6600:	0141                	addi	sp,sp,16
    6602:	8082                	ret

0000000000006604 <uthread_get_priority>:

enum sched_priority uthread_get_priority(){
    6604:	1141                	addi	sp,sp,-16
    6606:	e422                	sd	s0,8(sp)
    6608:	0800                	addi	s0,sp,16
    return curr_thread->priority;
    660a:	00003797          	auipc	a5,0x3
    660e:	e767b783          	ld	a5,-394(a5) # 9480 <curr_thread>
    6612:	6705                	lui	a4,0x1
    6614:	97ba                	add	a5,a5,a4
}
    6616:	4f88                	lw	a0,24(a5)
    6618:	6422                	ld	s0,8(sp)
    661a:	0141                	addi	sp,sp,16
    661c:	8082                	ret

000000000000661e <uthread_start_all>:

int uthread_start_all(){
    if (started){
    661e:	00003797          	auipc	a5,0x3
    6622:	e6a7a783          	lw	a5,-406(a5) # 9488 <started>
    6626:	ebc5                	bnez	a5,66d6 <uthread_start_all+0xb8>
int uthread_start_all(){
    6628:	1141                	addi	sp,sp,-16
    662a:	e406                	sd	ra,8(sp)
    662c:	e022                	sd	s0,0(sp)
    662e:	0800                	addi	s0,sp,16
        return -1;
    }
    started=1;
    6630:	4785                	li	a5,1
    6632:	00003717          	auipc	a4,0x3
    6636:	e4f72b23          	sw	a5,-426(a4) # 9488 <started>
    struct uthread *next_thread = (struct uthread *) 1;
    enum sched_priority max_priority = LOW;
    int count=0;
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
    663a:	00003797          	auipc	a5,0x3
    663e:	e467b783          	ld	a5,-442(a5) # 9480 <curr_thread>
    6642:	439c                	lw	a5,0(a5)
    6644:	2785                	addiw	a5,a5,1
    6646:	4691                	li	a3,4
    enum sched_priority max_priority = LOW;
    6648:	4881                	li	a7,0
    struct uthread *next_thread = (struct uthread *) 1;
    664a:	4605                	li	a2,1
         
        if (uthreads_arr[i].state == RUNNABLE &&
    664c:	00009597          	auipc	a1,0x9
    6650:	6dc58593          	addi	a1,a1,1756 # fd28 <uthreads_arr>
    6654:	6505                	lui	a0,0x1
    6656:	4809                	li	a6,2
    6658:	a819                	j	666e <uthread_start_all+0x50>
    for (int i = curr_thread->id+1; count<MAX_UTHREADS;  count++,i=(i+1)%MAX_UTHREADS) {
    665a:	2785                	addiw	a5,a5,1
    665c:	41f7d71b          	sraiw	a4,a5,0x1f
    6660:	01e7571b          	srliw	a4,a4,0x1e
    6664:	9fb9                	addw	a5,a5,a4
    6666:	8b8d                	andi	a5,a5,3
    6668:	9f99                	subw	a5,a5,a4
    666a:	36fd                	addiw	a3,a3,-1
    666c:	ca9d                	beqz	a3,66a2 <uthread_start_all+0x84>
        if (uthreads_arr[i].state == RUNNABLE &&
    666e:	00779713          	slli	a4,a5,0x7
    6672:	973e                	add	a4,a4,a5
    6674:	0716                	slli	a4,a4,0x5
    6676:	972e                	add	a4,a4,a1
    6678:	972a                	add	a4,a4,a0
    667a:	fa472703          	lw	a4,-92(a4)
    667e:	fd071ee3          	bne	a4,a6,665a <uthread_start_all+0x3c>
            uthreads_arr[i].priority > max_priority) {
    6682:	00779713          	slli	a4,a5,0x7
    6686:	973e                	add	a4,a4,a5
    6688:	0716                	slli	a4,a4,0x5
    668a:	972e                	add	a4,a4,a1
    668c:	972a                	add	a4,a4,a0
    668e:	4f18                	lw	a4,24(a4)
        if (uthreads_arr[i].state == RUNNABLE &&
    6690:	fce8f5e3          	bgeu	a7,a4,665a <uthread_start_all+0x3c>
            next_thread = &uthreads_arr[i];
    6694:	00779613          	slli	a2,a5,0x7
    6698:	963e                	add	a2,a2,a5
    669a:	0616                	slli	a2,a2,0x5
    669c:	962e                	add	a2,a2,a1
            max_priority = uthreads_arr[i].priority;
    669e:	88ba                	mv	a7,a4
    66a0:	bf6d                	j	665a <uthread_start_all+0x3c>
        }
    }
    struct context *next_context = &next_thread->context;
    next_thread->state = RUNNING;
    66a2:	6585                	lui	a1,0x1
    66a4:	00b607b3          	add	a5,a2,a1
    66a8:	4705                	li	a4,1
    66aa:	fae7a223          	sw	a4,-92(a5)
    curr_thread = next_thread;
    66ae:	00003797          	auipc	a5,0x3
    66b2:	dcc7b923          	sd	a2,-558(a5) # 9480 <curr_thread>
    struct context *next_context = &next_thread->context;
    66b6:	fa858593          	addi	a1,a1,-88 # fa8 <linktest+0x8c>
    uswtch(&garbageContext,next_context);
    66ba:	95b2                	add	a1,a1,a2
    66bc:	00009517          	auipc	a0,0x9
    66c0:	5fc50513          	addi	a0,a0,1532 # fcb8 <garbageContext>
    66c4:	00000097          	auipc	ra,0x0
    66c8:	cc8080e7          	jalr	-824(ra) # 638c <uswtch>

    return -1;
}
    66cc:	557d                	li	a0,-1
    66ce:	60a2                	ld	ra,8(sp)
    66d0:	6402                	ld	s0,0(sp)
    66d2:	0141                	addi	sp,sp,16
    66d4:	8082                	ret
    66d6:	557d                	li	a0,-1
    66d8:	8082                	ret

00000000000066da <uthread_self>:

struct uthread* uthread_self(){
    66da:	1141                	addi	sp,sp,-16
    66dc:	e422                	sd	s0,8(sp)
    66de:	0800                	addi	s0,sp,16
    return curr_thread;
    66e0:	00003517          	auipc	a0,0x3
    66e4:	da053503          	ld	a0,-608(a0) # 9480 <curr_thread>
    66e8:	6422                	ld	s0,8(sp)
    66ea:	0141                	addi	sp,sp,16
    66ec:	8082                	ret
