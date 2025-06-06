# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
# Modified by Authors of "Towards ML-KEM & ML-DSA on OpenTitan" (https://eprint.iacr.org/2024/1192).
# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors.


import sys
from math import floor
from typing import Dict, Iterator, Optional, Tuple

from shared.insn_yaml import Insn, DummyInsn, load_insns_yaml

from .state import OTBNState


# Load the insns.yml file at module load time: we'll use its data while
# declaring the classes. The point is that an OTBNInsn below is an instance of
# a particular Insn object from shared.insn_yaml, so we want a class variable
# on the OTBNInsn that points at the corresponding Insn.
try:
    INSNS_FILE = load_insns_yaml()
except RuntimeError as err:
    sys.stderr.write('{}\n'.format(err))
    sys.exit(1)


def insn_for_mnemonic(mnemonic: str, num_operands: int) -> Insn:
    '''Look up the named instruction in the loaded YAML data.

    To make sure nothing's gone really wrong, make sure it has the expected
    number of operands. If we fail to find the right instruction, print a
    message to stderr and exit (rather than raising a RuntimeError: this
    happens on module load time, so it's a lot clearer to the user what's going
    on this way).

    '''
    insn = INSNS_FILE.mnemonic_to_insn.get(mnemonic)
    if insn is None:
        sys.stderr.write('Failed to find an instruction for mnemonic {!r} in '
                         'insns.yml.\n'
                         .format(mnemonic))
        sys.exit(1)

    if len(insn.operands) != num_operands:
        sys.stderr.write('The instruction for mnemonic {!r} in insns.yml has '
                         '{} operands, but we expected {}.\n'
                         .format(mnemonic, len(insn.operands), num_operands))
        sys.exit(1)

    return insn


class OTBNInsn:
    '''A decoded OTBN instruction.

    '''

    # A class variable that holds the Insn subclass corresponding to this
    # instruction.
    insn = DummyInsn()  # type: Insn

    # A class variable that is set by Insn subclasses that represent
    # instructions that affect control flow (and are not allowed at the end of
    # a loop).
    affects_control = False

    # A class variable that is true if this instruction has valid bits. (Set to
    # false by the EmptyInsn subclass)
    has_bits = True

    # A class variable that is true if there will be a cycle of fetch stall
    # after the instruction executes.
    has_fetch_stall = False

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        self.raw = raw
        self.op_vals = op_vals

        # Memoized disassembly for this instruction. We store the PC at which
        # we disassembled too (which should be the same next time around, but
        # it can't hurt to check).
        self._disasm = None  # type: Optional[Tuple[int, str]]

    def execute(self, state: OTBNState) -> Optional[Iterator[None]]:
        '''Execute the instruction

        This may yield (returning an iterator object) if the instruction has
        stalled the processor and will take multiple cycles.

        '''
        raise NotImplementedError('OTBNInsn.execute')

    def disassemble(self, pc: int) -> str:
        '''Generate an assembly listing for this instruction'''
        if self._disasm is not None:
            old_pc, old_disasm = self._disasm
            assert pc == old_pc
            return old_disasm

        disasm = self.insn.disassemble(pc, self.op_vals)
        self._disasm = (pc, disasm)
        return disasm

    @staticmethod
    def to_2s_complement(value: int, size: int = 32) -> int:
        '''Interpret the signed value as a 2's complement u32'''
        # assert -(1 << (size - 1)) <= value < (1 << (size - 1))
        return (1 << size) + value if value < 0 else value

    @staticmethod
    def from_2s_complement(value: int, size: int = 32) -> int:
        '''Interpret the unsigned value as a 2's complement s32 or s16'''
        assert value < (1 << size)
        if size == 32:
            b = value.to_bytes(4, byteorder="little", signed=False)
        if size == 16:
            b = value.to_bytes(2, byteorder="little", signed=False)                                       
        return int.from_bytes(b, byteorder="little", signed=True)

    def rtl_trace(self, pc: int) -> str:
        '''Return the RTL trace entry for executing this insn'''
        if self.has_bits:
            return (f'E PC: {pc:#010x}, insn: {self.raw:#010x}\n'
                    f'# @{pc:#010x}: {self.insn.mnemonic}')
        else:
            return (f'E PC: {pc:#010x}, insn: ??\n'
                    f'# @{pc:#010x}: ??')


class RV32RegReg(OTBNInsn):
    '''A general class for register-register insns from the RV32I ISA'''
    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.grs1 = op_vals['grs1']
        self.grs2 = op_vals['grs2']


class RV32RegImm(OTBNInsn):
    '''A general class for register-immediate insns from the RV32I ISA'''
    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.grs1 = op_vals['grs1']
        self.imm = op_vals['imm']


class RV32ImmShift(OTBNInsn):
    '''A general class for immediate shift insns from the RV32I ISA'''
    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.grs1 = op_vals['grs1']
        self.shamt = op_vals['shamt']


def bit_shift(value: int, shift_type: int, shift_bits: int, size: int, arith: bool = False) -> int:
    '''Logical shift value by shift_bits to the left or right.

    value should be an unsigned size-bit value. shift_type should be 0 (shift
    left) or 1 (shift right), matching the encoding of the big number
    instructions. shift_bytes should be a non-negative number of bytes to shift
    by.

    Returns a 32-bit value, truncating on an overflowing left shift.

    '''
    mask = (1 << size) - 1
    # assert 0 <= value <= mask
    assert 0 <= shift_type <= 1
    assert 0 <= shift_bits

    if not arith:
        shifted = value << shift_bits if shift_type == 0 else value >> shift_bits
    else:
        # arithmetic shift
        if shift_type == 1:
            shifted = value >> shift_bits
            if ((value & (1 << (size - 1))) >> (size - 1)) == 1:
                # extend the most significant bits with the prior msb
                shifted |= (((2 ** shift_bits) - 1) << (size - shift_bits))
        else:
            shifted = value << shift_bits

    return shifted & mask


def logical_byte_shift(value: int, shift_type: int, shift_bytes: int) -> int:
    '''Logical shift value by shift_bytes to the left or right.

    value should be an unsigned 256-bit value. shift_type should be 0 (shift
    left) or 1 (shift right), matching the encoding of the big number
    instructions. shift_bytes should be a non-negative number of bytes to shift
    by.

    Returns an unsigned 256-bit value, truncating on an overflowing left shift.

    '''
    mask256 = (1 << 256) - 1
    assert 0 <= value <= mask256
    assert 0 <= shift_type <= 1
    assert 0 <= shift_bytes

    shift_bits = 8 * shift_bytes
    shifted = value << shift_bits if shift_type == 0 else value >> shift_bits
    return shifted & mask256


def extract_quarter_word(value: int, qwsel: int) -> int:
    '''Extract a 64-bit quarter word from a 256-bit value.'''
    assert 0 <= value < (1 << 256)
    assert 0 <= qwsel <= 3
    return (value >> (qwsel * 64)) & ((1 << 64) - 1)


def extract_sub_word(value: int, size: int, index: int) -> int:
    '''Extract a `size`-bit word at index `index` from a 256-bit value.'''
    assert 0 <= value < (1 << 256)
    assert 0 <= index <= 256 // size
    return (value >> (index * size)) & ((1 << size) - 1)
