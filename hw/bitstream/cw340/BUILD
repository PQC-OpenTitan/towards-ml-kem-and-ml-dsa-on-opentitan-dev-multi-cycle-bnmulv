# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:splice.bzl", "bitstream_splice")
load("//rules:otp.bzl", "get_otp_images")

# We do not have a signed CW340 ROM yet.
KEY_AUTHENTICITY = [
    "fake",
]

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "bitstream",
    testonly = True,
    srcs = select({
        "//hw/bitstream:bitstream_skip": ["lowrisc_systems_chip_earlgrey_cw340_0.1.bit"],
        "//hw/bitstream:bitstream_vivado": ["//hw/bitstream/vivado:fpga_cw340_test_rom"],
        "//hw/bitstream:bitstream_gcp_splice": ["@bitstreams//:chip_earlgrey_cw340_bitstream"],
        "//conditions:default": ["@bitstreams//:chip_earlgrey_cw340_bitstream"],
    }),
    tags = ["manual"],
)

filegroup(
    name = "rom_mmi",
    testonly = True,
    srcs = select({
        "//hw/bitstream:bitstream_skip": ["rom.mmi"],
        "//hw/bitstream:bitstream_vivado": ["//hw/bitstream/vivado:fpga_cw340_rom_mmi"],
        "//hw/bitstream:bitstream_gcp_splice": ["@bitstreams//:chip_earlgrey_cw340_rom_mmi"],
        "//conditions:default": ["@bitstreams//:chip_earlgrey_cw340_rom_mmi"],
    }),
    tags = ["manual"],
)

filegroup(
    name = "otp_mmi",
    testonly = True,
    srcs = select({
        "//hw/bitstream:bitstream_skip": ["otp.mmi"],
        "//hw/bitstream:bitstream_vivado": ["//hw/bitstream/vivado:fpga_cw340_otp_mmi"],
        "//hw/bitstream:bitstream_gcp_splice": ["@bitstreams//:chip_earlgrey_cw340_otp_mmi"],
        "//conditions:default": ["@bitstreams//:chip_earlgrey_cw340_otp_mmi"],
    }),
    tags = ["manual"],
)

# Build the Test ROM and splice it into the bitstream.
bitstream_splice(
    name = "test_rom",
    testonly = True,
    src = ":bitstream",
    data = "//sw/device/lib/testing/test_rom:test_rom_fpga_cw340_scr_vmem",
    meminfo = ":rom_mmi",
    tags = ["manual"],
    update_usr_access = True,
)

# Build the ROM and splice it into a cached bitstream.
[
    bitstream_splice(
        name = "rom_with_{}_keys".format(authenticity),
        testonly = True,
        src = ":bitstream",
        data = "//sw/device/silicon_creator/rom:rom_with_{}_keys_fpga_cw340_scr_vmem".format(authenticity),
        meminfo = ":rom_mmi",
        tags = ["manual"],
        update_usr_access = True,
    )
    for authenticity in KEY_AUTHENTICITY
]

# Splice OTP images into the locally-spliced ROM bitstream.
[
    bitstream_splice(
        name = "rom_with_{}_keys_otp_{}".format(authenticity, otp_name),
        testonly = True,
        src = ":rom_with_{}_keys".format(authenticity),
        data = img_target,
        meminfo = ":otp_mmi",
        tags = ["manual"],
        update_usr_access = True,
    )
    for (otp_name, img_target) in get_otp_images()
    for authenticity in KEY_AUTHENTICITY
]
