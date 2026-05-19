# Schedule-Faithful Miniature Test Flow

This directory holds the trace-oracle inputs for the schedule-faithful
miniature pipeline.

The human-authored trace lives in:

```text
traces/trace_6frames.tsv
```

Cell convention:

```text
X      unknown/uninitialized
I      invalid or architecturally irrelevant
a,b    valid tuple encoded as { a[7:0], b[7:0] }
```

The generator converts the TSV into a Verilog include file with expected
per-row register status and values.

## Using Makefile
In `pipes/tb/sched`, run:

```bash
make run RUN_ARGS=
``` 