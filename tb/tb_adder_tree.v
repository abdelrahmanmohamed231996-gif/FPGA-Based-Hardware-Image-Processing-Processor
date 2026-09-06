`timescale 1ns / 1ps

module tb_adder_tree;

  // Parameters matching the adder_tree module
  parameter WIDTH = 17;

  // Inputs
  reg clk;
  reg rst_n;
  reg valid_in;
  reg [3:0] out_row_d;
  reg [3:0] out_col_d;
  reg signed [WIDTH-1:0] in1, in2, in3, in4, in5, in6, in7, in8, in9;

  // Outputs
  wire signed [WIDTH+3:0] pixel_out;
  wire valid_out;
  wire [3:0] out_row_f;
  wire [3:0] out_col_f;

  // Instantiate the Unit Under Test (UUT)
  adder_tree #(
      .WIDTH(WIDTH)
  ) uut (
      .clk(clk),
      .rst_n(rst_n),
      .valid_in(valid_in),
      .out_row_d(out_row_d),
      .out_col_d(out_col_d),
      .in1(in1),
      .in2(in2),
      .in3(in3),
      .in4(in4),
      .in5(in5),
      .in6(in6),
      .in7(in7),
      .in8(in8),
      .in9(in9),
      .pixel_out(pixel_out),
      .valid_out(valid_out),
      .out_row_f(out_row_f),
      .out_col_f(out_col_f)
  );

  // 100MHz Clock generation
  always #5 clk = ~clk;

  initial begin
    // Initialize Inputs
    clk = 0;
    rst_n = 0;
    valid_in = 0;
    out_row_d = 4'd0;
    out_col_d = 4'd0;
    in1 = 0;
    in2 = 0;
    in3 = 0;
    in4 = 0;
    in5 = 0;
    in6 = 0;
    in7 = 0;
    in8 = 0;
    in9 = 0;

    // Wait for global reset to finish
    #20;
    rst_n = 1;

    // Wait for next clock edge to apply stimulus
    @(posedge clk);

    // Assert valid_in and provide inputs[cite: 1]
    valid_in = 1;
    out_row_d = 4'd5;
    out_col_d = 4'd10;

    // Provide test values: 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 = 45
    in1 = 17'sd1;
    in2 = 17'sd2;
    in3 = 17'sd3;
    in4 = 17'sd4;
    in5 = 17'sd5;
    in6 = 17'sd6;
    in7 = 17'sd7;
    in8 = 17'sd8;
    in9 = 17'sd9;

    // Hold valid_in high for just one cycle to test pipeline logic[cite: 2]
    @(posedge clk);
    valid_in = 0;

    // Clear input values to ensure outputs only reflect the captured pipeline data
    out_row_d = 4'd0;
    out_col_d = 4'd0;
    in1 = 0;
    in2 = 0;
    in3 = 0;
    in4 = 0;
    in5 = 0;
    in6 = 0;
    in7 = 0;
    in8 = 0;
    in9 = 0;

    // Wait 5 clock cycles to observe the output propagate through the 4-stage pipeline
    repeat (10) @(posedge clk);

    // End Simulation
    $finish;
  end

endmodule
