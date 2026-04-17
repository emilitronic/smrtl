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

  assign data_src_rdy_o = 1'b1;
  assign data_snk_val_o = 1'b0;
  assign data_snk_msg_o = 64'b0;

  pipe_ctrl ctrl
  (
    .clk            (clk),
    .reset          (reset),

    .ctrl_src_val_i (ctrl_src_val_i),
    .ctrl_src_rdy_o (ctrl_src_rdy_o),
    .ctrl_src_msg_i (ctrl_src_msg_i),

    .ctrl_snk_val_o (ctrl_snk_val_o),
    .ctrl_snk_rdy_i (ctrl_snk_rdy_i),
    .ctrl_snk_msg_o (ctrl_snk_msg_o)
  );

  `VC_TRACE_BEGIN
  begin
    ctrl.trace( trace_str );
  end
  `VC_TRACE_END

endmodule

`endif /* PIPE01_V */
