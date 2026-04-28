//========================================================================
// pipes/rtl/framed/pipe-framemeta-data.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 28 2026
/*
  This is a framemeta analogue of pipe_data. It chains pipe_framemeta_stage
  instances together and uses the same retirement-based done rule as the
  scalar and framebits datapaths.

  Message contract:
    - data_src_msg_i / data_snk_msg_o are packed as
      { frame_id, beat_idx, first, last, data }
*/

`ifndef PIPE_FRAMEMETA_DATA_V
`define PIPE_FRAMEMETA_DATA_V

`include "pipe-framemeta-stage.v"
`ifndef SYNTHESIS
`include "vc-trace.v"
`endif

module pipe_framemeta_data
#(
  parameter p_num_stages      = 2,
  parameter p_frame_id_nbits  = 4,
  parameter p_beat_idx_nbits  = 8,
  parameter p_data_nbits      = 64,
  parameter p_msg_nbits       = p_frame_id_nbits + p_beat_idx_nbits + 2 + p_data_nbits
)(
  input  logic                    clk,
  input  logic                    reset,

  input  logic                    pipe_start_i,
  input  logic [31:0]             num_inputs_i,
  output logic                    pipe_done_o,

  input  logic                    data_src_val_i,
  output logic                    data_src_rdy_o,
  input  logic [p_msg_nbits-1:0]  data_src_msg_i,

  output logic                    data_snk_val_o,
  input  logic                    data_snk_rdy_i,
  output logic [p_msg_nbits-1:0]  data_snk_msg_o
);

  localparam [31:0] c_num_stages = p_num_stages;

  logic                    running_reg;
  logic [31:0]             retired_outputs_reg;
  logic                    data_go;
  logic [p_msg_nbits-1:0]  stage_msg [0:p_num_stages];
  logic                    stage_val [0:p_num_stages];
  logic                    stage_rdy [0:p_num_stages];

  assign stage_val[0]            = running_reg && data_src_val_i;
  assign stage_msg[0]            = data_src_msg_i;
  assign data_go                 = data_snk_val_o && data_snk_rdy_i;
  assign data_src_rdy_o          = running_reg && stage_rdy[0];
  assign data_snk_val_o          = stage_val[p_num_stages];
  assign data_snk_msg_o          = stage_msg[p_num_stages];
  assign pipe_done_o             = running_reg && data_go && ( retired_outputs_reg + 32'd1 == num_inputs_i );
  assign stage_rdy[p_num_stages] = data_snk_rdy_i;

  genvar s;
  generate
    for ( s = 0; s < p_num_stages; s = s + 1 ) begin : STAGE
      pipe_framemeta_stage#(
        .p_frame_id_nbits ( p_frame_id_nbits ),
        .p_beat_idx_nbits ( p_beat_idx_nbits ),
        .p_data_nbits     ( p_data_nbits     ),
        .p_addend         ( 64'd1            )
      )
      stage
      (
        .clk       ( clk            ),
        .reset     ( reset          ),
        .in_val_i  ( stage_val[s]   ),
        .in_rdy_o  ( stage_rdy[s]   ),
        .in_msg_i  ( stage_msg[s]   ),
        .out_val_o ( stage_val[s+1] ),
        .out_rdy_i ( stage_rdy[s+1] ),
        .out_msg_o ( stage_msg[s+1] )
      );
    end
  endgenerate

  always @( posedge clk ) begin
    if ( reset ) begin
      running_reg         <= 1'b0;
      retired_outputs_reg <= 32'b0;
    end
    else begin
      if ( pipe_start_i ) begin
        running_reg         <= 1'b1;
        retired_outputs_reg <= 32'b0;
      end
      else if ( pipe_done_o ) begin
        running_reg         <= 1'b0;
        retired_outputs_reg <= retired_outputs_reg + 32'd1;
      end
      else if ( data_go ) begin
        retired_outputs_reg <= retired_outputs_reg + 32'd1;
      end
    end
  end

`ifndef SYNTHESIS
  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  logic [95:0] state_str;

  `VC_TRACE_BEGIN
  begin
    $sformat( state_str, "r:%x/%x n:%x ", retired_outputs_reg[7:0], num_inputs_i[7:0], c_num_stages[7:0] );
    vc_trace.append_str( trace_str, state_str );
    if ( p_num_stages > 0 ) begin
      STAGE[0].stage.trace( trace_str );
    end
    if ( p_num_stages > 1 ) begin
      vc_trace.append_str( trace_str, "|" );
      STAGE[1].stage.trace( trace_str );
    end
    if ( p_num_stages > 2 ) begin
      vc_trace.append_str( trace_str, "|" );
      STAGE[2].stage.trace( trace_str );
    end
    if ( p_num_stages > 3 ) begin
      vc_trace.append_str( trace_str, "|" );
      STAGE[3].stage.trace( trace_str );
    end
    if ( p_num_stages > 4 ) begin
      vc_trace.append_str( trace_str, "|" );
      STAGE[4].stage.trace( trace_str );
    end
    if ( p_num_stages > 5 ) begin
      vc_trace.append_str( trace_str, "|" );
      STAGE[5].stage.trace( trace_str );
    end
    if ( p_num_stages > 6 ) begin
      vc_trace.append_str( trace_str, "|" );
      STAGE[6].stage.trace( trace_str );
    end
    if ( p_num_stages > 7 ) begin
      vc_trace.append_str( trace_str, "|" );
      STAGE[7].stage.trace( trace_str );
    end
  end
  `VC_TRACE_END
`endif

endmodule

`endif /* PIPE_FRAMEMETA_DATA_V */
