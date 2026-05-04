//========================================================================
// PIPES Framemeta Unit Tests pipes/tb/framemeta/asic.t.v
//========================================================================
// Sebastian Claudiusz Magierowski May 4 2026

`define ASIC_IMPL             pipe_framemeta01
`define ASIC_IMPL_STR         "pipe_framemeta01"
`ifndef ASIC_IMPL_NUM_STAGES
`define ASIC_IMPL_NUM_STAGES  2 // default to 2 stages, but can be overridden by makefile
`endif
`define ASIC_TEST_CASES_FILE  "asic-test-cases.svh"
`define ASIC_CTRL_MSG_NBITS   32
`ifndef ASIC_FRAME_ID_NBITS
`define ASIC_FRAME_ID_NBITS   4
`endif
`ifndef ASIC_BEAT_IDX_NBITS
`define ASIC_BEAT_IDX_NBITS   8
`endif
`ifndef ASIC_DATA_NBITS
`define ASIC_DATA_NBITS       64
`endif
`ifndef ASIC_DATA_MSG_NBITS
`define ASIC_DATA_MSG_NBITS   (`ASIC_FRAME_ID_NBITS+`ASIC_BEAT_IDX_NBITS+2+`ASIC_DATA_NBITS)
`endif

`include "pipe-framemeta01.v"
`include "asic-test-harness.v"
