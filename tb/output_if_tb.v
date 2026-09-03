module tb_out_if();
reg rst_n,pixel_out_valid,mem_wr_en;
reg  [7:0] pixel_out,mem_wr_addr;
wire write_en;
wire [7:0] write_addr,write_data;


out_if dut(rst_n,pixel_out,pixel_out_valid,mem_wr_en,mem_wr_addr,write_data,
,write_en,write_addr);


initial begin
    rst_n=1;
    pixel_out_valid=0;
    mem_wr_en=0;
    pixel_out=0;
    mem_wr_addr=0;

    #1;
        rst_n=0;
    pixel_out_valid=1;
    mem_wr_en=1;
    pixel_out=1;
    mem_wr_addr=1;
    #1;
       

    if(write_addr||write_data||write_en)begin
      $display("rst_error________");
      $stop;
    end
    else $display("rst_done________");


        #1;
    rst_n=1;
    pixel_out_valid=0;
    mem_wr_en=1;
    pixel_out=8'hff;
    mem_wr_addr=8'hff;
    #1;

        if(write_addr||write_data||write_en)begin
      $display("error________");
      $stop;
    end
    else $display("done________");


    #1;
    rst_n=1;
    pixel_out_valid=1;
    mem_wr_en=0;
    pixel_out=8'hff;
    mem_wr_addr=8'hff;
    #1;

    if(write_addr!=8'hff||write_data!=8'hff||write_en)begin
      $display("error________");
      $stop;
    end
    else $display("done________");


            #1;
    rst_n=1;
    pixel_out_valid=1;
    mem_wr_en=1;
    pixel_out=8'hff;
    mem_wr_addr=8'hff;
    #1;

    if(write_addr!=8'hff||write_data!=8'hff||~write_en)begin
      $display("error________");
      $stop;
    end
    else $display("done________");

            #1;
    rst_n=1;
    pixel_out_valid=0;
    mem_wr_en=0;
    pixel_out=8'hff;
    mem_wr_addr=8'hff;
    #1;

        if(write_addr||write_data||write_en)begin
      $display("error________");
      $stop;
    end
    else $display("done________");











        



$stop;
end
endmodule