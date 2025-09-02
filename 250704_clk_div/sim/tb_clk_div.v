`timescale 1ns / 1ps
module tb_clk_div();

    reg clk, reset;
    wire clk_out;

    clk_div #(
        .DIV(16)
    ) dut (
    .clk_in (clk),
    .reset (reset),
    .clk_out (clk_out)
    );

    always #5 clk = ~clk; // 10ns period = 100MHz

    initial begin
        #0; clk = 0; reset = 1;
        #10; reset = 0;
        #1000;
        $stop;

    end
endmodule
