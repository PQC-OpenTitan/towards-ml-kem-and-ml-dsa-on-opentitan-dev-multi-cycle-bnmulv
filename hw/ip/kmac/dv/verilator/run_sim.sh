#!/bin/bash
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
# Modified by Authors of "Towards ML-KEM & ML-DSA on OpenTitan" (https://eprint.iacr.org/2024/1192).
# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors.


echo "## Building Model ##"
cd $REPO_TOP
fusesoc --cores-root $REPO_TOP run --flag=fileset_top --target=sim --no-export --setup lowrisc:ip:kmac_top_sim:0.1
make -C $REPO_TOP/build/lowrisc_ip_kmac_top_sim_0.1/sim-verilator
echo "## Running Model ##"
$REPO_TOP/build/lowrisc_ip_kmac_top_sim_0.1/sim-verilator/Vkmac_top_sim
echo "Copy Waveform to /tmp"
mv sim.fst /tmp
echo "## Done ##"

