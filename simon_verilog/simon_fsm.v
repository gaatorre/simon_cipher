`timescale 1ns / 1ps

module simon_fsm(
    input clk,
    input res_n,
    input ctrl,
    input start,
    input key_done,
    output reg [4:0] state
    );
    
    // FSM
    parameter idle = 5'b00001;
    parameter enc_gen = 5'b00010;
    parameter dec_gen = 5'b00100;
    parameter enc = 5'b01000;
    parameter dec = 5'b10000;
    
    // ctrl
    parameter ctrl_enc = 1'b0;
    parameter ctrl_dec = 1'b1;
    
    always @(posedge clk) begin
        if (!res_n) begin
            if (start && ctrl == ctrl_enc)
                state <= enc_gen;
            else if (start && ctrl == ctrl_dec)
                state <= dec_gen;
            else
                state <= idle;
            end
        else
            case (state)
                idle:
                    if (start && ctrl == ctrl_enc)
                        state <= enc_gen;
                    else if (start && ctrl == ctrl_dec)
                        state <= dec_gen;
                    else
                        state <= idle;
                enc_gen:
                    if (key_done)
                        state <= enc;
                    else
                        state <= enc_gen;
                dec_gen:
                    if (key_done)
                        state <= dec;
                    else
                        state <= dec_gen;
            endcase
    end
endmodule
