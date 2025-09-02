`timescale 1ns / 1ps

module SR04_Controller (
    input clk,
    rst,
    input button,

    input  echo,
    output trig,

    output [3:0] fnd_com,
    output [7:0] fnd_data,

    //input rx,
    output tx
);

    wire db_start, w_tick_1mhz_1us;
    wire [8:0] w_distance;
    wire w_tx_start, w_tx_done;


    uart_sender U_UART_TX (
        .clk  (clk),
        .rst  (rst),
        .start(w_tx_start),

        .distance(w_distance),
        // .tx_done(w_tx_done),
        .tx(tx)
    );

    FND_Controller U_FND_CTRL (
        .clk(clk),
        .reset(rst),
        .counter(w_distance),

        .fnd_com (fnd_com),
        .fnd_data(fnd_data)
    );

    SR04_Control_Unit U_SR04_CU (
        .clk(clk),
        .rst(rst),

        .db_start(db_start),
        .freq_tick_1mhz_1us(w_tick_1mhz_1us),
        .echo(echo),

        .trig(trig),
        .tx_start(w_tx_start),
        .distance(w_distance)
    );

    btn_debounce U_BD (
        .clk(clk),
        .rst(rst),

        .i_btn(button),   // 최소 4us 입력 (FF 4개)
        .o_btn(db_start)
    );

    Freq_generator U_FREQ_GEN (
        .clk(clk),
        .rst(rst),

        .tick_1mhz_1us(w_tick_1mhz_1us)
    );

endmodule
