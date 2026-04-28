//========================================================================
// pipes/rtl/framed/pipe-framebits-stage.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 18 2026
/*
  This is a single stage of a framebits pipeline. val/rdy handshakes move messages through stages.
  The message format is:  { first, last, data } where the first and last bits are used to indicate the first and last
  messages of a frame, respectively. The data bits are used to carry the payload data.

  Message contract:
  - in_msg_i / out_msg_o are packed as:
      - { first, last, data }
  - with:
      - first at bit p_data_nbits+1
      - last at bit p_data_nbits
      - data at bits [p_data_nbits-1:0]
  Other details:
  - trace prints first, last, and low 16 bits of data  
*/

`ifndef PIPE_FRAMEBITS_STAGE_V
`define PIPE_FRAMEBITS_STAGE_V

`ifndef SYNTHESIS
`include "vc-trace.v"
`endif

module pipe_framebits_stage
#(
  parameter p_data_nbits = 64,
  parameter p_addend     = 64'd1
)(
  input  logic                     clk,
  input  logic                     reset,

  input  logic                     in_val_i,
  output logic                     in_rdy_o,
  input  logic [p_data_nbits+1:0]  in_msg_i,

  output logic                     out_val_o,
  input  logic                     out_rdy_i,
  output logic [p_data_nbits+1:0]  out_msg_o
);

  localparam p_msg_nbits = p_data_nbits + 2;
  localparam c_data_lsb  = 0;
  localparam c_data_msb  = p_data_nbits - 1;
  localparam c_last_bit  = p_data_nbits;
  localparam c_first_bit = p_data_nbits + 1;

  logic                    val_reg;
  logic [p_msg_nbits-1:0]  msg_reg;
  logic                    advance;

  logic [p_data_nbits-1:0] out_data;
  logic                    out_first;
  logic                    out_last;

  assign advance   = out_rdy_i || !val_reg;
  assign in_rdy_o  = advance;
  assign out_val_o = val_reg;

  assign out_data  = msg_reg[c_data_msb:c_data_lsb] + p_addend;
  assign out_last  = msg_reg[c_last_bit];
  assign out_first = msg_reg[c_first_bit];
  assign out_msg_o = { out_first, out_last, out_data };

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

  logic [159:0] state_str;

  `VC_TRACE_BEGIN
  begin
    if ( out_val_o )
      $sformat( state_str, "fst:%x lst:%x dat:%x",
        out_first, out_last, out_data[15:0] );
    else
      $sformat( state_str, "fst:- lst:- dat:----" );
    vc_trace.append_str( trace_str, state_str );
  end
  `VC_TRACE_END
`endif

endmodule

`endif /* PIPE_FRAMEBITS_STAGE_V */
