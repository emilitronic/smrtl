# Framer Tests

This directory contains standalone tests for `pipe_framer`.

The framer converts raw 64-bit data beats into framebits messages:

```text
raw data -> { first, last, data }
```

Example:

```bash
make run PIPE_COUNT=13 FRAME_LEN=4 RUN_ARGS=
make trace PIPE_COUNT=13 FRAME_LEN=4 RUN_ARGS='+test-case=1'
```
