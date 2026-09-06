module output_ass(clk,rst_n,conv_sum,valid_in,row_f,col_f,pixel_out,pixel_out_valid,mem_wr_en,mem_wr_addr);
parameter PIXEL_WIDTH=8,SUM_WIDTH=20;

input  wire clk,rst_n,valid_in;
input  wire signed [SUM_WIDTH-1:0] conv_sum;
input wire [3:0]row_f, col_f;
output reg pixel_out_valid,mem_wr_en;
output reg   [PIXEL_WIDTH-1:0] pixel_out;
output reg [7:0] mem_wr_addr;




always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        pixel_out_valid<=0;
        mem_wr_en<=0;
        pixel_out<=0;
        mem_wr_addr<=0;
    end

        else if (valid_in) begin
            mem_wr_addr <= row_f * 14 + col_f;
            pixel_out_valid<=1;
            mem_wr_en<=1;
            if( conv_sum<0) pixel_out<=0;
            else if (conv_sum<=255) pixel_out<=conv_sum[7:0];
                else pixel_out<=255;

            
        end
        else begin
            pixel_out_valid<=0;
            mem_wr_en<=0;

        end

    
    
end
endmodule