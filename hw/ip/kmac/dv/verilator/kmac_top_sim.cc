// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Modified by Authors of "Towards ML-KEM & ML-DSA on OpenTitan" (https://eprint.iacr.org/2024/1192)
// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
//
#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include "verilated_fst_c.h"
#include "Vkmac_top_sim.h"
#include "fips202.h"
#include "testcases.h"

#define MAX_SIM_TIME 100000
vluint64_t sim_time = 0;

#define KMAC_DIGEST_REG_BYTES 32


void tick(Vkmac_top_sim *dut, VerilatedFstC *trace) {
  dut->clk_i ^= 1;
  dut->eval();
  trace->dump(sim_time);
  sim_time++;
  dut->clk_i ^= 1;
  dut->eval();
  trace->dump(sim_time);
  sim_time++;
}

void initial_reset(Vkmac_top_sim *dut, VerilatedFstC *trace) {
  dut->clk_i  = 0;
  dut->rst_ni = 0;
  for (int i=0; i<10; ++i) {
    tick(dut, trace);
  }
  dut->rst_ni = 1;
  tick(dut, trace);
}

void wait_until_kmac_app_iface_ready(Vkmac_top_sim *dut, VerilatedFstC *trace) {
  while (dut->app_rsp_ready_o == 0) {
    tick(dut, trace);
    if (sim_time > MAX_SIM_TIME) {
      break;
    }
  }
}

void wait_until_kmac_digest_ready(Vkmac_top_sim *dut, VerilatedFstC *trace) {
  while (dut->app_rsp_done_o == 0) {
    tick(dut, trace);
    if (sim_time > MAX_SIM_TIME) {
      break;
    }
  }
}

void request_next_kmac_digest(Vkmac_top_sim *dut, VerilatedFstC *trace) {
  dut->app_req_next_i = 1;
  tick(dut, trace);
  dut->app_req_next_i = 0;
  tick(dut, trace);
}

void release_app_iface(Vkmac_top_sim *dut, VerilatedFstC *trace) {
  dut->app_req_hold_i = 0;
  dut->app_req_next_i = 0;
  dut->app_req_valid_i = 0;
  dut->app_req_strb_i = 0x0;
  tick(dut, trace);
}

void config_app_iface(Vkmac_top_sim *dut, VerilatedFstC * trace, uint8_t mode) {
  if (  mode != APP_MODE_SHA3_256 &&
        mode != APP_MODE_SHA3_512 &&
        mode != APP_MODE_SHAKE128 &&
        mode != APP_MODE_SHAKE256 ) {
    printf("Invalid config value: %x\n", mode);
    return;
  }
  dut->app_req_valid_i = 1;
  dut->app_req_hold_i = 1;
  dut->app_req_next_i = 0;
  dut->app_req_data_i = (uint64_t) mode;
  dut->app_req_strb_i = 0xFF;
  tick(dut, trace);
  wait_until_kmac_app_iface_ready(dut, trace);
}

int check_digests(uint8_t *out, uint8_t *ref, size_t len) {
  for (int i = 0; i < len; i++) {
    if (out[i] != ref[i]) {
      printf("Missmatch: ref[%i] = %x | out[%i] = %x\n", i, ref[i], i, out[i]);
      return -1;
    }
  }
  return 0;
}

void write_data_to_app_iface(Vkmac_top_sim *dut, VerilatedFstC *trace, uint8_t* data, int n_bytes) {
  int n_words = n_bytes / 8;
  int n_residual_bytes = n_bytes - (n_words * 8);
  uint64_t msgword;

  for (int i = 0; i < n_words; i++) {
    msgword = 0;
    for (int j = 0; j < 8; j++) {
      msgword = (msgword << 8) | data[8 * (i + 1) - j - 1];
    }
    dut->app_req_valid_i = 1;
    dut->app_req_hold_i  = 1;
    dut->app_req_data_i  = msgword;
    dut->app_req_strb_i  = 0xFF;
    if (n_residual_bytes == 0 && i == (n_words - 1)) {
      dut->app_req_last_i = 1;
    } else {
      dut->app_req_last_i = 0;
    }
    tick(dut, trace);
    wait_until_kmac_app_iface_ready(dut, trace);
  }

  if (n_residual_bytes != 0) {
    dut->app_req_valid_i = 1;
    msgword = 0;
    for (int j = n_residual_bytes - 1; j >= 0; j--) {
      msgword = (msgword << 8) | data[8 * n_words + j];
    }
    dut->app_req_data_i = msgword;
    dut->app_req_strb_i = (1 << n_residual_bytes) - 1;
    dut->app_req_last_i = 1;
    tick(dut, trace);
  }
  
}

int get_rate(uint8_t mode) {
  switch (mode) {
    case APP_MODE_SHA3_256:
      return SHA3_256_RATE;
    case APP_MODE_SHA3_512:
      return SHA3_512_RATE;
    case APP_MODE_SHAKE128:
      return SHAKE128_RATE;
    case APP_MODE_SHAKE256:
      return SHAKE256_RATE;
    default:
      return -1;
  }
}

void get_kmac_digest(Vkmac_top_sim *dut, uint8_t* digest) {
  int word_idx = 0;
  int byte_idx = 0;
  for (int i = 0; i < KMAC_DIGEST_REG_BYTES; i++) {
    word_idx = i / 4;
    byte_idx = i % 4;
    digest[i] = ((dut->app_rsp_digest_share0_o[word_idx] ^ dut->app_rsp_digest_share1_o[word_idx]) >> (8*byte_idx)) & 0xFF;
  }
}

void read_digest(Vkmac_top_sim *dut, VerilatedFstC *trace, uint8_t mode, uint8_t* out, size_t outlen) {
  int rate = get_rate(mode);
  int n_reads = ((outlen + rate - 1) / rate) * ((rate + KMAC_DIGEST_REG_BYTES - 1) / KMAC_DIGEST_REG_BYTES);
  uint8_t kmac_digest_reg[KMAC_DIGEST_REG_BYTES];
  int n_bytes = 0;
  int bytes_read = 0;
  int current_rate = 0;
  
  for (int i = 0; i < n_reads; i++) {
    wait_until_kmac_digest_ready(dut, trace);
    get_kmac_digest(dut, kmac_digest_reg);
    n_bytes = rate - current_rate;
    if (n_bytes > KMAC_DIGEST_REG_BYTES) {
      n_bytes = KMAC_DIGEST_REG_BYTES;
    }
    if (bytes_read + n_bytes > outlen) {
      n_bytes = outlen - bytes_read;
    }
    memcpy(out + bytes_read, kmac_digest_reg, n_bytes);
    bytes_read += n_bytes;
    current_rate += n_bytes;
    if (bytes_read < outlen) {
      request_next_kmac_digest(dut, trace);
    } else {
      break;
    }
    if (current_rate == rate) {
      current_rate = 0;
    }
  }
}

void get_reference_digest(uint8_t mode, uint8_t* data_in, size_t inlen, uint8_t* data_out, size_t outlen) {
  switch (mode) {
    case APP_MODE_SHA3_256:
      sha3_256(data_out, data_in, inlen);
      break;
    case APP_MODE_SHA3_512:
      sha3_512(data_out, data_in, inlen);
      break;
    case APP_MODE_SHAKE128:
      shake128(data_out, outlen, data_in, inlen);
      break;
    case APP_MODE_SHAKE256:
      shake256(data_out, outlen, data_in, inlen);
      break;
    default:
      printf("Invalid mode for reference digest: %x\n", mode);
      break;
  }
}

int main(int argc, char **argv) {
  Vkmac_top_sim *dut = new Vkmac_top_sim;
  VerilatedFstC *trace = new VerilatedFstC;

  Verilated::traceEverOn(true);
  dut->trace(trace, 99, 0);
  trace->open("sim.fst");

  initial_reset(dut, trace);
  tick(dut, trace);

  for (int testidx = 0; testidx < N_TESTS; ++testidx) {
    config_app_iface(dut, trace, KMAC_TESTCASES[testidx].mode);
    write_data_to_app_iface(dut, trace, KMAC_TESTCASES[testidx].data_in, KMAC_TESTCASES[testidx].inlen);
    tick(dut, trace);
    uint8_t out_ref[KMAC_TESTCASES[testidx].outlen];
    uint8_t out[KMAC_TESTCASES[testidx].outlen];
    read_digest(dut, trace, KMAC_TESTCASES[testidx].mode, out, KMAC_TESTCASES[testidx].outlen);
    get_reference_digest(KMAC_TESTCASES[testidx].mode, KMAC_TESTCASES[testidx].data_in, KMAC_TESTCASES[testidx].inlen, out_ref, KMAC_TESTCASES[testidx].outlen);
    if (check_digests(out, out_ref, KMAC_TESTCASES[testidx].outlen) != 0) {
      printf("Testcase %i - FAIL\n", testidx);
    } else {
      printf("Testcase %i - PASS\n", testidx);
    }
    release_app_iface(dut, trace);
  }

  trace->close();
  return 0;
}
