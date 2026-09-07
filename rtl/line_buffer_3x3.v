
module line_buffer_3x3 #(
    parameter DATA_WIDTH    = 8,
    parameter IMAGE_WIDTH   = 16,
    parameter IMAGE_HEIGHT  = 16,
    parameter WINDOW_WIDTH  = 3,
    parameter WINDOW_HEIGHT = 3
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire [DATA_WIDTH-1:0] pixel_in,

    output reg valid_window,

    output reg [DATA_WIDTH-1:0]
        window [0:WINDOW_HEIGHT-1][0:WINDOW_WIDTH-1]
);

    // =========================================================
    // LINE BUFFERS
    //
    // line_buffer[0] = previous row
    // line_buffer[1] = two rows before
    // =========================================================

    reg [DATA_WIDTH-1:0]
        line_buffer [0:1][0:IMAGE_WIDTH-1];


    // =========================================================
    // SHIFT REGISTERS
    //
    // shift_reg[0] = TOP row
    // shift_reg[1] = MIDDLE row
    // shift_reg[2] = CURRENT row
    //
    // [0] = newest pixel
    // [1] = previous pixel
    // =========================================================

    reg [DATA_WIDTH-1:0]
        shift_reg [0:WINDOW_HEIGHT-1][0:WINDOW_WIDTH-1];


    // =========================================================
    // COUNTERS
    // =========================================================

    integer row_count;
    integer col_count;

    integer i;
    integer j;


    // =========================================================
    // MAIN PROCESS
    // =========================================================

    always @(posedge clk) begin

        // =====================================================
        // RESET
        // =====================================================

        if (!rstn) begin

            row_count    <= 0;
            col_count    <= 0;
            valid_window <= 0;

            // Clear line buffers
            for (i = 0; i < 2; i = i + 1) begin

                for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin

                    line_buffer[i][j] <= 0;

                end

            end


            // Clear shift registers
            for (i = 0; i < WINDOW_HEIGHT; i = i + 1) begin

                for (j = 0; j < WINDOW_WIDTH; j = j + 1) begin

                    shift_reg[i][j] <= 0;

                end

            end


            // Clear output window
            for (i = 0; i < WINDOW_HEIGHT; i = i + 1) begin

                for (j = 0; j < WINDOW_WIDTH; j = j + 1) begin

                    window[i][j] <= 0;

                end

            end

        end


        // =====================================================
        // NORMAL OPERATION
        // =====================================================

        else begin

            valid_window <= 0;

            if (valid_in) begin

                // =================================================
                // VALID 3x3 WINDOW
                //
                // Current pixel = bottom-right pixel
                // =================================================

                if ((row_count >= WINDOW_HEIGHT-1) &&
                    (col_count >= WINDOW_WIDTH-1)) begin


                    // ---------------------------------------------
                    // TOP ROW
                    // ---------------------------------------------

                    window[0][0] <= shift_reg[0][1];
                    window[0][1] <= shift_reg[0][0];
                    window[0][2] <= line_buffer[1][col_count];


                    // ---------------------------------------------
                    // MIDDLE ROW
                    // ---------------------------------------------

                    window[1][0] <= shift_reg[1][1];
                    window[1][1] <= shift_reg[1][0];
                    window[1][2] <= line_buffer[0][col_count];


                    // ---------------------------------------------
                    // BOTTOM ROW
                    // ---------------------------------------------

                    window[2][0] <= shift_reg[2][1];
                    window[2][1] <= shift_reg[2][0];
                    window[2][2] <= pixel_in;


                    valid_window <= 1;

                end


                // =================================================
                // SHIFT TOP ROW
                // =================================================

                shift_reg[0][1] <= shift_reg[0][0];

                shift_reg[0][0] <=
                    line_buffer[1][col_count];


                // =================================================
                // SHIFT MIDDLE ROW
                // =================================================

                shift_reg[1][1] <= shift_reg[1][0];

                shift_reg[1][0] <=
                    line_buffer[0][col_count];


                // =================================================
                // SHIFT CURRENT ROW
                // =================================================

                shift_reg[2][1] <= shift_reg[2][0];

                shift_reg[2][0] <= pixel_in;


                // =================================================
                // UPDATE LINE BUFFERS
                // =================================================

                line_buffer[1][col_count] <=
                    line_buffer[0][col_count];

                line_buffer[0][col_count] <=
                    pixel_in;


                // =================================================
                // COLUMN / ROW COUNTERS
                // =================================================

                if (col_count == IMAGE_WIDTH-1) begin

                    col_count <= 0;

                    if (row_count == IMAGE_HEIGHT-1)
                        row_count <= 0;

                    else
                        row_count <= row_count + 1;

                end

                else begin

                    col_count <= col_count + 1;

                end

            end

        end

    end

endmodule