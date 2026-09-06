module tb_mac_mult_array;
  parameter PIXEL_WIDTH = 8;
  parameter PRODUCT_WIDTH = 16;
  parameter KERNEL_WIDTH = 3;

  reg clk;
  reg rst_n;
  wire [(PIXEL_WIDTH*KERNEL_WIDTH*KERNEL_WIDTH)-1:0] win;
  reg [7:0] w1, w2, w3, w4, w5, w6, w7, w8, w9;
  wire signed [(PIXEL_WIDTH*KERNEL_WIDTH*KERNEL_WIDTH)-1:0] k;
  reg signed [7:0] k1, k2, k3, k4, k5, k6, k7, k8, k9;
  reg valid_in;
  reg [3:0] out_row;
  reg [3:0] out_col;

  wire [16:0] p1, p2, p3, p4, p5, p6, p7, p8, p9;
  wire valid_out;
  wire [3:0] out_row_d;
  wire [3:0] out_col_d;

  assign win = {w9, w8, w7, w6, w5, w4, w3, w2, w1};
  assign k   = {k9, k8, k7, k6, k5, k4, k3, k2, k1};

  mac_mult_array DUT (
      .clk(clk),
      .rst_n(rst_n),
      .win(win),
      .k(k),
      .valid_in(valid_in),
      .out_row(out_row),
      .out_col(out_col),
      .prod({p9, p8, p7, p6, p5, p4, p3, p2, p1}),
      .valid_out(valid_out),
      .out_row_d(out_row_d),
      .out_col_d(out_col_d)
  );

  always #5 clk = ~clk;

  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    repeat (2) @(negedge clk);
    rst_n = 1'b1;
    repeat (16) begin
      w9 = $random;
      w8 = $random;
      w7 = $random;
      w6 = $random;
      w5 = $random;
      w4 = $random;
      w3 = $random;
      w2 = $random;
      w1 = $random;

      k9 = $random;
      k8 = $random;
      k7 = $random;
      k6 = $random;
      k5 = $random;
      k4 = $random;
      k3 = $random;
      k2 = $random;
      k1 = $random;

      out_row = 1'd1;
      out_col = 1'd1;
      valid_in = 1'b1;
      @(negedge clk);
      valid_in = 1'b0;
    end

    $stop;

  end
endmodule
