module input_interface (
    // Inputs
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] pixel_in,
    input  wire       pixel_valid_in,
    input  wire       frame_start,

    // Outputs
    output wire [7:0] pixel_out,
    output wire       pixel_valid_out,
    output wire [3:0] row_cnt,
    output wire [3:0] col_cnt
);

endmodule