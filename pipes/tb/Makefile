# pipes/tb/Makefile

SIM      ?= iverilog

TOP      ?= top
EXE_DIR  ?= ../build
EXE      ?= $(EXE_DIR)/asic-exe

VC_DIR   := ../../lib/vc
SM_DIR   := ../../lib/sm
PROC_DIR := ../../lib/proc

INCLUDES := -I $(VC_DIR) -I $(SM_DIR) -I $(PROC_DIR) -I ../rtl -I ../rtl/lib -I ../rtl/scalar -I ../rtl/framed -I .
SRC_TOP  := asic.t.v
RUN_ARGS ?= +test-case=1
GEN_DIR  := generated
PIPE_STAGES ?= 2
PIPE_COUNT  ?= 3
PIPEVECS := $(GEN_DIR)/pipevecs_$(PIPE_STAGES)_$(PIPE_COUNT).svh
PIPEVECS_CURRENT := $(GEN_DIR)/current_pipevecs.svh

all: run

$(EXE_DIR):
	mkdir -p $(EXE_DIR)

$(GEN_DIR):
	mkdir -p $(GEN_DIR)

$(PIPEVECS): gen_pipevecs.py | $(GEN_DIR)
	python3 gen_pipevecs.py --stages $(PIPE_STAGES) --count $(PIPE_COUNT) --output $(PIPEVECS)

.PHONY: sync-current

sync-current: $(PIPEVECS)
	cp $(PIPEVECS) $(PIPEVECS_CURRENT)

build: $(EXE_DIR) sync-current
ifeq ($(SIM),iverilog)
	@iverilog -g2012 \
	  -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array \
	  -DASIC_IMPL_NUM_STAGES=$(PIPE_STAGES) \
	  $(INCLUDES) \
	  -s $(TOP) \
	  -o $(EXE) \
	  $(SRC_TOP)
else
	@echo "SIM=$(SIM) not yet supported"
	exit 1
endif

.PHONY: run runv trace debug build gen clean

gen: sync-current

run: build
	$(EXE) $(RUN_ARGS)

runv: build
	$(EXE) $(RUN_ARGS) +verbose=1

trace: build
	$(EXE) $(RUN_ARGS) +trace=1

debug: build
	$(EXE) $(RUN_ARGS) +verbose=1 +trace=1

clean:
	rm -f $(EXE_DIR)/asic-exe $(EXE_DIR)/*.vcd
	rm -rf $(GEN_DIR)
