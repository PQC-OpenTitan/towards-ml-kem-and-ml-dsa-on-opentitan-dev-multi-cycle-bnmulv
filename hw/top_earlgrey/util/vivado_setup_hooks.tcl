# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
# Modified by Authors of "Towards ML-KEM & ML-DSA on OpenTitan" (https://eprint.iacr.org/2024/1192).
# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors.


# Setup hook scripts, to be called at various stages during the build process
# See Xilinx UG 894 ("Using Tcl Scripting") for documentation.

# fusesoc-generated workroot containing the Vivado project file
set workroot [pwd]

# Pre synthesize design hook
set_property STEPS.SYNTH_DESIGN.TCL.PRE "${workroot}/vivado_hook_synth_design_pre.tcl" [get_runs synth_1]

# Implementation Strategy
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

# Pre implementation (init design) post hook
set_property STEPS.INIT_DESIGN.TCL.POST "${workroot}/vivado_hook_init_design_post.tcl" [get_runs impl_1]

# Post opt design hook
set_property STEPS.OPT_DESIGN.TCL.POST "${workroot}/vivado_hook_opt_design_post.tcl" [get_runs impl_1]

# TODO: This hook is not getting called by Vivado when running through our
# fusesoc flow (it gets called when writing a bitstream through the GUI).
# Requires an update to edalize, see https://github.com/olofk/edalize/pull/60.
#set_property STEPS.WRITE_BITSTREAM.TCL.PRE "${workroot}/vivado_hook_write_bitstream_pre.tcl" [get_runs impl_1]

# As workaround, we use the post route design hook, which gets called.
set_property STEPS.ROUTE_DESIGN.TCL.POST "${workroot}/vivado_hook_write_bitstream_pre.tcl" [get_runs impl_1]
