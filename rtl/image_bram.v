module image_bram (
    input wire clk,
    input wire [7:0] addr,
    output reg [7:0] image_mem_top,
    output reg [7:0] image_mem_mid,
    output reg [7:0] image_mem_bot

);
  reg [7:0] image_mem_top[0:255];
  reg [7:0] image_mem_mid[0:255];
  reg [7:0] image_mem_bot[0:255];

  initial $readmemh("image.mem", image_mem);

  always @(posedge clk) begin
    data_out <= image_mem[addr];

  end
endmodule
