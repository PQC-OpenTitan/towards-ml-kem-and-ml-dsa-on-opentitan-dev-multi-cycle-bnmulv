# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

s = "# regs:\n\
w0 = 0x002c08650058208a0024d3f5005d3b0f005e65b300166f57006b51fc0031c110\n\
w1 = 0x001925170058208a0032f882000fad9b0073969a000353ab00377155006e398a\n\
# dmem:\n\
0-32 = 002c08650058208a0024d3f5005d3b0f005e65b300166f57006b51fc0031c110"


print(s)
print(s.split("# dmem:")[1])
