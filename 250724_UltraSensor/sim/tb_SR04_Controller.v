`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/24 11:02:57
// Design Name: 
// Module Name: tb_SR04_Controller
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


module tb_SR04_Controller();
    reg clk;
    reg rst;
    reg start_btn;
    reg echo;
    wire trig;
    wire [8:0] distance;

    // Instantiate the SR04_Controller module
    SR04_Controller uut (
        .clk(clk),
        .rst(rst),
        .start_btn(start_btn),
        .echo(echo),
        .trig(trig),
        .distance(distance)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz clock

    // Testbench stimulus
    initial begin
        clk = 0;
        rst = 1; // Assert reset
        start_btn = 0;
        echo = 0;
        
        #10 rst = 0; // Deassert reset
        
        // Start the measurement
        #10 start_btn = 1; 
        #5000 start_btn = 0; 
        
        // Simulate echo signal after some time
        #50000 echo = 1; // Echo high for 50 ticks (500 us)
        #10000 echo = 0; 
        
        // Wait for a while to observe the output
        #20000;

        $finish; // End simulation
    end
endmodule
