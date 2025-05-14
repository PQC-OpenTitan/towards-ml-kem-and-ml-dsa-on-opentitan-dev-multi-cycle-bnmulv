/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */



/**
 * Test for trans8
*/

.section .text.start

/* Entry point. */
.globl main
main:
  /* Init all-zero register. */
  bn.xor  w31, w31, w31

  /* dmem[x] <= trans8(dmem[x]) */
  la      x10, x

  jal     x1, trans8

  /* Test self-inverse */
  bn.trans.8S w10, w23, 0
  bn.trans.8S w10, w24, 1
  bn.trans.8S w10, w25, 2
  bn.trans.8S w10, w26, 3
  bn.trans.8S w10, w27, 4
  bn.trans.8S w10, w28, 5
  bn.trans.8S w10, w29, 6
  bn.trans.8S w10, w30, 7
  bn.addi w23, w10, 0
  bn.addi w24, w11, 0
  bn.addi w25, w12, 0
  bn.addi w26, w13, 0
  bn.addi w27, w14, 0
  bn.addi w28, w15, 0
  bn.addi w29, w16, 0
  bn.addi w30, w17, 0
  bn.trans.8S w10, w23, 0
  bn.trans.8S w10, w24, 1
  bn.trans.8S w10, w25, 2
  bn.trans.8S w10, w26, 3
  bn.trans.8S w10, w27, 4
  bn.trans.8S w10, w28, 5
  bn.trans.8S w10, w29, 6
  bn.trans.8S w10, w30, 7
  bn.addi w23, w10, 0
  bn.addi w24, w11, 0
  bn.addi w25, w12, 0
  bn.addi w26, w13, 0
  bn.addi w27, w14, 0
  bn.addi w28, w15, 0
  bn.addi w29, w16, 0
  bn.addi w30, w17, 0
  /*bn.trans8 w23, w23*/
  /*bn.trans8 w23, w23*/

  ecall

.data

/* First input */
x:
  .word 0x003240ee
  .word 0x002db175
  .word 0x003277b9
  .word 0x0026905b
  .word 0x0039feba
  .word 0x003a52d7
  .word 0x0034e13f
  .word 0x00251899
  .word 0x0030a152
  .word 0x002a751d
  .word 0x0027f7f9
  .word 0x003e7579
  .word 0x003fdbcb
  .word 0x00216501
  .word 0x003b7e70
  .word 0x00334556
  .word 0x002c2e1d
  .word 0x00290b66
  .word 0x0035914f
  .word 0x002e965c
  .word 0x0035ea93
  .word 0x003525d8
  .word 0x0024395b
  .word 0x00388a20
  .word 0x003f67ed
  .word 0x003efd3a
  .word 0x0033985f
  .word 0x00216295
  .word 0x00201938
  .word 0x00244180
  .word 0x003e14b0
  .word 0x0029a908
  .word 0x002baf76
  .word 0x003cb606
  .word 0x002a0744
  .word 0x00318943
  .word 0x002debf7
  .word 0x00220c6e
  .word 0x0032ac9a
  .word 0x003afa9a
  .word 0x0024f962
  .word 0x00272575
  .word 0x002d2e3b
  .word 0x0021267d
  .word 0x002fdc2d
  .word 0x003a24ea
  .word 0x00350571
  .word 0x00310a4c
  .word 0x003b5530
  .word 0x0024c23e
  .word 0x00321ecb
  .word 0x002bf13d
  .word 0x003335e3
  .word 0x00239501
  .word 0x0038c900
  .word 0x00230f65
  .word 0x00254ada
  .word 0x0039cea0
  .word 0x003e4b82
  .word 0x002dd508
  .word 0x002d3826
  .word 0x0027d2fc
  .word 0x0028c25e
  .word 0x0033b888