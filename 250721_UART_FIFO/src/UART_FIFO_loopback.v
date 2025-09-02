`timescale 1ns / 1ps
module UART_FIFO_loopback(
    input clk,
    input rst,
    input rx,
    output tx
    );

    wire w_rx_done, w_tx_busy, w_tx_start, w_lp_push, w_lp_pop;
    wire [7:0] w_rx_data, w_tx_data, w_loopback_data;

    uart U_UART (
        .clk            (clk),
        .reset          (rst),
        .rx             (rx),
        .tx             (tx),
        .tx_start       (~w_tx_start),
        .tx_data        (w_tx_data),
        .tx_busy        (w_tx_busy),
        .rx_data        (w_rx_data),
        .rx_busy        (), // rx_busy is not used in this design
        .rx_done        (w_rx_done)
    );


    fifo U_UART_TX_FIFO (
        .clk(clk),
        .rst(rst),
        .w_data(w_loopback_data),
        .push(~w_lp_push),
        .pop(~w_tx_busy),
        .r_data(w_tx_data),
        .full(w_lp_pop),
        .empty(w_tx_start)
    );


    fifo U_UART_RX_FIFO (
        .clk(clk),
        .rst(rst),
        .w_data(w_rx_data),
        .push(w_rx_done),
        .pop(~w_lp_pop),
        .r_data(w_loopback_data),
        .full(),
        .empty(w_lp_push)
    );
endmodule
