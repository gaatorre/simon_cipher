`timescale 1ns / 1ps

module keys(
    input clk,
    input res_n,
    input start,
    input [255:0] key,
    output reg done,
    output reg [63:0] key_sched,
    output reg [6:0] rnd,
    output reg wr_en
    );
    
    reg [2:0] state;
    
    reg [63:0] key_tmp [3:0];
    
    parameter idle = 3'b000; 
    parameter strt = 3'b001; 
    parameter gen = 3'b010;
    parameter fin = 3'b100;
    
    parameter z = 64'h3DC94C3A046D678B;
    
    always @(*)
    begin
        if (rnd >= 4) begin
            key_sched = {key_tmp[3][2:0], key_tmp[3][63:3]};
            key_sched = key_sched ^ key_tmp[1];
            key_sched = key_sched ^ {key_sched[0], key_sched[63:1]};
            key_sched = ~key_tmp[0] ^ 64'h3 ^ key_sched ^ z[(rnd - 4) % 62];
            end
        else
            key_sched = key_tmp[rnd[3:0]];
    end
    
    always @(posedge clk)
    begin
        if (!res_n) begin
            done <= 0;
            wr_en <= 0;
            
            key_tmp[0] <= key[63:0];
            key_tmp[1] <= key[127:64];
            key_tmp[2] <= key[191:128];
            key_tmp[3] <= key[255:192];
            
            rnd <= 0;
            state <= idle;
            
        end
        else
            case (state)
                idle: begin
                    done <= 0;
                    
                    if (start) begin
                        wr_en <= 1;
                        state <= strt;
                        end
                    else begin
                        wr_en <= 0;
                        rnd <= 0;
                        end
                        
                    end
                strt: begin
                    if (rnd == 3) begin
                        state <= gen;
                        end
                        
                    done <= 0;
                    rnd <= rnd + 1;
                    end
                gen: begin
                    // Clean up here
                    key_tmp[3] <= key_sched;
                    key_tmp[2] <= key_tmp[3];
                    key_tmp[1] <= key_tmp[2];
                    key_tmp[0] <= key_tmp[1];
                        
                    rnd <= rnd + 1;
                        
                    if (rnd == 71) begin
                        wr_en <= 0;
                        done <= 1;
                        state <= fin;
                        end
                    else
                        done <= 0;
                    end
                fin: begin
                    wr_en <= 0;
                    done <= 1;
                    end
                default:
                    state <= idle;
            endcase 
    end
endmodule
