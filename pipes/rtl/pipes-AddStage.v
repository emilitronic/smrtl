//========================================================================
// Elastic Add Pipeline Stage
//========================================================================
// Sebastian Claudiusz Magierowski Apr 8 2026

`ifndef PIPES_ADD_STAGE_V
`define PIPES_ADD_STAGE_V

module pipes_AddStage
#(
  parameter p_data_nbits = 16,
  parameter p_addend     = 1
)(
  input                       clk,
  input                       reset,

  input  [p_data_nbits-1:0]   in_msg,
  input                       in_val,
  output                      in_rdy,

  output [p_data_nbits-1:0]   out_msg,
  output                      out_val,
  input                       out_rdy
);

  reg [p_data_nbits-1:0] data_reg;
  reg                    val_reg;

  wire advance = out_rdy || !val_reg;

  assign in_rdy  = advance;
  assign out_msg = data_reg;
  assign out_val = val_reg;

  always @( posedge clk ) begin
    if ( reset ) begin
      data_reg <= {p_data_nbits{1'b0}};
      val_reg  <= 1'b0;
    end
    else if ( advance ) begin
      val_reg <= in_val;
      if ( in_val )
        data_reg <= in_msg + p_addend;
    end
  end

endmodule

`endif /* PIPES_ADD_STAGE_V */
