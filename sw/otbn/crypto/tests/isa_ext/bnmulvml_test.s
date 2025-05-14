/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* 256-bit lane-wise vector multiplication with reduction example. */

.section .text.start

/******************************/
/*   Tests for bn.mulvm.l.8S    */
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

/* Perform vector addition and subtraction, limbs are 32-bit. */

bn.mulvm.l.8S w2, w0, w1, 0
bn.mulvm.l.8S w3, w0, w1, 1
bn.mulvm.l.8S w4, w0, w1, 2
bn.mulvm.l.8S w5, w0, w1, 3

bn.mulvm.l.8S w6, w0, w1, 4
bn.mulvm.l.8S w7, w0, w1, 5
bn.mulvm.l.8S w8, w0, w1, 6
bn.mulvm.l.8S w9, w0, w1, 7

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
/*   Tests for bn.mulvm.l.16H   */
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

/* Perform vector addition and subtraction, limbs are 32-bit. */

bn.mulvm.l.16H w2, w0, w1, 0
bn.mulvm.l.16H w3, w0, w1, 1
bn.mulvm.l.16H w4, w0, w1, 2
bn.mulvm.l.16H w5, w0, w1, 3
bn.mulvm.l.16H w6, w0, w1, 4
bn.mulvm.l.16H w7, w0, w1, 5
bn.mulvm.l.16H w8, w0, w1, 6
bn.mulvm.l.16H w9, w0, w1, 7
bn.mulvm.l.16H w10, w0, w1, 8
bn.mulvm.l.16H w11, w0, w1, 9
bn.mulvm.l.16H w12, w0, w1, 10
bn.mulvm.l.16H w13, w0, w1, 11
bn.mulvm.l.16H w14, w0, w1, 12
bn.mulvm.l.16H w15, w0, w1, 13
bn.mulvm.l.16H w16, w0, w1, 14
bn.mulvm.l.16H w17, w0, w1, 15

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
/*   Tests for bn.mulvm.l.8S  */
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

/* Perform vector addition and subtraction, limbs are 32-bit. */

bn.mulvm.l.8S w2, w0, w1, 0
bn.mulvm.l.8S w3, w0, w1, 1
bn.mulvm.l.8S w4, w0, w1, 2
bn.mulvm.l.8S w5, w0, w1, 3

bn.mulvm.l.8S w6, w0, w1, 4
bn.mulvm.l.8S w7, w0, w1, 5
bn.mulvm.l.8S w8, w0, w1, 6
bn.mulvm.l.8S w9, w0, w1, 7

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
  .quad 0x00023412006d0400
  .quad 0x0000021400368200
  .quad 0x0004321600523125
  .quad 0x0000000800003417

.globl operand2

operand2:
  .quad 0x006fe22100581103
  .quad 0x005aaaaa00591103
  .quad 0x000feabc00801143
  .quad 0x00203a08007fe000

.globl operand3

operand3:
  .quad 0x0004000300020d00
  .quad 0x0008000700060005
  .quad 0x00cc000b000a0009
  .quad 0x0b60000f005e0023

.globl operand4

operand4:
  .quad 0x0D000D000D000b00
  .quad 0x0D000D000D000023
  .quad 0x0D000D000D0000ff
  .quad 0x0D000D000BA00D00


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

.quad 0x005d1011001d1fdd
.quad 0x00368ae00006bede
.quad 0x002d86c0003b72f4
.quad 0x00380a24001d9a1e


.quad 0x003244ae003fc8a1
.quad 0x006adcad0071672e
.quad 0x005906fc00210fb1
.quad 0x00041ba8002e9d09


.quad 0x00269f7200229383
.quad 0x000cabbb0015f1b0
.quad 0x0043431600199772
.quad 0x0024d8a30034865d


.quad 0x000e5bf9004e1e04
.quad 0x0027bbbf001f918b
.quad 0x0040024d003f7ac0
.quad 0x0026bb90001c0477


.quad 0x00381915000732ce
.quad 0x001f5806002a28ec
.quad 0x00512f21006a33d6
.quad 0x002caa4700591c78


.quad 0x004057be001172b6
.quad 0x0073d0aa003aba48
.quad 0x00139e940026f3bc
.quad 0x000ba5e30042aace


.quad 0x004a5568006764b5
.quad 0x0054430a0061f2a5
.quad 0x003ae07e0016538c
.quad 0x004919a60062f448


.quad 0x0042f76c000bd7e1
.quad 0x004f738700248ce3
.quad 0x00526fe0004d955c
.quad 0x007784230056437c


.quad 0x0002b3ba00628817
.quad 0x0055017a0074cbec
.quad 0x00024ab200297f81
.quad 0x002301ba001ed2dd


.quad 0x0014725e0057ac02
.quad 0x0058a762004d54f8
.quad 0x0023a1c40051617e
.quad 0x007db2490060648b


.quad 0x005af3cb0055f6c2
.quad 0x0072d0450041cdb9
.quad 0x0007be3a004c8c2f
.quad 0x000c2556005a11b3


.quad 0x0074c9a300439b2a
.quad 0x00786b500013fb2d
.quad 0x005e8c390073c753
.quad 0x002616df00510e7f


.quad 0x0066a01a001cc03e
.quad 0x0045741d003a40b1
.quad 0x002a6b2000750d47
.quad 0x000cabde001d212e


.quad 0x002ad7c7004a8fb7
.quad 0x0043536a0009de52
.quad 0x0002d3c90007ebd9
.quad 0x003339460033068b


.quad 0x002b4d46005ec4f1
.quad 0x005367e000103601
.quad 0x0076fa840065713d
.quad 0x001a1b9e000f4385


.quad 0x00790e38003167d9
.quad 0x0004e83f0055e206
.quad 0x00104dd1005a952b
.quad 0x00181fd200228b36


.quad 0x0079d0f000459ba3
.quad 0x000e34ca001a45fb
.quad 0x000895fd0044fdcf
.quad 0x003b5d8500295c25


.quad 0x002ba46e00572ab3
.quad 0x005874cb00327e19
.quad 0x000356f000031fd8
.quad 0x006b97660061c9fb


.quad 0x00780f900015db59
.quad 0x0009688e00515d39
.quad 0x005aa998007ca0cc
.quad 0x00542ec300341410


.quad 0x003c1924000f907a
.quad 0x002d89ac00116cf9
.quad 0x00583ab6006e0939
.quad 0x004d3a710038adce


.quad 0x003bd348002635a0
.quad 0x007f950d001c9b50
.quad 0x006a7ee4005b09fc
.quad 0x001d61e500540113


.quad 0x004cd4af007aa09c
.quad 0x0005fd640017900f
.quad 0x00526d7f007657d5
.quad 0x00340fde00555ceb


.quad 0x00272b6c003573b5
.quad 0x0003dc0d007a38a1
.quad 0x007338d4000dcc67
.quad 0x00629a5f00145bbe


.quad 0x00488965007f450b
.quad 0x0070c0c7000f1321
.quad 0x007b5c77003c91e7
.quad 0x00784fa0006b0a46


.quad 0x002f6963007d8f59
.quad 0x006d0d10004a244b
.quad 0x007600d2006c894a
.quad 0x003c2c8700497844


.quad 0x00461000006457e4
.quad 0x006804f00033daaa
.quad 0x00660cd000440ffb
.quad 0x00391c6b004929c2


.quad 0x002979fd007f0b27
.quad 0x0025353d00168468
.quad 0x000d9206001754ce
.quad 0x002a94b90034d73f


.quad 0x007c154f0031a205
.quad 0x00446783002e8a8e
.quad 0x006bfb760005f950
.quad 0x004c4ff200551137


.quad 0x0061c02d005a79a0
.quad 0x002b72810015dde4
.quad 0x002f7442000f03d6
.quad 0x0026a5190045af2c


.quad 0x0025839b005d86cf
.quad 0x0044875300211495
.quad 0x004451fb000f6c8e
.quad 0x004b71720078128f


.quad 0x003720b4000f51b4
.quad 0x0007d252005909a9
.quad 0x0037c5ef00375800
.quad 0x0029c1940031b429


.quad 0x000858410013fbf6
.quad 0x0011f6ff005a2e74
.quad 0x006b34b000054e0b
.quad 0x0036479d00757f73


.quad 0x00026c6a0030e1e4
.quad 0x0043e0650018f83b
.quad 0x000968af007c8683
.quad 0x00049e24006d8bd9


.quad 0x003fa19b007a82a0
.quad 0x0076fd8200463946
.quad 0x00335d420008c3d6
.quad 0x004a18270050f4cd


.quad 0x0055302d0067a0d7
.quad 0x004b000b007a69b9
.quad 0x001783e100721044
.quad 0x000c6dd000211674


.quad 0x006a8723000f3424
.quad 0x00518fc4006cc51f
.quad 0x007a69e800563f53
.quad 0x003808840049e567


.quad 0x0002063a0074b251
.quad 0x0004dd0500362097
.quad 0x0054e0e700001e89
.quad 0x00776828007dc313


.quad 0x007ae0e600400fec
.quad 0x00597a4c0055a1ec
.quad 0x00072dba002af994
.quad 0x0015be300076d0e0


.quad 0x004c3f86004bfc7a
.quad 0x0069c8b4002046cf
.quad 0x00348fbb005620ce
.quad 0x0078230a0052e682


.quad 0x00085dcf005eafbf
.quad 0x0001731a0025fea8
.quad 0x002d4e5e007a754e
.quad 0x007f27350051e0ad


.quad 0x006a155c00543950
.quad 0x00358bd0000301ac
.quad 0x0025b56f001ff0b9
.quad 0x0066635d004c314d


.quad 0x006d6790007ecb1d
.quad 0x0027dd08006b84e7
.quad 0x00521d420041fedb
.quad 0x00544227000724e5


.quad 0x005a3ead00080e75
.quad 0x00205ed600550e50
.quad 0x0078684000679e29
.quad 0x002a1772006e4ef6


.quad 0x0069a2bd000d72ef
.quad 0x004bd207005aab4d
.quad 0x005fb30f006845ee
.quad 0x004bf530002d0d26


.quad 0x0044b5ea003b77f2
.quad 0x0062c66c006e3e85
.quad 0x007760f200206ee5
.quad 0x0018890d002c6b90


.quad 0x0028fe1700072a66
.quad 0x0006e0b00045841a
.quad 0x00449c4d004770ca
.quad 0x0043f6800053fc2d


.quad 0x003ac027002760b9
.quad 0x003d440d00170051
.quad 0x003cca390045470c
.quad 0x005aeddb006486fc


.quad 0x00472b110031918a
.quad 0x0006bad0003a8bf0
.quad 0x007d46190046804d
.quad 0x0063e5f6002994a2


.quad 0x00664da0001a3194
.quad 0x000d15080042323f
.quad 0x0010b3a7001049a0
.quad 0x000d1a0700129e39


.quad 0x00190b4f0012fef4
.quad 0x004661690000cd7f
.quad 0x0052ce3700628faa
.quad 0x002b85cc0001f7cf


.quad 0x001eb6f3001559de
.quad 0x001db055007926b7
.quad 0x0062f86e00254015
.quad 0x0078e50300633c29


.quad 0x003e3100007ef3bc
.quad 0x0025c4a6005bb3c8
.quad 0x0029484a002385b3
.quad 0x005f799b00420b1e


.quad 0x0019fa2d005bc7c6
.quad 0x000c9c650073630c
.quad 0x000c719a0028e392
.quad 0x003a366e001d7314


.quad 0x0065dc73001f9844
.quad 0x0049b54f006191d9
.quad 0x0076e0190079eb12
.quad 0x005a7ee1006b5f27


.quad 0x0003e3d600055b60
.quad 0x00716f57002ae85a
.quad 0x004501ee000e6709
.quad 0x0005d9fc002dee61


.quad 0x00010a8e000de4bc
.quad 0x0018f4f2005404ff
.quad 0x0033513600680076
.quad 0x0004a172007607a9


.quad 0x000acdb50055c24d
.quad 0x00740bba00302638
.quad 0x006f09fc0022ffe2
.quad 0x00619b08005078eb


.quad 0x004ed4680041a70f
.quad 0x0050beb70040e4c9
.quad 0x004773e300605bf9
.quad 0x001ae4c40079b958


.quad 0x001cb7ab0031c3f7
.quad 0x000377dc005b7a15
.quad 0x003d0ed6006fca71
.quad 0x003720a800788fe7


.quad 0x0064965f004a8b38
.quad 0x004f7f7000762188
.quad 0x00034aff002606de
.quad 0x005c8c0900726f83


.quad 0x0027a930005656bb
.quad 0x0044527500665663
.quad 0x007277ad00158e36
.quad 0x0074f70d0021baa0


.quad 0x00612e15005ac59c
.quad 0x0054a4bb006ccd00
.quad 0x0002dd430045e371
.quad 0x0020bba400552cf8


.quad 0x007804db005c8b6c
.quad 0x005a795100647cab
.quad 0x007d85f6003e3eab
.quad 0x00267b180055d482


.quad 0x00426f9900767d50
.quad 0x004540ff00064034
.quad 0x00532ec900560859
.quad 0x002e2b8b007add0c


prime_dilithium:
  .word 0x007fe001

prime_kyber:
  .word 0x00000D01
