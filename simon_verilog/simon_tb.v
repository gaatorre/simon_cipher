`timescale 1ns / 1ps

module simon_tb(

    );
    
    reg clk;
    reg res_n;
    reg start;
    reg ctrl;
    reg [255:0] keys;
    reg [127:0] in;
    wire [127:0] out;
    wire done;
    
    simon s(.clk(clk), .res_n(res_n), .start(start), .ctrl(ctrl), .keys(keys), .in(in), .out(out), .done(done));
    
    always
        #5 clk = !clk;
        
    initial begin
        keys = 255'h0;
        clk = 0;
        res_n = 0;
        in = 128'h4617626D9D4BBD60A1FE607B736A0C0C;
        ctrl = 1'b1;
        start = 0;
        
        @(posedge clk); @(posedge clk); #1 res_n = 1; start = 1;
        
        @(posedge clk); #1 start = 0;
        
        @(posedge done); $display("%x", out);
        
        @(posedge clk); #1 res_n = 0; ctrl = 1'b0; in = 128'h74206E69206D6F6F6D69732061207369;
        
        @(posedge clk); @(posedge clk); #1 res_n = 1; start = 1;
        
        @(posedge clk); #1 start = 0;
        
        @(posedge done); $display("%x", out);
        
        
    end
endmodule
