`timescale 1ns / 1ps

module uart_tx_rx (
    input clk,
    rst,
    input rx,

    output       tx,
    output [7:0] rx_fifo_data,
    output       rx_empty,
    output       rx_done
);

    wire [7:0] w_uart_rx_data, w_rx_tx_data, w_tx_uart_data;
    wire w_uart_rx_done;
    wire w_uart_tx_busy;

    wire w_tx_rx_full;
    wire w_tx_uart_empty;

    wire w_rx_tx_empty;

    assign rx_fifo_data = w_rx_tx_data;
    assign rx_empty     = w_rx_tx_empty;
    assign rx_done      = w_uart_rx_done;

    uart U_UART_TX_RX (
        //Input
        .clk(clk),
        .rst(rst),

        .tx_start(~w_tx_uart_empty & ~w_uart_tx_busy),

        // Rx_Input
        .rx(rx),
        .rx_data(w_uart_rx_data),
        // Rx_Output
        .rx_busy(),
        .rx_done(w_uart_rx_done),

        // Tx_Input
        .tx_data(w_tx_uart_data),
        // Tx_Output
        .tx(tx),
        .tx_busy(w_uart_tx_busy)
    );

    always @(posedge clk) begin
        if (w_uart_rx_done) begin
            $display("[%0t] UART RX: %c (0x%0h)", $time, w_uart_rx_data,
                     w_uart_rx_data);
        end
    end

    fifo U_Rx_fifo (
        .clk(clk),
        .rst(rst),
        .w_data(w_uart_rx_data),
        .push(w_uart_rx_done),
        .pop(~w_tx_rx_full),

        .r_data(w_rx_tx_data),  // ?
        .full  (),
        .empty (w_rx_tx_empty)
    );

    fifo U_Tx_fifo (
        .clk(clk),
        .rst(rst),
        .w_data(w_rx_tx_data),  // ?
        .push(~w_rx_tx_empty),
        .pop(~w_uart_tx_busy),

        .r_data(w_tx_uart_data),
        .full  (w_tx_rx_full),
        .empty (w_tx_uart_empty)
    );

endmodule

