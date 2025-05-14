# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

reg_start = 2
num_data_regs = 16
num_tw_regs = 8

print("/* Layer 8 */")
for i in range(8):
    a = reg_start + i * 2
    b = a + 1
    print(f"bn.submv.8S w30, w{a}, w{b}")
    print(f"bn.addmv.8S w{a}, w{a}, w{b}")
    print(f"bn.mulmv.8S w{b}, w30, w{reg_start+num_data_regs + i}")

print("/* Layer 7 */")
for idx, i in enumerate([0, 1, 4, 5, 8, 9, 12, 13]):
    a = reg_start + i
    b = a + 2
    print(f"bn.submv.8S w30, w{a}, w{b}")
    print(f"bn.addmv.8S w{a}, w{a}, w{b}")
    print(f"bn.mulmv.8S w{b}, w30, w{reg_start + num_data_regs + idx//2}")

print("/* Layer 6 */")
for i in range(8):
    a = reg_start + i + 4*(i>3)
    b = a + 4
    print(f"bn.submv.8S w30, w{a}, w{b}")
    print(f"bn.addmv.8S w{a}, w{a}, w{b}")
    print(f"bn.mulmv.8S w{b}, w30, w{reg_start + num_data_regs + i//4}")

print("/* Layer 5 */")
for i in range(8):
    a = reg_start + i * 2
    b = a + 1
    print(f"bn.submv.8S   w30, w{a}, w{b}")
    print(f"bn.addmv.8S   w{a}, w{a}, w{b}")
    print(f"bn.mulmv.l.8S w{b}, w30, w{reg_start + num_data_regs}, {i}")

print("/* Layer 4 */")
for i in range(8):
    a = reg_start + i * 2
    b = a + 1
    print(f"bn.submv.8S   w30, w{a}, w{b}")
    print(f"bn.addmv.8S   w{a}, w{a}, w{b}")
    print(f"bn.mulmv.l.8S w{b}, w30, w{reg_start+num_data_regs}, {i}")

print("/* Layer 3 */")
for idx, i in enumerate([0, 1, 4, 5, 8, 9, 12, 13]):
    a = reg_start + i
    b = a + 2
    print(f"bn.submv.8S   w30, w{a}, w{b}")
    print(f"bn.addmv.8S   w{a}, w{a}, w{b}")
    print(f"bn.mulmv.l.8S w{b}, w30, w{reg_start+num_data_regs+1}, {(idx//2)}")

print("/* Layer 2 */")
offset = 0
for i in range(8):
    if i == 4:
        offset = 4
    a = reg_start + offset + i
    b = a + 4
    print(f"bn.submv.8S   w30, w{a}, w{b}")
    print(f"bn.addmv.8S   w{a}, w{a}, w{b}")
    print(f"bn.mulmv.l.8S w{b}, w30, w{reg_start+num_data_regs+1}, {4+i//4}")

print("/* Layer 1 */")
for i in range(8):
    a = reg_start + i
    b = a + 8
    print(f"bn.submv.8S   w30, w{a}, w{b}")
    print(f"bn.addmv.8S   w{a}, w{a}, w{b}")
    print(f"bn.mulmv.l.8S w{b}, w30, w{reg_start+num_data_regs+1}, 6")

# mul ninv
print("/* Multiply n^{-1} */")
for i in range(8):
    a = reg_start + i
    print(f"bn.mulmv.l.8S w{a}, w{a}, w{reg_start+num_data_regs+1}, 7")

tw = [
# Layers 1-4   ,
[0x00495e02, 0x00397567, 0x00396569, 0x004f062b, 0x0053df73, 0x004fe033, 0x004f066b, 0x0076b1ae, 0x00360dd5, 0x0028edb0, 0x00207fe4, 0x00397283, 0x0070894a, 0x00088192, 0x006d3dc8, 0x00000000],
# Layer 5 - 1  ,
[0x004c7294, 0x0041e0b4, 0x0028a3d2, 0x0066528a, 0x004a18a7, 0x00794034, 0x000a52ee, 0x006b7d81],
# Layer 6 - 1  ,
[0x0036f72a, 0x0030911e, 0x0029d13f, 0x00492673, 0x0050685f, 0x002010a2, 0x003887f7, 0x0011b2c3, 0x000603a4, 0x000e2bed, 0x0010b72c, 0x004a5f35, 0x001f9d15, 0x00428cd4, 0x003177f4, 0x0020e612],
# Layer 7 - 1  ,
[0x002ee3f1, 0x0057a930, 0x003fd54c, 0x00503ee1, 0x002648b4, 0x001d90a2, 0x002ae59b, 0x006ef1f5, 0x00137eb9, 0x003ac6ef, 0x004eb2ea, 0x007bb175, 0x001ef256, 0x0045a6d4, 0x0052589c, 0x003f7288, 0x00175102, 0x001187ba, 0x00773e9e, 0x002592ec, 0x00404ce8, 0x001e54e6, 0x001a7e79, 0x004e4817, 0x00075d59, 0x0052aca9, 0x000296d8, 0x004cff12, 0x004aa582, 0x004f16c1, 0x0003978f, 0x0031b859],
# Layer 8 - 1  ,
[0x000006d9, 0x00289838, 0x00120a23, 0x00437ff8, 0x007f735d, 0x0061ab98, 0x00662960, 0x0049b0e3, 0x006257c5, 0x0064b5fe, 0x000154a8, 0x005cd5b4, 0x000c8d0d, 0x00185d96, 0x004bd579, 0x0009b434, 0x00574b3c, 0x007ef8f5, 0x0009b7ff, 0x004dc04e, 0x000f66d5, 0x00437f31, 0x0028de06, 0x007c0db3, 0x0069a8ef, 0x002a4e78, 0x00435e87, 0x004728af, 0x005a6d80, 0x00468298, 0x00465d8d, 0x005a68b0, 0x00409ba9, 0x00246e39, 0x00392db2, 0x0030c31c, 0x002dbfcb, 0x006b3375, 0x0078e00d, 0x001f1d68, 0x0064d3d5, 0x0048c39b, 0x00230923, 0x00285424, 0x00022a0b, 0x00095b76, 0x00628c37, 0x006330bb, 0x0021762a, 0x007bc759, 0x0012eb67, 0x0013232e, 0x007e832c, 0x006be1cc, 0x003da604, 0x007361b8, 0x00658591, 0x004f5859, 0x00454df2, 0x007faf80, 0x0026587a, 0x005e061e, 0x004ae53c, 0x005ea06c],
# Layer 5 - 2  ,
[0x004e9f1d, 0x001a2877, 0x002571df, 0x001649ee, 0x007611bd, 0x00492bb7, 0x002af697, 0x0022d8d5],
# Layer 6 - 2  ,
[0x00341c1d, 0x001ad873, 0x00736681, 0x0049553f, 0x003952f6, 0x0062564a, 0x0065ad05, 0x00439a1c, 0x0053aa5f, 0x0030b622, 0x00087f38, 0x003b0e6d, 0x002c83da, 0x001c496e, 0x00330e2b, 0x001c5b70],
# Layer 7 - 2  ,
[0x005884cc, 0x005b63d0, 0x0035225e, 0x006c09d1, 0x006bc4d3, 0x002e534c, 0x003b8820, 0x002ca4f8, 0x001b4827, 0x005d787a, 0x00400c7e, 0x005bd532, 0x00258ecb, 0x00097a6c, 0x006d285c, 0x00337caa, 0x0014b2a0, 0x0028f186, 0x004af670, 0x0075e826, 0x0005528c, 0x000f6e17, 0x00459b7e, 0x005dbecb, 0x00558536, 0x0055795d, 0x00234a86, 0x0078de66, 0x007adf59, 0x005bf3da, 0x00628b34, 0x001a9e7b],
# Layer 8 - 2  ,
[0x00671ac7, 0x0008f201, 0x00695688, 0x0007c017, 0x00519573, 0x0058018c, 0x003cbd37, 0x00196926, 0x00201fc6, 0x006de024, 0x001e6d3e, 0x006dbfd4, 0x007ab60d, 0x003f4cf5, 0x00273333, 0x001ef206, 0x005ba4ff, 0x00080e6d, 0x002603bd, 0x0074d0bd, 0x002867ba, 0x000b7009, 0x00673957, 0x0011c14e, 0x0060d772, 0x0056038e, 0x006a9dfa, 0x0063e1e3, 0x002decd4, 0x00427e23, 0x001a4b5d, 0x004c76c8, 0x003cf42f, 0x003352d6, 0x002f6316, 0x000d1ff0, 0x005e8885, 0x0051e0ed, 0x007b4064, 0x001cfe14, 0x007fb19a, 0x00034760, 0x006f0a11, 0x00345824, 0x002faa32, 0x0065adb3, 0x0035e1dd, 0x0073f1ce, 0x006af66c, 0x00085260, 0x0007c0f1, 0x000223d4, 0x0023fc65, 0x002ca5e6, 0x00433aac, 0x0010170e, 0x002e1669, 0x00741e78, 0x00776d0b, 0x0068c559, 0x005e6942, 0x0079e1fe, 0x00464ade, 0x0074b6d7],
]

for l in tw:
    print(l)

tw_new = []
for l in tw:
    l_new = []
    for i in range(0, len(l), 8):
        l_new = (l[i:i+8])[::-1] + l_new
    tw_new.append(l_new)

print("---")

for l in tw_new:
    print(l)

q = 8380417
for l in range(len(tw_new)):
    for t in range(len(tw_new[l])):
        tw_new[l][t] = (-tw_new[l][t]) % q

print("---")

for l in tw_new[::-1]:
    print("/* Layer X - Y */\n" + "\n.word 0x".join(format(i, '08x') for i in l))