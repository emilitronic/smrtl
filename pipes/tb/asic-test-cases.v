//========================================================================
// PIPES Test Cases pipes/tb/asic-test-cases.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 8 2026

// this file is to be `included by decoder.t.v
//
                                // instr 0: an initial command
localparam ev_addrs = 64'd0;    // instr 1: rs1 start address of events
localparam ev_count = 64'd2;    // instr 1: rs2 total number of events
localparam pt_addrs = 64'd4096; // instr 2: rs1 start address of pointers
localparam pt_count = 64'd1028; // instr 2: rs2 total number of pointers to produce
localparam st_addrs = 64'd8192; // instr 3: rs1 start address of end state
localparam pb_addrs = 64'd8200; // instr 3: rs2 address of max probability
localparam ev_step  = 64'd8;    // instr 4: rs1 number of bytes by which to increment address
localparam ev_size  = 64'd2;    // instr 4: rs2 size of event in bytes
                                // instr 5: final command (let's accel know it can start)

localparam c_r_dest_ptr = 32'h0030; // until we better understand how our 
                                    // mem works, more comments in 
                                    // decoder-test-harness.v in load_mem task
//                            k    a      
localparam init         = 32'h0000_0000;
localparam c_M_size     = 1; // # of rows in W, # of elements in o/p r
localparam c_N_size     = 2; // # of cols in W, # of elements in i/p x
localparam size         = {c_N_size[15:0],c_M_size[15:0]};

//------------------------------------------------------------------------
// Basic tests  
//------------------------------------------------------------------------

task init_2vecs; // opcode = 0, positive small numbers
begin
  clear_mem;
  //                                                              xs1
  //                rs2        rs1      cmd.funct7  rs2   rs1   xd xs2 rd   opcode
  load_from_mngr(0, {64'h0,    64'd0,    32'b0000000_00000_00000_0_0_0_00000_1111111}); // instr 0
  load_from_mngr(1, {ev_count, ev_addrs, 32'b0000001_00000_00000_0_1_1_00000_1111111}); // instr 1
  load_from_mngr(2, {pt_count, pt_addrs, 32'b0000010_00000_00000_0_1_1_00000_1111111}); // instr 2
  load_from_mngr(3, {pb_addrs, st_addrs, 32'b0000011_00000_00000_0_1_1_00000_1111111}); // instr 3
  // load_from_mngr(4, {64'h0,     c_r_dest_ptr,32'b0000000_00000_00000_0_1_1_00000_1111111});
  load_from_mngr(4, {ev_size,  ev_step,  32'b0000100_00000_00000_0_1_1_00000_1111111}); // instr 4
  load_from_mngr(5, {64'h0,    64'h0,    32'b1000000_00000_00000_0_0_0_00000_1111111}); // instr 5
  init_sink( 69'h01_0000000000000001 ); // what the sink expects to see
  init_pve_sml_data;            // put pos small data in mem & ref array
end
endtask

// feed RISC-V asm instrs into test src
task init_2vecs_asm; // opcode = 0, positive small numbers
begin
  clear_mem;
  // load the src with this command data (which only specified opcode  & funct7)
  //       rs2 rs1           cmd
  inst_src( 0, init,         "cmd f:1, o:0  " ); // cmd.init  + cmd.rs1 = k,a
  inst_src( 0, size,         "cmd f:2, o:0  " ); // cmd.size  + cmd.rs1 = N,M
  inst_src( 0, pt_addrs,     "cmd f:4, o:0  " ); // cmd.addrW + cmd.rs1 = Wptr
  inst_src( 0, st_addrs,     "cmd f:8, o:0  " ); // cmd.addrX + cmd.rs1 = xptr
  inst_src( 0, c_r_dest_ptr, "cmd f:16, o:0 " ); // cmd.addrR + cmd.rs1 = rptr
  // load the snk with this data (indicator of successful result)
  init_sink( 69'h01_0000000000000001 );
  init_pve_sml_data;            // put pos small data in mem & ref array
end
endtask

//------------------------------------------------------------------------
// initialize source and reference data for basic test
//------------------------------------------------------------------------

task init_pve_sml_data;
begin

  ubmark_name = "positive small data";
  ubmark_dest_size = c_M_size;

  address( ev_addrs ); // set test harness address
  data( 64'd30 );       // put data in current address and increment address
  data( 64'd1 );
  data( 64'd2 );
  data( 64'd3 );
  data( 64'd4 );
  data( 64'd5 );
  data( 64'd6 );
  data( 64'd7 );
  data( 64'd8 );
  data( 64'd9 );
  data( 64'd10 );
  data( 64'd11 );
  data( 64'd12 );
  data( 64'd13 );
  data( 64'd14 );
  data( 64'd15 );
  data( 64'd16 );
  data( 64'd17 );
  data( 64'd18 );
  data( 64'd19 );
  data( 64'd20 );
  data( 64'd21 );
  data( 64'd22 );
  data( 64'd23 );
  data( 64'd24 );
  data( 64'd25 );


  address( st_addrs ); 
  data( 64'd2 );
  data( 64'd3 );

  ref_address( c_r_dest_ptr );
  ref_data( 64'd8 );

end
endtask


//------------------------------------------------------------------------
// Test Case: 1x2 basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "basic 2 vec" ) // +test_case=1
begin
  init_rand_delays( 0, 0, 0 );
  init_2vecs;
  $write("ev[0]=%x\n", th.mem.mem.m[ ev_addrs    >>3]);
  $write("ev[1]=%x\n", th.mem.mem.m[(ev_addrs+ 8)>>3]);
  $write("ev[2]=%x\n", th.mem.mem.m[(ev_addrs+16)>>3]);
  $write("ev[3]=%x\n", th.mem.mem.m[(ev_addrs+24)>>3]);
  $write("ev[4]=%x\n", th.mem.mem.m[(ev_addrs+32)>>3]);
  run_test;
  $write("ev[0]=%x\n", th.mem.mem.m[ ev_addrs    >>3]);
  $write("ev[1]=%x\n", th.mem.mem.m[(ev_addrs+ 8)>>3]);
  $write("ev[2]=%x\n", th.mem.mem.m[(ev_addrs+16)>>3]);
  $write("ev[3]=%x\n", th.mem.mem.m[(ev_addrs+24)>>3]);
  $write("ev[4]=%x\n", th.mem.mem.m[(ev_addrs+32)>>3]);
  // verify;
  // $write("W[0,0]=%x\n", th.mem.mem.m[ c_ptr_ptr   >>3]);
  // $write("W[0,1]=%x\n", th.mem.mem.m[(c_ptr_ptr+8)>>3]);
  // $write("x[1]  =%x\n", th.mem.mem.m[(c_ptr_end+8)>>3]);
  // $write("x[1]  =%x\n", th.mem.mem.m[(c_ptr_end+8)>>3]);
  // $write("r[0]  =%x\n", th.mem.mem.m[32'h0030>>3]);
end
`VC_TEST_CASE_END


`VC_TEST_CASE_BEGIN( 2, "basic 2 vec from assembly" ) // +test_case=2
begin
  init_rand_delays( 0, 0, 0 );
  init_2vecs_asm;
  $write("W[0,0]=%x\n", th.mem.mem.m[ pt_addrs   >>3]);
  $write("W[0,1]=%x\n", th.mem.mem.m[(pt_addrs+8)>>3]);
  $write("x[0]  =%x\n", th.mem.mem.m[ st_addrs   >>3]);
  $write("x[1]  =%x\n", th.mem.mem.m[(st_addrs+8)>>3]);
  $write("r[0]  =%x\n", th.mem.mem.m[64'h0030>>3]);
  run_test;
  $write("W[0,0]=%x\n", th.mem.mem.m[ pt_addrs   >>3]);
  $write("W[0,1]=%x\n", th.mem.mem.m[(pt_addrs+8)>>3]);
  $write("x[0]  =%x\n", th.mem.mem.m[ st_addrs   >>3]);
  $write("x[1]  =%x\n", th.mem.mem.m[(st_addrs+8)>>3]);
  $write("r[0]  =%x\n", th.mem.mem.m[64'h0030>>3]);
  // verify;
  // $write("W[0,0]=%x\n", th.mem.mem.m[ c_ptr_ptr   >>3]);
  // $write("W[0,1]=%x\n", th.mem.mem.m[(c_ptr_ptr+8)>>3]);
  // $write("x[0]  =%x\n", th.mem.mem.m[ c_ptr_end   >>3]);
  // $write("x[1]  =%x\n", th.mem.mem.m[(c_ptr_end+8)>>3]);
  // $write("r[0]  =%x\n", th.mem.mem.m[32'h0030>>3]);
end
`VC_TEST_CASE_END

