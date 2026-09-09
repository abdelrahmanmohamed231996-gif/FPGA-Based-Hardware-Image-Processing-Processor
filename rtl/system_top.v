module system_top (
    input wire clk,         // System clock for processing pipeline
    input wire vga_clk_in,  // Pixel clock for the VGA display
    input wire rst_n,

    // Kernel Selection
    input wire filter0_sel,
    input wire filter1_sel,
    input wire filter2_sel,

    // VGA Outputs
    output wire       h_sync,
    output wire       v_sync,
    output wire       v_on,
    output wire [7:0] r,
    output wire [7:0] g,
    output wire [7:0] b,
    output wire       vga_blank_N,
    output wire       vga_sync_N
);

  // -----------------------------------------------------------------
  // Internal Interconnects
  // -----------------------------------------------------------------
  // conv_top to output_ass
  wire signed [20:0] conv_sum;
  wire               conv_valid;
  wire        [ 3:0] conv_row;
  wire        [ 3:0] conv_col;

  // output_ass to out_if
  wire               pixel_out_valid;
  wire               mem_wr_en_ass;
  wire        [ 7:0] pixel_out_clipped;
  wire        [ 7:0] mem_wr_addr_ass;

  // out_if to fr_buf
  wire               fr_write_en;
  wire        [ 7:0] fr_write_addr;
  wire        [ 7:0] fr_write_data;

  // fr_buf to vga_controller
  wire        [ 7:0] vga_rd_addr;
  wire        [ 7:0] vga_rd_data;

  // -----------------------------------------------------------------
  // 1. Convolution Engine
  // -----------------------------------------------------------------
  conv_top u_conv_top (
      .clk(clk),
      .rst_n(rst_n),
      .filter0_sel(filter0_sel),
      .filter1_sel(filter1_sel),
      .filter2_sel(filter2_sel),
      .pixel_out(conv_sum),
      .valid_out(conv_valid),
      .out_row(conv_row),
      .out_col(conv_col)
  );

  // -----------------------------------------------------------------
  // 2. Output Assembly (Clipping & Address Calculation)
  // -----------------------------------------------------------------
  output_ass #(
      .PIXEL_WIDTH(8),
      .SUM_WIDTH  (21)  // Matched to conv_top's 21-bit output
  ) u_output_ass (
      .clk(clk),
      .rst_n(rst_n),
      .conv_sum(conv_sum),
      .valid_in(conv_valid),
      .row_f(conv_row),
      .col_f(conv_col),
      .pixel_out(pixel_out_clipped),
      .pixel_out_valid(pixel_out_valid),
      .mem_wr_en(mem_wr_en_ass),
      .mem_wr_addr(mem_wr_addr_ass)
  );

  // -----------------------------------------------------------------
  // 3. Output Interface
  // -----------------------------------------------------------------
  out_if #(
      .PIXEL_WIDTH(8)
  ) u_out_if (
      .rst_n(rst_n),
      .pixel_out(pixel_out_clipped),
      .pixel_out_valid(pixel_out_valid),
      .mem_wr_en(mem_wr_en_ass),
      .mem_wr_addr(mem_wr_addr_ass),
      .write_en(fr_write_en),
      .write_addr(fr_write_addr),
      .write_data(fr_write_data)
  );

  // -----------------------------------------------------------------
  // 4. Frame Buffer (Dual-Port RAM)
  // -----------------------------------------------------------------
  fr_buf #(
      .PIXEL_WIDTH(8),
      .ADDR_WIDTH (8)
  ) u_fr_buf (
      .wr_clk(clk),
      .write_en(fr_write_en),
      .write_addr(fr_write_addr),
      .write_data(fr_write_data),

      .rd_clk (vga_clk_in),
      .rd_addr(vga_rd_addr),
      .rd_data(vga_rd_data)
  );

  // -----------------------------------------------------------------
  // 5. VGA Controller
  // -----------------------------------------------------------------
  vga_controller u_vga_controller (
      .vga_clk(vga_clk_in),  // Driven by top-level input
      .ref_clk(clk),
      .rst_n(rst_n),
      .rd_data(vga_rd_data),
      .rd_addr(vga_rd_addr),
      .h_sync(h_sync),
      .v_sync(v_sync),
      .v_on(v_on),
      .r(r),
      .g(g),
      .b(b),
      .vga_blank_N(vga_blank_N),
      .vga_sync_N(vga_sync_N)
  );

endmodule
