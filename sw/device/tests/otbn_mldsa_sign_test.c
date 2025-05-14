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

#include "sw/device/tests/pq-crystals/dilithium_opentitan/lowram/params.h"
#include "sw/device/tests/pq-crystals/dilithium_opentitan/lowram/sign.h"
#include "sw/device/tests/pq-crystals/dilithium_opentitan/lowram/fips202.h"

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

// Declare symbols and addresses for otbn_mldsa_plain_sign_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mldsa_plain_sign_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_sign_test, signature);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_sign_test, message);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_sign_test, messagelen);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_sign_test, sk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_sign_test, ctx);

static const otbn_app_t kAppMLDSAPlainSign = OTBN_APP_T_INIT(otbn_mldsa_plain_sign_test);
static const otbn_addr_t kSigPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_sign_test, signature);
static const otbn_addr_t kMsgPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_sign_test, message);
static const otbn_addr_t kMlenPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_sign_test, messagelen);
static const otbn_addr_t kSkPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_sign_test, sk);
static const otbn_addr_t kCtxPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_sign_test, ctx);

// Declare symbols and addresses for otbn_mldsa_base_sign_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mldsa_base_sign_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_sign_test, signature);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_sign_test, message);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_sign_test, messagelen);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_sign_test, sk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_sign_test, ctx);

static const otbn_app_t kAppMLDSABaseSign = OTBN_APP_T_INIT(otbn_mldsa_base_sign_test);
static const otbn_addr_t kSigBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_sign_test, signature);
static const otbn_addr_t kMsgBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_sign_test, message);
static const otbn_addr_t kMlenBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_sign_test, messagelen);
static const otbn_addr_t kSkBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_sign_test, sk);
static const otbn_addr_t kCtxBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_sign_test, ctx);

// Declare symbols and addresses for otbn_mldsa_isaext_sign_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mldsa_isaext_sign_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_sign_test, signature);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_sign_test, message);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_sign_test, messagelen);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_sign_test, sk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_sign_test, ctx);

static const otbn_app_t kAppMLDSAIsaextSign = OTBN_APP_T_INIT(otbn_mldsa_isaext_sign_test);
static const otbn_addr_t kSigIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_sign_test, signature);
static const otbn_addr_t kMsgIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_sign_test, message);
static const otbn_addr_t kMlenIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_sign_test, messagelen);
static const otbn_addr_t kSkIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_sign_test, sk);
static const otbn_addr_t kCtxIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_sign_test, ctx);


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

static void test_mldsa_sign(dif_otbn_t *otbn) {
  LOG_INFO("Generate zeta");
  uint8_t zeta[SEEDBYTES];
  randombytes(zeta, SEEDBYTES);

  LOG_INFO("Generate message");
  /* mlen must be uint32_t to be correctly written to OTBN's DMEM. */
  uint32_t mlen = MLEN;
  uint8_t m[MLEN];
  randombytes(m, MLEN);

  LOG_INFO("Run reference implementation");
  uint8_t pk_expected[CRYPTO_PUBLICKEYBYTES];
  uint8_t sk_expected[CRYPTO_SECRETKEYBYTES];
  crypto_sign_keypair_internal(pk_expected, sk_expected, zeta);

  // Prepare context
  uint8_t pre[2+CTXLEN];
  pre[0] = 0;
  pre[1] = CTXLEN;
  for(int i = 0; i < CTXLEN; i++)
    pre[2 + i] = context[i];
  
  size_t siglen;
  uint8_t sig_expected[CRYPTO_BYTES_ALIGNED];
  uint8_t rnd[RNDBYTES] = {0};
  crypto_sign_signature_internal(sig_expected, &siglen, m, mlen, pre, sizeof(pre), rnd, sk_expected);

  uint8_t sig[CRYPTO_BYTES_ALIGNED];
  /* Run plain sign */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load plain sign");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLDSAPlainSign));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, MLEN, &m, kMsgPlain));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(uint32_t), &mlen, kMlenPlain));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_SECRETKEYBYTES, &sk_expected, kSkPlain));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CTXLEN, &context, kCtxPlain));

  LOG_INFO("Run plain sign"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_BYTES_ALIGNED, kSigPlain, &sig));

  LOG_INFO("Check plain signature");
  CHECK_ARRAYS_EQ(sig, sig_expected, CRYPTO_BYTES);

  /* Run base sign */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load base sign");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLDSABaseSign));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, MLEN, &m, kMsgBase));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(uint32_t), &mlen, kMlenBase));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_SECRETKEYBYTES, &sk_expected, kSkBase));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CTXLEN, &context, kCtxBase));

  LOG_INFO("Run base sign"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_BYTES_ALIGNED, kSigBase, &sig));

  LOG_INFO("Check base signature");
  CHECK_ARRAYS_EQ(sig, sig_expected, CRYPTO_BYTES);

  /* Run ISAEXT sign */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load ISAEXT sign");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLDSAIsaextSign));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, MLEN, &m, kMsgIsaext));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(uint32_t), &mlen, kMlenIsaext));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_SECRETKEYBYTES, &sk_expected, kSkIsaext));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CTXLEN, &context, kCtxIsaext));

  LOG_INFO("Run ISAEXT sign"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, CRYPTO_BYTES_ALIGNED, kSigIsaext, &sig));

  LOG_INFO("Check ISAEXT signature");
  // CHECK_ARRAYS_EQ(sig, sig_expected, CRYPTO_BYTES);
    for (int i = 0; i < CRYPTO_BYTES; ++i) {
    CHECK(sig[i] == sig_expected[i],
          "Unexpected result c at byte %d: 0x%02x (actual) != 0x%02x (expected)", i,
          sig[i], sig_expected[i]);
  }
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
    test_mldsa_sign(&otbn);
  }

  // Wipe OTBN
  LOG_INFO("Wipe OTBN");
  test_sec_wipe(&otbn);

  return true;
}
