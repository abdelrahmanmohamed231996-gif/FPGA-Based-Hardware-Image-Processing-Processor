module tb ();
parameter [7:0] COEF_WIDTH=8;
reg clk,rst_n;
reg filter0_sel,filter1_sel,filter2_sel;
wire signed   [0:7] k0,k1,k2,k3,k4,k5,k6,k7,k8;

    k_regs #(COEF_WIDTH) dut(clk,rst_n,filter0_sel,filter1_sel,filter2_sel,k0,k1,k2,k3,k4,k5,k6,k7,k8);

initial begin
    clk=0;
    forever #2 clk=~clk;
end
initial begin

@(negedge clk);
    rst_n=0;
    filter0_sel=1;
    filter1_sel=1;
    filter2_sel=1;
    @(negedge clk);


    @(posedge clk);
    if(k0) begin
      $display("error_______k=%h",k0);
      $stop;
    end
    else $display("pass_______k=%h",k0);


    @(negedge clk);
    rst_n=1;
    filter0_sel=1;
    filter1_sel=0;
    filter2_sel=0;
    @(negedge clk);

    @(posedge clk);
    if(k0!=8'hff) begin
      $display("error_______k=%h",k0);
      $stop;
    end
        else $display("pass_______k=%h",k0);
                @(negedge clk);
    rst_n=1;
    filter0_sel=0;
    filter1_sel=1;
    filter2_sel=0;
    @(negedge clk);

    @(posedge clk);
    if(k0!=8'hfe) begin
      $display("error_______k=%h",k0);
      $stop;
    end
        else $display("pass_______k=%h",k0);
          @(negedge clk);

                rst_n=1;
    filter0_sel=0;
    filter1_sel=0;
    filter2_sel=1;
    @(negedge clk);

    @(posedge clk);
    if(k0!=8'hff) begin
      $display("error_______k=%h",k0);
      $stop;
    end
        else $display("pass_______k=%h",k0);
          @(negedge clk);


    rst_n=1;
    filter0_sel=0;
    filter1_sel=0;
    filter2_sel=0;
    @(negedge clk);

    @(posedge clk);
    if(k0!=8'h00) begin
      $display("error_______k=%h",k0);
      $stop;
    end
        else $display("pass_______k=%h",k0);













  $stop;  
end



    








endmodule
