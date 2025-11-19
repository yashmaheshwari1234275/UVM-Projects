`ifndef APB_SEQ_ITEM_SV
`define APB_SEQ_ITEM_SV

class apb_seq_item extends uvm_sequence_item;

  rand bit        P_write;   // 1 = write, 0 = read
  rand bit [31:0] P_addr;
  rand bit [31:0] P_wdata;

  bit  [31:0]     P_rdata;
  bit             P_slverr;
  bit             P_ready;

  // Constraints
  constraint addr_c { P_addr inside {[0:31]}; }   // our mem size
  constraint wdata_c { P_wdata inside {[0:32'hFFFF_FFFF]}; }

  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(P_write,   UVM_ALL_ON)
    `uvm_field_int(P_addr,    UVM_ALL_ON)
    `uvm_field_int(P_wdata,   UVM_ALL_ON)
    `uvm_field_int(P_rdata,   UVM_ALL_ON)
    `uvm_field_int(P_slverr,  UVM_ALL_ON)
    `uvm_field_int(P_ready,   UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="apb_seq_item");
    super.new(name);
  endfunction

endclass

`endif
