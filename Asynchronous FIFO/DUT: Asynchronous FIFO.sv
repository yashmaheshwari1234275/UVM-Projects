// async_fifo.sv
module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input  logic                 wr_clk,
    input  logic                 rd_clk,
    input  logic                 rst_n,
    input  logic                 wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic                 rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                 full,
    output logic                 empty
);
    logic [DATA_WIDTH-1:0] mem [DEPTH-1:0];
    logic [$clog2(DEPTH):0] wr_ptr, rd_ptr;

    // Write side
    always_ff @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= 0;
        else if (wr_en && !full) begin
            mem[wr_ptr[$clog2(DEPTH)-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read side
    always_ff @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n)
            rd_ptr <= 0;
        else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr[$clog2(DEPTH)-1:0]];
            rd_ptr <= rd_ptr + 1;
        end
    end

    assign full  = (wr_ptr - rd_ptr) == DEPTH;
    assign empty = (wr_ptr == rd_ptr);
endmodule
