`timescale 1ns / 1ps

module stopwatch(
    input           clk,
    input           rst,
    input  [1:0]    sw,
    input           btn_L,
    input           btn_R,
    input           btn_U,
    input           btn_D,
    output [6:0]    led,
    output [3:0]    fnd_com,
    output [7:0]    fnd_data
);
    wire [6:0] w_msec, w_sw_msec, w_w_msec;
    wire [5:0] w_sec, w_sw_sec,  w_w_sec;
    wire [5:0] w_min, w_sw_min,  w_w_min;
    wire [4:0] w_hour, w_sw_hour, w_w_hour;
    wire w_btn_L, w_btn_R, w_btn_U, w_btn_D;
    wire w_clear, w_run_stop, w_inc, w_dec;
    wire w_w_clear;

    wire [3:0] w_adjust_digit_sel;
    //wire [1:0] mode;

    /////// indicator //////
    indicator_led U_Indicator_Led (
        .clk        (clk),
        .rst        (rst),
        .sec_hour   (sw[0]),
        .sw_w       (sw[1]),
        .adjust_digit_sel   (w_adjust_digit_sel),
        .led        (led)
    );

    /////// Btn Debouncer ///////
    btn_debounce U_Btn_DB_L (
        .clk        (clk),
        .rst        (rst),
        .i_btn      (btn_L),
        .o_btn      (w_btn_L)
    );

    btn_debounce U_Btn_DB_R (
        .clk        (clk),
        .rst        (rst),
        .i_btn      (btn_R),
        .o_btn      (w_btn_R)
    );

    btn_debounce U_Btn_DB_U (
        .clk        (clk),
        .rst        (rst),
        .i_btn      (btn_U),
        .o_btn      (w_inc)
    );

    btn_debounce U_Btn_DB_D (
        .clk        (clk),
        .rst        (rst),
        .i_btn      (btn_D),
        .o_btn      (w_dec)
    );

    /////// Stopwatch control unit ///////
    control_unit U_SW_CU(
        .clk        (clk),
        .rst        (rst),
        .enable     (!sw[1]),
        .btn_L      (w_btn_L),
        .btn_R      (w_btn_R),
        .run_stop   (w_run_stop),
        .clear      (w_clear)
    );

    /////// Stopwatch ///////
    stopwatch_dp U_SW_DP (
        .clk        (clk ),
        .rst        (rst ),
        .clear      (w_clear),
        .run_stop   (w_run_stop),
        .msec       (w_sw_msec),
        .sec        (w_sw_sec ),
        .min        (w_sw_min),
        .hour       (w_sw_hour)
    );

    /////// Watch control unit //////
    control_unit_watch U_W_CU(
        .clk                (clk),
        .rst                (rst),
        .enable             (sw[1]),
        .btn_L              (w_btn_L),
        .btn_R              (w_btn_R),
        .adjust_digit_sel   (w_adjust_digit_sel),
        .clear              (w_w_clear)
    );

    /////// Watch ///////
    watch_dp U_W_DP (
        .clk                (clk),
        .rst                (rst),
        .clear              (w_w_clear),
        .inc                (w_inc),
        .dec                (w_dec),
        .adjust_digit_sel   (w_adjust_digit_sel),
        .msec               (w_w_msec),
        .sec                (w_w_sec),
        .min                (w_w_min),
        .hour               (w_w_hour)
    );

    /////// mux 2x1 ///////
    mux_2x1 #(
        .WIDTH (24)
    ) U_Mux_sw (
        .sel        (sw[1]),
        .first      ({w_sw_hour, w_sw_min, w_sw_sec, w_sw_msec}),
        .second     ({w_w_hour, w_w_min, w_w_sec, w_w_msec}),
        .o_data     ({w_hour, w_min, w_sec, w_msec})
    );
  
    /////// fnd controller ///////
    fnd_controller U_FND_CTRL (
        .clk        (clk),
        .rst        (rst),
        .msec       (w_msec),
        .sec        (w_sec),
        .min        (w_min),
        .hour       (w_hour),
        .sw         (sw[0]),
        .adjust_digit_sel   (w_adjust_digit_sel),
        .fnd_com    (fnd_com),
        .fnd_data   (fnd_data)
    );

endmodule
