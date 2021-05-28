`timescale 1ns / 1ps

// Dual port memory
module dp_mem(
    input clk,
    input [63:0] data_in,
    input [6:0] wr_adr,
    input wr_en,
    input [6:0] rd_adr,
    output reg [63:0] dat_out
    );
    
    reg [63:0] mem[0:127];
    
    always @(posedge clk)
        begin
            if (wr_en)
                mem[wr_adr] <= data_in;
          
            dat_out <= mem[rd_adr];
        end
endmodule
