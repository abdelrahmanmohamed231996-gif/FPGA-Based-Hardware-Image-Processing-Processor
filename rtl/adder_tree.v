module adder_tree #(
    parameter WIDTH = 17
) (
    input wire clk,
    input wire rst_n,
    input wire valid_in,
    input wire [3:0] out_row_d,
    input wire [3:0] out_col_d,
    input wire signed [WIDTH-1:0] in1,
    input wire signed [WIDTH-1:0] in2,
    input wire signed [WIDTH-1:0] in3,
    input wire signed [WIDTH-1:0] in4,
    input wire signed [WIDTH-1:0] in5,
    input wire signed [WIDTH-1:0] in6,
    input wire signed [WIDTH-1:0] in7,
    input wire signed [WIDTH-1:0] in8,
    input wire signed [WIDTH-1:0] in9,

    output wire signed [WIDTH+3:0] pixel_out,
    output reg valid_out,
    output reg [3:0] out_row_f,
    output reg [3:0] out_col_f
);

  wire signed [  WIDTH:0] sum_reg_add_in12;
  wire signed [  WIDTH:0] sum_reg_add_in34;
  wire signed [  WIDTH:0] sum_reg_add_in56;
  wire signed [  WIDTH:0] sum_reg_add_in78;

  wire signed [WIDTH+1:0] sum_reg_add_in1234;
  wire signed [WIDTH+1:0] sum_reg_add_in5678;

  wire signed [WIDTH+2:0] sum_reg_add_in12345678;
  wire signed [WIDTH-1:0] in9_w;


  in9_reg #(WIDTH) reg_inst (
      .clk(clk),
      .rst_n(rst_n),
      .data_in(in9),
      .data_out(in9_w)
  );



  signed_adder_subtractor #(
      .WIDTH(17)
  ) adder_inst1 (
      .dataa(in1),
      .datab(in2),
      .add_sub(1'b1),
      .clk(clk),
      .result(sum_reg_add_in12)
  );

  signed_adder_subtractor #(
      .WIDTH(17)
  ) adder_inst2 (
      .dataa(in3),
      .datab(in4),
      .add_sub(1'b1),
      .clk(clk),
      .result(sum_reg_add_in34)
  );

  signed_adder_subtractor #(
      .WIDTH(17)
  ) adder_inst3 (
      .dataa(in5),
      .datab(in6),
      .add_sub(1'b1),
      .clk(clk),
      .result(sum_reg_add_in56)
  );

  signed_adder_subtractor #(
      .WIDTH(17)
  ) adder_inst4 (
      .dataa(in7),
      .datab(in8),
      .add_sub(1'b1),
      .clk(clk),
      .result(sum_reg_add_in78)
  );

  signed_adder_subtractor #(
      .WIDTH(18)
  ) adder_inst5 (
      .dataa(sum_reg_add_in12),
      .datab(sum_reg_add_in34),
      .add_sub(1'b1),
      .clk(clk),
      .result(sum_reg_add_in1234)
  );

  signed_adder_subtractor #(
      .WIDTH(18)
  ) adder_inst6 (
      .dataa(sum_reg_add_in56),
      .datab(sum_reg_add_in78),
      .add_sub(1'b1),
      .clk(clk),
      .result(sum_reg_add_in5678)
  );

  signed_adder_subtractor #(
      .WIDTH(19)
  ) adder_inst7 (
      .dataa(sum_reg_add_in1234),
      .datab(sum_reg_add_in5678),
      .add_sub(1'b1),
      .clk(clk),
      .result(sum_reg_add_in12345678)
  );

  signed_adder_subtractor #(
      .WIDTH(20)
  ) adder_inst8 (
      .dataa(sum_reg_add_in12345678),
      .datab({{3{in9_w[16]}}, in9_w}),
      .add_sub(1'b1),
      .clk(clk),
      .result(pixel_out)
  );

  //   delay_multibit #(
  //       .WIDTH(1)
  //   ) valid_delay_inst (
  //       .clk(clk),
  //       .rst_n(rst_n),
  //       .valid_in(valid_in),
  //       .data_in(1'b1),
  //       .data_out(valid_out)
  //   );

  //   delay_multibit #(
  //       .WIDTH(4)
  //   ) out_row_delay_inst (
  //       .clk(clk),
  //       .rst_n(rst_n),
  //       .valid_in(valid_in),
  //       .data_in(out_row_d),
  //       .data_out(out_row_f)
  //   );

  //   delay_multibit #(
  //       .WIDTH(4)
  //   ) out_col_delay_inst (
  //       .clk(clk),
  //       .rst_n(rst_n),
  //       .valid_in(valid_in),
  //       .data_in(out_col_d),
  //       .data_out(out_col_f)
  //   );

  reg           valid_pipe  [0:3];
  reg     [3:0] out_row_pipe[0:3];
  reg     [3:0] out_col_pipe[0:3];

  integer       idx;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (idx = 0; idx < 4; idx = idx + 1) begin
        valid_pipe[idx]   <= 1'b0;
        out_row_pipe[idx] <= 4'b0;
        out_col_pipe[idx] <= 4'b0;
      end
      valid_out <= 1'b0;
      out_row_f <= 4'b0;
      out_col_f <= 4'b0;
    end else begin
      valid_pipe[0]   <= valid_in;
      out_row_pipe[0] <= out_row_d;
      out_col_pipe[0] <= out_col_d;

      for (idx = 1; idx < 3; idx = idx + 1) begin
        valid_pipe[idx]   <= valid_pipe[idx-1];
        out_row_pipe[idx] <= out_row_pipe[idx-1];
        out_col_pipe[idx] <= out_col_pipe[idx-1];
      end

      valid_out <= valid_pipe[2];
      out_row_f <= out_row_pipe[2];
      out_col_f <= out_col_pipe[2];
    end
  end


endmodule
