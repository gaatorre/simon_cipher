`timescale 1ns / 1ps

module simon(
    input clk,
    input res_n,
    input start,
    input ctrl,
    input [255:0] keys,
    input [127:0] in,
    output reg [127:0] out,
    output reg done
    );
    
    reg [63:0] mem[0:71];
    
    reg key_done;
    wire [4:0] fsm_state;
    
    // Starting here!
    simon_fsm f(.clk(clk), .res_n(res_n), .ctrl(ctrl), .start(start), .key_done(key_done), .state(fsm_state));
    
    // Key schedule here
    
    reg [1:0] key_state;
    reg [6:0] key_rnd;
    reg [63:0] key_tmp [3:0];
    reg [63:0] key_scratch;
    
    parameter idle = 2'b00; 
    parameter strt = 2'b01; 
    parameter gen = 2'b10; 
    
    // Constant required for Simon
    parameter z = 64'h3DC94C3A046D678B;
    
    always @(*)
    begin
        if (key_state == gen) begin
            key_scratch = {key_tmp[3][2:0], key_tmp[3][63:3]};
            key_scratch = key_scratch ^ key_tmp[1];
            key_scratch = key_scratch ^ {key_scratch[0], key_scratch[63:1]};
            key_scratch = ~key_tmp[0] ^ 64'h3 ^ key_scratch ^ z[(key_rnd - 4) % 62];
            end
        else
            key_scratch = 0;
    end
    
    always @(posedge clk)
    begin
        if (!res_n) begin
            key_state <= idle;
            key_done <= 0;
        end
        else
            case (key_state)
                idle: begin
                    key_rnd <= 6'h0;
                    key_done <= 0;
                    
                    if (start)
                        key_state <= strt;
                    end
                strt: begin
                    key_rnd <= 0;
                    key_done <= 0;
                    
                    key_tmp[0] <= keys[63:0];
                    key_tmp[1] <= keys[127:64];
                    key_tmp[2] <= keys[191:128];
                    key_tmp[3] <= keys[255:192];
                    
                    mem[0] <= keys[63:0];
                    mem[1] <= keys[127:64];
                    mem[2] <= keys[191:128];
                    mem[3] <= keys[255:192];
                    
                    key_rnd <= 6'h4;
                    
                    key_state <= gen;
                    end
                gen: begin
                    if (key_rnd < 72) begin
                        key_tmp[3] <= key_scratch;
                        key_tmp[2] <= key_tmp[3];
                        key_tmp[1] <= key_tmp[2];
                        key_tmp[0] <= key_tmp[1];
                        
                        mem[key_rnd] <= key_scratch;
                        
                        key_rnd <= key_rnd + 1;
                        key_done <= 0;
                        end
                    else begin
                        key_done <= 1;
                        end
                    end
                default:
                    key_state <= idle;
            endcase 
    end
    
    // Decryption/encryption stuff here!
    reg [63:0] cipher_rnd;
    
    always @(posedge clk) begin
        if (!fsm_state[4]) begin
            cipher_rnd <= ctrl ? 71 : 0;
            done <= 0;
            out <= in;
        end
        else if (fsm_state[4]) begin
            if (cipher_rnd >= 0 && cipher_rnd <= 71) begin
                out <= {out[63:0], mem[cipher_rnd] ^ out[127:64] ^ {out[61:0], out[63:62]} ^ ({out[62:0], out[63]} & {out[55:0], out[63:56]})};
                cipher_rnd <= cipher_rnd - 1;
                done <= 0;
                end
            else begin
                done <= 1;
                end
        end 
    end
    
endmodule
