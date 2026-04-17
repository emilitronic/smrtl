//========================================================================
// PIPES Test Cases pipes/tb/asic-test-cases.svh
//========================================================================
// Sebastian Claudiusz Magierowski Apr 8 2026
/*
send a series of initiation messages to DUT and wait for a finished message from DUT
send a data sequence (of known length) to DUT
*/
// this file is to be `included by asic-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task input_program;
begin
  init_ctrl_src( 32'h0000_0000 ); // start word
  init_ctrl_src( 32'h0000_0003 ); // number of inputs to process
  init_ctrl_snk( 32'h0000_0001 ); // what the sink expects to see

  init_data_src( 64'h0000_0000_0000_0011 );
  init_data_src( 64'h0000_0000_0000_0022 );
  init_data_src( 64'h0000_0000_0000_0033 );

  init_data_snk( 64'h0000_0000_0000_0011 );
  init_data_snk( 64'h0000_0000_0000_0022 );
  init_data_snk( 64'h0000_0000_0000_0033 );
end
endtask

//------------------------------------------------------------------------
// Test Case:
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "control program plus 3 data words" ) // +test_case=1
begin
  clear_streams();
  init_rand_delays( 0, 0, 0, 0 ); // no random delays
  input_program();
  run_test();
end
`VC_TEST_CASE_END
