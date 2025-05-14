# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

N = 256
REG_SIZE = 256
BITS_PER_COEFF = 3

def lcm(x, y):
    from math import gcd
    return x * y // gcd(x, y)

k = 1
max_k = -1
while k * BITS_PER_COEFF < 256:
    if lcm(REG_SIZE, k * BITS_PER_COEFF) <= N * BITS_PER_COEFF:
        max_k = k
    k += 1

bits_per_call = max_k * BITS_PER_COEFF
bits_per_call=240
print(bits_per_call)
class Register:
    def __init__(self, name: str):
        self.bits = 0
        self.name = name
        self.computes = 0

    def __str__(self):
        return f"{self.name}: {self.bits}"

    def load(self):
        print(f"bn.lid  t{self.name[-1]}, 0(a1++)")
        if self.bits != 0:
            print("Overwriting data")
            exit(-1)
        self.bits = 256

    def store(self):
        print(f"bn.sid  t{self.name[-1]}, 0(a0++)")
        if self.bits != 256:
            print("Not enough datat to store")
            exit(-1)
        self.bits = 0

    def move(self, src):
        # assert src.bits >= bits_per_call
        print(f"bn.mov  {self.name}, {src.name}")
        self.bits = src.bits
        src.bits = 0

    def compute(self):
        print("jal     x1, _inner_polyeta_pack_dilithium")
        # if self.bits < bits_per_call:
        #     print("Not enough bits")
        #     exit(-1)
        # self.bits -= bits_per_call
        self.bits += bits_per_call
        self.computes += 1

    def overwrite(self, top, bot, shift, shift_print=""):
        if shift_print == "":
            shift_print = str(shift)
        print(f"bn.rshi {self.name}, {top.name}, {bot.name} >> {shift_print}")
        top.bits -= shift
        # bot.bits = max(bot.bits - shift, 0)
        self.bits += shift


bn0 = Register("bn0")
bn0.bits = 10**6
acc = Register("w4")
working = Register("w2")


while working.computes < (N * BITS_PER_COEFF) // bits_per_call:
    working.compute()
    if working.bits + acc.bits < REG_SIZE:
        acc.overwrite(working, acc, working.bits)
    else:
        acc_missing = REG_SIZE - acc.bits
        acc.overwrite(working, acc, acc_missing)
        acc.store()
        acc.overwrite(working, bn0, working.bits, shift_print=str(bits_per_call))  # actually, for optimization reasons it would be best to have bits_per_call here as the shift
    # print(acc, working)
    print("\n")
