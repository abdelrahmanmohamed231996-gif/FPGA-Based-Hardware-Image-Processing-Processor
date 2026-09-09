module addr_gen (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [3:0] row_cnt,
    output reg  [3:0] col_cnt,
    output wire [7:0] addr_top,
    output wire [7:0] addr_mid,
    output wire [7:0] addr_bot,
    output reg        valid
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      row_cnt <= 0;
      col_cnt <= 0;
      valid   <= 0;
    end else begin
      valid <= 1'b1;
      if (col_cnt == 15) begin
        col_cnt <= 0;
        row_cnt <= (row_cnt == 15) ? 0 : row_cnt + 1;
      end else begin
        col_cnt <= col_cnt + 1;
      end
    end
  end

  // row_cnt-2 / -1 wrap harmlessly for row_cnt<2; window_gen's
  // win_valid gating already discards those cycles downstream.
  assign addr_top = ((row_cnt - 2) * 16) + col_cnt;
  assign addr_mid = ((row_cnt - 1) * 16) + col_cnt;
  assign addr_bot = (row_cnt * 16) + col_cnt;

endmodule
