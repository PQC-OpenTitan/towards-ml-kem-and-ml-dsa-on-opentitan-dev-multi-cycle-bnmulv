/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/**
 * Test to obtain mldsa_isaext code size
*/

.section .text.start

#define CTXLEN 32

#define SEEDBYTES 32
#define CRHBYTES 64
#define TRBYTES 64
#define RNDBYTES 32
#define N 256
#define Q 8380417
#define D 13
#define ROOT_OF_UNITY 1753

#if DILITHIUM_MODE == 2
#define K 4
#define L 4
#define ETA 2
#define TAU 39
#define BETA 78
#define GAMMA1 131072
#define GAMMA2 95232
#define OMEGA 80
#define CTILDEBYTES 32

#define CRYPTO_PUBLICKEYBYTES 1312
#define CRYPTO_SECRETKEYBYTES 2560
#define CRYPTO_BYTES 2420
#define STACK_SIZE 51200 /* minimum 50KB */

#elif DILITHIUM_MODE == 3
#define K 6
#define L 5
#define ETA 4
#define TAU 49
#define BETA 196
#define GAMMA1 524288
#define GAMMA2 261888
#define OMEGA 55
#define CTILDEBYTES 48

#define CRYPTO_PUBLICKEYBYTES 1952
#define CRYPTO_SECRETKEYBYTES 4032
#define CRYPTO_BYTES 3309
#define STACK_SIZE 78848 /* minimum 77KB */

#elif DILITHIUM_MODE == 5
#define K 8
#define L 7
#define ETA 2
#define TAU 60
#define BETA 120
#define GAMMA1 524288
#define GAMMA2 261888
#define OMEGA 75
#define CTILDEBYTES 64

#define CRYPTO_PUBLICKEYBYTES 2592
#define CRYPTO_SECRETKEYBYTES 4896
#define CRYPTO_BYTES 4627
#define STACK_SIZE 120832 /* minimum 118KB */

#endif

#define POLYT1_PACKEDBYTES  320
#define POLYT0_PACKEDBYTES  416
#define POLYVECH_PACKEDBYTES (OMEGA + K)

#if GAMMA1 == (1 << 17)
#define POLYZ_PACKEDBYTES   576
#elif GAMMA1 == (1 << 19)
#define POLYZ_PACKEDBYTES   640
#endif

#if GAMMA2 == (Q-1)/88
#define POLYW1_PACKEDBYTES  192
#elif GAMMA2 == (Q-1)/32
#define POLYW1_PACKEDBYTES  128
#endif

#if ETA == 2
#define POLYETA_PACKEDBYTES  96
#elif ETA == 4
#define POLYETA_PACKEDBYTES 128
#endif

/* Entry point. */
.globl main
main:
  /* Init all-zero register. */
  bn.xor  w31, w31, w31
  
  /* MOD <= dmem[modulus] = DILITHIUM_Q */
  li      x5, 2
  la      x6, modulus
  bn.lid  x5, 0(x6)
  bn.rshi w2, w31, w2 >> 224
  bn.wsrw 0x0, w2

  /* Loadf stack address */
  la  x2, stack_end
  la  x10, zeta
  la  x11, pk
  la  x12, sk
  jal x1, key_pair_dilithium

  la x10, signature
  la x11, message
  la x12, messagelen
  lw x12, 0(x12) /* msglen */
  la x13, sk
  jal x1, sign_dilithium

  la    x10, signature
  li    x11, CRYPTO_BYTES  /* siglen */
  la    x12, message
  la    x13, messagelen
  lw    x13, 0(x13) /* msglen */
  la    x14, pk
  jal x1, verify_dilithium

  ecall

.data
.balign 32
zeta:
  .zero 32
pk:
  .zero CRYPTO_PUBLICKEYBYTES
.balign 32
#if DILITHIUM_MODE == 2
.global stack
stack:
    .zero 2528 /* STACK_SIZE + STACK_SIGNATURE */

.globl signature
signature:
  .zero CRYPTO_BYTES
  .zero 12

.zero 17408 /* STACK_SIZE + STACK_MAT - (CRYPTO_BYTES + 12) - 1504 */

.globl sk
sk:
  .zero CRYPTO_SECRETKEYBYTES

.globl message
message:
  .zero 3196
/* account for longer messages in the tests */

.globl messagelen
messagelen:
  .zero 4

  .zero 23072
stack_end:

#elif DILITHIUM_MODE == 3
.global stack
stack:
    .zero 2656 /* STACK_SIZE + STACK_SIGNATURE */

/* In case of Dilithium3, CTILDEBYTES is 48, not divisible by 32.
   To make the packing easier, we dis-align the start of the signature buffer
   because we will simply need to write C to the beginning, which is much easier
   than dealing with the disalignment later on in the signature. */
  .zero 16
.globl signature
signature:
  .zero CRYPTO_BYTES
  .zero 3

.zero 24576 /* STACK_SIZE + STACK_MAT - (CRYPTO_BYTES + 12) - 79328 */

.globl sk
sk:
  .zero CRYPTO_SECRETKEYBYTES

.globl message
message:
  .zero 3196
/* account for longer messages in the tests */

.globl messagelen
messagelen:
  .zero 4

  .zero 41056
stack_end:

#elif DILITHIUM_MODE == 5
.global stack
stack:
    .zero 2368 /* STACK_SIZE + STACK_SIGNATURE */

.globl signature
signature:
  .zero CRYPTO_BYTES
  .zero 13

.zero 32768 /* STACK_SIZE + STACK_MAT - (CRYPTO_BYTES + 13) - 9536 */

.globl sk
sk:
  .zero CRYPTO_SECRETKEYBYTES

.globl message
message:
  .zero 3196
/* account for longer messages in the tests */

.globl messagelen
messagelen:
  .zero 4

  .zero 72960
stack_end:
#endif

.balign 32
/* Modulus for reduction */
.global modulus
modulus:
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
.global twiddles_fwd
twiddles_fwd:
  /* Layers 1-4 */
  .word 0x00495e02
  .word 0x00397567
  .word 0x00396569
  .word 0x004f062b
  .word 0x0053df73
  .word 0x004fe033
  .word 0x004f066b
  .word 0x0076b1ae
  .word 0x00360dd5
  .word 0x0028edb0
  .word 0x00207fe4
  .word 0x00397283
  .word 0x0070894a
  .word 0x00088192
  .word 0x006d3dc8
  /* Padding */
  .word 0x00000000
  /* Layer 5 - 1*/
  .word 0x004c7294
  .word 0x0041e0b4
  .word 0x0028a3d2
  .word 0x0066528a
  .word 0x004a18a7
  .word 0x00794034
  .word 0x000a52ee
  .word 0x006b7d81
  /* Layer 6 - 1 */
  .word 0x0036f72a
  .word 0x0030911e
  .word 0x0029d13f
  .word 0x00492673
  .word 0x0050685f
  .word 0x002010a2
  .word 0x003887f7
  .word 0x0011b2c3
  .word 0x000603a4
  .word 0x000e2bed
  .word 0x0010b72c
  .word 0x004a5f35
  .word 0x001f9d15
  .word 0x00428cd4
  .word 0x003177f4
  .word 0x0020e612
  /* Layer 7 - 1 */
  .word 0x002ee3f1
  .word 0x0057a930
  .word 0x003fd54c
  .word 0x00503ee1
  .word 0x002648b4
  .word 0x001d90a2
  .word 0x002ae59b
  .word 0x006ef1f5
  .word 0x00137eb9
  .word 0x003ac6ef
  .word 0x004eb2ea
  .word 0x007bb175
  .word 0x001ef256
  .word 0x0045a6d4
  .word 0x0052589c
  .word 0x003f7288
  .word 0x00175102
  .word 0x001187ba
  .word 0x00773e9e
  .word 0x002592ec
  .word 0x00404ce8
  .word 0x001e54e6
  .word 0x001a7e79
  .word 0x004e4817
  .word 0x00075d59
  .word 0x0052aca9
  .word 0x000296d8
  .word 0x004cff12
  .word 0x004aa582
  .word 0x004f16c1
  .word 0x0003978f
  .word 0x0031b859
  /* Layer 8 - 1 */
  .word 0x000006d9
  .word 0x00289838
  .word 0x00120a23
  .word 0x00437ff8
  .word 0x007f735d
  .word 0x0061ab98
  .word 0x00662960
  .word 0x0049b0e3
  .word 0x006257c5
  .word 0x0064b5fe
  .word 0x000154a8
  .word 0x005cd5b4
  .word 0x000c8d0d
  .word 0x00185d96
  .word 0x004bd579
  .word 0x0009b434
  .word 0x00574b3c
  .word 0x007ef8f5
  .word 0x0009b7ff
  .word 0x004dc04e
  .word 0x000f66d5
  .word 0x00437f31
  .word 0x0028de06
  .word 0x007c0db3
  .word 0x0069a8ef
  .word 0x002a4e78
  .word 0x00435e87
  .word 0x004728af
  .word 0x005a6d80
  .word 0x00468298
  .word 0x00465d8d
  .word 0x005a68b0
  .word 0x00409ba9
  .word 0x00246e39
  .word 0x00392db2
  .word 0x0030c31c
  .word 0x002dbfcb
  .word 0x006b3375
  .word 0x0078e00d
  .word 0x001f1d68
  .word 0x0064d3d5
  .word 0x0048c39b
  .word 0x00230923
  .word 0x00285424
  .word 0x00022a0b
  .word 0x00095b76
  .word 0x00628c37
  .word 0x006330bb
  .word 0x0021762a
  .word 0x007bc759
  .word 0x0012eb67
  .word 0x0013232e
  .word 0x007e832c
  .word 0x006be1cc
  .word 0x003da604
  .word 0x007361b8
  .word 0x00658591
  .word 0x004f5859
  .word 0x00454df2
  .word 0x007faf80
  .word 0x0026587a
  .word 0x005e061e
  .word 0x004ae53c
  .word 0x005ea06c
  /* Layer 5 - 2*/
  .word 0x004e9f1d
  .word 0x001a2877
  .word 0x002571df
  .word 0x001649ee
  .word 0x007611bd
  .word 0x00492bb7
  .word 0x002af697
  .word 0x0022d8d5
  /* Layer 6 - 2 */
  .word 0x00341c1d
  .word 0x001ad873
  .word 0x00736681
  .word 0x0049553f
  .word 0x003952f6
  .word 0x0062564a
  .word 0x0065ad05
  .word 0x00439a1c
  .word 0x0053aa5f
  .word 0x0030b622
  .word 0x00087f38
  .word 0x003b0e6d
  .word 0x002c83da
  .word 0x001c496e
  .word 0x00330e2b
  .word 0x001c5b70
  /* Layer 7 - 2 */
  .word 0x005884cc
  .word 0x005b63d0
  .word 0x0035225e
  .word 0x006c09d1
  .word 0x006bc4d3
  .word 0x002e534c
  .word 0x003b8820
  .word 0x002ca4f8
  .word 0x001b4827
  .word 0x005d787a
  .word 0x00400c7e
  .word 0x005bd532
  .word 0x00258ecb
  .word 0x00097a6c
  .word 0x006d285c
  .word 0x00337caa
  .word 0x0014b2a0
  .word 0x0028f186
  .word 0x004af670
  .word 0x0075e826
  .word 0x0005528c
  .word 0x000f6e17
  .word 0x00459b7e
  .word 0x005dbecb
  .word 0x00558536
  .word 0x0055795d
  .word 0x00234a86
  .word 0x0078de66
  .word 0x007adf59
  .word 0x005bf3da
  .word 0x00628b34
  .word 0x001a9e7b
  /* Layer 8 - 2 */
  .word 0x00671ac7
  .word 0x0008f201
  .word 0x00695688
  .word 0x0007c017
  .word 0x00519573
  .word 0x0058018c
  .word 0x003cbd37
  .word 0x00196926
  .word 0x00201fc6
  .word 0x006de024
  .word 0x001e6d3e
  .word 0x006dbfd4
  .word 0x007ab60d
  .word 0x003f4cf5
  .word 0x00273333
  .word 0x001ef206
  .word 0x005ba4ff
  .word 0x00080e6d
  .word 0x002603bd
  .word 0x0074d0bd
  .word 0x002867ba
  .word 0x000b7009
  .word 0x00673957
  .word 0x0011c14e
  .word 0x0060d772
  .word 0x0056038e
  .word 0x006a9dfa
  .word 0x0063e1e3
  .word 0x002decd4
  .word 0x00427e23
  .word 0x001a4b5d
  .word 0x004c76c8
  .word 0x003cf42f
  .word 0x003352d6
  .word 0x002f6316
  .word 0x000d1ff0
  .word 0x005e8885
  .word 0x0051e0ed
  .word 0x007b4064
  .word 0x001cfe14
  .word 0x007fb19a
  .word 0x00034760
  .word 0x006f0a11
  .word 0x00345824
  .word 0x002faa32
  .word 0x0065adb3
  .word 0x0035e1dd
  .word 0x0073f1ce
  .word 0x006af66c
  .word 0x00085260
  .word 0x0007c0f1
  .word 0x000223d4
  .word 0x0023fc65
  .word 0x002ca5e6
  .word 0x00433aac
  .word 0x0010170e
  .word 0x002e1669
  .word 0x00741e78
  .word 0x00776d0b
  .word 0x0068c559
  .word 0x005e6942
  .word 0x0079e1fe
  .word 0x00464ade
  .word 0x0074b6d7

.global twiddles_inv
twiddles_inv:
    /* Layer 8 - 1 */
    .word 0x000b292a
    .word 0x00399523
    .word 0x0005fe03
    .word 0x002176bf
    .word 0x00171aa8
    .word 0x000872f6
    .word 0x000bc189
    .word 0x0051c998
    .word 0x006fc8f3
    .word 0x003ca555
    .word 0x00533a1b
    .word 0x005be39c
    .word 0x007dbc2d
    .word 0x00781f10
    .word 0x00778da1
    .word 0x0014e995
    .word 0x000bee33
    .word 0x0049fe24
    .word 0x001a324e
    .word 0x005035cf
    .word 0x004b87dd
    .word 0x0010d5f0
    .word 0x007c98a1
    .word 0x00002e67
    .word 0x0062e1ed
    .word 0x00049f9d
    .word 0x002dff14
    .word 0x0021577c
    .word 0x0072c011
    .word 0x00507ceb
    .word 0x004c8d2b
    .word 0x0042ebd2
    .word 0x00336939
    .word 0x006594a4
    .word 0x003d61de
    .word 0x0051f32d
    .word 0x001bfe1e
    .word 0x00154207
    .word 0x0029dc73
    .word 0x001f088f
    .word 0x006e1eb3
    .word 0x0018a6aa
    .word 0x00746ff8
    .word 0x00577847
    .word 0x000b0f44
    .word 0x0059dc44
    .word 0x0077d194
    .word 0x00243b02
    .word 0x0060edfb
    .word 0x0058acce
    .word 0x0040930c
    .word 0x000529f4
    .word 0x0012202d
    .word 0x006172c3
    .word 0x0011ffdd
    .word 0x005fc03b
    .word 0x006676db
    .word 0x004322ca
    .word 0x0027de75
    .word 0x002e4a8e
    .word 0x00781fea
    .word 0x00168979
    .word 0x0076ee00
    .word 0x0018c53a
    /* Layer 7 - 1 */
    .word 0x00654186
    .word 0x001d54cd
    .word 0x0023ec27
    .word 0x000500a8
    .word 0x0007019b
    .word 0x005c957b
    .word 0x002a66a4
    .word 0x002a5acb
    .word 0x00222136
    .word 0x003a4483
    .word 0x007071ea
    .word 0x007a8d75
    .word 0x0009f7db
    .word 0x0034e991
    .word 0x0056ee7b
    .word 0x006b2d61
    .word 0x004c6357
    .word 0x0012b7a5
    .word 0x00766595
    .word 0x005a5136
    .word 0x00240acf
    .word 0x003fd383
    .word 0x00226787
    .word 0x006497da
    .word 0x00533b09
    .word 0x004457e1
    .word 0x00518cb5
    .word 0x00141b2e
    .word 0x0013d630
    .word 0x004abda3
    .word 0x00247c31
    .word 0x00275b35
    /* Layer 6 - 1 */
    .word 0x00638491
    .word 0x004cd1d6
    .word 0x00639693
    .word 0x00535c27
    .word 0x0044d194
    .word 0x007760c9
    .word 0x004f29df
    .word 0x002c35a2
    .word 0x003c45e5
    .word 0x001a32fc
    .word 0x001d89b7
    .word 0x00468d0b
    .word 0x00368ac2
    .word 0x000c7980
    .word 0x0065078e
    .word 0x004bc3e4
    /* Layer 5 - 1 */
    .word 0x005d072c
    .word 0x0054e96a
    .word 0x0036b44a
    .word 0x0009ce44
    .word 0x00699613
    .word 0x005a6e22
    .word 0x0065b78a
    .word 0x003140e4
    /* Layer 8 - 2 */
    .word 0x00213f95
    .word 0x0034fac5
    .word 0x0021d9e3
    .word 0x00598787
    .word 0x00003081
    .word 0x003a920f
    .word 0x003087a8
    .word 0x001a5a70
    .word 0x000c7e49
    .word 0x004239fd
    .word 0x0013fe35
    .word 0x00015cd5
    .word 0x006cbcd3
    .word 0x006cf49a
    .word 0x000418a8
    .word 0x005e69d7
    .word 0x001caf46
    .word 0x001d53ca
    .word 0x0076848b
    .word 0x007db5f6
    .word 0x00578bdd
    .word 0x005cd6de
    .word 0x00371c66
    .word 0x001b0c2c
    .word 0x0060c299
    .word 0x0006fff4
    .word 0x0014ac8c
    .word 0x00522036
    .word 0x004f1ce5
    .word 0x0046b24f
    .word 0x005b71c8
    .word 0x003f4458
    .word 0x00257751
    .word 0x00398274
    .word 0x00395d69
    .word 0x00257281
    .word 0x0038b752
    .word 0x003c817a
    .word 0x00559189
    .word 0x00163712
    .word 0x0003d24e
    .word 0x005701fb
    .word 0x003c60d0
    .word 0x0070792c
    .word 0x00321fb3
    .word 0x00762802
    .word 0x0000e70c
    .word 0x002894c5
    .word 0x00762bcd
    .word 0x00340a88
    .word 0x0067826b
    .word 0x007352f4
    .word 0x00230a4d
    .word 0x007e8b59
    .word 0x001b2a03
    .word 0x001d883c
    .word 0x00362f1e
    .word 0x0019b6a1
    .word 0x001e3469
    .word 0x00006ca4
    .word 0x003c6009
    .word 0x006dd5de
    .word 0x005747c9
    .word 0x007fd928
    /* Layer 7 - 2 */
    .word 0x004e27a8
    .word 0x007c4872
    .word 0x0030c940
    .word 0x00353a7f
    .word 0x0032e0ef
    .word 0x007d4929
    .word 0x002d3358
    .word 0x007882a8
    .word 0x003197ea
    .word 0x00656188
    .word 0x00618b1b
    .word 0x003f9319
    .word 0x005a4d15
    .word 0x0008a163
    .word 0x006e5847
    .word 0x00688eff
    .word 0x00406d79
    .word 0x002d8765
    .word 0x003a392d
    .word 0x0060edab
    .word 0x00042e8c
    .word 0x00312d17
    .word 0x00451912
    .word 0x006c6148
    .word 0x0010ee0c
    .word 0x0054fa66
    .word 0x00624f5f
    .word 0x0059974d
    .word 0x002fa120
    .word 0x00400ab5
    .word 0x002836d1
    .word 0x0050fc10
    /* Layer 6 - 2 */
    .word 0x005ef9ef
    .word 0x004e680d
    .word 0x003d532d
    .word 0x006042ec
    .word 0x003580cc
    .word 0x006f28d5
    .word 0x0071b414
    .word 0x0079dc5d
    .word 0x006e2d3e
    .word 0x0047580a
    .word 0x005fcf5f
    .word 0x002f77a2
    .word 0x0036b98e
    .word 0x00560ec2
    .word 0x004f4ee3
    .word 0x0048e8d7
    /* Layer 5 - 2 */
    .word 0x00146280
    .word 0x00758d13
    .word 0x00069fcd
    .word 0x0035c75a
    .word 0x00198d77
    .word 0x00573c2f
    .word 0x003dff4d
    .word 0x00336d6d
    /* Layer 1--4 */
    .word 0x0012a239
    .word 0x00775e6f
    .word 0x000f56b7
    .word 0x00466d7e
    .word 0x005f601d
    .word 0x0056f251
    .word 0x0049d22c
    .word 0x00092e53
    .word 0x0030d996
    .word 0x002fffce
    .word 0x002c008e
    .word 0x0030d9d6
    .word 0x00467a98
    .word 0x00466a9a
    /* including ninv */
    .word 0x0000b662
    /* ninv */
    .word 0x007f6021

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

.global power2round_D_preprocessed
power2round_D_preprocessed:
    .word 0xfff
    .word 0xfff
    .word 0xfff
    .word 0xfff
    .word 0xfff
    .word 0xfff
    .word 0xfff
    .word 0xfff

.global eta
eta:
    .word ETA
    .word ETA
    .word ETA
    .word ETA
    .word ETA
    .word ETA
    .word ETA
    .word ETA

.global polyt0_pack_const
polyt0_pack_const:
    .word 0x1000
    .word 0x1000
    .word 0x1000
    .word 0x1000
    .word 0x1000
    .word 0x1000
    .word 0x1000
    .word 0x1000

.global decompose_const
decompose_const:
#if GAMMA2 == (Q-1)/88
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
#elif GAMMA2 == (Q-1)/32
    .word 1025
    .word 1025
    .word 1025
    .word 1025
    .word 1025
    .word 1025
    .word 1025
    .word 1025
#endif

.global gamma1_vec_const
gamma1_vec_const:
    .word GAMMA1
    .word GAMMA1
    .word GAMMA1
    .word GAMMA1
    .word GAMMA1
    .word GAMMA1
    .word GAMMA1
    .word GAMMA1

.global gamma2_vec_const
gamma2_vec_const:
    .word GAMMA2
    .word GAMMA2
    .word GAMMA2
    .word GAMMA2
    .word GAMMA2
    .word GAMMA2
    .word GAMMA2
    .word GAMMA2

.global qm1half_const
qm1half_const:
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000

.global decompose_127_const
decompose_127_const:
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f

.global decompose_43_const
decompose_43_const:
#if GAMMA2 == (Q-1)/88
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
#elif GAMMA2 == (Q-1)/32
    .word 0x000000f
    .word 0x000000f
    .word 0x000000f
    .word 0x000000f
    .word 0x000000f
    .word 0x000000f
    .word 0x000000f
    .word 0x000000f
#endif

.global polyeta_unpack_mask
polyeta_unpack_mask:
#if ETA == 2
    .word 0x07
    .word 0x07
    .word 0x07
    .word 0x07
    .word 0x07
    .word 0x07
    .word 0x07
    .word 0x07
#elif ETA == 4
    .word 0x0f
    .word 0x0f
    .word 0x0f
    .word 0x0f
    .word 0x0f
    .word 0x0f
    .word 0x0f
    .word 0x0f
#endif

.global polyt1_unpack_dilithium_mask
polyt1_unpack_dilithium_mask:
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff

.global polyt0_unpack_dilithium_mask
polyt0_unpack_dilithium_mask:
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff

.global polyz_unpack_dilithium_mask
polyz_unpack_dilithium_mask:
#if GAMMA1 == (1 << 17)
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
#elif GAMMA1 == (1 << 19)
    .word 0xfffff
    .word 0xfffff
    .word 0xfffff
    .word 0xfffff
    .word 0xfffff
    .word 0xfffff
    .word 0xfffff
    .word 0xfffff
#endif

.global poly_uniform_eta_205
poly_uniform_eta_205:
    .word 205
    .word 205
    .word 205
    .word 205
    .word 205
    .word 205
    .word 205
    .word 205

.global poly_uniform_eta_5
poly_uniform_eta_5:
    .word 5
    .word 5
    .word 5
    .word 5
    .word 5
    .word 5
    .word 5
    .word 5
.balign 32
.globl result
result:
    .zero 32