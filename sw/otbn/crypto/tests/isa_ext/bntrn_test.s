/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* 256-bit trn1 and trn2 example. */

.section .text.start

/******************************/
/*    Tests for bn.trn.16h    */
/******************************/

/* Load operands into WDRs */
li x2, 0
li x3, 1

bn.lid x2, 0(x0)
bn.lid x3, 32(x0)

/* Perform 16H transpose limbs are 16-bit. */

bn.trn1.16h w3, w0, w1
bn.trn2.16h w2, w0, w1

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 512(x0)
bn.sid x4++, 544(x0)

/******************************/
/*    Tests for bn.trn.8S    */
/******************************/

/* Load operands into WDRs */
li x2, 0
li x3, 1

bn.lid x2, 64(x0)
bn.lid x3, 96(x0)

/* Perform 8S transpose, limbs are 32-bit. */

bn.trn1.8S w3, w0, w1
bn.trn2.8S w2, w0, w1

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 576(x0)
bn.sid x4++, 608(x0)

/******************************/
/*    Tests for bn.trn.4D    */
/******************************/

/* Load operands into WDRs */
li x2, 0
li x3, 1

bn.lid x2, 128(x0)
bn.lid x3, 160(x0)

/* Perform 4D transpose limbs are 64-bit. */

bn.trn1.4D w3, w0, w1
bn.trn2.4D w2, w0, w1

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 640(x0)
bn.sid x4++, 672(x0)

/******************************/
/*    Tests for bn.trn.2D    */
/******************************/

/* Load operands into WDRs */
li x2, 0
li x3, 1

bn.lid x2, 192(x0)
bn.lid x3, 224(x0)

/* Perform 2Q tranpose, limbs are 128-bit. */

bn.trn1.2Q w3, w0, w1
bn.trn2.2Q w2, w0, w1

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 704(x0)
bn.sid x4++, 736(x0)


/******************************/
/*  Tests for bn.trn random   */
/******************************/

/* Load operands into WDRs */

li x2, 0
li x3, 1

la x5, operand10
la x4, operand10

loopi 128, 14

bn.lid x2, 0(x5++)

la x4, operand10

loopi 128, 10

bn.lid x3, 0(x4++)

/* Perform 8S transpose, limbs are 32-bit. */#
bn.trn1.16h w3, w0, w1
bn.trn2.16h w2, w0, w1

bn.trn1.8S w3, w0, w1
bn.trn2.8S w2, w0, w1

bn.trn1.4D w3, w0, w1
bn.trn2.4D w2, w0, w1

bn.trn1.2Q w3, w0, w1
bn.trn2.2Q w2, w0, w1

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
/* 256-bit integer
   0010000f000e000d 000c000b000a0009
   0008000700060005 0004000300020001 
   (.quad below is in reverse order) */

operand1:
  .quad 0x0004000300020001
  .quad 0x0008000700060005
  .quad 0x000c000b000a0009
  .quad 0x0010000f000e000d

/* 256-bit integer
   0010000f000e000d 000c000b000a0009
   0008000700060005 0004000300020001 
   (.quad below is in reverse order) */

operand2:
  .quad 0x0004000300020001
  .quad 0x0008000700060005
  .quad 0x000c000b000a0009
  .quad 0x0010000f000e000d

/* 256-bit integer
   0000000800000007 0000000600000005
   0000000400000003 0000000200000001 
   (.quad below is in reverse order) */

operand3:
  .quad 0x0000000200000001
  .quad 0x0000000400000003
  .quad 0x0000000600000005
  .quad 0x0000000800000007

/* 256-bit integer
   0000000800000007 0000000600000005
   0000000400000003 0000000200000001 
   (.quad below is in reverse order) */

operand4:
  .quad 0x0000000200000001
  .quad 0x0000000400000003
  .quad 0x0000000600000005
  .quad 0x0000000800000007

/* 256-bit integer
   0000000000000004 0000000000000003
   0000000000000002 0000000000000001 
   (.quad below is in reverse order) */

operand5:
  .quad 0x0000000000000001
  .quad 0x0000000000000002
  .quad 0x0000000000000003
  .quad 0x0000000000000004

/* 256-bit integer
   0000000000000000 0000000000000002
   0000000000000000 0000000000000001 
   (.quad below is in reverse order) */

operand6:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000002
  .quad 0x0000000000000000

/* 256-bit integer
   0000000000000000 0000000000000002
   0000000000000000 0000000000000001 
   (.quad below is in reverse order) */

operand7:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000002
  .quad 0x0000000000000000

operand8:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000002
  .quad 0x0000000000000000

/* 256-bit integer
   0000000000000000 0000000000000002
   0000000000000000 0000000000000001 
   (.quad below is in reverse order) */

operand9:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000002
  .quad 0x0000000000000000


operand10:
.quad 0xbb91433a6aa79987
.quad 0xd1f6f86c029a7245
.quad 0xcd8778e7d340bbcd
.quad 0xdaea58ba4c73a942


.quad 0xecc2e843769336af
.quad 0x71dd6ca7bd5679a9
.quad 0xe3623a856346021b
.quad 0x12152897b533e949


.quad 0xfffe7bec5a8fd4b7
.quad 0x14c22f8fd3ecff7f
.quad 0xea6a686d7d19aed3
.quad 0x74f678e057896f42


.quad 0xa72c13da0c7d9afd
.quad 0x2c375493c3c9f6a8
.quad 0x420c7b3b7b438953
.quad 0x495a37596ed25434


.quad 0x0d17cf0d0ff0e9a2
.quad 0x054c10c4a724afb1
.quad 0xc1bf4c4b56897a33
.quad 0x14ef2599d874b227


.quad 0x79b5702f310685b6
.quad 0xb0dfebc7a2b1bd29
.quad 0x80d450799e08f226
.quad 0x4ccf9f4cc7115b49


.quad 0xa93353fc5f91a288
.quad 0x6ab60fbc93a611a2
.quad 0x95b36b798ff3c8d2
.quad 0x2863ac983befa0da


.quad 0x293b93b75afab88d
.quad 0x3d677b1b1d5618da
.quad 0xd1eb3f5c95dbe538
.quad 0x507279d9c62775da


.quad 0xc9204f465c11fcdd
.quad 0xfd2c46ca3665a1a6
.quad 0x90707e2d9d6cad4b
.quad 0x3111ac42ae4e4080


.quad 0x4410cbe3224a7a84
.quad 0x587df9e83b175ec5
.quad 0xae58b24f9182a4ad
.quad 0x15bf2628eabec4fb


.quad 0x5cef066dac8540c4
.quad 0x8e8623e16a0c216f
.quad 0x3d84f65f2f2e360a
.quad 0x41ecaa34f5ec9f14


.quad 0x345bcdfcbebcc006
.quad 0x6baa0b47186cc083
.quad 0xdb0b1a00d724497b
.quad 0xf04004ceffb26eca


.quad 0x26a79c6e85a37087
.quad 0xd0b9dba0be6ee627
.quad 0x6c9c1ee71bed582b
.quad 0x19d69740f38d1460


.quad 0x4521eb7fabdf677b
.quad 0x0b8be99234357d5f
.quad 0xb28177aa1fd5dfc3
.quad 0x57aa7c8fc3505354


.quad 0x0582b9164370b995
.quad 0xa400563e267a6b3a
.quad 0x22bf9160002052be
.quad 0xcb6108d046a8f344


.quad 0x31b2b327f746800e
.quad 0x1b7ff399067d0f77
.quad 0x34fba7967fec884f
.quad 0x45a77ed1ba0c0035


.quad 0xe509cff85ffebab2
.quad 0x675c64f8507e4058
.quad 0x4f6c69740dc3f7e0
.quad 0x07c10e2e3bab557b


.quad 0x9bc7efbc5844e463
.quad 0x4e109e6f7b034767
.quad 0x93834d7f460e251d
.quad 0x28628b61c5a2ee0e


.quad 0x979568e7afa05c21
.quad 0x6c9a04c2f8a167b7
.quad 0x68c0d3c142cb640e
.quad 0xb7d7ea591e3053ac


.quad 0xfe3fc4af03bd4968
.quad 0xf17b39d1a06ab68f
.quad 0xe5ffb7cac9ce096b
.quad 0x1db1c1eae2942874


.quad 0xa04ed79d97b982a3
.quad 0x5509dc685f71840b
.quad 0xaf3cfeea6858f460
.quad 0x7a974c26e26afbd4


.quad 0xc280339e4efd285b
.quad 0x9b150fbbd81a334f
.quad 0x130d7ee2569e6c9c
.quad 0x0946bf7f8751a4f5


.quad 0xdfe6c8400f65efd0
.quad 0xe649ef46fc7d6024
.quad 0x7198e69cbd8b4909
.quad 0xa2466bbf96681060


.quad 0xc44ec9ddf1929637
.quad 0x4012635b8bc58741
.quad 0x583037d32f093ad1
.quad 0x3c09c11a7ba89068


.quad 0xc7baa569af05d73d
.quad 0xce080305923c6b46
.quad 0x3456d90650e15a42
.quad 0xb19e71f4f2e09595


.quad 0x4583002a449f40b0
.quad 0x0d52032aa00bd0c1
.quad 0x2c2ab905b220dfe0
.quad 0x56158c4574d46353


.quad 0x84ca16d245c747c0
.quad 0x69b58b3563cc4814
.quad 0x05b71d870f18f7df
.quad 0x5721ede7e5063a5e


.quad 0x539d18746e68215b
.quad 0xd7d5a96601a3847c
.quad 0x32cd4848d209d937
.quad 0x998e8669aa394a8f


.quad 0x18c6b6bc35c61940
.quad 0x07f8a06225a2e2ce
.quad 0x8c163d33253f11e1
.quad 0x34404ccba9bbaec0


.quad 0xf6bbe71ee514cbbc
.quad 0x87b4a3a8b5a40a6b
.quad 0x5c51692eb500963e
.quad 0x59ecf5aa04765033


.quad 0x4aafb6c5341e42a6
.quad 0x98a1fc99fbce05df
.quad 0x35fc7b6b08a70f60
.quad 0x0719afbb36baaab2


.quad 0x29c47d26b05ea2cb
.quad 0xa0d298061c377a9c
.quad 0x6412e32280edc129
.quad 0x0e21361125f29d9a


.quad 0xec3706209616866d
.quad 0x1022931ff2ea2361
.quad 0xeecb24157f34a23a
.quad 0xc946c3c1f05bd61c


.quad 0x989c22fa19300dba
.quad 0xe1fb0df88efa2146
.quad 0x024e4c364cd9ea95
.quad 0xd9e578afd4cf1deb


.quad 0x50f4504204f9c63e
.quad 0xda8f845ff621cace
.quad 0x380fdb51862cbdb4
.quad 0xda4acd24be44c40f


.quad 0xb744fa795cb201f5
.quad 0x4cd0d05f5a9e3328
.quad 0xce7a09cf8321e694
.quad 0xe8220f969e7600b9


.quad 0xb8429b249b00abae
.quad 0xfabbf9bff8845246
.quad 0x2c0f5a9225caae25
.quad 0x7a9313a3b9bb67e0


.quad 0xc95b105175b34f85
.quad 0x4a366f0434f097a7
.quad 0x34597beca1c58c74
.quad 0x3b8eee3423624716


.quad 0xd60648d3a856ae2c
.quad 0x511acc4064971054
.quad 0x3c83060ca32405a5
.quad 0xd0d0a71b8cfff903


.quad 0xbc97d1f10f62da8b
.quad 0x47333e0d13b52a24
.quad 0x36e17af3802c1fc5
.quad 0x757884ffe1f805a8


.quad 0xbac89c625efe0307
.quad 0x6259e5f847da8269
.quad 0xba062b1ad4679b36
.quad 0xf598c13a9beb679f


.quad 0x2b1f0230978f96e3
.quad 0xb5d775cc51d7f402
.quad 0x9e1025b4ee96758b
.quad 0xc8aee3e559b0cfde


.quad 0x448d71a292bc1ce2
.quad 0x0bd6e9a1502eddef
.quad 0x1bcfc08076c60e7f
.quad 0x2dca5fcbdadb40f5


.quad 0x9c104051f084b065
.quad 0x4fb488e438bcaf15
.quad 0x5e06cd047e61ab67
.quad 0xcf4b59226009fb55


.quad 0x79606ef63b710a60
.quad 0xea7209e1cf632488
.quad 0x2ac59a6cf348ff44
.quad 0xd14a1e8094f832d4


.quad 0x026bd4f3902f0f27
.quad 0xbaf10aa7e72e2381
.quad 0x1fd8f47445a9101f
.quad 0x6ebab90d99a63201


.quad 0x59f37921cf72cc96
.quad 0x1cd108a6bcabf4ba
.quad 0xbe9f80f030500e2c
.quad 0xbc398091e916b48e


.quad 0x81fc2c65a5b3e05f
.quad 0x7616d4cc3081cc9b
.quad 0x6b469cbaebd6e0ec
.quad 0x71c69209b972f04a


.quad 0x81611bb97f05f95b
.quad 0xdb3e0197fa3b23e6
.quad 0xedcd86b832f81b5c
.quad 0x185910522ede8bed


.quad 0xe73715a4cb879934
.quad 0x4e244b8fd10e7275
.quad 0xafce62049bacd399
.quad 0x02729020c1982607


.quad 0xf32caa798de81a9f
.quad 0x49d0233298dee306
.quad 0x8dade4144f0eeb22
.quad 0x8eaa944e82e76ea6


.quad 0x45d031e6558302c3
.quad 0x96f0731fc1acc6c8
.quad 0xd169c8b6380c9a50
.quad 0x53b90ff3fc93135b


.quad 0xcc4c46aa597411bc
.quad 0x1df31493cd286238
.quad 0x6df00fc30cc98d74
.quad 0xe1a75c3186fd3999


.quad 0xf05e6cc6183e045b
.quad 0x5605e8890ec4b14b
.quad 0x3edc564dd2f0c4a7
.quad 0xab53f0953274fffe


.quad 0x002ef61d4983c7d7
.quad 0xb1df50f08003b7fd
.quad 0x1432fdd5584eeb7a
.quad 0x62c43839ac819626


.quad 0x1b82682849410d21
.quad 0x85aa9b1a661d5fb7
.quad 0x9c7897e847d68ac0
.quad 0x10eeef0a1ea0cb2d


.quad 0xfdd542f1431540bf
.quad 0x119bd4dabbca1f17
.quad 0x2c3ff52b03f7e0d4
.quad 0x1f015abcf0a2ec8c


.quad 0x0bb15517d9315b1d
.quad 0xd8afc3f978ea1a46
.quad 0x178749548a017820
.quad 0x942dee8622eea873


.quad 0xf01290b8df7a98b2
.quad 0x71cbb5482d474a14
.quad 0x4c5f8ffafe8d9c17
.quad 0x88a26f01fb3d66fd


.quad 0x8dc4ee3a31ec981b
.quad 0xb622995f8a708edc
.quad 0x473087a9bbcd61e2
.quad 0x23b128c9536abb1b


.quad 0x082d317ff6f168b1
.quad 0xa3eaadf1a1267f7d
.quad 0xe4cdfbe3508f0be7
.quad 0xb836593a022c6372


.quad 0x485cd9e904beb975
.quad 0x03100ca8a502b0a3
.quad 0x4e087eef4810030a
.quad 0x588035f8bc599719


.quad 0xee5859c32420dbdc
.quad 0x54d9bec50912c879
.quad 0xc8c70ed7cd21d1ab
.quad 0x2b9b01c2c2a0d175


.quad 0x1ed5704e1a968012
.quad 0xfa77ecd50a841ef3
.quad 0xa2050804ba8cd469
.quad 0xf2fb4c0a76ffdb0c


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
