# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
package(default_visibility = ["//visibility:public"])

# Headers libraries
cc_library(
    name = "params",
    hdrs = ["params.h"],
)

cc_library(
    name = "poly_h",
    hdrs = ["poly.h"],
    deps = [
        ":params",
    ],
)

# C libraries
cc_library(
    name = "cbd",
    srcs = ["cbd.c"],
    copts = [
        "-Wno-error",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["cbd.h"],
    deps = [
        ":params",
        ":poly_h",
    ],
)

cc_library(
    name = "fips202",
    srcs = ["fips202.c"],
    copts = [
        "-Wno-error",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["fips202.h"],
)

cc_library(
    name = "indcpa",
    srcs = ["indcpa.c"],
    copts = [
        "-Wno-error",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["indcpa.h"],
    deps = [
        ":params",
        ":polyvec",
        ":poly",
        ":ntt",
        ":symmetric",
        ":randombytes",
    ],
)

cc_library(
    name = "kem",
    srcs = ["kem.c"],
    copts = [
        "-Wno-error",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["kem.h"],
    deps = [
        ":params",
        ":indcpa",
        ":verify",
        ":symmetric",
        ":randombytes",
    ],
)

cc_library(
    name = "ntt",
    srcs = ["ntt.c"],
    copts = [
        "-Wno-error",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["ntt.h"],
    deps = [
        ":params",
        ":reduce",
    ],
)

cc_library(
    name = "poly",
    srcs = ["poly.c"],
    copts = [
        "-Wno-error",
        "-Wno-sign-conversion",
        "-Wno-implicit-int-conversion",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["poly.h"],
    deps = [
        ":ntt",
        ":reduce",
        ":cbd",
        ":symmetric",
        ":verify",
    ],
)

cc_library(
    name = "polyvec",
    srcs = ["polyvec.c"],
    copts = [
        "-Wno-error",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["polyvec.h"],
    deps = [
        ":poly",
    ],
)

cc_library(
    name = "randombytes",
    srcs = ["randombytes.c"],
    copts = [
        "-Wno-error",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["randombytes.h"],
)

cc_library(
    name = "reduce",
    srcs = ["reduce.c"],
    copts = [
        "-Wno-error",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["reduce.h"],
    deps = [
        ":params",
    ],
)

cc_library(
    name = "symmetric",
    srcs = ["symmetric-shake.c"],
    copts = [
        "-Wno-error",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["symmetric.h"],
    deps = [
        ":params",
        ":fips202",
    ],
)

cc_library(
    name = "verify",
    srcs = ["verify.c"],
    copts = [
        "-Wno-error",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wmissing-prototypes",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wpointer-arith",
        "-O3",
        "-fomit-frame-pointer",
    ],
    hdrs = ["verify.h"],
    deps = [
        ":params"
    ],
)
