`timescale 1ns / 1ps
module tb_stopwatch(
    );

    reg clk;
    reg reset;

    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    stopwatch_top uut (
        .clk(clk),
        .reset(reset),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        # 10
        reset = 0;
    end
endmodule