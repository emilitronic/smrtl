# Framed RTL

This directory is reserved for framed-pipe variants.  The intent is to keep the current scalar baseline in `rtl/scalar/` stable while new framing-oriented designs are explored here.
```
                 _____________________
                |  pipe-framed01.v    |
                |                     |
                |    pipe_ctrl.v      |
                |        |            |
                |        V            |
pipe-framer.v ->| pipe-framed-data.v  |
                |        A            |
                |        |            |
                | pipe-framed-stage.v |     
                `_____________________'
```

### Using Makefile
In `pipes/tb/framed`
```bash
# run all test cases with 5 vectors
$ make run PIPE_COUNT=5 RUN_ARGS=
# see all traces as well
$ make trace PIPE_COUNT=5 RUN_ARGS=
# see just one trace
$ make trace PIPE_COUNT=5 RUN_ARGS='+test-case=4'
```