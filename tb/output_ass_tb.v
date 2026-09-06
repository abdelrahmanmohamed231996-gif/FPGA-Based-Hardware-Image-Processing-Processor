`timescale 1ns/1ps

module tb_output_ass;

reg clk;
reg rst_n;

reg signed [19:0] conv_sum;
reg valid_in;
reg [3:0] row_f;
reg [3:0] col_f;

wire [7:0] pixel_out;
wire pixel_out_valid;
wire mem_wr_en;
wire [7:0] mem_wr_addr;

integer checks;
integer errors;

output_ass dut (
    .clk(clk),
    .rst_n(rst_n),
    .conv_sum(conv_sum),
    .valid_in(valid_in),
    .row_f(row_f),
    .col_f(col_f),
    .pixel_out(pixel_out),
    .pixel_out_valid(pixel_out_valid),
    .mem_wr_en(mem_wr_en),
    .mem_wr_addr(mem_wr_addr)
);


// Clock = 20 ns
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end


// --------------------------------------------------
// CHECK TASK
// --------------------------------------------------

task check;
    input condition;
    input [200:0] message;

    begin
        checks = checks + 1;

        if (!condition) begin
            errors = errors + 1;
            $display("ERROR: %s", message);
        end
        else begin
            $display("PASS : %s", message);
        end
    end
endtask


// --------------------------------------------------
// TEST
// --------------------------------------------------

initial begin

    checks = 0;
    errors = 0;

    conv_sum = 0;
    valid_in = 0;
    row_f = 0;
    col_f = 0;

    // ==============================================
    // TEST 1 : RESET
    // ==============================================

    $display("\n================ TEST 1 : RESET ================");

    rst_n = 0;

    #5;

    check(pixel_out == 8'd0,
          "pixel_out reset");

    check(pixel_out_valid == 1'b0,
          "pixel_out_valid reset");

    check(mem_wr_en == 1'b0,
          "mem_wr_en reset");

    check(mem_wr_addr == 8'd0,
          "mem_wr_addr reset");


    // release reset
    rst_n = 1;

    @(posedge clk);
    #1;


    // ==============================================
    // TEST 2 : valid_in = 0
    // ==============================================

    $display("\n============= TEST 2 : INVALID INPUT ===========");

    valid_in = 0;
    conv_sum = 20'sd100;
    row_f = 4'd5;
    col_f = 4'd7;

    @(posedge clk);
    #1;

    check(pixel_out_valid == 1'b0,
          "invalid input -> pixel_out_valid = 0");

    check(mem_wr_en == 1'b0,
          "invalid input -> mem_wr_en = 0");


    // ==============================================
    // TEST 3 : NORMAL VALUE
    // ==============================================

    $display("\n========== TEST 3 : NORMAL PIXEL VALUE =========");

    valid_in = 1;
    conv_sum = 20'sd100;
    row_f = 4'd2;
    col_f = 4'd3;

    @(posedge clk);
    #1;

    check(pixel_out == 8'd100,
          "conv_sum 100 -> pixel_out 100");

    check(pixel_out_valid == 1'b1,
          "valid input -> pixel_out_valid = 1");

    check(mem_wr_en == 1'b1,
          "valid input -> mem_wr_en = 1");

    check(mem_wr_addr == 8'd31,
          "row 2 col 3 -> address 31");


    // ==============================================
    // TEST 4 : ZERO
    // ==============================================

    $display("\n=============== TEST 4 : ZERO ==================");

    conv_sum = 20'sd0;
    row_f = 4'd0;
    col_f = 4'd0;

    @(posedge clk);
    #1;

    check(pixel_out == 8'd0,
          "conv_sum 0 -> pixel_out 0");

    check(mem_wr_addr == 8'd0,
          "row 0 col 0 -> address 0");


    // ==============================================
    // TEST 5 : 255
    // ==============================================

    $display("\n=============== TEST 5 : 255 ==================");

    conv_sum = 20'sd255;
    row_f = 4'd0;
    col_f = 4'd13;

    @(posedge clk);
    #1;

    check(pixel_out == 8'd255,
          "conv_sum 255 -> pixel_out 255");

    check(mem_wr_addr == 8'd13,
          "row 0 col 13 -> address 13");


    // ==============================================
    // TEST 6 : 256
    // ==============================================

    $display("\n=============== TEST 6 : 256 ==================");

    conv_sum = 20'sd256;

    @(posedge clk);
    #1;

    check(pixel_out == 8'd255,
          "conv_sum 256 -> clipped to 255");


    // ==============================================
    // TEST 7 : 400
    // ==============================================

    $display("\n=============== TEST 7 : 400 ==================");

    conv_sum = 20'sd400;

    @(posedge clk);
    #1;

    check(pixel_out == 8'd255,
          "conv_sum 400 -> clipped to 255");


    // ==============================================
    // TEST 8 : LARGE POSITIVE VALUE
    // ==============================================

    $display("\n========== TEST 8 : LARGE POSITIVE =============");

    conv_sum = 20'sd1000;

    @(posedge clk);
    #1;

    check(pixel_out == 8'd255,
          "conv_sum 1000 -> clipped to 255");


    // ==============================================
    // TEST 9 : NEGATIVE VALUE
    // ==============================================

    $display("\n============= TEST 9 : NEGATIVE ================");

    conv_sum = -20'sd1;

    @(posedge clk);
    #1;

    check(pixel_out == 8'd0,
          "conv_sum -1 -> clipped to 0");


    // ==============================================
    // TEST 10 : LARGE NEGATIVE
    // ==============================================

    $display("\n========== TEST 10 : LARGE NEGATIVE ============");

    conv_sum = -20'sd500;

    @(posedge clk);
    #1;

    check(pixel_out == 8'd0,
          "conv_sum -500 -> clipped to 0");


    // ==============================================
    // TEST 11 : ADDRESS TEST
    // ==============================================

    $display("\n============= TEST 11 : ADDRESS ================");

    // row 1 col 0
    row_f = 4'd1;
    col_f = 4'd0;
    conv_sum = 20'sd50;

    @(posedge clk);
    #1;

    check(mem_wr_addr == 8'd14,
          "row 1 col 0 -> address 14");


    // row 1 col 1
    row_f = 4'd1;
    col_f = 4'd1;

    @(posedge clk);
    #1;

    check(mem_wr_addr == 8'd15,
          "row 1 col 1 -> address 15");


    // row 13 col 13
    row_f = 4'd13;
    col_f = 4'd13;

    @(posedge clk);
    #1;

    check(mem_wr_addr == 8'd195,
          "row 13 col 13 -> address 195");


    // ==============================================
    // TEST 12 : FULL ADDRESS COVERAGE
    // ==============================================

    $display("\n======= TEST 12 : FULL 14x14 ADDRESS ===========");

    // We check all 196 output pixels

    row_f = 0;
    col_f = 0;
    conv_sum = 20'sd100;
    valid_in = 1;

    repeat (14) begin

        repeat (14) begin

            @(posedge clk);
            #1;

            check(mem_wr_addr == ((row_f * 14) + col_f),
                  "address calculation");

            col_f = col_f + 1;

        end

        col_f = 0;
        row_f = row_f + 1;

    end


    // ==============================================
    // TEST 13 : VALID / WRITE ENABLE
    // ==============================================

    $display("\n======= TEST 13 : VALID / WRITE ENABLE =========");

    valid_in = 1;
    conv_sum = 20'sd123;

    @(posedge clk);
    #1;

    check(pixel_out_valid == 1'b1,
          "valid_in 1 -> pixel_out_valid 1");

    check(mem_wr_en == 1'b1,
          "valid_in 1 -> mem_wr_en 1");


    valid_in = 0;

    @(posedge clk);
    #1;

    check(pixel_out_valid == 1'b0,
          "valid_in 0 -> pixel_out_valid 0");

    check(mem_wr_en == 1'b0,
          "valid_in 0 -> mem_wr_en 0");


    // ==============================================
    // TEST 14 : LATENCY
    // ==============================================

    $display("\n============== TEST 14 : LATENCY ===============");

    valid_in = 1;
    conv_sum = 20'sd77;
    row_f = 4'd4;
    col_f = 4'd5;

    // Before clock edge, output should still contain
    // previous registered value.

    #5;

    check(pixel_out != 8'd77,
          "before clock edge output has not updated yet");

    @(posedge clk);
    #1;

    check(pixel_out == 8'd77,
          "after clock edge pixel_out updated");

    check(mem_wr_addr == 8'd61,
          "after clock edge address updated");

    check(pixel_out_valid == 1'b1,
          "after clock edge valid updated");

    check(mem_wr_en == 1'b1,
          "after clock edge write enable updated");


    // ==============================================
    // FINAL RESULT
    // ==============================================

    $display("\n==============================================");
    $display("TOTAL CHECKS = %0d", checks);
    $display("TOTAL ERRORS = %0d", errors);
    $display("==============================================");

    if (errors == 0)
        $display("ALL TESTS PASSED !!!");
    else
        $display("SOME TESTS FAILED !!!");

    $stop;

end

endmodule