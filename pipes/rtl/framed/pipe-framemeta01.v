//========================================================================
// pipes/rtl/framed/pipe-framemeta01.v
//========================================================================
// Sebastian Claudiusz Magierowski May 4 2026
/*
                 _________________________
                |   pipe-framemeta01.v    |
                |                         |
                |        pipe_ctrl.v      |
                |            |            |
                |            V            |
                |+-----------------------+|
pipe-framer.v ->|| pipe-framemeta-data.v ||
                ||          A            ||
                ||          |            ||
                || pipe-framemeta-stage.v||
                |+-----------------------+|
                `_________________________'
*/

`ifndef PIPE_FRAMEMETA01_V
`define PIPE_FRAMEMETA01_V

`include "pipe-ctrl.v"
`include "pipe-framemeta-data.v"
`ifndef SYNTHESIS
`include "vc-trace.v"
`endif

module pipe_framemeta01
#(
  parameter p_num_stages      = 2,
  parameter p_frame_id_nbits  = 4,
  parameter p_beat_idx_nbits  = 8,
  parameter p_data_nbits      = 64,
  parameter p_msg_nbits       = p_frame_id_nbits + p_beat_idx_nbits + 2 + p_data_nbits
)(
  input  logic                    clk,
  input  logic                    reset,

  input  logic                    ctrl_src_val_i,
  output logic                    ctrl_src_rdy_o,
  input  logic [31:0]             ctrl_src_msg_i,

  output logic                    ctrl_snk_val_o,
  input  logic                    ctrl_snk_rdy_i,
  output logic [31:0]             ctrl_snk_msg_o,

  input  logic                    data_src_val_i,
  output logic                    data_src_rdy_o,
  input  logic [p_msg_nbits-1:0]  data_src_msg_i,

  output logic                    data_snk_val_o,
  input  logic                    data_snk_rdy_i,
  output logic [p_msg_nbits-1:0]  data_snk_msg_o
);

  logic        pipe_start;
  logic [31:0] num_inputs;
  logic        pipe_done;

  pipe_ctrl ctrl
  (
    .clk            ( clk            ),
    .reset          ( reset          ),

    .ctrl_src_val_i ( ctrl_src_val_i ),
    .ctrl_src_rdy_o ( ctrl_src_rdy_o ),
    .ctrl_src_msg_i ( ctrl_src_msg_i ),

    .ctrl_snk_val_o ( ctrl_snk_val_o ),
    .ctrl_snk_rdy_i ( ctrl_snk_rdy_i ),
    .ctrl_snk_msg_o ( ctrl_snk_msg_o ),

    .pipe_start_o   ( pipe_start     ),
    .num_inputs_o   ( num_inputs     ),
    .pipe_done_i    ( pipe_done      )
  );

  pipe_framemeta_data#(
    .p_num_stages     ( p_num_stages     ),
    .p_frame_id_nbits ( p_frame_id_nbits ),
    .p_beat_idx_nbits ( p_beat_idx_nbits ),
    .p_data_nbits     ( p_data_nbits     )
  )
  data
  (
    .clk            ( clk            ),
    .reset          ( reset          ),

    .pipe_start_i   ( pipe_start     ),
    .num_inputs_i   ( num_inputs     ),
    .pipe_done_o    ( pipe_done      ),

    .data_src_val_i ( data_src_val_i ),
    .data_src_rdy_o ( data_src_rdy_o ),
    .data_src_msg_i ( data_src_msg_i ),

    .data_snk_val_o ( data_snk_val_o ),
    .data_snk_rdy_i ( data_snk_rdy_i ),
    .data_snk_msg_o ( data_snk_msg_o )
  );

`ifndef SYNTHESIS
  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `VC_TRACE_BEGIN
  begin
    ctrl.trace( trace_str );
    vc_trace.append_str( trace_str, " " );
    data.trace( trace_str );
  end
  `VC_TRACE_END
`endif

endmodule

`endif /* PIPE_FRAMEMETA01_V */
