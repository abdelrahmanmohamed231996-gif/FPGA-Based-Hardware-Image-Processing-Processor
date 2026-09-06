module in9_reg #(
    parameter WIDTH = 8
) (
    input wire clk,
    input wire rst_n,
    input wire [WIDTH-1:0] data_in,
    output wire [WIDTH-1:0] data_out
);

  // Array of 4 registers, each 'WIDTH' bits wide
  reg [WIDTH-1:0] shift_reg[0:3];
  integer i;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < 4; i = i + 1) begin
        shift_reg[i] <= {WIDTH{1'b0}};
      end
    end else begin
      shift_reg[0] <= data_in;  // Stage 1
      shift_reg[1] <= shift_reg[0];  // Stage 2
      shift_reg[2] <= shift_reg[1];  // Stage 3
    end
  end

  assign data_out = shift_reg[2];

endmodule
