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

`VC_TEST_CASE_BEGIN( 1, "no random delays" ) // +test_case=1
begin
  clear_streams();
  init_rand_delays( 0, 0, 0, 0 ); // no random delays
  pipevecs_1_3();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 2, "control path random delays" ) // +test_case=2
begin
  clear_streams();
  init_rand_delays( 4, 4, 0, 0 );
  pipevecs_1_3();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 3, "data path random delays" ) // +test_case=3
begin
  clear_streams();
  init_rand_delays( 0, 0, 4, 4 );
  pipevecs_1_3();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 4, "all paths random delays" ) // +test_case=4
begin
  clear_streams();
  init_rand_delays( 4, 4, 4, 4 );
  pipevecs_1_3();
  run_test();
end
`VC_TEST_CASE_END
