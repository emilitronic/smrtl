//========================================================================
// pipes/rtl/framed/pipe-framemeta-stage.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 28 2026
/*
  This is a single stage of a framemeta pipeline. The message format is:

    { frame_id, beat_idx, first, last, data }

  The metadata and frame boundary bits are preserved unchanged. The data
  field is transformed by the stage function, which is currently data + 1.
*/

`ifndef PIPE_FRAMEMETA_STAGE_V
`define PIPE_FRAMEMETA_STAGE_V

`ifndef SYNTHESIS
`include "vc-trace.v"
`endif

module pipe_framemeta_stage
#(
  parameter p_frame_id_nbits = 4,
  parameter p_beat_idx_nbits = 8,
  parameter p_data_nbits     = 64,
  parameter p_addend         = 64'd1,
  parameter p_msg_nbits      = p_frame_id_nbits + p_beat_idx_nbits + 2 + p_data_nbits
)(
  input  logic                     clk,
  input  logic                     reset,

  input  logic                     in_val_i,
  output logic                     in_rdy_o,
  input  logic [p_msg_nbits-1:0]   in_msg_i,

  output logic                     out_val_o,
  input  logic                     out_rdy_i,
  output logic [p_msg_nbits-1:0]   out_msg_o
);

  localparam c_data_lsb        = 0;
  localparam c_data_msb        = p_data_nbits - 1;
  localparam c_last_bit        = p_data_nbits;
  localparam c_first_bit       = p_data_nbits + 1;
  localparam c_beat_idx_lsb    = p_data_nbits + 2;
  localparam c_beat_idx_msb    = c_beat_idx_lsb + p_beat_idx_nbits - 1;
  localparam c_frame_id_lsb    = c_beat_idx_msb + 1;
  localparam c_frame_id_msb    = c_frame_id_lsb + p_frame_id_nbits - 1;

  logic                    val_reg;
  logic [p_msg_nbits-1:0]  msg_reg;
  logic                    advance;

  logic [p_frame_id_nbits-1:0] out_frame_id;
  logic [p_beat_idx_nbits-1:0] out_beat_idx;
  logic                       out_first;
  logic                       out_last;
  logic [p_data_nbits-1:0]    out_data;

  assign advance   = out_rdy_i || !val_reg;
  assign in_rdy_o  = advance;
  assign out_val_o = val_reg;

  assign out_data     = msg_reg[c_data_msb:c_data_lsb] + p_addend;
  assign out_last     = msg_reg[c_last_bit];
  assign out_first    = msg_reg[c_first_bit];
  assign out_beat_idx = msg_reg[c_beat_idx_msb:c_beat_idx_lsb];
  assign out_frame_id = msg_reg[c_frame_id_msb:c_frame_id_lsb];
  assign out_msg_o    = { out_frame_id, out_beat_idx, out_first, out_last, out_data };

  always @( posedge clk ) begin
    if ( reset ) begin
      val_reg <= 1'b0;
      msg_reg <= '0;
    end
    else if ( advance ) begin
      val_reg <= in_val_i;
      if ( in_val_i )
        msg_reg <= in_msg_i;
    end
  end

`ifndef SYNTHESIS
  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  logic [255:0] state_str;

  `VC_TRACE_BEGIN
  begin
    if ( out_val_o )
      $sformat( state_str, "fid:%x bid:%x fst:%x lst:%x dat:%x",
        out_frame_id, out_beat_idx, out_first, out_last, out_data[15:0] );
    else
      $sformat( state_str, "fid:- bid:- fst:- lst:- dat:----" );
    vc_trace.append_str( trace_str, state_str );
  end
  `VC_TRACE_END
`endif

endmodule

`endif /* PIPE_FRAMEMETA_STAGE_V */
