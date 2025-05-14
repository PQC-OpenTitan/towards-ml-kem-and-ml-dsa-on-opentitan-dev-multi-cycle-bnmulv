# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

'''
Script for helping to calculate bit offsets for packing in Dilithium
'''
import math

OUTPUT_POINTER = "a0"
INPUT_POINTER = "a1"
INSTRUCTION_COUNT = 0

def lcm(a, b):
    return abs(a*b) // math.gcd(a, b)

def iprint(s):
    print(s)
    global INSTRUCTION_COUNT
    INSTRUCTION_COUNT += 1

def pack_data(el_size: int, el_real_size: int, el_num: int, gpr_width: int):
    global INSTRUCTION_COUNT
    INSTRUCTION_COUNT = 0
    size_per_iter = lcm(el_real_size, gpr_width)
    gprs_per_iter = size_per_iter // gpr_width
    el_per_iter = size_per_iter // el_real_size

    assert el_num % el_per_iter == 0
    el_done = 0
    bits_remaining = 0
    input_offset = 0
    output_offset = 0
    while el_done < el_per_iter:
        bits_set = bits_remaining
        print("/* " + "*" * bits_set + "o" * (gpr_width - bits_set) + " */")
        bits_remaining = 0
        while bits_set < gpr_width:
            print(f"/* coefficient {el_done} */")
            iprint(f"lw t0, {input_offset}(a1)")
            if bits_set != 0:
                iprint(f"slli t1, t0, {bits_set}")
                iprint(f"or a2, a2, t1 /* {bits_set} */")
            else:
                iprint(f"or a2, a2, t0 /* {bits_set} */")
            el_done += 1
            input_offset += gpr_width // 8
            if (bits_set + el_real_size) <= gpr_width:
                bits_set += el_real_size
            else:
                bits_remaining = (bits_set + el_real_size) - gpr_width
                bits_set += el_real_size - bits_remaining

            print("/* " + "*" * bits_set + "o" * (gpr_width - bits_set) + "|" + "x" * bits_remaining + " */")
        iprint(f"sw a2, {output_offset}(a0)")
        output_offset += gpr_width // 8
        if el_done < el_per_iter:
            iprint(f"srli t0, t0, {(el_real_size - bits_remaining)}")
            iprint("or a2, zero, t0")


def unpack_data(el_size: int, el_real_size: int, el_num: int, gpr_width: int):
    bytes_processed = 0
    input_offset = 0
    output_offset = 0
    bits_processed = 0
    iprint(f"lw t0, {input_offset}(a1)")
    input_offset += 4
    bytes_processed += 4
    mask = 2**(el_real_size) - 1
    tmp_regs = [f't{i}' for i in range(3, 7)]
    tmp_reg_map = {}
    if mask > 0x7ff:
        if mask not in tmp_reg_map:
            reg = tmp_regs.pop(0)
            tmp_reg_map[mask] = reg
            mask = reg
        else:
            mask = tmp_reg_map[mask]
    # if mask == 0xfff:
    #     mask = "t5"
    # elif mask == 0xffff:
    #     mask = "t4"
    # elif mask == 0x3ffff:
    #     mask = "t3"
    # elif mask == 0x3fff:
    #     mask = "t6"
    while bytes_processed < (el_real_size * el_num) // 8:
        while (bits_processed + el_real_size) < gpr_width:
            iprint(f"and{'i' if type(mask) is int else ''} t1, t0, {mask}")
            bits_processed += el_real_size
            iprint(f"sw t1, {output_offset}(a0) /* coeff {output_offset // 4} */")
            output_offset += 4
            iprint(f"srli t0, t0, {el_real_size}")
        print(f"/* Bits rest: {gpr_width- bits_processed} */")
        if (gpr_width - bits_processed) != el_real_size:
            iprint(f"lw t2, {input_offset}(a1)")
            bytes_processed += 4
            input_offset += 4
            tmp_mask = 2**(el_real_size - (gpr_width - bits_processed)) - 1
            if tmp_mask > 0x7ff:
                if tmp_mask not in tmp_reg_map:
                    reg = tmp_regs.pop(0)
                    tmp_reg_map[tmp_mask] = reg
                    tmp_mask = reg
                else:
                    tmp_mask = tmp_reg_map[tmp_mask]
            # map special constants: TODO: generalize this
            # if tmp_mask == 0xfff:
            #     tmp_mask = "t5"
            # elif tmp_mask == 0xffff:
            #     tmp_mask = "t4"
            # elif tmp_mask == 0x3ffff:
            #     tmp_mask = "t3"
            # elif tmp_mask == 0x3fff:
            #     tmp_mask = "t6"
            iprint(f"and{'i' if type(tmp_mask) is int else ''} t1, t2, {tmp_mask}")
            iprint(f"slli t1, t1, {gpr_width - bits_processed}")
            iprint(f"or t1, t1, t0")
            iprint(f"sw t1, {output_offset}(a0)")
            output_offset += 4
            iprint(f"srli t0, t2, {el_real_size - (gpr_width - bits_processed)}")
            bits_processed = el_real_size - (gpr_width - bits_processed)
            print(f"/* Bytes processed: {bytes_processed} */\n")
        else:
            iprint(f"and{'i' if type(mask) is int else ''} t1, t0, {(mask)}")
            bits_processed += el_real_size
            iprint(f"sw t1, {output_offset}(a0) /* coeff {output_offset // 4} */")
            output_offset += 4
            print(f"/* Bytes processed: {bytes_processed} */\n")
            break
    print(tmp_reg_map)
    


# pack_data(32, 3, 256, 32)
# pack_data(32, 10, 256, 32)
# pack_data(32, 13, 256, 32)
# unpack_data(32, 10, 256, 32)
# unpack_data(32, 18, 256, 32)
# pack_data(32, 6, 256, 32)  # w1
# unpack_data(32, 3, 256, 32)  # eta
# unpack_data(32, 18, 256, 32)  # z
pack_data(32, 18, 256, 32)  # z

print(INSTRUCTION_COUNT)
