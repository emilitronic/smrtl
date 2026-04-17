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
  init_ctrl_src( 32'h0000_0000 ); // load the control source with a simple command
  init_ctrl_snk( 32'h0000_0001 ); // what the sink expects to see
end
endtask

//------------------------------------------------------------------------
// Test Case:
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "control test" ) // +test_case=1
begin
  clear_streams();
  init_rand_delays( 0, 0, 0, 0 ); // no random delays
  input_program();
  run_test();
end
`VC_TEST_CASE_END
