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

OTBN_DECLARE_APP_SYMBOLS(otbn_mlkem_plain_encap_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_plain_encap_test, coins);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_plain_encap_test, ct);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_plain_encap_test, ss);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_plain_encap_test, ek);

static const otbn_app_t kAppMLKEMPlainEncap = OTBN_APP_T_INIT(otbn_mlkem_plain_encap_test);
static const otbn_addr_t kCoinsEPlain = OTBN_ADDR_T_INIT(otbn_mlkem_plain_encap_test, coins);
static const otbn_addr_t kCtEPlain = OTBN_ADDR_T_INIT(otbn_mlkem_plain_encap_test, ct);
static const otbn_addr_t kSsEPlain = OTBN_ADDR_T_INIT(otbn_mlkem_plain_encap_test, ss);
static const otbn_addr_t kEkEPlain = OTBN_ADDR_T_INIT(otbn_mlkem_plain_encap_test, ek);

OTBN_DECLARE_APP_SYMBOLS(otbn_mlkem_base_encap_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_base_encap_test, coins);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_base_encap_test, ct);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_base_encap_test, ss);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_base_encap_test, ek);

static const otbn_app_t kAppMLKEMBaseEncap = OTBN_APP_T_INIT(otbn_mlkem_base_encap_test);
static const otbn_addr_t kCoinsEBase = OTBN_ADDR_T_INIT(otbn_mlkem_base_encap_test, coins);
static const otbn_addr_t kCtEBase = OTBN_ADDR_T_INIT(otbn_mlkem_base_encap_test, ct);
static const otbn_addr_t kSsEBase = OTBN_ADDR_T_INIT(otbn_mlkem_base_encap_test, ss);
static const otbn_addr_t kEkEBase = OTBN_ADDR_T_INIT(otbn_mlkem_base_encap_test, ek);

OTBN_DECLARE_APP_SYMBOLS(otbn_mlkem_isaext_encap_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_isaext_encap_test, coins);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_isaext_encap_test, ct);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_isaext_encap_test, ss);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mlkem_isaext_encap_test, ek);

static const otbn_app_t kAppMLKEMIsaextEncap = OTBN_APP_T_INIT(otbn_mlkem_isaext_encap_test);
static const otbn_addr_t kCoinsEIsaext = OTBN_ADDR_T_INIT(otbn_mlkem_isaext_encap_test, coins);
static const otbn_addr_t kCtEIsaext = OTBN_ADDR_T_INIT(otbn_mlkem_isaext_encap_test, ct);
static const otbn_addr_t kSsEIsaext = OTBN_ADDR_T_INIT(otbn_mlkem_isaext_encap_test, ss);
static const otbn_addr_t kEkEIsaext = OTBN_ADDR_T_INIT(otbn_mlkem_isaext_encap_test, ek);

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

static void test_mlkem_encap(dif_otbn_t *otbn) {
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
  crypto_kem_keypair_derand(ek_expected, dk_expected, coins); 
  crypto_kem_enc_derand(ct_expected, ssE_expected, ek_expected, coinsE);

  uint8_t ct[CRYPTO_CIPHERTEXTBYTES];
  uint8_t ssE[CRYPTO_BYTES]; 

  /* Run plain encap */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load plain encap");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLKEMPlainEncap));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, KYBER_SYMBYTES, coinsE, kCoinsEPlain));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_PUBLICKEYBYTES, ek_expected, kEkEPlain));

  LOG_INFO("Run plain encap"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_CIPHERTEXTBYTES, kCtEPlain, ct));
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_BYTES, kSsEPlain, ssE));

  LOG_INFO("Check plain ct and ss");
  CHECK_ARRAYS_EQ(ct, ct_expected, CRYPTO_CIPHERTEXTBYTES);
  CHECK_ARRAYS_EQ(ssE, ssE_expected, CRYPTO_BYTES);

  /* Run base encap */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load base encap");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLKEMBaseEncap));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, KYBER_SYMBYTES, coinsE, kCoinsEBase));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_PUBLICKEYBYTES, ek_expected, kEkEBase));

  LOG_INFO("Run base encap"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_CIPHERTEXTBYTES, kCtEBase, ct));
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_BYTES, kSsEBase, ssE));

  LOG_INFO("Check base ct and ss");
  CHECK_ARRAYS_EQ(ct, ct_expected, CRYPTO_CIPHERTEXTBYTES);
  CHECK_ARRAYS_EQ(ssE, ssE_expected, CRYPTO_BYTES);

  /* Run ISAEXT encap */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load ISAEXT encap");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLKEMIsaextEncap));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, KYBER_SYMBYTES, coinsE, kCoinsEIsaext));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_PUBLICKEYBYTES, ek_expected, kEkEIsaext));

  LOG_INFO("Run ISAEXT encap"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_CIPHERTEXTBYTES, kCtEIsaext, ct));
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_BYTES, kSsEIsaext, ssE));

  LOG_INFO("Check ISAEXT ct and ss");
  CHECK_ARRAYS_EQ(ct, ct_expected, CRYPTO_CIPHERTEXTBYTES);
  CHECK_ARRAYS_EQ(ssE, ssE_expected, CRYPTO_BYTES);
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
    test_mlkem_encap(&otbn);
  }

  test_sec_wipe(&otbn);

  return true;
}
