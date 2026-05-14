//========================================================================
// pipes/rtl/framed/pipe-framemeta-checker.v
//========================================================================
// Sebastian Claudiusz Magierowski May 12 2026
/*
  Transparent framemeta stream checker.

  This block passes `{ frame_id, beat_idx, first, last, data }` through
  unchanged, while independently reconstructing the frame position from
  `start_i`, `num_inputs_i`, `frame_len_i`, and valid/ready handshakes.

  The reconstructed position is compared against the carried metadata during
  simulation only. Functional logic must not depend on the carried metadata.

  What's the point?  When the checker follows some block
*/

`ifndef PIPE_FRAMEMETA_CHECKER_V
`define PIPE_FRAMEMETA_CHECKER_V

`ifndef SYNTHESIS
`include "vc-trace.v"
`endif

module pipe_framemeta_checker
#(
  parameter p_frame_id_nbits = 4,
  parameter p_beat_idx_nbits = 8,
  parameter p_data_nbits     = 64,
  parameter p_msg_nbits      = p_frame_id_nbits + p_beat_idx_nbits + 2 + p_data_nbits
)(
  input  logic                    clk,
  input  logic                    reset,

  input  logic                    start_i,
  input  logic [31:0]             num_inputs_i,
  input  logic [31:0]             frame_len_i,

  input  logic                    in_val_i,
  output logic                    in_rdy_o,
  input  logic [p_msg_nbits-1:0]  in_msg_i,

  output logic                    out_val_o,
  input  logic                    out_rdy_i,
  output logic [p_msg_nbits-1:0]  out_msg_o
);

  localparam c_data_lsb        = 0;
  localparam c_data_msb        = p_data_nbits - 1;
  localparam c_last_bit        = p_data_nbits;
  localparam c_first_bit       = p_data_nbits + 1;
  localparam c_beat_idx_lsb    = p_data_nbits + 2;
  localparam c_beat_idx_msb    = c_beat_idx_lsb + p_beat_idx_nbits - 1;
  localparam c_frame_id_lsb    = c_beat_idx_msb + 1;
  localparam c_frame_id_msb    = c_frame_id_lsb + p_frame_id_nbits - 1;

  logic running_reg;
  logic [31:0] total_idx_reg;
  logic [31:0] frame_idx_reg;
  logic [31:0] frame_id_reg;
  logic [31:0] frame_len_reg;
  logic [31:0] num_inputs_reg;
  logic        go;
  logic        expected_first;
  logic        expected_last;

  logic [p_frame_id_nbits-1:0] expected_frame_id;
  logic [p_beat_idx_nbits-1:0] expected_beat_idx;
  logic [p_frame_id_nbits-1:0] msg_frame_id;
  logic [p_beat_idx_nbits-1:0] msg_beat_idx;
  logic                        msg_first;
  logic                        msg_last;

  assign in_rdy_o  = out_rdy_i;
  assign out_val_o = in_val_i;
  assign out_msg_o = in_msg_i;

  assign go = in_val_i && in_rdy_o;
  // checker's locally reconstructed state
  assign expected_first    = ( frame_idx_reg == 32'd0 );
  assign expected_last     = ( frame_idx_reg + 32'd1 == frame_len_reg ) ||
                             ( total_idx_reg + 32'd1 == num_inputs_reg );
  assign expected_frame_id = frame_id_reg[p_frame_id_nbits-1:0];
  assign expected_beat_idx = frame_idx_reg[p_beat_idx_nbits-1:0];

  assign msg_frame_id = in_msg_i[c_frame_id_msb:c_frame_id_lsb];
  assign msg_beat_idx = in_msg_i[c_beat_idx_msb:c_beat_idx_lsb];
  assign msg_first    = in_msg_i[c_first_bit];
  assign msg_last     = in_msg_i[c_last_bit];

  always @( posedge clk ) begin
    if ( reset ) begin
      running_reg    <= 1'b0;
      total_idx_reg  <= 32'b0;
      frame_idx_reg  <= 32'b0;
      frame_id_reg   <= 32'b0;
      frame_len_reg  <= 32'b0;
      num_inputs_reg <= 32'b0;
    end
    else begin
      if ( start_i ) begin
        running_reg    <= ( num_inputs_i != 32'd0 ) && ( frame_len_i != 32'd0 );
        total_idx_reg  <= 32'b0;
        frame_idx_reg  <= 32'b0;
        frame_id_reg   <= 32'b0;
        frame_len_reg  <= frame_len_i;
        num_inputs_reg <= num_inputs_i;
      end
      else if ( go ) begin
        if ( expected_last ) begin
          frame_idx_reg <= 32'b0;
          frame_id_reg  <= frame_id_reg + 32'd1;
        end
        else begin
          frame_idx_reg <= frame_idx_reg + 32'd1;
        end

        if ( total_idx_reg + 32'd1 == num_inputs_reg )
          running_reg <= 1'b0;

        total_idx_reg <= total_idx_reg + 32'd1;
      end
    end
  end

`ifndef SYNTHESIS
  //----------------------------------------------------------------------
  // Simulation Check
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( !reset && running_reg && go ) begin
      if ( ( msg_frame_id != expected_frame_id ) ||
           ( msg_beat_idx != expected_beat_idx ) ||
           ( msg_first    != expected_first    ) ||
           ( msg_last     != expected_last     ) ) begin
        $display(
          "\n[pipe_framemeta_checker FAILED] expected fid=%x bid=%x first=%x last=%x, actual fid=%x bid=%x first=%x last=%x",
          expected_frame_id, expected_beat_idx, expected_first, expected_last,
          msg_frame_id, msg_beat_idx, msg_first, msg_last
        );
        $finish;
      end
    end
  end

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  logic [255:0] state_str;

  `VC_TRACE_BEGIN
  begin
    if ( running_reg )
      $sformat( state_str, "chk:%x/%x fid:%x bid:%x",
        total_idx_reg[7:0], num_inputs_reg[7:0], expected_frame_id, expected_beat_idx );
    else
      $sformat( state_str, "chk:idle" );
    vc_trace.append_str( trace_str, state_str );
  end
  `VC_TRACE_END
`endif

endmodule

`endif /* PIPE_FRAMEMETA_CHECKER_V */
