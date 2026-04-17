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

task pipevecs_1_3;
begin
  `include "generated/current_pipevecs.svh"
end
endtask

//------------------------------------------------------------------------
// Test Case:
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "control program plus 3 data words" ) // +test_case=1
begin
  clear_streams();
  init_rand_delays( 0, 0, 0, 0 ); // no random delays
  pipevecs_1_3();
  run_test();
end
`VC_TEST_CASE_END
