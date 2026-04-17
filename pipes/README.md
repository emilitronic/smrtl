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
________                           ______                             ________
        |------ctrl_src_val------>|      |--------ctrl_snk_val------>|
ctrl_src|<-----ctrl_src_rdy-------|      |<-------ctrl_snk_rdy-------|ctrl_snk 
        |------ctrl_src_msg------>|      |--------ctrl_snk_msg------>|        
--------'                         | ASIC |                           |--------'
        |------data_src_val------>|      |--------data_snk_val------>|
data_src|<-----data_src_rdy-------|      |<-------data_snk_rdy-------|data_snk
        |------data_src_msg------>|      |--------data_snk_msg------>|  
--------'                         `------'                           `--------'          
```

### Using Makefile
In `pipes/tb`
```bash
# Compile and run all test cases in build directory
% make run
```