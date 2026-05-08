//========================================================================
// PIPES Framemetagen Unit Tests pipes/tb/framemetagen/asic.t.v
//========================================================================
// Sebastian Claudiusz Magierowski May 8 2026

`define ASIC_IMPL             pipe_framemetagen01
`define ASIC_IMPL_STR         "pipe_framemetagen01"
`ifndef ASIC_IMPL_NUM_STAGES
`define ASIC_IMPL_NUM_STAGES  2
`endif
`ifndef ASIC_FRAME_LEN
`define ASIC_FRAME_LEN        5
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
`define ASIC_DATA_SRC_MSG_NBITS `ASIC_DATA_NBITS
`ifndef ASIC_DATA_SNK_MSG_NBITS
`define ASIC_DATA_SNK_MSG_NBITS (`ASIC_FRAME_ID_NBITS+`ASIC_BEAT_IDX_NBITS+2+`ASIC_DATA_NBITS)
`endif

`include "pipe-framemetagen01.v"
`include "framemetagen-test-harness.v"

