module k_regs(clk,rst_n,filter0_sel,filter1_sel,filter2_sel,k0,k1,k2,k3,k4,k5,k6,k7,k8);
    parameter [7:0] COEF_WIDTH=8;
input  wire clk,rst_n;
input  wire filter0_sel,filter1_sel,filter2_sel;
    output reg signed [0:COEF_WIDTH-1] k0,k1,k2,k3,k4,k5,k6,k7,k8;
reg signed [0:7]  filter0 [0:8] ;
reg signed [0:7] filter1  [0:8] ;
reg signed [0:7] filter2 [0:8];
reg signed [0:7] filter3 [0:8];
integer i;

always @(posedge clk) begin
    if(~rst_n) begin
            k0<=0;
            k1<=0;
            k2<=0;
            k3<=0;
            k4<=0;
            k5<=0;
            k6<=0;
            k7<=0;
            k8<=0;
            
        end




    else if(filter0_sel) begin
       
            // k0<=filter0[0:7];
            // k1<=filter0[8:15];
            // k2<=filter0[16:23];
            // k3<=filter0[24:31];
            // k4<=filter0[32:39];
            // k5<=filter0[40:47];
            // k6<=filter0[48:55];
            // k7<=filter0[56:63];
            // k8<=filter0[64:71];
            k0<=filter0[0];
            k1<=filter0[1];
            k2<=filter0[2];
            k3<=filter0[3];
            k4<=filter0[4];
            k5<=filter0[5];
            k6<=filter0[6];
            k7<=filter0[7];
            k8<=filter0[8];


            
    
      
    end 
    else if(filter1_sel) begin
         
            // k0<=filter1[0:7];
            // k1<=filter1[8:15];
            // k2<=filter1[16:23];
            // k3<=filter1[24:31];
            // k4<=filter1[32:39];
            // k5<=filter1[40:47];
            // k6<=filter1[48:55];
            // k7<=filter1[56:63];
            // k8<=filter1[64:71];
            k0<=filter1[0];
            k1<=filter1[1];
            k2<=filter1[2];
            k3<=filter1[3];
            k4<=filter1[4];
            k5<=filter1[5];
            k6<=filter1[6];
            k7<=filter1[7];
            k8<=filter1[8];


            
        
      
    end 
        else if(filter2_sel) begin
      
            // k0<=filter2[0:7];
            // k1<=filter2[8:15];
            // k2<=filter2[16:23];
            // k3<=filter2[24:31];
            // k4<=filter2[32:39];
            // k5<=filter2[40:47];
            // k6<=filter2[48:55];
            // k7<=filter2[56:63];
            // k8<=filter2[64:71];
            k0<=filter2[0];
            k1<=filter2[1];
            k2<=filter2[2];
            k3<=filter2[3];
            k4<=filter2[4];
            k5<=filter2[5];
            k6<=filter2[6];
            k7<=filter2[7];
            k8<=filter2[8];



            
        end
      
    
        else  begin
       
            k0<=filter3[0];
            k1<=filter3[1];
            k2<=filter3[2];
            k3<=filter3[3];
            k4<=filter3[4];
            k5<=filter3[5];
            k6<=filter3[6];
            k7<=filter3[7];
            k8<=filter3[8];


            
        
      
    end 
end


        
    


initial begin
    // $readmemh("bottom_sobel.mem",filter0,0,8);
    // $readmemh("emboss.mem",filter1,0,8);
    // $readmemh("outline.mem",filter2,0,8);
    // $readmemh("identify.mem",filter3,0,8);
    $readmemh("G:/nti/2d_conv_project/mem/bottom_sobel.mem", filter0, 0, 8);
$readmemh("G:/nti/2d_conv_project/mem/emboss.mem", filter1, 0, 8);
$readmemh("G:/nti/2d_conv_project/mem/outline.mem", filter2, 0, 8);
$readmemh("G:/nti/2d_conv_project/mem/identify.mem", filter3, 0, 8);


    

end

endmodule
