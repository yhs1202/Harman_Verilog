`timescale 1ns / 1ps
module tb_adder();
    /*
    reg a, b, c_in;
    wire sum, c_out;
    full_adder dut (
        .a(a),
        .b(b),
        .c_in (c_in),
        .sum(sum),
        .c_out(c_out)
    );

    initial begin
        #0; a=0; b=0; c_in=0;
        #10; a=1; b=0; c_in=0;
        #10; a=0; b=1; c_in=0;
        #10; a=1; b=1; c_in=0;
        #10; a=0; b=0; c_in=1;
        #10; a=1; b=0; c_in=1;
        #10; a=0; b=1; c_in=1;
        #10; a=1; b=1; c_in=1;
        #10;
        $finish;
    end
    */

    /*
    reg [3:0] a, b;
    reg c_in;
    wire [3:0] sum;
    wire c_out;

    full_adder4 dut(
        .a (a),
        .b (b),
        .c_in (c_in),
        .sum (sum),
        .c_out (c_out)
    );

    integer i=0, j=0; 
    initial begin
        #0; a=0; b=0; c_in=0;
        #10;
        for (i=0; i<16; i=i+1) begin
            for (j=0; j<16; j=j+1) begin
                a = i;
                b = j;
                #10;
            end
        end
        $finish;
    end
    */


    reg [7:0] a, b;
    // reg c_in;
    wire [7:0] sum;
    wire c_out;

    full_adder8 dut(
        .a (a),
        .b (b),
        // .c_in (c_in),
        .sum (sum),
        .c_out (c_out)
    );

    integer i=0, j=0; 
    initial begin
        #0; a=0; b=0;
        //  c_in=0;
        #10;
        for (i=0; i<256; i=i+1) begin
            for (j=0; j<256; j=j+1) begin
                a = i;
                b = j;
                #10;
            end
        end
        $finish;
    end
endmodule