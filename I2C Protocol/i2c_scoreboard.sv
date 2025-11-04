//=================== i2c_scoreboard.sv ===================//
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "i2c_seq_item.sv"

class i2c_scoreboard extends uvm_component;
  `uvm_component_utils(i2c_scoreboard)

  // Analysis FIFOs to receive data from monitor
  uvm_analysis_imp#(i2c_seq_item, i2c_scoreboard) item_collected_port;

  // Internal queue to store expected data
  i2c_seq_item expected_q[$];

  // Constructor
  function new(string name = "i2c_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_port = new("item_collected_port", this);
  endfunction

  // Method called when monitor sends a transaction
  function void write(i2c_seq_item trans);
    i2c_seq_item exp;
    if (expected_q.size() == 0) begin
      `uvm_error(get_type_name(), "Scoreboard: No expected data available!")
      return;
    end

    exp = expected_q.pop_front();

    // Compare received vs expected
    if (exp.expected_data === trans.data_in && trans.data_valid) begin
      `uvm_info(get_type_name(),
        $sformatf("✅ PASS: Expected %0h, Got %0h", exp.expected_data, trans.data_in),
        UVM_LOW)
    end else begin
      `uvm_error(get_type_name(),
        $sformatf("❌ FAIL: Expected %0h, Got %0h", exp.expected_data, trans.data_in))
    end
  endfunction

  // Task to store expected transaction from sequence/driver
  task add_expected(i2c_seq_item tx);
    i2c_seq_item copy_tx;
    copy_tx = i2c_seq_item::type_id::create("copy_tx");
    copy_tx.copy(tx); // use do_copy
    expected_q.push_back(copy_tx);
    `uvm_info(get_type_name(),
      $sformatf("Expected data queued: %0h", tx.expected_data),
      UVM_HIGH)
  endtask

endclass
