module fr_buf(wr_clk,write_en,write_addr,write_data,rd_clk,rd_addr,rd_data);

parameter PIXEL_WIDTH=8 , ADDR_WIDTH=8;

///////////////////// SIMPLE DUAL-PORT SYNC RAM ////////////////////////////
	input [(PIXEL_WIDTH-1):0] write_data;
	input [(ADDR_WIDTH-1):0] write_addr, rd_addr;
	input wr_clk, write_en, rd_clk;
	output reg [(PIXEL_WIDTH-1):0] rd_data;


	reg [0:PIXEL_WIDTH-1] ram [0:(2**ADDR_WIDTH)-1];

	always @ (posedge wr_clk)
	begin
		// Port A write
		if (write_en) 
		begin
			ram[write_addr] <= write_data;
	
		end
	end

	always @ (posedge rd_clk)
	begin
		// Port B raed 
		rd_data<= ram[rd_addr];
	
	end

	initial begin
		$readmemh("G:/nti/2d_conv_project/mem/dual_port_ram.mem",ram,0,256);
	end

endmodule
