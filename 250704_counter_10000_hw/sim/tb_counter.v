`timescale 1ns / 1ps
module tb_counter();

    reg clk, reset;
    reg stop, rev;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;

    counter dut (
        .clk(clk),
        .reset(reset),
        .stop(stop),
        .rev(rev),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; reset = 1; stop = 0; rev = 0;
        #10; reset = 0; rev = 0;   // increase 
        #10000; stop = 1;            // 0->9999 increase
        #1000; stop = 0;
        #90000; rev = 1;
        
        #100; reset = 1;   // rev check
        #100; reset = 0;
        #300;
        // stop = 1;             // rev+stop check
        // #200; reset = 1; stop = 0;
        // #100; reset = 0;
        $stop;


    end
endmodule


