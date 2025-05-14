// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/dif/dif_otbn.h"
#include "sw/device/lib/testing/entropy_testutils.h"
#include "sw/device/lib/testing/otbn_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

enum {
  /**
   * Data width of big number subset, in bytes.
   */
  kOtbnWlenBytes = 256 / 8,
};

OTTF_DEFINE_TEST_CONFIG();


// Testcase for bn.addv and bn.subv
OTBN_DECLARE_APP_SYMBOLS(bnaddv_test);
OTBN_DECLARE_SYMBOL_ADDR(bnaddv_test, operand1);
static const otbn_app_t kAppBnAddVTest = OTBN_APP_T_INIT(bnaddv_test);
static const otbn_addr_t KBnAddVOperands = OTBN_ADDR_T_INIT(bnaddv_test, operand1);

// Testcase for bn.addvm and bn.subvm
OTBN_DECLARE_APP_SYMBOLS(bnaddvm_test);
OTBN_DECLARE_SYMBOL_ADDR(bnaddvm_test, operand1);
static const otbn_app_t kAppBnAddVMTest = OTBN_APP_T_INIT(bnaddvm_test);
static const otbn_addr_t KBnAddVMOperands = OTBN_ADDR_T_INIT(bnaddvm_test, operand1);

// Testcase for bn.mulv
OTBN_DECLARE_APP_SYMBOLS(bnmulv_test);
OTBN_DECLARE_SYMBOL_ADDR(bnmulv_test, operand1);
static const otbn_app_t kAppBnMulVTest = OTBN_APP_T_INIT(bnmulv_test);
static const otbn_addr_t KBnMulVOperands = OTBN_ADDR_T_INIT(bnmulv_test, operand1);

// Testcase for bn.mulv.l
OTBN_DECLARE_APP_SYMBOLS(bnmulvl_test);
OTBN_DECLARE_SYMBOL_ADDR(bnmulvl_test, operand1);
static const otbn_app_t kAppBnMulVLTest = OTBN_APP_T_INIT(bnmulvl_test);
static const otbn_addr_t KBnMulVLOperands = OTBN_ADDR_T_INIT(bnmulvl_test, operand1);

// Testcase for bn.mulvm
OTBN_DECLARE_APP_SYMBOLS(bnmulvm_test);
OTBN_DECLARE_SYMBOL_ADDR(bnmulvm_test, operand1);
static const otbn_app_t kAppBnMulVMTest = OTBN_APP_T_INIT(bnmulvm_test);
static const otbn_addr_t KBnMulVMOperands = OTBN_ADDR_T_INIT(bnmulvm_test, operand1);

// Testcase for bn.mulvm.l
OTBN_DECLARE_APP_SYMBOLS(bnmulvml_test);
OTBN_DECLARE_SYMBOL_ADDR(bnmulvml_test, operand1);
static const otbn_app_t kAppBnMulVMLTest = OTBN_APP_T_INIT(bnmulvml_test);
static const otbn_addr_t KBnMulVMLOperands = OTBN_ADDR_T_INIT(bnmulvml_test, operand1);

// Testvectors
static const uint32_t kExpectedBnAddV[] = {
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0,
    0x2, 
    0x4, 
    0x6, 
    0x8, 
    0xa, 
    0xc, 
    0xe, 
    0x10, 
    0xfffffffe, 
    0xfffffffd, 
    0xfffffffc, 
    0xfffffffb, 
    0xfffffffa, 
    0xfffffff9, 
    0xfffffff8, 
    0xfffffff7, 
    0x0, 
    0x1, 
    0x2, 
    0x3, 
    0x4, 
    0x5, 
    0x6, 
    0x7, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0,
    0x00040002, 
    0x00080006, 
    0x000c000a, 
    0x0010000e, 
    0x00140012, 
    0x00180016, 
    0x001c001a, 
    0x0020001e,
    0xfffdfffe, 
    0xfffbfffc, 
    0xfff9fffa, 
    0xfff7fff8, 
    0xfff5fff6, 
    0xfff3fff4, 
    0xfff1fff2, 
    0xffeffff0, 
    0x00010000, 
    0x00030002, 
    0x00050004, 
    0x00070006, 
    0x00090008, 
    0x000b000a, 
    0x000d000c, 
    0x000f000e
};

static const uint32_t kExpectedBnAddVM[] = {
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000002,  
    0x00000004,  
    0x00000006,  
    0x00000008,  
    0x0000000A,  
    0x0000000C,  
    0x0000000E,  
    0x00000010,  
    0x007FDFFF,  
    0x007FDFFE,  
    0x007FDFFD,  
    0x007FDFFC,  
    0x007FDFFB,  
    0x007FDFFA,  
    0x007FDFF9,  
    0x007FDFF8,  
    0x00000000,  
    0x00000001,  
    0x00000002,  
    0x00000003,  
    0x00000004,  
    0x00000005,  
    0x00000006,  
    0x00000007,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00040002,  
    0x00080006,  
    0x000c000a,  
    0x0010000e,  
    0x00140012,  
    0x00180016,  
    0x001c001a,  
    0x0020001e,  
    0x0CFE0CFF,  
    0x0CFC0CFD,  
    0x0CFA0CFB,  
    0x0CF80CF9,  
    0x0CF60CF7,  
    0x0CF40CF5,  
    0x0CF20CF3,  
    0x0CF00CF1,  
    0x00010000,  
    0x00030002,  
    0x00050004,  
    0x00070006,  
    0x00090008,  
    0x000b000a,  
    0x000d000c,  
    0x000f000e   
};

static const uint32_t kOperandsBnAddV[] = {
    0x00000001, 
    0x00000002,
    0x00000003, 
    0x00000004,
    0x00000005, 
    0x00000006,
    0x00000007, 
    0x00000008,
    0x00000001, 
    0x00000002,
    0x00000003, 
    0x00000004,
    0x00000005, 
    0x00000006,
    0x00000007, 
    0x00000008,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007,
    0x000a0009, 
    0x000c000b, 
    0x000e000d, 
    0x0010000f, 
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000a0009, 
    0x000c000b, 
    0x000e000d, 
    0x0010000f,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
};

static const uint32_t kOperandsBnAddVM[] = {
    0x00000001, 
    0x00000002,
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008, 
    0x00000001, 
    0x00000002, 
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008,     
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000a0009, 
    0x000c000b, 
    0x000e000d, 
    0x0010000f, 
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000a0009, 
    0x000c000b, 
    0x000e000d, 
    0x0010000f, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
};

static const uint32_t kOperandsBnMulV[] = {
    0x00000001, 
    0x00000002, 
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008,     
    0x007fe000, 
    0x00000002, 
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008,     
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000A0009, 
    0x000C000B, 
    0x000E000D, 
    0x0010000F,     
    0x0D000D00, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000A0009, 
    0x000C000B, 
    0x000E000D, 
    0x0010000F, 
};

static const uint32_t kOperandsBnMulVL[] = {
    0x00000001, 
    0x00000002, 
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008,    
    0x007fe000, 
    0x00000002, 
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008, 
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000A0009, 
    0x000C000B, 
    0x000E000D, 
    0x0010000F,     
    0x0D000D00, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000A0009, 
    0x000C000B, 
    0x000E000D, 
    0x0010000F, 
};

static const uint32_t kOperandsBnMulVM[] = {
    0x00000001, 
    0x00000002, 
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008,     
    0x007fe000, 
    0x00000002, 
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008, 
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000A0009, 
    0x000C000B, 
    0x000E000D, 
    0x0010000F,     
    0x0D000D00, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000A0009, 
    0x000C000B, 
    0x000E000D, 
    0x0010000F, 
};

static const uint32_t kOperandsBnMulVML[] = {
    0x00000001, 
    0x00000002, 
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008,     
    0x007fe000, 
    0x00000002, 
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008,     
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000A0009, 
    0x000C000B, 
    0x000E000D, 
    0x0010000F,     
    0x0D000D00, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000A0009, 
    0x000C000B, 
    0x000E000D, 
    0x0010000F, 
};

// Reference montgomery multiplication
uint32_t montgomery_multiplication(uint32_t op0_i, uint32_t op1_i, uint32_t q_dash_i, uint32_t q_i, uint32_t LOG_R, uint32_t DATA_WIDTH) {
    uint64_t p;                // Use a wider type to avoid overflow
    uint64_t m;
    uint64_t s;
    uint64_t t;
    uint32_t result = 0;      // Initialize result

    if (DATA_WIDTH == 16) {
        // Process each 16-bit chunk separately
        for (int i = 0; i < 2; i++) {
            // Extract the lower 16 bits and the upper 16 bits
            uint32_t op0_chunk = (op0_i >> (16 * i)) & 0xFFFF;
            uint32_t op1_chunk = (op1_i >> (16 * i)) & 0xFFFF;
            // Compute p for the chunk
            p = (uint64_t)op0_chunk * (uint64_t)op1_chunk;
            // Compute m = p[LOG_R-1:0] * q_dash_i
            m = (p & ((1ULL << LOG_R) - 1)) * q_dash_i; // Extract lower LOG_R bits
            // Compute s = p + (m[LOG_R-1:0] * q_i)
            s = (uint32_t)p + (uint32_t)((m & ((1ULL << LOG_R) - 1)) * q_i); // Extract lower LOG_R bits from m
            // Compute t = s[LOG_R+DATA_WIDTH:LOG_R]
            t = (s >> LOG_R) & ((1U << DATA_WIDTH) - 1); // Shift right by LOG_R and mask
            // If q_i <= t, then t = t - q_i
            if (q_i <= t) {
                t = t - q_i;
            }
            // Combine the results for each chunk
            result |= (t & 0xFFFF) << (16 * i); // Store the result for each chunk
        }
        return result;
    } else {
        // Compute p = op0_i * op1_i
        p = (uint64_t)op0_i * (uint64_t)op1_i;
        // Compute m = p[LOG_R-1:0] * q_dash_i
        m = (p & 0xFFFFFFFF) * q_dash_i; // Extract lower LOG_R bits
        // Compute s = p + (m[LOG_R-1:0] * q_i)
        s = p + (m & 0xFFFFFFFF) * q_i; // Extract lower LOG_R bits from m
        // Compute t = s[LOG_R+DATA_WIDTH:LOG_R]
        t = (s >> LOG_R); // Shift right by LOG_R and mask
        // If q_i <= t, then t = t - q_i
        if (q_i <= t) {
          result = (uint32_t)(t - q_i) & 0xFFFFFFFF;
        } else {
          result = (uint32_t)t & 0xFFFFFFFF;
        }
        // Return the final result
        return result; // Assuming you want to return the final value in result
    }
}

// Helper function for lanewise modular multiplication
uint32_t getOpL16h(uint32_t op, int i) {
    uint32_t value = op;
    uint32_t lower16 = value & 0x0000FFFF;      // Extract lower 16 bits
    uint32_t higher16 = (value >> 16) & 0x0000FFFF; // Extract higher 16 bits

    if (i % 2 == 0) {
        // Even: concatenate lower 16 bits with the next lower 16 bits
        return (lower16 << 16) | lower16;
    } else {
        // Odd: concatenate higher 16 bits with the next higher 16 bits
        return (higher16 << 16) | higher16;
    }
}

// Testcase for bn.addv and bn.subv
bool test_bnaddv(dif_otbn_t *otbn){
  // Load the Smoke Test App
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppBnAddVTest));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(kOperandsBnAddV), &kOperandsBnAddV, KBnAddVOperands)); 
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  for (uint32_t i = 0; i < 32*8; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, (512) + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      CHECK(data[j] == kExpectedBnAddV[j+(i/kOtbnWlenBytes*8)]);
      if(data[j] == kExpectedBnAddV[j+(i/kOtbnWlenBytes*8)]){

      }
      else{
        LOG_INFO("Data: 0x%08x | Exp[%d]: 0x%08x",data[j],j+(i/kOtbnWlenBytes)*8,kExpectedBnAddV[j+(i/kOtbnWlenBytes)*8]);
        return false;
      }
    }
  }
  return true;
}

// Testcase for bn.addvm and bn.subvm
bool test_bnaddvm(dif_otbn_t *otbn){
  // Load the Smoke Test App
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppBnAddVMTest));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(kOperandsBnAddVM), &kOperandsBnAddVM, KBnAddVMOperands)); 
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  for (uint32_t i = 0; i < 32*8; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, (512) + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      CHECK(data[j] == kExpectedBnAddVM[j+(i/kOtbnWlenBytes*8)]);
      if(data[j] == kExpectedBnAddVM[j+(i/kOtbnWlenBytes*8)]){

      }
      else{
        LOG_INFO("Data: 0x%08x | Exp[%d]: 0x%08x",data[j],j+(i/kOtbnWlenBytes)*8,kExpectedBnAddVM[j+(i/kOtbnWlenBytes)*8]);
        return false;
      }
    }
  }
  return true;
}

// Testcase for bn.mulv
bool test_bnmulv(dif_otbn_t *otbn){
  // Load the Smoke Test App
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppBnMulVTest));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(kOperandsBnMulV), &kOperandsBnMulV, KBnMulVOperands)); 
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));
  
  uint32_t result[8];

  for (uint32_t i = 0; i < 32*1; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, (512) + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      result[j] = (uint32_t)(((uint64_t)kOperandsBnMulV[0+j] * (uint64_t)kOperandsBnMulV[8+j]) & 0xFFFFFFFF);
      CHECK(data[j] == result[j]);
      if(data[j] == result[j]){
      }
      else{
        LOG_INFO("Data: 0x%08x | Exp[%d]: 0x%08x",data[j],j+(i/kOtbnWlenBytes)*8,result[j]);
        CHECK(data[j] == result[j]);
        return false;
      }
    }
  }
  for (uint32_t i = 0; i < 32*1; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, (544) + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {

      result[j] = (((kOperandsBnMulV[16+j] & 0xFFFF) * (kOperandsBnMulV[24+j] & 0xFFFF)) & 0xFFFF) | ((((kOperandsBnMulV[16+j] & 0xFFFF0000) >> 16) * ((kOperandsBnMulV[24+j] & 0xFFFF0000) >> 16) & 0xFFFF) << 16);
      CHECK((data[j] == result[j]));
      if(data[j] == result[j]){

      }
      else{
        LOG_INFO("Data: 0x%08x | Exp[%d]: 0x%08x",data[j],j+(i/kOtbnWlenBytes)*8,result[j]);
        CHECK((data[j] == result[j]));
        return false;
      }
    }
  }
  return true;
}

// Testcase for bn.mulv.l
bool test_bnmulvl(dif_otbn_t *otbn){
  // Load the Smoke Test App
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppBnMulVLTest));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(kOperandsBnMulVL), &kOperandsBnMulVL, KBnMulVLOperands)); 
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));
  
  uint32_t result[8];
  uint32_t op16h;
  int idx;
  for (uint32_t i = 0; i < 32*8; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, (512) + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      result[j] = (uint32_t)(((uint64_t)kOperandsBnMulVL[0+j] * (uint64_t)kOperandsBnMulVL[8+(i/kOtbnWlenBytes)]) & 0xFFFFFFFF);
      CHECK(data[j] == result[j]);
      if(data[j] == result[j]){

      }
      else{
        LOG_INFO("Data: 0x%08x | Exp[%d]: 0x%08x",data[j],(i/kOtbnWlenBytes),result[j]);
        CHECK(data[j] == result[j]);
        return false;
      }
    }
  }
  for (uint32_t i = 0; i < 32*16; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, (768) + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      idx = (i/kOtbnWlenBytes)/2;
      op16h = getOpL16h(kOperandsBnMulVL[24+idx],(i/kOtbnWlenBytes));
      result[j] = (((kOperandsBnMulVL[16+j] & 0xFFFF) * (op16h & 0xFFFF)) & 0xFFFF) | ((((kOperandsBnMulVL[16+j] & 0xFFFF0000) >> 16) * ((op16h & 0xFFFF0000) >> 16) & 0xFFFF) << 16);
      CHECK((data[j] == result[j]));
      if(data[j] == result[j]){

      }
      else{
        LOG_INFO("Data: 0x%08x | Exp[%d]: 0x%08x",data[j],j+(i/kOtbnWlenBytes)*8,result[j]);
        return false;
      }
    }
  }
  return true;
}

// Testcase for bn.mulvm
bool test_bnmulvm(dif_otbn_t *otbn){
  // Load the Smoke Test App
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppBnMulVMTest));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(kOperandsBnMulVM), &kOperandsBnMulVM, KBnMulVMOperands)); 
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));
  
  uint32_t result[8];

  for (uint32_t i = 0; i < 32*1; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, (512) + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      result[j] = montgomery_multiplication(kOperandsBnMulVM[0+j], kOperandsBnMulVM[8+j], 4236238847, 8380417, 32, 32);
      CHECK(data[j] == result[j]);
      if(data[j] == result[j]){

      }
      else{
        LOG_INFO("Data: 0x%08x | Exp[%d]: 0x%08x",data[j],j+(i/kOtbnWlenBytes)*8,result[j]);
        CHECK(data[j] == result[j]);
        return false;
      }
    }
  }
  for (uint32_t i = 0; i < 32*1; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, (544) + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      result[j] = montgomery_multiplication(kOperandsBnMulVM[16+j], kOperandsBnMulVM[24+j], 3327, 3329, 16, 16);
      CHECK((data[j] == result[j]));
      if(data[j] == result[j]){}
      else{
        LOG_INFO("Data: 0x%08x | Exp[%d]: 0x%08x",data[j],j+(i/kOtbnWlenBytes)*8,result[j]);
        CHECK((data[j] == result[j]));
        return false;
      }
    }
  }
  return true;
}

// Testcase for bn.mulvm.l
bool test_bnmulvml(dif_otbn_t *otbn){
  // Load the Smoke Test App
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppBnMulVMLTest));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(kOperandsBnMulVML), &kOperandsBnMulVML, KBnMulVMLOperands)); 
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));
  
  uint32_t result[8];
  uint32_t op16h;
  int idx;
  for (uint32_t i = 0; i < 32*8; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, (512) + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      result[j] = montgomery_multiplication(kOperandsBnMulVML[0+j], kOperandsBnMulVML[8+(i/kOtbnWlenBytes)], 4236238847, 8380417, 32, 32);
      CHECK(data[j] == result[j]);
      if(data[j] == result[j]){

      }
      else{
        LOG_INFO("Data: 0x%08x | Exp[%d]: 0x%08x",data[j],(i/kOtbnWlenBytes),result[j]);
        CHECK(data[j] == result[j]);
        return false;
      }
    }
  }
  for (uint32_t i = 0; i < 32*16; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, (768) + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      idx = (i/kOtbnWlenBytes)/2;
      op16h = getOpL16h(kOperandsBnMulVML[24+idx],(i/kOtbnWlenBytes));
      result[j] = montgomery_multiplication(kOperandsBnMulVML[16+j], op16h, 3327, 3329, 16, 16);
      CHECK((data[j] == result[j]));
      if(data[j] == result[j]){

      }
      else{
        LOG_INFO("Data: 0x%08x | Exp[%d]: 0x%08x",data[j],j+(i/kOtbnWlenBytes)*8,result[j]);
        return false;
      }
    }
  }
  return true;
}

bool test_main(void) {
  // Initialise the entropy source and OTBN
  dif_otbn_t otbn;
  CHECK_STATUS_OK(entropy_testutils_auto_mode_init());
  CHECK_DIF_OK(
      dif_otbn_init(mmio_region_from_addr(TOP_EARLGREY_OTBN_BASE_ADDR), &otbn));

  // Test bn.addv and bn.subv
  test_bnaddv(&otbn);

  // Test bn.addvm and bn.subvm
  test_bnaddvm(&otbn);

  // Test bn.mulv
  test_bnmulv(&otbn);

  // Test bn.mulv.l
  test_bnmulvl(&otbn);

  // Test bn.mulvm
  test_bnmulvm(&otbn);

  // Test bn.mulvm.l
  test_bnmulvml(&otbn);

  return true;
}
