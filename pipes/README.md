# Pipelines (galore)

```
SRC -> | 1 -> SNK

SRC -> | 1 - | 2 -> SNK

SRC -> | 1 - | 2 - ... | N -> SNK

SRC -> FIFOi -> | 1 - | 2 - ... | N -> FIFOo -> SNK

```

Directory organization:

- `rtl/` for pipeline RTL modules
- `tb/` for the top-level simulation entry and testbench build flow

The intent is to begin from a very small scaffold and add:

- ingress buffering
- pipeline stages
- control
- egress buffering

one piece at a time.

```
SRC & SNK = PROC

SRC ---> UNPACK ---> PIPE -> PACK -> SNK
                     |  |
MEM resp -> UNPACK --+  +--> PACK -> MEM req

SRC ------------cmd_valid_i-----------> ASIC --------resp_valid_o---------> SNK
SRC <-----------cmd_ready_o------------ ASIC <-------resp_ready_i---------- SNK
SRC ->src_msg->|                    |-> ASIC ->|              |->sink_msg-> SNK
               |-> cmd_rs2_i        |          |resp_rd_o --->|
               |-> cmd_rs1_i        |          |resp_data_o ->|                   
               |-> cmd_inst_funct_i |     
               |-> cmd_inst_opcode_i|
               
MEM ----------mem_resp_valid_i----------> ASIC ----------mem_req_valid_o---------> MEM
MEM <----------------1------------------- ASIC <---------mem_req_ready_i---------- MEM
MEM ->memresp_msg->|                  |-> ASIC ->|                 |->memreq_msg-> MEM
                   |-> mem_resp_addr_i|          |mem_req_addr_o ->|
                   |-> mem_resp_data_i|          |mem_req_data_o ->|
```

