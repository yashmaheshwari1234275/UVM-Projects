module AMBA_APB(
    input         P_clk,
    input         P_rst,      // active-high reset (your original)
    input  [31:0] P_addr,
    input         P_selx,
    input         P_enable,
    input         P_write,
    input  [31:0] P_wdata,

    output reg        P_ready,
    output reg        P_slverr,
    output reg [31:0] P_rdata
);

  // memory
  reg [31:0] mem [0:31];

  // FSM states
  parameter idle   = 2'b00;
  parameter setup  = 2'b01;
  parameter access = 2'b10;

  reg [1:0] present_state, next_state;

  // sequential: state updates + write operation
  always @(posedge P_clk) begin
    if (P_rst) begin
      present_state <= idle;
      P_ready       <= 0;
      P_slverr      <= 0;
      P_rdata       <= 0;
    end
    else begin
      present_state <= next_state;

      // Perform WRITE only in ACCESS phase
      if (present_state == access && P_ready && P_write)
          mem[P_addr] <= P_wdata;

      // Perform READ output update in ACCESS
      if (present_state == access && P_ready && !P_write)
          P_rdata <= mem[P_addr];
    end
  end

  // combinational: next_state + outputs
  always @(*) begin

    // default values
    next_state = present_state;
    P_ready    = 0;
    P_slverr   = 0;

    case (present_state)

      //------------------------------------
      // IDLE
      //------------------------------------
      idle: begin
        if (P_selx && !P_enable)
          next_state = setup;
      end

      //------------------------------------
      // SETUP
      //------------------------------------
      setup: begin
        if (!P_selx) begin
          next_state = idle;
        end
        else if (P_enable) begin
          next_state = access;
        end
      end

      //------------------------------------
      // ACCESS
      //------------------------------------
      access: begin
        // READY asserted only in ACCESS
        P_ready = 1;

        // End transfer when P_sel drops or enable drops
        if (!P_selx || !P_enable)
          next_state = idle;
      end

    endcase
  end

endmodule
