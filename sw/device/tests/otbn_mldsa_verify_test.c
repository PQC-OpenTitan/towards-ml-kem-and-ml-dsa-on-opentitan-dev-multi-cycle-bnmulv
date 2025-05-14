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

// Declare symbols and addresses for otbn_mldsa_plain_verify_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mldsa_plain_verify_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_verify_test, signature);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_verify_test, message);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_verify_test, messagelen);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_verify_test, pk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_verify_test, ctx);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_plain_verify_test, result);


static const otbn_app_t kAppMLDSAPlainVerify = OTBN_APP_T_INIT(otbn_mldsa_plain_verify_test);
static const otbn_addr_t kSigPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_verify_test, signature);
static const otbn_addr_t kMsgPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_verify_test, message);
static const otbn_addr_t kMlenPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_verify_test, messagelen);
static const otbn_addr_t kPkPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_verify_test, pk);
static const otbn_addr_t kCtxPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_verify_test, ctx);
static const otbn_addr_t kResPlain = OTBN_ADDR_T_INIT(otbn_mldsa_plain_verify_test, result);

// Declare symbols and addresses for otbn_mldsa_base_verify_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mldsa_base_verify_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_verify_test, signature);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_verify_test, message);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_verify_test, messagelen);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_verify_test, pk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_verify_test, ctx);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_base_verify_test, result);


static const otbn_app_t kAppMLDSABaseVerify = OTBN_APP_T_INIT(otbn_mldsa_base_verify_test);
static const otbn_addr_t kSigBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_verify_test, signature);
static const otbn_addr_t kMsgBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_verify_test, message);
static const otbn_addr_t kMlenBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_verify_test, messagelen);
static const otbn_addr_t kPkBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_verify_test, pk);
static const otbn_addr_t kCtxBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_verify_test, ctx);
static const otbn_addr_t kResBase = OTBN_ADDR_T_INIT(otbn_mldsa_base_verify_test, result);

// Declare symbols and addresses for otbn_mldsa_isaext_verify_test.s
OTBN_DECLARE_APP_SYMBOLS(otbn_mldsa_isaext_verify_test);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_verify_test, signature);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_verify_test, message);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_verify_test, messagelen);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_verify_test, pk);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_verify_test, ctx);
OTBN_DECLARE_SYMBOL_ADDR(otbn_mldsa_isaext_verify_test, result);


static const otbn_app_t kAppMLDSAIsaextVerify = OTBN_APP_T_INIT(otbn_mldsa_isaext_verify_test);
static const otbn_addr_t kSigIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_verify_test, signature);
static const otbn_addr_t kMsgIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_verify_test, message);
static const otbn_addr_t kMlenIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_verify_test, messagelen);
static const otbn_addr_t kPkIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_verify_test, pk);
static const otbn_addr_t kCtxIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_verify_test, ctx);
static const otbn_addr_t kResIsaext = OTBN_ADDR_T_INIT(otbn_mldsa_isaext_verify_test, result);

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

static void test_mldsa_verify(dif_otbn_t *otbn) {
  LOG_INFO("Generate zeta");
  uint8_t zeta[SEEDBYTES];
  randombytes(zeta, SEEDBYTES);

  LOG_INFO("Run C implementation");
  uint8_t pk[CRYPTO_PUBLICKEYBYTES];
  uint8_t sk[CRYPTO_SECRETKEYBYTES];
  crypto_sign_keypair_internal(pk, sk, zeta);

  /* mlen must be uint32_t to be correctly written to OTBN's DMEM. */
  uint32_t mlen = MLEN;
  uint8_t m[MLEN];
  randombytes(m, MLEN);

  // Prepare context
  uint8_t pre[2+CTXLEN];
  pre[0] = 0;
  pre[1] = CTXLEN;
  for(int i = 0; i < CTXLEN; i++)
    pre[2 + i] = context[i];
  
  size_t siglen;
  uint8_t sig[CRYPTO_BYTES_ALIGNED];
  uint8_t rnd[RNDBYTES] = {0};
  crypto_sign_signature_internal(sig, &siglen, m, mlen, pre, sizeof(pre), rnd, sk);

  // uint8_t m2[MLEN];
  // randombytes(m2, MLEN);

  int res_expected;
  res_expected = crypto_sign_verify_internal(sig, CRYPTO_BYTES, m, mlen, pre, sizeof(pre), pk);
  LOG_INFO("res_exp = %d", res_expected);

  int res;

  /* Run plain verify */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load plain verify");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLDSAPlainVerify));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_BYTES_ALIGNED, &sig, kSigPlain));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, MLEN, &m, kMsgPlain));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(uint32_t), &mlen, kMlenPlain));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_PUBLICKEYBYTES, &pk, kPkPlain));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CTXLEN, &context, kCtxPlain));

  LOG_INFO("Run plain verify"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));
  
  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, sizeof(uint32_t), kResPlain, &res));

  LOG_INFO("Check plain verify");
  CHECK(res == res_expected, "Verification failed: got %d != %d (expected)", res, res_expected);
  LOG_INFO("res plain = %d", res);

  /* Run base verify */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load base verify");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLDSABaseVerify));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_BYTES_ALIGNED, &sig, kSigBase));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, MLEN, &m, kMsgBase));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(uint32_t), &mlen, kMlenBase));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_PUBLICKEYBYTES, &pk, kPkBase));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CTXLEN, &context, kCtxBase));

  LOG_INFO("Run base verify"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));
  
  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, sizeof(uint32_t), kResBase, &res));

  LOG_INFO("Check base verify");
  CHECK(res == res_expected, "Verification failed: got %d != %d (expected)", res, res_expected);
  LOG_INFO("res base = %d", res);

  /* Run ISAEXT verify */
  /* ------------------------------------------------------------------------ */
  LOG_INFO("Load ISAEXT verify");
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppMLDSAIsaextVerify));

  LOG_INFO("Write inputs to OTBN's DMEM");
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_BYTES_ALIGNED, &sig, kSigIsaext));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, MLEN, &m, kMsgIsaext));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(uint32_t), &mlen, kMlenIsaext));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CRYPTO_PUBLICKEYBYTES, &pk, kPkIsaext));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, CTXLEN, &context, kCtxIsaext));

  LOG_INFO("Run ISAEXT verify"); 
  CHECK_DIF_OK(dif_otbn_set_ctrl_software_errs_fatal(otbn, true));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK(dif_otbn_set_ctrl_software_errs_fatal(otbn, false) == kDifUnavailable);
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));
 
  LOG_INFO("Retrieve results");
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, sizeof(uint32_t), kResIsaext, &res));

  LOG_INFO("Check ISAEXT verify");
  CHECK(res == res_expected, "Verification failed: got %d != %d (expected)", res, res_expected);
  LOG_INFO("res isaext = %d", res);
}

bool test_main(void) {

  CHECK_STATUS_OK(entropy_testutils_auto_mode_init());

  LOG_INFO("Initialize OTBN");
  dif_otbn_t otbn;
  CHECK_DIF_OK(
      dif_otbn_init(mmio_region_from_addr(TOP_EARLGREY_OTBN_BASE_ADDR), &otbn));

  for(int i = 0; i < NTESTS; i++) {
    LOG_INFO("Iteration %d", i);
    test_mldsa_verify(&otbn);
  }

  LOG_INFO("Wipe OTBN");
  test_sec_wipe(&otbn);

  return true;
}
