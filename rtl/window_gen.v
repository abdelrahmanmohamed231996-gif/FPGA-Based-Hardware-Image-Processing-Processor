module window_gen #(
    parameter PIXEL_WIDTH = 8,
    parameter TILE_ROWS   = 16,  // total valid rows per tile - adjust if different
    parameter TILE_COLS   = 16   // total valid cols per tile - adjust if different
) (
    input wire clk,
    input wire rst_n,
    input wire [PIXEL_WIDTH-1:0] row_top,
    input wire [PIXEL_WIDTH-1:0] row_mid,
    input wire [PIXEL_WIDTH-1:0] row_bot,
    input wire valid_in,
    input wire [3:0] row_cnt,
    input wire [3:0] col_cnt,

    output reg [(PIXEL_WIDTH*9)-1:0] window_out,
    output reg win_valid,
    output reg [3:0] out_row,
    output reg [3:0] out_col
);

  reg [PIXEL_WIDTH-1:0] sr_top[0:2];  // holds last 3 columns of row_top
  reg [PIXEL_WIDTH-1:0] sr_mid[0:2];  // holds last 3 columns of row_mid
  reg [PIXEL_WIDTH-1:0] sr_bot[0:2];  // holds last 3 columns of row_bot

  // registered address/valid tracking, aligned to the 1-cycle sr latency
  reg [3:0] row_cnt_d, col_cnt_d;
  reg valid_in_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sr_top[0]  <= 0;
      sr_top[1]  <= 0;
      sr_top[2]  <= 0;
      sr_mid[0]  <= 0;
      sr_mid[1]  <= 0;
      sr_mid[2]  <= 0;
      sr_bot[0]  <= 0;
      sr_bot[1]  <= 0;
      sr_bot[2]  <= 0;
      row_cnt_d  <= 4'd0;
      col_cnt_d  <= 4'd0;
      valid_in_d <= 1'b0;
    end else begin
      valid_in_d <= valid_in;
      if (valid_in) begin
        sr_top[0] <= sr_top[1];
        sr_top[1] <= sr_top[2];
        sr_top[2] <= row_top;
        sr_mid[0] <= sr_mid[1];
        sr_mid[1] <= sr_mid[2];
        sr_mid[2] <= row_mid;
        sr_bot[0] <= sr_bot[1];
        sr_bot[1] <= sr_bot[2];
        sr_bot[2] <= row_bot;
        row_cnt_d <= row_cnt;
        col_cnt_d <= col_cnt;
      end
    end
  end

  always @(*) begin
    window_out[PIXEL_WIDTH-1:0] = sr_top[0];
    window_out[2*PIXEL_WIDTH-1:PIXEL_WIDTH] = sr_top[1];
    window_out[3*PIXEL_WIDTH-1:2*PIXEL_WIDTH] = sr_top[2];
    window_out[4*PIXEL_WIDTH-1:3*PIXEL_WIDTH] = sr_mid[0];
    window_out[5*PIXEL_WIDTH-1:4*PIXEL_WIDTH] = sr_mid[1];
    window_out[6*PIXEL_WIDTH-1:5*PIXEL_WIDTH] = sr_mid[2];
    window_out[7*PIXEL_WIDTH-1:6*PIXEL_WIDTH] = sr_bot[0];
    window_out[8*PIXEL_WIDTH-1:7*PIXEL_WIDTH] = sr_bot[1];
    window_out[9*PIXEL_WIDTH-1:8*PIXEL_WIDTH] = sr_bot[2];

    out_row = row_cnt_d - 4'd2;
    out_col = col_cnt_d - 4'd2;

    win_valid = valid_in_d &&
                    (row_cnt_d >= 4'd2) && (row_cnt_d <= TILE_ROWS - 1) &&
                    (col_cnt_d >= 4'd2) && (col_cnt_d <= TILE_COLS - 1);
  end

endmodule
