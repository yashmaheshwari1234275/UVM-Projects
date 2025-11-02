// i2c_sequence.sv
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

class i2c_sequence extends uvm_sequence #(i2c_seq_item);
  `uvm_object_utils(i2c_sequence)

  function new(string name="i2c_sequence");
    super.new(name);
  endfunction

  task body();
    i2c_seq_item tx;
    repeat(10) begin
      tx = i2c_seq_item::type_id::create("tx");
      assert(tx.randomize());
      tx.expected_data = tx.data_in; // expectation for scoreboard
      tx.expect_valid  = 1;
      start_item(tx);
      finish_item(tx);
    end
  endtask
endclass
