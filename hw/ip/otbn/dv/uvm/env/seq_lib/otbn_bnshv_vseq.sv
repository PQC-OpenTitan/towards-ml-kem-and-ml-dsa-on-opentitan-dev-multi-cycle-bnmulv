/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

// A bnshv test sequence. This loads up the fixed "bnshv_test.elf" binary and forces everything to be in
// "simple" mode.

class otbn_bnshv_vseq extends otbn_single_vseq;
  `uvm_object_utils(otbn_bnshv_vseq)
  `uvm_object_new

  constraint do_backdoor_load_c { do_backdoor_load == 1'b0; }

  // Override pick_elf_path to always choose "bnshv_test.elf"
  protected function string pick_elf_path();
    // Check that cfg.otbn_elf_dir was set by the test
    `DV_CHECK_FATAL(cfg.otbn_elf_dir.len() > 0);

    return $sformatf("%0s/bnshv_test.elf", cfg.otbn_elf_dir);
  endfunction

endclass
