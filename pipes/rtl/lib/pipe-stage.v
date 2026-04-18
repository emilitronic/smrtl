//========================================================================
// pipes/rtl/pipe-stage.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 17 2026

`ifndef PIPE_STAGE_V
`define PIPE_STAGE_V

`ifndef SYNTHESIS
`include "vc-trace.v"
`endif

module pipe_stage
#(
  parameter p_data_nbits = 64,
  parameter p_addend     = 64'd1
)(
  input  logic                     clk,
  input  logic                     reset,

  input  logic                     in_val_i,
  output logic                     in_rdy_o,
  input  logic [p_data_nbits-1:0]  in_msg_i,

  output logic                     out_val_o,
  input  logic                     out_rdy_i,
  output logic [p_data_nbits-1:0]  out_msg_o
);

  logic                    val_reg;
  logic [p_data_nbits-1:0] msg_reg;
  logic                    advance;

  assign advance   = out_rdy_i || !val_reg;
  assign in_rdy_o  = advance;
  assign out_val_o = val_reg;
  assign out_msg_o = msg_reg + p_addend;

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

  logic [95:0] state_str;

  `VC_TRACE_BEGIN
  begin
    if ( out_val_o )
      $sformat( state_str, "stg:%x", out_msg_o[15:0] );
    else
      $sformat( state_str, "stg:----" );
    vc_trace.append_str( trace_str, state_str );
  end
  `VC_TRACE_END
`endif

endmodule

`endif /* PIPE_STAGE_V */
