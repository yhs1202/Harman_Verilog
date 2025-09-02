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

module uart_loopback (
    input       clk,
    input       reset,
    input       rx,
    output      tx
);
    wire w_rx_done;
    wire [7:0] w_rx_data;

    uart U_UART (
        .clk            (clk),
        .reset            (reset),
        .tx_start       (w_rx_done),
        .tx_data        (w_rx_data),
        .rx             (rx),
        .tx             (tx),
        .tx_busy        (),
        .rx_data        (w_rx_data),
        .rx_busy        (),
        .rx_done        (w_rx_done)
    );
endmodule

module uart (
    input clk,
    input reset,
    input tx_start,
    input rx,
    input [7:0] tx_data,
    output tx, // busy -> top dptj skrksmsrj dksla
    output tx_busy,
    output [7:0] rx_data,
    output rx_busy,
    output rx_done
    );
    
    wire w_b_tick;
    wire w_tx_busy;
    wire w_start;

    uart_rx U_UART_RX (
        .clk(clk),
        .reset(reset),
        .b_tick(w_b_tick),
        .rx(rx), //////////// rx is connected to tx of uart_tx
        .rx_data(rx_data),
        .rx_busy(rx_busy),
        .rx_done(rx_done)
    );
    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .start(tx_start),
        .b_tick(w_b_tick),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx    (tx)
    );
    baud_tick_gen U_BAUD_TICK (
        .clk(clk),
        .reset(reset),
        .b_tick(w_b_tick)
    );
endmodule
