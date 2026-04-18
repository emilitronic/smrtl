//=========================================================================
// PIPE Test Harness pipes/tb/asic-test-harness.v
//=========================================================================
// Sebastian Claudiusz Magierowski Apr 8 2026

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-test.v"
`include "vc-trace.v"
`include "vc-preprocessor.v"

`ifndef ASIC_CTRL_MSG_NBITS
  `ifdef BUS_B
    `define ASIC_CTRL_MSG_NBITS `BUS_B
  `else
    `define ASIC_CTRL_MSG_NBITS 32
  `endif
`endif

`ifndef ASIC_DATA_MSG_NBITS
  `ifdef BUS_B
    `define ASIC_DATA_MSG_NBITS `BUS_B
  `else
    `define ASIC_DATA_MSG_NBITS 64
  `endif
`endif

//------------------------------------------------------------------------
// Test Harness Module
//------------------------------------------------------------------------

module TestHarness#(
  parameter p_num_msgs = 2*1024
)(
  input  logic clk,
  input  logic reset,
  input  logic [31:0] ctrl_src_max_delay,
  input  logic [31:0] ctrl_snk_max_delay,
  input  logic [31:0] data_src_max_delay,
  input  logic [31:0] data_snk_max_delay,
  output logic done
);

  // Control path: processor-like command / status traffic

  logic [`ASIC_CTRL_MSG_NBITS-1:0] ctrl_src_msg;
  logic                            ctrl_src_val;
  logic                            ctrl_src_rdy;
  logic                            ctrl_src_done;

  logic [`ASIC_CTRL_MSG_NBITS-1:0] ctrl_snk_msg;
  logic                            ctrl_snk_val;
  logic                            ctrl_snk_rdy;
  logic                            ctrl_snk_done;

  // Data path: memory-like payload traffic

  logic [`ASIC_DATA_MSG_NBITS-1:0] data_src_msg;
  logic                            data_src_val;
  logic                            data_src_rdy;
  logic                            data_src_done;

  logic [`ASIC_DATA_MSG_NBITS-1:0] data_snk_msg;
  logic                            data_snk_val;
  logic                            data_snk_rdy;
  logic                            data_snk_done;

  //----------------------------------------------------------------------
  // Control source
  //----------------------------------------------------------------------

  vc_TestRandDelaySource#(
    .p_msg_nbits ( `ASIC_CTRL_MSG_NBITS ),
    .p_num_msgs  ( p_num_msgs           )
  )
  ctrl_src
  (
    .clk       ( clk                ),
    .reset     ( reset              ),
    .max_delay ( ctrl_src_max_delay ),
    .val       ( ctrl_src_val       ),
    .rdy       ( ctrl_src_rdy       ),
    .msg       ( ctrl_src_msg       ),
    .done      ( ctrl_src_done      )
  );

  //----------------------------------------------------------------------
  // Data source
  //----------------------------------------------------------------------

  vc_TestRandDelaySource#(
    .p_msg_nbits ( `ASIC_DATA_MSG_NBITS ),
    .p_num_msgs  ( p_num_msgs           )
  )
  data_src
  (
    .clk       ( clk                ),
    .reset     ( reset              ),
    .max_delay ( data_src_max_delay ),
    .val       ( data_src_val       ),
    .rdy       ( data_src_rdy       ),
    .msg       ( data_src_msg       ),
    .done      ( data_src_done      )
  );

  //----------------------------------------------------------------------
  // ASIC
  //----------------------------------------------------------------------

  `ASIC_IMPL#(
    .p_num_stages ( `ASIC_IMPL_NUM_STAGES )
  )
  asic
  (
    .clk            ( clk          ),
    .reset          ( reset        ),

    // Control path
    .ctrl_src_val_i ( ctrl_src_val ), // src_val --v--> ASIC
    .ctrl_src_rdy_o ( ctrl_src_rdy ), // src_rdy <--r-- ASIC
    .ctrl_src_msg_i ( ctrl_src_msg ), // src_msg -----> ASIC
    .ctrl_snk_val_o ( ctrl_snk_val ), //                ASIC --v--> snk_val
    .ctrl_snk_rdy_i ( ctrl_snk_rdy ), //                ASIC <--r-- snk_rdy
    .ctrl_snk_msg_o ( ctrl_snk_msg ), //                ASIC -----> snk_msg

    // Data path
    .data_src_val_i ( data_src_val ), // src_val --v--> ASIC
    .data_src_rdy_o ( data_src_rdy ), // src_rdy <--r-- ASIC
    .data_src_msg_i ( data_src_msg ), // src_msg -----> ASIC
    .data_snk_val_o ( data_snk_val ), //                ASIC --v--> snk_val
    .data_snk_rdy_i ( data_snk_rdy ), //                ASIC <--r-- snk_rdy
    .data_snk_msg_o ( data_snk_msg )  //                ASIC -----> snk_msg

  );

  //----------------------------------------------------------------------
  // Control sink
  //----------------------------------------------------------------------

  vc_TestRandDelaySink#(
    .p_msg_nbits ( `ASIC_CTRL_MSG_NBITS ),
    .p_num_msgs  ( p_num_msgs           )
  )
  ctrl_snk
  (
    .clk       ( clk                ),
    .reset     ( reset              ),
    .max_delay ( ctrl_snk_max_delay ),
    .val       ( ctrl_snk_val       ),
    .rdy       ( ctrl_snk_rdy       ),
    .msg       ( ctrl_snk_msg       ),
    .done      ( ctrl_snk_done      )
  );

  //----------------------------------------------------------------------
  // Data sink
  //----------------------------------------------------------------------

  vc_TestRandDelaySink#(
    .p_msg_nbits ( `ASIC_DATA_MSG_NBITS ),
    .p_num_msgs  ( p_num_msgs           )
  )
  data_snk
  (
    .clk       ( clk                ),
    .reset     ( reset              ),
    .max_delay ( data_snk_max_delay ),
    .val       ( data_snk_val       ),
    .rdy       ( data_snk_rdy       ),
    .msg       ( data_snk_msg       ),
    .done      ( data_snk_done      )
  );

  assign done = ctrl_src_done && ctrl_snk_done && data_src_done && data_snk_done;

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `VC_TRACE_BEGIN
  begin
    ctrl_src.trace( trace_str );
    vc_trace.append_str( trace_str, " || " );
    data_src.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    asic.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    ctrl_snk.trace( trace_str );
    vc_trace.append_str( trace_str, " || " );
    data_snk.trace( trace_str );
  end
  `VC_TRACE_END

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `VC_PREPROCESSOR_TOSTR(`ASIC_IMPL) )

  logic         th_reset = 1'b1;
  logic [31:0]  th_ctrl_src_max_delay;
  logic [31:0]  th_ctrl_snk_max_delay;
  logic [31:0]  th_data_src_max_delay;
  logic [31:0]  th_data_snk_max_delay;
  logic [11:0]  th_ctrl_src_idx;
  logic [11:0]  th_ctrl_snk_idx;
  logic [11:0]  th_data_src_idx;
  logic [11:0]  th_data_snk_idx;
  logic         th_done;

  integer sim_num_cycles;

  TestHarness th
  (
    .clk                ( clk                   ),
    .reset              ( th_reset              ),
    .ctrl_src_max_delay ( th_ctrl_src_max_delay ),
    .ctrl_snk_max_delay ( th_ctrl_snk_max_delay ),
    .data_src_max_delay ( th_data_src_max_delay ),
    .data_snk_max_delay ( th_data_snk_max_delay ),
    .done               ( th_done               )
  );

  //----------------------------------------------------------------------
  // Helper tasks to load the source and sink memories
  //----------------------------------------------------------------------

  task load_ctrl_src
  (
    input [11:0]                         i,
    input [`ASIC_CTRL_MSG_NBITS-1:0]     msg
  );
  begin
    th.ctrl_src.src.m[i] = msg;
  end
  endtask

  task load_ctrl_snk
  (
    input [11:0]                         i,
    input [`ASIC_CTRL_MSG_NBITS-1:0]     msg
  );
  begin
    th.ctrl_snk.sink.m[i] = msg;
  end
  endtask

  task load_data_src
  (
    input [11:0]                         i,
    input [`ASIC_DATA_MSG_NBITS-1:0]     msg
  );
  begin
    th.data_src.src.m[i] = msg;
  end
  endtask

  task load_data_snk
  (
    input [11:0]                         i,
    input [`ASIC_DATA_MSG_NBITS-1:0]     msg
  );
  begin
    th.data_snk.sink.m[i] = msg;
  end
  endtask

  task clear_streams;
  begin
    th_ctrl_src_idx = 0;
    th_ctrl_snk_idx = 0;
    th_data_src_idx = 0;
    th_data_snk_idx = 0;

    load_ctrl_src( 0, {`ASIC_CTRL_MSG_NBITS{1'bx}} );
    load_ctrl_snk( 0, {`ASIC_CTRL_MSG_NBITS{1'bx}} );
    load_data_src( 0, {`ASIC_DATA_MSG_NBITS{1'bx}} );
    load_data_snk( 0, {`ASIC_DATA_MSG_NBITS{1'bx}} );
  end
  endtask

  task init_ctrl_src
  (
    input [`ASIC_CTRL_MSG_NBITS-1:0] msg
  );
  begin
    load_ctrl_src( th_ctrl_src_idx, msg );
    th_ctrl_src_idx = th_ctrl_src_idx + 1;
    load_ctrl_src( th_ctrl_src_idx, {`ASIC_CTRL_MSG_NBITS{1'bx}} );
  end
  endtask

  task init_ctrl_snk
  (
    input [`ASIC_CTRL_MSG_NBITS-1:0] msg
  );
  begin
    load_ctrl_snk( th_ctrl_snk_idx, msg );
    th_ctrl_snk_idx = th_ctrl_snk_idx + 1;
    load_ctrl_snk( th_ctrl_snk_idx, {`ASIC_CTRL_MSG_NBITS{1'bx}} );
  end
  endtask

  task init_data_src
  (
    input [`ASIC_DATA_MSG_NBITS-1:0] msg
  );
  begin
    load_data_src( th_data_src_idx, msg );
    th_data_src_idx = th_data_src_idx + 1;
    load_data_src( th_data_src_idx, {`ASIC_DATA_MSG_NBITS{1'bx}} );
  end
  endtask

  task init_data_snk
  (
    input [`ASIC_DATA_MSG_NBITS-1:0] msg
  );
  begin
    load_data_snk( th_data_snk_idx, msg );
    th_data_snk_idx = th_data_snk_idx + 1;
    load_data_snk( th_data_snk_idx, {`ASIC_DATA_MSG_NBITS{1'bx}} );
  end
  endtask

  // Compatibility aliases while test cases are being rewritten.

  task init_src_ctrl
  (
    input [`ASIC_CTRL_MSG_NBITS-1:0] msg
  );
  begin
    init_ctrl_src( msg );
  end
  endtask

  task init_snk_ctrl
  (
    input [`ASIC_CTRL_MSG_NBITS-1:0] msg
  );
  begin
    init_ctrl_snk( msg );
  end
  endtask

  task init_src_data
  (
    input [`ASIC_DATA_MSG_NBITS-1:0] msg
  );
  begin
    init_data_src( msg );
  end
  endtask

  task init_snk_data
  (
    input [`ASIC_DATA_MSG_NBITS-1:0] msg
  );
  begin
    init_data_snk( msg );
  end
  endtask

  //----------------------------------------------------------------------
  // Helper task to initialize random delay setup
  //----------------------------------------------------------------------

  task init_rand_delays
  (
    input logic [31:0] ctrl_src_max_delay,
    input logic [31:0] ctrl_snk_max_delay,
    input logic [31:0] data_src_max_delay,
    input logic [31:0] data_snk_max_delay
  );
  begin
    th_ctrl_src_max_delay = ctrl_src_max_delay;
    th_ctrl_snk_max_delay = ctrl_snk_max_delay;
    th_data_src_max_delay = data_src_max_delay;
    th_data_snk_max_delay = data_snk_max_delay;
  end
  endtask

  //----------------------------------------------------------------------
  // Helper task to run test
  //----------------------------------------------------------------------

  task run_test();
  begin
    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    sim_num_cycles = 3*256 + 16;

    while ( !th_done && (th.vc_trace.cycles < sim_num_cycles) ) begin
      th.display_trace();
      #10;
    end

    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  `include `ASIC_TEST_CASES_FILE

  `VC_TEST_SUITE_END
endmodule
