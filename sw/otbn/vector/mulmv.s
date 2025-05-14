/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.globl mulmv
mulmv:
    /* Set up constants for input/output
         x23 <= 23
         x24 <= 24
         x25 <= 25
         x26 <= 26 */
    li      x23, 23
    li      x24, 24
    li      x25, 25
    li      x26, 26

    /* Load the least significant limbs of x and y.
         w23 <= dmem[x10] = x[255:0]
         w24 <= dmem[x11] = y[255:0] */
    bn.lid  x23, 0(x10)
    bn.lid  x24, 0(x11)

    bn.mulvm.8S   w25, w23, w24
    bn.mulvm.l.8S w26, w23, w24, 6

    /* Write result
         dmem[x10] <= w25
         dmem[x11] <= w26 */
    bn.sid  x25, 0(x10)
    bn.sid  x26, 0(x11)

    ret

