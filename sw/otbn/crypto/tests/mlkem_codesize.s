/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/*
 * Test to obtain mlkem_isaext code size
*/

.section .text.start

#define STACK_SIZE 20000
#define CRYPTO_BYTES 32

#if KYBER_K == 2
  #define CRYPTO_PUBLICKEYBYTES  800
  #define CRYPTO_SECRETKEYBYTES  1632
  #define CRYPTO_CIPHERTEXTBYTES 768
#elif KYBER_K == 3 
  #define CRYPTO_PUBLICKEYBYTES  1184
  #define CRYPTO_SECRETKEYBYTES  2400
  #define CRYPTO_CIPHERTEXTBYTES 1088
#elif KYBER_K == 4
  #define CRYPTO_PUBLICKEYBYTES  1568
  #define CRYPTO_SECRETKEYBYTES  3168
  #define CRYPTO_CIPHERTEXTBYTES 1568
#endif 

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
    la   x10, randombytes_keypair
    la   x11, kem_pk
    la   x12, kem_sk
    jal  x1, crypto_kem_keypair

    la   x2, stack_end
    la   x10, randombytes_encap
    la   x11, ct
    la   x12, key_b
    la   x13, kem_pk
    jal  x1, crypto_kem_enc

    la   x2, stack_end
    la   x10, ct
    la   x11, kem_sk 
    la   x12, key_a  
    jal  x1, crypto_kem_dec

    ecall

.data
.balign 32
.global stack
stack:
  .zero STACK_SIZE
stack_end:
randombytes_keypair:
  .zero 2*CRYPTO_BYTES
kem_sk:
  .zero CRYPTO_SECRETKEYBYTES
kem_pk:
  .zero CRYPTO_PUBLICKEYBYTES
randombytes_encap:
  .zero CRYPTO_BYTES
ct:
  .zero CRYPTO_CIPHERTEXTBYTES
key_b:
  .zero CRYPTO_BYTES
key_a:
  .zero CRYPTO_BYTES

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
  
.globl const_tomont
const_tomont:
  .word 0x05490549 /* 2^32 % KYBER_Q */
  .word 0x05490549
  .word 0x05490549
  .word 0x05490549
  .word 0x05490549
  .word 0x05490549
  .word 0x05490549
  .word 0x05490549

.globl twiddles_ntt
twiddles_ntt:
    /* Layer 1--4 */ 
    .half 0x06c1
    .half 0x0a14
    .half 0x0cd9
    .half 0x0a52
    .half 0x0276
    .half 0x0769
    .half 0x0350
    .half 0x0426
    .half 0x077f
    .half 0x00c1
    .half 0x031d
    .half 0x0ae2
    .half 0x0cbc
    .half 0x0239
    .half 0x06d2
    /* Padding */
    .half 0x0000
    /* Layer 5 */
    .word 0x01280128
    .word 0x098f098f
    .word 0x053b053b
    .word 0x05c405c4
    .word 0x0be60be6
    .word 0x00380038
    .word 0x08c008c0
    .word 0x05350535
    .word 0x05920592
    .word 0x082e082e
    .word 0x02170217
    .word 0x0b420b42
    .word 0x09590959
    .word 0x0b3f0b3f
    .word 0x07b607b6
    .word 0x03350335
    /* Layer 6 */
    .word 0x01210121
    .word 0x0cb50cb5
    .word 0x04ad04ad
    .word 0x08e508e5
    .word 0x028a028a
    .word 0x09d109d1
    .word 0x0b310b31
    .word 0x05280528
    .word 0x014b014b
    .word 0x06dc06dc
    .word 0x09000900
    .word 0x08070807
    .word 0x07b907b9
    .word 0x02780278
    .word 0x00210021
    .word 0x077b077b
    .word 0x090f090f
    .word 0x03270327
    .word 0x059e059e
    .word 0x05fe05fe
    .word 0x0a570a57
    .word 0x05c905c9
    .word 0x09aa09aa
    .word 0x04cb04cb
    .word 0x059b059b
    .word 0x01c401c4
    .word 0x0b340b34
    .word 0x09620962
    .word 0x0a390a39
    .word 0x02880288
    .word 0x0c260c26
    .word 0x038e038e
    /* Layer 7 */
    .word 0x00110011
    .word 0x06650665
    .word 0x05810581
    .word 0x02f402f4
    .word 0x06a706a7
    .word 0x07370737
    .word 0x03ab03ab
    .word 0x02dd02dd
    .word 0x0ac90ac9
    .word 0x02d302d3
    .word 0x0a660a66
    .word 0x086c086c
    .word 0x06730673
    .word 0x03b803b8
    .word 0x09040904
    .word 0x09210921
    .word 0x02470247
    .word 0x08f008f0
    .word 0x0cd10cd1
    .word 0x0bc70bc7
    .word 0x0ae50ae5
    .word 0x05b505b5
    .word 0x09850985
    .word 0x010c010c
    .word 0x0a590a59
    .word 0x044c044c
    .word 0x00e900e9
    .word 0x0bea0bea
    .word 0x06fd06fd
    .word 0x0a7f0a7f
    .word 0x09540954
    .word 0x02810281
    .word 0x06300630
    .word 0x01770177
    .word 0x04270427
    .word 0x08330833
    .word 0x0af40af4
    .word 0x04770477
    .word 0x06ba06ba
    .word 0x083e083e
    .word 0x08fa08fa
    .word 0x09f509f5
    .word 0x013f013f
    .word 0x02310231
    .word 0x04440444
    .word 0x08660866
    .word 0x04bc04bc
    .word 0x0b770b77
    .word 0x07f507f5
    .word 0x082a082a
    .word 0x0ad50ad5
    .word 0x09a209a2
    .word 0x01930193
    .word 0x0ad70ad7
    .word 0x07520752
    .word 0x03750375
    .word 0x0c940c94
    .word 0x066d066d
    .word 0x02f502f5
    .word 0x0a220a22
    .word 0x04020402
    .word 0x03760376
    .word 0x04050405
    .word 0x086a086a

.globl twiddles_intt
twiddles_intt:
    /* Layer 7 */
    .word 0x04970497
    .word 0x08fc08fc
    .word 0x098b098b
    .word 0x08ff08ff
    .word 0x02df02df
    .word 0x0a0c0a0c
    .word 0x06940694
    .word 0x006d006d
    .word 0x098c098c
    .word 0x05af05af
    .word 0x022a022a
    .word 0x0b6e0b6e
    .word 0x035f035f
    .word 0x022c022c
    .word 0x04d704d7
    .word 0x050c050c
    .word 0x018a018a
    .word 0x08450845
    .word 0x049b049b
    .word 0x08bd08bd
    .word 0x0ad00ad0
    .word 0x0bc20bc2
    .word 0x030c030c
    .word 0x04070407
    .word 0x04c304c3
    .word 0x06470647
    .word 0x088a088a
    .word 0x020d020d
    .word 0x04ce04ce
    .word 0x08da08da
    .word 0x0b8a0b8a
    .word 0x06d106d1
    .word 0x0a800a80
    .word 0x03ad03ad
    .word 0x02820282
    .word 0x06040604
    .word 0x01170117
    .word 0x0c180c18
    .word 0x08b508b5
    .word 0x02a802a8
    .word 0x0bf50bf5
    .word 0x037c037c
    .word 0x074c074c
    .word 0x021c021c
    .word 0x013a013a
    .word 0x00300030
    .word 0x04110411
    .word 0x0aba0aba
    .word 0x03e003e0
    .word 0x03fd03fd
    .word 0x09490949
    .word 0x068e068e
    .word 0x04950495
    .word 0x029b029b
    .word 0x0a2e0a2e
    .word 0x02380238
    .word 0x0a240a24
    .word 0x09560956
    .word 0x05ca05ca
    .word 0x065a065a
    .word 0x0a0d0a0d
    .word 0x07800780
    .word 0x069c069c
    .word 0x0cf00cf0
    /* Layer 6 */
    .word 0x09730973
    .word 0x00db00db
    .word 0x0a790a79
    .word 0x02c802c8
    .word 0x039f039f
    .word 0x01cd01cd
    .word 0x0b3d0b3d
    .word 0x07660766
    .word 0x08360836
    .word 0x03570357
    .word 0x07380738
    .word 0x02aa02aa
    .word 0x07030703
    .word 0x07630763
    .word 0x09da09da
    .word 0x03f203f2
    .word 0x05860586
    .word 0x0ce00ce0
    .word 0x0a890a89
    .word 0x05480548
    .word 0x04fa04fa
    .word 0x04010401
    .word 0x06250625
    .word 0x0bb60bb6
    .word 0x07d907d9
    .word 0x01d001d0
    .word 0x03300330
    .word 0x0a770a77
    .word 0x041c041c
    .word 0x08540854
    .word 0x004c004c
    .word 0x0be00be0
    /* Layer 5 */
    .word 0x09cc09cc
    .word 0x054b054b
    .word 0x01c201c2
    .word 0x03a803a8
    .word 0x01bf01bf
    .word 0x0aea0aea
    .word 0x04d304d3
    .word 0x076f076f
    .word 0x07cc07cc
    .word 0x04410441
    .word 0x0cc90cc9
    .word 0x011b011b
    .word 0x073d073d
    .word 0x07c607c6
    .word 0x03720372
    .word 0x0bd90bd9
    /* Layer 4--2 */ 
    .half 0x062f
    .half 0x0ac8
    .half 0x0045
    .half 0x021f
    .half 0x09e4
    .half 0x0c40
    .half 0x0582
    .half 0x08db
    .half 0x09b1
    .half 0x0598
    .half 0x0a8b
    .half 0x02af
    .half 0x0028
    .half 0x02ed
    /* Layer 1 */ 
    .half 0x068d
    /* 1/128 mod KYBER_Q */
    .half 0x0ce7

.globl twiddles_basemul
twiddles_basemul:
    .word 0x06650011
    .word 0xf99bffef
    .word 0x02d30ac9
    .word 0xfd2df537
    .word 0x08f00247
    .word 0xf710fdb9
    .word 0x044c0a59
    .word 0xfbb4f5a7

    .word 0x02f40581
    .word 0xfd0cfa7f
    .word 0x086c0a66
    .word 0xf794f59a
    .word 0x0bc70cd1
    .word 0xf439f32f
    .word 0x0bea00e9
    .word 0xf416ff17

    .word 0x073706a7
    .word 0xf8c9f959
    .word 0x03b80673
    .word 0xfc48f98d
    .word 0x05b50ae5
    .word 0xfa4bf51b
    .word 0x0a7f06fd
    .word 0xf581f903

    .word 0x02dd03ab
    .word 0xfd23fc55
    .word 0x09210904
    .word 0xf6dff6fc
    .word 0x010c0985
    .word 0xfef4f67b
    .word 0x02810954
    .word 0xfd7ff6ac

    .word 0x01770630
    .word 0xfe89f9d0
    .word 0x09f508fa
    .word 0xf60bf706
    .word 0x082a07f5
    .word 0xf7d6f80b
    .word 0x066d0c94
    .word 0xf993f36c

    .word 0x08330427
    .word 0xf7cdfbd9
    .word 0x0231013f
    .word 0xfdcffec1
    .word 0x09a20ad5
    .word 0xf65ef52b
    .word 0x0a2202f5
    .word 0xf5defd0b

    .word 0x04770af4
    .word 0xfb89f50c
    .word 0x08660444
    .word 0xf79afbbc
    .word 0x0ad70193
    .word 0xf529fe6d
    .word 0x03760402
    .word 0xfc8afbfe

    .word 0x083e06ba
    .word 0xf7c2f946
    .word 0x0b7704bc
    .word 0xf489fb44
    .word 0x03750752
    .word 0xfc8bf8ae
    .word 0x086a0405
    .word 0xf796fbfb
