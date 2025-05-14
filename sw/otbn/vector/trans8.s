/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.globl trans8
trans8:
    /* Set up constants for input/output*/
    li      x23, 23
    li      x24, 24
    li      x25, 25
    li      x26, 26
    li      x27, 27
    li      x28, 28
    li      x29, 29
    li      x30, 30

    /* Load */
    bn.lid  x23, 0(x10)
    bn.lid  x24, 32(x10)
    bn.lid  x25, 64(x10)
    bn.lid  x26, 96(x10)
    bn.lid  x27, 128(x10)
    bn.lid  x28, 160(x10)
    bn.lid  x29, 192(x10)
    bn.lid  x30, 224(x10)

    /* bn.trans8 w23, w23 */
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

    ret

