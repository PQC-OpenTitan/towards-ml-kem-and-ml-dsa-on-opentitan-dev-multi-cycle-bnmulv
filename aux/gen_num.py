# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

from random import randrange, seed

COUNT = 256
LEN = 4
DILITHIUM_Q = 8380417
MAX_VAL = 2 ** 32 - 1


def to_2s_complement(value: int) -> int:
    '''Interpret the signed value as a 2's complement u32'''
    assert -(1 << 31) <= value < (1 << 31)
    return (1 << 32) + value if value < 0 else value


seed(10)

x = []
y = []
exp = ""
exp_words = []
ctr = 0
while ctr < COUNT:
    # xi = randrange(DILITHIUM_Q // 4, DILITHIUM_Q // 2)
    # yi = randrange(DILITHIUM_Q // 4, DILITHIUM_Q // 2)
    xi = randrange(0, (1 << 31) - (1 << 22) - 1)
    yi = randrange(0, (1 << 32))

    # if xi % 2 == 0:
    #     xi *= -1
    # if yi % 2 != 0:
    #     yi *= -1
    
    result = (xi + (1 << 22)) >> 23  # TODO: match op
    result = xi - result * DILITHIUM_Q
    print(f"{xi} -> {result}")
    x.append(xi)
    y.append(yi)

    # if result >= DILITHIUM_Q:
    #     result -= DILITHIUM_Q
    # elif result < 0:
    #     result += DILITHIUM_Q

    result = to_2s_complement(result)
    exp = format(result, '08x') + exp  # prepend
    exp_words.append(format(result, '08x'))

    ctr += 1

x_str = "x:\n"
y_str = "y:\n"
for i in range(COUNT):
    x_str += f"  .word 0x{format(to_2s_complement(x[i]), '08x')}\n"
    # y_str += f"  .word 0x{format(to_2s_complement(y[i]), '08x')}\n"

print(x_str)
print(y_str)

exp_start_byte = 0
print("output:")
for e in exp_words:
    print(f"  {exp_start_byte}-{exp_start_byte+3} = 0x{e}")
    exp_start_byte += 4

print("0x" + exp)

x_mat = [[0] * 8 for i in range(8)]

for i in range(8):
    for j in range(8):
        print(x[i * 8 + j])
        x_mat[i][j] = x[i * 8 + j]

for row in x_mat:
    print(row)

x_mat_t = [[0] * 8 for i in range(8)]

for i in range(8):
    for j in range(8):
        x_mat_t[j][i] = x_mat[i][j]

print("-")
for row in x_mat_t:
    print(row)

x_t = []

for i in range(8):
    for j in range(8):
        x_t.append(x_mat_t[i][j])

x_t_str = ""

print(COUNT)
for i in range(0, COUNT, 8):
    x_t_str += f"w{(i // 8) + 23} = 0x{''.join([format(x_t[i + j], '08x') for j in range(7, -1, -1)])}\n"

print(x_t_str)
