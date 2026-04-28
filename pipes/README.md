# Pipelines (galore)

```
SRC -> | 1 -> SNK

SRC -> | 1 - | 2 -> SNK

SRC -> | 1 - | 2 - ... | N -> SNK

SRC -> FIFOi -> | 1 - | 2 - ... | N -> FIFOo -> SNK

```

Directory organization:

- `doc/` for design notes and staged development plans
- `rtl/lib/` for reusable pipeline RTL blocks
- `rtl/scalar/` for preserved scalar pipe variants
- `rtl/framed/` for future framed-pipe variants
- `tb/` for shared testbench infrastructure
- `tb/scalar/` for the scalar baseline simulation entry and build flow
- `tb/framed/` for framed-pipe tests

The intent is to preserve small useful variants and add:

- ingress buffering
- pipeline stages
- control
- egress buffering

one piece at a time, without losing a known-good baseline.

See `doc/framed-pipeline-plan.md` for the staged framed-pipeline plan.

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

See `pipes/rtl/scalar/README.md` for the scalar pipeline baseline.
See `pipes/rtl/framed/README.md` for the framed-pipe variants.

(c) Sebastian Claudiusz Magierowski
