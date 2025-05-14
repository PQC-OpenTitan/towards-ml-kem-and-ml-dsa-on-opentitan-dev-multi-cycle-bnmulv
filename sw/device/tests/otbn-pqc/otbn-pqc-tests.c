// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Modified by Authors of "Towards ML-KEM & ML-DSA on OpenTitan" (https://eprint.iacr.org/2024/1192)
// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors

#include <stdint.h>
#include <string.h>
#include <time.h>
#include "sw/device/lib/dif/dif_otbn.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/otbn_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"


uint32_t otbn_count = 0;

OTTF_DEFINE_TEST_CONFIG();

uint64_t get_mcycle(void) {
	
	uint32_t mc, mch;

	// get mcycle and mcycleh
	asm volatile("csrr %0, mcycle" : "=r" (mc));
	asm volatile("csrr %0, mcycleh": "=r" (mch));

        LOG_INFO("mcycle: %u", mc);
        LOG_INFO("mcycleh: %u", mch);
	return ((uint64_t)mch << 32) | mc;
}

static void test_ntt_base_dilithium(dif_otbn_t *otbn){
  OTBN_DECLARE_APP_SYMBOLS(otbn_ntt_base_dilithium);
  OTBN_DECLARE_SYMBOL_ADDR(otbn_ntt_base_dilithium, input);  // Position of Input and Result
  OTBN_DECLARE_SYMBOL_ADDR(otbn_ntt_base_dilithium, output);  // Position of Input and Result
  OTBN_DECLARE_SYMBOL_ADDR(otbn_ntt_base_dilithium, twiddles);  // Position of Input and Result
  OTBN_DECLARE_SYMBOL_ADDR(otbn_ntt_base_dilithium, modulus);  // Position of Input and Result

  const otbn_app_t kOtbnAppNttBaseDilithium = OTBN_APP_T_INIT(otbn_ntt_base_dilithium);
  const otbn_addr_t kInput = OTBN_ADDR_T_INIT(otbn_bn_addv, input);
  const otbn_addr_t kOutput = OTBN_ADDR_T_INIT(otbn_bn_addv, output);
  const otbn_addr_t kTwiddles = OTBN_ADDR_T_INIT(otbn_bn_addv, twiddles);
  const otbn_addr_t kModulus = OTBN_ADDR_T_INIT(otbn_bn_addv, modulus);

  // Load Dilitihum NTT
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kOtbnAppNttBaseDilithium));
  
  // Initialize operands
  uint32_t ntt_base_dilitihum_input[256];
  uint32_t ntt_base_dilitihum_output[256];


  for(uint32_t j = 0; j < 8; j++)
    {
      ntt_base_dilitihum_input = j;
    }
  
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(ntt_base_dilitihum_input), &ntt_base_dilitihum_input, kInput)); 


  // Execute OTBN programm
  uint32_t count0 = 0, count1 = 0;
  asm volatile("csrr %0, mcycle" : "=r" (count0));
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));
  asm volatile("csrr %0, mcycle" : "=r" (count1));
  otbn_count = (count1 - count0);
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, sizeof(ntt_base_dilitihum_output), kOutput, &ntt_base_dilitihum_output));
     
  // Compare results with expected output
  for(int j = 0; j < 256; j++)
    {     
      CHECK(ntt_base_dilitihum_output[j] == (ntt_base_dilitihum_input[j]));
    }

}

  
bool test_main(void)
{
  //entropy_testutils_auto_mode_init();
  
  dif_otbn_t otbn;
  CHECK_DIF_OK(dif_otbn_init(mmio_region_from_addr(TOP_EARLGREY_OTBN_BASE_ADDR), &otbn));
  test_ntt_base_dilithium(&otbn);
  return true;
}
