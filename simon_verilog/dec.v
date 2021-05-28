`timescale 1ns / 1ps

module dec(
    input clk,
    input res_n,
    input start,
    input ctrl,
    input [63:0] key,
    input [127:0] cipher,
    output reg [127:0] plain,
    output reg done,
    output reg [6:0] key_adr
    );
    
    reg [3:0] state;
    
    // FSM
    parameter idle = 4'b0001;
    parameter dec = 4'b0010;
    parameter enc = 4'b0100;
    parameter fin = 4'b1000;
    
    // ctrl
    parameter ctrl_enc = 1'b0;
    parameter ctrl_dec = 1'b1;
    
//    always @(*) begin
//        tmp = {plain[63:0], key ^ plain[127:64] ^ {plain[61:0], plain[63:62]} ^ ({plain[62:0], plain[63]} & {plain[55:0], plain[63:56]})};
//    end
    
    always @(posedge clk) begin
        if (!res_n) begin
            plain <= cipher;
            done <= 0;
            key_adr <= ctrl == ctrl_dec ? 71 : 0;
            state <= idle;
        end
        else begin
            case (state)
                idle: begin                  
                    done <= 0;
                    
                    if (start && ctrl == ctrl_dec) begin
                        key_adr <= 70;
                        state <= dec;
                    end
                    else if (start && ctrl == ctrl_enc) begin
                        key_adr <= 1;
                        state <= enc;
                    end
                    else begin
                        plain <= cipher;
                        key_adr <= ctrl == ctrl_dec ? 71 : 0;
                    end
                end
                dec: begin
                    plain <= {plain[63:0], key ^ plain[127:64] ^ {plain[61:0], plain[63:62]} ^ ({plain[62:0], plain[63]} & {plain[55:0], plain[63:56]})};
                    
                    if (key_adr == 127) begin
                        done <= 1;
                        state <= fin;
                    end
                    else
                        key_adr <= key_adr -1;
                end
                enc: begin
                    plain <= {key ^ plain[63:0] ^ {plain[125:64], plain[127:126]} ^ ({plain[126:64], plain[127]} & {plain[119:64], plain[127:120]}), plain[127:64]};
                    
                    if (key_adr == 72) begin
                        done <= 1;
                        state <= fin;
                    end
                    else
                        key_adr <= key_adr + 1;
                end
                fin:
                    done <= 1;
            endcase
        end
    end
    
endmodule