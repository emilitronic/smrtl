//========================================================================
// Pipe Framemetagen Test Cases pipes/tb/framemetagen/asic-test-cases.svh
//========================================================================
// Sebastian Claudiusz Magierowski May 8 2026

task current_pipevecs;
begin
  `include "generated/current_pipevecs.svh"
end
endtask

`VC_TEST_CASE_BEGIN( 1, "framemetagen, no random delays" )
begin
  clear_streams();
  init_rand_delays( 0, 0, 0, 0 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 2, "framemetagen, control path random delays" )
begin
  clear_streams();
  init_rand_delays( 4, 4, 0, 0 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 3, "framemetagen, data path random delays" )
begin
  clear_streams();
  init_rand_delays( 0, 0, 4, 4 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 4, "framemetagen, all random delays" )
begin
  clear_streams();
  init_rand_delays( 4, 4, 4, 4 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END

