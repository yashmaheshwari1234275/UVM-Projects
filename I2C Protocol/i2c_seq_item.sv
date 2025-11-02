// i2c_seq_item.sv
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

class i2c_seq_item extends uvm_sequence_item;
  `uvm_object_utils(i2c_seq_item)

  rand bit [6:0] slave_addr;
  rand bit [7:0] data_in;
  rand bit       write_en;
  rand bit       start;

  // For scoreboard / check
  bit [7:0]      expected_data;
  bit            expect_valid;

  function new(string name="i2c_seq_item");
    super.new(name);
    start = 1; // default as transfer
    write_en = 1;
    expect_valid = 0;
  endfunction

  function void do_copy(uvm_object rhs);
    super.do_copy(rhs);
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer = null);
    return super.do_compare(rhs, comparer);
  endfunction

  function void display(string tag="ITEM");
    `uvm_info(get_type_name(), $sformatf("%s: ADDR=%0h DATA=%0h", tag, slave_addr, data_in), UVM_MEDIUM)
  endfunction

endclass
