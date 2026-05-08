//========================================================================
// PIPES Framegen Unit Tests pipes/tb/framegen/asic.t.v
//========================================================================
// Sebastian Claudiusz Magierowski May 8 2026

`define ASIC_IMPL             pipe_framegen01
`define ASIC_IMPL_STR         "pipe_framegen01"
`ifndef ASIC_IMPL_NUM_STAGES
`define ASIC_IMPL_NUM_STAGES  2
`endif
`ifndef ASIC_FRAME_LEN
`define ASIC_FRAME_LEN        5
`endif
`define ASIC_TEST_CASES_FILE       "asic-test-cases.svh"
`define ASIC_CTRL_MSG_NBITS        32
`define ASIC_DATA_SRC_MSG_NBITS    64
`define ASIC_DATA_SNK_MSG_NBITS    66

`include "pipe-framegen01.v"
`include "framegen-test-harness.v"

