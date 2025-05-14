/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */



/**
 * Test for andv
*/

.section .text.start

/* Entry point. */
.globl main
main:
  /* Init all-zero register. */
  bn.xor  w31, w31, w31

  /* dmem[y] <= vadd(dmem[x], dmem[y]) = dmem[x] + dmem[y] */
  la      x10, x
  la      x11, y
  jal     x1, andv

  /* Set up output */
  li     x0, 0
  la     x2, x
  /* Load result into w0.
       w0 <= dmem[x] */
  
  bn.lid x0, 0(x2)

  ecall

.data

/* First input */
x:
  .word 0x924770d3
  .word 0x93fdcab8
  .word 0xd035d259
  .word 0x2904cdef
  .word 0x53e8eb43
  .word 0x0b680c1c
  .word 0x9a6ab329
  .word 0xacca7f0d

/* Second input */
y:
  .word 0x6dcbac50
  .word 0x34c2da80
  .word 0xd2d6b877
  .word 0x854a9657
  .word 0xff1e5bef
  .word 0xdc338383
  .word 0x61b0ee09
  .word 0x74f2e2ed
