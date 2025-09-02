`timescale 1ns / 1ps
module tb_fsm();
    reg clk, reset;
    reg [2:0] sw;
    wire [2:0] led;

    fsm dut(
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .led(led)
    );


    always #5 clk <= ~clk;

    initial begin
        // initialize
        #0; clk = 0; reset = 1;

        // idle - st1 - st2 - st3 - st4 - st3
        #100; reset = 0; sw = 3'b000; // idle
        #100; sw = 3'b001; // st1
        #100; sw = 3'b010; // st2
        #100; sw = 3'b100; // st3
        #100; sw = 3'b111; // st4
        #100; sw = 3'b100; // st3

        // idle - st1 - st3 - idle - st2
        #100; sw = 3'b000; // idle
        #100; sw = 3'b001; // st1
        #100; sw = 3'b100; // st3
        #100; sw = 3'b000; // idle
        #100; sw = 3'b010; // st2

        $finish;
    end
endmodule
