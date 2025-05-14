/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */



/**
 * Test for mulv
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
  jal     x1, mulv

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
  .word 0x00000857
  .word 0x00007b89
  .word 0xffffcb3e
  .word 0x00007dc5
  .word 0xffffd6fc
  .word 0xffff828a
  .word 0xffffec86
  .word 0xffffa38c

/* Second input */
y:
  .word 0xffff9235
  .word 0x000003cc
  .word 0xffff8995
  .word 0xffffb8f5
  .word 0x000008ce
  .word 0x000053e8
  .word 0xffffc001
  .word 0x00000b68