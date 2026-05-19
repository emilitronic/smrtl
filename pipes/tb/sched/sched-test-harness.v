//========================================================================
// PIPE Schedule Test Harness pipes/tb/sched/sched-test-harness.v
//========================================================================
// Sebastian Claudiusz Magierowski May 14 2026
/*
  - Loads generated/current_sched_trace.svh. 
  - Defines expected arrays from the generated trace.
  - Uses a replay stub that updates debug register status/value outputs on clock edges.
  - Checks each row using the X/I/valid rules:
      - X: do not check status or value
      - I: require invalid status
      - tuple: require valid status and exact 16-bit value
  - This validates the oracle format and checker mechanics before the real RTL exists.
*/
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "pipe_sched" )

  localparam c_max_trace_rows = 512;
  localparam c_num_regs       = 16;

  localparam c_status_x       = 2'd0;
  localparam c_status_i       = 2'd1;
  localparam c_status_v       = 2'd2;

  integer    sched_trace_nrows;
  logic [7:0]  sched_trace_i      [0:c_max_trace_rows-1];
  logic [7:0]  sched_trace_k      [0:c_max_trace_rows-1];
  logic [1:0]  sched_trace_status [0:c_max_trace_rows-1][0:c_num_regs-1]; // holds oracle cell status: X/I/V
  logic [15:0] sched_trace_value  [0:c_max_trace_rows-1][0:c_num_regs-1]; // holds oracle cell value when status is V

  logic        reset = 1'b1;
  logic        advance = 1'b0;
  integer      check_errors;

  logic        dut_done;
  logic [7:0]  dut_dbg_i;
  logic [7:0]  dut_dbg_k;
  logic [2*c_num_regs-1:0]  dut_status_bus;
  logic [16*c_num_regs-1:0] dut_value_bus;
  logic        lpv_val;
  logic        lpv_rdy;
  logic [15:0] lpv_msg;

  logic [1:0]  dut_status [0:c_num_regs-1];
  logic [15:0] dut_value  [0:c_num_regs-1];

  `include "generated/current_sched_trace.svh"

  //----------------------------------------------------------------------
  // Register Name Helper
  //----------------------------------------------------------------------

  function string reg_name
  (
    input integer reg_idx
  );
  begin
    case ( reg_idx )
      0:  reg_name = "A";
      1:  reg_name = "R0";
      2:  reg_name = "R1";
      3:  reg_name = "R2";
      4:  reg_name = "R3";
      5:  reg_name = "R4";
      6:  reg_name = "R5";
      7:  reg_name = "R6";
      8:  reg_name = "R7";
      9:  reg_name = "R8";
      10: reg_name = "D2";
      11: reg_name = "D3";
      12: reg_name = "D4";
      13: reg_name = "D5";
      14: reg_name = "D6";
      15: reg_name = "F6";
      default: reg_name = "?";
    endcase
  end
  endfunction

  //----------------------------------------------------------------------
  // DUT
  //----------------------------------------------------------------------

  pipe_sched01 dut
  (
    .clk          ( clk            ),
    .reset        ( reset          ),
    .advance_i    ( advance        ),
    .lpv_val_i    ( lpv_val        ),
    .lpv_rdy_o    ( lpv_rdy        ),
    .lpv_msg_i    ( lpv_msg        ),
    .done_o       ( dut_done       ),
    .dbg_i_o      ( dut_dbg_i      ),
    .dbg_k_o      ( dut_dbg_k      ),
    .dbg_status_o ( dut_status_bus ),
    .dbg_value_o  ( dut_value_bus  )
  );

  genvar g;
  generate
    for ( g = 0; g < c_num_regs; g = g + 1 ) begin : MAP_DUT_DBG
      assign dut_status[g] = dut_status_bus[(2*g)+1:(2*g)];
      assign dut_value[g]  = dut_value_bus[(16*g)+15:(16*g)];
    end
  endgenerate

  //----------------------------------------------------------------------
  // Check Tasks
  //----------------------------------------------------------------------

  // Compare one DUT debug register against one oracle cell. The oracle cell
  // can be unconstrained (X), invalid (I), or a valid 16-bit tuple value.
  task check_sched_reg
  (
    input integer row_idx,
    input integer reg_idx
  );
    logic [1:0]  exp_status;
    logic [15:0] exp_value;
  begin
    exp_status = sched_trace_status[row_idx][reg_idx];
    exp_value  = sched_trace_value[row_idx][reg_idx];

    if ( exp_status == c_status_x ) begin
      // X means unknown/uninitialized in the oracle. Do not constrain status
      // or value for this register in this row.
    end
    else if ( exp_status == c_status_i ) begin
      if ( dut_status[reg_idx] != c_status_i ) begin
        $display(
          "     [ FAILED ] row=%0d epoch=(%0d,%0d) reg=%s expected=I actual_status=%0d actual_value=%x",
          row_idx, sched_trace_i[row_idx], sched_trace_k[row_idx], reg_name( reg_idx ),
          dut_status[reg_idx], dut_value[reg_idx]
        );
        check_errors = check_errors + 1;
      end
    end
    else if ( exp_status == c_status_v ) begin
      if ( ( dut_status[reg_idx] != c_status_v ) || ( dut_value[reg_idx] != exp_value ) ) begin
        $display(
          "     [ FAILED ] row=%0d epoch=(%0d,%0d) reg=%s expected=%x actual_status=%0d actual_value=%x",
          row_idx, sched_trace_i[row_idx], sched_trace_k[row_idx], reg_name( reg_idx ),
          exp_value, dut_status[reg_idx], dut_value[reg_idx]
        );
        check_errors = check_errors + 1;
      end
    end
    else begin
      $display(
        "     [ FAILED ] row=%0d epoch=(%0d,%0d) reg=%s bad expected status=%0d",
        row_idx, sched_trace_i[row_idx], sched_trace_k[row_idx], reg_name( reg_idx ), exp_status
      );
      check_errors = check_errors + 1;
    end
  end
  endtask

  // Compare all traced DUT debug registers against one expected trace row.
  task check_sched_row
  (
    input integer row_idx
  );
    integer reg_idx;
  begin
    for ( reg_idx = 0; reg_idx < c_num_regs; reg_idx = reg_idx + 1 )
      check_sched_reg( row_idx, reg_idx );
  end
  endtask

  // Load the generated oracle, run the schedule RTL one advance per oracle
  // row, and compare the DUT debug registers after each accepting edge.
  task run_trace_check;
    integer row_idx;
  begin
    init_sched_trace();
    check_errors = 0;

    reset = 1'b1;
    advance = 1'b0;
    lpv_val = 1'b1;
    lpv_msg = 16'b0;
    @( posedge clk );
    #1;
    reset = 1'b0;

    for ( row_idx = 0; row_idx < sched_trace_nrows; row_idx = row_idx + 1 ) begin
      lpv_msg = { sched_trace_i[row_idx], sched_trace_k[row_idx] };
      advance = 1'b1;
      @( posedge clk );
      #1;
      check_sched_row( row_idx );
    end

    advance = 1'b0;
    `VC_TEST_NET( dut_done, 1'b1 );
    `VC_TEST_NET( check_errors, 0 );
  end
  endtask

  //----------------------------------------------------------------------
  // Tests
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "schedule RTL matches trace oracle" )
  begin
    run_trace_check();
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule
