`timescale 1ns/1ps

module tb_line_buffer_3x3;

    // =========================================================
    // PARAMETERS
    // =========================================================

    parameter DATA_WIDTH   = 8;
    parameter IMAGE_WIDTH  = 16;
    parameter IMAGE_HEIGHT = 16;

    parameter WINDOW_WIDTH  = 3;
    parameter WINDOW_HEIGHT = 3;

    parameter TOTAL_PIXELS =
        IMAGE_WIDTH * IMAGE_HEIGHT;

    parameter TOTAL_WINDOWS =
        (IMAGE_WIDTH  - WINDOW_WIDTH  + 1) *
        (IMAGE_HEIGHT - WINDOW_HEIGHT + 1);


    // =========================================================
    // SIGNALS
    // =========================================================

    reg clk;
    reg rstn;
    reg valid_in;

    reg [DATA_WIDTH-1:0] pixel_in;

    wire valid_window;


    // =========================================================
    // DUT WINDOW
    //
    // 2D ARRAY
    //
    // window[row][column]
    // =========================================================

    wire [DATA_WIDTH-1:0]
        window [0:WINDOW_HEIGHT-1][0:WINDOW_WIDTH-1];


    // =========================================================
    // IMAGE
    //
    // 2D ARRAY
    //
    // image[row][column]
    // =========================================================

    reg [DATA_WIDTH-1:0]
        image [0:IMAGE_HEIGHT-1][0:IMAGE_WIDTH-1];


    // =========================================================
    // EXPECTED WINDOW
    //
    // 2D ARRAY
    // =========================================================

    reg [DATA_WIDTH-1:0]
        expected_window
        [0:WINDOW_HEIGHT-1][0:WINDOW_WIDTH-1];


    // =========================================================
    // KERNEL
    //
    // SIGNED
    //
    // Change these values whenever you want.
    // =========================================================

    integer kernel
        [0:WINDOW_HEIGHT-1][0:WINDOW_WIDTH-1];


    // =========================================================
    // VARIABLES
    // =========================================================

    integer row;
    integer col;

    integer i;
    integer j;

    integer pixel_index;

    integer window_count;
    integer error_count;

    integer current_row;
    integer current_col;

    integer expected_output;
    integer dut_output;

    integer acc;

    integer seed;


    // =========================================================
    // DUT
    // =========================================================

    line_buffer_3x3 #(
        .DATA_WIDTH    (DATA_WIDTH),
        .IMAGE_WIDTH   (IMAGE_WIDTH),
        .IMAGE_HEIGHT  (IMAGE_HEIGHT),
        .WINDOW_WIDTH  (WINDOW_WIDTH),
        .WINDOW_HEIGHT (WINDOW_HEIGHT)
    )
    dut (
        .clk          (clk),
        .rstn         (rstn),
        .valid_in     (valid_in),
        .pixel_in     (pixel_in),
        .valid_window (valid_window),
        .window       (window)
    );


    // =========================================================
    // CLOCK
    // =========================================================

    initial begin

        clk = 0;

        forever #5 clk = ~clk;

    end


    // =========================================================
    // VCD
    // =========================================================

    initial begin

        $dumpfile("line_buffer.vcd");

        $dumpvars(0, tb_line_buffer_3x3);

    end


    // =========================================================
    // GENERATE RANDOM IMAGE
    // =========================================================
    //
    // IMPORTANT:
    //
    // The image is RANDOM.
    //
    // No:
    // 0 1 2 3
    // 4 5 6 7
    //
    // Instead:
    //
    // random values from 0 -> 255
    //
    // Seed is fixed so we can reproduce the same test.
    // =========================================================

    initial begin

        seed = 12345;

        for (
            row = 0;
            row < IMAGE_HEIGHT;
            row = row + 1
        ) begin

            for (
                col = 0;
                col < IMAGE_WIDTH;
                col = col + 1
            ) begin

                image[row][col] =
                    $urandom(seed) % 256;

            end

        end

    end


    // =========================================================
    // KERNEL
    // =========================================================
    //
    // CURRENT KERNEL:
    //
    // [ 1  0 -1 ]
    // [ 1  0 -1 ]
    // [ 1  0 -1 ]
    //
    // You can change it easily.
    // =========================================================

    initial begin

        kernel[0][0] =  1;
        kernel[0][1] =  0;
        kernel[0][2] = -1;

        kernel[1][0] =  1;
        kernel[1][1] =  0;
        kernel[1][2] = -1;

        kernel[2][0] =  1;
        kernel[2][1] =  0;
        kernel[2][2] = -1;

    end


    // =========================================================
    // PRINT RANDOM IMAGE
    // =========================================================

    initial begin

        #1;

        $display("");
        $display("========================================");
        $display("RANDOM IMAGE");
        $display("========================================");

        for (
            row = 0;
            row < IMAGE_HEIGHT;
            row = row + 1
        ) begin

            $write("[ ");

            for (
                col = 0;
                col < IMAGE_WIDTH;
                col = col + 1
            ) begin

                $write(
                    "%3d ",
                    image[row][col]
                );

            end

            $display("]");

        end

    end


    // =========================================================
    // PRINT KERNEL
    // =========================================================

    initial begin

        #2;

        $display("");
        $display("========================================");
        $display("KERNEL");
        $display("========================================");

        for (
            row = 0;
            row < WINDOW_HEIGHT;
            row = row + 1
        ) begin

            $write("[ ");

            for (
                col = 0;
                col < WINDOW_WIDTH;
                col = col + 1
            ) begin

                $write(
                    "%3d ",
                    kernel[row][col]
                );

            end

            $display("]");

        end

    end


    // =========================================================
    // SEND IMAGE TO DUT
    // =========================================================

    initial begin

        rstn     = 0;
        valid_in = 0;
        pixel_in = 0;


        // =====================================================
        // RESET
        // =====================================================

        #20;

        rstn = 1;


        // =====================================================
        // SEND ALL IMAGE PIXELS
        // =====================================================

        for (
            pixel_index = 0;
            pixel_index < TOTAL_PIXELS;
            pixel_index = pixel_index + 1
        ) begin

            @(negedge clk);

            valid_in = 1;

            pixel_in =
                image[
                    pixel_index / IMAGE_WIDTH
                ][
                    pixel_index % IMAGE_WIDTH
                ];

        end


        // =====================================================
        // STOP INPUT
        // =====================================================

        @(negedge clk);

        valid_in = 0;

        pixel_in = 0;

    end


    // =========================================================
    // GOLDEN MODEL + CHECKER
    // =========================================================

    initial begin

        window_count = 0;
        error_count  = 0;


        // Wait for reset
        wait(rstn == 1);


        forever begin

            // =================================================
            // Wait for DUT clock
            // =================================================

            @(posedge clk);


            // =================================================
            // Allow nonblocking assignments to update
            // =================================================

            #1;


            if (valid_window) begin

                // =================================================
                // CURRENT WINDOW POSITION
                //
                // Current pixel is bottom-right.
                // =================================================

                current_row =
                    (WINDOW_HEIGHT - 1) +
                    window_count /
                    (IMAGE_WIDTH - WINDOW_WIDTH + 1);

                current_col =
                    (WINDOW_WIDTH - 1) +
                    window_count %
                    (IMAGE_WIDTH - WINDOW_WIDTH + 1);


                // =================================================
                // BUILD GOLDEN EXPECTED WINDOW
                //
                // expected_window[row][col]
                //
                // comes directly from image[row][col]
                // =================================================

                for (
                    row = 0;
                    row < WINDOW_HEIGHT;
                    row = row + 1
                ) begin

                    for (
                        col = 0;
                        col < WINDOW_WIDTH;
                        col = col + 1
                    ) begin

                        expected_window[row][col] =
                            image[
                                current_row -
                                (WINDOW_HEIGHT - 1) +
                                row
                            ][
                                current_col -
                                (WINDOW_WIDTH - 1) +
                                col
                            ];

                    end

                end


                // =================================================
                // CHECK LINE BUFFER WINDOW
                // =================================================

                for (
                    row = 0;
                    row < WINDOW_HEIGHT;
                    row = row + 1
                ) begin

                    for (
                        col = 0;
                        col < WINDOW_WIDTH;
                        col = col + 1
                    ) begin

                        if (
                            window[row][col]
                            !==
                            expected_window[row][col]
                        ) begin

                            $display(
                                "WINDOW ERROR: Window=%0d Array[%0d][%0d] Expected=%0d Output=%0d",
                                window_count + 1,
                                row,
                                col,
                                expected_window[row][col],
                                window[row][col]
                            );

                            error_count =
                                error_count + 1;

                        end

                    end

                end


                // =================================================
                // GOLDEN MODEL
                //
                // EXPECTED OUTPUT
                //
                // Σ(image × kernel)
                // =================================================

                acc = 0;

                for (
                    row = 0;
                    row < WINDOW_HEIGHT;
                    row = row + 1
                ) begin

                    for (
                        col = 0;
                        col < WINDOW_WIDTH;
                        col = col + 1
                    ) begin

                        acc =
                            acc +
                            expected_window[row][col] *
                            kernel[row][col];

                    end

                end

                expected_output = acc;


                // =================================================
                // DUT CALCULATION
                //
                // Σ(window × kernel)
                // =================================================

                dut_output = 0;

                for (
                    row = 0;
                    row < WINDOW_HEIGHT;
                    row = row + 1
                ) begin

                    for (
                        col = 0;
                        col < WINDOW_WIDTH;
                        col = col + 1
                    ) begin

                        dut_output =
                            dut_output +
                            window[row][col] *
                            kernel[row][col];

                    end

                end


                // =================================================
                // PRINT WINDOW NUMBER
                // =================================================

                $display("");
                $display("========================================");
                $display(
                    "WINDOW #%0d",
                    window_count + 1
                );

                $display(
                    "POSITION = image[%0d][%0d]",
                    current_row,
                    current_col
                );

                $display("========================================");


                // =================================================
                // PRINT EXPECTED ARRAY
                // =================================================

                $display("EXPECTED WINDOW:");

                for (
                    row = 0;
                    row < WINDOW_HEIGHT;
                    row = row + 1
                ) begin

                    $write("[ ");

                    for (
                        col = 0;
                        col < WINDOW_WIDTH;
                        col = col + 1
                    ) begin

                        $write(
                            "%3d ",
                            expected_window[row][col]
                        );

                    end

                    $display("]");

                end


                // =================================================
                // PRINT DUT ARRAY
                // =================================================

                $display("DUT WINDOW:");

                for (
                    row = 0;
                    row < WINDOW_HEIGHT;
                    row = row + 1
                ) begin

                    $write("[ ");

                    for (
                        col = 0;
                        col < WINDOW_WIDTH;
                        col = col + 1
                    ) begin

                        $write(
                            "%3d ",
                            window[row][col]
                        );

                    end

                    $display("]");

                end


                // =================================================
                // PRINT OUTPUTS
                // =================================================

                $display("----------------------------------------");

                $display(
                    "EXPECTED OUTPUT = %0d",
                    expected_output
                );

                $display(
                    "DUT OUTPUT      = %0d",
                    dut_output
                );


                // =================================================
                // RESULT
                // =================================================

                if (
                    expected_output == dut_output
                ) begin

                    $display(
                        "RESULT          = PASS"
                    );

                end

                else begin

                    $display(
                        "RESULT          = FAIL"
                    );

                end


                // =================================================
                // NEXT WINDOW
                // =================================================

                window_count =
                    window_count + 1;


                // =================================================
                // FINISH
                // =================================================

                if (
                    window_count ==
                    TOTAL_WINDOWS
                ) begin

                    $display("");
                    $display("");
                    $display("========================================");
                    $display("FINAL RESULT");
                    $display("========================================");

                    $display(
                        "IMAGE SIZE      = %0d x %0d",
                        IMAGE_WIDTH,
                        IMAGE_HEIGHT
                    );

                    $display(
                        "TOTAL PIXELS    = %0d",
                        TOTAL_PIXELS
                    );

                    $display(
                        "TOTAL WINDOWS   = %0d",
                        TOTAL_WINDOWS
                    );

                    $display(
                        "TOTAL ERRORS    = %0d",
                        error_count
                    );


                    if (
                        error_count == 0
                    ) begin

                        $display("");
                        $display(
                            "******** TEST PASSED ********"
                        );

                        $display(
                            "All windows are correct."
                        );

                        $display(
                            "Expected = DUT Output"
                        );

                        $display("");

                    end

                    else begin

                        $display("");
                        $display(
                            "******** TEST FAILED ********"
                        );

                        $display(
                            "There are %0d errors.",
                            error_count
                        );

                        $display("");

                    end


                    $display(
                        "========================================"
                    );


                    $finish;

                end

            end

        end

    end

endmodule
