# Pipelines (galore)

```
SRC -> | 1 -> SNK

SRC -> | 1 - | 2 -> SNK

SRC -> | 1 - | 2 - ... | N -> SNK

SRC -> FIFOi -> | 1 - | 2 - ... | N -> FIFOo -> SNK

```

Directory organization:

- `rtl/` for pipeline RTL modules
- `tb/` for the top-level simulation entry and testbench build flow

The intent is to begin from a very small scaffold and add:

- ingress buffering
- pipeline stages
- control
- egress buffering

one piece at a time.

```
________                       ______                         ________
        |----ctrl_src_val---->|      |------ctrl_snk_val---->|
ctrl_src|<---ctrl_src_rdy-----|      |<-----ctrl_snk_rdy-----|ctrl_snk 
        |----ctrl_src_msg---->|      |------ctrl_snk_msg---->|        
--------|                     | ASIC |                       |--------'
        |----data_src_val---->|      |------data_snk_val---->|
data_src|<---data_src_rdy-----|      |<-----data_snk_rdy-----|data_snk
        |----data_src_msg---->|      |------data_snk_msg---->|  
--------'                     '------'                       '--------'          
```

### Using Makefile
In `pipes/tb`
```bash
# make test vectors (default is 1 stage and 3 vectors)
% make gen
# but you can vary it, e.g., 2 stages and 5 vectors
% make gen PIPE_STAGES=2 PIPE_COUNT=5
# quiet default, it also generates the test vectors
% make run
# maybe you want to try different test cases
% make run RUN_ARGS='+test-case=1'
# or try all test cases
% make run RUN_ARGS='+test-case'
# or even simpler, run all test cases with (e.g., with some pipe settings)
% make run PIPE_STAGES=3 PIPE_COUNT=4 RUN_ARGS=
# adds +verbose=1
% make runv
# adds +trace=1
% make trace
# adds +verbose=1 +trace=1
% make debug
# customize
% make run RUN_ARGS='+test-case=1 +dump-vcd'
```

### What You'll See
```bash
# try this
$ make trace PIPE_STAGES=4 PIPE_COUNT=12 RUN_ARGS='+test-case=1'
cp generated/pipevecs_4_12.svh generated/current_pipevecs.svh
../build/asic-exe +test-case=1 +trace=1

 Test Suite: pipe01
  + Test Case 1: pipe, no random delays
   0:          || .                > i:0000	 :00/00 n:04 stg:----|stg:----|stg:----|stg:---- > .        || .               
   1: 00000000 || #                > start	 :00/00 n:04 stg:----|stg:----|stg:----|stg:---- >          ||                 
   2: 0000000c || #                > nt:000c	 :00/00 n:04 stg:----|stg:----|stg:----|stg:---- >          ||                 
   3: .        || 0000000000000011 > un:000c	 :00/0c n:04 stg:----|stg:----|stg:----|stg:---- >          ||                 
   4: .        || 0000000000000022 > un:000c	 :00/0c n:04 stg:0012|stg:----|stg:----|stg:---- >          ||                 
   5: .        || 0000000000000033 > un:000c	 :00/0c n:04 stg:0023|stg:0013|stg:----|stg:---- >          ||                 
   6: .        || 0000000000000044 > un:000c	 :00/0c n:04 stg:0034|stg:0024|stg:0014|stg:---- >          ||                 
   7: .        || 0000000000000055 > un:000c	 :00/0c n:04 stg:0045|stg:0035|stg:0025|stg:0015 >          || 0000000000000015
   8: .        || 0000000000000066 > un:000c	 :01/0c n:04 stg:0056|stg:0046|stg:0036|stg:0026 >          || 0000000000000026
   9: .        || 0000000000000077 > un:000c	 :02/0c n:04 stg:0067|stg:0057|stg:0047|stg:0037 >          || 0000000000000037
  10: .        || 0000000000000088 > un:000c	 :03/0c n:04 stg:0078|stg:0068|stg:0058|stg:0048 >          || 0000000000000048
  11: .        || 0000000000000099 > un:000c	 :04/0c n:04 stg:0089|stg:0079|stg:0069|stg:0059 >          || 0000000000000059
  12: .        || 00000000000000aa > un:000c	 :05/0c n:04 stg:009a|stg:008a|stg:007a|stg:006a >          || 000000000000006a
  13: .        || 00000000000000bb > un:000c	 :06/0c n:04 stg:00ab|stg:009b|stg:008b|stg:007b >          || 000000000000007b
  14: .        || 00000000000000cc > un:000c	 :07/0c n:04 stg:00bc|stg:00ac|stg:009c|stg:008c >          || 000000000000008c
  15: .        ||                  > un:000c	 :08/0c n:04 stg:00cd|stg:00bd|stg:00ad|stg:009d >          || 000000000000009d
  16: .        ||                  > un:000c	 :09/0c n:04 stg:----|stg:00ce|stg:00be|stg:00ae >          || 00000000000000ae
  17: .        ||                  > un:000c	 :0a/0c n:04 stg:----|stg:----|stg:00cf|stg:00bf >          || 00000000000000bf
  18: .        ||                  > un:000c	 :0b/0c n:04 stg:----|stg:----|stg:----|stg:00d0 >          || 00000000000000d0
  19: .        || .                > done	 :0c/0c n:04 stg:----|stg:----|stg:----|stg:---- > 00000001 || .               

./asic-test-harness.v:414: $finish called at 290 (1s)
```

(c) Sebastian Claudiusz Magierowski