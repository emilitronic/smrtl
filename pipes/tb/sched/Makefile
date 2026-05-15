# pipes/tb/sched/Makefile

SIM      ?= iverilog

TOP      ?= top
EXE_DIR  ?= ../../build
EXE      ?= $(EXE_DIR)/sched-exe

VC_DIR   := ../../../lib/vc

INCLUDES := -I $(VC_DIR) -I .
SRC_TOP  := sched.t.v
RUN_ARGS ?= +test-case=1
TRACE_TSV ?= traces/trace_6frames.tsv
GEN_DIR   := generated
TRACE_SVH := $(GEN_DIR)/trace_6frames.svh
TRACE_CURRENT := $(GEN_DIR)/current_sched_trace.svh

all: run

$(EXE_DIR):
	mkdir -p $(EXE_DIR)

$(GEN_DIR):
	mkdir -p $(GEN_DIR)

$(TRACE_SVH): gen_sched_trace.py $(TRACE_TSV) | $(GEN_DIR)
	python3 gen_sched_trace.py --input $(TRACE_TSV) --output $(TRACE_SVH)

.PHONY: sync-current

sync-current: $(TRACE_SVH)
	cp $(TRACE_SVH) $(TRACE_CURRENT)

build: $(EXE_DIR) sync-current
ifeq ($(SIM),iverilog)
	@iverilog -g2012 \
	  -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array \
	  $(INCLUDES) \
	  -s $(TOP) \
	  -o $(EXE) \
	  $(SRC_TOP)
else
	@echo "SIM=$(SIM) not yet supported"
	exit 1
endif

.PHONY: run runv debug build gen clean

gen: sync-current

run: build
	$(EXE) $(RUN_ARGS)

runv: build
	$(EXE) $(RUN_ARGS) +verbose=1

debug: build
	$(EXE) $(RUN_ARGS) +verbose=1

clean:
	rm -f $(EXE_DIR)/sched-exe
	rm -rf $(GEN_DIR)

