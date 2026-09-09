module out_if(rst_n,pixel_out,pixel_out_valid,mem_wr_en,mem_wr_addr,write_data,
write_en,write_addr);
parameter [7:0] PIXEL_WIDTH=8;
input wire rst_n,pixel_out_valid,mem_wr_en;
input  wire [ PIXEL_WIDTH-1:0] pixel_out,mem_wr_addr;
output reg write_en;
output reg [7:0] write_addr,write_data;

always @(*) begin
    if (~rst_n) begin
        write_en=0;
        write_addr=0;
        write_data=0;
        
    end
    else if (pixel_out_valid&&mem_wr_en) begin
        write_en=1;
        write_addr=mem_wr_addr;
        write_data=pixel_out;



        
    end
    else if(pixel_out_valid) begin
              write_en=0;
        write_addr=mem_wr_addr;
        write_data=pixel_out;

    end else  begin
        write_en=0;
        write_addr=0;
        write_data=0;

        
    end
    
end




endmodule
