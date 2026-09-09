module conv_top (
    input  wire               clk,
    input  wire               rst_n,
    // New kernel selection inputs
    input  wire               filter0_sel,
    input  wire               filter1_sel,
    input  wire               filter2_sel,
    // Final pipelined outputs from the adder tree
    output wire signed [20:0] pixel_out,    // 17+3 = 20:0 (21 bits)
    output wire               valid_out,
    output wire        [ 3:0] out_row,
    output wire        [ 3:0] out_col
);

  wire [3:0] row_cnt, col_cnt;
  wire [7:0] addr_top, addr_mid, addr_bot;
  wire [7:0] row_top, row_mid, row_bot;
  wire        addr_valid;

  // Window Generator connections
  wire [71:0] window_out;
  wire        win_valid;
  wire [ 3:0] win_row;
  wire [ 3:0] win_col;

  // Kernel Registers connections
  wire [0:7] k0, k1, k2, k3, k4, k5, k6, k7, k8;
  wire [ 71:0] packed_k;

  // MAC connections
  wire [152:0] prod;
  wire         mac_valid;
  wire [  3:0] mac_row;
  wire [  3:0] mac_col;

  addr_gen u_addr_gen (
      .clk(clk),
      .rst_n(rst_n),
      .row_cnt(row_cnt),
      .col_cnt(col_cnt),
      .addr_top(addr_top),
      .addr_mid(addr_mid),
      .addr_bot(addr_bot),
      .valid(addr_valid)
  );

  image_bram u_image_bram (
      .clk(clk),
      .addr_top(addr_top),
      .addr_mid(addr_mid),
      .addr_bot(addr_bot),
      .row_top(row_top),
      .row_mid(row_mid),
      .row_bot(row_bot)
  );

  window_gen #(
      .PIXEL_WIDTH(8),
      .TILE_ROWS  (16),
      .TILE_COLS  (16)
  ) u_window_gen (
      .clk(clk),
      .rst_n(rst_n),
      .row_top(row_top),
      .row_mid(row_mid),
      .row_bot(row_bot),
      .valid_in(addr_valid),
      .row_cnt(row_cnt),
      .col_cnt(col_cnt),
      .window_out(window_out),
      .win_valid(win_valid),
      .out_row(win_row),
      .out_col(win_col)
  );

  // Kernel Register Instantiation
  k_regs u_k_regs (
      .clk(clk),
      .rst_n(rst_n),
      .filter0_sel(filter0_sel),
      .filter1_sel(filter1_sel),
      .filter2_sel(filter2_sel),
      .k0(k0),
      .k1(k1),
      .k2(k2),
      .k3(k3),
      .k4(k4),
      .k5(k5),
      .k6(k6),
      .k7(k7),
      .k8(k8)
  );

  // Pack the individual 8-bit kernels into a 72-bit vector for the MAC
  assign packed_k = {k8, k7, k6, k5, k4, k3, k2, k1, k0};

  // Multiplier Array Instantiation
  mac_mult_array #(
      .PIXEL_WIDTH  (8),
      .PRODUCT_WIDTH(17),
      .KERNEL_WIDTH (3)
  ) u_mac (
      .clk(clk),
      .rst_n(rst_n),
      .win(window_out),
      .k(packed_k),
      .valid_in(win_valid),
      .out_row(win_row),
      .out_col(win_col),
      .prod(prod),
      .valid_out(mac_valid),
      .out_row_d(mac_row),
      .out_col_d(mac_col)
  );

  // Adder Tree Instantiation
  adder_tree #(
      .WIDTH(17)
  ) u_adder_tree (
      .clk(clk),
      .rst_n(rst_n),
      .valid_in(mac_valid),
      .out_row_d(mac_row),
      .out_col_d(mac_col),
      .in1(prod[16:0]),
      .in2(prod[33:17]),
      .in3(prod[50:34]),
      .in4(prod[67:51]),
      .in5(prod[84:68]),
      .in6(prod[101:85]),
      .in7(prod[118:102]),
      .in8(prod[135:119]),
      .in9(prod[152:136]),
      .pixel_out(pixel_out),
      .valid_out(valid_out),
      .out_row_f(out_row),
      .out_col_f(out_col)
  );

endmodule
