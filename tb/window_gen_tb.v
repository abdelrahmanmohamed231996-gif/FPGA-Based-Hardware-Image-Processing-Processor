`timescale 1ns / 1ps

module window_gen_tb;

  localparam PIXEL_WIDTH = 8;
  localparam TILE_ROWS = 6;
  localparam TILE_COLS = 6;

  reg clk, rst_n;
  reg [PIXEL_WIDTH-1:0] row_top, row_mid, row_bot;
  reg valid_in;
  reg [3:0] row_cnt, col_cnt;

  wire [(PIXEL_WIDTH*9)-1:0] window_out;
  wire win_valid;
  wire [3:0] out_row, out_col;

  integer errors = 0;
  integer checks = 0;

  window_gen #(
      .PIXEL_WIDTH(PIXEL_WIDTH),
      .TILE_ROWS  (TILE_ROWS),
      .TILE_COLS  (TILE_COLS)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .row_top(row_top),
      .row_mid(row_mid),
      .row_bot(row_bot),
      .valid_in(valid_in),
      .row_cnt(row_cnt),
      .col_cnt(col_cnt),
      .window_out(window_out),
      .win_valid(win_valid),
      .out_row(out_row),
      .out_col(out_col)
  );

  // ---- clock ----
  always #5 clk = ~clk;

  // ---- golden reference model: mirrors the DUT's internal registers ----
  reg [PIXEL_WIDTH-1:0] ref_top[0:2], ref_mid[0:2], ref_bot[0:2];
  reg [3:0] ref_row_d, ref_col_d;
  reg ref_valid_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ref_top[0]  <= 0;
      ref_top[1]  <= 0;
      ref_top[2]  <= 0;
      ref_mid[0]  <= 0;
      ref_mid[1]  <= 0;
      ref_mid[2]  <= 0;
      ref_bot[0]  <= 0;
      ref_bot[1]  <= 0;
      ref_bot[2]  <= 0;
      ref_row_d   <= 0;
      ref_col_d   <= 0;
      ref_valid_d <= 0;
    end else begin
      ref_valid_d <= valid_in;
      if (valid_in) begin
        ref_top[0] <= ref_top[1];
        ref_top[1] <= ref_top[2];
        ref_top[2] <= row_top;
        ref_mid[0] <= ref_mid[1];
        ref_mid[1] <= ref_mid[2];
        ref_mid[2] <= row_mid;
        ref_bot[0] <= ref_bot[1];
        ref_bot[1] <= ref_bot[2];
        ref_bot[2] <= row_bot;
        ref_row_d  <= row_cnt;
        ref_col_d  <= col_cnt;
      end
    end
  end

  wire [(PIXEL_WIDTH*9)-1:0] exp_window = {
    ref_bot[2],
    ref_bot[1],
    ref_bot[0],
    ref_mid[2],
    ref_mid[1],
    ref_mid[0],
    ref_top[2],
    ref_top[1],
    ref_top[0]
  };

  wire exp_valid = ref_valid_d &&
                   (ref_row_d >= 2) && (ref_row_d <= TILE_ROWS - 1) &&
                   (ref_col_d >= 2) && (ref_col_d <= TILE_COLS - 1);

  wire [3:0] exp_row = ref_row_d - 4'd2;
  wire [3:0] exp_col = ref_col_d - 4'd2;

  task check;
    begin
      checks = checks + 1;

      if (window_out !== exp_window) begin
        errors = errors + 1;
        $display("[%0t] ERROR window_out mismatch: got=%h exp=%h", $time, window_out, exp_window);
      end

      if (win_valid !== exp_valid) begin
        errors = errors + 1;
        $display("[%0t] ERROR win_valid mismatch: got=%b exp=%b (row_d=%0d col_d=%0d)", $time,
                 win_valid, exp_valid, ref_row_d, ref_col_d);
      end

      if (exp_valid) begin
        if (out_row !== exp_row) begin
          errors = errors + 1;
          $display("[%0t] ERROR out_row mismatch: got=%0d exp=%0d", $time, out_row, exp_row);
        end
        if (out_col !== exp_col) begin
          errors = errors + 1;
          $display("[%0t] ERROR out_col mismatch: got=%0d exp=%0d", $time, out_col, exp_col);
        end
      end
    end
  endtask

  integer r, c;
  reg [PIXEL_WIDTH-1:0] px_cnt;

  initial begin
    $dumpfile("window_gen_tb.vcd");
    $dumpvars(0, window_gen_tb);

    clk = 0;
    rst_n = 0;
    valid_in = 0;
    row_top = 0;
    row_mid = 0;
    row_bot = 0;
    row_cnt = 0;
    col_cnt = 0;
    px_cnt = 0;

    repeat (3) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    // ---------------------------------------------------------------
    // Test 1: sweep row/col across and beyond the full tile.
    // Exercises left/top edge suppression, right/bottom edge
    // suppression, and steady-state window correctness.
    // ---------------------------------------------------------------
    for (r = 0; r < TILE_ROWS + 2; r = r + 1) begin
      for (c = 0; c < TILE_COLS + 2; c = c + 1) begin
        @(negedge clk);
        row_cnt  = r[3:0];
        col_cnt  = c[3:0];
        row_top  = px_cnt;
        px_cnt   = px_cnt + 1;
        row_mid  = px_cnt + 8'h40;
        row_bot  = px_cnt + 8'h80;
        valid_in = 1'b1;
        @(posedge clk);
        #1 check;
      end
    end

    // ---------------------------------------------------------------
    // Test 2: pause valid_in mid-stream - shift register and
    // out_row/out_col/win_valid must hold, not corrupt, on the
    // cycle(s) valid_in is low.
    // ---------------------------------------------------------------
    for (r = 0; r < 3; r = r + 1) begin
      @(negedge clk);
      row_cnt  = 4'd4;
      col_cnt  = r[3:0] + 4'd3;
      row_top  = px_cnt;
      px_cnt   = px_cnt + 1;
      row_mid  = px_cnt + 8'h40;
      row_bot  = px_cnt + 8'h80;
      valid_in = (r != 1);  // deassert on the middle iteration
      @(posedge clk);
      #1 check;
    end

    // ---------------------------------------------------------------
    // Test 3: async reset mid-stream, then confirm clean resumption.
    // ---------------------------------------------------------------
    @(negedge clk);
    rst_n = 0;
    @(posedge clk);
    #1 check;

    @(negedge clk);
    rst_n    = 1;
    valid_in = 1'b0;
    @(posedge clk);
    #1 check;

    $display("--------------------------------------------------");
    $display("Checks run: %0d   Errors: %0d", checks, errors);
    if (errors == 0) $display("TEST PASSED");
    else $display("TEST FAILED");
    $finish;
  end

  // safety watchdog
  initial begin
    #100000;
    $display("TIMEOUT - simulation did not finish");
    $finish;
  end

endmodule
