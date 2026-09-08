module pixel_rx_if (
    input wire clk,
    input wire rst_n,
    input wire [7:0] pixel_in,
    input wire pixel_valid_in,
    input wire frame_start,

    output reg [7:0] pixel_out,
    output reg pixel_valid_out,
    output reg [3:0] row_cnt,
    output reg [3:0] col_cnt
);

  always @(posedge clk) begin

    if (!rst_n) begin
      pixel_out <= 8'd0;
      pixel_valid_out <= 1'b0;
      row_cnt <= 4'd0;
      col_cnt <= 4'd0;
    end else begin

      pixel_out <= pixel_in;
      pixel_valid_out <= pixel_valid_in;

      if (frame_start) begin
        row_cnt <= 4'd0;
        col_cnt <= 4'd0;
      end else if (pixel_valid_in) begin

        if (col_cnt == 4'd15) begin
          col_cnt <= 4'd0;

          if (row_cnt == 4'd15) row_cnt <= 4'd0;
          else row_cnt <= row_cnt + 4'd1;
        end else begin
          col_cnt <= col_cnt + 4'd1;
        end

      end
    end

  end

endmodule
