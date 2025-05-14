# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0


load("//rules:otbn.bzl", "otbn_consttime_test", "otbn_sim_test")

package(default_visibility = ["//visibility:public"])

otbn_sim_test(
    name = "addmv_test",
    srcs = [
        "addmv_test.s",
    ],
    exp = "addmv_test.exp",
    deps = [
        "//sw/otbn/vector:addmv",
    ],
)

otbn_sim_test(
    name = "submv_test",
    srcs = [
        "submv_test.s",
    ],
    exp = "submv_test.exp",
    deps = [
        "//sw/otbn/vector:submv",
    ],
)

otbn_sim_test(
    name = "mulmv_test",
    srcs = [
        "mulmv_test.s",
    ],
    exp = "mulmv_test.exp",
    deps = [
        "//sw/otbn/vector:mulmv",
    ],
)

otbn_sim_test(
    name = "mulv_test",
    srcs = [
        "mulv_test.s",
    ],
    exp = "mulv_test.exp",
    deps = [
        "//sw/otbn/vector:mulv",
    ],
)

otbn_sim_test(
    name = "trans8_test",
    srcs = [
        "trans8_test.s",
    ],
    exp = "trans8_test.exp",
    deps = [
        "//sw/otbn/vector:trans8",
    ],
)

otbn_sim_test(
    name = "andv_test",
    srcs = [
        "andv_test.s",
    ],
    exp = "andv_test.exp",
    deps = [
        "//sw/otbn/vector:andv",
    ],
)