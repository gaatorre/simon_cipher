`timescale 1ns / 1ps

module simon_tb(

    );
    
    reg clk;
    reg res_n;
    reg start;
    reg ctrl;
    reg [255:0] keys;
    reg [127:0] pt;
    wire [127:0] ct;
    wire done;
    
    simon s(.clk(clk), .res_n(res_n), .start(start), .ctrl(ctrl), .keys(keys), .pt(pt), .ct(ct), .done(done));
    
    always
        #10 clk = !clk;
        
    initial begin
        keys = 255'h0;
        clk = 0;
        res_n = 0;
        pt = 128'h0;
        ctrl = 1'b1;
        start = 0;
        
        @(posedge clk); @(posedge clk); #1 res_n = 1; start = 1;
        
        @(posedge clk); #1 start = 0;
        
        @(posedge done); #1 res_n = 0;
        
        keys = 255'h1;
        
        @(posedge clk); @(posedge clk); #1 res_n = 1; start = 1;
        
        @(posedge clk); #1 start = 0;
        
        @(posedge done); #1 res_n = 0;
    end
endmodule
