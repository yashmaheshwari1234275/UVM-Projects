//=================== i2c_agent.sv ===================//
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "i2c_driver.sv"
`include "i2c_monitor.sv"

class i2c_agent extends uvm_agent;
  `uvm_component_utils(i2c_agent)

  i2c_driver    drv;
  i2c_monitor   mon;
  uvm_sequencer #(i2c_seq_item) seqr;

  // config flag
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(string name="i2c_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      seqr = uvm_sequencer#(i2c_seq_item)::type_id::create("seqr", this);
      drv  = i2c_driver::type_id::create("drv", this);
    end
    mon = i2c_monitor::type_id::create("mon", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction

endclass
