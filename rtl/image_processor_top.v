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
parameter PRODUCT_WIDTH = 16;
parameter SUM_WIDTH = 20;
parameter KERNEL_WIDTH = 3;
parameter WIDTH = 17;


//Input Interface — pixel_rx_if

// pixel_rx_if #(
//        .WIDTH()
//   ) m0 (
//        .clk(),
//        .rst_n(),
//        .pixel_in(),
//        .pixel_valid_in(),
//        .frame_start(),
//        .pixel_out(),
//        .pixel_valid_out(),
//        .row_cnt(),
//        .col_cnt
//   );

// reg  pixel_valid_out;
// reg  [3:0] row_cnt,col_cnt;
// reg  [PIXEL_WIDTH-1:0] pixel_out;
// reg pixel_out_valid,mem_wr_en;
// reg [ PIXEL_WIDTH-1:0] pixel_out_output_assembly,mem_wr_addr;
// wire write_en;
// wire [7:0] write_addr,write_data;

// wire [7:0]  rd_data,rd_addr;


//Input Interface — pixel_rx_if


//Line Buffers — line_buffer_fifo

// line_buffer_fifo #(
//        .WIDTH()
//     ) m1 (

//     );

//Window Generator — window_gen

 window_gen #(
       .PIXEL_WIDTH(PIXEL_WIDTH),
       .TILE_ROWS(),
       .TILE_COLS() 
       ) m3(
       .clk(),
       .rst_n(),
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
k_regs  #(COEF_WIDTH,PIXEL_WIDTH) m4(clk,rst_n,filter0_sel,filter1_sel,filter2_sel,k0,k1,k2,k3,k4,k5,k6,k7,k8);

//Multiplier Array — mac_mult_array

mac_mult_array #(PIXEL_WIDTH,PRODUCT_WIDTH,KERNEL_WIDTH) m5(clk,rst_n,window_out,{k8,k7,k6,k5,k4,k3,k2,k1,k0}
,win_valid,out_row,out_col,prod,valid_out,out_row_d,out_col_d);

//Adder Tree — adder_tree

adder_tree #( WIDTH ) m6 (clk,rst_n,valid_out, out_row_d, out_col_d,prod[16:0],prod[33:17],prod[49:34],
prod[65:50],prod[81:66],prod[97:82],prod[113:98],prod[129:114],prod[145:130],pixel_out,valid_out,out_row_f,out_col_f);
//Output Assembly — output_assembly


output_ass #(PIXEL_WIDTH,SUM_WIDTH) m7(clk,rst_n,pixel_out,valid_out,out_row_f,out_col_f,pixel_out,pixel_out_valid,mem_wr_en,mem_wr_addr);


//Output Interface — output_if



out_if #(PIXEL_WIDTH) m8(rst_n,pixel_out,pixel_out_valid,mem_wr_en,
mem_wr_addr,write_data,
write_en,write_addr);


//Frame Buffer — dual_port_bram
	
	

fr_buf #(PIXEL_WIDTH,ADDR_WIDTH) m9 (clk,write_en,write_addr,write_data,VGA_CLK,rd_addr,rd_data);



//VGA Controller — vga_ctrl

vga_controller #(s0,s1,s2,s3) m10(VGA_CLK,clk,rst_n,VGA_HS,VGA_VS,v_on, VGA_R,VGA_G,VGA_B,VGA_BLANK_N,VGA_SYNC_N,rd_data,
rd_addr);







endmodule