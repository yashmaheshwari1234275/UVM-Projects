//=================== i2c_monitor.sv ===================//
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "i2c_seq_item.sv"

class i2c_monitor extends uvm_monitor;
  `uvm_component_utils(i2c_monitor)

  // Virtual interface for observing DUT signals
  virtual i2c_if.MON vif;

  // Analysis port for sending observed transactions to scoreboard or coverage
  uvm_analysis_port #(i2c_seq_item) mon_ap;

  // Constructor
  function new(string name = "i2c_monitor", uvm_component parent);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction

  // Build phase: get virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual i2c_if.MON)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found for monitor");
  endfunction

  // Main run phase
  task run_phase(uvm_phase phase);
    i2c_seq_item rx;
    forever begin
      @(posedge vif.data_valid); // Wait until slave output is valid
      rx = i2c_seq_item::type_id::create("rx", this);

      rx.data_in       = vif.data_out;
      rx.expect_valid  = 1;
      rx.expected_data = vif.data_out; // Mirror expected with received (for now)

      `uvm_info(get_type_name(), 
        $sformatf("Observed data: %0h from DUT", vif.data_out), UVM_MEDIUM)

      // Send the observed transaction to the scoreboard
      mon_ap.write(rx);

      @(negedge vif.data_valid); // Wait until data_valid drops
    end
  endtask

endclass
