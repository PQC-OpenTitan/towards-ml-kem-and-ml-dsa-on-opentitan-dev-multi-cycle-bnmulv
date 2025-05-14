# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

def lcm(x, y):
    from math import gcd # or can import gcd from `math` in Python 3
    return x * y // gcd(x, y)


COEFF_SIZE = 18
N = 256
WDR_SIZE = 256

k = 1
max_k = -1
while k * COEFF_SIZE < 256:
    if lcm(WDR_SIZE, k * COEFF_SIZE) <= N * COEFF_SIZE:
        max_k = k
    k += 1

print(max_k)
