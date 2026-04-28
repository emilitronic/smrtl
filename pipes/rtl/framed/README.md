# Framed RTL

This directory is reserved for framed-pipe variants. The current Stage 1
baseline is the framebits pipe, which carries only `first`, `last`, and
`data`.

Now the system uses sideband frame boundary labels.  Two extra bits are carried to indicate whether signals are first, middle, or last in a frame.

## Frame boundary encoding

| `first` | `last` | Beat meaning |
|---:|---:|---|
| 0 | 0 | Middle beat |
| 0 | 1 | Last beat |
| 1 | 0 | First beat |
| 1 | 1 | Only beat in the frame (single-beat frame) |

```
                 _____________________
                | pipe-framebits01.v  |
                |                     |
                |    pipe_ctrl.v      |
                |        |            |
                |        V            |
pipe-framer.v ->| pipe-framebits-data.v |
                |        A            |
                |        |            |
                | pipe-framebits-stage.v |     
                `_____________________'
```

## Using Makefile
In `pipes/tb/framebits`
```bash
# run all test cases with 5 vectors
$ make run PIPE_COUNT=5 RUN_ARGS=
# see all traces as well
$ make trace PIPE_COUNT=5 RUN_ARGS=
# see just one trace
$ make trace PIPE_COUNT=5 RUN_ARGS='+test-case=4'
# vary the number of stages
$ make run PIPE_STAGES=5 PIPE_COUNT=8 RUN_ARGS=
# run a new frame pattern (default is 3,1), 1-beat frame, 2-beat frame, 5-beat frame, repeat until pipe count exhausted
$ make run PIPE_STAGES=4 PIPE_COUNT=12 FRAME_PATTERN=1,2,5 RUN_ARGS=
```

## What You'll See
```bash
# try this
$ make trace PIPE_STAGES=4 PIPE_COUNT=12 FRAME_PATTERN=1,2,5 RUN_ARGS='+test-case=1'
cp generated/pipevecs_framebits_4_12_1_2_5.svh generated/current_pipevecs.svh
../../build/asic-framebits-exe +test-case=1 +trace=1

 Test Suite: pipe_framebits01
  + Test Case 1: framebits pipe, no random delays
   0:          || .                 > i:0000	 :00/00 n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- > .        || .                
   1: 00000000 || #                 > start	   :00/00 n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- >          ||                  
   2: 0000000c || #                 > nt:000c	 :00/00 n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- >          ||                  
   3: .        || 30000000000000011 > un:000c	 :00/0c n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- >          ||                  
   4: .        || 20000000000000022 > un:000c	 :00/0c n:04 fst:1 lst:1 dat:0012|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- >          ||                  
   5: .        || 10000000000000033 > un:000c	 :00/0c n:04 fst:1 lst:0 dat:0023|fst:1 lst:1 dat:0013|fst:- lst:- dat:----|fst:- lst:- dat:---- >          ||                  
   6: .        || 20000000000000044 > un:000c	 :00/0c n:04 fst:0 lst:1 dat:0034|fst:1 lst:0 dat:0024|fst:1 lst:1 dat:0014|fst:- lst:- dat:---- >          ||                  
   7: .        || 00000000000000055 > un:000c	 :00/0c n:04 fst:1 lst:0 dat:0045|fst:0 lst:1 dat:0035|fst:1 lst:0 dat:0025|fst:1 lst:1 dat:0015 >          || 30000000000000015
   8: .        || 00000000000000066 > un:000c	 :01/0c n:04 fst:0 lst:0 dat:0056|fst:1 lst:0 dat:0046|fst:0 lst:1 dat:0036|fst:1 lst:0 dat:0026 >          || 20000000000000026
   9: .        || 00000000000000077 > un:000c	 :02/0c n:04 fst:0 lst:0 dat:0067|fst:0 lst:0 dat:0057|fst:1 lst:0 dat:0047|fst:0 lst:1 dat:0037 >          || 10000000000000037
  10: .        || 10000000000000088 > un:000c	 :03/0c n:04 fst:0 lst:0 dat:0078|fst:0 lst:0 dat:0068|fst:0 lst:0 dat:0058|fst:1 lst:0 dat:0048 >          || 20000000000000048
  11: .        || 30000000000000099 > un:000c	 :04/0c n:04 fst:0 lst:1 dat:0089|fst:0 lst:0 dat:0079|fst:0 lst:0 dat:0069|fst:0 lst:0 dat:0059 >          || 00000000000000059
  12: .        || 200000000000000aa > un:000c	 :05/0c n:04 fst:1 lst:1 dat:009a|fst:0 lst:1 dat:008a|fst:0 lst:0 dat:007a|fst:0 lst:0 dat:006a >          || 0000000000000006a
  13: .        || 100000000000000bb > un:000c	 :06/0c n:04 fst:1 lst:0 dat:00ab|fst:1 lst:1 dat:009b|fst:0 lst:1 dat:008b|fst:0 lst:0 dat:007b >          || 0000000000000007b
  14: .        || 300000000000000cc > un:000c	 :07/0c n:04 fst:0 lst:1 dat:00bc|fst:1 lst:0 dat:00ac|fst:1 lst:1 dat:009c|fst:0 lst:1 dat:008c >          || 1000000000000008c
  15: .        ||                   > un:000c	 :08/0c n:04 fst:1 lst:1 dat:00cd|fst:0 lst:1 dat:00bd|fst:1 lst:0 dat:00ad|fst:1 lst:1 dat:009d >          || 3000000000000009d
  16: .        ||                   > un:000c	 :09/0c n:04 fst:- lst:- dat:----|fst:1 lst:1 dat:00ce|fst:0 lst:1 dat:00be|fst:1 lst:0 dat:00ae >          || 200000000000000ae
  17: .        ||                   > un:000c	 :0a/0c n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:1 lst:1 dat:00cf|fst:0 lst:1 dat:00bf >          || 100000000000000bf
  18: .        ||                   > un:000c	 :0b/0c n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:1 lst:1 dat:00d0 >          || 300000000000000d0
  19: .        || .                 > done	   :0c/0c n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- > 00000001 || .                

../asic-test-harness.v:413: $finish called at 290 (1s)
```
To begin with, you are sending a start signal to your pipe's controller (cycle 1).  Then on cycle 2 you are indicating how many total beats need to be processed (12 in this case).


## Details
What's happening under the hood? For example, when running
```bash
$ make run PIPE_STAGES=4 PIPE_COUNT=12 RUN_ARGS=
```
the execution will look for `tb/framebits/generated/pipevecs_framebits_4_12_3_1.svh`. If that file already exists and is up to date, Make will copy it to `tb/framebits/generated/current_pipevecs.svh`; otherwise Make will run `tb/framebits/gen_pipevecs_framebits.py` first. The test harness includes `current_pipevecs.svh` to get the test vectors for the simulation.
