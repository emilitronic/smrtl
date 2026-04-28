//========================================================================
// PIPES Scalar Unit Tests pipes/tb/scalar/asic.t.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 8 2026

// This file is intentionally minimal while the pipes framework is being
// organized. The top-level testbench entry will grow from here as the
// RTL and harness files are added under ../../rtl and ./.

`define ASIC_IMPL             pipe_scalar01       // ASIC module name
`define ASIC_IMPL_STR         "pipe_scalar01"     // ASIC module name string for macro digest
`ifndef ASIC_IMPL_NUM_STAGES
`define ASIC_IMPL_NUM_STAGES  2
`endif
`define ASIC_TEST_CASES_FILE  "asic-test-cases.svh"
`define ASIC_CTRL_MSG_NBITS   32
`define ASIC_DATA_MSG_NBITS   64

`include "pipe-scalar01.v"                        // ASIC module's RTL file name
`include "asic-test-harness.v"                    // ASIC test harness file name
