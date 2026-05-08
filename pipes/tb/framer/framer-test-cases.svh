//========================================================================
// Pipe Framer Test Cases pipes/tb/framer/framer-test-cases.svh
//========================================================================
// Sebastian Claudiusz Magierowski May 8 2026

task current_pipevecs;
begin
  `include "generated/current_pipevecs.svh"
end
endtask

`VC_TEST_CASE_BEGIN( 1, "framer, no random delays" )
begin
  clear_streams();
  init_config( `PIPE_COUNT, `FRAME_LEN );
  init_rand_delays( 0, 0 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 2, "framer, raw source random delays" )
begin
  clear_streams();
  init_config( `PIPE_COUNT, `FRAME_LEN );
  init_rand_delays( 4, 0 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 3, "framer, framed sink random delays" )
begin
  clear_streams();
  init_config( `PIPE_COUNT, `FRAME_LEN );
  init_rand_delays( 0, 4 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 4, "framer, all random delays" )
begin
  clear_streams();
  init_config( `PIPE_COUNT, `FRAME_LEN );
  init_rand_delays( 4, 4 );
  current_pipevecs();
  run_test();
end
`VC_TEST_CASE_END
