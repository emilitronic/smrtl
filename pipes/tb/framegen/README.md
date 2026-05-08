# Framegen Pipe Test Flow

This test flow drives raw 64-bit data into `pipe_framegen01`.  A pipe system with a framer and control.

The DUT internally generates `{ first, last, data }` framebits with
`pipe_framer`, sends those framed beats through `pipe_framebits_data`, and
checks the framed sink output.

## Using Makefile
In `pipes/tb/framegen`
```bash
make run PIPE_STAGES=4 PIPE_COUNT=12 FRAME_LEN=5 RUN_ARGS=
make trace PIPE_STAGES=4 PIPE_COUNT=12 FRAME_LEN=5 RUN_ARGS='+test-case=1'
```

## What You'll See
```bash
$ make trace PIPE_STAGES=4 PIPE_COUNT=12 FRAME_LEN=5 RUN_ARGS='+test-case=1'
python3 gen_pipevecs_framegen.py --stages 4 --count 12 --frame-len 5 --output generated/pipevecs_framegen_4_12_5.svh
cp generated/pipevecs_framegen_4_12_5.svh generated/current_pipevecs.svh
../../build/asic-framegen-exe +test-case=1 +trace=1

 Test Suite: pipe_framegen01
  + Test Case 1: framegen, no random delays
   0:          || .                > i:0000	   frm:idle            > :00/00 n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- > .        || .                
   1: 00000000 || #                > start	   frm:idle            > :00/00 n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- >          ||                  
   2: 0000000c || #                > nt:000c	 frm:idle            > :00/0c n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- >          ||                  
   3: .        || 0000000000000011 > un:000c	 frm:00/0c pos:00/05 > :00/0c n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- >          ||                  
   4: .        || 0000000000000022 > un:000c	 frm:01/0c pos:01/05 > :00/0c n:04 fst:1 lst:0 dat:0012|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- >          ||                  
   5: .        || 0000000000000033 > un:000c	 frm:02/0c pos:02/05 > :00/0c n:04 fst:0 lst:0 dat:0023|fst:1 lst:0 dat:0013|fst:- lst:- dat:----|fst:- lst:- dat:---- >          ||                  
   6: .        || 0000000000000044 > un:000c	 frm:03/0c pos:03/05 > :00/0c n:04 fst:0 lst:0 dat:0034|fst:0 lst:0 dat:0024|fst:1 lst:0 dat:0014|fst:- lst:- dat:---- >          ||                  
   7: .        || 0000000000000055 > un:000c	 frm:04/0c pos:04/05 > :00/0c n:04 fst:0 lst:0 dat:0045|fst:0 lst:0 dat:0035|fst:0 lst:0 dat:0025|fst:1 lst:0 dat:0015 >          || 20000000000000015
   8: .        || 0000000000000066 > un:000c	 frm:05/0c pos:00/05 > :01/0c n:04 fst:0 lst:1 dat:0056|fst:0 lst:0 dat:0046|fst:0 lst:0 dat:0036|fst:0 lst:0 dat:0026 >          || 00000000000000026
   9: .        || 0000000000000077 > un:000c	 frm:06/0c pos:01/05 > :02/0c n:04 fst:1 lst:0 dat:0067|fst:0 lst:1 dat:0057|fst:0 lst:0 dat:0047|fst:0 lst:0 dat:0037 >          || 00000000000000037
  10: .        || 0000000000000088 > un:000c	 frm:07/0c pos:02/05 > :03/0c n:04 fst:0 lst:0 dat:0078|fst:1 lst:0 dat:0068|fst:0 lst:1 dat:0058|fst:0 lst:0 dat:0048 >          || 00000000000000048
  11: .        || 0000000000000099 > un:000c	 frm:08/0c pos:03/05 > :04/0c n:04 fst:0 lst:0 dat:0089|fst:0 lst:0 dat:0079|fst:1 lst:0 dat:0069|fst:0 lst:1 dat:0059 >          || 10000000000000059
  12: .        || 00000000000000aa > un:000c	 frm:09/0c pos:04/05 > :05/0c n:04 fst:0 lst:0 dat:009a|fst:0 lst:0 dat:008a|fst:0 lst:0 dat:007a|fst:1 lst:0 dat:006a >          || 2000000000000006a
  13: .        || 00000000000000bb > un:000c	 frm:0a/0c pos:00/05 > :06/0c n:04 fst:0 lst:1 dat:00ab|fst:0 lst:0 dat:009b|fst:0 lst:0 dat:008b|fst:0 lst:0 dat:007b >          || 0000000000000007b
  14: .        || 00000000000000cc > un:000c	 frm:0b/0c pos:01/05 > :07/0c n:04 fst:1 lst:0 dat:00bc|fst:0 lst:1 dat:00ac|fst:0 lst:0 dat:009c|fst:0 lst:0 dat:008c >          || 0000000000000008c
  15: .        || .                > un:000c	 frm:idle            > :08/0c n:04 fst:0 lst:1 dat:00cd|fst:1 lst:0 dat:00bd|fst:0 lst:1 dat:00ad|fst:0 lst:0 dat:009d >          || 0000000000000009d
  16: .        || .                > un:000c	 frm:idle            > :09/0c n:04 fst:- lst:- dat:----|fst:0 lst:1 dat:00ce|fst:1 lst:0 dat:00be|fst:0 lst:1 dat:00ae >          || 100000000000000ae
  17: .        || .                > un:000c	 frm:idle            > :0a/0c n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:0 lst:1 dat:00cf|fst:1 lst:0 dat:00bf >          || 200000000000000bf
  18: .        || .                > un:000c	 frm:idle            > :0b/0c n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:0 lst:1 dat:00d0 >          || 100000000000000d0
  19: .        || .                > done	     frm:idle            > :0c/0c n:04 fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:----|fst:- lst:- dat:---- > 00000001 || .                

./framegen-test-harness.v:309: $finish called at 290 (1s)

```
To begin with, you are sending a start signal to your pipe's controller (cycle 1).  Then on cycle 2 you are indicating how many total beats need to be processed (12 in this case).