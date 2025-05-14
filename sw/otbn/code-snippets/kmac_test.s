/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */
/* Modified by Authors of "Towards ML-KEM & ML-DSA on OpenTitan" (https://eprint.iacr.org/2024/1192) */
/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */


# KMAC test that tests the KMAC application interface between OTBN and KMAC

#define MAX_INPUT_LENGTH 32
#define MAX_OUTPUT_LENGTH 32

.section .text.start
.globl kmac_test

/* KMAC STATUS */
# Bit 0: Done
# Bit 1: Ready
# Bit 2: Error

/* KMAC CFG */
# Bit 0 - 1:  SHA3 Mode:
#  'b00: SHA3
#  'b10: Shake
#  'b11: CShake
# Bit 2 - 4:  Keccak Strength:
#  'b000: L128
#  'b001: L224
#  'b010: L256
#  'b011: L384
#  'b100: L512
# Bit 5 - 7:  Message Length Bytes 
# Bit 8 - 15: Message Length in 64-bit words

kmac_test:

#la x23, kmac_message_length
#lw x23, 0(x23)
#
#la x5, kmac_config
#lw x5, 0(x5)

li x23, 32
li x5, 8

slli x6, x23, 5
or x5, x5, x6

csrrw x0, 0x7d9, x5

# Calculate nr. of writes to KMAC MSG reg
srli x24, x23, 5
andi x25, x23, 0x1F
beq  x25, x0, skip_additional_kmac_msg_write
addi x24, x24, 1

skip_additional_kmac_msg_write:
slli x24, x24, 5

# Write to KMAC MSG reg
li x5, 0
li x6, 0
write_to_kmac_msg:
    bn.lid x6, 0(x5)
    bn.wsrw 0x9, w0
    addi x5, x5, 32
    bne x5, x24, write_to_kmac_msg

# Read KMAC DIGEST regs
li x5, 2
la x6, kmac_output
bn.wsrr w2, 0xA
bn.sid  x5, 0(x6)

# Release
li x5, 1
slli x5, x5, 31
csrrw x0, 0x7d9, x5

ecall

.data
.balign 32

#.globl kmac_config
#kmac_config:
#    .zero 4
#
#.globl kmac_message_length
#kmac_message_length:
#    .zero 4
#
#.globl kmac_digest_length
#kmac_digest_length:
#    .zero 4

.balign 32
.globl kmac_input
kmac_input:
    .zero MAX_INPUT_LENGTH

.balign 32
.globl kmac_output
kmac_output:
    .zero MAX_OUTPUT_LENGTH
