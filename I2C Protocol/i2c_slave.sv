//=================== I2C SLAVE ===================//
module i2c_slave (
  input  logic       clk,
  input  logic       rst_n,
  input  logic [6:0] own_addr,
  input  logic       scl,
  inout  tri         sda,
  output logic [7:0] data_out,
  output logic       data_valid
);

  typedef enum logic [2:0] {
    IDLE,
    ADDR_RECV,
    ADDR_ACK,
    DATA_RECV,
    DATA_ACK
  } state_t;

  state_t state;
  logic [3:0] bit_cnt;
  logic [7:0] addr_shift;
  logic [7:0] data_shift;
  logic sda_in, sda_out, sda_oe;

  assign sda_in = sda;
  assign sda = sda_oe ? sda_out : 1'bz;

  always_ff @(negedge scl or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      bit_cnt <= 0;
      data_valid <= 0;
      data_out <= 0;
      addr_shift <= 0;
      data_shift <= 0;
      sda_out <= 1'b1;
      sda_oe <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          data_valid <= 0;
          if (sda_in == 0) begin
            // START detected
            bit_cnt <= 7;
            state <= ADDR_RECV;
          end
        end

        ADDR_RECV: begin
          addr_shift[bit_cnt] <= sda_in;
          if (bit_cnt == 0)
            state <= ADDR_ACK;
          else
            bit_cnt <= bit_cnt - 1;
        end

        ADDR_ACK: begin
          // Address compare
          if (addr_shift[7:1] == own_addr) begin
            sda_oe <= 1'b1;
            sda_out <= 1'b0; // ACK
          end
          else begin
            sda_oe <= 1'b1;
            sda_out <= 1'b1; // NACK
          end
          state <= DATA_RECV;
          bit_cnt <= 7;
        end

        DATA_RECV: begin
          sda_oe <= 1'b0;
          data_shift[bit_cnt] <= sda_in;
          if (bit_cnt == 0)
            state <= DATA_ACK;
          else
            bit_cnt <= bit_cnt - 1;
        end

        DATA_ACK: begin
          sda_oe <= 1'b1;
          sda_out <= 1'b0; // ACK
          data_out <= data_shift;
          data_valid <= 1'b1;
          state <= IDLE;
        end
      endcase
    end
  end

endmodule
