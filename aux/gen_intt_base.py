# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

to_be_mult = [[1,3,5,7,9,11,13,15], [2,3,6,7,10,11,14,15], [4,5,6,7,12,13,14,15],
              [8,9,10,11,12,13,14,15]]

bf_offsets = [1,2,4,8]
tf_per_reg = 4
tf_used = 0
tf_idx = 0
tf_reg = 1
for c in range(4):
    idxs = to_be_mult[c]
    offset = bf_offsets[c]
    # Butterflies
    print(f"            /* Layer {c} */")
    for pos, i in enumerate(idxs):
        print(f'''            bn.subm wtmp, coeff{i - offset}, coeff{i}
            bn.addm coeff{i - offset}, coeff{i - offset}, coeff{i}
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z wtmp, wtmp.0, tf{tf_reg}.{tf_idx}, 192 /* a*bq' */
            bn.add wtmp, wtmp3, wtmp >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z wtmp, wtmp.1, wtmp3.3, 0 /* *q */
            bn.rshi coeff{i}, wtmp3, wtmp >> 32 /* >> l */
              ''')
        # print(f'''
        #     bn.subm wtmp, coeff{i - offset}, coeff{i}
        #     bn.addm coeff{i - offset}, coeff{i - offset}, coeff{i}
        #     /* Barrett */
        #     bn.mulqacc.wo.z coeff{i}, wtmp.0, tf{tf_reg}.{tf_idx}, 0 /* (coeff{i - offset} - coeff{i}) * twiddle */
        #     bn.mulqacc.wo.z wtmp, coeff{i}.0, wtmp3.1, 0 /* * barrett const */
        #     bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        #     bn.sub          coeff{i}, coeff{i}, wtmp''')
        tf_used += 1
        if tf_used == offset:
            tf_used = 0
            if tf_idx == 3:
                tf_reg += 0
            tf_idx = (tf_idx + 1) % 4
        
