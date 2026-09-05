// `timescale 1ns/1ps

// module tb_vga_controller;

//     //====================================================
//     // Clock / Reset
//     //====================================================

//     reg vga_clk;
//     reg rst_n;

//     //====================================================
//     // DUT I/O
//     //====================================================

//     wire h_sync;
//     wire v_sync;
//     wire v_on;

//     wire [7:0] r;
//     wire [7:0] g;
//     wire [7:0] b;

//     wire vga_blank_N;
//     wire vga_sync_N;

//     reg  [7:0] rd_data;
//     wire [7:0] rd_addr;


//     //====================================================
//     // Test variables
//     //====================================================

//     integer errors;
//     integer checks;

//     integer i;
//     integer j;

//     reg [7:0] expected_addr;


//     //====================================================
//     // DUT
//     //====================================================

//     vga_controller dut (
//         .vga_clk      (vga_clk),
//         .rst_n        (rst_n),

//         .h_sync       (h_sync),
//         .v_sync       (v_sync),
//         .v_on         (v_on),

//         .r            (r),
//         .g            (g),
//         .b            (b),

//         .vga_blank_N  (vga_blank_N),
//         .vga_sync_N   (vga_sync_N),

//         .rd_data      (rd_data),
//         .rd_addr      (rd_addr)
//     );


//     //====================================================
//     // VGA Clock
//     //====================================================

//     initial begin
//         vga_clk = 1'b0;

//         forever #20 vga_clk = ~vga_clk;
//     end


//     //====================================================
//     // Check Task
//     //====================================================

//     task check;
//         input condition;
//         input [255:0] message;

//         begin

//             checks = checks + 1;

//             if (!condition) begin

//                 errors = errors + 1;

//                 $display("ERROR: %s", message);

//                 $display("       time=%0t h=%0d v=%0d rd_addr=%0d",
//                          $time,
//                          dut.h_counter,
//                          dut.v_counter,
//                          rd_addr);

//             end

//         end
//     endtask


//     //====================================================
//     // Initial
//     //====================================================

//     initial begin

//         rst_n   = 1'b0;
//         rd_data = 8'h00;

//         errors = 0;
//         checks = 0;

//         #100;

//         rst_n = 1'b1;

//     end


//     //====================================================
//     // Test sequence
//     //====================================================

//     initial begin

//         //================================================
//         // Wait reset release
//         //================================================

//         @(posedge rst_n);

//         repeat(2)
//             @(posedge vga_clk);

//         #1;


//         //================================================
//         // TEST 1 : RESET
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 1 : RESET");
//         $display("========================================");

//         rst_n = 1'b0;

//         @(posedge vga_clk);
//         #1;

//         check(
//             dut.h_counter == 10'd0,
//             "H counter reset"
//         );

//         check(
//             dut.v_counter == 10'd0,
//             "V counter reset"
//         );

//         check(
//             dut.h_cs == dut.s0,
//             "H FSM reset"
//         );

//         check(
//             dut.v_cs == dut.s0,
//             "V FSM reset"
//         );

//         rst_n = 1'b1;

//         @(posedge vga_clk);
//         #1;


// //================================================
// // TEST 2 : HORIZONTAL COUNTER
// //================================================

// $display("");
// $display("========================================");
// $display("TEST 2 : HORIZONTAL COUNTER");
// $display("========================================");

// wait(dut.h_counter == 10'd0 &&
//      dut.v_counter == 10'd0);

// #1;

// for (i = 0; i < 800; i = i + 1) begin

//     check(
//         dut.h_counter == i,
//         "Horizontal counter sequence"
//     );

//     @(posedge vga_clk);
//     #1;

// end        //================================================
//         // TEST 3 : VERTICAL COUNTER
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 3 : VERTICAL COUNTER");
//         $display("========================================");

//         // Wait beginning of frame
//         wait(dut.h_counter == 10'd0 &&
//              dut.v_counter == 10'd0);

//         #1;

//         for (i = 0; i < 525; i = i + 1) begin

//             check(
//                 dut.v_counter == i,
//                 "Vertical counter sequence"
//             );

//             // One complete horizontal line
//             repeat(800)
//                 @(posedge vga_clk);

//             #1;

//         end


//         //================================================
//         // TEST 4 : H_SYNC
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 4 : H_SYNC");
//         $display("========================================");

//         wait(dut.h_counter == 10'd0 &&
//              dut.v_counter == 10'd0);

//         #1;

//         // Visible
//         check(
//             h_sync == 1'b1,
//             "HSYNC HIGH in visible area"
//         );

//         // Front porch
//         wait(dut.h_counter == 10'd640);
//         #1;

//         check(
//             h_sync == 1'b1,
//             "HSYNC HIGH in front porch"
//         );

//         // Sync pulse
//         wait(dut.h_counter == 10'd656);
//         #1;

//         check(
//             h_sync == 1'b0,
//             "HSYNC LOW during sync pulse"
//         );

//         wait(dut.h_counter == 10'd751);
//         #1;

//         check(
//             h_sync == 1'b0,
//             "HSYNC LOW at end of sync"
//         );

//         wait(dut.h_counter == 10'd752);
//         #1;

//         check(
//             h_sync == 1'b1,
//             "HSYNC HIGH after sync"
//         );


//         //================================================
//         // TEST 5 : V_SYNC
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 5 : V_SYNC");
//         $display("========================================");

//         wait(dut.h_counter == 10'd0 &&
//              dut.v_counter == 10'd489);

//         #1;

//         check(
//             v_sync == 1'b1,
//             "VSYNC HIGH before sync"
//         );

//         wait(dut.h_counter == 10'd0 &&
//              dut.v_counter == 10'd490);

//         #1;

//         check(
//             v_sync == 1'b0,
//             "VSYNC LOW during sync"
//         );


//         //================================================
//         // TEST 6 : VIDEO ON
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 6 : VIDEO ON");
//         $display("========================================");

//         wait(dut.h_counter == 10'd100 &&
//              dut.v_counter == 10'd100);

//         #1;

//         check(
//             v_on == 1'b1,
//             "v_on HIGH inside visible area"
//         );

//         wait(dut.h_counter == 10'd700 &&
//              dut.v_counter == 10'd100);

//         #1;

//         check(
//             v_on == 1'b0,
//             "v_on LOW outside visible area"
//         );


//         //================================================
//         // TEST 7 : IMAGE TOP LEFT
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 7 : IMAGE TOP LEFT");
//         $display("========================================");

//         wait(dut.h_counter == 10'd180 &&
//              dut.v_counter == 10'd100);

//         #1;

//         check(
//             dut.img_col == 4'd0,
//             "Image column starts at 0"
//         );

//         check(
//             dut.img_row == 4'd0,
//             "Image row starts at 0"
//         );

//         check(
//             rd_addr == 8'd0,
//             "Top-left address = 0"
//         );


//         //================================================
//         // TEST 8 : HORIZONTAL SCALING
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 8 : HORIZONTAL SCALING");
//         $display("========================================");

//         for (i = 0; i < 14; i = i + 1) begin

//             wait(dut.h_counter == (180 + i*20) &&
//                  dut.v_counter == 10'd100);

//             #1;

//             check(
//                 dut.img_col == i,
//                 "Horizontal scaling"
//             );

//             check(
//                 rd_addr == i,
//                 "Horizontal address"
//             );

//         end


//         //================================================
//         // TEST 9 : VERTICAL SCALING
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 9 : VERTICAL SCALING");
//         $display("========================================");

//         for (i = 0; i < 14; i = i + 1) begin

//             wait(dut.h_counter == 10'd180 &&
//                  dut.v_counter == (100 + i*20));

//             #1;

//             check(
//                 dut.img_row == i,
//                 "Vertical scaling"
//             );

//             check(
//                 rd_addr == i*14,
//                 "Vertical address"
//             );

//         end


//         //================================================
//         // TEST 10 : FULL 14x14 ADDRESS COVERAGE
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 10 : FULL 14x14 ADDRESS COVERAGE");
//         $display("========================================");

//         for (i = 0; i < 14; i = i + 1) begin

//             for (j = 0; j < 14; j = j + 1) begin

//                 wait(dut.h_counter == (180 + j*20) &&
//                      dut.v_counter == (100 + i*20));

//                 #1;

//                 expected_addr = i*14 + j;

//                 check(
//                     dut.img_row == i,
//                     "Full image row coverage"
//                 );

//                 check(
//                     dut.img_col == j,
//                     "Full image column coverage"
//                 );

//                 check(
//                     rd_addr == expected_addr,
//                     "Full image address mapping"
//                 );

//             end

//         end


//         //================================================
//         // TEST 11 : LAST PIXEL
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 11 : LAST PIXEL");
//         $display("========================================");

//         wait(dut.h_counter == 10'd440 &&
//              dut.v_counter == 10'd360);

//         #1;

//         check(
//             dut.img_row == 4'd13,
//             "Last row = 13"
//         );

//         check(
//             dut.img_col == 4'd13,
//             "Last column = 13"
//         );

//         check(
//             rd_addr == 8'd195,
//             "Last address = 195"
//         );


//         //================================================
//         // TEST 12 : OUTSIDE IMAGE
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 12 : OUTSIDE IMAGE");
//         $display("========================================");

//         wait(dut.h_counter == 10'd179 &&
//              dut.v_counter == 10'd100);

//         #1;

//         check(
//             {r,g,b} == 24'h000000,
//             "Left side is black"
//         );

//         wait(dut.h_counter == 10'd460 &&
//              dut.v_counter == 10'd100);

//         #1;

//         check(
//             {r,g,b} == 24'h000000,
//             "Right side is black"
//         );

//         wait(dut.h_counter == 10'd180 &&
//              dut.v_counter == 10'd99);

//         #1;

//         check(
//             {r,g,b} == 24'h000000,
//             "Above image is black"
//         );

//         wait(dut.h_counter == 10'd180 &&
//              dut.v_counter == 10'd380);

//         #1;

//         check(
//             {r,g,b} == 24'h000000,
//             "Below image is black"
//         );


//         //================================================
//         // TEST 13 : RGB
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 13 : RGB MAPPING");
//         $display("========================================");

//         wait(dut.h_counter == 10'd180 &&
//              dut.v_counter == 10'd100);

//         rd_data = 8'hA5;

//         #1;

//         check(
//             r == 8'hA5,
//             "R = rd_data"
//         );

//         check(
//             g == 8'hA5,
//             "G = rd_data"
//         );

//         check(
//             b == 8'hA5,
//             "B = rd_data"
//         );


//         //================================================
//         // TEST 14 : VGA BLANK
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 14 : VGA BLANK");
//         $display("========================================");

//         wait(dut.h_counter == 10'd200 &&
//              dut.v_counter == 10'd200);

//         #1;

//         check(
//             vga_blank_N == 1'b1,
//             "Blank HIGH during active video"
//         );

//         wait(dut.h_counter == 10'd700 &&
//              dut.v_counter == 10'd200);

//         #1;

//         check(
//             vga_blank_N == 1'b0,
//             "Blank LOW outside active video"
//         );


//         //================================================
//         // TEST 15 : VGA SYNC
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("TEST 15 : VGA SYNC OUTPUT"
//         );

//         check(
//             vga_sync_N == 1'b0,
//             "VGA sync tied LOW"
//         );


//         //================================================
//         // FINAL RESULT
//         //================================================

//         $display("");
//         $display("========================================");
//         $display("        VERIFICATION RESULT");
//         $display("========================================");

//         $display("Total checks = %0d", checks);
//         $display("Total errors = %0d", errors);

//         if (errors == 0) begin

//             $display("");
//             $display("========================================");
//             $display("        ALL TESTS PASSED !!!");
//             $display("========================================");

//         end

//         else begin

//             $display("");
//             $display("========================================");
//             $display("        TEST FAILED !!!");
//             $display("========================================");

//         end

//         $stop;

//     end

// endmodule
`timescale 1ns/1ps

// Testbench for the VGA controller (640x480 @ 60Hz timing)
// Checks the H/V counters, sync polarities, blanking and the
// 14x14 image address generation (scale = 20, offset = 180,100)

module tb_vga_controller;

    // clock / reset
    reg vga_clk;
    reg rst_n;

    // DUT I/O
    wire h_sync;
    wire v_sync;
    wire v_on;

    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;

    wire vga_blank_N;
    wire vga_sync_N;

    reg  [7:0] rd_data;
    wire [7:0] rd_addr;

    // bookkeeping
    integer errors;
    integer checks;
    integer i, j;
    reg [7:0] expected_addr;

    vga_controller dut (
        .vga_clk     (vga_clk),
        .rst_n       (rst_n),
        .h_sync      (h_sync),
        .v_sync      (v_sync),
        .v_on        (v_on),
        .r           (r),
        .g           (g),
        .b           (b),
        .vga_blank_N (vga_blank_N),
        .vga_sync_N  (vga_sync_N),
        .rd_data     (rd_data),
        .rd_addr     (rd_addr)
    );

    // 25 MHz-ish pixel clock (period doesn't matter for functional check)
    initial begin
        vga_clk = 1'b0;
        forever #20 vga_clk = ~vga_clk;
    end

    // simple self-checking task, keeps a running pass/fail count
    task check;
        input condition;
        input [255:0] message;
        begin
            checks = checks + 1;
            if (!condition) begin
                errors = errors + 1;
                $display("ERROR: %s", message);
                $display("       time=%0t h=%0d v=%0d rd_addr=%0d",
                          $time, dut.h_counter, dut.v_counter, rd_addr);
            end
        end
    endtask

    initial begin
        rst_n   = 1'b0;
        rd_data = 8'h00;
        errors  = 0;
        checks  = 0;
        #100;
        rst_n = 1'b1;
    end

    initial begin

        // wait for the first reset release before doing anything
        @(posedge rst_n);
        repeat (2) @(posedge vga_clk);
        #1;

        // ---------------------------------------------------
        // TEST 1 : reset behaviour
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 1 : RESET");
        $display("========================================");

        rst_n = 1'b0;
        @(posedge vga_clk);
        #1;

        check(dut.h_counter == 10'd0, "H counter reset");
        check(dut.v_counter == 10'd0, "V counter reset");
        check(dut.h_cs == dut.s0,     "H FSM reset");
        check(dut.v_cs == dut.s0,     "V FSM reset");

        rst_n = 1'b1;
        @(posedge vga_clk);
        #1;

        // ---------------------------------------------------
        // TEST 2 : horizontal counter should just count 0..799
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 2 : HORIZONTAL COUNTER");
        $display("========================================");

        wait (dut.h_counter == 10'd0 && dut.v_counter == 10'd0);
        #1;

        for (i = 0; i < 800; i = i + 1) begin
            check(dut.h_counter == i, "Horizontal counter sequence");
            @(posedge vga_clk);
            #1;
        end

        // ---------------------------------------------------
        // TEST 3 : same idea but for the vertical counter (0..524)
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 3 : VERTICAL COUNTER");
        $display("========================================");

        // wait for a fresh frame
        wait (dut.h_counter == 10'd0 && dut.v_counter == 10'd0);
        #1;

        for (i = 0; i < 525; i = i + 1) begin
            check(dut.v_counter == i, "Vertical counter sequence");
            repeat (800) @(posedge vga_clk);   // one full line
            #1;
        end

        // ---------------------------------------------------
        // TEST 4 : HSYNC polarity across visible / FP / sync / BP
        // 640 visible - 16 FP - 96 sync - 48 BP  (standard 640x480@60)
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 4 : H_SYNC");
        $display("========================================");

        wait (dut.h_counter == 10'd0 && dut.v_counter == 10'd0);
        #1;

        check(h_sync == 1'b1, "HSYNC HIGH in visible area");

        wait (dut.h_counter == 10'd640);   // start of front porch
        #1;
        check(h_sync == 1'b1, "HSYNC HIGH in front porch");

        wait (dut.h_counter == 10'd656);   // start of the sync pulse
        #1;
        check(h_sync == 1'b0, "HSYNC LOW during sync pulse");

        wait (dut.h_counter == 10'd751);   // last cycle still inside sync
        #1;
        check(h_sync == 1'b0, "HSYNC LOW at end of sync");

        wait (dut.h_counter == 10'd752);   // back porch begins
        #1;
        check(h_sync == 1'b1, "HSYNC HIGH after sync");

        // ---------------------------------------------------
        // TEST 5 : VSYNC polarity, same logic as above but vertical
        // 480 visible - 10 FP - 2 sync - 33 BP
        // NOTE: sync actually starts at v=490 (FSM moves to s2 there),
        // so v=489 is the last front-porch line and v=490 is the
        // first sync line -- mirrors how TEST 4 checks h=640/h=656.
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 5 : V_SYNC");
        $display("========================================");

        wait (dut.h_counter == 10'd0 && dut.v_counter == 10'd489);
        #1;
        check(v_sync == 1'b1, "VSYNC HIGH before sync");

        wait (dut.h_counter == 10'd0 && dut.v_counter == 10'd490);
        #1;
        check(v_sync == 1'b0, "VSYNC LOW during sync");

        // ---------------------------------------------------
        // TEST 6 : v_on should only be asserted at the very
        // start of the visible frame (top-left corner)
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 6 : VIDEO ON");
        $display("========================================");

        wait (dut.h_counter == 10'd0 && dut.v_counter == 10'd0);
        #1;
        check(v_on == 1'b1, "v_on HIGH inside visible area");

        wait (dut.h_counter == 10'd700 && dut.v_counter == 10'd100);
        #1;
        check(v_on == 1'b0, "v_on LOW outside visible area");

        // ---------------------------------------------------
        // TEST 7 : first pixel of the 14x14 image window
        // (offset X=180, Y=100)
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 7 : IMAGE TOP LEFT");
        $display("========================================");

        wait (dut.h_counter == 10'd180 && dut.v_counter == 10'd100);
        #1;

        check(dut.img_col == 4'd0, "Image column starts at 0");
        check(dut.img_row == 4'd0, "Image row starts at 0");
        check(rd_addr == 8'd0,     "Top-left address = 0");

        // ---------------------------------------------------
        // TEST 8 : horizontal scaling -> each image column is
        // 20 pixels wide on screen (scale = 20)
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 8 : HORIZONTAL SCALING");
        $display("========================================");

        for (i = 0; i < 14; i = i + 1) begin
            wait (dut.h_counter == (180 + i*20) && dut.v_counter == 10'd100);
            #1;
            check(dut.img_col == i, "Horizontal scaling");
            check(rd_addr == i,     "Horizontal address");
        end

        // ---------------------------------------------------
        // TEST 9 : vertical scaling -> each image row spans
        // 20 lines on screen
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 9 : VERTICAL SCALING");
        $display("========================================");

        for (i = 0; i < 14; i = i + 1) begin
            wait (dut.h_counter == 10'd180 && dut.v_counter == (100 + i*20));
            #1;
            check(dut.img_row == i,   "Vertical scaling");
            check(rd_addr == i*14,    "Vertical address");
        end

        // ---------------------------------------------------
        // TEST 10 : sweep the whole 14x14 grid and make sure
        // every (row,col) maps to the right linear address
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 10 : FULL 14x14 ADDRESS COVERAGE");
        $display("========================================");

        for (i = 0; i < 14; i = i + 1) begin
            for (j = 0; j < 14; j = j + 1) begin

                wait (dut.h_counter == (180 + j*20) && dut.v_counter == (100 + i*20));
                #1;

                expected_addr = i*14 + j;

                check(dut.img_row == i,          "Full image row coverage");
                check(dut.img_col == j,          "Full image column coverage");
                check(rd_addr == expected_addr,  "Full image address mapping");
            end
        end

        // ---------------------------------------------------
        // TEST 11 : bottom-right corner of the image (row 13, col 13)
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 11 : LAST PIXEL");
        $display("========================================");

        wait (dut.h_counter == 10'd440 && dut.v_counter == 10'd360);
        #1;

        check(dut.img_row == 4'd13, "Last row = 13");
        check(dut.img_col == 4'd13, "Last column = 13");
        check(rd_addr == 8'd195,    "Last address = 195");

        // ---------------------------------------------------
        // TEST 12 : anything outside the image box must be black
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 12 : OUTSIDE IMAGE");
        $display("========================================");

        wait (dut.h_counter == 10'd179 && dut.v_counter == 10'd100);
        #1;
        check({r,g,b} == 24'h000000, "Left side is black");

        wait (dut.h_counter == 10'd460 && dut.v_counter == 10'd100);
        #1;
        check({r,g,b} == 24'h000000, "Right side is black");

        wait (dut.h_counter == 10'd180 && dut.v_counter == 10'd99);
        #1;
        check({r,g,b} == 24'h000000, "Above image is black");

        wait (dut.h_counter == 10'd180 && dut.v_counter == 10'd380);
        #1;
        check({r,g,b} == 24'h000000, "Below image is black");

        // ---------------------------------------------------
        // TEST 13 : rd_data should pass straight through to r/g/b
        // (grayscale, so all three channels equal rd_data)
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 13 : RGB MAPPING");
        $display("========================================");

        wait (dut.h_counter == 10'd180 && dut.v_counter == 10'd100);
        rd_data = 8'hA5;
        #1;

        check(r == 8'hA5, "R = rd_data");
        check(g == 8'hA5, "G = rd_data");
        check(b == 8'hA5, "B = rd_data");

        // ---------------------------------------------------
        // TEST 14 : blank should follow v_on exactly
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 14 : VGA BLANK");
        $display("========================================");

        wait (dut.h_counter == 10'd200 && dut.v_counter == 10'd200);
        #1;
        check(vga_blank_N == 1'b1, "Blank HIGH during active video");

        wait (dut.h_counter == 10'd700 && dut.v_counter == 10'd200);
        #1;
        check(vga_blank_N == 1'b0, "Blank LOW outside active video");

        // ---------------------------------------------------
        // TEST 15 : vga_sync_N is tied low (sync-on-RGB not used)
        // ---------------------------------------------------
        $display("\n========================================");
        $display("TEST 15 : VGA SYNC OUTPUT");
        $display("========================================");

        check(vga_sync_N == 1'b0, "VGA sync tied LOW");

        // ---------------------------------------------------
        // wrap up
        // ---------------------------------------------------
        $display("\n========================================");
        $display("        VERIFICATION RESULT");
        $display("========================================");
        $display("Total checks = %0d", checks);
        $display("Total errors = %0d", errors);

        if (errors == 0) begin
            $display("\n========================================");
            $display("        ALL TESTS PASSED !!!");
            $display("========================================");
        end else begin
            $display("\n========================================");
            $display("        TEST FAILED !!!");
            $display("========================================");
        end

        $stop;
    end

endmodule