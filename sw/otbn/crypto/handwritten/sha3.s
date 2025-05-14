/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Based on: https://github.com/mjosaarinen/tiny_sha3 */

.text
/* Register aliases */
.equ x0, zero
.equ x2, sp
.equ x3, fp

.equ x5, t0
.equ x6, t1
.equ x7, t2

.equ x8, s0
.equ x9, s1

.equ x10, a0
.equ x11, a1

.equ x12, a2
.equ x13, a3
.equ x14, a4
.equ x15, a5
.equ x16, a6
.equ x17, a7

.equ x18, s2
.equ x19, s3
.equ x20, s4
.equ x21, s5
.equ x22, s6
.equ x23, s7
.equ x24, s8
.equ x25, s9
.equ x26, s10
.equ x27, s11

.equ x28, t3
.equ x29, t4
.equ x30, t5
.equ x31, t6

#define KECCAKF_ROUNDS 24
#define rc_addr t1
#define bn0 w31
/* 
SHA-3 context:
    200B - data  - offset = 0
      4B - pt    - offset = 200
      4B - rsiz  - offset = 204
      4B - mdlen - offset = 208
    
    MUST be 32B aligned
*/

.global sha3_init
/**
 * sha3_init
 *
 * Initialize SHA-3 "context". 
 *
 * Flags: -
 *
 * @param[in]  a1: message digest length
 * @param[out] a0: pointer to 212 bytes of memory for holding the context.
                   32B aligned.
 *
 * clobbered registers: a0-a1, t0-t2
 */
sha3_init:
    addi t0, a0, 0
    addi t1, zero, 31
    /* Init state to all zeros using bn0 */
    /* 6*32 = 192 */
    LOOPI 6, 1
        bn.sid t1, 0(t0++)
    /* 192 + 8 = 200 DONE */
    sw zero, 0(t0)
    sw zero, 4(t0)
    /* pt = 0 */
    sw zero, 8(t0)
    /* rsiz = 200 - 2 * mdlen */
    slli t1, a1, 1 /* 2 * mdlen */
    addi t2, zero, 200
    sub t1, t2, t1
    sw t1, 12(t0)
    /* mdlen */
    sw a1, 16(t0)
    ret


.global sha3_update
/**
 * sha3_update
 *
 * Update state with additional data (absorb?)
 *
 * Flags: -
 *
 * @param[in]    a2: data length
 * @param[in]    a1: pointer to data
 * @param[inout] a0: pointer to 212 bytes of memory for holding the context.
                   32B aligned.
 *
 * clobbered registers: a0-a7, t0-t5
 */
sha3_update:
    /* Load pt as j */
    lw t0, 200(a0)
    /* Constants */
    li   t5, 0xFFFFFFFC

    /* Counter */
    li a3, 0
    /* NOTE: Could write larger chunks at once, e.g. 4B or even 32B */
    /* Iterare over each input byte */
    beq a2, zero, _sha3_update_skip_loop
    li t6, 3
    LOOP a2, 22
        /* get destination address */
        add t1, a0, t0 /* state[pt] */
        addi t0, t0, 1 /* pt++ */
        /* align destination address */
        and t2, t1, t5
        /* aligned load from destination */
        lw t3, 0(t2)
        /* get lower two bits of destination address */
        andi  t4, t1, 0x3
        slli  t4, t4, 3 /* byte -> bit */

        /* get source address */
        add a4, a1, a3
        /* align source address */
        and a5, a4, t5
        /* aligned load from destination */
        lw a5, 0(a5)
        /* Get lower two bits of source address */
        andi a6, a4, 0x3
        slli a7, a6, 3 /* byte -> bit */
        /* Mask out desired byte */
        srl  a7, a5, a7
        andi a7, a7, 0xFF

        /* Shift a7 to position accoring to t4 */
        sll a7, a7, t4
        /* xor */
        xor t3, t3, a7
        /* Store back to aligned address from t2 */
        sw t3, 0(t2)

        /* Load rsiz */
        lw t4, 204(a0)
        sub t3, t0, t4
        bne t3, zero, _sha3_update_skip

        jal x1, sha3_keccakf
        xor t0, t0, t0 /* j = 0 */

_sha3_update_skip:

        /* Increment counter */
        addi a3, a3, 1
_sha3_update_skip_loop:
    /* store j as pt */
    sw t0, 200(a0)

    ret

/**
 * sha3_final
 *
 * Finalize
 *
 * Flags: -
 *
 * @param[out]   a1: pointer to digest. 4B aligned.
 * @param[inout] a0: pointer to 212 bytes of memory for holding the context.
                   32B aligned.
 *
 * clobbered registers: a0-a7, t0-t6
 */
.global sha3_final
sha3_final:
    /* Constants */
    li   a2, 0xFFFFFFFC
    
    /* Load pt */
    lw t0, 200(a0)
    /* state[pt] */
    add t0, a0, t0
    /* Set low bits to zero */
    and t1, t0, a2
    /* Aligned load */
    lw   t3, 0(t1)
    /* Exgtract lower bits for exact offset */
    andi t4, t0, 0x3
    slli t4, t4, 3 /* byte -> bit */
    addi t5, zero, 0x06
    sll  t5, t5, t4
    xor  t3, t3, t5
    sw t3, 0(t1)

    /* Load rsiz */
    lw t0, 204(a0)
    addi t0, t0, -1 /* rsiz - 1 */ 
    /* state[rsiz - 1] */
    add t0, a0, t0
    /* Set low bits to zero */
    and t1, t0, a2
    /* Aligned load */
    lw   t3, 0(t1)
    /* Exgtract lower bits for exact offset */
    andi t4, t0, 0x3
    slli t4, t4, 3 /* byte -> bit */
    addi t5, zero, 0x80
    sll  t5, t5, t4
    xor  t3, t3, t5
    sw t3, 0(t1)

    jal x1, sha3_keccakf

    /* Load mdlen */
    lw t0, 208(a0)
    srli t1, t0, 2 /* flooring div by 2 */
    beq t1, zero, _sha3_final_remaining
    addi t2, a0, 0
    /* 1. Process floor(mdlen/4) 32-bit values */
    LOOP t1, 4
        lw   t3, 0(t2)
        addi t2, t2, 4
        sw   t3, 0(a1) /* t6 for endianness conversion */
        addi a1, a1, 4
    
    /* 2. Process the remaining mdlen % 4 bytes*/
_sha3_final_remaining:
    /* remaining bytes */
    sub t1, t0, t1
    
    /* construct mask 0xFFFFFFFF */
    addi t6, zero, 0xFF
    slli t3, t6, 8
    or   t6, t6, t3
    slli t3, t6, 16
    or   t6, t6, t3

    /* aligned load from destination (already aligned) */
    lw t3, 0(a1)
    
    /* Shift mask according to remaining bytes */
    slli t1, t1, 3 /* bytes -> bits */
    sll  t4, t6, t1 /* e.g., 0xFFFFFFFF -> 0xFF000000 */

    /* clear bytes in destination */
    and t3, t3, t4

    /* aligned load from state */
    lw t5, 0(t2)
    /* Invert mask */
    sub t4, zero, t4
    /* AND apply mask */
    and t5, t5, t4

    /* OR onto previously masked */
    or t3, t3, t5

    /* Store back */
    sw t3, 0(a1)
    ret

/*
    Assumes Keccak state in w0-w24 low bits... Or load here?
*/
sha3_keccakf:
    /* Load coefficient mask for 64-bit 0xffffffffffffffff */
    bn.addi w25, bn0, 1
    bn.rshi w25, w25, bn0 >> 192
    bn.subi w25, w25, 1

    /* Copy context pointer */
    add t1, zero, a0

    /* Load data into the state */
    addi t0, zero, 30
    bn.lid t0, 0(t1++)
    bn.and w0, w25, w30 >> 0
    bn.and w1, w25, w30 >> 64
    bn.and w2, w25, w30 >> 128
    bn.and w3, w25, w30 >> 192
    bn.lid t0, 0(t1++)
    bn.and w4, w25, w30 >> 0
    bn.and w5, w25, w30 >> 64
    bn.and w6, w25, w30 >> 128
    bn.and w7, w25, w30 >> 192
    bn.lid t0, 0(t1++)
    bn.and w8, w25, w30 >> 0
    bn.and w9, w25, w30 >> 64
    bn.and w10, w25, w30 >> 128
    bn.and w11, w25, w30 >> 192
    bn.lid t0, 0(t1++)
    bn.and w12, w25, w30 >> 0
    bn.and w13, w25, w30 >> 64
    bn.and w14, w25, w30 >> 128
    bn.and w15, w25, w30 >> 192
    bn.lid t0, 0(t1++)
    bn.and w16, w25, w30 >> 0
    bn.and w17, w25, w30 >> 64
    bn.and w18, w25, w30 >> 128
    bn.and w19, w25, w30 >> 192
    bn.lid t0, 0(t1++)
    bn.and w20, w25, w30 >> 0
    bn.and w21, w25, w30 >> 64
    bn.and w22, w25, w30 >> 128
    bn.and w23, w25, w30 >> 192
    bn.lid t0, 0(t1++)
    bn.and w24, w25, w30

    la rc_addr, rc
    LOOPI KECCAKF_ROUNDS, 289
        /* THETA */
        bn.xor w25, w0, w5
        bn.xor w25, w25, w10
        bn.xor w25, w25, w15
        bn.xor w25, w25, w20
        bn.xor w26, w1, w6
        bn.xor w26, w26, w11
        bn.xor w26, w26, w16
        bn.xor w26, w26, w21
        bn.xor w27, w2, w7
        bn.xor w27, w27, w12
        bn.xor w27, w27, w17
        bn.xor w27, w27, w22
        bn.xor w28, w3, w8
        bn.xor w28, w28, w13
        bn.xor w28, w28, w18
        bn.xor w28, w28, w23
        bn.xor w29, w4, w9
        bn.xor w29, w29, w14
        bn.xor w29, w29, w19
        bn.xor w29, w29, w24
        bn.rshi w30, w26, bn0 >> 64
        bn.rshi w30, w26, w30 >> 63
        bn.rshi w30, bn0, w30 >> 192
        bn.xor w30, w29, w30
        bn.xor w0, w0, w30
        bn.xor w5, w5, w30
        bn.xor w10, w10, w30
        bn.xor w15, w15, w30
        bn.xor w20, w20, w30
        bn.rshi w30, w27, bn0 >> 64
        bn.rshi w30, w27, w30 >> 63
        bn.rshi w30, bn0, w30 >> 192
        bn.xor w30, w25, w30
        bn.xor w1, w1, w30
        bn.xor w6, w6, w30
        bn.xor w11, w11, w30
        bn.xor w16, w16, w30
        bn.xor w21, w21, w30
        bn.rshi w30, w28, bn0 >> 64
        bn.rshi w30, w28, w30 >> 63
        bn.rshi w30, bn0, w30 >> 192
        bn.xor w30, w26, w30
        bn.xor w2, w2, w30
        bn.xor w7, w7, w30
        bn.xor w12, w12, w30
        bn.xor w17, w17, w30
        bn.xor w22, w22, w30
        bn.rshi w30, w29, bn0 >> 64
        bn.rshi w30, w29, w30 >> 63
        bn.rshi w30, bn0, w30 >> 192
        bn.xor w30, w27, w30
        bn.xor w3, w3, w30
        bn.xor w8, w8, w30
        bn.xor w13, w13, w30
        bn.xor w18, w18, w30
        bn.xor w23, w23, w30
        bn.rshi w30, w25, bn0 >> 64
        bn.rshi w30, w25, w30 >> 63
        bn.rshi w30, bn0, w30 >> 192
        bn.xor w30, w28, w30
        bn.xor w4, w4, w30
        bn.xor w9, w9, w30
        bn.xor w14, w14, w30
        bn.xor w19, w19, w30
        bn.xor w24, w24, w30
        /* RHO PI */
        bn.mov w30, w1
        bn.mov w25, w10
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 63
        bn.rshi w10, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w7
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 61
        bn.rshi w7, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w11
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 58
        bn.rshi w11, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w17
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 54
        bn.rshi w17, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w18
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 49
        bn.rshi w18, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w3
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 43
        bn.rshi w3, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w5
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 36
        bn.rshi w5, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w16
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 28
        bn.rshi w16, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w8
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 19
        bn.rshi w8, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w21
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 9
        bn.rshi w21, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w24
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 62
        bn.rshi w24, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w4
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 50
        bn.rshi w4, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w15
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 37
        bn.rshi w15, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w23
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 23
        bn.rshi w23, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w19
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 8
        bn.rshi w19, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w13
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 56
        bn.rshi w13, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w12
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 39
        bn.rshi w12, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w2
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 21
        bn.rshi w2, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w20
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 2
        bn.rshi w20, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w14
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 46
        bn.rshi w14, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w22
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 25
        bn.rshi w22, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w9
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 3
        bn.rshi w9, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w6
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 44
        bn.rshi w6, bn0, w26 >> 192
        bn.mov w30, w25
        bn.mov w25, w1
        bn.rshi w26, w30, bn0 >> 64
        bn.rshi w26, w30, w26 >> 20
        bn.rshi w1, bn0, w26 >> 192
        bn.mov w30, w25
        /* CHI */
        bn.mov w25, w0
        bn.mov w26, w1
        bn.mov w27, w2
        bn.mov w28, w3
        bn.mov w29, w4
        bn.not w30, w26
        bn.and w30, w30, w27
        bn.xor w0, w0, w30
        bn.not w30, w27
        bn.and w30, w30, w28
        bn.xor w1, w1, w30
        bn.not w30, w28
        bn.and w30, w30, w29
        bn.xor w2, w2, w30
        bn.not w30, w29
        bn.and w30, w30, w25
        bn.xor w3, w3, w30
        bn.not w30, w25
        bn.and w30, w30, w26
        bn.xor w4, w4, w30
        bn.mov w25, w5
        bn.mov w26, w6
        bn.mov w27, w7
        bn.mov w28, w8
        bn.mov w29, w9
        bn.not w30, w26
        bn.and w30, w30, w27
        bn.xor w5, w5, w30
        bn.not w30, w27
        bn.and w30, w30, w28
        bn.xor w6, w6, w30
        bn.not w30, w28
        bn.and w30, w30, w29
        bn.xor w7, w7, w30
        bn.not w30, w29
        bn.and w30, w30, w25
        bn.xor w8, w8, w30
        bn.not w30, w25
        bn.and w30, w30, w26
        bn.xor w9, w9, w30
        bn.mov w25, w10
        bn.mov w26, w11
        bn.mov w27, w12
        bn.mov w28, w13
        bn.mov w29, w14
        bn.not w30, w26
        bn.and w30, w30, w27
        bn.xor w10, w10, w30
        bn.not w30, w27
        bn.and w30, w30, w28
        bn.xor w11, w11, w30
        bn.not w30, w28
        bn.and w30, w30, w29
        bn.xor w12, w12, w30
        bn.not w30, w29
        bn.and w30, w30, w25
        bn.xor w13, w13, w30
        bn.not w30, w25
        bn.and w30, w30, w26
        bn.xor w14, w14, w30
        bn.mov w25, w15
        bn.mov w26, w16
        bn.mov w27, w17
        bn.mov w28, w18
        bn.mov w29, w19
        bn.not w30, w26
        bn.and w30, w30, w27
        bn.xor w15, w15, w30
        bn.not w30, w27
        bn.and w30, w30, w28
        bn.xor w16, w16, w30
        bn.not w30, w28
        bn.and w30, w30, w29
        bn.xor w17, w17, w30
        bn.not w30, w29
        bn.and w30, w30, w25
        bn.xor w18, w18, w30
        bn.not w30, w25
        bn.and w30, w30, w26
        bn.xor w19, w19, w30
        bn.mov w25, w20
        bn.mov w26, w21
        bn.mov w27, w22
        bn.mov w28, w23
        bn.mov w29, w24
        bn.not w30, w26
        bn.and w30, w30, w27
        bn.xor w20, w20, w30
        bn.not w30, w27
        bn.and w30, w30, w28
        bn.xor w21, w21, w30
        bn.not w30, w28
        bn.and w30, w30, w29
        bn.xor w22, w22, w30
        bn.not w30, w29
        bn.and w30, w30, w25
        bn.xor w23, w23, w30
        bn.not w30, w25
        bn.and w30, w30, w26
        bn.xor w24, w24, w30
        /* IOTA */
        bn.lid t0, 0(rc_addr)
        addi rc_addr, rc_addr, 32
        bn.xor w0, w0, w30

    addi t0, zero, 30
    add t1, zero, a0
    bn.rshi w30, w0, w30 >> 64
    bn.rshi w30, w1, w30 >> 64
    bn.rshi w30, w2, w30 >> 64
    bn.rshi w30, w3, w30 >> 64
    bn.sid t0, 0(t1++)
    bn.rshi w30, w4, w30 >> 64
    bn.rshi w30, w5, w30 >> 64
    bn.rshi w30, w6, w30 >> 64
    bn.rshi w30, w7, w30 >> 64
    bn.sid t0, 0(t1++)
    bn.rshi w30, w8, w30 >> 64
    bn.rshi w30, w9, w30 >> 64
    bn.rshi w30, w10, w30 >> 64
    bn.rshi w30, w11, w30 >> 64
    bn.sid t0, 0(t1++)
    bn.rshi w30, w12, w30 >> 64
    bn.rshi w30, w13, w30 >> 64
    bn.rshi w30, w14, w30 >> 64
    bn.rshi w30, w15, w30 >> 64
    bn.sid t0, 0(t1++)
    bn.rshi w30, w16, w30 >> 64
    bn.rshi w30, w17, w30 >> 64
    bn.rshi w30, w18, w30 >> 64
    bn.rshi w30, w19, w30 >> 64
    bn.sid t0, 0(t1++)
    bn.rshi w30, w20, w30 >> 64
    bn.rshi w30, w21, w30 >> 64
    bn.rshi w30, w22, w30 >> 64
    bn.rshi w30, w23, w30 >> 64
    bn.sid t0, 0(t1++)

    /* Only 64-bit remaining */
    bn.lid t0, 0(t1)

    /* Load coefficient mask for 64-bit 0xffffffffffffffff */
    bn.addi w25, bn0, 1
    bn.rshi w25, w25, bn0 >> 192
    bn.subi w25, w25, 1
    bn.not w25, w25
    bn.and w30, w25, w30

    bn.or w30, w24, w30
    bn.sid t0, 0(t1++)
    ret

/**
 * shake_xof
 *
 * Switch to SHAKE operation mode
 *
 * Flags: -
 *
 * @param[inout] a0: pointer to 212 bytes of memory for holding the context.
                   32B aligned.
 *
 * clobbered registers: a0-a7, t0-t5
 */
.global shake_xof
shake_xof:
    /* Constants */
    li   a2, 0xFFFFFFFC
    
    /* Load pt */
    lw t0, 200(a0)
    /* state[pt] */
    add t0, a0, t0
    /* Set low bits to zero */
    and t1, t0, a2
    /* Aligned load */
    lw   t3, 0(t1)
    /* Exgtract lower bits for exact offset */
    andi t4, t0, 0x3
    slli t4, t4, 3 /* byte -> bit */
    addi t5, zero, 0x1F
    sll  t5, t5, t4
    xor  t3, t3, t5
    sw t3, 0(t1)

    /* Load rsiz */
    lw t0, 204(a0)
    addi t0, t0, -1 /* rsiz - 1 */ 
    /* state[rsiz - 1] */
    add t0, a0, t0
    /* Set low bits to zero */
    and t1, t0, a2
    /* Aligned load */
    lw   t3, 0(t1)
    /* Exgtract lower bits for exact offset */
    andi t4, t0, 0x3
    slli t4, t4, 3 /* byte -> bit */
    addi t5, zero, 0x80
    sll  t5, t5, t4
    xor  t3, t3, t5
    sw t3, 0(t1)

    jal x1, sha3_keccakf

    sw zero, 200(a0)

    ret

/**
 * shake_out
 *
 * Get SHAKE output
 *
 * Flags: -
 *
 * @param[in]    a2: desired output length
 * @param[in]    a1: output pointer
 * @param[inout] a0: pointer to 212 bytes of memory for holding the context.
                   32B aligned.
 *
 * clobbered registers: a0-a7, t0-t5
 */
.global shake_out
shake_out:
    /* Load pt as j */
    lw t0, 200(a0)
    /* Constants */
    li t5, 0xFFFFFFFC
    li t6, 0xFF
    li a7, 0
    addi a7, a7, -1

    /* Counter */
    li a3, 0

    beq a2, zero, _shake_out_skip_loop
    LOOP a2, 26
        /* Load rsiz */
        lw t4, 204(a0)
        sub t3, t0, t4
        srli t3, t3, 31
        bne t3, zero, _shake_out_skip

        jal x1, sha3_keccakf
        xor t0, t0, t0 /* j = 0 */

_shake_out_skip:
        /* Get source address */
        add  t2, t0, a0
        addi t0, t0, 1 /* j++ */

        /* Align source address */
        and t3, t2, t5
        /* Aligned load */
        lw t3, 0(t3)
        /* Extract 2 low bits from address */
        andi t2, t2, 0x3
        slli t2, t2, 3 /* bits -> bytes */
        srl t3, t3, t2
        andi t3, t3, 0xFF

        /* Get destination address */
        add t2, a1, a3
        addi a3, a3, 1 /* counter++ */
        /* Align destination address */
        and a6, t2, t5
        /* Aligned load */
        lw t4, 0(a6)
        /* Extract 2 low bits from address */
        andi a4, t2, 0x3
        slli a4, a4, 3
        /* Clear index for insertion */
        sll a5, t6, a4
        xor a5, a7, a5
        and t4, t4, a5

        /* Insert */ 
        sll t3, t3, a4
        or  t4, t4, t3

        /* Aligned store to output */
        sw t4, 0(a6)

_shake_out_skip_loop:
    /* store j as pt */
    sw t0, 200(a0)
    ret