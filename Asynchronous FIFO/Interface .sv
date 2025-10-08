// fifo_if.sv
interface fifo_if #(parameter DATA_WIDTH = 8)(input logic wr_clk, input logic rd_clk);
    logic rst_n;
    logic wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic rd_en;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full;
    logic empty;
endinterface
