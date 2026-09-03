module fr_buf_tb;

    parameter PIXEL_WIDTH = 8;
    parameter ADDR_WIDTH  = 8;

    reg wr_clk, rd_clk ,write_en;
    reg [ADDR_WIDTH-1:0] write_addr,rd_addr;
    reg [PIXEL_WIDTH-1:0] write_data;
    wire [PIXEL_WIDTH-1:0] rd_data;

    fr_buf #(.PIXEL_WIDTH(PIXEL_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) dut (
        .wr_clk(wr_clk),.write_en(write_en),.write_addr(write_addr),.write_data(write_data),
            .rd_clk(rd_clk),.rd_addr(rd_addr),.rd_data(rd_data));


    // Write clock = 10 ns
    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk;
    end

    // Read clock = 20 ns
    initial begin
        rd_clk = 0;
        forever #10 rd_clk = ~rd_clk;
    end



    initial begin

        write_en   = 0;
        write_addr = 0;
        write_data = 0;
        rd_addr    = 0;

        // Wait for initialization
        #20;
        // TEST 1 : WRITE


        $display("TEST 1 : WRITE");
        write_en   = 1;
        write_addr = 8'd10;
        write_data = 8'hAA;

        @(posedge wr_clk);

        write_en   = 0;

        write_addr = 8'd20;
        write_data = 8'h55;
        write_en   = 1;

        @(posedge wr_clk);

        write_en = 0;


       
        // TEST 2 : READ ADDRESS 10
       

        
        $display("TEST 2 : READ ADDRESS 10");
       

        rd_addr = 8'd10;

        @(posedge rd_clk);
        #1;

        if (rd_data == 8'hAA)
            $display("PASS : addr=10 data=%h", rd_data);
        else begin
            $display("ERROR : addr=10 expected=AA got=%h", rd_data);
            $stop;
        end


        
        // TEST 3 : READ ADDRESS 20
    

        
        $display("TEST 3 : READ ADDRESS 20");
        

        rd_addr = 8'd20;

        @(posedge rd_clk);
        #1;

        if (rd_data == 8'h55)
            $display("PASS : addr=20 data=%h", rd_data);
        else begin
            $display("ERROR : addr=20 expected=55 got=%h", rd_data);
            $stop;
        end


        
        // TEST 4 : WRITE ENABLE = 0
        // Make sure memory doesn't change
        

       
        $display("TEST 4 : WRITE ENABLE = 0");
        

        // Try to overwrite address 10
        write_en   = 0;
        write_addr = 8'd10;
        write_data = 8'hFF;

        @(posedge wr_clk);

        // Read address 10 again
        rd_addr = 8'd10;

        @(posedge rd_clk);
        #1;

        if (rd_data == 8'hAA)
            $display("PASS : memory unchanged, data=%h", rd_data);
        else begin
            $display("ERROR : memory changed! got=%h", rd_data);
            $stop;
        end


      
        // TEST 5 : DIFFERENT ADDRESSES
      

      
        $display("TEST 5 : MULTIPLE ADDRESSES");
       

        write_en = 1;

        write_addr = 8'd0;
        write_data = 8'h11;
        @(posedge wr_clk);

        write_addr = 8'd50;
        write_data = 8'h22;
        @(posedge wr_clk);

        write_addr = 8'd100;
        write_data = 8'h33;
        @(posedge wr_clk);

        write_en = 0;


        // Read address 0
        rd_addr = 8'd0;
        @(posedge rd_clk);
        #1;

        if (rd_data == 8'h11)
            $display("PASS : addr=0 data=%h", rd_data);
        else begin
            $display("ERROR : addr=0 got=%h", rd_data);
            $stop;
        end


        // Read address 50
        rd_addr = 8'd50;
        @(posedge rd_clk);
        #1;

        if (rd_data == 8'h22)
            $display("PASS : addr=50 data=%h", rd_data);
        else begin
            $display("ERROR : addr=50 got=%h", rd_data);
            $stop;
        end


        // Read address 100
        rd_addr = 8'd100;
        @(posedge rd_clk);
        #1;

        if (rd_data == 8'h33)
            $display("PASS : addr=100 data=%h", rd_data);
        else begin
            $display("ERROR : addr=100 got=%h", rd_data);
            $stop;
        end


       
        // FINISH
      

        $display("====================================");
        $display("ALL TESTS PASSED");
        $display("====================================");

        $stop;

    end

endmodule