//========================================================================
// pipes/rtl/pipe-data.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 17 2026

`ifndef PIPE_DATA_V
`define PIPE_DATA_V

`include "pipe-stage.v"
`include "vc-trace.v"

module pipe_data
(
  input  logic        clk,
  input  logic        reset,

  input  logic        pipe_start_i,
  input  logic [31:0] num_inputs_i,
  output logic        pipe_done_o,

  input  logic        data_src_val_i,
  output logic        data_src_rdy_o,
  input  logic [63:0] data_src_msg_i,

  output logic        data_snk_val_o,
  input  logic        data_snk_rdy_i,
  output logic [63:0] data_snk_msg_o
);

  localparam [31:0] c_num_stages = 32'd2;

  logic        running_reg; // is pipe running (i.e., has it been started and not yet completed)?
  logic [31:0] retired_outputs_reg; // how many outputs succesfully pumpd out of pipe
  logic        data_go;
  logic        stage0_in_val;
  logic        stage0_in_rdy;
  logic [63:0] stage0_in_msg;
  logic        stage0_out_val;
  logic        stage0_out_rdy;
  logic [63:0] stage0_out_msg;
  logic        stage1_out_val;
  logic [63:0] stage1_out_msg;

  assign stage0_in_val  = running_reg && data_src_val_i;
  assign stage0_in_msg  = data_src_msg_i;
  assign data_go        = data_snk_val_o && data_snk_rdy_i;
  assign data_src_rdy_o = running_reg && stage0_in_rdy;
  assign data_snk_val_o = stage1_out_val;
  assign data_snk_msg_o = stage1_out_msg;
  assign pipe_done_o    = running_reg && data_go && ( retired_outputs_reg + 32'd1 == num_inputs_i );

  pipe_stage#(
    .p_data_nbits ( 64    ),
    .p_addend     ( 64'd1 )
  )
  stage0
  (
    .clk       ( clk           ),
    .reset     ( reset         ),
    .in_val_i  ( stage0_in_val ),
    .in_rdy_o  ( stage0_in_rdy ),
    .in_msg_i  ( stage0_in_msg ),
    .out_val_o ( stage0_out_val ),
    .out_rdy_i ( stage0_out_rdy ),
    .out_msg_o ( stage0_out_msg )
  );

  pipe_stage#(
    .p_data_nbits ( 64    ),
    .p_addend     ( 64'd1 )
  )
  stage1
  (
    .clk       ( clk            ),
    .reset     ( reset          ),
    .in_val_i  ( stage0_out_val ),
    .in_rdy_o  ( stage0_out_rdy ),
    .in_msg_i  ( stage0_out_msg ),
    .out_val_o ( stage1_out_val ),
    .out_rdy_i ( data_snk_rdy_i ),
    .out_msg_o ( stage1_out_msg )
  );

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

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  logic [95:0] state_str;

  `VC_TRACE_BEGIN
  begin
    $sformat( state_str, "r:%x/%x n:%x ", retired_outputs_reg[7:0], num_inputs_i[7:0], c_num_stages[7:0] );
    vc_trace.append_str( trace_str, state_str );
    stage0.trace( trace_str );
    vc_trace.append_str( trace_str, "|" );
    stage1.trace( trace_str );
  end
  `VC_TRACE_END

endmodule

`endif /* PIPE_DATA_V */
