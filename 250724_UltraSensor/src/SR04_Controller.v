`timescale 1ns / 1ps
module SR04_Controller(
    input clk, rst,
    input start_btn, echo,
    output trig,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [2:0] state
    );

    wire w_tick, w_start;
    wire [8:0] w_distance;

    fnd_controller U_FND_CTRL (
        .clk(clk),
        .rst(rst),
        .count({5'b0, w_distance}),
        .fnd_com(fnd_com), // Connect to your FND display
        .fnd_data(fnd_data) // Connect to your FND display
    );

    SR04_Controller_unit U_SR04_CU (
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .start(w_start),
        .echo(echo),
        .trig(trig),
        .distance(w_distance),
        .state(state)
    );

    tick_gen_1Mhz U_TICK_GEN (
        .clk_in(clk),
        .rst(rst),
        .tick_1Mhz(w_tick)
    );

    btn_debounce U_BDN (
        .clk(clk),
        .rst(rst),
        .i_btn(start_btn),
        .o_btn(w_start)
    );
endmodule
