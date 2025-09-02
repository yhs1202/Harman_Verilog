`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/15 13:02:31
// Design Name: 
// Module Name: uart
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


module uart(
    input clk,
    input reset,
    input btn_start,
    output tx // busy -> top dptj skrksmsrj dksla
    );
    
    wire w_b_tick;
    wire w_tx_busy;
    wire w_btn_start;

    btn_debounce U_BTN_DEBOUNCE (
        .clk(clk),
        .reset(reset),
        .btn_in(btn_start),
        .btn_out(w_btn_start)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .start(w_btn_start),
        .b_tick(w_b_tick),
        .tx_data(8'h30),
        .tx_busy(w_tx_busy),
        .tx    (tx)
    );
    baud_tick_gen U_BAUD_TICK (
        .clk(clk),
        .reset(reset),
        .b_tick(w_b_tick)
    );
endmodule
