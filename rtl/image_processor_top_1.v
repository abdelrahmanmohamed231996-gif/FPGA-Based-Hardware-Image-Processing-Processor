module image_processor_top (
    input wire rst_n,
    input wire clk,
    input wire filter0_sel,
    input wire filter1_sel,
    input wire filter2_sel,
    input wire [PIXEL_WIDTH-1:0] pixel_in,
    input wire pixel_valid_in,
    input wire frame_start,
    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS,
    output wire VGA_BLANK_N,
    output wire VGA_SYNC_N,
    output wire VGA_CLK
);

  parameter PIXEL_WIDTH = 8;
  parameter COEF_WIDTH = 8;
  parameter ADDR_WIDTH = 8;
  parameter TILE_COLS = 16;
  parameter TILE_ROWS = 16;
  parameter IMG_SIZE = 16;
  parameter PRODUCT_WIDTH = 17;
  parameter SUM_WIDTH = 20;
  parameter KERNEL_WIDTH = 3;
  parameter WIDTH = 17;

  // Internal wires
  wire [PIXEL_WIDTH-1:0] pixel_out_w;
  wire pixel_valid_out_w;
  wire [3:0] row_cnt_w;
  wire [3:0] col_cnt_w;

  wire [PIXEL_WIDTH-1:0] window[0:2][0:2];
  wire valid_window_w;

  wire [PIXEL_WIDTH-1:0] row_top_w;
  wire [PIXEL_WIDTH-1:0] row_mid_w;
  wire [PIXEL_WIDTH-1:0] row_bot_w;
  wire valid_in_window;

  wire [(PIXEL_WIDTH*9)-1:0] window_out_w;
  wire win_valid_w;
  wire [3:0] out_row_w;
  wire [3:0] out_col_w;

  wire signed [COEF_WIDTH-1:0] k0, k1, k2, k3, k4, k5, k6, k7, k8;
  wire [(COEF_WIDTH*9)-1:0] k_concat;

  wire [(PRODUCT_WIDTH*9)-1:0] prod_w;
  wire valid_out_mac;
  wire [3:0] out_row_d_w;
  wire [3:0] out_col_d_w;

  wire signed [PRODUCT_WIDTH-1:0] prod1, prod2, prod3, prod4, prod5, prod6, prod7, prod8, prod9;

  wire signed [SUM_WIDTH-1:0] pixel_out_adder;
  wire valid_out_adder;
  wire [3:0] out_row_f_w;
  wire [3:0] out_col_f_w;

  wire [PIXEL_WIDTH-1:0] pixel_out_asm;
  wire pixel_out_valid_asm;
  wire mem_wr_en_asm;
  wire [ADDR_WIDTH-1:0] mem_wr_addr_asm;

  wire write_en_if;
  wire [ADDR_WIDTH-1:0] write_addr_if;
  wire [PIXEL_WIDTH-1:0] write_data_if;

  wire [PIXEL_WIDTH-1:0] rd_data_fb;
  wire [ADDR_WIDTH-1:0] rd_addr_vga;

  wire vga_clk_w;

  assign VGA_CLK = vga_clk_w;
  assign vga_clk_w = clk;  // Placeholder; ideally use PLL

  assign row_top_w = window[0][2];
  assign row_mid_w = window[1][2];
  assign row_bot_w = window[2][2];
  assign valid_in_window = valid_window_w;

  assign k_concat = {k8, k7, k6, k5, k4, k3, k2, k1, k0};

  assign prod1 = prod_w[PRODUCT_WIDTH-1:0];
  assign prod2 = prod_w[2*PRODUCT_WIDTH-1:PRODUCT_WIDTH];
  assign prod3 = prod_w[3*PRODUCT_WIDTH-1:2*PRODUCT_WIDTH];
  assign prod4 = prod_w[4*PRODUCT_WIDTH-1:3*PRODUCT_WIDTH];
  assign prod5 = prod_w[5*PRODUCT_WIDTH-1:4*PRODUCT_WIDTH];
  assign prod6 = prod_w[6*PRODUCT_WIDTH-1:5*PRODUCT_WIDTH];
  assign prod7 = prod_w[7*PRODUCT_WIDTH-1:6*PRODUCT_WIDTH];
  assign prod8 = prod_w[8*PRODUCT_WIDTH-1:7*PRODUCT_WIDTH];
  assign prod9 = prod_w[9*PRODUCT_WIDTH-1:8*PRODUCT_WIDTH];

  input_interface m0 (
      .clk(clk),
      .rst_n(rst_n),
      .pixel_in(pixel_in),
      .pixel_valid_in(pixel_valid_in),
      .frame_start(frame_start),
      .pixel_out(pixel_out_w),
      .pixel_valid_out(pixel_valid_out_w),
      .row_cnt(row_cnt_w),
      .col_cnt(col_cnt_w)
  );

  line_buffer_3x3 #(
      .DATA_WIDTH(PIXEL_WIDTH),
      .IMAGE_WIDTH(IMG_SIZE),
      .IMAGE_HEIGHT(IMG_SIZE),
      .WINDOW_WIDTH(KERNEL_WIDTH),
      .WINDOW_HEIGHT(KERNEL_WIDTH)
  ) m1 (
      .clk(clk),
      .rst_n(rst_n),
      .valid_in(pixel_valid_out_w),
      .pixel_in(pixel_out_w),
      .valid_window(valid_window_w),
      .window(window)
  );

  window_gen #(
      .PIXEL_WIDTH(PIXEL_WIDTH),
      .TILE_ROWS  (TILE_ROWS),
      .TILE_COLS  (TILE_COLS)
  ) m2 (
      .clk(clk),
      .rst_n(rst_n),
      .row_top(row_top_w),
      .row_mid(row_mid_w),
      .row_bot(row_bot_w),
      .valid_in(valid_in_window),
      .row_cnt(row_cnt_w),
      .col_cnt(col_cnt_w),
      .window_out(window_out_w),
      .win_valid(win_valid_w),
      .out_row(out_row_w),
      .out_col(out_col_w)
  );

  k_regs #(
      .COEF_WIDTH (COEF_WIDTH),
      .PIXEL_WIDTH(PIXEL_WIDTH)
  ) m3 (
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

  mac_mult_array #(
      .PIXEL_WIDTH  (PIXEL_WIDTH),
      .PRODUCT_WIDTH(PRODUCT_WIDTH),
      .KERNEL_WIDTH (KERNEL_WIDTH)
  ) m4 (
      .clk(clk),
      .rst_n(rst_n),
      .win(window_out_w),
      .k(k_concat),
      .valid_in(win_valid_w),
      .out_row(out_row_w),
      .out_col(out_col_w),
      .prod(prod_w),
      .valid_out(valid_out_mac),
      .out_row_d(out_row_d_w),
      .out_col_d(out_col_d_w)
  );

  adder_tree #(
      .WIDTH(PRODUCT_WIDTH)
  ) m5 (
      .clk(clk),
      .rst_n(rst_n),
      .valid_in(valid_out_mac),
      .out_row_d(out_row_d_w),
      .out_col_d(out_col_d_w),
      .in1(prod1),
      .in2(prod2),
      .in3(prod3),
      .in4(prod4),
      .in5(prod5),
      .in6(prod6),
      .in7(prod7),
      .in8(prod8),
      .in9(prod9),
      .pixel_out(pixel_out_adder),
      .valid_out(valid_out_adder),
      .out_row_f(out_row_f_w),
      .out_col_f(out_col_f_w)
  );

  output_ass #(
      .PIXEL_WIDTH(PIXEL_WIDTH),
      .SUM_WIDTH  (SUM_WIDTH)
  ) m6 (
      .clk(clk),
      .rst_n(rst_n),
      .conv_sum(pixel_out_adder),
      .valid_in(valid_out_adder),
      .row_f(out_row_f_w),
      .col_f(out_col_f_w),
      .pixel_out(pixel_out_asm),
      .pixel_out_valid(pixel_out_valid_asm),
      .mem_wr_en(mem_wr_en_asm),
      .mem_wr_addr(mem_wr_addr_asm)
  );

  out_if #(
      .PIXEL_WIDTH(PIXEL_WIDTH)
  ) m7 (
      .rst_n(rst_n),
      .pixel_out(pixel_out_asm),
      .pixel_out_valid(pixel_out_valid_asm),
      .mem_wr_en(mem_wr_en_asm),
      .mem_wr_addr(mem_wr_addr_asm),
      .write_data(write_data_if),
      .write_en(write_en_if),
      .write_addr(write_addr_if)
  );

  fr_buf #(
      .PIXEL_WIDTH(PIXEL_WIDTH),
      .ADDR_WIDTH (ADDR_WIDTH)
  ) m8 (
      .wr_clk(clk),
      .write_en(write_en_if),
      .write_addr(write_addr_if),
      .write_data(write_data_if),
      .rd_clk(vga_clk_w),
      .rd_addr(rd_addr_vga),
      .rd_data(rd_data_fb)
  );

  vga_controller m9 (
      .vga_clk(vga_clk_w),
      .ref_clk(clk),
      .rst_n(rst_n),
      .h_sync(VGA_HS),
      .v_sync(VGA_VS),
      .v_on(),
      .r(VGA_R),
      .g(VGA_G),
      .b(VGA_B),
      .vga_blank_N(VGA_BLANK_N),
      .vga_sync_N(VGA_SYNC_N),
      .rd_data(rd_data_fb),
      .rd_addr(rd_addr_vga)
  );

endmodule
