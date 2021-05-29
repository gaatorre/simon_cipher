`timescale 1ns / 1ps

module simon_tb(

    );
    
    reg clk;
    reg res_n;
    reg start;
    reg ctrl;
    reg [255:0] keys [0:24];
    reg [127:0] in [0:24];
    reg [127:0] ex_out [0:24];
    wire [127:0] out;
    wire done;
    reg [127:0] data_in;
    reg [255:0] key_in;
    
    integer i;
    integer dec_pass;
    integer enc_pass;
    
    simon s(.clk(clk), .res_n(res_n), .start(start), .ctrl(ctrl), .keys(key_in), .in(data_in), .out(out), .done(done));
    
    always
        #5 clk = !clk;
        
    initial begin
        $readmemh("/home/gabe/classes/cse225-project/simon_verilog/keys.txt", keys);
        $readmemh("/home/gabe/classes/cse225-project/simon_verilog/pt.txt", in);
        $readmemh("/home/gabe/classes/cse225-project/simon_verilog/ct.txt", ex_out);
        
        ctrl = 1'b1;
        clk = 0;
        res_n = 0;
        start = 0;
        dec_pass = 0;
        enc_pass = 0;
        
        $display("Testing decryption");
        // Decryption
        for (i = 0; i < 25; i = i+1) begin
            data_in = ex_out[i];
            key_in = keys[i];
            @(posedge clk); @(posedge clk); #1 res_n = 1; start = 1;
        
            @(posedge clk); #1 start = 0;
            
            @(posedge done);
            
            $display("%d) key: %x", i, keys[i]);
            $display("%d) ciphertext: %x", i, ex_out[i]);
            $display("%d) plaintext: %x", i, out);
            
            if (out == in[i]) begin
                $display("[PASS]");
                dec_pass = dec_pass + 1;
                end
            else
                $display("[FAIL] - expected %x", in[i]);
                
            @(posedge clk); #1 res_n = 0;
        end
        
        $display("Results: %d/25", dec_pass);
        
        @(posedge clk); #1 res_n = 0; ctrl = 1'b0;
        @(posedge clk);
        
        $display("Testing Encryption");
        // Encryption
        for (i = 0; i < 25; i = i+1) begin
            data_in = in[i];
            key_in = keys[i];
            @(posedge clk); @(posedge clk); #1 res_n = 1; start = 1;
        
            @(posedge clk); #1 start = 0;
            
            @(posedge done);
            
            $display("%d) key: %x", i, keys[i]);
            $display("%d) plaintext: %x", i, in[i]);
            $display("%d) ciphertext: %x", i, out);
            
            if (out == ex_out[i]) begin
                $display("[PASS]");
                enc_pass = enc_pass + 1;
                end
            else
                $display("[FAIL] - expected %x", ex_out[i]);
                
            @(posedge clk); #1 res_n = 0;
        end
        $display("Results: %d/25", enc_pass);
        $display();
        
        $display("Total results");
        $display("Encryption: %d/25", enc_pass);
        $display("Decryption: %d/25", dec_pass);
        
        $finish; 
    end
endmodule

//`timescale 1ns / 1ps

//module simon_tb(

//    );
    
//    reg clk;
//    reg res_n;
//    reg start;
//    reg ctrl;
//    reg [255:0] keys;
//    reg [127:0] in;
//    wire [127:0] out;
//    wire done;
    
//    simon s(.clk(clk), .res_n(res_n), .start(start), .ctrl(ctrl), .keys(keys), .in(in), .out(out), .done(done));
    
//    always
//        #5 clk = !clk;
        
//    initial begin
//        keys = 255'h0;
//        clk = 0;
//        res_n = 0;
//        in = 128'h4617626D9D4BBD60A1FE607B736A0C0C;
//        ctrl = 1'b0;
//        start = 0;
        
//        @(posedge clk); @(posedge clk); #1 res_n = 1; start = 1;
        
//        @(posedge clk); #1 start = 0;
        
//        @(posedge done); $display("%x", out);
        
//        @(posedge clk); #1 res_n = 0; ctrl = 1'b0; in = 128'h74206E69206D6F6F6D69732061207369;
        
//        @(posedge clk); @(posedge clk); #1 res_n = 1; start = 1;
        
//        @(posedge clk); #1 start = 0;
        
//        @(posedge done); $display("%x", out);
        
        
//    end
//endmodule
