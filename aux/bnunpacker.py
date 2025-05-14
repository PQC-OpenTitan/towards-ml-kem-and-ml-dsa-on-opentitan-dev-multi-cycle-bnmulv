# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

N = 256
REG_SIZE = 256
BITS_PER_COEFF = 18

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

    def move(self, src):
        assert src.bits >= bits_per_call
        print(f"bn.mov  {self.name}, {src.name}")
        self.bits = src.bits
        src.bits -= bits_per_call

    def compute(self):
        print("jal     x1, _inner_poly_uniform_gamma1_dilithium\n")
        if self.bits < bits_per_call:
            print("Not enough bits")
            exit(-1)
        self.bits -= bits_per_call
        self.computes += 1

    def refill(self, src):
        missing = REG_SIZE - self.bits
        if src.bits < missing:
            print("Not enough bits in source")
            exit(-1)
        src.bits -= missing
        self.bits += missing

    def overwrite(self, top, bot):
        assert top.bits + bot.bits >= REG_SIZE
        assert bot.bits < REG_SIZE
        print(f"bn.rshi {self.name}, {top.name}, {bot.name} >> {REG_SIZE - bot.bits}")
        top.bits = top.bits - (bits_per_call - bot.bits) # not REG_SIZE, keep slack
        assert top.bits >= 0
        bot.bits = max(bot.bits - bits_per_call, 0)
        self.bits = REG_SIZE


bn0 = Register("bn0")
bn0.bits = 10**6
w1 = Register("w1")
w3 = Register("w3")
w6 = Register("w6")

w6.load()
w1.move(w6) # mov
w1.compute() # 48 rest in w1

next_load_to = w3

while w1.computes < (N * BITS_PER_COEFF) // bits_per_call:
    # print(w3)
    # print(w6)
    if next_load_to == w3:
        if w6.bits < bits_per_call:
            w3.load()
            w1.overwrite(w3, w6)
            w1.compute()
            next_load_to = w6
        else:
            w1.overwrite(bn0, w6)
            w1.compute()
            continue

    # print(w3)
    # print(w6)
    if next_load_to == w6:
        if w3.bits < bits_per_call:
            w6.load()
            w1.overwrite(w6, w3)
            w1.compute()
            next_load_to = w3
        else:
            w1.overwrite(bn0, w3)
            w1.compute()
            continue
