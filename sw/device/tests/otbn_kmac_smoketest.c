// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Modified by Authors of "Towards ML-KEM & ML-DSA on OpenTitan" (https://eprint.iacr.org/2024/1192)
// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors

#include "sw/device/lib/dif/dif_otbn.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/entropy_testutils.h"
#include "sw/device/lib/testing/otbn_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#define SHA3_256_CFG 8
#define SHA3_512_CFG 16
#define SHAKE128_CFG 2
#define SHAKE256_CFG 10

OTBN_DECLARE_APP_SYMBOLS(kmac_test);
//OTBN_DECLARE_SYMBOL_ADDR(kmac_test, kmac_config);
//OTBN_DECLARE_SYMBOL_ADDR(kmac_test, kmac_message_length);
//OTBN_DECLARE_SYMBOL_ADDR(kmac_test, kmac_digest_length);
OTBN_DECLARE_SYMBOL_ADDR(kmac_test, kmac_input);
OTBN_DECLARE_SYMBOL_ADDR(kmac_test, kmac_output);

static const otbn_app_t kAppKmacTest = OTBN_APP_T_INIT(kmac_test);
//static const otbn_addr_t kAppKmacCfg = OTBN_ADDR_T_INIT(kmac_test, kmac_config);
//static const otbn_addr_t kAppKmacMsgLen = OTBN_ADDR_T_INIT(kmac_test, kmac_message_length);
//static const otbn_addr_t kAppKmacDigestLen = OTBN_ADDR_T_INIT(kmac_test, kmac_digest_length);
static const otbn_addr_t kAppKmacInp = OTBN_ADDR_T_INIT(kmac_test, kmac_input);
static const otbn_addr_t kAppKmacOut = OTBN_ADDR_T_INIT(kmac_test, kmac_output);

OTTF_DEFINE_TEST_CONFIG();

//static void get_reference_digest(uint8_t mode, uint8_t *input, size_t input_len, uint8_t *output, size_t output_len) {}


static void test_kmac(dif_otbn_t *otbn) {
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppKmacTest));

  //uint8_t kmac_config_value[4] = {SHA3_256_CFG, 0x0, 0x0, 0x0};
  //CHECK_STATUS_OK(otbn_testutils_write_data(otbn, 4, &kmac_config_value, kAppKmacCfg));

  //uint8_t kmac_message_length_value[4] = {0x20, 0x0, 0x0, 0x0};
  //CHECK_STATUS_OK(otbn_testutils_write_data(otbn, 4, &kmac_message_length_value, kAppKmacMsgLen));

  //uint8_t kmac_digest_length_value[4] = {0x20, 0x0, 0x0, 0x0};
  //CHECK_STATUS_OK(otbn_testutils_write_data(otbn, 4, &kmac_digest_length_value, kAppKmacDigestLen));

  static const uint8_t kmac_input_data[32] = {
    0xc1, 0x78, 0xce, 0x0f, 0x72, 0x0a, 0x6d, 0x73,
    0xc6, 0xcf, 0x1c, 0xaa, 0x90, 0x5e, 0xe7, 0x24,
    0xd5, 0xba, 0x94, 0x1c, 0x2e, 0x26, 0x28, 0x13,
    0x6e, 0x3a, 0xad, 0x7d, 0x85, 0x37, 0x33, 0xba
  };
  static const uint8_t kmac_reference_digest[32] = {
    0x64, 0x53, 0x7b, 0x87, 0x89, 0x28, 0x35, 0xff,
    0x09, 0x63, 0xef, 0x9a, 0xd5, 0x14, 0x5a, 0xb4,
    0xcf, 0xce, 0x5d, 0x30, 0x3a, 0x0c, 0xb0, 0x41,
    0x5b, 0x3b, 0x03, 0xf9, 0xd1, 0x6e, 0x7d, 0x6b
  };
  uint8_t kmac_output_data[32];

  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, 32, &kmac_input_data, kAppKmacInp));

  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, 32, kAppKmacOut, &kmac_output_data));

  CHECK_ARRAYS_EQ(kmac_output_data, kmac_reference_digest, 32);
}

static void test_sec_wipe(dif_otbn_t *otbn) {
  dif_otbn_status_t otbn_status;

  CHECK_DIF_OK(dif_otbn_write_cmd(otbn, kDifOtbnCmdSecWipeDmem));
  CHECK_DIF_OK(dif_otbn_get_status(otbn, &otbn_status));
  CHECK(otbn_status == kDifOtbnStatusBusySecWipeDmem);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  CHECK_DIF_OK(dif_otbn_write_cmd(otbn, kDifOtbnCmdSecWipeImem));
  CHECK_DIF_OK(dif_otbn_get_status(otbn, &otbn_status));
  CHECK(otbn_status == kDifOtbnStatusBusySecWipeImem);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));
}

bool test_main(void) {
  CHECK_STATUS_OK(entropy_testutils_auto_mode_init());

  dif_otbn_t otbn;
  CHECK_DIF_OK(
    dif_otbn_init(mmio_region_from_addr(TOP_EARLGREY_OTBN_BASE_ADDR), &otbn));

  test_kmac(&otbn);
  test_sec_wipe(&otbn);

  return true;
}
