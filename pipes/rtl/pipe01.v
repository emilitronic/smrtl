//========================================================================
// pipes/rtl/pipe01.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 16 2026

`ifndef PIPE01_V
`define PIPE01_V

`include "pipe-ctrl.v"
`include "vc-trace.v"

module pipe01
(
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
  input  logic [63:0]                data_src_msg_i,

  output logic                       data_snk_val_o,
  input  logic                       data_snk_rdy_i,
  output logic [63:0]                data_snk_msg_o
);

  logic        pipe_start;
  logic [31:0] num_inputs;
  logic        pipe_done;

  logic        running_reg;
  logic [31:0] retired_outputs_reg;

  wire data_go = data_snk_val_o && data_snk_rdy_i;

  assign data_src_rdy_o = running_reg && data_snk_rdy_i;
  assign data_snk_val_o = running_reg && data_src_val_i;
  assign data_snk_msg_o = data_src_msg_i;
  assign pipe_done      = running_reg && data_go && ( retired_outputs_reg + 32'd1 == num_inputs );

  pipe_ctrl ctrl
  (
    .clk            (clk),
    .reset          (reset),

    .ctrl_src_val_i (ctrl_src_val_i),
    .ctrl_src_rdy_o (ctrl_src_rdy_o),
    .ctrl_src_msg_i (ctrl_src_msg_i),

    .ctrl_snk_val_o (ctrl_snk_val_o),
    .ctrl_snk_rdy_i (ctrl_snk_rdy_i),
    .ctrl_snk_msg_o (ctrl_snk_msg_o),

    .pipe_start_o   (pipe_start),
    .num_inputs_o   (num_inputs),
    .pipe_done_i    (pipe_done)
  );

  always @( posedge clk ) begin
    if ( reset ) begin
      running_reg         <= 1'b0;
      retired_outputs_reg <= 32'b0;
    end
    else begin
      if ( pipe_start ) begin
        running_reg         <= 1'b1;
        retired_outputs_reg <= 32'b0;
      end
      else if ( pipe_done ) begin
        running_reg         <= 1'b0;
        retired_outputs_reg <= retired_outputs_reg + 32'd1;
      end
      else if ( data_go ) begin
        retired_outputs_reg <= retired_outputs_reg + 32'd1;
      end
    end
  end

  reg [95:0] state_str;

  `VC_TRACE_BEGIN
  begin
    ctrl.trace( trace_str );
    $sformat( state_str, " r:%x/%x\t", retired_outputs_reg[7:0], num_inputs[7:0] );
    vc_trace.append_str( trace_str, state_str );
  end
  `VC_TRACE_END

endmodule

`endif /* PIPE01_V */
