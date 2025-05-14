# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

upper = [0, 1, 2, 3, 4, 5, 6, 7]
lower = [64, 65, 66, 67, 68, 69, 70, 71]

upper_rows = []
for i in range(0, len(upper), 2):
    upper_rows.append(([upper[i] + j*8 for j in range(8)], [upper[i+1] + j*8 for j in range(8)]))

for r in upper_rows:
    print(r[0])
    print(r[1])
    print("-------------------------")

lower_rows = []
for i in range(0, len(lower), 2):
    lower_rows.append(([lower[i] + j*8 for j in range(8)], [lower[i+1] + j*8 for j in range(8)]))

for r in lower_rows:
    print(r[0])
    print(r[1])
    print("-------------------------")

print("--------------------------------------------------")
print("--------------------------------------------------")

upper = [i + 128 for i in upper]
lower = [i + 128 for i in lower]

upper_rows = []
for i in range(0, len(upper), 2):
    upper_rows.append(([upper[i] + j*8 for j in range(8)], [upper[i+1] + j*8 for j in range(8)]))

for r in upper_rows:
    print(r[0])
    print(r[1])
    print("-------------------------")

lower_rows = []
for i in range(0, len(lower), 2):
    lower_rows.append(([lower[i] + j*8 for j in range(8)], [lower[i+1] + j*8 for j in range(8)]))

for r in lower_rows:
    print(r[0])
    print(r[1])
    print("-------------------------")