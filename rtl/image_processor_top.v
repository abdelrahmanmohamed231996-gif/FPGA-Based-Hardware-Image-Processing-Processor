module image_processor_top (
       input wire rst_n,
       input wire clk,
       input wire filter0_sel,
       input wire filter1_sel,
       input wire filter2_sel,
       input wire [PIXEL_WIDTH-1:0]pixel_in,
       input wire pixel_valid_in,
       input wire frame_start,
       output wire [7:0] VGA_R
       output wire [7:0] VGA_G,
       output wire [7:0] VGA_B,
       output wire VGA_HS,
       output wire VGA_VS,
       output wire VGA_BLANK_N,
       output wire VGA_SYNC_N,
       output wire VGA_CLK);

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


//Input Interface — pixel_rx_if

// pixel_rx_if ) m0 (
//        .clk(clk),
//        .rst_n(rst_n),
//        .pixel_in(pixel_in),
//        .pixel_valid_in(pixel_valid_in),
//        .frame_start(frame_start),
//        .pixel_out(pixel_out_w),
//        .pixel_valid_out(pixel_valid_out_w),
//        .row_cnt(row_cnt_w),
//        .col_cnt(col_cnt_w)
//   );

wire [7:0] pixel_out_w;
wire pixel_valid_out_w;
wire [3:0] row_cnt_w;
wire [3:0] col_cnt_w;




//Line Buffers — line_buffer_fifo

// line_buffer_3x3 #(
//     .DATA_WIDTH(),
//     .IMAGE_HEIGHT(),
//     .IMAGE_WIDTH(),
//     .WINDOW_WIDTH(),
//     .WINDOW_HEIGHT()
//     ) m1 (
       .clk(clk),
       .rst_n(rst_n),
       .valid_in(pixel_valid_out_w),
       .pixel_in(pixel_out_w)
//     );

//Window Generator — window_gen

 window_gen #(
       .PIXEL_WIDTH(PIXEL_WIDTH),
       .TILE_ROWS(),
       .TILE_COLS() 
       ) m2(
       .clk(clk),
       .rst_n(rst_n),
       .row_top(),
       .row_mid(),
       .row_bot(),
       .valid_in(),
       .row_cnt(),
       .col_cnt(),
       .window_out(),
       .win_valid(),
       .out_row(),
       .out_col()
       );



//Kernel Register Bank — kernel_regs

k_regs  #(
       .CEF_WIDTH(),
       .PIXEL_WIDTH()
       ) m3 (
       .clk(clk),
       .rst_n(rst_n),
       .filter0_sel(),
       .filter1_sel(),
       .filter2_sel(),
       .k0(),
       .k1(),
       .k2(),
       .k3(),
       .k4(),
       .k5(),
       .k6(),
       .k7(),
       .k8()
       );

//Multipler Array — mac_mult_array

mac_mult_array #(
       .PIXEL_WIDTH(),
       .PRODUCT_WIDTH(),
       .KERNEL_WIDTH()
       ) m4 (
       .clk(clk),
       .rst_n(rst_n),
       .window_out(),
       .k({k8,k7,k6,k5,k4,k3,k2,k1,k0}),
       .win_valid(),
       .out_row(),
       .out_col(),
       .prod(),
       .valid_out(),
       .out_row_d(),
       .out_col_d()
       );

//Adder Tree — adder_tree

adder_tree #(
       .WIDTH()
        ) m5 (
       .clk(clk),
       .rst_n(rst_n),
       .valid_out(),
       .out_row_d(),
       .out_col_d(),
       .ds(prod[16:0]),
       .DS(prod[33:17]),
       .dws(prod[49:34]),
       .swq(prod[65:50]),
       .wq(prod[81:66]),
       .wq(prod[97:82]),
       .qw(prod[113:98]),
       .wq(prod[129:114]),
       .wq(prod[145:130]),
       .pixel_out(),
       .valid_out(),
       .out_row_f(),
       .out_col_f()
       );


//Output Assembly — output_assembly

output_ass #(
       .PIXEL_WIDTH(),
       .SUM_WIDTH()
       ) m6 (
       .clk(clk),
       .rst_n(rst_n),
       .pixel_out(),
       .valid_out(),
       .out_row_f(),
       .out_col_f(),
       .pixel_out(),
       .pixel_out_valid(),
       .mem_wr_en(),
       .mem_wr_addr()
       );


//Output Interface — output_if



out_if #(
       .PIXEL_WIDTH()
       ) m7 (
       .rst_n(rst_n),
       .pixel_out(),
       .pixel_out_valid(),
       .mem_wr_en(),
       .mem_wr_addr(),
       .write_data(),
       .write_en(),
       .write_addr()
       );


//Frame Buffer — dual_port_bram
	
	

fr_buf #(
       .PIXEL_WIDTH(),
       .ADDR_WIDTH()
       ) m8 (
       .clk(clk),
       .write_en(),
       .write_addr(),
       .write_data(),
       .VGA_CLK(),
       .rd_addr(),
       .rd_data()
       );



//VGA Controller — vga_ctrl

vga_controller m9 ( 
       .VGA_CLK(),
       .clk(clk),
       .rst_n(rst_n),
       .VGA_HS(),
       .VGA_VS(),
       .v_on(),
       .VGA_R(),
       .VGA_G(),
       .VGA_B(),
       .VGA_BLANK_N(),
       .VGA_SYNC_N(),
       .rd_data(),
       .rd_addr()
       );



endmodule