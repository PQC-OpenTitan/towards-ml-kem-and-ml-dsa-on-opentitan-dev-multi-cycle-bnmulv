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

#include "sw/device/tests/pq-crystals/dilithium_opentitan/ref/params.h"
#include "sw/device/tests/pq-crystals/dilithium_opentitan/ref/sign.h"
#include "sw/device/tests/pq-crystals/dilithium_opentitan/ref/fips202.h"

#ifndef NTESTS 
#define NTESTS 1
#endif

#define MLEN 64
#define CTXLEN 32

#if DILITHIUM_MODE == 2
  #define CRYPTO_BYTES_ALIGNED CRYPTO_BYTES
#elif DILITHIUM_MODE == 3
  #define CRYPTO_BYTES_ALIGNED (CRYPTO_BYTES+3)
#elif DILITHIUM_MODE == 5
  #define CRYPTO_BYTES_ALIGNED (CRYPTO_BYTES+13)
#endif

const uint8_t context[CTXLEN] = {
  0x00, 0x00, 0x00, 0x00, 0x11, 0x11, 0x11, 0x11, 0x22, 0x22, 0x22, 0x22, 0x33,
  0x33, 0x33, 0x33, 0x44, 0x44, 0x44, 0x44, 0x55, 0x55, 0x55, 0x55, 0x66, 0x66,
  0x66, 0x66, 0x77, 0x77, 0x77, 0x77
};

// Declare symbols and addresses for otbn_mldsa_plain_keypair_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mldsa_plain_keypair_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_keypair_test, zeta);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_keypair_test, pk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_keypair_test, sk);

static const otbn_app_t kAppMLDSAPlainKeypair = OTBN_APP_T_INIT(otbn_mldsa_plain_keypair_test);
static const otbn_addr_t kZetaPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_keypair_test, zeta);
static const otbn_addr_t kPkPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_keypair_test, pk);
static const otbn_addr_t kSkPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_keypair_test, sk);

// Declare symbols and addresses for otbn_mldsa_base_keypair_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mldsa_base_keypair_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_keypair_test, zeta);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_keypair_test, pk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_keypair_test, sk);

static const otbn_app_t kAppMLDSABaseKeypair = OTBN_APP_T_INIT(otbn_mldsa_base_keypair_test);
static const otbn_addr_t kZetaBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_keypair_test, zeta);
static const otbn_addr_t kPkBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_keypair_test, pk);
static const otbn_addr_t kSkBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_keypair_test, sk);

// Declare symbols and addresses for otbn_mldsa_isaext_keypair_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mldsa_isaext_keypair_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_keypair_test, zeta);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_keypair_test, pk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_keypair_test, sk);

static const otbn_app_t kAppMLDSAIsaextKeypair = OTBN_APP_T_INIT(otbn_mldsa_isaext_keypair_test);
static const otbn_addr_t kZetaIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_keypair_test, zeta);
static const otbn_addr_t kPkIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_keypair_test, pk);
static const otbn_addr_t kSkIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_keypair_test, sk);

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

static void test_mldsa_keypair(dif_otbn_t *otbn) {
  LOG_INFO("Generate zeta");
  uint8_t zeta[SEEDBYTES];
  randombytes(zeta, SEEDBYTES);
  LOG_INFO("%02x %02x %02x", zeta[0], zeta[1], zeta[2]);

  LOG_INFO("Run C implementation");
  uint8_t pk_expected[CRYPTO_PUBLICKEYBYTES];
  uint8_t sk_expected[CRYPTO_SECRETKEYBYTES];
  crypto_sign_keypair_internal(pk_expected, sk_expected, zeta);

  uint8_t pk[CRYPTO_PUBLICKEYBYTES];
  uint8_t sk[CRYPTO_SECRETKEYBYTES];

  /* Run plain keypair */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load plain keypair");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLDSAPlainKeypair));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, SEEDBYTES, &zeta, kZetaPlain));

  LOG_INFO("Run plain keypair"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_PUBLICKEYBYTES, kPkPlain, &pk));
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_SECRETKEYBYTES, kSkPlain, &sk));

  LOG_INFO("Check plain keys");
  CHECK_ARRAYS_EQ(pk, pk_expected, CRYPTO_PUBLICKEYBYTES);
  CHECK_ARRAYS_EQ(sk, sk_expected, CRYPTO_SECRETKEYBYTES);

  /* Run base keypair */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load base keypair");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLDSABaseKeypair));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, SEEDBYTES, &zeta, kZetaBase));

  LOG_INFO("Run plain keypair"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_PUBLICKEYBYTES, kPkBase, &pk));
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_SECRETKEYBYTES, kSkBase, &sk));

  LOG_INFO("Check base keys");
  CHECK_ARRAYS_EQ(pk, pk_expected, CRYPTO_PUBLICKEYBYTES);
  CHECK_ARRAYS_EQ(sk, sk_expected, CRYPTO_SECRETKEYBYTES);

  /* Run ISAEXT keypair */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load ISAEXT keypair");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLDSAIsaextKeypair));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, SEEDBYTES, &zeta, kZetaIsaext));

  LOG_INFO("Run ISAEXT keypair"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_PUBLICKEYBYTES, kPkIsaext, &pk));
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_SECRETKEYBYTES, kSkIsaext, &sk));

  LOG_INFO("Check ISAEXT keys");
  CHECK_ARRAYS_EQ(pk, pk_expected, CRYPTO_PUBLICKEYBYTES);
  CHECK_ARRAYS_EQ(sk, sk_expected, CRYPTO_SECRETKEYBYTES);
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
    test_mldsa_keypair(&otbn);
  }

  test_sec_wipe(&otbn);

  return true;
}
