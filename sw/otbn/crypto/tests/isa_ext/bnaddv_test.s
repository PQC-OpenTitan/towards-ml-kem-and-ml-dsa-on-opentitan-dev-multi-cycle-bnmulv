/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* 256-bit vector addition and subtraction example. */

.section .text.start

/******************************/
/*    Tests for bn.addv.8S    */
/******************************/

/* Load mod WSR with base li pseudo-instruction*/
li x23, 0x7fe001
csrrw x0, 0x7d0, x23

/* Load operands into WDRs */
li x2, 0
li x3, 1
li x4, 32

bn.lid x2, 0(x0)
bn.lid x3, 0(x4)

/* Perform vector addition and subtraction, limbs are 32-bit. */

bn.addv.8S w3, w0, w1
bn.subv.8S w2, w0, w1

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 512(x0)
bn.sid x4++, 544(x0)


/* Load operands into WDRs */
li x2, 0
li x3, 1
li x4, 32

bn.lid x2, 64(x0)
bn.lid x3, 0(x4)

/* Perform vector addition and subtraction, limbs are 32-bit. */

bn.addv.8S w3, w0, w1
bn.subv.8S w2, w0, w1

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 576(x0)
bn.sid x4++, 608(x0)

/******************************/
/*    Tests for bn.addv.16H   */
/******************************/

/* Load mod WSR with base li pseudo-instruction*/
li x23, 0x00000D01
csrrw x0, 0x7d0, x23

/* Load operands into WDRs */
li x2, 0
li x3, 1
li x4, 32

bn.lid x2, 96(x0)
bn.lid x3, 128(x0)

/* Perform vector addition and subtraction, limbs are 32-bit. */

bn.addv.16H w3, w0, w1
bn.subv.16H w2, w0, w1

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 640(x0)
bn.sid x4++, 672(x0)

/* Load operands into WDRs */
li x2, 0
li x3, 1
li x4, 32

bn.lid x2, 160(x0)
bn.lid x3, 128(x0)

/* Perform vector addition and subtraction, limbs are 32-bit. */

bn.addv.16H w3, w0, w1
bn.subv.16H w2, w0, w1

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 704(x0)


/******************************/
/*    Tests for bn.addv.8S    */
/******************************/

/* Load mod WSR with base li pseudo-instruction*/
li x23, 0x7fe001
csrrw x0, 0x7d0, x23


/* Load operands into WDRs */
li x2, 0
li x3, 1

la x5, operand7
la x4, operand7

loopi 256, 8

bn.lid x2, 0(x5++)

la x4, operand7

loopi 256, 4

bn.lid x3, 0(x4++)

/* Perform vector addition and subtraction, limbs are 32-bit. */

bn.addv.8S w6, w0, w1
bn.subv.8S w7, w0, w1

li x31, 0
li x31, 1
li x31, 2
li x31, 3
li x31, 4
li x31, 5
li x31, 6
li x31, 7

/******************************/
/*   Test memory extension    */
/******************************/
li x4, 3
li x20, 1024
slli x21, x20, 6
slli x22, x20, 5
slli x23, x20, 4
slli x24, x20, 3
slli x25, x20, 2
slli x26, x20, 1
add x20, x21, x22
add x20, x20, x23
add x20, x20, x24
add x20, x20, x25
add x20, x20, x26
bn.sid x4, 1024(x20)
bn.lid x4, 1024(x20)
bn.sid x4, 736(x0)


ecall

.section .data

/* 256-bit integer
   0000000800000007 0000000600000005
   0000000400000003 0000000200000001 
   (.quad below is in reverse order) */

.globl operand1

operand1:
  .quad 0x0000000200000001
  .quad 0x0000000400000003
  .quad 0x0000000600000005
  .quad 0x0000000800000007

operand2:
  .quad 0x0000000200000001
  .quad 0x0000000400000003
  .quad 0x0000000600000005
  .quad 0x0000000800000007

operand3:
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff

operand4:
  .quad 0x0004000300020001
  .quad 0x0008000700060005
  .quad 0x000c000b000a0009
  .quad 0x0010000f000e000d


operand5:
  .quad 0x0004000300020001
  .quad 0x0008000700060005
  .quad 0x000c000b000a0009
  .quad 0x0010000f000e000d

operand6:
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff

.globl operand7
operand7:
.quad 0x004021c3004238b2
.quad 0x002b76c8001b1240
.quad 0x003ad74c00757a27
.quad 0x002117040006c8a9

.quad 0x007e066a0030d5c2
.quad 0x0079cbc40005d82e
.quad 0x001b18be005ec155
.quad 0x0019a873006127df

.quad 0x003e79ec00267402
.quad 0x00474f660021fdd7
.quad 0x002506980038edd9
.quad 0x0013b7f6001f4e93

.quad 0x0055d28c0000bae4
.quad 0x0042543b007ad521
.quad 0x001cfab70062485d
.quad 0x006c76c7006df357

.quad 0x001b0ef30074c983
.quad 0x004d50ba004e6e63
.quad 0x006faac8001f1986
.quad 0x00744570002ad076

.quad 0x0053cf3c0012c554
.quad 0x000c2a65005a5be4
.quad 0x00746f78003070ea
.quad 0x0062beb3004319bb

.quad 0x005d92aa002981c9
.quad 0x0050aee7004af07b
.quad 0x0058ca4e0017c7b2
.quad 0x006dac48007e8063

.quad 0x0045d365001177d7
.quad 0x0076baa1005d58a0
.quad 0x001fbdb80001640c
.quad 0x000699380058f44e

.quad 0x00528db40028fc25
.quad 0x006b84d00073213a
.quad 0x00149d0c00140c10
.quad 0x001debe00079bf24

.quad 0x0021cb5b0052fa40
.quad 0x0014193700261e4f
.quad 0x000450f20027038a
.quad 0x004485fd00796326

.quad 0x000645b300305f6b
.quad 0x0029c2c40026a09b
.quad 0x001455e40039f5ac
.quad 0x007d09b1002a1d28

.quad 0x0068cd94006c5e89
.quad 0x0044ea700072c053
.quad 0x0041d84a005a07cd
.quad 0x007c02ee00724ccb

.quad 0x00313c210044cf7c
.quad 0x006df9ff001e84aa
.quad 0x00373e0e007437f4
.quad 0x005cf70d0049f279

.quad 0x00332af5000a6623
.quad 0x000ec97b00427cf7
.quad 0x002e1645005dbf84
.quad 0x00405be0000131cd

.quad 0x0004190b0001990e
.quad 0x002954f600040aed
.quad 0x0048311b002052be
.quad 0x0013e739003a92b7

.quad 0x003f12c400045e1f
.quad 0x0006d362007e8f6b
.quad 0x0008e72c000c874f
.quad 0x0038de46003a7ec1

.quad 0x00430e2e0016b9f2
.quad 0x0076242a00125fb7
.quad 0x000048d5004757c5
.quad 0x0042ee1f003a3504

.quad 0x006ece85005ae3b3
.quad 0x00241dd300220671
.quad 0x00282c58001fa491
.quad 0x006c8b1100544c83

.quad 0x003b47b8004c3ac2
.quad 0x003523e9005f85c6
.quad 0x005af2f0005c0389
.quad 0x0005e8e90037d370

.quad 0x007f42b3003e2961
.quad 0x003797ee0012d54e
.quad 0x003935fe000087d7
.quad 0x003921af004cc6af

.quad 0x0076d65d005f6174
.quad 0x001f1bbe0009634c
.quad 0x0068bd8c0072f390
.quad 0x0035eb3100239a0f

.quad 0x0030d2190010e7bd
.quad 0x003bce850050319f
.quad 0x00123ebc00340bef
.quad 0x0048ff6d007363e7

.quad 0x001ec6800069afb2
.quad 0x00038d79003c7e2b
.quad 0x003545b9003aa78e
.quad 0x006eea7b000daf33

.quad 0x007fc855004ef454
.quad 0x002262db0068662a
.quad 0x004637230014fa73
.quad 0x0018c0a200476f71

.quad 0x006c83da003195df
.quad 0x003b81690060ea22
.quad 0x0063d89e007579a1
.quad 0x004ad091001d53af

.quad 0x00145f9f00306027
.quad 0x005543100033cf81
.quad 0x0035b8ad004d5e7c
.quad 0x002b0b990071826a

.quad 0x006b35c90058a735
.quad 0x004fea620065274d
.quad 0x00387d7c001cb7c1
.quad 0x0037ad39003f7894

.quad 0x0031f7cd0003c07e
.quad 0x000ba7b60023e479
.quad 0x0059e7e3003e5793
.quad 0x0034e5360063c93b

.quad 0x004cd68b005378d5
.quad 0x007a8053002c4283
.quad 0x00393c1b00485197
.quad 0x004d4c6300660d6d

.quad 0x00798531004e09f2
.quad 0x0056829900516900
.quad 0x00686876002dd4d4
.quad 0x000374f60077502b

.quad 0x00425630002b423e
.quad 0x00481b68000d03e7
.quad 0x0009faff00292f4f
.quad 0x001b6fad00484a45

.quad 0x004edcd3000ac16a
.quad 0x007ab6c5003e7a64
.quad 0x002be25a000e0027
.quad 0x0024b5f5007bfd4f

.quad 0x004edcd3000ac16a
.quad 0x007ab6c5003e7a64
.quad 0x002be25a000e0027
.quad 0x0024b5f5007bfd4f


.quad 0x00720448003c0541
.quad 0x002692ff0026e17b
.quad 0x0006e2370054613c
.quad 0x0079022f0017f43b


.quad 0x004241c900364d88
.quad 0x00338c34001de028
.quad 0x004ecc32006d09fc
.quad 0x001bf6fb00045c41


.quad 0x00088fa0007ae635
.quad 0x004622aa005f48e2
.quad 0x001ddae1004e3ca8
.quad 0x00016b6f00744293


.quad 0x0072b90b0049213c
.quad 0x0063efc60034d273
.quad 0x002da8320042a58e
.quad 0x005c0dc6001d9f7c


.quad 0x007099b400276a78
.quad 0x007a97ca00427055
.quad 0x001a5a3a00540dda
.quad 0x0031b2ae0069c66d


.quad 0x000d6ebe0050ae9a
.quad 0x0048ee70007db73e
.quad 0x00667b84006deb31
.quad 0x001dcdbd006b06d0


.quad 0x003bc7270000ccdb
.quad 0x002f0b9e00302f8b
.quad 0x00122593004cc45f
.quad 0x0004e579002337e9


.quad 0x0046f07800669a6d
.quad 0x0044fd7f003a09fd
.quad 0x006f1a86004c1ec5
.quad 0x0015e414003083e4


.quad 0x00773aed0015c249
.quad 0x00726534006c61da
.quad 0x0034a9a6001cb98d
.quad 0x00561f4f00126667


.quad 0x0029c1da003575b4
.quad 0x0004f460006c535f
.quad 0x0037a478005213ae
.quad 0x0061025400472f2b


.quad 0x001e91190060bbbd
.quad 0x0059c98a0042dd4f
.quad 0x0056a0490063ad92
.quad 0x0055bf700011ff3f


.quad 0x00373f190040ce84
.quad 0x00486845004acea4
.quad 0x001e4c4800014a6a
.quad 0x007f17840021fa95


.quad 0x007eae04007fc9ea
.quad 0x002ca80c001702e9
.quad 0x00503a170005dd5d
.quad 0x007e5cde001d71aa


.quad 0x006c54ef00530e07
.quad 0x001fc9310067e1b3
.quad 0x0060d435003a6f94
.quad 0x00565830004c90ce


.quad 0x0009f86d0026aaf7
.quad 0x0058286d005b1341
.quad 0x004f1f73005c0dcc
.quad 0x00687f190050f2bc


.quad 0x001cab61005d3f14
.quad 0x003453e0000dec3a
.quad 0x00615be40011df14
.quad 0x0062f12600214ed7


.quad 0x00017ab60025b85d
.quad 0x0074bfe10079a1f2
.quad 0x000904dc0004daf6
.quad 0x005f1022006a2b90


.quad 0x0070d3d6003a779d
.quad 0x0037caf30042b0d3
.quad 0x007a40a50053b262
.quad 0x0073101c00488484


.quad 0x00696893000b9983
.quad 0x0062829f000521d4
.quad 0x005142f90022aa84
.quad 0x004e333100082da0


.quad 0x0061915b00186218
.quad 0x001631f1005d2545
.quad 0x001e2713001a99e0
.quad 0x004def4c00523162


.quad 0x007f4512000a7109
.quad 0x007a7458005ba09e
.quad 0x000b8ee7004cad5b
.quad 0x005fba6e001ef88b


.quad 0x001a8ae50044042b
.quad 0x001b67dd0048512e
.quad 0x006bf5d000258301
.quad 0x007eaf3f00019f99


.quad 0x002ef61d00162744
.quad 0x000bcf8c0023b6fd
.quad 0x0037fdad0064eaca
.quad 0x005cd774002cb4cd


.quad 0x000947f100534c8f
.quad 0x004bfa0f0036deeb
.quad 0x001fb6af00686a31
.quad 0x00730ee900286af0


.quad 0x0014c0f500260039
.quad 0x002034b70078fda0
.quad 0x004af4d30078c0cd
.quad 0x00091a7e005f0aab


.quad 0x003435000067996b
.quad 0x0065e24800085954
.quad 0x000d29250023f70c
.quad 0x0052ed5e0077482e


.quad 0x004e8ed8003276f3
.quad 0x00681465005289ba
.quad 0x00728f62004d3a1a
.quad 0x00448df0007c2507


.quad 0x00684d1f0078f7b8
.quad 0x005017f300132dc7
.quad 0x0042471b007c406b
.quad 0x003a0882007f7a75


.quad 0x002f316f002f26c3
.quad 0x0013aca9004ebe3b
.quad 0x00073a1900232b46
.quad 0x006457ca002ce36e


.quad 0x006ed959003fd96c
.quad 0x0010cca2002bef59
.quad 0x001bfe530022027a
.quad 0x001655470008b5a0


.quad 0x0013f7e60029db94
.quad 0x006ede1c00150867
.quad 0x00792d4600551011
.quad 0x0025e16b00516ff0


.quad 0x1ed5704e1a968012
.quad 0xfa77ecd50a841ef3
.quad 0xa2050804ba8cd469
.quad 0xf2fb4c0a76ffdb0c


.quad 0x5e1ac56adb88ea58
.quad 0x0469dcb51aeac763
.quad 0xe3a028c3c3f01139
.quad 0x37f61c181728dd37


.quad 0x251d5fbccdef151f
.quad 0x0b89cbd22e0a720c
.quad 0x473183a45b02d828
.quad 0x52105947d5ff0809


.quad 0x6f727cd860361ec4
.quad 0xd6f1fd6d4b0cd221
.quad 0x243702958a9cdbd5
.quad 0x7808bc80a073e5b8


.quad 0xf3fb1afddfcf348e
.quad 0xe06739c7349d0955
.quad 0x4d3defbb8bc754ed
.quad 0x5d954b026dbdbd53


.quad 0x33b378253404731e
.quad 0xabc8f2018798db57
.quad 0x3785bf03a27e5501
.quad 0xcdd8277fd58d4c79


.quad 0x234195ae98c145e6
.quad 0x4a41c39e62c9536a
.quad 0x5425e126eeda956a
.quad 0x94241ace6cc7d521


.quad 0x7824f85c46fa186f
.quad 0x982974b7cef0ce81
.quad 0x4dbf107be2151720
.quad 0x9a510557d4214524


.quad 0xa65915070cdf6830
.quad 0xc4240302276b0c3a
.quad 0x2af78b081e21ffbd
.quad 0x211ac1fcde67349a


.quad 0x3606f2caf21b2de6
.quad 0x723c28465338959e
.quad 0xc17343470d4e2198
.quad 0xa5d453948bbd85a2


.quad 0x1cd3d4044fc21761
.quad 0x865151516029ce79
.quad 0xaf5bdf99a9224d81
.quad 0x5b75460d6141d275


.quad 0xc6434b2f542e9bd2
.quad 0x53e38bf74ffffbcd
.quad 0x0adbec4ed03fc8f3
.quad 0x2d1ad73951bcaf22


.quad 0x8fc2c139081ac04e
.quad 0xdf8d95dc01b9e0b4
.quad 0x1ba38b57c0c4eec8
.quad 0xabe1ad367200a212


.quad 0xd176796aed8f3192
.quad 0x4ab0b3ff32fd1eb8
.quad 0xda4c357e47f5ec69
.quad 0xc0831ac734a5e6f4


.quad 0x381d4db6863d45fd
.quad 0xc92129725bf936b9
.quad 0x8555bb8e18df516e
.quad 0xb16dbd01936a64ac


.quad 0x35ebaea33ea1c856
.quad 0xec49ca1850c1c2a7
.quad 0xecd50fabcaa7f6c0
.quad 0xc6e661602319cb7c


.quad 0xe041d2b0bc967d1c
.quad 0xe0d5f68c2e0ec657
.quad 0xc856778e969f5efc
.quad 0x47299e13ba7abd9a


.quad 0xd3f6a61690332bd3
.quad 0x57c2957a31263e7b
.quad 0x1b7c7727876140e7
.quad 0xe532593073450ae1


.quad 0x4c6510286e7a3c36
.quad 0x49f6e922a8a73e8a
.quad 0xc12a6b1a3f6ce14a
.quad 0x9d2ceffd8d90b52b


.quad 0x4f2859c2340290e2
.quad 0xe0f54b6e56fbada7
.quad 0x82b79bbb6b534a0f
.quad 0x393efae313b3cdf5


.quad 0xc90994da928196c5
.quad 0x1ef7f54a2d115baa
.quad 0xa541402e444a0a84
.quad 0xd468438e9e2c824f


.quad 0xb89eb620a052a1dc
.quad 0x197f9d97f9d91203
.quad 0x3e42edfb92d1b8fa
.quad 0x3726504c0ad2bd00


.quad 0xcaf46d023428741d
.quad 0x9d5c7d488b5779b7
.quad 0x1a6cb90863f4cd2f
.quad 0x933ddb859d6cfcf9


.quad 0xf40b8b4d1d780545
.quad 0x0ceda0e0a465f46a
.quad 0xc5c9fe0238ae7258
.quad 0xd742914e8ac86b5b


.quad 0xebf46b3bec429131
.quad 0x485b0da03fba44ca
.quad 0xfb3742c86ad1ea1f
.quad 0x9197cdaa0ac6d859


.quad 0x2cbaf059a1bbf927
.quad 0x006804f019ad7add
.quad 0x86448ddca51ad145
.quad 0x29aebcbed2948b67


.quad 0x9d821b384a6c8bbb
.quad 0x4d11f5d7b668e5d5
.quad 0x2205124a268db51b
.quad 0x720e159d352797a9


.quad 0x2cf0f5a8dbfaa3bd
.quad 0xea09e957d8f84c40
.quad 0xcab95d0b7f661a4f
.quad 0x2443503aa32c527d


.quad 0x983bc15ddb23bb56
.quad 0xbe7bd3fe2a0b5e38
.quad 0x012f3444ea5465ab
.quad 0xe36dc6e0fc06b124


.quad 0xbd7625166cc267a8
.quad 0x3a3607c7e5e79661
.quad 0xe38b73c260774d4f
.quad 0x3e3bf1ee4e64932b


.quad 0xf07b0295d1dad358
.quad 0x2f7bf2b1b8aaeb1a
.quad 0x1c30c627e3fe59c8
.quad 0xc5f8432024a89472


.quad 0x1383786889719d09
.quad 0x1f0a373d1a53aea8
.quad 0x0968f4c2cd51efa6
.quad 0x5720884b4663ffff


.quad 0x6d670d4517ab0213
.quad 0xa11ba1a73a0a78af
.quad 0xc2d8aa353d6d46fd
.quad 0xba55ff995b56cc8f


.quad 0xde880358dfc2a45f
.quad 0x4066fe022b3b799c
.quad 0xb9051eb4b75ae545
.quad 0xfb8b3a1e66377599


.quad 0xc8a311be01e740da
.quad 0x7a2c80ff2371a9ff
.quad 0x617f24a4bec271c1
.quad 0x487a4e618380377b


.quad 0xed2f48fdf2529609
.quad 0xec16919c6ad225f4
.quad 0x3e6aea6410d21f74
.quad 0xab0d49da4eb64604


.quad 0x367466a75e5d330d
.quad 0x22fc1d4b143120bf
.quad 0x294aa139e5c6a055
.quad 0x94d2495161e563d6


.quad 0x4f6721843034104c
.quad 0x2bce9aa3d320e392
.quad 0x227e8dffabfffaec
.quad 0x00959e31e7bcf2af


.quad 0x473a80147aad5d6f
.quad 0x8847c9c4efe448af
.quad 0x172ecfe96d3ae1a8
.quad 0x5a61a3be4dbf871d


.quad 0x60703e905848b06f
.quad 0xef4594f9229d5eed
.quad 0x429caee332edd5b3
.quad 0x52ea87dad71c225b


.quad 0x8ec67679ef985b2f
.quad 0xc4048d58e6c9437a
.quad 0x97ffb69ffd6092b4
.quad 0x7e46e459fc0d3345


.quad 0xb44068f87f5f0c1b
.quad 0x8885be19325f054b
.quad 0xaea67e9fc191a05e
.quad 0x593e02d9656dc5b0


.quad 0x9235bfd13879eee6
.quad 0x6f049fb46db9af2b
.quad 0xe2bfca058d445f43
.quad 0x9684789f53598f9c


.quad 0xa9bf4410f45054d8
.quad 0x57b5f2b615556b77
.quad 0x0fdbd32ee6aea7bb
.quad 0x30bfd591af014e84


.quad 0x532ff690602378b2
.quad 0xe629483802ed9e8a
.quad 0x66ddc1bf4f0caf83
.quad 0x99722a409706acbe


.quad 0x83881f1e4f734b05
.quad 0xc056c23116400446
.quad 0x6da93d285db01185
.quad 0x3137b6e201d39c30


.quad 0x00baa028a5fde205
.quad 0xaa12c561717aa134
.quad 0xb1108b9b4c3247a4
.quad 0x4c47ee73d5af28a7


.quad 0x40b70b92b40492f2
.quad 0xcd535c6ba4916d39
.quad 0x27f36668db8fa204
.quad 0xacb8c74f5514554c


.quad 0xcfb26f3febdf336c
.quad 0x2f81356773a55326
.quad 0x290673f9ccdd0b3a
.quad 0x806cfb08bd633fb4


.quad 0x757bac3a178d1f23
.quad 0xc01662e91f78edbe
.quad 0xa429cf7f6ec6f087
.quad 0x29a1261f24f8b819


.quad 0x091c7705cfe15b7e
.quad 0x049c905e86d787c4
.quad 0xb23679d25b8e60cc
.quad 0x3fe9058204623c31


.quad 0xe28592c55fe7147b
.quad 0xa4fc85f0dea41585
.quad 0x8807495ac9f10747
.quad 0xda28fb4f38b3eb8f


.quad 0xa3f0fb7563c2e88d
.quad 0x796e3d58b6c5c479
.quad 0xda55d34fa100a4d4
.quad 0x0838367e029cd319


.quad 0x8f421d9190fb5966
.quad 0x2440b5976149529b
.quad 0x98d0c14a73dd0bf9
.quad 0xfb9ba0d8b73da095


.quad 0xcfcfe57616ff9b8e
.quad 0xfa32f14b8f072978
.quad 0x7ca5e2e7b261c86e
.quad 0x1aff1a32ca7b4ff6


.quad 0xa856ebdf6e724599
.quad 0x069754ff7935c5f1
.quad 0x182d5166bbb921ed
.quad 0x137fc19925eca7f4


.quad 0x33fdce1d194f827f
.quad 0x15eeabe5c3ff27c0
.quad 0xbf3f4b7a239a2029
.quad 0xe2a8fccdb622fa57


.quad 0x5f371526692767e1
.quad 0x8f2cffd581a085cc
.quad 0xe88d55b4ca2ddd8d
.quad 0x6800e594386bb9c8


.quad 0x251377f541a1647a
.quad 0x1d7c18177bbc9b0c
.quad 0xb090f037b0c3abd2
.quad 0x8914e1bab94a5159


.quad 0x4752d6ed4a380bcc
.quad 0x20c75fb108742198
.quad 0xe04b2cc03798274d
.quad 0xba2e0d7d0f6eafa1


.quad 0xc9f52ac43648d727
.quad 0x88a233867549174d
.quad 0xa8c858fedc5e6fef
.quad 0xe93ab8df3314fb06


.quad 0x185b2e454dc76637
.quad 0x962f25e7cdb96e9b
.quad 0x75e55e2fbd9684ec
.quad 0x4f0cfc429ead8e35


.quad 0x96528607803c8c6c
.quad 0xb3ad9ab85acddd60
.quad 0x8bdaa70d97187fd9
.quad 0x3d971b93b029d5e2


.quad 0x2339afdf0b73bd66
.quad 0x42b4a18436f880a2
.quad 0x0c502ee107544867
.quad 0x26a48bd872de3df1

.quad 0xc61147a6a578cb6e
.quad 0xf1114e41729ecff8
.quad 0x5e062a6c877163ee
.quad 0x87ebbde56add6a6e


.quad 0x1a53ba5c98c77dc2
.quad 0x6fa2febe50480a75
.quad 0xf059451c663a39ae
.quad 0x49dde503ce75f4b5


.quad 0xf278bd307fd25569
.quad 0x80d4108c13f7c4d5
.quad 0x186460300bd634ec
.quad 0xc57e7b846ff3118a


.quad 0x61da65f79b7d9ec3
.quad 0x53503bd8bda039d5
.quad 0x804b0365b3a85b58
.quad 0xf86928914280efdb


.quad 0xabd56e3d88cec2c1
.quad 0xc09bc12c3be9aaf4
.quad 0x499e7b4f58d6dbcc
.quad 0xeb9a7d0d52237c26


.quad 0x830cace40d0df8a9
.quad 0x8701a8f7b3ab0c5d
.quad 0x33ee1b2fde198497
.quad 0x92cda20256912ec9


.quad 0xd0adc339c5211035
.quad 0xf97e7714bf1dad87
.quad 0x0ba92a66b5e24e86
.quad 0xf49814b6ec5f06c5


.quad 0x6184c3e268a47cac
.quad 0x187bf365716a37c9
.quad 0x49e2da1d9eb7177c
.quad 0x95b5607691457b32


.quad 0x70229476f5d2f59a
.quad 0x44ba173c5454c2f9
.quad 0xefd5a01d54002bd2
.quad 0xccd35808cc169c1d


.quad 0xfafdb0c492930749
.quad 0x6a69965af1119196
.quad 0xe53d3722cc9b060e
.quad 0xdd2e25e8b46d60f4


.quad 0x5fdfc3b17032d79f
.quad 0xbf4c80cea0b6b865
.quad 0x978bec8ea6bec253
.quad 0xd04c6518df9cc554


.quad 0x4c4110c16481756a
.quad 0xd4592941e86f7578
.quad 0x4cef7ac16153672c
.quad 0xf79907bc8319373d


.quad 0xb97e022fe21da5bb
.quad 0x8b3d817b94e7030e
.quad 0x78d550969bdff42d
.quad 0xa0819448a2ac52cf


.quad 0x9033ee686216bce1
.quad 0xca2840db751f7668
.quad 0x044dce77cc22e868
.quad 0xb57b8ab06bf8ce5b


.quad 0x205e809b59d68e0f
.quad 0x4518ce0053f9a2c8
.quad 0xd8e9cda7247c3dcf
.quad 0x9e194a8f2a8046c2


.quad 0xee57215a7112293b
.quad 0xe28669ea0f85ac70
.quad 0x346865a2b12482b8
.quad 0x3d22cb74584559bd


.quad 0x2e758cfe4190810b
.quad 0x9e3d97a57c775d69
.quad 0xf51b9e7d5c7ea146
.quad 0x8a66968142471366


.quad 0xf130968a5d1eb271
.quad 0xf67742402ead337c
.quad 0x2610e0b519e5f10d
.quad 0xfb232b5239fa4b9c


.quad 0x90bfc2783f2e51ca
.quad 0x99ddf7820cb47541
.quad 0x8d6cc980c34b8857
.quad 0xa7879d3e64910c57


.quad 0xca705743c36a3f9f
.quad 0x0e44adb5b3803308
.quad 0x4f9e6a14acc0c0f2
.quad 0xa914524579c9f971


.quad 0x817cf40d8d6d3c66
.quad 0x58b9c17b856ee050
.quad 0xe2957370c03d6dd9
.quad 0xc188690cb0e7f4d0


.quad 0xfe9841a59e8b4f1b
.quad 0x2108707d918a653a
.quad 0xe2a0423534624009
.quad 0x691044846dce3ba7


.quad 0xd5aa42f1a0ab2972
.quad 0x96e84701b7ec4d69
.quad 0xab3d2d9836b727d1
.quad 0x4bf8b3dfc7f79b55


.quad 0xcdf1003594919012
.quad 0x658fcd8989e7f7cc
.quad 0x3a11002fd779396a
.quad 0xd916314a9e337b15


.quad 0x5c06730308844494
.quad 0x8ab4860f2438788b
.quad 0x54888a363c3d24c4
.quad 0x18aebd8e7589fbcd


.quad 0x14888bc2100837b2
.quad 0x80941975b8c2d064
.quad 0x404658276d095cc6
.quad 0x7d7ccc51b60dd616


.quad 0x921074e60b9d5897
.quad 0x1366b99f9722b94b
.quad 0xac6e47fd4fb635d0
.quad 0x3ac6b789e47f5ea2


.quad 0xd66ec3b6ecfc0f98
.quad 0x6fae82d32fffc422
.quad 0x8b993f252b3f3555
.quad 0x0079ca6619fac60b


.quad 0x35fea9afc57cf0ae
.quad 0x3f3be73475a264c3
.quad 0x31bbd110f07ed07c
.quad 0xaf173814652f2c7b


.quad 0xce25fb6ac9416820
.quad 0x8392fe30e524d42a
.quad 0xfccd4279535208c8
.quad 0x763b230842b123c0


.quad 0xbf219ea69d7f63e4
.quad 0xcb730a90024667ca
.quad 0x9fc4f21efbef1a1a
.quad 0x5b5ace5199a8aa91


.quad 0xc91995a9597a8c1d
.quad 0xadb82ea1fa3c1bb8
.quad 0xf79d3c0dcd291450
.quad 0xb1f5b1a45039d954


.quad 0x3337ebe2e5739d09
.quad 0x7954eade969c195e
.quad 0xa8b6b279766f7311
.quad 0xf1bd5ba540a8b883


.quad 0xcc4e2234a62c1fce
.quad 0xbf67adb735eb779f
.quad 0xf53fa615572d6a60
.quad 0xb1e5afb3e4c63c85


.quad 0xe196cfe9f157a60b
.quad 0x764559460ff2edcd
.quad 0xa1d5b06434e5eba6
.quad 0x7eb4c3d9b57779c3


.quad 0x49eefa210909d3e6
.quad 0xd252762a0fe2bf2d
.quad 0x759e18889d52ff09
.quad 0x7e0b5b076debdf31


.quad 0x45451d00fcfb3988
.quad 0x8945c64492f505e7
.quad 0x71dd487b3bf4ae3d
.quad 0x1366959d3b491765


.quad 0x0e7517cdd86254fd
.quad 0x0218d43fd71b6b3c
.quad 0xea893e8515e0120f
.quad 0xdbc08d7afeff910d


.quad 0xbcb455bf88ad69ea
.quad 0x1a70c02bddfec896
.quad 0x6adc82a5406d5ac6
.quad 0x0fff3a26ccef8357


.quad 0xd9fb9678bf603ed0
.quad 0xba3dbf4e48ef3a9c
.quad 0x86d78023c36054e1
.quad 0x49072ef751053a47


.quad 0x7608697cdc64c269
.quad 0xebe1235837acd8e0
.quad 0x2efec33709f1641d
.quad 0x966e8b4792eadea9


.quad 0x706bdfc7055ad42f
.quad 0xf51729ad8ba8f2ae
.quad 0x2bd1d6ee6f0ddba3
.quad 0x1489a40737ab1ad3


.quad 0xe8542cc8e44fd4d5
.quad 0x3884e7b5c30f4543
.quad 0x859c67ea7acbc71e
.quad 0x93048dd69d69ef72


.quad 0xfa68b6550006f6de
.quad 0x7f146a0ab78c8f9e
.quad 0x0da29e25397760c1
.quad 0xdf75055299a349af


.quad 0x22f23a59adab928a
.quad 0x239649e06e9a1665
.quad 0x423dfc70664d9b23
.quad 0xcca2ea7e7ded3865


.quad 0x3b70d28f23cc5c91
.quad 0x448b03b802ece834
.quad 0x362cd6bca8a5b11b
.quad 0x07d5808f3779b13c


.quad 0x8504f795d2adcaa9
.quad 0xe45c6ca56c882f0a
.quad 0xc2a7a205b29a8fdd
.quad 0xecd7c9d29badbf24


.quad 0xa49af1db293965ad
.quad 0xaf734b1ff26a914d
.quad 0x05111e8596965693
.quad 0xe4bf5e3f32df4d52


.quad 0x547cb98448923fa1
.quad 0xe0f364b0efe7a003
.quad 0x3bb7eb6c4b322e92
.quad 0x624f3ff1e5286a20


.quad 0x7bc84c55a5e80475
.quad 0xc1054389700f17d5
.quad 0x59e5512416eefee4
.quad 0xcc6157c4c34876fd


.quad 0x7bfeb450c2a8bf9b
.quad 0xe474b07c00b45c44
.quad 0xcb0628573312d8f2
.quad 0x97040e1fa4f33800


.quad 0x8cc07cf18168d801
.quad 0x80497206eda96601
.quad 0x51ed5f9264c03e8e
.quad 0x3652378de3b3e773


.quad 0x2e212836750fd0cc
.quad 0x9096eb82717a37b2
.quad 0x1a9919174f411e3d
.quad 0xcd0dacd09e3ccdd3


.quad 0x26477f48e2bf4651
.quad 0x52ae1f85738000e8
.quad 0x625f333c763cb070
.quad 0xd4d5c1268dbc87a5


.quad 0xcd52e73b9bbeaf81
.quad 0x92d1371918bdc057
.quad 0x48a765811fcd55a8
.quad 0x1ae50f394fc5cb88


.quad 0x613bb621c19662ac
.quad 0x05d90a9decbf716b
.quad 0x639fcffb833fe890
.quad 0xe5bde26504d00267


.quad 0x2c442d91624e22d0
.quad 0x4c4fb1a717f3e171
.quad 0xd71f19c0bd2fd494
.quad 0x5bea13ed703ca949


.quad 0x307fcf9f9dc32047
.quad 0x8381f9dec963f4eb
.quad 0xf0edfc8ac342a691
.quad 0x21a41daa44657231


.quad 0xcf06b60f3c7c560b
.quad 0xd2cdeae81726bbed
.quad 0xf60ff833b802303e
.quad 0x25dc36c0e14ffcdc


.quad 0xbf7552ce3112d2a0
.quad 0xafb310b832d2c1ed
.quad 0x1b9af64cbc72ad92
.quad 0x8f6f20145ce4fe9b


.quad 0x1fdc91f86843ab4e
.quad 0xb4f58164f1694724
.quad 0xd193a45c49035078
.quad 0x316c702fff033e17


.quad 0x39b818855cbdb1c9
.quad 0x572c8bc19368d34c
.quad 0x779a2993a70ca8b5
.quad 0xcf020fc7c6bda316


.quad 0xba1890e1d275caaa
.quad 0x90ad74298d21c3d8
.quad 0xb3cc8b4454d91ce8
.quad 0xbf9261084189a424


.quad 0x1f2c857471656a17
.quad 0xd36b1aa322d13e6f
.quad 0x46adf2c605be95b2
.quad 0x32792eb43031e492


.quad 0x8327a71a4d4b1641
.quad 0x7fb5c1eabfc2ae7c
.quad 0xd342a7cdecb67ea1
.quad 0x811e3707752aebef


.quad 0x30253964fffa3f78
.quad 0x2494eceb8a7cda26
.quad 0x31d16344f437694c
.quad 0x88736f16cd566312


.quad 0x4ec90dbb70114b63
.quad 0x687ce32bc746c4cc
.quad 0x6b65b83ab065a0a5
.quad 0x272ef8d2ae891541


.quad 0x0fc5e5bb39b88d9f
.quad 0xbfb19f8fb7370e13
.quad 0xb49b2732ce7c42c5
.quad 0xad6a3fa1f74cb67b


.quad 0x4d6ef4f21e6476a5
.quad 0x003d54352510b39e
.quad 0x5d3f2a42d6578463
.quad 0x9ca728d2e25a4fb3


.quad 0xe9223f892310c673
.quad 0x0ca7fbd89399d193
.quad 0x009e885fac7bd85b
.quad 0xf33bf660b778adf7


.quad 0x328ccf01f4e2839a
.quad 0x23f3270228db20ab
.quad 0x8fff51d39db03c2a
.quad 0x244f1c8388cd18fc


.quad 0xf9e1ddab3cbccb88
.quad 0x2b20a3c0ce2a60d3
.quad 0xb02f32b50af7da43
.quad 0x119baff8d079a94e


.quad 0x185421f34922dcf6
.quad 0xc9d8c55515963d7a
.quad 0xa4db1e7556d2f8ae
.quad 0xf59722580ac07dc1


.quad 0x457caf45b18702bb
.quad 0x15942f76a4d9f0f3
.quad 0xb1359560f13a3a40
.quad 0xc7276e0e5dea3092


.quad 0xa91ffd163d501d82
.quad 0x5f2d1a2261dd47f6
.quad 0x020f7e474aa05f5e
.quad 0xea4750d168af4b35


.quad 0xe6d706f85a36fcd1
.quad 0x6e81f8c75c84a89b
.quad 0x36593b6774656481
.quad 0x574d43c7b02d3262


.quad 0x73d4e51a990bac83
.quad 0x8fb8dd69bda1c38d
.quad 0x0c054ddf2613c278
.quad 0xd3442362bb04bc87


.quad 0xf0e08f26c4f38aed
.quad 0xe9c7c49cd2a3907a
.quad 0x1edc6be310176b42
.quad 0x13227bd57418af3f


.quad 0x16f20ee4799e7250
.quad 0xf2d00ee9d5a8ef64
.quad 0x588d30676c981d98
.quad 0x1fecbbd152d1dee2


.quad 0x3a17bb354adf711a
.quad 0x7bd2d8c245de4009
.quad 0xf306e29c11242650
.quad 0xe10ac9631ef5839c


.quad 0x7425156e86bac698
.quad 0xf671c282ece61842
.quad 0x5ea80d4d7c861b8e
.quad 0x888ae5d826a4f47f


.quad 0x57e9f4dcec77c702
.quad 0x222c9c1f77ce70c1
.quad 0x619ad02d8e07eccd
.quad 0x9c565e62f05b7adc


.quad 0x7096632ab3d13923
.quad 0xbdfdc83a1a1250f5
.quad 0xa2ce2961bb3643fb
.quad 0xe4670d402bdc0a55


.quad 0x5b6b7296de8f18b1
.quad 0x9168778705171107
.quad 0x204e0c1a3f3936ef
.quad 0xa8737b5168520f42


.quad 0x7671f096e5f6a054
.quad 0xb66919c339b3f7c6
.quad 0x8bf9acf7993c6dbe
.quad 0x58716e29304f3eff


.quad 0x7f3f55f8eba5535e
.quad 0x2a148726c8f492f1
.quad 0xda4a3ae361944ece
.quad 0x715390644a54a691


.quad 0x9a6a385413ce6a3c
.quad 0x02c183c18eed98c6
.quad 0xafa3b0481c125f6f
.quad 0x1b646b2c4f55fbaa


.quad 0xaff7fc190d798016
.quad 0x215e8b017e369bc8
.quad 0xd42ce088165fef3d
.quad 0x7bc1748aa45b2fe2


.quad 0x7fe65e369eb091b6
.quad 0xb40bc743709ae64e
.quad 0xc827df22a478439b
.quad 0xf8db9be78130382a


.quad 0x0dd1b4f033f0770e
.quad 0x2b67245d10907191
.quad 0x6a98bc076468b9b2
.quad 0x65c9811948758624


.quad 0x994679f6a7ab729e
.quad 0x973dde3e31d4eb85
.quad 0xa90c5c4ae9cc805e
.quad 0xe7eff1771c6206c6


.quad 0x92af437024a590cf
.quad 0xd673ee8dbcb06a22
.quad 0xfe4dfb672b84115b
.quad 0x46da916d89039fed


.quad 0x044ec53403603307
.quad 0xe8695f4c0db5de10
.quad 0x8778f331fa95b715
.quad 0xdda14f370b42d7fc


.quad 0xfbf444f33d9b3e6b
.quad 0xfbae3508cd8bd5b2
.quad 0xb52c21e5b8304f65
.quad 0x2b338aa2e0aed96e


.quad 0x964da5cc81568a8d
.quad 0x81318c566363836f
.quad 0x7f25c56abc7578eb
.quad 0xc049350b39d64fd6


.quad 0x351b34ad2daebe24
.quad 0xc09316350f4bb390
.quad 0x5bcedda849eb7ab5
.quad 0xb88c252eb3f9274b


.quad 0x494d9219871c0686
.quad 0x5e1dc6bd2eb4f4cc
.quad 0xfda038105183d84a
.quad 0xeaec04da7c49a122


.quad 0x3f1e91c8ca1ba80e
.quad 0x20fb0f62766f384b
.quad 0xe6f603eac9c1e322
.quad 0x7fabf74a06bb9e36


.quad 0x4179ffbae9f6a261
.quad 0xf69f30efab06ca29
.quad 0x31e6cf56d6adc929
.quad 0xaede9cff541b8da0


.quad 0xb69bf8ddb309d885
.quad 0x9a6a0198934b7ed4
.quad 0x75b36d493ac137dd
.quad 0xb35c6f1325c2144d


.quad 0xe80a36d1f03b68c9
.quad 0x6de1319fc1872fc8
.quad 0x7ca7e973a8fb2cba
.quad 0xf0844bf67d89642b


.quad 0xb40d767a7cb23bf9
.quad 0x2cf9a049c9ab751a
.quad 0x5ddd9debc0a14447
.quad 0xb0fe3f4ffefaa3d8


.quad 0xf7e122fe7e0c17a1
.quad 0xf1d5f7b123b709e9
.quad 0x327fab6f30b8793b
.quad 0x1284728dc06946b9


.quad 0x04ad52cf2b80a1c3
.quad 0x7f72d9dce536014f
.quad 0xb5167b0c1c2b422e
.quad 0x33780d8cc643c702


.quad 0x577bbf2a82ea8326
.quad 0x1e0a95204840ce8a
.quad 0x312887d9f203826b
.quad 0x5e0312857e0c00fa


.quad 0x5b491223a3adb3cd
.quad 0x395d0c56242b331f
.quad 0xe871019e3ee39044
.quad 0xb56fe75f1e48e69e


.quad 0x79cb0ffd15fc9061
.quad 0xecfdf007b810c7f5
.quad 0x26935751181e1378
.quad 0xdf592f9de385e92d


.quad 0xffa8c0a1e0fc8e96
.quad 0x38a83451fa975124
.quad 0x088f2974d5cd79ab
.quad 0x448b6607480b062f


.quad 0xcc5c3712ca750b1b
.quad 0xc1804608afd9257d
.quad 0x4df96aa8d599657f
.quad 0x9c5064809efbb618


.quad 0x835726774988d82d
.quad 0xfb314aa38b105901
.quad 0xbabb0b9d35947393
.quad 0x62439181219c45a7


.quad 0x1d96e33bf4f31415
.quad 0xd42ed180abfec68f
.quad 0x98bc567fa7ad6249
.quad 0x0c78a1a061580d38


.quad 0x0bc7bb82cb1853c9
.quad 0x2d85438c77f55442
.quad 0x3d7ed5e755d793a2
.quad 0x8b2e97da61cf7078


.quad 0xc99c983e14bd51df
.quad 0x4dc506fb052efe00
.quad 0x189cc1d5c48b7c0f
.quad 0x3042ed548b6f31ef


.quad 0x37beeb1cd828b5dc
.quad 0xbc7d74851da3f50c
.quad 0x422532fd0ffd8840
.quad 0x7127bdd4f2c5c1d1


.quad 0xf433a3f1cf85ee83
.quad 0xffe2906e8ee274d4
.quad 0x95abf733f366de10
.quad 0xa88e8d8c3f2c35df


.quad 0xe877922306df46e9
.quad 0x92daa67117f12328
.quad 0xf109d38b7bd7e010
.quad 0x750ab4b8a88d1fed


.quad 0xdeccf14d1a780d1a
.quad 0x87a7126016dc1634
.quad 0x05018e21089a4712
.quad 0x1eb5abbca1401b2d


.quad 0x49a123016a4f9f5d
.quad 0xbec163ea6e5dcb35
.quad 0x56ad543279315bcf
.quad 0xc6599d32013bd43f


.quad 0xf305a2abeda0985d
.quad 0x43df94bc2da10672
.quad 0x79aa9927a10e3810
.quad 0x39cd300810ede1d5


.quad 0x6ebeda989220fc03
.quad 0x64ccde12be62db91
.quad 0x7d28daf44e771113
.quad 0xc19d0a763b34d017


.quad 0x741260cdac210214
.quad 0x9af4d1c8c7eae484
.quad 0x5c54257b3f726331
.quad 0x292495ed8431074d


.quad 0x62f1a2a31a743ef2
.quad 0x3d3bd7796585868e
.quad 0xe16732be48ea463e
.quad 0x8c16ddde7d873cb8


.quad 0xe587a5219b40ba7c
.quad 0x660412017847abfc
.quad 0x8605ff18abaa8941
.quad 0x2bc021c1e0538e1f


.quad 0x448ebda2d148df32
.quad 0xe41de0234915987b
.quad 0x5043353f00d9db81
.quad 0x79aa9c5516e0a43a


.quad 0x772348f6451ef946
.quad 0x8fae4f3f884994c4
.quad 0x1ec49c1e67ff2db9
.quad 0x492b017df0c97abd


.quad 0xbad89c7553d2d355
.quad 0xdb764ceb38aaec46
.quad 0x77b1ea0775db37b5
.quad 0x3972edf2c18921e8


.quad 0xf9b6fa9e75b0eea6
.quad 0xc577fcd4f11380c6
.quad 0xed567a2e626f4232
.quad 0x7cd5ae925cc75f81


.quad 0xa598ff9ca170c4fd
.quad 0x1e54201790bda8c0
.quad 0x3807dea5f1c0cf20
.quad 0x7b2f7c5267b735c3
