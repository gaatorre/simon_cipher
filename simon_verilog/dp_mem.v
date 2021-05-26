`timescale 1ns / 1ps

// Dual port memory
module dp_mem(
    input clk,
    input [63:0] data_in,
    input [6:0] wr_adr,
    input [1:0] wr_en,
    input [255:0] keys,
    output reg [63:0] dat_out,
    output [6:0] rd_adr
    );
    
    reg [63:0] mem[0:71];
    
    always @(posedge clk)
        begin
            if (wr_en[0] && ~wr_en[1])
                mem[wr_adr] <= data_in;
            else if (wr_en[1] && ~wr_en[0]) begin
                mem[0] <= keys[63:0];
                mem[1] <= keys[127:64];
                mem[2] <= keys[191:128];
                mem[3] <= keys[255:192];
                end
          
            dat_out <= mem[rd_adr];
        end
endmodule
