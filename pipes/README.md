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