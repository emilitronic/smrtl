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

## Using Makefile
In `pipes/tb/framed`
```bash
# run all test cases with 5 vectors
$ make run PIPE_COUNT=5 RUN_ARGS=
# see all traces as well
$ make trace PIPE_COUNT=5 RUN_ARGS=
# see just one trace
$ make trace PIPE_COUNT=5 RUN_ARGS='+test-case=4'
# vary the number of stages
$ make run PIPE_STAGES=5 PIPE_COUNT=8 RUN_ARGS=
```

## Details
What's happening under the hood? For example, when running
```bash
$ make run PIPE_STAGES=4 PIPE_COUNT=12 RUN_ARGS=
```
the execution will look for `tb/framed/generated/pipevecs_framed_4_12.svh`.  If that file already exists and is up to date (i.e., not older than the Python generator script `tb/framed/gen_pipevecs_framed.py`) Make will copy it to `tb/framed/generated/current_pipevecs.svh` it will not rerun the Python generator script.  If the file does not exist or is outdated, Make will run the Python generator script to create it, and then copy it to `current_pipevecs.svh`.  The test harness will include `current_pipevecs.svh` to get the test vectors for the simulation. 