/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */
/* Modified by Authors of "Towards ML-KEM & ML-DSA on OpenTitan" (https://eprint.iacr.org/2024/1192) */
/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */


/**
 * Test for poly_reduce32_dilithium
*/

.section .text.start

/* Entry point. */
.globl main
main:
  /* Init all-zero register. */
  bn.xor  w31, w31, w31

  /* MOD <= dmem[modulus] = DILITHIUM_Q */
  /*li      x2, 2
  la      x3, modulus
  bn.lid  x2, 0(x3)*/
  bn.addi w2, w31, 128
  bn.add w2, w31, w2 << 16
  bn.addi w3, w31, 32
  bn.sub w2, w2, w3 << 8
  bn.addi w30, w2, 1
  bn.wsrw 0x0, w30

  /* dmem[data] <= NTT(dmem[input]) */
  la  x10, input1
  la  x11, input1
  jal  x1, poly_reduce32_dilithium

  ecall

.data
.balign 32
/* First input */
input1:
  .word 0x4923b869
  .word 0x3dc494b6
  .word 0x1a616d40
  .word 0x0467561c
  .word 0x29f475a1
  .word 0x79e837c3
  .word 0x05b4060e
  .word 0x35ebfa81
  .word 0x3a797176
  .word 0x3a7ca165
  .word 0x7c14e94f
  .word 0x4a9d8058
  .word 0x11260300
  .word 0x44a6f55a
  .word 0x283d12b0
  .word 0x3c281b6f
  .word 0x6c0a6aba
  .word 0x6bcc64e7
  .word 0x04b9f44e
  .word 0x268c8cd0
  .word 0x444931e7
  .word 0x3134a323
  .word 0x0e740589
  .word 0x3884bccc
  .word 0x794e08d6
  .word 0x7c38e7ef
  .word 0x1f6bf333
  .word 0x125ea410
  .word 0x3a55851c
  .word 0x5488b2af
  .word 0x63857e49
  .word 0x62ecba33
  .word 0x37a49864
  .word 0x45bda9bc
  .word 0x2a73be6d
  .word 0x1f0e4290
  .word 0x3959e585
  .word 0x75d6e094
  .word 0x5630702b
  .word 0x5e3fc2f1
  .word 0x4292f454
  .word 0x15499d69
  .word 0x35d0d365
  .word 0x59d31fd1
  .word 0x7bfda5a4
  .word 0x6a1eda1f
  .word 0x44889785
  .word 0x2cc0efd1
  .word 0x0debbae2
  .word 0x6aae8e73
  .word 0x3ab4b980
  .word 0x632623f3
  .word 0x5cf49ea9
  .word 0x2a08301b
  .word 0x4f3f0fe1
  .word 0x033003c9
  .word 0x7b2e79f9
  .word 0x6cf49a04
  .word 0x5bef5dcd
  .word 0x4c728d32
  .word 0x7d9bdf64
  .word 0x14d12baf
  .word 0x1215404d
  .word 0x7e3089d1
  .word 0x0a351b39
  .word 0x369fa045
  .word 0x719ab661
  .word 0x6e7c711b
  .word 0x55005aca
  .word 0x4c7be20e
  .word 0x504a46f1
  .word 0x3641a3a9
  .word 0x6ffdaa67
  .word 0x62d9f00d
  .word 0x2099f26b
  .word 0x364b3d87
  .word 0x507de123
  .word 0x3bbc337e
  .word 0x40d53856
  .word 0x33c8990b
  .word 0x5cff78eb
  .word 0x73f7797e
  .word 0x584614b4
  .word 0x7497a25f
  .word 0x7b7c23cd
  .word 0x4c3a763d
  .word 0x0216b3c4
  .word 0x5362f10a
  .word 0x5ec6ceb0
  .word 0x4d88e9c1
  .word 0x1592676a
  .word 0x472e801d
  .word 0x1c24e862
  .word 0x48e65767
  .word 0x19c5179c
  .word 0x6f642d86
  .word 0x4857caff
  .word 0x298b386c
  .word 0x4d933666
  .word 0x5c885e3f
  .word 0x32de7bdb
  .word 0x07a2d6b7
  .word 0x5a6e3ef7
  .word 0x2d48d8aa
  .word 0x6941447f
  .word 0x7a52ad17
  .word 0x18e002b8
  .word 0x521157b3
  .word 0x77526e81
  .word 0x51ed4859
  .word 0x48f62b74
  .word 0x47912461
  .word 0x27cdfa46
  .word 0x4a3d6007
  .word 0x516e8be9
  .word 0x6b011af9
  .word 0x7943e813
  .word 0x32a9d7e3
  .word 0x2c34082d
  .word 0x3eeee639
  .word 0x33eb98f0
  .word 0x7875ce87
  .word 0x707801f4
  .word 0x6aab9d88
  .word 0x4a6b6edb
  .word 0x1399eff8
  .word 0x7ad8b7c3
  .word 0x1e160749
  .word 0x5c6073db
  .word 0x5c93ddb2
  .word 0x2c3c0a3a
  .word 0x55233ddf
  .word 0x58c1a033
  .word 0x41513a40
  .word 0x49d9e5cd
  .word 0x4a986dc9
  .word 0x2d7ff0e7
  .word 0x4fab618b
  .word 0x099538bb
  .word 0x539a4835
  .word 0x2b53e48e
  .word 0x2987c2f2
  .word 0x7e4d0158
  .word 0x0269f2fa
  .word 0x25048e9f
  .word 0x73fe60c5
  .word 0x4eae9885
  .word 0x6fd6f540
  .word 0x00b2f878
  .word 0x6b56428f
  .word 0x0ff4275e
  .word 0x08a0db3f
  .word 0x4fe3a2e8
  .word 0x59f39e5d
  .word 0x2afbfb05
  .word 0x330d0c8d
  .word 0x3e91de30
  .word 0x553e5063
  .word 0x21f5cb79
  .word 0x0baa868e
  .word 0x13a95531
  .word 0x746ff68f
  .word 0x12055395
  .word 0x44becfe2
  .word 0x5a4a61a6
  .word 0x7012dc6e
  .word 0x5b451395
  .word 0x12c4ce60
  .word 0x6de0f958
  .word 0x4212ce88
  .word 0x265745b5
  .word 0x73bc2aae
  .word 0x038e4050
  .word 0x5403284e
  .word 0x2b5a4c18
  .word 0x0585a03c
  .word 0x3c1dce53
  .word 0x7dab371f
  .word 0x428a7a4e
  .word 0x720dd00d
  .word 0x10a09221
  .word 0x06d2faaf
  .word 0x7c188364
  .word 0x4e11dedb
  .word 0x74f33c5d
  .word 0x04405b33
  .word 0x772096d3
  .word 0x1c58b8f1
  .word 0x6aca189d
  .word 0x0d2c947b
  .word 0x27d9ac67
  .word 0x458d1695
  .word 0x6e78632a
  .word 0x64e452ac
  .word 0x7e60b287
  .word 0x09250b7d
  .word 0x3a547576
  .word 0x780a9476
  .word 0x16e437b6
  .word 0x2ef908d0
  .word 0x2abf45ab
  .word 0x079f513c
  .word 0x2d83378c
  .word 0x29ac579b
  .word 0x40318204
  .word 0x3408cda9
  .word 0x3ac9f808
  .word 0x7210a823
  .word 0x36fd49e9
  .word 0x0f723734
  .word 0x7045a451
  .word 0x68ee96b0
  .word 0x490c5d8e
  .word 0x35f3865c
  .word 0x60654693
  .word 0x72c3c6d4
  .word 0x7faf361d
  .word 0x47ec432c
  .word 0x39b285ba
  .word 0x3c7591ea
  .word 0x26a5b05c
  .word 0x4019cacb
  .word 0x50c019ba
  .word 0x1784a866
  .word 0x2fd6e8f0
  .word 0x43f98429
  .word 0x150d4163
  .word 0x1513f2fe
  .word 0x03a311ab
  .word 0x28370dc6
  .word 0x02365f91
  .word 0x62b88c89
  .word 0x35d20e76
  .word 0x02340969
  .word 0x055c263b
  .word 0x0ea29693
  .word 0x2cde06eb
  .word 0x36f9e8ad
  .word 0x3db9e3fe
  .word 0x3e3384fd
  .word 0x3c48b60c
  .word 0x14300489
  .word 0x464b2cce
  .word 0x24ef1ffc
  .word 0x7e26c21d
  .word 0x61a91aef
  .word 0x14abfb86
  .word 0x2e205266
  .word 0x31c7f0fb
  .word 0x73a94a5e
  .word 0x3ee6993d
  .word 0x0a9e34fa
  .word 0x1f5a61d9
  .word 0x3981cf98
  .word 0x34f7c07d
  .word 0x5c9e221c
.global reduce32_const
reduce32_const:
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
.global modulus
modulus:
    .word 0x7fe001
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0