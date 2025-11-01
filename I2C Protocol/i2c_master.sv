//=================== I2C MASTER ===================//
module i2c_master (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        start,
  input  logic [6:0]  slave_addr,
  input  logic [7:0]  data_in,
  input  logic        write_en,
  output logic        scl,
  inout  tri          sda,
  output logic        done
);

  // Internal registers
  typedef enum logic [2:0] {
    IDLE,
    START_COND,
    SEND_ADDR,
    SEND_DATA,
    STOP_COND,
    DONE
  } state_t;

  state_t state;
  logic [3:0] bit_cnt;
  logic sda_out;
  logic sda_oe; // output enable
  assign sda = sda_oe ? sda_out : 1'bz;

  // Generate SCL (clock divider)
  logic [3:0] clk_div;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      clk_div <= 0;
    else
      clk_div <= clk_div + 1;
  end
  assign scl = clk_div[3]; // slower clock

  // State machine
  always_ff @(posedge scl or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      bit_cnt <= 0;
      done <= 0;
      sda_out <= 1'b1;
      sda_oe <= 1'b1;
    end else begin
      case (state)
        IDLE: begin
          done <= 0;
          if (start)
            state <= START_COND;
        end

        START_COND: begin
          sda_out <= 1'b0; // start condition: SDA low while SCL high
          sda_oe <= 1'b1;
          bit_cnt <= 7;
          state <= SEND_ADDR;
        end

        SEND_ADDR: begin
          sda_out <= slave_addr[bit_cnt];
          if (bit_cnt == 0) state <= SEND_DATA;
          else bit_cnt <= bit_cnt - 1;
        end

        SEND_DATA: begin
          sda_out <= data_in[bit_cnt];
          if (bit_cnt == 0)
            state <= STOP_COND;
          else
            bit_cnt <= bit_cnt - 1;
        end

        STOP_COND: begin
          sda_out <= 1'b0;
          sda_oe <= 1'b1;
          state <= DONE;
        end

        DONE: begin
          sda_out <= 1'b1; // SDA high, stop condition
          done <= 1'b1;
          state <= IDLE;
        end
      endcase
    end
  end

endmodule
