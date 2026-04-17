# pipes/tb/Makefile

SIM      ?= iverilog

TOP      ?= top
EXE_DIR  ?= ../build
EXE      ?= $(EXE_DIR)/asic-exe

VC_DIR   := ../../lib/vc
SM_DIR   := ../../lib/sm
PROC_DIR := ../../lib/proc

INCLUDES := -I $(VC_DIR) -I $(SM_DIR) -I $(PROC_DIR) -I ../rtl -I .
SRC_TOP  := asic.t.v
RUN_ARGS ?= +test-case=1

all: run

$(EXE_DIR):
	mkdir -p $(EXE_DIR)

build: $(EXE_DIR)
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

.PHONY: run runv trace debug build clean

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
