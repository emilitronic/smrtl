//=========================================================================
// PIPE Framer Test Harness pipes/tb/framer/framer-test-harness.v
//=========================================================================
// Sebastian Claudiusz Magierowski May 8 2026

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-test.v"
`include "vc-trace.v"

`ifndef RAW_MSG_NBITS
`define RAW_MSG_NBITS 64
`endif

`ifndef FRM_MSG_NBITS
`define FRM_MSG_NBITS 66
`endif

module TestHarness#(
  parameter p_num_msgs = 2*1024
)(
  input  logic        clk,
  input  logic        reset,
  input  logic [31:0] raw_src_max_delay,
  input  logic [31:0] frm_snk_max_delay,
  input  logic [31:0] num_inputs,
  input  logic [31:0] frame_len,
  output logic        done
);

  logic [`RAW_MSG_NBITS-1:0] raw_src_msg;
  logic                      raw_src_val;
  logic                      raw_src_rdy;
  logic                      raw_src_done;

  logic [`FRM_MSG_NBITS-1:0] frm_snk_msg;
  logic                      frm_snk_val;
  logic                      frm_snk_rdy;
  logic                      frm_snk_done;

  logic                      framer_done;
  logic                      framer_done_seen_reg;
  logic                      start;
  logic                      started_reg;

  assign start = !started_reg;

  always @( posedge clk ) begin
    if ( reset ) begin
      started_reg <= 1'b0;
      framer_done_seen_reg <= 1'b0;
    end
    else begin
      started_reg <= 1'b1;

      if ( framer_done )
        framer_done_seen_reg <= 1'b1;
    end
  end

  vc_TestRandDelaySource#(
    .p_msg_nbits ( `RAW_MSG_NBITS ),
    .p_num_msgs  ( p_num_msgs     )
  )
  raw_src
  (
    .clk       ( clk               ),
    .reset     ( reset             ),
    .max_delay ( raw_src_max_delay ),
    .val       ( raw_src_val       ),
    .rdy       ( raw_src_rdy       ),
    .msg       ( raw_src_msg       ),
    .done      ( raw_src_done      )
  );

  pipe_framer#(
    .p_data_nbits ( `RAW_MSG_NBITS )
  )
  framer
  (
    .clk          ( clk          ),
    .reset        ( reset        ),
    .start_i      ( start        ),
    .num_inputs_i ( num_inputs   ),
    .frame_len_i  ( frame_len    ),
    .done_o       ( framer_done  ),
    .raw_val_i    ( raw_src_val  ),
    .raw_rdy_o    ( raw_src_rdy  ),
    .raw_msg_i    ( raw_src_msg  ),
    .frm_val_o    ( frm_snk_val  ),
    .frm_rdy_i    ( frm_snk_rdy  ),
    .frm_msg_o    ( frm_snk_msg  )
  );

  vc_TestRandDelaySink#(
    .p_msg_nbits ( `FRM_MSG_NBITS ),
    .p_num_msgs  ( p_num_msgs     )
  )
  frm_snk
  (
    .clk       ( clk               ),
    .reset     ( reset             ),
    .max_delay ( frm_snk_max_delay ),
    .val       ( frm_snk_val       ),
    .rdy       ( frm_snk_rdy       ),
    .msg       ( frm_snk_msg       ),
    .done      ( frm_snk_done      )
  );

  assign done = raw_src_done && frm_snk_done && framer_done_seen_reg;

  `VC_TRACE_BEGIN
  begin
    raw_src.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    framer.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    frm_snk.trace( trace_str );
  end
  `VC_TRACE_END

endmodule

module top;
  `VC_TEST_SUITE_BEGIN( "pipe_framer" )

  logic        th_reset = 1'b1;
  logic [31:0] th_raw_src_max_delay;
  logic [31:0] th_frm_snk_max_delay;
  logic [31:0] th_num_inputs;
  logic [31:0] th_frame_len;
  logic [11:0] th_raw_src_idx;
  logic [11:0] th_frm_snk_idx;
  logic        th_done;

  integer sim_num_cycles;

  TestHarness th
  (
    .clk               ( clk                  ),
    .reset             ( th_reset             ),
    .raw_src_max_delay ( th_raw_src_max_delay ),
    .frm_snk_max_delay ( th_frm_snk_max_delay ),
    .num_inputs        ( th_num_inputs        ),
    .frame_len         ( th_frame_len         ),
    .done              ( th_done              )
  );

  task load_raw_src
  (
    input [11:0]                     i,
    input [`RAW_MSG_NBITS-1:0]       msg
  );
  begin
    th.raw_src.src.m[i] = msg;
  end
  endtask

  task load_frm_snk
  (
    input [11:0]                     i,
    input [`FRM_MSG_NBITS-1:0]       msg
  );
  begin
    th.frm_snk.sink.m[i] = msg;
  end
  endtask

  task clear_streams;
  begin
    th_raw_src_idx = 12'd0;
    th_frm_snk_idx = 12'd0;
    load_raw_src( 12'd0, 'x );
    load_frm_snk( 12'd0, 'x );
  end
  endtask

  task init_raw_src
  (
    input [`RAW_MSG_NBITS-1:0] msg
  );
  begin
    load_raw_src( th_raw_src_idx, msg );
    th_raw_src_idx = th_raw_src_idx + 12'd1;
    load_raw_src( th_raw_src_idx, 'x );
  end
  endtask

  task init_frm_snk
  (
    input [`FRM_MSG_NBITS-1:0] msg
  );
  begin
    load_frm_snk( th_frm_snk_idx, msg );
    th_frm_snk_idx = th_frm_snk_idx + 12'd1;
    load_frm_snk( th_frm_snk_idx, 'x );
  end
  endtask

  task init_rand_delays
  (
    input [31:0] raw_src_delay,
    input [31:0] frm_snk_delay
  );
  begin
    th_raw_src_max_delay = raw_src_delay;
    th_frm_snk_max_delay = frm_snk_delay;
  end
  endtask

  task init_config
  (
    input [31:0] num_inputs,
    input [31:0] frame_len
  );
  begin
    th_num_inputs = num_inputs;
    th_frame_len  = frame_len;
  end
  endtask

  task run_test;
  begin
    th_reset = 1'b1;
    #20;
    th_reset = 1'b0;

    sim_num_cycles = 5000;

    while ( !th_done && ( th.vc_trace.cycles < sim_num_cycles ) ) begin
      th.display_trace();
      #10;
    end

    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  `include "framer-test-cases.svh"

  `VC_TEST_SUITE_END
endmodule
