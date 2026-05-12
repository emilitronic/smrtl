# Framemetagen Pipe Test Flow

This test flow drives raw data into `pipe_framemetagen01`.

The DUT internally generates `{ frame_id, beat_idx, first, last, data }` with
`pipe_framemeta_framer`, sends those beats through `pipe_framemeta_data`, and
checks the metadata-preserving sink output.

## Using Makefile
In `pipes/tb/framemetagen`
```sh
make run PIPE_STAGES=4 PIPE_COUNT=12 FRAME_LEN=5 RUN_ARGS=
make trace PIPE_STAGES=4 PIPE_COUNT=12 FRAME_LEN=5 RUN_ARGS='+test-case=1'
```

## What You'll See
When running in `pipes/tb/framemetagen` as described above:
```sh
$ make trace PIPE_STAGES=4 PIPE_COUNT=12 FRAME_LEN=5 RUN_ARGS='+test-case=1'
python3 gen_pipevecs_framemetagen.py --stages 4 --count 12 --frame-len 5 --frame-id-nbits 4 --beat-idx-nbits 8 --data-nbits 64 --output generated/pipevecs_framemetagen_4_12_5_4_8_64.svh
cp generated/pipevecs_framemetagen_4_12_5_4_8_64.svh generated/current_pipevecs.svh
../../build/asic-framemetagen-exe +test-case=1 +trace=1

 Test Suite: pipe_framemetagen01
  + Test Case 1: framemetagen, no random delays
   0:          || .                > i:0000	   mfrm:idle                  > :00/00 n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- > .        || .                   
   1: 00000000 || #                > start	   mfrm:idle                  > :00/00 n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   2: 0000000c || #                > nt:000c	 mfrm:idle                  > :00/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   3: .        || 0000000000000011 > un:000c	 mfrm:00/0c fid:0 bid:00/05 > :00/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   4: .        || 0000000000000022 > un:000c	 mfrm:01/0c fid:0 bid:01/05 > :00/0c n:04 fid:0 bid:00 fst:1 lst:0 dat:0012|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   5: .        || 0000000000000033 > un:000c	 mfrm:02/0c fid:0 bid:02/05 > :00/0c n:04 fid:0 bid:01 fst:0 lst:0 dat:0023|fid:0 bid:00 fst:1 lst:0 dat:0013|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   6: .        || 0000000000000044 > un:000c	 mfrm:03/0c fid:0 bid:03/05 > :00/0c n:04 fid:0 bid:02 fst:0 lst:0 dat:0034|fid:0 bid:01 fst:0 lst:0 dat:0024|fid:0 bid:00 fst:1 lst:0 dat:0014|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   7: .        || 0000000000000055 > un:000c	 mfrm:04/0c fid:0 bid:04/05 > :00/0c n:04 fid:0 bid:03 fst:0 lst:0 dat:0045|fid:0 bid:02 fst:0 lst:0 dat:0035|fid:0 bid:01 fst:0 lst:0 dat:0025|fid:0 bid:00 fst:1 lst:0 dat:0015 >          || 00020000000000000015
   8: .        || 0000000000000066 > un:000c	 mfrm:05/0c fid:1 bid:00/05 > :01/0c n:04 fid:0 bid:04 fst:0 lst:1 dat:0056|fid:0 bid:03 fst:0 lst:0 dat:0046|fid:0 bid:02 fst:0 lst:0 dat:0036|fid:0 bid:01 fst:0 lst:0 dat:0026 >          || 00040000000000000026
   9: .        || 0000000000000077 > un:000c	 mfrm:06/0c fid:1 bid:01/05 > :02/0c n:04 fid:1 bid:00 fst:1 lst:0 dat:0067|fid:0 bid:04 fst:0 lst:1 dat:0057|fid:0 bid:03 fst:0 lst:0 dat:0047|fid:0 bid:02 fst:0 lst:0 dat:0037 >          || 00080000000000000037
  10: .        || 0000000000000088 > un:000c	 mfrm:07/0c fid:1 bid:02/05 > :03/0c n:04 fid:1 bid:01 fst:0 lst:0 dat:0078|fid:1 bid:00 fst:1 lst:0 dat:0068|fid:0 bid:04 fst:0 lst:1 dat:0058|fid:0 bid:03 fst:0 lst:0 dat:0048 >          || 000c0000000000000048
  11: .        || 0000000000000099 > un:000c	 mfrm:08/0c fid:1 bid:03/05 > :04/0c n:04 fid:1 bid:02 fst:0 lst:0 dat:0089|fid:1 bid:01 fst:0 lst:0 dat:0079|fid:1 bid:00 fst:1 lst:0 dat:0069|fid:0 bid:04 fst:0 lst:1 dat:0059 >          || 00110000000000000059
  12: .        || 00000000000000aa > un:000c	 mfrm:09/0c fid:1 bid:04/05 > :05/0c n:04 fid:1 bid:03 fst:0 lst:0 dat:009a|fid:1 bid:02 fst:0 lst:0 dat:008a|fid:1 bid:01 fst:0 lst:0 dat:007a|fid:1 bid:00 fst:1 lst:0 dat:006a >          || 0402000000000000006a
  13: .        || 00000000000000bb > un:000c	 mfrm:0a/0c fid:2 bid:00/05 > :06/0c n:04 fid:1 bid:04 fst:0 lst:1 dat:00ab|fid:1 bid:03 fst:0 lst:0 dat:009b|fid:1 bid:02 fst:0 lst:0 dat:008b|fid:1 bid:01 fst:0 lst:0 dat:007b >          || 0404000000000000007b
  14: .        || 00000000000000cc > un:000c	 mfrm:0b/0c fid:2 bid:01/05 > :07/0c n:04 fid:2 bid:00 fst:1 lst:0 dat:00bc|fid:1 bid:04 fst:0 lst:1 dat:00ac|fid:1 bid:03 fst:0 lst:0 dat:009c|fid:1 bid:02 fst:0 lst:0 dat:008c >          || 0408000000000000008c
  15: .        || .                > un:000c	 mfrm:idle                  > :08/0c n:04 fid:2 bid:01 fst:0 lst:1 dat:00cd|fid:2 bid:00 fst:1 lst:0 dat:00bd|fid:1 bid:04 fst:0 lst:1 dat:00ad|fid:1 bid:03 fst:0 lst:0 dat:009d >          || 040c000000000000009d
  16: .        || .                > un:000c	 mfrm:idle                  > :09/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:2 bid:01 fst:0 lst:1 dat:00ce|fid:2 bid:00 fst:1 lst:0 dat:00be|fid:1 bid:04 fst:0 lst:1 dat:00ae >          || 041100000000000000ae
  17: .        || .                > un:000c	 mfrm:idle                  > :0a/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:2 bid:01 fst:0 lst:1 dat:00cf|fid:2 bid:00 fst:1 lst:0 dat:00bf >          || 080200000000000000bf
  18: .        || .                > un:000c	 mfrm:idle                  > :0b/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:2 bid:01 fst:0 lst:1 dat:00d0 >          || 080500000000000000d0
  19: .        || .                > done	     mfrm:idle                  > :0c/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- > 00000001 || .                   

./framemetagen-test-harness.v:312: $finish called at 290 (1s)
```

If you have a checker in the pipe you'll see
```sh
$ make trace PIPE_STAGES=4 PIPE_COUNT=12 FRAME_LEN=5 RUN_ARGS='+test-case=1'
cp generated/pipevecs_framemetagen_4_12_5_4_8_64.svh generated/current_pipevecs.svh
../../build/asic-framemetagen-exe +test-case=1 +trace=1

 Test Suite: pipe_framemetagen01
  + Test Case 1: framemetagen, no random delays
   0:          || .                > i:0000	   mfrm:idle                  > chk:idle               > :00/00 n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- > .        || .                   
   1: 00000000 || #                > start	   mfrm:idle                  > chk:idle               > :00/00 n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   2: 0000000c || #                > nt:000c	 mfrm:idle                  > chk:idle               > :00/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   3: .        || 0000000000000011 > un:000c	 mfrm:00/0c fid:0 bid:00/05 > chk:00/0c fid:0 bid:00 > :00/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   4: .        || 0000000000000022 > un:000c	 mfrm:01/0c fid:0 bid:01/05 > chk:01/0c fid:0 bid:01 > :00/0c n:04 fid:0 bid:00 fst:1 lst:0 dat:0012|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   5: .        || 0000000000000033 > un:000c	 mfrm:02/0c fid:0 bid:02/05 > chk:02/0c fid:0 bid:02 > :00/0c n:04 fid:0 bid:01 fst:0 lst:0 dat:0023|fid:0 bid:00 fst:1 lst:0 dat:0013|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   6: .        || 0000000000000044 > un:000c	 mfrm:03/0c fid:0 bid:03/05 > chk:03/0c fid:0 bid:03 > :00/0c n:04 fid:0 bid:02 fst:0 lst:0 dat:0034|fid:0 bid:01 fst:0 lst:0 dat:0024|fid:0 bid:00 fst:1 lst:0 dat:0014|fid:- bid:-  fst:- lst:- dat:---- >          ||                     
   7: .        || 0000000000000055 > un:000c	 mfrm:04/0c fid:0 bid:04/05 > chk:04/0c fid:0 bid:04 > :00/0c n:04 fid:0 bid:03 fst:0 lst:0 dat:0045|fid:0 bid:02 fst:0 lst:0 dat:0035|fid:0 bid:01 fst:0 lst:0 dat:0025|fid:0 bid:00 fst:1 lst:0 dat:0015 >          || 00020000000000000015
   8: .        || 0000000000000066 > un:000c	 mfrm:05/0c fid:1 bid:00/05 > chk:05/0c fid:1 bid:00 > :01/0c n:04 fid:0 bid:04 fst:0 lst:1 dat:0056|fid:0 bid:03 fst:0 lst:0 dat:0046|fid:0 bid:02 fst:0 lst:0 dat:0036|fid:0 bid:01 fst:0 lst:0 dat:0026 >          || 00040000000000000026
   9: .        || 0000000000000077 > un:000c	 mfrm:06/0c fid:1 bid:01/05 > chk:06/0c fid:1 bid:01 > :02/0c n:04 fid:1 bid:00 fst:1 lst:0 dat:0067|fid:0 bid:04 fst:0 lst:1 dat:0057|fid:0 bid:03 fst:0 lst:0 dat:0047|fid:0 bid:02 fst:0 lst:0 dat:0037 >          || 00080000000000000037
  10: .        || 0000000000000088 > un:000c	 mfrm:07/0c fid:1 bid:02/05 > chk:07/0c fid:1 bid:02 > :03/0c n:04 fid:1 bid:01 fst:0 lst:0 dat:0078|fid:1 bid:00 fst:1 lst:0 dat:0068|fid:0 bid:04 fst:0 lst:1 dat:0058|fid:0 bid:03 fst:0 lst:0 dat:0048 >          || 000c0000000000000048
  11: .        || 0000000000000099 > un:000c	 mfrm:08/0c fid:1 bid:03/05 > chk:08/0c fid:1 bid:03 > :04/0c n:04 fid:1 bid:02 fst:0 lst:0 dat:0089|fid:1 bid:01 fst:0 lst:0 dat:0079|fid:1 bid:00 fst:1 lst:0 dat:0069|fid:0 bid:04 fst:0 lst:1 dat:0059 >          || 00110000000000000059
  12: .        || 00000000000000aa > un:000c	 mfrm:09/0c fid:1 bid:04/05 > chk:09/0c fid:1 bid:04 > :05/0c n:04 fid:1 bid:03 fst:0 lst:0 dat:009a|fid:1 bid:02 fst:0 lst:0 dat:008a|fid:1 bid:01 fst:0 lst:0 dat:007a|fid:1 bid:00 fst:1 lst:0 dat:006a >          || 0402000000000000006a
  13: .        || 00000000000000bb > un:000c	 mfrm:0a/0c fid:2 bid:00/05 > chk:0a/0c fid:2 bid:00 > :06/0c n:04 fid:1 bid:04 fst:0 lst:1 dat:00ab|fid:1 bid:03 fst:0 lst:0 dat:009b|fid:1 bid:02 fst:0 lst:0 dat:008b|fid:1 bid:01 fst:0 lst:0 dat:007b >          || 0404000000000000007b
  14: .        || 00000000000000cc > un:000c	 mfrm:0b/0c fid:2 bid:01/05 > chk:0b/0c fid:2 bid:01 > :07/0c n:04 fid:2 bid:00 fst:1 lst:0 dat:00bc|fid:1 bid:04 fst:0 lst:1 dat:00ac|fid:1 bid:03 fst:0 lst:0 dat:009c|fid:1 bid:02 fst:0 lst:0 dat:008c >          || 0408000000000000008c
  15: .        || .                > un:000c	 mfrm:idle                  > chk:idle               > :08/0c n:04 fid:2 bid:01 fst:0 lst:1 dat:00cd|fid:2 bid:00 fst:1 lst:0 dat:00bd|fid:1 bid:04 fst:0 lst:1 dat:00ad|fid:1 bid:03 fst:0 lst:0 dat:009d >          || 040c000000000000009d
  16: .        || .                > un:000c	 mfrm:idle                  > chk:idle               > :09/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:2 bid:01 fst:0 lst:1 dat:00ce|fid:2 bid:00 fst:1 lst:0 dat:00be|fid:1 bid:04 fst:0 lst:1 dat:00ae >          || 041100000000000000ae
  17: .        || .                > un:000c	 mfrm:idle                  > chk:idle               > :0a/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:2 bid:01 fst:0 lst:1 dat:00cf|fid:2 bid:00 fst:1 lst:0 dat:00bf >          || 080200000000000000bf
  18: .        || .                > un:000c	 mfrm:idle                  > chk:idle               > :0b/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:2 bid:01 fst:0 lst:1 dat:00d0 >          || 080500000000000000d0
  19: .        || .                > done	     mfrm:idle                  > chk:idle               > :0c/0c n:04 fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:----|fid:- bid:-  fst:- lst:- dat:---- > 00000001 || .                   

./framemetagen-test-harness.v:312: $finish called at 290 (1s)
```