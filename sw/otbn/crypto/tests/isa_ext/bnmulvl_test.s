/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* 256-bit lane-wise vector multiplication with truncation example. */

.section .text.start

/******************************/
/*   Tests for bn.mulv.l.8S    */
/******************************/

/* Load mod WSR with base li pseudo-instruction*/
li x23, 0x7fe001
csrrw x0, 0x7d0, x23

li x23, 0xFC7FDFFF
csrrw x0, 0x7d1, x23

/* Load operands into WDRs */
li x2, 0
li x3, 1

la x4, operand1
bn.lid x2, 0(x4)

la x4, operand2
bn.lid x3, 0(x4)

/* Perform vectorized trunacted multiplication, limbs are 32-bit. */

bn.mulv.l.8S w2, w0, w1, 0
bn.mulv.l.8S w3, w0, w1, 1
bn.mulv.l.8S w4, w0, w1, 2
bn.mulv.l.8S w5, w0, w1, 3

bn.mulv.l.8S w6, w0, w1, 4
bn.mulv.l.8S w7, w0, w1, 5
bn.mulv.l.8S w8, w0, w1, 6
bn.mulv.l.8S w9, w0, w1, 7

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 512(x0)
bn.sid x4++, 544(x0)
bn.sid x4++, 576(x0)
bn.sid x4++, 608(x0)

bn.sid x4++, 640(x0)
bn.sid x4++, 672(x0)
bn.sid x4++, 704(x0)
bn.sid x4++, 736(x0)


/******************************/
/*   Tests for bn.mulv.l.16H   */
/******************************/

/* Load mod WSR with base li pseudo-instruction*/
li x23, 0x00000D01
csrrw x0, 0x7d0, x23

li x23, 0xCFF
csrrw x0, 0x7d1, x23

/* Load operands into WDRs */
li x2, 0
li x3, 1

la x4, operand3
bn.lid x2, 0(x4)

la x4, operand4
bn.lid x3, 0(x4)

/* Perform vectorized truncated multiplication, limbs are 16-bit. */

bn.mulv.l.16H w2, w0, w1, 0
bn.mulv.l.16H w3, w0, w1, 1
bn.mulv.l.16H w4, w0, w1, 2
bn.mulv.l.16H w5, w0, w1, 3
bn.mulv.l.16H w6, w0, w1, 4
bn.mulv.l.16H w7, w0, w1, 5
bn.mulv.l.16H w8, w0, w1, 6
bn.mulv.l.16H w9, w0, w1, 7
bn.mulv.l.16H w10, w0, w1, 8
bn.mulv.l.16H w11, w0, w1, 9
bn.mulv.l.16H w12, w0, w1, 10
bn.mulv.l.16H w13, w0, w1, 11
bn.mulv.l.16H w14, w0, w1, 12
bn.mulv.l.16H w15, w0, w1, 13
bn.mulv.l.16H w16, w0, w1, 14
bn.mulv.l.16H w17, w0, w1, 15

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 768(x0)
bn.sid x4++, 800(x0)
bn.sid x4++, 832(x0)
bn.sid x4++, 864(x0)
bn.sid x4++, 896(x0)
bn.sid x4++, 928(x0)
bn.sid x4++, 960(x0)
bn.sid x4++, 992(x0)
bn.sid x4++, 1024(x0)
bn.sid x4++, 1056(x0)
bn.sid x4++, 1088(x0)
bn.sid x4++, 1120(x0)
bn.sid x4++, 1152(x0)
bn.sid x4++, 1184(x0)
bn.sid x4++, 1216(x0)
bn.sid x4++, 1248(x0)


/******************************/
/*   Tests for bn.mulv.l.8S    */
/******************************/

/* Load mod WSR with base li pseudo-instruction*/
li x23, 0x7fe001
csrrw x0, 0x7d0, x23

li x23, 0xFC7FDFFF
csrrw x0, 0x7d1, x23

/* Load operands into WDRs */
li x2, 0
li x3, 1

la x5, operand5

loopi 128, 15

bn.lid x2, 0(x5++)

la x4, operand5

loopi 128, 10

bn.lid x3, 0(x4++)

/* Perform vectorized trunacted multiplication, limbs are 32-bit. */
bn.mulv.l.8S w2, w0, w1, 0
bn.mulv.l.8S w3, w0, w1, 1
bn.mulv.l.8S w4, w0, w1, 2
bn.mulv.l.8S w5, w0, w1, 3

bn.mulv.l.8S w6, w0, w1, 4
bn.mulv.l.8S w7, w0, w1, 5
bn.mulv.l.8S w8, w0, w1, 6
bn.mulv.l.8S w9, w0, w1, 7

li x31, 0
li x31, 1
li x31, 2
li x31, 3
li x31, 4
li x31, 5
li x31, 6
li x31, 7


ecall

.section .data
   
.globl operand1
operand1:
  .quad 0x0000000200000001
  .quad 0x0000000400000003
  .quad 0x0000000600000005
  .quad 0x0000000800000007
.globl operand2
operand2:
  .quad 0x007fe000007fe000
  .quad 0x007fe000007fe000
  .quad 0x007fe000007fe000
  .quad 0x007fe000007fe000
.globl operand3
operand3:
  .quad 0x0004000300020001
  .quad 0x0008000700060005
  .quad 0x000c000b000a0009
  .quad 0x0010000f000e000d
.globl operand4
operand4:
  .quad 0x0D000D000D000D00
  .quad 0x0D000D000D000D00
  .quad 0x0D000D000D000D00
  .quad 0x0D000D000D000D00


.globl operand5
operand5:
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

prime_dilithium:
  .word 0x007fe001

prime_kyber:
  .word 0x00000D01
