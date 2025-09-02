`timescale 1ns / 1ps
module tb_gates();

    reg a, b;
    wire y0, y1, y2, y3, y4, y5, y6;


    gates dut (
        .a(a),
        .b(b),
        .y0(y0),
        .y1(y1),
        .y2(y2),
        .y3(y3),
        .y4(y4),
        .y5(y5),
        .y6(y6)
    );
    
    initial begin
        #0; a=0;b=0;    // 0ns
        #10; a=1;b=0;   // 10ns
        #10; a=0;b=1;   // 20ns
        #10; a=1;b=1;
        #10;
        $stop;
        $finish;
    end
endmodule