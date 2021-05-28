`timescale 1ns / 1ps

module simon(
    input clk,
    input res_n,
    input start,
    input ctrl,
    input [255:0] keys,
    input [127:0] in,
    output [127:0] out,
    output done
    );
    
    wire [63:0] key_out;
    wire key_done;
    wire [6:0] key_rnd;
    wire [6:0] rd_adr;
    wire [63:0] data_out;
    wire [4:0] state; 
    wire key_wr_en;
    wire dec_done;
    
    // FSM
    parameter idle = 5'b00001;
    parameter enc_gen = 5'b00010;
    parameter dec_gen = 5'b00100;
    parameter enc = 5'b01000;
    parameter dec = 5'b10000;
    
    dp_mem mem(.clk(clk), .data_in(key_out), .dat_out(data_out), .wr_en(key_wr_en), .wr_adr(key_rnd), .rd_adr(rd_adr));
    
    keys key_schedule(.clk(clk), .res_n(res_n), .key(keys), .rnd(key_rnd), .key_sched(key_out), .done(key_done), .start(state[1] || state[2]), .wr_en(key_wr_en));
    
    simon_fsm f(.clk(clk), .res_n(res_n), .ctrl(ctrl), .start(start), .key_done(key_done), .state(state));
    
    dec d(.clk(clk), .res_n(res_n), .start(state[4] || state[3]), .key(data_out), .cipher(in), .plain(out), .done(dec_done), .key_adr(rd_adr), .ctrl(ctrl));
    
    assign done = dec_done;
    
endmodule

