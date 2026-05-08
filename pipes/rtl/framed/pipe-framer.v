//========================================================================
// pipes/rtl/framed/pipe-framer.v
//========================================================================
// Sebastian Claudiusz Magierowski May 8 2026
/*
  This block converts a raw data stream into a framebits stream:

    raw data -> { first, last, data }

  The first version uses a fixed frame length and a total beat count supplied
  by control/configuration. All counters advance only when a raw input beat is
  accepted and the corresponding framed output beat is consumed.
*/

`ifndef PIPE_FRAMER_V
`define PIPE_FRAMER_V

`ifndef SYNTHESIS
`include "vc-trace.v"
`endif

module pipe_framer
#(
  parameter p_data_nbits = 64,
  parameter p_msg_nbits  = p_data_nbits + 2
)(
  input  logic                     clk,
  input  logic                     reset,
  // config/control interface
  input  logic                     start_i,
  input  logic [31:0]              num_inputs_i,
  input  logic [31:0]              frame_len_i,
  output logic                     done_o,
  // rawn input stream interface
  input  logic                     raw_val_i,
  output logic                     raw_rdy_o,
  input  logic [p_data_nbits-1:0]  raw_msg_i,
  // framed output stream interface
  output logic                     frm_val_o,
  input  logic                     frm_rdy_i,
  output logic [p_msg_nbits-1:0]   frm_msg_o
);

  localparam c_data_lsb  = 0;
  localparam c_data_msb  = p_data_nbits - 1;
  localparam c_last_bit  = p_data_nbits;
  localparam c_first_bit = p_data_nbits + 1;

  logic        running_reg;
  logic [31:0] total_idx_reg;
  logic [31:0] frame_idx_reg;
  logic [31:0] frame_len_reg;
  logic [31:0] num_inputs_reg;
  logic        raw_go;
  logic        first;
  logic        last;

  assign raw_go    = raw_val_i && raw_rdy_o;
  assign first     = ( frame_idx_reg == 32'd0 );
  assign last      = ( frame_idx_reg + 32'd1 == frame_len_reg ) ||
                     ( total_idx_reg + 32'd1 == num_inputs_reg );
  assign raw_rdy_o = running_reg && frm_rdy_i;
  assign frm_val_o = running_reg && raw_val_i;
  assign frm_msg_o = { first, last, raw_msg_i };
  assign done_o    = running_reg && raw_go && ( total_idx_reg + 32'd1 == num_inputs_reg );

  always @( posedge clk ) begin
    if ( reset ) begin
      running_reg    <= 1'b0;
      total_idx_reg  <= 32'b0;
      frame_idx_reg  <= 32'b0;
      frame_len_reg  <= 32'b0;
      num_inputs_reg <= 32'b0;
    end
    else begin
      if ( start_i ) begin
        running_reg    <= ( num_inputs_i != 32'd0 ) && ( frame_len_i != 32'd0 );
        total_idx_reg  <= 32'b0;
        frame_idx_reg  <= 32'b0;
        frame_len_reg  <= frame_len_i;
        num_inputs_reg <= num_inputs_i;
      end
      else if ( raw_go ) begin
        if ( done_o ) begin
          running_reg <= 1'b0;
        end

        total_idx_reg <= total_idx_reg + 32'd1;

        if ( last )
          frame_idx_reg <= 32'b0;
        else
          frame_idx_reg <= frame_idx_reg + 32'd1;
      end
    end
  end

`ifndef SYNTHESIS
  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  logic [159:0] state_str;

  `VC_TRACE_BEGIN
  begin
    if ( running_reg )
      $sformat( state_str, "frm:%x/%x pos:%x/%x",
        total_idx_reg[7:0], num_inputs_reg[7:0], frame_idx_reg[7:0], frame_len_reg[7:0] );
    else
      $sformat( state_str, "frm:idle" );
    vc_trace.append_str( trace_str, state_str );
  end
  `VC_TRACE_END
`endif

endmodule

`endif /* PIPE_FRAMER_V */
