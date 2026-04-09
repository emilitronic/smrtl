# Pipelines (galore)

```
SRC -> | 1 -> SNK

SRC -> | 1 - | 2 -> SNK

SRC -> | 1 - | 2 - ... | N -> SNK

SRC -> FIFOi -> | 1 - | 2 - ... | N -> FIFOo -> SNK

```

This directory is being restarted with the same high-level organization
used in `max/serial_matmul`:

- `rtl/` for pipeline RTL modules
- `tb/` for the top-level simulation entry and testbench build flow

The intent is to begin from a very small scaffold and add:

- ingress buffering
- pipeline stages
- control
- egress buffering

one piece at a time.
