//========================================================================
// PIPES Unit Tests pipes/tb/asic.t.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 8 2026

// This file is intentionally minimal while the pipes framework is being
// organized. The top-level testbench entry will grow from here as the
// RTL and harness files are added under ../rtl and ./.

`define ASIC_IMPL             pipe1                  // ASIC module name
`define ASIC_IMPL_STR         "pipe1"                // ASIC module name string for macro digest
`define ASIC_TEST_CASES_FILE  "asic-test-cases.v"

`include "pipe.v"                                    // ASIC module's RTL file name
`include "asic-test-harness.v"                       // ASIC test harness file name