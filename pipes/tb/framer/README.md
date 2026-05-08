# Framer Tests

This directory contains standalone tests for `pipe_framer`.

The framer converts raw 64-bit data beats into framebits messages:

```text
raw data -> { first, last, data }
```

## Using Makefile
In `pipes/tb/framer`
```bash
make run PIPE_COUNT=13 FRAME_LEN=4 RUN_ARGS=
make trace PIPE_COUNT=13 FRAME_LEN=4 RUN_ARGS='+test-case=1'
```

## What You'll See
```bash
$ make trace PIPE_COUNT=13 FRAME_LEN=4 RUN_ARGS='+test-case=1'
cp generated/pipevecs_framer_13_4.svh generated/current_pipevecs.svh
../../build/framer-exe +test-case=1 +trace=1

 Test Suite: pipe_framer
  + Test Case 1: framer, no random delays
   0: .                > frm:idle > .                
   1: 0000000000000011 > frm:00/0d pos:00/04 > 20000000000000011
   2: 0000000000000022 > frm:01/0d pos:01/04 > 00000000000000022
   3: 0000000000000033 > frm:02/0d pos:02/04 > 00000000000000033
   4: 0000000000000044 > frm:03/0d pos:03/04 > 10000000000000044
   5: 0000000000000055 > frm:04/0d pos:00/04 > 20000000000000055
   6: 0000000000000066 > frm:05/0d pos:01/04 > 00000000000000066
   7: 0000000000000077 > frm:06/0d pos:02/04 > 00000000000000077
   8: 0000000000000088 > frm:07/0d pos:03/04 > 10000000000000088
   9: 0000000000000099 > frm:08/0d pos:00/04 > 20000000000000099
  10: 00000000000000aa > frm:09/0d pos:01/04 > 000000000000000aa
  11: 00000000000000bb > frm:0a/0d pos:02/04 > 000000000000000bb
  12: 00000000000000cc > frm:0b/0d pos:03/04 > 100000000000000cc
  13: 00000000000000dd > frm:0c/0d pos:00/04 > 300000000000000dd

./framer-test-harness.v:246: $finish called at 220 (1s)
```