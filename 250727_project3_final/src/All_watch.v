`timescale 1ns / 1ps

module All_watch
(
    input [7:0] rx_fifo_data,


    input clk, rst,
    input sw_1, sw_2, sw_3,
    input btn_R, btn_L, btn_U, btn_D,

    input rx_empty,
    input cmd_r, cmd_m, cmd_c, cmd_H, cmd_M, cmd_S, cmd_L, cmd_s,

    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [8:0] led_data
); 
   
    wire [3:0] sw_w_led;
    wire [6:0] sw_w_msec;
    wire [5:0] sw_w_sec;
    wire [5:0] sw_w_min;
    wire [4:0] sw_w_hour;
 
    wire [6:0] w_w_msec;
    wire [5:0] w_w_sec;
    wire [5:0] w_w_min;
    wire [4:0] w_w_hour;


    wire btn_db_R, btn_db_L, btn_db_U, btn_db_D;
    wire sw_w_btn_L, sw_w_btn_R;
    wire w_w_btn_L, w_w_btn_R, w_w_btn_U, w_w_btn_D;


    wire w_sw_2 = sw_2 || cmd_m;
    wire [23:0] w_fnd_data;

    assign w_fnd_data = (w_sw_2 == 1'b0) ? {w_w_hour, w_w_min, w_w_sec, w_w_msec} : {sw_w_hour, sw_w_min, sw_w_sec, sw_w_msec};

    assign w_w_btn_L = (w_sw_2 == 1'b0) ? (btn_db_L || cmd_M) : 1'b0;


    
    assign w_w_btn_R = ((sw_2 || cmd_m) == 1'b0) ? (btn_db_R || cmd_r) : 1'b0;
    
     
    assign w_w_btn_U = (w_sw_2 == 1'b0) ? (btn_db_U || cmd_H) : 1'b0;
    assign w_w_btn_D = (w_sw_2 == 1'b0) ? (btn_db_D || cmd_S) : 1'b0;
    
    assign sw_w_btn_L = (w_sw_2 == 1'b1) ? (btn_db_L || cmd_c) : 1'b0;
    assign sw_w_btn_R = (w_sw_2 == 1'b1) ? (btn_db_R || cmd_r) : 1'b0;


    LED_Controller U_LED_CTRL
    (
        .clk(clk),
        .rst(rst),
        .sw_2(sw_2),
        .sw_3(sw_3),
        .cmd_m(cmd_m),
        .cmd_L(cmd_L),
        .i_led_data(sw_w_led),

        .o_led_data(led_data)
    );


    watch U_WATCH
    (
        .clk(clk),
        .rst(rst),
        .btn_L(w_w_btn_L), 
        .btn_R(w_w_btn_R), 
        .btn_U(w_w_btn_U), 
        .btn_D(w_w_btn_D),

        .w_w_msec(w_w_msec),
        .w_w_sec(w_w_sec), 
        .w_w_min(w_w_min), 
        .w_w_hour(w_w_hour)
    );


    stopwatch U_STOPWATCH
    (
        .clk(clk),
        .rst(rst),
        .btn_R(sw_w_btn_R),
        .btn_L(sw_w_btn_L),

        .sw_w_led(sw_w_led),
        .sw_w_msec(sw_w_msec),
        .sw_w_sec(sw_w_sec),
        .sw_w_min(sw_w_min),
        .sw_w_hour(sw_w_hour)
    );


    FND_Controller U_FND_CTRL
    (
        .clk(clk),
        .reset(rst),
        .sw_1(sw_1),
        .sw_3(sw_3),
        .cmd_s(cmd_s),
        .cmd_L(cmd_L),
        .data(w_fnd_data),

        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );


    btn_debounce U_BTN_DB_L
    (
        .clk(clk), 
        .rst(rst), 
        .i_btn(btn_L),

        .o_btn(btn_db_L)
    );

    btn_debounce U_BTN_DB_R
    (
        .clk(clk), 
        .rst(rst), 
        .i_btn(btn_R),

        .o_btn(btn_db_R)
    );

    btn_debounce U_BTN_DB_U
    (
        .clk(clk), 
        .rst(rst), 
        .i_btn(btn_U),

        .o_btn(btn_db_U)
    );

    btn_debounce U_BTN_DB_D
    (
        .clk(clk), 
        .rst(rst), 
        .i_btn(btn_D),

        .o_btn(btn_db_D)
    );


endmodule

