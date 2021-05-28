`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2021 03:45:42 PM
// Design Name: 
// Module Name: keys_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module keys_tb(

    );
    
    reg clk;
    reg res_n;
    reg start;
    reg [255:0] key;
    
    wire done;
    wire [63:0] key_sched;
    wire wr_en;
    wire [6:0] rnd;
    
    always
        #10 clk = !clk;
        
    keys k(.clk(clk), .res_n(res_n), .start(start), .key(key), .done(done), .key_sched(key_sched), .wr_en(wr_en), .rnd(rnd));
    
    
    always @(posedge clk) begin
        $display("(%d) - %x", rnd, key_sched);
        end
    
    initial begin
        key = 255'h0;
        clk = 0;
        res_n = 0;
        
        @(posedge clk); @(posedge clk); #1 res_n = 1;
        
        @(posedge clk); #1 start = 1;
        
        @(posedge clk); #1 start = 0;
        
        @(negedge wr_en); #1 res_n = 0;
        
        $display("PASS? [%s]", key_sched == 64'h1A87AFF74EDE4B2A ? "YES" : "NO");
        
        @(posedge clk); @(posedge clk); #1 res_n = 1; start = 1;
        
        @(posedge clk); #1 start = 0;
        
        @(posedge done); #1 res_n = 0;
        
        $display("PASS? [%s]", key_sched == 64'h1A87AFF74EDE4B2A ? "YES" : "NO");
    end
    
endmodule
