  
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
  output logic [31:0] ctrl_snk_msg_o,

  output logic        pipe_start_o,
  output logic [31:0] num_inputs_o,
  input  logic        pipe_done_i
);

  localparam [1:0] c_state_IDLE       = 2'd0;
  localparam [1:0] c_state_LOAD_COUNT = 2'd1;
  localparam [1:0] c_state_RUN        = 2'd2;
  localparam [1:0] c_state_RESP       = 2'd3;

  logic [1:0]  state_reg;
  logic [1:0]  state_next;
  logic [31:0] last_cmd;
  logic [31:0] num_inputs_reg;

  wire ctrl_src_go = ctrl_src_val_i && ctrl_src_rdy_o;
  wire ctrl_snk_go = ctrl_snk_val_o && ctrl_snk_rdy_i;

  // State transition logic
  always @(*) begin
    state_next = state_reg;

    case ( state_reg )
      c_state_IDLE: begin
        if ( ctrl_src_go && ( ctrl_src_msg_i == 32'd0 ) )
          state_next = c_state_LOAD_COUNT;
      end

      c_state_LOAD_COUNT: begin
        if ( ctrl_src_go )
          state_next = c_state_RUN;
      end

      c_state_RUN: begin
        if ( pipe_done_i )
          state_next = c_state_RESP;
      end

      c_state_RESP: begin
        if ( ctrl_snk_go )
          state_next = c_state_IDLE;
      end

      default: begin
        state_next = c_state_IDLE;
      end
    endcase
  end

  assign ctrl_src_rdy_o =
    ( state_reg == c_state_IDLE ) || ( state_reg == c_state_LOAD_COUNT );
  assign ctrl_snk_val_o = ( state_reg == c_state_RESP );
  assign ctrl_snk_msg_o = 32'd1;
  assign pipe_start_o   = ( state_reg == c_state_LOAD_COUNT ) && ctrl_src_go;
  assign num_inputs_o   = num_inputs_reg;

  // State
  always @( posedge clk ) begin
    if ( reset ) begin
      state_reg      <= c_state_IDLE;
      last_cmd       <= 32'b0;
      num_inputs_reg <= 32'b0;
    end
    else begin
      state_reg <= state_next;

      if ( ctrl_src_go )
        last_cmd <= ctrl_src_msg_i;

      if ( state_reg == c_state_LOAD_COUNT && ctrl_src_go )
        num_inputs_reg <= ctrl_src_msg_i;
    end
  end

  reg [63:0] state_str;

  `VC_TRACE_BEGIN
  begin
    if ( state_reg == c_state_IDLE && ctrl_src_go ) begin
      vc_trace.append_str( trace_str, "start" );
    end
    else if ( state_reg == c_state_LOAD_COUNT && ctrl_src_go ) begin
      $sformat( state_str, "cnt:%x", ctrl_src_msg_i[15:0] );
      vc_trace.append_str( trace_str, state_str );
    end
    else if ( state_reg == c_state_RUN ) begin
      $sformat( state_str, "run:%x", num_inputs_reg[15:0] );
      vc_trace.append_str( trace_str, state_str );
    end
    else if ( state_reg == c_state_RESP ) begin
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
