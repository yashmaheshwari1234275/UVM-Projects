`ifndef APB_IF_SV
`define APB_IF_SV

interface apb_if(input logic P_clk, input logic P_rst);

    // APB control signals
    logic        P_selx;
    logic        P_enable;
    logic        P_write;

    // APB address/data
    logic [31:0] P_addr;
    logic [31:0] P_wdata;

    // APB slave response
    logic        P_ready;
    logic        P_slverr;
    logic [31:0] P_rdata;

    // Modports
    //---------------------------

    // Driver drives → DUT
    modport DRV_MP (
        input  P_clk, P_rst, P_ready, P_slverr, P_rdata,
        output P_selx, P_enable, P_write, P_addr, P_wdata
    );

    // Monitor snoops everything
    modport MON_MP (
        input P_clk,
        input P_rst,
        input P_selx,
        input P_enable,
        input P_write,
        input P_addr,
        input P_wdata,
        input P_ready,
        input P_slverr,
        input P_rdata
    );

endinterface

`endif
