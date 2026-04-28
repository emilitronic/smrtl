//========================================================================
// pipes/rtl/framed/pipe-framed01.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 18 2026
/*
                 _______________________
                |    pipe-framed01.v    |
                |                       |
                |      pipe_ctrl.v      |
                |          |            |
                |          V            |
                |+---------------------+|
pipe-framer.v ->|| pipe-framed-data.v  ||
                ||        A            ||
                ||        |            ||
                || pipe-framed-stage.v || 
                |'_____________________'|    
                `_______________________'
*/
`ifndef PIPE_FRAMED01_V
`define PIPE_FRAMED01_V

`include "pipe-ctrl.v"
`include "pipe-framed-data.v"
`ifndef SYNTHESIS
`include "vc-trace.v"
`endif

module pipe_framed01
#(
  parameter p_num_stages = 2,
  parameter p_data_nbits = 64
)(
  input  logic                       clk,
  input  logic                       reset,

  input  logic                       ctrl_src_val_i,
  output logic                       ctrl_src_rdy_o,
  input  logic [31:0]                ctrl_src_msg_i,

  output logic                       ctrl_snk_val_o,
  input  logic                       ctrl_snk_rdy_i,
  output logic [31:0]                ctrl_snk_msg_o,

  input  logic                       data_src_val_i,
  output logic                       data_src_rdy_o,
  input  logic [p_data_nbits+1:0]    data_src_msg_i,

  output logic                       data_snk_val_o,
  input  logic                       data_snk_rdy_i,
  output logic [p_data_nbits+1:0]    data_snk_msg_o
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

  pipe_framed_data#(
    .p_num_stages ( p_num_stages ),
    .p_data_nbits ( p_data_nbits )
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

`endif /* PIPE_FRAMED01_V */
