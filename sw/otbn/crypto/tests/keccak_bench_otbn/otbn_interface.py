# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import struct
from typing import List, Tuple
from hw.ip.otbn.util.otbn_sim_py import run_sim


def keccak_otbn(message: bytes, dgst_mode: bool, dgst_size: int,
                shake_absorbs: int, shake_absorb_size: int,
                shake_squeezes: int, shake_squeeze_size: int) -> int:
    # skip the first 8 bytes (=model, op_state)
    # account for alignment of message
    message_addr = 0
    digest_addr = 1028
    msg_len_addr = digest_addr + 4
    dgst_mode_addr = msg_len_addr + 4
    dgst_size_addr = dgst_mode_addr + 4
    shake_absorbs_addr = dgst_size_addr + 4
    shake_absorb_size_addr = shake_absorbs_addr + 4
    shake_squeezes_addr = shake_absorb_size_addr + 4
    shake_squeeze_size_addr = shake_squeezes_addr + 4
    from math import ceil
    message_bytes            = message
    dgst_mode_bytes          = int(dgst_mode).to_bytes(4, "little")
    shake_absorbs_bytes      = int(shake_absorbs).to_bytes(4, "little")
    dgst_size_bytes          = int(dgst_size).to_bytes(4, "little")
    shake_absorb_size_bytes  = int(shake_absorb_size).to_bytes(4, "little")
    shake_squeezes_bytes     = int(shake_squeezes).to_bytes(4, "little")
    shake_squeeze_size_bytes = int(shake_squeeze_size).to_bytes(4, "little")

    regs, raw_dmem, stat_data = run_sim(
        f"symmetric_test",
        [(message_addr, message_bytes),
            (dgst_mode_addr, dgst_mode_bytes),
            (shake_absorbs_addr, shake_absorbs_bytes),
            (dgst_size_addr, dgst_size_bytes),
            (shake_absorb_size_addr, shake_absorb_size_bytes),
            (shake_squeezes_addr, shake_squeezes_bytes),
            (shake_squeeze_size_addr, shake_squeeze_size_bytes)])

    digest = raw_dmem[digest_addr:digest_addr+1024]

    print(regs)

    # digest
    return digest, stat_data
