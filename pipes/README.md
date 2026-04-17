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
# make test vectors (default is one stage and three vectors)
% make gen
# but you can vary it
% make gen PIPE_STAGES=2 PIPE_COUNT=5
# quiet default
% make run
# maybe you want to try different test cases
% make run RUN_ARGS='+test-case=1'
# or try all test cases
% make run RUN_ARGS='+test-case'
# or even simpler, run all test cases with
% make run RUN_ARGS=
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
# when making a new set of test vectors
$ make gen PIPE_COUNT=50             
python3 gen_pipevecs.py --stages 1 --count 50 --output generated/pipevecs_1_50.svh
cp generated/pipevecs_1_50.svh generated/current_pipevecs.svh
# when running a test case
$ make trace RUN_ARGS='+test-case=1'
../build/asic-exe +test-case=1 +trace=1

 Test Suite: pipe01
  + Test Case 1: 2-stage pipe, no random delays
   0:          || .                > i:0000	 :00/00 n:02 stg:----|stg:---- > .        || .               
   1: 00000000 || #                > start	 :00/00 n:02 stg:----|stg:---- >          ||                 
   2: 00000003 || #                > nt:0003	 :00/00 n:02 stg:----|stg:---- >          ||                 
   3: .        || 0000000000000011 > un:0003	 :00/03 n:02 stg:----|stg:---- >          ||                 
   4: .        || 0000000000000022 > un:0003	 :00/03 n:02 stg:0012|stg:---- >          ||                 
   5: .        || 0000000000000033 > un:0003	 :00/03 n:02 stg:0023|stg:0013 >          || 0000000000000013
   6: .        ||                  > un:0003	 :01/03 n:02 stg:0034|stg:0024 >          || 0000000000000024
   7: .        ||                  > un:0003	 :02/03 n:02 stg:----|stg:0035 >          || 0000000000000035
   8: .        || .                > done	 :03/03 n:02 stg:----|stg:---- > 00000001 || .               

./asic-test-harness.v:411: $finish called at 180 (1s)
```

(c) Sebastian Claudiusz Magierowski