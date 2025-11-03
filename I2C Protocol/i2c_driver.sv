//=================== i2c_driver.sv ===================//
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "i2c_seq_item.sv"

class i2c_driver extends uvm_driver #(i2c_seq_item);
  `uvm_component_utils(i2c_driver)

  // Virtual interface to drive signals to DUT
  virtual i2c_if.DRV vif;

  // Constructor
  function new(string name = "i2c_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: get interface handle
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual i2c_if.DRV)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found for driver");
  endfunction

  // Reset task
  task reset_dut();
    vif.start     <= 0;
    vif.slave_addr <= 0;
    vif.data_in   <= 0;
    vif.write_en  <= 0;
    `uvm_info(get_type_name(), "I2C Driver: Reset applied", UVM_LOW)
    repeat (5) @(posedge vif.clk);
  endtask

  // Main run phase
  task run_phase(uvm_phase phase);
    i2c_seq_item tx;
    reset_dut();

    forever begin
      seq_item_port.get_next_item(tx); // Get transaction from sequencer

      drive_transfer(tx);

      seq_item_port.item_done(); // Tell sequencer that item is done
    end
  endtask

  // Task to drive a single transaction
  task drive_transfer(i2c_seq_item tx);
    `uvm_info(get_type_name(),
      $sformatf("Driving I2C TX: ADDR=%0h DATA=%0h WRITE_EN=%0b",
                 tx.slave_addr, tx.data_in, tx.write_en), UVM_MEDIUM)

    // Start condition
    vif.start <= 1;
    vif.slave_addr <= tx.slave_addr;
    vif.data_in <= tx.data_in;
    vif.write_en <= tx.write_en;
    @(posedge vif.clk);
    vif.start <= 0;

    // Wait for DUT to finish operation (done signal)
    wait (vif.done == 1);
    @(posedge vif.clk);
    vif.write_en <= 0;

    `uvm_info(get_type_name(), "I2C Driver: Transaction completed", UVM_LOW)
  endtask

endclass
