// tb_top.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

module tb_top;
    logic wr_clk = 0, rd_clk = 0, rst_n = 0;
    always #5 wr_clk = ~wr_clk;
    always #7 rd_clk = ~rd_clk;

    fifo_if #(8) fifo_vif(wr_clk, rd_clk);

    async_fifo dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst_n(fifo_vif.rst_n),
        .wr_en(fifo_vif.wr_en),
        .wr_data(fifo_vif.wr_data),
        .rd_en(fifo_vif.rd_en),
        .rd_data(fifo_vif.rd_data),
        .full(fifo_vif.full),
        .empty(fifo_vif.empty)
    );

    initial begin
        fifo_vif.rst_n = 0;
        #20 fifo_vif.rst_n = 1;
    end

    initial begin
        uvm_config_db#(virtual fifo_if)::set(null, "*", "vif", fifo_vif);
        run_test("fifo_test");
    end
endmodule
