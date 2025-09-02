`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/16 14:12:22
// Design Name: 
// Module Name: tb_uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_uart();
    reg clk, reset, start;
    wire tx;

    uart_sender uut (
    .clk(clk),
    .reset(reset),
    .btn_start(start),
    .tx(tx)
    );

    always #5 clk = ~clk; // 100MHz clock

    initial begin
        #0; clk = 0; reset = 1; start = 0;
        #10; reset = 0; // release reset
        #10; start = 1; // start transmission
        #10; start = 0; // release start
        #(104160*12); // wait for transmission to complete


        #10; start = 0; // start transmission again
        #1000; start = 1;
        #10; start = 0; // start transmission again
        #1000; start = 1;
        #5000; start = 0;
        

        #(104160 * 12 * 6); // wait for all transmissions to complete
        $finish; // end simulation
    end
endmodule
