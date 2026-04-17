//========================================================================
// Verilog Components: Test Source with Random Delays
//========================================================================

`ifndef VC_TEST_RAND_DELAY_SOURCE_V
`define VC_TEST_RAND_DELAY_SOURCE_V

`include "vc-TestSource.v"
`include "vc-TestRandDelay.v"
`include "vc-trace.v"

module vc_TestRandDelaySource
#(
  parameter p_msg_nbits = 1,
  parameter p_num_msgs  = 1024
)(
  input                    clk,
  input                    reset,

  // Max delay input

  input [31:0]             max_delay,

  // Source message interface

  output                   val,
  input                    rdy,
  output [p_msg_nbits-1:0] msg,

  // Goes high once all source data has been issued

  output                   done
);

  //----------------------------------------------------------------------
  // Test source
  //----------------------------------------------------------------------

  wire                   src_val;
  wire                   src_rdy;
  wire [p_msg_nbits-1:0] src_msg;

  vc_TestSource#(p_msg_nbits,p_num_msgs) src
  (
    .clk       (clk),
    .reset     (reset),

    .val       (src_val),
    .rdy       (src_rdy),
    .msg       (src_msg),

    .done      (done)
  );

  //----------------------------------------------------------------------
  // Test random delay
  //----------------------------------------------------------------------

  // vc_TestRandDelay#(p_msg_nbits,p_max_delay_nbits) rand_delay
  vc_TestRandDelay#(p_msg_nbits) rand_delay
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (max_delay),

    .in_val    (src_val),
    .in_rdy    (src_rdy),
    .in_msg    (src_msg),

    .out_val   (val),
    .out_rdy   (rdy),
    .out_msg   (msg)
  );

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  reg [`VC_TRACE_NBITS_TO_NCHARS(p_msg_nbits)*8-1:0] msg_str;

  `VC_TRACE_BEGIN
  begin
    $sformat( msg_str, "%x", msg ); // SEBASTIAN
    // $sformat( msg_str, "%3d %3d %3d %3d", msg[63:48],msg[47:32],msg[31:16],msg[15:0] );  // SEBASTIAN NEW FOR DecPipe.v
    vc_trace.append_val_rdy_str( trace_str, val, rdy, msg_str );
  end
  `VC_TRACE_END

endmodule

`endif /* VC_TEST_RAND_DELAY_SOURCE */

