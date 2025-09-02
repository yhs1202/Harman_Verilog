`timescale 1ns / 1ps
module DHT11_top(
    input clk, rst,
    input start_btn,
    inout dht_io,

    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [2:0] state,
    output valid
    );

    wire w_start;

    fnd_controller U_FND_CTRL (
        .clk(clk),
        .rst(rst),
        // .count({5'b0, dht_data}), // Assuming dht_data contains the count
        .fnd_com(fnd_com), // Connect to your FND display
        .fnd_data(fnd_data) // Connect to your FND display
    );

    btn_debounce U_BDN (
        .clk(clk),
        .rst(rst),
        .i_btn(start_btn),
        .o_btn(w_start)
    );

    DHT11_Controller U_DHT11_CTRL (
        .clk(clk),
        .rst(rst),
        .start(w_start),
        .dht_io(dht_io),
        // .fnd_com(fnd_com),
        // .fnd_data(fnd_data),
        .humidity(humidity),
        .temperature(temperature),
        .led(led)
    );
endmodule
