`timescale 1ns / 1ps
module DHT11_Controller(
    input clk, rst,
    input start_btn,
    input sw,

    // output [7:0] humidity,
    // output [7:0] temperature,
    // output done,
    // output [5:0] led, // state, valid
    output valid,
    output [3:0] state,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    
    inout dht_io

    );

    wire [39:0] w_dht_data;

    wire w_tick, w_start;

    tick_gen U_TICK_GEN_1us (
        .clk_in(clk),
        .rst(rst),
        .tick_1Mhz(w_tick)
    );
    
    DHT11_controller_unit U_DHT11_CU (
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .start(w_start),
        .dht_data_out(w_dht_data),
        .valid(),
        .state(),
        .dht_io(dht_io),
        .state(state)
    );





    fnd_controller U_Fnd_Controller (
        .clk        (clk),
        .rst        (rst),
        .msec       (w_dht_data[31:24]),    // decimal RH data
        .sec        (w_dht_data[39:32]),    // integral RH data
        .min        (w_dht_data[15:8]),     // decimal T data
        .hour       (w_dht_data[23:16]),    // integral T data
        .sw         (sw),
        .fnd_com    (fnd_com),
        .fnd_data   (fnd_data)
    );

    btn_debounce U_Btn_Debounce_R (
        .clk        (clk),
        .rst        (rst),
        .i_btn      (start_btn),
        .o_btn      (w_start)
    );
endmodule
