# pipes/tb/framemeta/Makefile

SIM      ?= iverilog

TOP      ?= top
EXE_DIR  ?= ../../build
EXE      ?= $(EXE_DIR)/asic-framemeta-exe

VC_DIR   := ../../../lib/vc
SM_DIR   := ../../../lib/sm
PROC_DIR := ../../../lib/proc

INCLUDES := -I $(VC_DIR) -I $(SM_DIR) -I $(PROC_DIR) -I ../../rtl -I ../../rtl/lib -I ../../rtl/scalar -I ../../rtl/framed -I .. -I .
SRC_TOP  := asic.t.v
RUN_ARGS ?= +test-case=1
PIPE_STAGES ?= 2
FRAME_ID_NBITS ?= 4
BEAT_IDX_NBITS ?= 8
DATA_NBITS ?= 64
MSG_NBITS := $(shell expr $(FRAME_ID_NBITS) + $(BEAT_IDX_NBITS) + 2 + $(DATA_NBITS))
GEN_DIR   := generated
PIPE_COUNT ?= 4
FRAME_PATTERN ?= 3,1
comma := ,
FRAME_PATTERN_ID := $(subst $(comma),_,$(FRAME_PATTERN))
PIPEVECS := $(GEN_DIR)/pipevecs_framemeta_$(PIPE_STAGES)_$(PIPE_COUNT)_$(FRAME_PATTERN_ID)_$(FRAME_ID_NBITS)_$(BEAT_IDX_NBITS).svh
PIPEVECS_CURRENT := $(GEN_DIR)/current_pipevecs.svh

all: run

$(EXE_DIR):
	mkdir -p $(EXE_DIR)

$(GEN_DIR):
	mkdir -p $(GEN_DIR)

$(PIPEVECS): gen_pipevecs_framemeta.py | $(GEN_DIR)
	python3 gen_pipevecs_framemeta.py --stages $(PIPE_STAGES) --count $(PIPE_COUNT) --frame-pattern $(FRAME_PATTERN) --frame-id-nbits $(FRAME_ID_NBITS) --beat-idx-nbits $(BEAT_IDX_NBITS) --data-nbits $(DATA_NBITS) --output $(PIPEVECS)

.PHONY: sync-current

sync-current: $(PIPEVECS)
	cp $(PIPEVECS) $(PIPEVECS_CURRENT)

build: $(EXE_DIR) sync-current
ifeq ($(SIM),iverilog)
	@iverilog -g2012 \
	  -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array \
	  -DASIC_IMPL_NUM_STAGES=$(PIPE_STAGES) \
	  -DASIC_FRAME_ID_NBITS=$(FRAME_ID_NBITS) \
	  -DASIC_BEAT_IDX_NBITS=$(BEAT_IDX_NBITS) \
	  -DASIC_DATA_NBITS=$(DATA_NBITS) \
	  -DASIC_DATA_MSG_NBITS=$(MSG_NBITS) \
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
	rm -f $(EXE_DIR)/asic-framemeta-exe $(EXE_DIR)/*.vcd
	rm -rf $(GEN_DIR)
