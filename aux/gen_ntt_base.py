# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

to_be_mult = [[8,9,10,11,12,13,14,15], [4,5,6,7,12,13,14,15],
              [2,3,6,7,10,11,14,15], [1,3,5,7,9,11,13,15]]

bf_offsets = [8,4,2,1]
tf_per_reg = 4
tf_used = 0
tf_idx = 0
tf_reg = 1
for c in range(4):
    idxs = to_be_mult[c]
    offset = bf_offsets[c]
    # Butterflies
    print(f"\n            /* Layer {c+1+4} */")
    for pos, i in enumerate(idxs):
        print(f'''
            /* Plantard multiplication: Twiddle * coeff */
            bn.mulqacc.wo.z coeff{i}, coeff{i}.0, tf1.{tf_idx}, 192 /* a*bq' */
            bn.add coeff{i}, wtmp3, coeff{i} >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z coeff{i}, coeff{i}.1, wtmp3.2, 0 /* *q */
            bn.rshi wtmp, wtmp3, coeff{i} >> 32 /* >> l */
            /* Butterfly */
            bn.subm coeff{i}, coeff{i-offset}, wtmp
            bn.addm coeff{i-offset}, coeff{i-offset}, wtmp''')
        # print(f'''
        #     /* Barrett */
        #     bn.mulqacc.wo.z coeff{i}, coeff{i}.0, tf{tf_reg}.{tf_idx}, 0 /* coeff{i} * twiddle */
        #     bn.mulqacc.wo.z wtmp, coeff{i}.0, wtmp3.1, 0 /* * barrett const */
        #     bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        #     bn.sub          wtmp, coeff{i}, wtmp
        #     /* Butterfly */
        #     bn.subm  coeff{i}, coeff{i-offset}, wtmp
        #     bn.addm  coeff{i-offset}, coeff{i-offset}, wtmp''')
        tf_used += 1
        if tf_used == offset:
            tf_used = 0
            tf_idx = (tf_idx + 1) % 4
            if tf_idx == 0:
                tf_reg += 0  # change to 0 here for second merge

'''
Note: for the second layer merge, just remove the increment of tf_reg. In the
second merge, we need to load twiddle factors during the main loop anyways, so
we can just reuse the register.
'''
