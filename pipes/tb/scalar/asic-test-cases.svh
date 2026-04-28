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

task current_pipevecs;
begin
  `include "generated/current_pipevecs.svh"
end
endtask

//------------------------------------------------------------------------
// Test Case:
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "pipe, no random delays" ) // +test_case=1
begin
  clear_streams();
  init_rand_delays( 0, 0, 0, 0 ); // no random delays
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 2, "pipe, control path random delays" ) // +test_case=2
begin
  clear_streams();
  init_rand_delays( 4, 4, 0, 0 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 3, "pipe, data path random delays" ) // +test_case=3
begin
  clear_streams();
  init_rand_delays( 0, 0, 4, 4 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 4, "pipe, all paths random delays" ) // +test_case=4
begin
  clear_streams();
  init_rand_delays( 4, 4, 4, 4 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END
