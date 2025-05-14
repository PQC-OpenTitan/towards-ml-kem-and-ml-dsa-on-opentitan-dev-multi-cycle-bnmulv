# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import os
from multiprocessing import Pool
import sqlite3
import time
import hashlib
from otbn_interface import keccak_otbn

NPROC = 1
ITERATIONS = 1

# DATABASE_PATH = "/home/ubuntu/dilithium_benchmarks/dilithium_bench.db"


def bench_digest():
    s = hashlib.shake_128()
    rand = b'\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3\xa3'
    # rand = os.urandom(32)
    # reference computation
    s.update(rand)
    digest = s.digest(512)
    shake_squeezes = 16
    shake_squeeze_size = 32
    digest_otbn, stat_data = keccak_otbn(rand, True, 128, 10, 20, shake_squeezes, shake_squeeze_size)

    if digest != digest_otbn[:shake_squeezes * shake_squeeze_size]:
        print("Error: digests do not match!!!")
        print(rand)
        print(digest)
        print(digest_otbn)
        return -1
    print("Iteration done")
    return stat_data


def run_bench():
    if __name__ == "sw.otbn.crypto.tests.keccak_bench_otbn.bench_keccak":
        print(f"Benchmark Keccak")
        result = bench_digest()

        if result == -1:
            print("Error in Computation")
            exit(-1)
