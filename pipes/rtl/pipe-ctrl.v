  
//========================================================================
// pipes/rtl/pipe-ctrl.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 16 2026
/*
  1. Wait idle with ctrl_src_rdy_o = 1
  2. When ctrl_src_val_i && ctrl_src_rdy_o, accept the command
  3. Move into “response pending” state
  4. Drive ctrl_snk_val_o = 1 and ctrl_snk_msg_o = 32'd1
  5. When ctrl_snk_val_o && ctrl_snk_rdy_i, clear the pending response and return to idle
*/

`ifndef PIPE_CTRL_V
`define PIPE_CTRL_V

`include "vc-trace.v"

module pipe_ctrl
(
  input  logic        clk,
  input  logic        reset,

  input  logic        ctrl_src_val_i,
  output logic        ctrl_src_rdy_o,
  input  logic [31:0] ctrl_src_msg_i,

  output logic        ctrl_snk_val_o,
  input  logic        ctrl_snk_rdy_i,
  output logic [31:0] ctrl_snk_msg_o
);

  localparam [0:0] c_state_idle = 1'b0;
  localparam [0:0] c_state_resp = 1'b1;

  logic [0:0]  state_reg;
  logic [0:0]  state_next;
  logic [31:0] last_cmd;

  // State transition logic
  always @(*) begin
    state_next = state_reg;

    case ( state_reg )
      c_state_idle: begin
        if ( ctrl_src_val_i )
          state_next = c_state_resp;
      end

      c_state_resp: begin
        if ( ctrl_snk_rdy_i )
          state_next = c_state_idle;
      end

      default: begin
        state_next = c_state_idle;
      end
    endcase
  end

  assign ctrl_src_rdy_o = ( state_reg == c_state_idle );
  assign ctrl_snk_val_o = ( state_reg == c_state_resp );
  assign ctrl_snk_msg_o = 32'd1;

  // State
  always @( posedge clk ) begin
    if ( reset ) begin
      state_reg <= c_state_idle;
      last_cmd  <= 32'b0;
    end
    else begin
      state_reg <= state_next;

      if ( ctrl_src_val_i && ctrl_src_rdy_o )
        last_cmd <= ctrl_src_msg_i;
    end
  end

  reg [39:0] state_str;

  `VC_TRACE_BEGIN
  begin
    if ( ctrl_src_val_i && ctrl_src_rdy_o ) begin
      $sformat( state_str, "a:%x", ctrl_src_msg_i[15:0] );
      vc_trace.append_str( trace_str, state_str );
    end
    else if ( state_reg == c_state_resp ) begin
      vc_trace.append_str( trace_str, "done" );
    end
    else begin
      $sformat( state_str, "i:%x", last_cmd[15:0] );
      vc_trace.append_str( trace_str, state_str );
    end
  end
  `VC_TRACE_END

endmodule

`endif /* PIPE_CTRL_V */
