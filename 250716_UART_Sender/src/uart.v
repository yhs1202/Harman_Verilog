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


module uart_sender (
    input clk,
    input reset,
    input btn_start,
    output tx // busy -> top dptj skrksmsrj dksla
    );
    
    wire w_b_tick;
    wire w_tx_busy;
    wire w_btn_start, w_send;
    wire [7:0] w_tx_data;

    ascii_sender U_ASCII_SENDER (
        .clk(clk),
        .reset(reset),
        .start(w_btn_start),    // from BD_Start
        .tx_busy(w_tx_busy),    // from UART_TX
        .sent_start(w_send),  // to UART_TX start
        .ascii_data(w_tx_data) // to UART_TX data 
    );
    btn_debounce U_BTN_DEBOUNCE (
        .clk(clk),
        .reset(reset),
        .btn_in(btn_start),
        .btn_out(w_btn_start)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .start(w_send), //
        .b_tick(w_b_tick),
        .tx_data(w_tx_data),
        .tx_busy(w_tx_busy),
        .tx    (tx)
    );
    baud_tick_gen U_BAUD_TICK (
        .clk(clk),
        .reset(reset),
        .b_tick(w_b_tick)
    );
endmodule
