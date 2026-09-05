module vga_controller(vga_clk,ref_clk,rst_n,h_sync,v_sync,v_on, r,g,b,vga_blank_N,vga_sync_N,rd_data,rd_addr);
// module vga_controller(vga_clk,rst_n,h_sync,v_sync,v_on, r,g,b,vga_blank_N,vga_sync_N,rd_data,rd_addr);for test

localparam [7:0] X_offset=8'd180,Y_offset=8'd100;
localparam [4:0] scale=5'd20;
localparam [3:0] img_size=4'd14;

parameter [2:0] s0 = 000,
                s1 = 001,
                s2 = 010,
                s3 = 011;

input wire rst_n,ref_clk;
                // input wire rst_n,vga_clk;for test
input  wire [7:0] rd_data;
output reg  [7:0] rd_addr;


output reg h_sync, v_sync, v_on;

output reg [7:0] r, g, b;

output reg vga_blank_N, vga_sync_N;
output wire   vga_clk; //comment at test

reg [2:0] h_ns, h_cs, v_ns, v_cs;

reg [9:0] h_counter, v_counter;
reg [3:0] img_col,img_row;



//  pll ins_pll (
// 		  ref_clk,   //  refclk.clk
// 		  ~rst_n,      //   reset.reset
// 		   vga_clk  // outclk0.clk
// 	);





//====================================================
// Counter
//====================================================

always @(posedge vga_clk or negedge rst_n) begin

    if (~rst_n) begin
        v_counter <= 0;
        h_counter <= 0;
    end

    else if (h_counter == 10'd799) begin

        h_counter <= 0;

        if (v_counter == 10'd524) begin
            v_counter <= 0;
        end

        else begin
            v_counter <= v_counter + 1;
        end

    end

    else begin
        h_counter <= h_counter + 1;
    end

end


//====================================================
// H_FSM
//====================================================

always @(*) begin

    case (h_cs)

        s0: begin
            if (h_counter == 'd639)
                h_ns = s1;
            else
                h_ns = h_cs;
        end

        s1: begin
            if (h_counter == 'd655)
                h_ns = s2;
            else
                h_ns = h_cs;
        end

        s2: begin
            if (h_counter == 'd751)
                h_ns = s3;
            else
                h_ns = h_cs;
        end

        s3: begin
            if (h_counter == 'd799)
                h_ns = s0;
            else
                h_ns = h_cs;
        end

        default:
            h_ns = s0;

    endcase

end


always @(posedge vga_clk or negedge rst_n) begin

    if (~rst_n)
        h_cs <= s0;
    else
        h_cs <= h_ns;

end


//====================================================
// Horizontal Outputs
//====================================================

always @(*) begin

    begin : out_block1

        if (h_cs == s2)
            h_sync = 0;
        else
            h_sync = 1;


    end

end


//====================================================
// V_FSM
//====================================================

always @(*) begin

    case (v_cs)

        s0: begin
            if (v_counter == 'd479)
                v_ns = s1;
            else
                v_ns = v_cs;
        end

        s1: begin
            if (v_counter == 'd489)
                v_ns = s2;
            else
                v_ns = v_cs;
        end

        s2: begin
            if (v_counter == 'd491)
                v_ns = s3;
            else
                v_ns = v_cs;
        end

        s3: begin
            if (v_counter == 'd524)
                v_ns = s0;
            else
                v_ns = v_cs;
        end

        default:
            v_ns = s0;

    endcase

end


always @(posedge vga_clk , negedge rst_n) begin

    if (~rst_n)
        v_cs <= s0;
    else
        v_cs <= v_ns;

end


//====================================================
// Vertical Outputs + RGB
//====================================================

always @(*)

    begin : out_block2

        if (v_cs == s2)
            v_sync = 0;
        else
            v_sync = 1;


        if (h_cs == s0 && v_cs == s0)
            v_on = 1;
        else
            v_on = 0;
            // VGA Blank
    vga_blank_N = v_on;


    // VGA Sync
    vga_sync_N = 1'b0;



        if (v_on) begin

if ((h_counter >= 10'd180) && (h_counter < 10'd460) &&
    (v_counter >= 10'd100) && (v_counter < 10'd380)) begin
        img_col=(h_counter-X_offset)/scale;
        img_row=(v_counter-Y_offset)/scale;

        rd_addr=img_row*img_size+img_col;
        {r,g,b}={rd_data,rd_data,rd_data};


    

end
else begin
    {r,g,b} = 24'h000000;
    rd_addr=0;
end               
            end

               else begin
            {r, g, b} = 24'h000000;
                rd_addr=0;

        end




    end
endmodule