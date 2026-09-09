`timescale 1ns / 1ps
module system_top_tb;

  reg clk;
  reg vga_clk_in;
  reg rst_n;
  reg filter0_sel, filter1_sel, filter2_sel;

  wire h_sync, v_sync, v_on;
  wire [7:0] r, g, b;
  wire vga_blank_N, vga_sync_N;

  localparam CLK_PERIOD = 10;
  localparam VGA_CLK_PERIOD = 40;

  initial clk = 1'b0;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial vga_clk_in = 1'b0;
  always #(VGA_CLK_PERIOD / 2) vga_clk_in = ~vga_clk_in;


  system_top dut (
      .clk        (clk),
      .vga_clk_in (vga_clk_in),
      .rst_n      (rst_n),
      .filter0_sel(filter0_sel),
      .filter1_sel(filter1_sel),
      .filter2_sel(filter2_sel),
      .h_sync     (h_sync),
      .v_sync     (v_sync),
      .v_on       (v_on),
      .r          (r),
      .g          (g),
      .b          (b),
      .vga_blank_N(vga_blank_N),
      .vga_sync_N (vga_sync_N)
  );

  localparam IMG_ROWS = 16, IMG_COLS = 16;
  localparam OUT_ROWS = 14, OUT_COLS = 14;
  localparam NUM_PIX = OUT_ROWS * OUT_COLS;  // 196

  reg [7:0] golden_img[0:IMG_ROWS*IMG_COLS-1];
  reg signed [7:0] golden_kernel[0:8];  // k0..k8, row-major TL->BR
  reg [7:0] golden_pix[0:NUM_PIX-1];  // expected clipped pixel value
  reg golden_checked[0:NUM_PIX-1];  // dedupe repeated frames

  integer gi, gj, gm, gn, gk;
  integer gsum;

  task automatic build_golden_model;
    integer p;
    begin
      $readmemh("../mem_files/image.mem", golden_img);
      $readmemh("../mem_files/outline.mem", golden_kernel);

      for (gi = 0; gi < OUT_ROWS; gi = gi + 1) begin
        for (gj = 0; gj < OUT_COLS; gj = gj + 1) begin
          gsum = 0;
          gk   = 0;
          for (gm = 0; gm < 3; gm = gm + 1) begin
            for (gn = 0; gn < 3; gn = gn + 1) begin
              gsum = gsum + $signed(golden_kernel[gk]) *
                  $signed({1'b0, golden_img[(gi+gm)*IMG_COLS+(gj+gn)]});
              gk = gk + 1;
            end
          end
          if (gsum < 0) golden_pix[gi*OUT_COLS+gj] = 8'd0;
          else if (gsum <= 255) golden_pix[gi*OUT_COLS+gj] = gsum[7:0];
          else golden_pix[gi*OUT_COLS+gj] = 8'd255;
        end
      end

      for (p = 0; p < NUM_PIX; p = p + 1) golden_checked[p] = 1'b0;
    end
  endtask

  integer write_count;
  integer match_count;
  integer error_count;
  integer addr;

  initial begin
    write_count = 0;
    match_count = 0;
    error_count = 0;
  end

  always @(posedge clk) begin
    if (rst_n && dut.fr_write_en) begin
      addr = dut.fr_write_addr;
      if (addr >= NUM_PIX) begin
        error_count = error_count + 1;
        $display("[%0t] ERROR: write to out-of-range frame-buffer addr=%0d (expected 0..%0d)",
                 $time, addr, NUM_PIX - 1);
      end else if (!golden_checked[addr]) begin
        golden_checked[addr] = 1'b1;
        write_count = write_count + 1;
        if (dut.fr_write_data === golden_pix[addr]) begin
          match_count = match_count + 1;
        end else begin
          error_count = error_count + 1;
          $display("[%0t] MISMATCH addr=%0d (row=%0d,col=%0d): expected=0x%02h got=0x%02h", $time,
                   addr, addr / OUT_COLS, addr % OUT_COLS, golden_pix[addr], dut.fr_write_data);
        end
      end

    end
  end


  integer timeout_cycles;
  localparam TIMEOUT_LIMIT = 5000;

  initial begin

    rst_n       = 1'b0;
    filter0_sel = 1'b0;
    filter1_sel = 1'b0;
    filter2_sel = 1'b0;

    build_golden_model();

    repeat (5) @(posedge clk);
    rst_n = 1'b1;

    filter2_sel = 1'b1;

    timeout_cycles = 0;
    while ((write_count < NUM_PIX) && (timeout_cycles < TIMEOUT_LIMIT)) begin
      @(posedge clk);
      timeout_cycles = timeout_cycles + 1;
    end

    repeat (10) @(posedge clk);

    $display("--------------------------------------------------");
    if (timeout_cycles >= TIMEOUT_LIMIT && write_count < NUM_PIX) begin
      $display("TEST FAILED: timed out after %0d cycles, only %0d/%0d pixels observed",
               TIMEOUT_LIMIT, write_count, NUM_PIX);
    end else if (error_count == 0 && write_count == NUM_PIX) begin
      $display("TEST PASSED: all %0d output pixels match the golden model", NUM_PIX);
    end else begin
      $display("TEST FAILED: %0d/%0d pixels written, %0d mismatches", write_count, NUM_PIX,
               error_count);
    end
    $display("--------------------------------------------------");

    $finish;
  end

  initial begin
    #(CLK_PERIOD * (TIMEOUT_LIMIT + 200));
    $display("TEST FAILED: global watchdog timeout, simulation did not finish");
    $finish;
  end

endmodule
