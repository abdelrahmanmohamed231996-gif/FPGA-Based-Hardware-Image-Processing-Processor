module image_bram (
    input  wire       clk,
    input  wire [7:0] addr_top,
    input  wire [7:0] addr_mid,
    input  wire [7:0] addr_bot,
    output reg  [7:0] row_top,
    output reg  [7:0] row_mid,
    output reg  [7:0] row_bot
);
  (* ramstyle = "M10K" *)reg [7:0] image_mem_top[0:255];
  (* ramstyle = "M10K" *)reg [7:0] image_mem_mid[0:255];
  (* ramstyle = "M10K" *)reg [7:0] image_mem_bot[0:255];

  initial begin
    $readmemh("../mem_files/image.mem", image_mem_top);
    $readmemh("../mem_files/image.mem", image_mem_mid);
    $readmemh("../mem_files/image.mem", image_mem_bot);
  end


  always @(posedge clk) row_top <= image_mem_top[addr_top];
  always @(posedge clk) row_mid <= image_mem_mid[addr_mid];
  always @(posedge clk) row_bot <= image_mem_bot[addr_bot];

endmodule
