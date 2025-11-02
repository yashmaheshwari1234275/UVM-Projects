//=================== I2C TESTBENCH ===================//
module i2c_test_dut;

  logic clk;
  logic rst_n;
  logic start;
  logic [6:0] slave_addr = 7'b1010000;
  logic [7:0] data_in = 8'hA5;
  logic write_en = 1'b1;
  logic scl;
  tri   sda;
  logic done;

  logic [7:0] data_out;
  logic data_valid;

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz
  end

  // DUT Instantiation
  i2c_master u_master (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .slave_addr(slave_addr),
    .data_in(data_in),
    .write_en(write_en),
    .scl(scl),
    .sda(sda),
    .done(done)
  );

  i2c_slave u_slave (
    .clk(clk),
    .rst_n(rst_n),
    .own_addr(slave_addr),
    .scl(scl),
    .sda(sda),
    .data_out(data_out),
    .data_valid(data_valid)
  );

  // Stimulus
  initial begin
    rst_n = 0;
    start = 0;
    #20;
    rst_n = 1;
    #20;
    start = 1;
    #10;
    start = 0;

    wait(done);
    #100;

    if (data_valid)
      $display("✅ Data Received by Slave: %h", data_out);
    else
      $display("❌ Data not received!");

    #100;
    $finish;
  end

endmodule
