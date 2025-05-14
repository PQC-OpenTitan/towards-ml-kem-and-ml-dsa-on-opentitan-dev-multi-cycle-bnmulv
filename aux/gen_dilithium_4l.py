# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

reg_start = 2
num_data_regs = 16
num_tw_regs = 2



for i in range(num_data_regs+num_tw_regs):
    print(f"li x{i+reg_start}, {i+reg_start}")

for i in range(num_data_regs):
    print(f"bn.lid x{reg_start+i}, {i*(512//8)}(x28) /* a[{(i)*(512//8)//4}-{(i)*(512//8)//4+4}] */")

for i in range(8):
    print(f"bn.mulmv.l.8S w30, w{reg_start+i+8}, w{reg_start+num_data_regs}, 0")
    print(f"bn.submv.8S w{reg_start+i+8}, w{reg_start+i}, w30")
    print(f"bn.addmv.8S w{reg_start+i}, w{reg_start+i}, w30")

offset = 0
for i in range(8):
    if i == 4:
        offset = 4
    a = reg_start + offset + i
    b = a + 4
    print(f"bn.mulmv.l.8S w30, w{b}, w{reg_start+num_data_regs}, {1+i//4}")
    print(f"bn.submv.8S w{b}, w{a}, w30")
    print(f"bn.addmv.8S w{a}, w{a}, w30")

print("/* Layer 3 */")
for idx, i in enumerate([0, 1, 4, 5, 8, 9, 12, 13]):
    a = reg_start + i
    b = a + 2
    print(f"bn.mulmv.l.8S w30, w{b}, w{reg_start+num_data_regs}, {3+(idx//2)}")
    print(f"bn.submv.8S w{b}, w{a}, w30")
    print(f"bn.addmv.8S w{a}, w{a}, w30")

print("/* Layer 4 */")
for i in range(8):
    a = reg_start + i * 2
    b = a + 1
    print(f"bn.mulmv.l.8S w30, w{b}, w{reg_start+num_data_regs + ((7+i) >= 8)}, {(7 + i) % 8}")
    print(f"bn.submv.8S w{b}, w{a}, w30")
    print(f"bn.addmv.8S w{a}, w{a}, w30")

for i in range(num_data_regs):
    print(f"bn.sid x{reg_start+i}, {i*(512//8)}(x28)")

print("\n-----\n-----\n-----")

reg_start = 2
num_data_regs = 16
num_tw_regs = 15

for i in range(num_data_regs):
    print(f"bn.lid x{reg_start+i}, {i*8*4}(x28)")

for i in range(num_data_regs):
    print(f"bn.sid x{reg_start+i}, {i*8*4}(x28)")

print("/* Layer 5 */")
for i in range(8):
    a = reg_start + i * 2
    b = a + 1
    print(f"bn.mulmv.l.8S w30, w{b}, w{reg_start + num_data_regs}, {i}")
    print(f"bn.submv.8S   w{b}, w{a}, w30")
    print(f"bn.addmv.8S   w{a}, w{a}, w30")

print("/* Layer 6 */")
for i in range(8):
    a = reg_start + i + 4*(i>3)
    b = a + 4
    print(f"bn.mulmv.8S w30, w{b}, w{reg_start + num_data_regs + i//4}")
    print(f"bn.submv.8S w{b}, w{a}, w30")
    print(f"bn.addmv.8S w{a}, w{a}, w30")

print("/* Layer 7 */")
for idx, i in enumerate([0, 1, 4, 5, 8, 9, 12, 13]):
    a = reg_start + i
    b = a + 2
    print(f"bn.mulmv.8S w30, w{b}, w{reg_start + num_data_regs + idx//2}")
    print(f"bn.submv.8S w{b}, w{a}, w30")
    print(f"bn.addmv.8S w{a}, w{a}, w30")

print("/* Layer 8 */")
for i in range(8):
    a = reg_start + i * 2
    b = a + 1
    print(f"bn.mulmv.8S w30, w{b}, w{reg_start+num_data_regs + i}")
    print(f"bn.submv.8S w{b}, w{a}, w30")
    print(f"bn.addmv.8S w{a}, w{a}, w30")