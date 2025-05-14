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

OTBN_DECLARE_APP_SYMBOLS(otbn_mlkem_plain_decap_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_plain_decap_test, ct);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_plain_decap_test, dk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_plain_decap_test, ss);

static const otbn_app_t kAppMLKEMPlainDecap = OTBN_APP_T_INIT(otbn_mlkem_plain_decap_test);
static const otbn_addr_t kCtDPlain = OTBN_ADDR_T_INIT(otbn_mlkem_plain_decap_test, ct);
static const otbn_addr_t kDkDPlain = OTBN_ADDR_T_INIT(otbn_mlkem_plain_decap_test, dk);
static const otbn_addr_t kSsDPlain = OTBN_ADDR_T_INIT(otbn_mlkem_plain_decap_test, ss);

OTBN_DECLARE_APP_SYMBOLS(otbn_mlkem_base_decap_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_base_decap_test, ct);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_base_decap_test, dk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_base_decap_test, ss);

static const otbn_app_t kAppMLKEMBaseDecap = OTBN_APP_T_INIT(otbn_mlkem_base_decap_test);
static const otbn_addr_t kCtDBase = OTBN_ADDR_T_INIT(otbn_mlkem_base_decap_test, ct);
static const otbn_addr_t kDkDBase = OTBN_ADDR_T_INIT(otbn_mlkem_base_decap_test, dk);
static const otbn_addr_t kSsDBase = OTBN_ADDR_T_INIT(otbn_mlkem_base_decap_test, ss);

OTBN_DECLARE_APP_SYMBOLS(otbn_mlkem_isaext_decap_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_isaext_decap_test, ct);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_isaext_decap_test, dk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_isaext_decap_test, ss);

static const otbn_app_t kAppMLKEMIsaextDecap = OTBN_APP_T_INIT(otbn_mlkem_isaext_decap_test);
static const otbn_addr_t kCtDIsaext = OTBN_ADDR_T_INIT(otbn_mlkem_isaext_decap_test, ct);
static const otbn_addr_t kDkDIsaext = OTBN_ADDR_T_INIT(otbn_mlkem_isaext_decap_test, dk);
static const otbn_addr_t kSsDIsaext = OTBN_ADDR_T_INIT(otbn_mlkem_isaext_decap_test, ss);

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

static void test_mlkem_decap(dif_otbn_t *otbn) {
  LOG_INFO("Generate inputs");
  uint8_t coins[2*KYBER_SYMBYTES];
  randombytes(coins, 2*KYBER_SYMBYTES);
  uint8_t coinsE[KYBER_SYMBYTES];
  randombytes(coinsE, KYBER_SYMBYTES);

  LOG_INFO("Run reference implementation");
  uint8_t ek_expected[CRYPTO_PUBLICKEYBYTES];
  uint8_t dk_expected[CRYPTO_SECRETKEYBYTES];
  uint8_t ct_expected[CRYPTO_CIPHERTEXTBYTES];
  uint8_t ssE_expected[CRYPTO_BYTES];
  uint8_t ssD_expected[CRYPTO_BYTES];
  crypto_kem_keypair_derand(ek_expected, dk_expected, coins); 
  crypto_kem_enc_derand(ct_expected, ssE_expected, ek_expected, coinsE);
  crypto_kem_dec(ssD_expected, ct_expected, dk_expected);

  uint8_t ssD[CRYPTO_PUBLICKEYBYTES];

  /* Run plain decap */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load plain decap");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLKEMPlainDecap));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_CIPHERTEXTBYTES, ct_expected, kCtDPlain));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_SECRETKEYBYTES, dk_expected, kDkDPlain));

  LOG_INFO("Run plain decap"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_BYTES, kSsDPlain, ssD));

  LOG_INFO("Check plain key_a");
  CHECK_ARRAYS_EQ(ssD, ssD_expected, CRYPTO_BYTES);

  LOG_INFO("Check plain key_a vs key_b");
  CHECK_ARRAYS_EQ(ssD, ssE_expected, CRYPTO_BYTES);

  /* Run base decap */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load base decap");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLKEMBaseDecap));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_CIPHERTEXTBYTES, ct_expected, kCtDBase));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_SECRETKEYBYTES, dk_expected, kDkDBase));

  LOG_INFO("Run base decap"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_BYTES, kSsDBase, ssD));

  LOG_INFO("Check base key_a");
  CHECK_ARRAYS_EQ(ssD, ssD_expected, CRYPTO_BYTES);

  LOG_INFO("Check base key_a vs key_b");
  CHECK_ARRAYS_EQ(ssD, ssE_expected, CRYPTO_BYTES);

  /* Run ISAEXT decap */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load ISAEXT decap");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLKEMIsaextDecap));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_CIPHERTEXTBYTES, ct_expected, kCtDIsaext));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_SECRETKEYBYTES, dk_expected, kDkDIsaext));

  LOG_INFO("Run ISAEXT decap"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_BYTES, kSsDIsaext, ssD));

  LOG_INFO("Check ISAEXT key_a");
  CHECK_ARRAYS_EQ(ssD, ssD_expected, CRYPTO_BYTES);

  LOG_INFO("Check ISAEXT key_a vs key_b");
  CHECK_ARRAYS_EQ(ssD, ssE_expected, CRYPTO_BYTES);
}

bool test_main(void) {

  CHECK_STATUS_OK(entropy_testutils_auto_mode_init());

  // Initialize OTBN
  LOG_INFO("Initialize OTBN");
  dif_otbn_t otbn;
  CHECK_DIF_OK(
      dif_otbn_init(mmio_region_from_addr(TOP_EARLGREY_OTBN_BASE_ADDR), &otbn));

  // Run mlkem_plain_keygen on OTBN and compare with ref implementation NTESTS times
  for(int i = 0; i < NTESTS; i++) {
    LOG_INFO("Iteration %d", i);
    test_mlkem_decap(&otbn);
  }

  test_sec_wipe(&otbn);

  return true;

}
