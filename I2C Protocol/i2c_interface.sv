interface i2c_if(input logic clk);
  logic rst_n;
  logic start;
  logic [6:0] slave_addr;
  logic [7:0] data_in;
  logic write_en;
  logic scl;
  tri   sda;
  logic done;
  logic [7:0] data_out;
  logic data_valid;

  // Define modports for clarity
  modport DRV (output start, output slave_addr, output data_in, 
               output write_en, input scl, inout sda, input done);
  
  modport MON (input scl, inout sda, input data_out, input data_valid);
  
  modport DUT (input clk, input rst_n, input start, input slave_addr, input data_in,
               input write_en, output scl, inout sda, output done);
endinterface
