// Quartus Prime Verilog Template
// Signed multiply with input and output registers

module signed_multiply_with_input_and_output_registers #(
    parameter WIDTH = 8
) (
    input clk,
    input signed [WIDTH:0] dataa,
    input signed [WIDTH-1:0] datab,
    output reg signed [2*WIDTH:0] dataout
);

  // Declare input and output registers
  reg signed  [  WIDTH:0] dataa_reg;
  reg signed  [WIDTH-1:0] datab_reg;
  wire signed [2*WIDTH:0] mult_out;

  // Store the result of the multiply
  assign mult_out = dataa_reg * datab_reg;

  // Update data
  always @(posedge clk) begin
    dataa_reg <= dataa;
    datab_reg <= datab;
    dataout   <= mult_out;
  end

endmodule
