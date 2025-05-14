// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdlib.h>
#include "sw/device/lib/dif/dif_otbn.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/entropy_testutils.h"
#include "sw/device/lib/testing/otbn_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#include "sw/device/tests/pq-crystals/kyber_opentitan/ref/params.h"
#include "sw/device/tests/pq-crystals/kyber_opentitan/ref/kem.h"
#include "sw/device/tests/pq-crystals/kyber_opentitan/ref/fips202.h"

#ifndef NTESTS 
#define NTESTS 1
#endif

// Declare symbols and addresses for kyber_base_mlkem_keypair_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mlkem_plain_keypair_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_plain_keypair_test, coins);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_plain_keypair_test, dk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_plain_keypair_test, ek);

static const otbn_app_t kAppMLKEMPlainKeypair = OTBN_APP_T_INIT(otbn_mlkem_plain_keypair_test);
static const otbn_addr_t kCoinsPlain = OTBN_ADDR_T_INIT(otbn_mlkem_plain_keypair_test, coins);
static const otbn_addr_t kEkPlain = OTBN_ADDR_T_INIT(otbn_mlkem_plain_keypair_test, ek);
static const otbn_addr_t kDkPlain = OTBN_ADDR_T_INIT(otbn_mlkem_plain_keypair_test, dk);

// Declare symbols and addresses for kyber_base_mlkem_keypair_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mlkem_base_keypair_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_base_keypair_test, coins);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_base_keypair_test, dk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_base_keypair_test, ek);

static const otbn_app_t kAppMLKEMBaseKeypair = OTBN_APP_T_INIT(otbn_mlkem_base_keypair_test);
static const otbn_addr_t kCoinsBase = OTBN_ADDR_T_INIT(otbn_mlkem_base_keypair_test, coins);
static const otbn_addr_t kEkBase = OTBN_ADDR_T_INIT(otbn_mlkem_base_keypair_test, ek);
static const otbn_addr_t kDkBase = OTBN_ADDR_T_INIT(otbn_mlkem_base_keypair_test, dk);

// Declare symbols and addresses for kyber_mlkem_keypair_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mlkem_isaext_keypair_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_isaext_keypair_test, coins);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_isaext_keypair_test, dk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_isaext_keypair_test, ek);

static const otbn_app_t kAppMLKEMIsaextKeypair = OTBN_APP_T_INIT(otbn_mlkem_isaext_keypair_test);
static const otbn_addr_t kCoinsIsaext = OTBN_ADDR_T_INIT(otbn_mlkem_isaext_keypair_test, coins);
static const otbn_addr_t kEkIsaext = OTBN_ADDR_T_INIT(otbn_mlkem_isaext_keypair_test, ek);
static const otbn_addr_t kDkIsaext = OTBN_ADDR_T_INIT(otbn_mlkem_isaext_keypair_test, dk);

OTTF_DEFINE_TEST_CONFIG();

/* Deterministic randombytes by Daniel J. Bernstein */
/* taken from SUPERCOP (https://bench.cr.yp.to)     */
static keccak_state rngstate = {
  {0x1F, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, (1ULL << 63),
  0, 0, 0, 0},
  SHAKE128_RATE};

void randombytes(uint8_t *x,size_t xlen)
{
  shake128_squeeze(x, xlen, &rngstate);
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

static void test_mlkem_keypair(dif_otbn_t *otbn) {
  LOG_INFO("Generate inputs");
  uint8_t coins[2*KYBER_SYMBYTES];
  randombytes(coins, 2*KYBER_SYMBYTES);

  // Run C implementation and retrieve result
  LOG_INFO("Run reference implementation");
  uint8_t ek_expected[CRYPTO_PUBLICKEYBYTES];
  uint8_t dk_expected[CRYPTO_SECRETKEYBYTES];
  crypto_kem_keypair_derand(ek_expected, dk_expected, coins);

  uint8_t ek[CRYPTO_PUBLICKEYBYTES];
  uint8_t dk[CRYPTO_SECRETKEYBYTES];

  /* Run plain keypair */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load plain keypair");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLKEMPlainKeypair));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, 2*KYBER_SYMBYTES, coins, kCoinsPlain));

  LOG_INFO("Run plain keypair"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_PUBLICKEYBYTES, kEkPlain, ek));
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_SECRETKEYBYTES, kDkPlain, dk));

  LOG_INFO("Check plain keys");
  CHECK_ARRAYS_EQ(ek, ek_expected, CRYPTO_PUBLICKEYBYTES);
  CHECK_ARRAYS_EQ(dk, dk_expected, CRYPTO_SECRETKEYBYTES);

  /* Run base keypair */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load base keypair");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLKEMBaseKeypair));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, 2*KYBER_SYMBYTES, coins, kCoinsBase));

  LOG_INFO("Run base keypair"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_PUBLICKEYBYTES, kEkBase, ek));
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_SECRETKEYBYTES, kDkBase, dk));

  LOG_INFO("Check base keys");
  CHECK_ARRAYS_EQ(ek, ek_expected, CRYPTO_PUBLICKEYBYTES);
  CHECK_ARRAYS_EQ(dk, dk_expected, CRYPTO_SECRETKEYBYTES);

  /* Run ISAEXT keypair */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load ISAEXT keypair");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLKEMIsaextKeypair));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, 2*KYBER_SYMBYTES, coins, kCoinsIsaext));

  LOG_INFO("Run ISAEXT keypair"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_PUBLICKEYBYTES, kEkIsaext, ek));
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_SECRETKEYBYTES, kDkIsaext, dk));

  LOG_INFO("Check ISAEXT keys");
  CHECK_ARRAYS_EQ(ek, ek_expected, CRYPTO_PUBLICKEYBYTES);
  CHECK_ARRAYS_EQ(dk, dk_expected, CRYPTO_SECRETKEYBYTES);
}

bool test_main(void) {

  CHECK_STATUS_OK(entropy_testutils_auto_mode_init());

  // Initialize OTBN
  LOG_INFO("Initialize OTBN");
  dif_otbn_t otbn;
  CHECK_DIF_OK(
      dif_otbn_init(mmio_region_from_addr(TOP_EARLGREY_OTBN_BASE_ADDR), &otbn));

  for(int i = 0; i < NTESTS; i++) {
    LOG_INFO("Iteration %d", i);
    test_mlkem_keypair(&otbn);
  }

  test_sec_wipe(&otbn);

  return true;
}
