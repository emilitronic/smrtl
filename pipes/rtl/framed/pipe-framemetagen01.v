//========================================================================
// pipes/rtl/framed/pipe-framemetagen01.v
//========================================================================
// Sebastian Claudiusz Magierowski May 8 2026
/*
  Integrated framemeta pipe:

    ctrl_src -> pipe_ctrl ---------------------------------> ctrl_snk
                    |
                    v
    raw data -> pipe_framemeta_framer -> pipe_framemeta_data -> framemeta data

  The control program is still the simple two-word program:

    1. start word, currently 32'd0
    2. number of raw input beats to process

  The frame length is a top-level parameter for now.
*/

`ifndef PIPE_FRAMEMETAGEN01_V
`define PIPE_FRAMEMETAGEN01_V

`include "pipe-ctrl.v"
`include "pipe-framemeta-framer.v"
`include "pipe-framemeta-data.v"
`ifndef SYNTHESIS
`include "vc-trace.v"
`endif

module pipe_framemetagen01
#(
  parameter p_num_stages      = 2,
  parameter p_frame_id_nbits  = 4,
  parameter p_beat_idx_nbits  = 8,
  parameter p_data_nbits      = 64,
  parameter p_frame_len       = 5,
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
  input  logic [p_data_nbits-1:0] data_src_msg_i,

  output logic                    data_snk_val_o,
  input  logic                    data_snk_rdy_i,
  output logic [p_msg_nbits-1:0]  data_snk_msg_o
);

  logic                   pipe_start;
  logic [31:0]            num_inputs;
  logic                   pipe_done;
  logic                   framer_done;
  logic                   meta_val;
  logic                   meta_rdy;
  logic [p_msg_nbits-1:0] meta_msg;

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

  pipe_framemeta_framer#(
    .p_frame_id_nbits ( p_frame_id_nbits ),
    .p_beat_idx_nbits ( p_beat_idx_nbits ),
    .p_data_nbits     ( p_data_nbits     )
  )
  framer
  (
    .clk          ( clk                ),
    .reset        ( reset              ),

    .start_i      ( pipe_start         ),
    .num_inputs_i ( num_inputs         ),
    .frame_len_i  ( 32'( p_frame_len ) ),
    .done_o       ( framer_done        ),

    .raw_val_i    ( data_src_val_i     ),
    .raw_rdy_o    ( data_src_rdy_o     ),
    .raw_msg_i    ( data_src_msg_i     ),

    .meta_val_o   ( meta_val           ),
    .meta_rdy_i   ( meta_rdy           ),
    .meta_msg_o   ( meta_msg           )
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

    .data_src_val_i ( meta_val       ),
    .data_src_rdy_o ( meta_rdy       ),
    .data_src_msg_i ( meta_msg       ),

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
    framer.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    data.trace( trace_str );
  end
  `VC_TRACE_END
`endif

endmodule

`endif /* PIPE_FRAMEMETAGEN01_V */
