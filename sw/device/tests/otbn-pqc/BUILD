// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


load("//rules:opentitan.bzl", "OPENTITAN_CPU")
load(
    "//rules:opentitan_test.bzl",
    "ROM_BOOT_FAILURE_MSG",
    "cw310_params",
    "dv_params",
    "opentitan_functest",
    "verilator_params",
)

opentitan_functest(
    name = "otbn-pqc-tests",
    srcs = ["otbn-pqc-tests.c"],
    verilator = verilator_params(
        timeout = "eternal",
    ),
    deps = [
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/dif:otbn",
        "//sw/device/lib/runtime:ibex",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing:entropy_testutils",
        "//sw/device/lib/testing:otbn_testutils",
        "//sw/device/lib/testing/test_framework:ottf_main",
        "//sw/otbn/crypto/tests:ntt_base_dilithium_test",
    ]
)
