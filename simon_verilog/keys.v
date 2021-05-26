`timescale 1ns / 1ps

module keys(
    input clk,
    input res_n,
    input start,
    input [255:0] key,
    output reg done,
    output reg [63:0] key_sched,
    output reg [6:0] rnd
    );
    
//    reg [6:0] rnd;
    reg [1:0] state;
    
    reg [63:0] key_tmp [3:0];
    reg [63:0] tmp;
    
    parameter idle = 2'b00; 
    parameter strt = 2'b01; 
    parameter gen = 2'b10; 
    
    parameter z = 64'h3DC94C3A046D678B;
    
    always @(*)
    begin
        key_sched = key_tmp[3];
        
        if (state == gen) begin
            tmp = {key_tmp[3][2:0], key_tmp[3][63:3]};
            tmp = tmp ^ key_tmp[1];
            tmp = tmp ^ {tmp[0], tmp[63:1]};
            tmp = ~key_tmp[0] ^ 64'h3 ^ tmp ^ z[(rnd - 4) % 62];
            end
        else
            tmp = 0;
    end
    
    always @(posedge clk)
    begin
        if (!res_n) begin
            state <= idle;
            done <= 0;
            key_tmp[3] <= key[255:192];
        end
        else
            case (state)
                idle: begin
                    rnd <= 6'h0;
                    done <= 0;
                    
                    if (start)
                        state <= strt;
                    end
                strt: begin
                    rnd <= 0;
                    done <= 0;
                    
                    key_tmp[0] <= key[63:0];
                    key_tmp[1] <= key[127:64];
                    key_tmp[2] <= key[191:128];
                    key_tmp[3] <= key[255:192];
                    
                    rnd <= 6'h4;
                    
                    state <= gen;
                    end
                gen: begin
                    if (rnd < 72) begin
                        key_tmp[3] <= tmp;
                        key_tmp[2] <= key_tmp[3];
                        key_tmp[1] <= key_tmp[2];
                        key_tmp[0] <= key_tmp[1];
                        
                        rnd <= rnd + 1;
                        done <= 0;
                        end
                    else begin
                        done <= 1;
                        end
                    end
                default:
                    state <= idle;
            endcase 
        
    end
endmodule
