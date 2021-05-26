`timescale 1ns / 1ps

module simon(
    input clk,
    input res_n,
    input start,
    input ctrl,
    input [255:0] keys,
    input [127:0] pt,
    output [127:0] ct,
    output done
    );
    
    wire [63:0] key_out;
    wire key_done;
    wire key_start;
    wire [6:0] key_rnd;
    wire [6:0] simon_rnd;
    wire [63:0] simon_key;
    
    wire ld_keys;
    
    // FSM
    reg [4:0] state;
    parameter idle = 5'b00001;
    parameter enc_gen = 5'b00010;
    parameter dec_gen = 5'b00100;
    parameter enc = 5'b01000;
    parameter dec = 5'b10000;
    
    // ctrl
    parameter ctrl_enc = 1'b0;
    parameter ctrl_dec = 1'b1;
    
    // wr_addr is -1 because key_rnd is the next round
    dp_mem mem(.clk(clk), .data_in(key_out), .dat_out(simon_key), .wr_en({state[0], state[1] | state[2]}), .wr_adr(key_rnd - 1), .rd_adr(simon_rnd), .keys(keys));
    
    keys key_schedule(.clk(clk), .res_n(res_n), .key(keys), .rnd(key_rnd), .key_sched(key_out), .done(key_done), .start(state[1] | state[2]));
    
    
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
                    state <= enc;
                dec_gen:
                    if (key_done)
                        state <= dec;
                    else
                        state <= dec_gen;
                enc:
                    $display("ENC");
                dec:
                    $display("DEC");
            endcase
    end
    
    assign done = state[3] | state[4];
    
endmodule
