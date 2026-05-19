//========================================================================
// pipes/rtl/sched/pipe-sched01.v
//========================================================================
// Sebastian Claudiusz Magierowski May 18 2026
/*
  Schedule-faithful miniature pipe reference model.

  This module is intentionally a compact control/schedule model, not the final
  structural RTL implementation and not the final target computation. It has
  the same traced register shape as the target pipeline:

    A
    R0..R8
    D2..D6
    F6

  Each register has a 2-bit status and a 16-bit tuple value. The tuple encodes
  `{ x[7:0], y[7:0] }`. Status meanings match the sched test oracle:

    0: X / unconstrained
    1: I / invalid
    2: V / valid tuple

  Implementation note:

  This version models the pipe procedurally. The traced registers are stored in
  arrays, and most next-state behavior is computed in one `always @(*)` block.
  This makes `pipe_sched01` useful as an executable schedule reference, but it
  deliberately does not expose the register-by-register structure as clearly as
  the future structural implementation should.
*/

`ifndef PIPE_SCHED01_V
`define PIPE_SCHED01_V

module pipe_sched01
#(
  parameter p_last_frame = 5,
  parameter p_num_regs   = 16
)(
  input  logic                       clk,
  input  logic                       reset,
  input  logic                       advance_i,

  input  logic                       lpv_val_i,
  output logic                       lpv_rdy_o,
  input  logic [15:0]                lpv_msg_i,

  output logic                       done_o,
  output logic                       dbg_advance_o,
  output logic [7:0]                 dbg_i_o,
  output logic [7:0]                 dbg_k_o,
  output logic [2*p_num_regs-1:0]    dbg_status_o,
  output logic [16*p_num_regs-1:0]   dbg_value_o
);

  localparam c_status_x = 2'd0;
  localparam c_status_i = 2'd1;
  localparam c_status_v = 2'd2;

  localparam c_reg_a  = 0;
  localparam c_reg_r0 = 1;
  localparam c_reg_r1 = 2;
  localparam c_reg_r2 = 3;
  localparam c_reg_r3 = 4;
  localparam c_reg_r4 = 5;
  localparam c_reg_r5 = 6;
  localparam c_reg_r6 = 7;
  localparam c_reg_r7 = 8;
  localparam c_reg_r8 = 9;
  localparam c_reg_d2 = 10;
  localparam c_reg_d3 = 11;
  localparam c_reg_d4 = 12;
  localparam c_reg_d5 = 13;
  localparam c_reg_d6 = 14;
  localparam c_reg_f6 = 15;

  logic [7:0]  epoch_i_reg;
  logic [7:0]  epoch_k_reg;
  logic        done_reg;
  logic        dbg_advance_reg;

  logic [1:0]  reg_status [0:p_num_regs-1];
  logic [15:0] reg_value  [0:p_num_regs-1];
  logic [15:0] mem_value  [0:15];

  logic [1:0]  next_status [0:p_num_regs-1];
  logic [15:0] next_value  [0:p_num_regs-1];
  logic [15:0] next_r0_value;
  logic [1:0]  next_r0_status;
  logic        real_frame;
  logic        drain_epoch;
  logic        needs_input;
  logic        real_go;
  logic        drain_go;
  logic        pipe_go;
  logic        mem_write_en;
  logic [3:0]  mem_write_idx;

  function logic [15:0] make_tuple
  (
    input logic [7:0] x,
    input logic [7:0] y
  );
  begin
    make_tuple = { x, y };
  end
  endfunction

  function logic [1:0] combine_status2
  (
    input logic [1:0] in0_status,
    input logic [1:0] in1_status
  );
  begin
    if ( ( in0_status == c_status_x ) || ( in1_status == c_status_x ) )
      combine_status2 = c_status_x;
    else if ( ( in0_status == c_status_i ) || ( in1_status == c_status_i ) )
      combine_status2 = c_status_i;
    else
      combine_status2 = c_status_v;
  end
  endfunction

  function logic [1:0] combine_status3
  (
    input logic [1:0] in0_status,
    input logic [1:0] in1_status,
    input logic [1:0] in2_status
  );
  begin
    if ( ( in0_status == c_status_x ) ||
         ( in1_status == c_status_x ) ||
         ( in2_status == c_status_x ) )
      combine_status3 = c_status_x;
    else if ( ( in0_status == c_status_i ) ||
              ( in1_status == c_status_i ) ||
              ( in2_status == c_status_i ) )
      combine_status3 = c_status_i;
    else
      combine_status3 = c_status_v;
  end
  endfunction

  function logic [15:0] p1_result
  (
    input logic [15:0] a_value,
    input logic [15:0] r1_value
  );
  begin
    p1_result = {
      a_value[15:8] + r1_value[15:8],
      a_value[7:0]  + r1_value[7:0]
    };
  end
  endfunction

  function logic [15:0] p6_result
  (
    input logic [15:0] r6_value,
    input logic [15:0] d6_value,
    input logic [15:0] f6_value
  );
  begin
    p6_result = {
      r6_value[15:8],
      r6_value[7:0] + d6_value[7:0] + f6_value[7:0]
    };
  end
  endfunction

  integer r;

  always @(*) begin
    real_frame   = ( epoch_i_reg <= p_last_frame[7:0] );
    drain_epoch  = ( epoch_i_reg == ( p_last_frame[7:0] + 8'd1 ) );
    needs_input  = real_frame;
    real_go      = needs_input && lpv_val_i && lpv_rdy_o;
    drain_go     = !needs_input && advance_i && !done_reg;
    pipe_go      = real_go || drain_go;

    for ( r = 0; r < p_num_regs; r = r + 1 ) begin
      next_status[r] = reg_status[r];
      next_value[r]  = reg_value[r];
    end

    // A holds the current frame header during real frames. During the drain
    // epoch it becomes architecturally irrelevant even if the physical bits
    // could have retained the previous header.

    if ( epoch_i_reg == 8'd0 ) begin
      next_status[c_reg_a] = c_status_i;
      next_value[c_reg_a]  = 16'b0;
    end
    else if ( real_frame && ( epoch_k_reg == 8'd0 ) ) begin
      next_status[c_reg_a] = c_status_v;
      next_value[c_reg_a]  = lpv_msg_i;
    end
    else if ( drain_epoch && ( epoch_k_reg == 8'd0 ) ) begin
      next_status[c_reg_a] = c_status_i;
      next_value[c_reg_a]  = 16'b0;
    end

    // R0 is the M initialization path for frame 0, and later the feedback
    // path from R8/P8. Invalid selected feedback is represented as I.

    next_r0_status = c_status_i;
    next_r0_value  = 16'b0;

    if ( epoch_i_reg == 8'd0 ) begin
      if ( epoch_k_reg == 8'd0 ) begin
        next_r0_status = c_status_i;
        next_r0_value  = 16'b0;
      end
      else begin
        next_r0_status = c_status_v;
        next_r0_value  = lpv_msg_i;
      end
    end
    else begin
      if ( reg_status[c_reg_r8] == c_status_v ) begin
        next_r0_status = c_status_v;
        next_r0_value  = reg_value[c_reg_r8];
      end
      else begin
        next_r0_status = c_status_i;
        next_r0_value  = 16'b0;
      end
    end

    next_status[c_reg_r0] = next_r0_status;
    next_value[c_reg_r0]  = next_r0_value;

    // R1 reads the simplified M state during real frames after frame 0.

    if ( epoch_i_reg == 8'd0 ) begin
      next_status[c_reg_r1] = c_status_x;
      next_value[c_reg_r1]  = 16'b0;
    end
    else if ( real_frame && ( epoch_k_reg < 8'd16 ) ) begin
      next_status[c_reg_r1] = c_status_v;
      next_value[c_reg_r1]  = mem_value[epoch_k_reg[3:0]];
    end
    else begin
      next_status[c_reg_r1] = c_status_i;
      next_value[c_reg_r1]  = 16'b0;
    end

    // Main pipeline. Stage results are computed from pre-edge register values.

    next_status[c_reg_r2] = combine_status2( reg_status[c_reg_a], reg_status[c_reg_r1] );
    next_value[c_reg_r2]  = p1_result( reg_value[c_reg_a], reg_value[c_reg_r1] );

    next_status[c_reg_r3] = reg_status[c_reg_r2];
    next_value[c_reg_r3]  = reg_value[c_reg_r2];
    next_status[c_reg_r4] = reg_status[c_reg_r3];
    next_value[c_reg_r4]  = reg_value[c_reg_r3];
    next_status[c_reg_r5] = reg_status[c_reg_r4];
    next_value[c_reg_r5]  = reg_value[c_reg_r4];
    next_status[c_reg_r6] = reg_status[c_reg_r5];
    next_value[c_reg_r6]  = reg_value[c_reg_r5];

    next_status[c_reg_r7] = combine_status3(
      reg_status[c_reg_r6], reg_status[c_reg_d6], reg_status[c_reg_f6]
    );
    next_value[c_reg_r7] = p6_result(
      reg_value[c_reg_r6], reg_value[c_reg_d6], reg_value[c_reg_f6]
    );

    next_status[c_reg_r8] = reg_status[c_reg_r7];
    next_value[c_reg_r8]  = reg_value[c_reg_r7];

    // D side path. Header/drain beats are invalid for this path.

    if ( real_frame && ( epoch_i_reg > 8'd0 ) && ( epoch_k_reg > 8'd0 ) ) begin
      next_status[c_reg_d2] = c_status_v;
      next_value[c_reg_d2]  = lpv_msg_i;
    end
    else begin
      next_status[c_reg_d2] = c_status_i;
      next_value[c_reg_d2]  = 16'b0;
    end

    next_status[c_reg_d3] = reg_status[c_reg_d2];
    next_value[c_reg_d3]  = reg_value[c_reg_d2];
    next_status[c_reg_d4] = reg_status[c_reg_d3];
    next_value[c_reg_d4]  = reg_value[c_reg_d3];
    next_status[c_reg_d5] = reg_status[c_reg_d4];
    next_value[c_reg_d5]  = reg_value[c_reg_d4];
    next_status[c_reg_d6] = reg_status[c_reg_d5];
    next_value[c_reg_d6]  = reg_value[c_reg_d5];

    // F6 captures from the pre-edge D2 value at group boundaries and holds
    // otherwise. The k=4 slot is an intentional invalid gap.

    if ( epoch_k_reg == 8'd4 ) begin
      next_status[c_reg_f6] = c_status_i;
      next_value[c_reg_f6]  = 16'b0;
    end
    else if ( ( epoch_k_reg == 8'd0 ) ||
              ( epoch_k_reg == 8'd5 ) ||
              ( epoch_k_reg == 8'd9 ) ||
              ( epoch_k_reg == 8'd13 ) ) begin
      next_status[c_reg_f6] = reg_status[c_reg_d2];
      next_value[c_reg_f6]  = reg_value[c_reg_d2];
    end
  end

  always @( posedge clk ) begin
    if ( reset ) begin
      epoch_i_reg <= 8'd0;
      epoch_k_reg <= 8'd0;
      done_reg    <= 1'b0;
      dbg_advance_reg <= 1'b0;

      for ( r = 0; r < p_num_regs; r = r + 1 ) begin
        reg_status[r] <= c_status_x;
        reg_value[r]  <= 16'b0;
      end

      for ( r = 0; r < 16; r = r + 1 ) begin
        mem_value[r] <= 16'b0;
      end
    end
    else if ( pipe_go && !done_reg ) begin
      dbg_advance_reg <= 1'b1;

      for ( r = 0; r < p_num_regs; r = r + 1 ) begin
        reg_status[r] <= next_status[r];
        reg_value[r]  <= next_value[r];
      end

      mem_write_en  = 1'b0;
      mem_write_idx = 4'b0;

      if ( epoch_i_reg == 8'd0 ) begin
        if ( epoch_k_reg > 8'd0 ) begin
          mem_write_en  = 1'b1;
          mem_write_idx = epoch_k_reg[3:0] - 4'd1;
        end
      end
      else if ( next_r0_status == c_status_v ) begin
        if ( epoch_k_reg >= 8'd8 ) begin
          mem_write_en  = 1'b1;
          mem_write_idx = epoch_k_reg[3:0] - 4'd8;
        end
        else if ( epoch_k_reg <= 8'd6 ) begin
          mem_write_en  = 1'b1;
          mem_write_idx = epoch_k_reg[3:0] + 4'd9;
        end
      end

      if ( mem_write_en )
        mem_value[mem_write_idx] <= next_r0_value;

      if ( drain_epoch && ( epoch_k_reg == 8'd6 ) ) begin
        done_reg <= 1'b1;
      end
      else if ( epoch_k_reg == 8'd16 ) begin
        epoch_i_reg <= epoch_i_reg + 8'd1;
        epoch_k_reg <= 8'd0;
      end
      else begin
        epoch_k_reg <= epoch_k_reg + 8'd1;
      end
    end
    else begin
      dbg_advance_reg <= 1'b0;
    end
  end

  genvar g;
  generate
    for ( g = 0; g < p_num_regs; g = g + 1 ) begin : DBG
      assign dbg_status_o[(2*g)+1:(2*g)]     = reg_status[g];
      assign dbg_value_o[(16*g)+15:(16*g)]   = reg_value[g];
    end
  endgenerate

  assign dbg_i_o = epoch_i_reg;
  assign dbg_k_o = epoch_k_reg;
  assign done_o  = done_reg;
  assign dbg_advance_o = dbg_advance_reg;
  assign lpv_rdy_o = advance_i && needs_input && !done_reg;

endmodule

`endif /* PIPE_SCHED01_V */
