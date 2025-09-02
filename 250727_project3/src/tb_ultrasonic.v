`timescale 1ns / 1ps

module tb_ultrasonic ();

    reg clk, rst;
    reg  button;
    reg  echo;

    wire trig;

    SR04_Controller dut (
        .clk(clk),
        .rst(rst),

        .button(button),

        .echo(echo),
        .trig(trig)
    );

    always #5 clk = ~clk;


    initial begin
        #0;
        clk = 0;
        rst = 1;
        button = 0;
        echo = 0;
        #10;
        rst = 0;
        #10;
        button = 1;
        wait(dut.db_start); // 최소 4us 입력 (FF 4개) or Wait until db signal
        button = 0;
        #400000;
        echo = 1;
        #(58000 * 123);
        echo = 0;
        #1000;
    end


endmodule
