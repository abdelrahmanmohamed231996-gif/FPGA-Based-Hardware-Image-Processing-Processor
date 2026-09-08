module mac_mult_array #(
    parameter PIXEL_WIDTH   = 8,
    parameter PRODUCT_WIDTH = 17,
    parameter KERNEL_WIDTH  = 3

) (
    input wire clk,
    input wire rst_n,
    input wire [(PIXEL_WIDTH*KERNEL_WIDTH*KERNEL_WIDTH)-1:0] win,
    input wire signed [(PIXEL_WIDTH*KERNEL_WIDTH*KERNEL_WIDTH)-1:0] k,
    input wire valid_in,
    input wire [3:0] out_row,
    input wire [3:0] out_col,

    output wire [(PRODUCT_WIDTH*9)-1:0] prod,
    output reg valid_out,
    output reg [3:0] out_row_d,
    output reg [3:0] out_col_d
);

  reg valid_reg;
  reg [3:0] out_row_reg;
  reg [3:0] out_col_reg;


  signed_multiply_with_input_and_output_registers #(
      .WIDTH(PIXEL_WIDTH)
  ) mult_inst1 (
      .clk(clk),
      .dataa($signed({1'b0, win[7:0]})),
      .datab(k[7:0]),
      .dataout(prod[16:0])
  );

  signed_multiply_with_input_and_output_registers #(
      .WIDTH(PIXEL_WIDTH)
  ) mult_inst2 (
      .clk(clk),
      .dataa($signed({1'b0, win[15:8]})),
      .datab(k[15:8]),
      .dataout(prod[33:17])
  );
  signed_multiply_with_input_and_output_registers #(
      .WIDTH(PIXEL_WIDTH)
  ) mult_inst3 (
      .clk(clk),
      .dataa($signed({1'b0, win[23:16]})),
      .datab(k[23:16]),
      .dataout(prod[50:34])
  );
  signed_multiply_with_input_and_output_registers #(
      .WIDTH(PIXEL_WIDTH)
  ) mult_inst4 (
      .clk(clk),
      .dataa($signed({1'b0, win[31:24]})),
      .datab(k[31:24]),
      .dataout(prod[67:51])
  );

  signed_multiply_with_input_and_output_registers #(
      .WIDTH(PIXEL_WIDTH)
  ) mult_inst5 (
      .clk(clk),
      .dataa($signed({1'b0, win[39:32]})),
      .datab(k[39:32]),
      .dataout(prod[84:68])
  );

  signed_multiply_with_input_and_output_registers #(
      .WIDTH(PIXEL_WIDTH)
  ) mult_inst6 (
      .clk(clk),
      .dataa($signed({1'b0, win[47:40]})),
      .datab(k[47:40]),
      .dataout(prod[101:85])
  );

  signed_multiply_with_input_and_output_registers #(
      .WIDTH(PIXEL_WIDTH)
  ) mult_inst7 (
      .clk(clk),
      .dataa($signed({1'b0, win[55:48]})),
      .datab(k[55:48]),
      .dataout(prod[118:102])
  );

  signed_multiply_with_input_and_output_registers #(
      .WIDTH(PIXEL_WIDTH)
  ) mult_inst8 (
      .clk(clk),
      .dataa($signed({1'b0, win[63:56]})),
      .datab(k[63:56]),
      .dataout(prod[135:119])
  );

  signed_multiply_with_input_and_output_registers #(
      .WIDTH(PIXEL_WIDTH)
  ) mult_inst9 (
      .clk(clk),
      .dataa($signed({1'b0, win[71:64]})),
      .datab(k[71:64]),
      .dataout(prod[152:136])
  );


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_out <= 1'b0;
      out_row_d <= 4'b0;
      out_col_d <= 4'b0;

    end else if (valid_in) begin
      valid_out <= valid_reg;
      out_row_d <= out_row_reg;
      out_col_d <= out_col_reg;
    end
  end

  always @(posedge clk) begin
    if (valid_in) begin
      valid_reg   <= valid_in;
      out_row_reg <= out_row;
      out_col_reg <= out_col;
    end
  end

endmodule
