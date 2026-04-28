//========================================================================
// PIPES Framed Unit Tests pipes/tb/framed/asic.t.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 18 2026

`define ASIC_IMPL             pipe_framed01
`define ASIC_IMPL_STR         "pipe_framed01"
`ifndef ASIC_IMPL_NUM_STAGES
`define ASIC_IMPL_NUM_STAGES  2 // default to 2 stages, but can be overridden by makefile
`endif
`define ASIC_TEST_CASES_FILE  "asic-test-cases.svh"
`define ASIC_CTRL_MSG_NBITS   32
`define ASIC_DATA_MSG_NBITS   66

`include "pipe-framed01.v"
`include "asic-test-harness.v"
