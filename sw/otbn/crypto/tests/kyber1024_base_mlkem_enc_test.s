/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/*
 * Test for kyber1024_base_mlkem_enc
*/

.section .text.start

/* Entry point. */
.globl main
main:
  /* Init all-zero register. */
  bn.xor  w31, w31, w31

  /* MOD <= dmem[modulus] = KYBER_Q */
  li      x5, 2
  la      x6, modulus
  bn.lid  x5, 0(x6)
  bn.wsrw 0x0, w2

  /* Load stack pointer */
  la   x2, stack_end
  la   x10, randombytes
  la   x11, ct
  la   x12, key_b
  la   x13, pk
  jal  x1, crypto_kem_enc

  ecall

.data
.balign 32
.global stack
stack:
  .zero 20000
stack_end:
ct:
  .zero 1568
key_b:
  .zero 32

.balign 32
/* First input: randombytes */
randombytes:
  .word 0x87ccb835
  .word 0x62dc233c
  .word 0x1660d2b8
  .word 0x752ffa9a
  .word 0x586a91ab
  .word 0x889174d9
  .word 0x6a5ed235
  .word 0xb2855043
pk: 
  .word 0x5a720c78
  .word 0x1b1f1525
  .word 0x1dc7e909
  .word 0xd65d9726
  .word 0x59e02052
  .word 0x6e6b52ca
  .word 0xa54a876f
  .word 0x9722b6e8
  .word 0x7d030fce
  .word 0x6aa812a3
  .word 0x291f1305
  .word 0x2899d423
  .word 0xcb0e45b7
  .word 0xaad896e9
  .word 0x256aae21
  .word 0x4b4de4a9
  .word 0xcc1b998c
  .word 0x13639dc5
  .word 0x2b651ca6
  .word 0x0a7904f9
  .word 0x4bb83c06
  .word 0x110b871d
  .word 0x8c6c8c82
  .word 0x2d63f77d
  .word 0x5a7d71cf
  .word 0x484d3ee3
  .word 0x7e63257a
  .word 0x0a0e034d
  .word 0x211ab276
  .word 0x02c1ea42
  .word 0x60a4c54f
  .word 0x108da03c
  .word 0xc854c981
  .word 0x708e36a9
  .word 0x009a1611
  .word 0x564a99a4
  .word 0xccaefbf9
  .word 0x752702cb
  .word 0x9d67a2c9
  .word 0xeb5364ca
  .word 0x61db907b
  .word 0xc0804935
  .word 0x747af13c
  .word 0x97041405
  .word 0x96a93ab2
  .word 0xcca437d6
  .word 0x395e7c02
  .word 0x4e63de11
  .word 0xb45aa63e
  .word 0xc2ef5594
  .word 0xb81a2653
  .word 0x555afc5e
  .word 0x8a3a70ba
  .word 0x9d781c0c
  .word 0xecadbc94
  .word 0xbb19b388
  .word 0x4e351869
  .word 0xd69834b3
  .word 0x97210d68
  .word 0x82356c20
  .word 0x39197b0b
  .word 0xe8c6b452
  .word 0x8422721d
  .word 0xf41ba34b
  .word 0x813ea946
  .word 0x7b6be87b
  .word 0xad656140
  .word 0xf8bf459b
  .word 0x54d30463
  .word 0xd1cd9260
  .word 0xa1493e11
  .word 0x88e390be
  .word 0x5d15a0d0
  .word 0x06b903e6
  .word 0x0a87b8cc
  .word 0x31b262e1
  .word 0xf2e43efa
  .word 0x03cb6301
  .word 0x2b3ad222
  .word 0xfacc7f21
  .word 0x24634acf
  .word 0x53b8e4ee
  .word 0xe40922b4
  .word 0xaecc8647
  .word 0x82125752
  .word 0x5ba838d2
  .word 0x87478d83
  .word 0xc22c85a1
  .word 0x4b386185
  .word 0xa2131b20
  .word 0x7c0c71df
  .word 0xebaa3a4c
  .word 0x62d4de7f
  .word 0xfc43fb0a
  .word 0x147916c8
  .word 0x17a3d9c7
  .word 0x79002262
  .word 0x78b3c475
  .word 0x71d47cce
  .word 0xdd72c035
  .word 0x9bc63cf0
  .word 0xbbc3bc7b
  .word 0x3e4337c7
  .word 0xc39050e0
  .word 0x5c5a8324
  .word 0xb862915b
  .word 0xc4c82bcb
  .word 0x2368b009
  .word 0x365df422
  .word 0x58bc6f62
  .word 0x0534eec0
  .word 0x7b504343
  .word 0x2a9bb720
  .word 0x2129c900
  .word 0x84bd8734
  .word 0x02032307
  .word 0xc6b8653f
  .word 0x6f5c3c8f
  .word 0xa7f7a1fc
  .word 0x0d1a3d7a
  .word 0xa337a2a8
  .word 0xc8ec1805
  .word 0x203cb7a5
  .word 0xe04f35c8
  .word 0x9cd37b16
  .word 0x0572f064
  .word 0xfe11f703
  .word 0x57443918
  .word 0x48455068
  .word 0x0d7ab8b3
  .word 0x5087b3ea
  .word 0x4c0ad87d
  .word 0x4a9969ce
  .word 0x23362a65
  .word 0xa286be66
  .word 0xf28251f7
  .word 0x676f7978
  .word 0x3ce22525
  .word 0xe41b2783
  .word 0x28d65c26
  .word 0x9eb43580
  .word 0xed245236
  .word 0x21b10514
  .word 0x48db454f
  .word 0xf3c828dd
  .word 0xea248213
  .word 0x56cc7d17
  .word 0x75bf0b72
  .word 0x04532d4c
  .word 0xc4958a14
  .word 0x0e7624e7
  .word 0x10b96601
  .word 0x0e97b04b
  .word 0x320ff290
  .word 0x38c875aa
  .word 0x2193f2c6
  .word 0x0c1a16bf
  .word 0x3b9018b5
  .word 0x9c3ab5a3
  .word 0xd23452af
  .word 0xf2ce4eb2
  .word 0x2060b5cf
  .word 0x0889731f
  .word 0xcac49e09
  .word 0x5125bf90
  .word 0x159244c7
  .word 0x16882bb3
  .word 0x9df6dbbe
  .word 0x38586b81
  .word 0xdc85ce54
  .word 0x0a829e72
  .word 0xfe5ef1cc
  .word 0x72ad7f9c
  .word 0x3843654a
  .word 0xb16ea3d3
  .word 0x0ac216a1
  .word 0x6d0405ad
  .word 0x8144fa2b
  .word 0xc2e1a5d0
  .word 0x4de91593
  .word 0x346de185
  .word 0x3ac79248
  .word 0x0ed1a066
  .word 0x3c2e4c92
  .word 0xda480665
  .word 0x5a465187
  .word 0x923a91a5
  .word 0x87d34f88
  .word 0x5bdb9134
  .word 0x6083109e
  .word 0xe0338dcc
  .word 0x7583508e
  .word 0x0da936ad
  .word 0xb1cd65f8
  .word 0xb87c611a
  .word 0x0b94b02b
  .word 0x12336360
  .word 0x5f18c000
  .word 0x5d51f87f
  .word 0xc7d94b55
  .word 0x70973b1a
  .word 0x4ca16862
  .word 0xd12d3860
  .word 0x2976f769
  .word 0x0d1d6869
  .word 0x7b499c75
  .word 0x50caba86
  .word 0x3d1da382
  .word 0x878897b4
  .word 0x95ab2b17
  .word 0x8bb1fa73
  .word 0x71cb9841
  .word 0x935cc2cf
  .word 0x6897a096
  .word 0x138d3463
  .word 0xbb367f28
  .word 0xc07c6a01
  .word 0x629f1631
  .word 0x47d4b39e
  .word 0x9b7d1b52
  .word 0x8ae6223b
  .word 0x9008f4b8
  .word 0x875ce377
  .word 0x55bc4348
  .word 0x08256f55
  .word 0xea8a2c50
  .word 0xd3c931a9
  .word 0x55139d51
  .word 0x87ade3bc
  .word 0x03a319d7
  .word 0xb441540c
  .word 0x9277e498
  .word 0xfa64ca61
  .word 0x04fbe424
  .word 0x1c7598fb
  .word 0x84fe4888
  .word 0x4370847a
  .word 0x16057033
  .word 0x0cf049a3
  .word 0x6e5090cf
  .word 0xd95d5a72
  .word 0xd89b6de4
  .word 0x8c2b8a3f
  .word 0xa357f989
  .word 0xbcf6a916
  .word 0x9ce6a021
  .word 0x972fa41e
  .word 0x0a585657
  .word 0x8b375c8b
  .word 0x7f123283
  .word 0xb6945d6a
  .word 0x4fd2ea39
  .word 0x0f0bc8a0
  .word 0x29e9bdf1
  .word 0xc0c11141
  .word 0x790fb0ea
  .word 0x82689d6a
  .word 0x6d244d16
  .word 0x831cf9e3
  .word 0x19553e58
  .word 0xcd33e670
  .word 0xe20fd03f
  .word 0xbbf04f62
  .word 0x1e462d9e
  .word 0xe860a70a
  .word 0x5b93b9f7
  .word 0x8edaad7f
  .word 0x4202a214
  .word 0x348b5738
  .word 0x9f7cefb0
  .word 0x90ba7881
  .word 0xd973ccb4
  .word 0xb6f2dc0f
  .word 0xf6a70251
  .word 0x34a8cbab
  .word 0x5009f192
  .word 0x65164b0c
  .word 0x45900938
  .word 0xd00bd5c5
  .word 0x903ed7c7
  .word 0xa17e3146
  .word 0x40b31998
  .word 0xc60ecc02
  .word 0xf0361f69
  .word 0x0c88a664
  .word 0x8850e4fb
  .word 0x8949387b
  .word 0x61254032
  .word 0xd1252322
  .word 0x04e808e8
  .word 0x444454aa
  .word 0x44947c40
  .word 0xf726b361
  .word 0x9d39668f
  .word 0x71220b92
  .word 0x942957f3
  .word 0x1af4e072
  .word 0x7227c7d7
  .word 0x59091324
  .word 0x0eb8af78
  .word 0x522d9b88
  .word 0x74e13c87
  .word 0x9bf2987b
  .word 0x8303b175
  .word 0xaaeb848b
  .word 0x1cab9b97
  .word 0xa51783bb
  .word 0x075162d3
  .word 0x00bab53a
  .word 0xddbdb947
  .word 0xb08bb375
  .word 0x21d65914
  .word 0xee13b60e
  .word 0x04250426
  .word 0xadba2e5e
  .word 0xc58458b9
  .word 0xfab60ca2
  .word 0x28f4a673
  .word 0xf91fe50a
  .word 0x92845bdc
  .word 0x6ff31ac2
  .word 0x0ba749bd
  .word 0xaa98a606
  .word 0x46632703
  .word 0xacae8648
  .word 0x4bfd7021
  .word 0x550308b8
  .word 0xfaaba5c6
  .word 0xb7ae4583
  .word 0x7cf60d2e
  .word 0xb23518e0
  .word 0x31824094
  .word 0x8145aeb7
  .word 0x582bd8a5
  .word 0x41d031b6
  .word 0xb3049d93
  .word 0xd3adf01f
  .word 0xa7004f6a
  .word 0x279bdead
  .word 0x54c1f1f6
  .word 0x882f0a40
  .word 0x505c8654
  .word 0x5821fc05
  .word 0x63c26c22
  .word 0xc9052053
  .word 0xf55b16b7
  .word 0x37ec722c
  .word 0xbb15bc2e
  .word 0x3d002156
  .word 0x661f7916
  .word 0xcbf9f471
  .word 0x1e1763c4
  .word 0xe4091010
  .word 0xaad1c5bb
  .word 0x734e6354
  .word 0x68007bc7
  .word 0x9cd40942
  .word 0x6969613a
  .word 0x43ec1d23
  .word 0xaa89590e
  .word 0x5a180068
  .word 0x40e1b6b7
  .word 0x17067480
  .word 0xb9b76a45
  .word 0xc14acedb
  .word 0x6f2c7d01
  .word 0x5dce3c82
  .word 0x35bca0f3
  .word 0x7dc9cb85
  .word 0xd0371477
  .word 0xa45f481b
  .word 0x7148a00e
  .word 0x9bb859ba
  .word 0xe29db522
  .word 0x48967cae
  .word 0xdb0632ef
  .word 0x850295db
  .word 0x5a636868
  .word 0xa1394222
  .word 0x07e901db
  .word 0x2b88156e
  .word 0x430905aa
  .word 0x12241d92
  .word 0x6972f197
  .word 0xf593fa4c
  .word 0xc722e96e
  .word 0x7b9360d6
  .word 0x07c33759
  .word 0x8f96624d
  .word 0x11126d00
  .word 0x689602c6
  .word 0xdee55359

/* Modulus: KYBER_Q = 3329 */
.globl modulus
modulus:
  .word 0x00000d01
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

.globl modulus_bn
modulus_bn:
  .word 0x0d010d01
  .word 0x0d010d01
  .word 0x0d010d01
  .word 0x0d010d01
  .word 0x0d010d01
  .word 0x0d010d01
  .word 0x0d010d01
  .word 0x0d010d01

.globl modulus_over_2
modulus_over_2:
  .word 0x06810681
  .word 0x06810681
  .word 0x06810681
  .word 0x06810681
  .word 0x06810681
  .word 0x06810681
  .word 0x06810681
  .word 0x06810681

.globl const_0x0fff
const_0x0fff:
  .word 0x0fff0fff
  .word 0x0fff0fff
  .word 0x0fff0fff
  .word 0x0fff0fff
  .word 0x0fff0fff
  .word 0x0fff0fff
  .word 0x0fff0fff
  .word 0x0fff0fff

.globl const_1290167
const_1290167:
  .word 0x0013afb7
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

.globl const_8
const_8:
  .word 0x00080008
  .word 0x00080008
  .word 0x00080008
  .word 0x00080008
  .word 0x00080008
  .word 0x00080008
  .word 0x00080008
  .word 0x00080008
  
/* 1/Q mod 2^32 */
.globl qinv
qinv:
  .word 0x6ba8f301
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

.globl const_toplant
const_toplant:
  .word 0x97f44fab
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

.globl twiddles_ntt_base
twiddles_ntt_base:
    /* Layer 1--4 */ 
  .word 0x84f5c5b6, 0x00000000
  .word 0xc666e465, 0x00000000
  .word 0xfcec8b58, 0x00000000
  .word 0xcb2b72d0, 0x00000000
  .word 0x30726d5b, 0x00000000
  .word 0x91e11612, 0x00000000
  .word 0x41360f89, 0x00000000
  .word 0x51aaf2da, 0x00000000
  .word 0x93922fd5, 0x00000000
  .word 0x0ed77946, 0x00000000
  .word 0x3d4a0dff, 0x00000000
  .word 0xd63e49fb, 0x00000000
  .word 0xfab1a391, 0x00000000
  .word 0x2bc18ea7, 0x00000000
  .word 0x864470e4, 0x00000000
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Layer 5 - 1 */
  .word 0x16c32c11, 0x00000000
  /* Layer 6 - 1 */
  .word 0x16395e0d, 0x00000000
  .word 0x19743224, 0x00000000
  /* Layer 7 - 1 */
  .word 0x014eab2e, 0x00000000
  .word 0xd4522112, 0x00000000
  .word 0x2cd52aae, 0x00000000
  .word 0xcbb540d4, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 2 */
  .word 0xbc2c9a1c, 0x00000000
  /* Layer 6 - 2 */
  .word 0xfa27d58e, 0x00000000
  .word 0x87094e0e, 0x00000000
  /* Layer 7 - 2 */
  .word 0x7de29fcd, 0x00000000
  .word 0x379942fb, 0x00000000
  .word 0xaff27732, 0x00000000
  .word 0x54970814, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 3 */
  .word 0x66f8144e, 0x00000000
  /* Layer 6 - 3 */
  .word 0x5c0c9c92, 0x00000000
  .word 0xb12d72a9, 0x00000000
  /* Layer 7 - 3 */
  .word 0x6c5a2074, 0x00000000
  .word 0xccb52d24, 0x00000000
  .word 0xfc4f0d9d, 0x00000000
  .word 0x11eaedee, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 4 */
  .word 0x71811d74, 0x00000000
  /* Layer 6 - 4 */
  .word 0xaf19ea51, 0x00000000
  .word 0x9e078945, 0x00000000
  /* Layer 7 - 4 */
  .word 0x3a22e9a0, 0x00000000
  .word 0xa5cbdca1, 0x00000000
  .word 0xe7da790b, 0x00000000
  .word 0xea8b7f1e, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 5 */
  .word 0xea3cc040, 0x00000000
  /* Layer 6 - 5 */
  .word 0x31fc27af, 0x00000000
  .word 0x9807ff63, 0x00000000
  /* Layer 7 - 5 */
  .word 0x82f5ed16, 0x00000000
  .word 0x7ef63bd5, 0x00000000
  .word 0xd6795921, 0x00000000
  .word 0x8992f4b3, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 6 */
  .word 0x044e701f, 0x00000000
  /* Layer 6 - 6 */
  .word 0xc13fe765, 0x00000000
  .word 0x3099ccc9, 0x00000000
  /* Layer 7 - 6 */
  .word 0x8e08c440, 0x00000000
  .word 0x4935720b, 0x00000000
  .word 0x7059d1b5, 0x00000000
  .word 0xcea1560e, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 7 */
  .word 0xac4184cf, 0x00000000
  /* Layer 6 - 7 */
  .word 0xdc518394, 0x00000000
  .word 0x0289a6a5, 0x00000000
  /* Layer 7 - 7 */
  .word 0x483585bb, 0x00000000
  .word 0xb17c3187, 0x00000000
  .word 0xbb67bcf2, 0x00000000
  .word 0xb7a31ad7, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 8 */
  .word 0x6681f601, 0x00000000
  /* Layer 6 - 8 */
  .word 0x658209b1, 0x00000000
  .word 0x934370f8, 0x00000000
  /* Layer 7 - 8 */
  .word 0x385e2025, 0x00000000
  .word 0xb3b7194d, 0x00000000
  .word 0x149bf401, 0x00000000
  .word 0x314afa3c, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 9 */
  .word 0x6da8cba2, 0x00000000
  /* Layer 6 - 9 */
  .word 0xb254be68, 0x00000000
  .word 0x6e59f915, 0x00000000
  /* Layer 7 - 9 */
  .word 0x79cf3ed4, 0x00000000
  .word 0xb0b7545c, 0x00000000
  .word 0x9ca52e5f, 0x00000000
  .word 0xf79e2ee9, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 10 */
  .word 0xa1074e36, 0x00000000
  /* Layer 6 - 10 */
  .word 0x3e0eeb29, 0x00000000
  .word 0x22c23fd4, 0x00000000
  /* Layer 7 - 10 */
  .word 0x1cd665aa, 0x00000000
  .word 0xc4049d2f, 0x00000000
  .word 0xa0b88f58, 0x00000000
  .word 0x7e801d88, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 11 */
  .word 0x2924384b, 0x00000000
  /* Layer 6 - 11 */
  .word 0x6e95083b, 0x00000000
  .word 0xdc8c92ba, 0x00000000
  /* Layer 7 - 11 */
  .word 0x51bea292, 0x00000000
  .word 0x1887f58b, 0x00000000
  .word 0xd53e5dab, 0x00000000
  .word 0x3a369957, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 12 */
  .word 0xdda02ec2, 0x00000000
  /* Layer 6 - 12 */
  .word 0x75f6ed02, 0x00000000
  .word 0xb8b6b6df, 0x00000000
  /* Layer 7 - 12 */
  .word 0xa169bccb, 0x00000000
  .word 0x2b2410ec, 0x00000000
  .word 0xbda2a4b9, 0x00000000
  .word 0xc77a806d, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 13 */
  .word 0xb805896c, 0x00000000
  /* Layer 6 - 13 */
  .word 0xcb8de165, 0x00000000
  .word 0xc93f49e7, 0x00000000
  /* Layer 7 - 13 */
  .word 0xd7a0a4e0, 0x00000000
  .word 0x53f98a58, 0x00000000
  .word 0x1efd9db9, 0x00000000
  .word 0x4ee63d0f, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 14 */
  .word 0xdd651f9c, 0x00000000
  /* Layer 6 - 14 */
  .word 0x71e38c09, 0x00000000
  .word 0x31d4c840, 0x00000000
  /* Layer 7 - 14 */
  .word 0x57e58be2, 0x00000000
  .word 0xa555be54, 0x00000000
  .word 0xd565bd19, 0x00000000
  .word 0x442224c3, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 15 */
  .word 0x97ccf03d, 0x00000000
  /* Layer 6 - 15 */
  .word 0xbe402274, 0x00000000
  .word 0xef28ae1a, 0x00000000
  /* Layer 7 - 15 */
  .word 0x846bf7b2, 0x00000000
  .word 0x5d33e851, 0x00000000
  .word 0x901c4c98, 0x00000000
  .word 0x4f214c36, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 5 - 16 */
  .word 0x3f228731, 0x00000000
  /* Layer 6 - 16 */
  .word 0x5e5b3410, 0x00000000
  .word 0x45fa9df4, 0x00000000
  /* Layer 7 - 16 */
  .word 0xa24249ac, 0x00000000
  .word 0xe1b38fba, 0x00000000
  .word 0x440e750b, 0x00000000
  .word 0xa5a47d32, 0x00000000
  .word 0x00000000, 0x00000000

.globl twiddles_intt_base
twiddles_intt_base:
  /* Layer 7 - 1 */
  .word 0x5a5b82cf, 0x00000000
  .word 0xbbf18af6, 0x00000000
  .word 0x1e4c7047, 0x00000000
  .word 0x5dbdb655, 0x00000000
  /* Layer 6 - 1 */
  .word 0xba05620d, 0x00000000
  .word 0xa1a4cbf1, 0x00000000
  /* Layer 5 - 1 */
  .word 0xc0dd78d0, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 2 */
  .word 0xb0deb3cb, 0x00000000
  .word 0x6fe3b369, 0x00000000
  .word 0xa2cc17b0, 0x00000000
  .word 0x7b94084f, 0x00000000
  /* Layer 6 - 2 */
  .word 0x10d751e7, 0x00000000
  .word 0x41bfdd8d, 0x00000000
  /* Layer 5 - 2 */
  .word 0x68330fc4, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 3 */
  .word 0xbbdddb3e, 0x00000000
  .word 0x2a9a42e8, 0x00000000
  .word 0x5aaa41ad, 0x00000000
  .word 0xa81a741f, 0x00000000
  /* Layer 6 - 3 */
  .word 0xce2b37c1, 0x00000000
  .word 0x8e1c73f8, 0x00000000
  /* Layer 5 - 3 */
  .word 0x229ae065, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 4 */
  .word 0xb119c2f2, 0x00000000
  .word 0xe1026248, 0x00000000
  .word 0xac0675a9, 0x00000000
  .word 0x285f5b21, 0x00000000
  /* Layer 6 - 4 */
  .word 0x36c0b61a, 0x00000000
  .word 0x34721e9c, 0x00000000
  /* Layer 5 - 4 */
  .word 0x47fa7695, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 5 */
  .word 0x38857f94, 0x00000000
  .word 0x425d5b48, 0x00000000
  .word 0xd4dbef15, 0x00000000
  .word 0x5e964336, 0x00000000
  /* Layer 6 - 5 */
  .word 0x47494922, 0x00000000
  .word 0x8a0912ff, 0x00000000
  /* Layer 5 - 5 */
  .word 0x225fd13f, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 6 */
  .word 0xc5c966aa, 0x00000000
  .word 0x2ac1a256, 0x00000000
  .word 0xe7780a76, 0x00000000
  .word 0xae415d6f, 0x00000000
  /* Layer 6 - 6 */
  .word 0x23736d47, 0x00000000
  .word 0x916af7c6, 0x00000000
  /* Layer 5 - 6 */
  .word 0xd6dbc7b6, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 7 */
  .word 0x817fe279, 0x00000000
  .word 0x5f4770a9, 0x00000000
  .word 0x3bfb62d2, 0x00000000
  .word 0xe3299a57, 0x00000000
  /* Layer 6 - 7 */
  .word 0xdd3dc02d, 0x00000000
  .word 0xc1f114d8, 0x00000000
  /* Layer 5 - 7 */
  .word 0x5ef8b1cb, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 8 */
  .word 0x0861d118, 0x00000000
  .word 0x635ad1a2, 0x00000000
  .word 0x4f48aba5, 0x00000000
  .word 0x8630c12d, 0x00000000
  /* Layer 6 - 8 */
  .word 0x91a606ec, 0x00000000
  .word 0x4dab4199, 0x00000000
  /* Layer 5 - 8 */
  .word 0x9257345f, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 9 */
  .word 0xceb505c5, 0x00000000
  .word 0xeb640c00, 0x00000000
  .word 0x4c48e6b4, 0x00000000
  .word 0xc7a1dfdc, 0x00000000
  /* Layer 6 - 9 */
  .word 0x6cbc8f09, 0x00000000
  .word 0x9a7df650, 0x00000000
  /* Layer 5 - 9 */
  .word 0x997e0a00, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 10 */
  .word 0x485ce52a, 0x00000000
  .word 0x4498430f, 0x00000000
  .word 0x4e83ce7a, 0x00000000
  .word 0xb7ca7a46, 0x00000000
  /* Layer 6 - 10 */
  .word 0xfd76595c, 0x00000000
  .word 0x23ae7c6d, 0x00000000
  /* Layer 5 - 10 */
  .word 0x53be7b32, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 11 */
  .word 0x315ea9f3, 0x00000000
  .word 0x8fa62e4c, 0x00000000
  .word 0xb6ca8df6, 0x00000000
  .word 0x71f73bc1, 0x00000000
  /* Layer 6 - 11 */
  .word 0xcf663338, 0x00000000
  .word 0x3ec0189c, 0x00000000
  /* Layer 5 - 11 */
  .word 0xfbb18fe2, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 12 */
  .word 0x766d0b4e, 0x00000000
  .word 0x2986a6e0, 0x00000000
  .word 0x8109c42c, 0x00000000
  .word 0x7d0a12eb, 0x00000000
  /* Layer 6 - 12 */
  .word 0x67f8009e, 0x00000000
  .word 0xce03d852, 0x00000000
  /* Layer 5 - 12 */
  .word 0x15c33fc1, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 13 */
  .word 0x157480e3, 0x00000000
  .word 0x182586f6, 0x00000000
  .word 0x5a342360, 0x00000000
  .word 0xc5dd1661, 0x00000000
  /* Layer 6 - 13 */
  .word 0x61f876bc, 0x00000000
  .word 0x50e615b0, 0x00000000
  /* Layer 5 - 13 */
  .word 0x8e7ee28d, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 14 */
  .word 0xee151213, 0x00000000
  .word 0x03b0f264, 0x00000000
  .word 0x334ad2dd, 0x00000000
  .word 0x93a5df8d, 0x00000000
  /* Layer 6 - 14 */
  .word 0x4ed28d58, 0x00000000
  .word 0xa3f3636f, 0x00000000
  /* Layer 5 - 14 */
  .word 0x9907ebb3, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 15 */
  .word 0xab68f7ed, 0x00000000
  .word 0x500d88cf, 0x00000000
  .word 0xc866bd06, 0x00000000
  .word 0x821d6034, 0x00000000
  /* Layer 6 - 15 */
  .word 0x78f6b1f3, 0x00000000
  .word 0x05d82a73, 0x00000000
  /* Layer 5 - 15 */
  .word 0x43d365e5, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 7 - 16 */
  .word 0x344abf2d, 0x00000000
  .word 0xd32ad553, 0x00000000
  .word 0x2baddeef, 0x00000000
  .word 0xfeb154d3, 0x00000000
  /* Layer 6 - 16 */
  .word 0xe68bcddd, 0x00000000
  .word 0xe9c6a1f4, 0x00000000
  /* Layer 5 - 16 */
  .word 0xe93cd3f0, 0x00000000
  .word 0x00000000, 0x00000000
  /* Layer 4--1 */ 
  .word 0x79bb8f1d, 0x00000000
  .word 0xd43e715a, 0x00000000
  .word 0x054e5c70, 0x00000000
  .word 0x29c1b606, 0x00000000
  .word 0xc2b5f202, 0x00000000
  .word 0xf12886bb, 0x00000000
  .word 0x6c6dd02c, 0x00000000
  .word 0xae550d27, 0x00000000
  .word 0xbec9f078, 0x00000000
  .word 0x6e1ee9ef, 0x00000000
  .word 0xcf8d92a6, 0x00000000
  .word 0x34d48d31, 0x00000000
  .word 0x031374a9, 0x00000000
  .word 0x39991b9c, 0x00000000
  .word 0x6b6de3db, 0x00000000
  /* n_inv */ 
  .word 0x912fe8a0, 0x00000000

.globl twiddles_basemul_base
twiddles_basemul_base:
  /* basemul -- 1 */
  .word 0x014eab2e, 0x00000000
  .word 0xd4522112, 0x00000000
  .word 0x2cd52aae, 0x00000000
  .word 0xcbb540d4, 0x00000000
  /* basemul -- 2 */
  .word 0x7de29fcd, 0x00000000
  .word 0x379942fb, 0x00000000
  .word 0xaff27732, 0x00000000
  .word 0x54970814, 0x00000000
  /* basemul -- 3 */
  .word 0x6c5a2074, 0x00000000
  .word 0xccb52d24, 0x00000000
  .word 0xfc4f0d9d, 0x00000000
  .word 0x11eaedee, 0x00000000
  /* basemul -- 4 */
  .word 0x3a22e9a0, 0x00000000
  .word 0xa5cbdca1, 0x00000000
  .word 0xe7da790b, 0x00000000
  .word 0xea8b7f1e, 0x00000000
  /* basemul -- 5 */
  .word 0x82f5ed16, 0x00000000
  .word 0x7ef63bd5, 0x00000000
  .word 0xd6795921, 0x00000000
  .word 0x8992f4b3, 0x00000000
  /* basemul -- 6 */
  .word 0x8e08c440, 0x00000000
  .word 0x4935720b, 0x00000000
  .word 0x7059d1b5, 0x00000000
  .word 0xcea1560e, 0x00000000
  /* basemul -- 7 */
  .word 0x483585bb, 0x00000000
  .word 0xb17c3187, 0x00000000
  .word 0xbb67bcf2, 0x00000000
  .word 0xb7a31ad7, 0x00000000
  /* basemul -- 8 */
  .word 0x385e2025, 0x00000000
  .word 0xb3b7194d, 0x00000000
  .word 0x149bf401, 0x00000000
  .word 0x314afa3c, 0x00000000
  /* basemul -- 9 */
  .word 0x79cf3ed4, 0x00000000
  .word 0xb0b7545c, 0x00000000
  .word 0x9ca52e5f, 0x00000000
  .word 0xf79e2ee9, 0x00000000
  /* basemul -- 10 */
  .word 0x1cd665aa, 0x00000000
  .word 0xc4049d2f, 0x00000000
  .word 0xa0b88f58, 0x00000000
  .word 0x7e801d88, 0x00000000
  /* basemul -- 11 */
  .word 0x51bea292, 0x00000000
  .word 0x1887f58b, 0x00000000
  .word 0xd53e5dab, 0x00000000
  .word 0x3a369957, 0x00000000
  /* basemul -- 12 */
  .word 0xa169bccb, 0x00000000
  .word 0x2b2410ec, 0x00000000
  .word 0xbda2a4b9, 0x00000000
  .word 0xc77a806d, 0x00000000
  /* basemul -- 13 */
  .word 0xd7a0a4e0, 0x00000000
  .word 0x53f98a58, 0x00000000
  .word 0x1efd9db9, 0x00000000
  .word 0x4ee63d0f, 0x00000000
  /* basemul -- 14 */
  .word 0x57e58be2, 0x00000000
  .word 0xa555be54, 0x00000000
  .word 0xd565bd19, 0x00000000
  .word 0x442224c3, 0x00000000
  /* basemul -- 15 */
  .word 0x846bf7b2, 0x00000000
  .word 0x5d33e851, 0x00000000
  .word 0x901c4c98, 0x00000000
  .word 0x4f214c36, 0x00000000
  /* basemul -- 16 */
  .word 0xa24249ac, 0x00000000
  .word 0xe1b38fba, 0x00000000
  .word 0x440e750b, 0x00000000
  .word 0xa5a47d32, 0x00000000

.globl context
context:
  .balign 32
  .zero 212

.globl rc
.balign 32
rc:
  .balign 32
  .dword 0x0000000000000001
  .balign 32
  .dword 0x0000000000008082
  .balign 32
  .dword 0x800000000000808a
  .balign 32
  .dword 0x8000000080008000
  .balign 32
  .dword 0x000000000000808b
  .balign 32
  .dword 0x0000000080000001
  .balign 32
  .dword 0x8000000080008081
  .balign 32
  .dword 0x8000000000008009
  .balign 32
  .dword 0x000000000000008a
  .balign 32
  .dword 0x0000000000000088
  .balign 32
  .dword 0x0000000080008009
  .balign 32
  .dword 0x000000008000000a
  .balign 32
  .dword 0x000000008000808b
  .balign 32
  .dword 0x800000000000008b
  .balign 32
  .dword 0x8000000000008089
  .balign 32
  .dword 0x8000000000008003
  .balign 32
  .dword 0x8000000000008002
  .balign 32
  .dword 0x8000000000000080
  .balign 32
  .dword 0x000000000000800a
  .balign 32
  .dword 0x800000008000000a
  .balign 32
  .dword 0x8000000080008081
  .balign 32
  .dword 0x8000000000008080
  .balign 32
  .dword 0x0000000080000001
  .balign 32
  .dword 0x8000000080008008