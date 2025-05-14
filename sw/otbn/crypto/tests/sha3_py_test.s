/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/**
 * Standalone tests for SHA-3 hash computation.
 */

.section .text.start
run_sha3:
  /* Load stack pointer */
  la x2, stack_end

  la x10, context
  /* Get digest size in bytes */
  la x5, dgst_size
  lw x5, 0(x5)
  srli x11, x5, 3
  jal x1, sha3_init

  /* SHA or SHAKE? */
  la x5, dgst_mode
  lw x5, 0(x5)
  bne x5, zero, _SHAKE

_SHA:
  la x10, context
  la x11, msg
  la x12, msg_len
  lw x12, 0(x12)
  jal x1, sha3_update

  la x10, context
  la x11, digest
  jal x1, sha3_final
  beq zero, zero, _END
_SHAKE:
  la x19, context
  la x18, msg
  la x9, shake_absorb_size
  lw x9, 0(x9)
  la x8, shake_absorbs
  lw x8, 0(x8)
  LOOP x8, 5
    addi x10, x19, 0  /* Copy back context address */
    addi x11, x18, 0  /* Copy back message address */
    addi x12, x9, 0   /* Copy back the absorb size */
    jal  x1, sha3_update
    add  x18, x18, x9 /* Advance message address */

  la x10, context
  jal x1, shake_xof

  la x8, context
  la x9, digest
  la x18, shake_squeezes
  lw x18, 0(x18)
  la x19, shake_squeeze_size
  lw x19, 0(x19)
  LOOP x18, 5
    addi x10, x8, 0  /* Copy back context */
    addi x11, x9, 0  /* Copy back digest address */
    addi x12, x19, 0 /* Copy back squeeze size */
    jal x1, shake_out
    add x9, x9, x19  /* Advance digest address */

_END:

  ecall

.section .data

.global msg
msg:
  .balign 32
  .dword 0xA3A3A3A3A3A3A3A3
  .dword 0xA3A3A3A3A3A3A3A3
  .dword 0xA3A3A3A3
  .zero 1004 /* 1024! */
/* digest starts at 1028! Not clear why. */
.global digest
digest:
  .balign 32
  .zero 1024

.global msg_len
msg_len:
  .balign 4
  .zero 4

.global dgst_mode /* 0=SHA-3, 1=SHAKE */
dgst_mode:
  .balign 4
  .word 0x00000001

.global dgst_size /* Desired digest size/length for SHAKE */
dgst_size:
  .balign 4
  .word 0x00000080

.global shake_absorbs /* Number of times data is absorbed */
shake_absorbs:
  .balign 4
  .word 0x0000000A

.global shake_absorb_size /* Amount of bytes to be absorbed each time */
shake_absorb_size:
  .balign 4
  .word 0x00000014

.global shake_squeezes /* Number of times data is squeezed */
shake_squeezes:
  .balign 4
  .word 0x00000010

.global shake_squeeze_size /* Number of bytes to be squeezed each time */
shake_squeeze_size:
  .balign 4
  .word 0x00000020

.balign 32
.global context
context:
  .balign 32
  .zero 212

.global rc
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

  .zero 64
stack_end:
  .zero 1