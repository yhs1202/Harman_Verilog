`timescale 1ns / 1ps

module fnd_controller(
    input        clk,
    input        rst,
    input  [6:0] msec,
    input  [5:0] sec,
    input  [5:0] min,
    input  [4:0] hour,
    input        sw,
    input  [3:0] adjust_digit_sel,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    
    wire [2:0] w_digit_sel;
    wire [3:0] w_digit_msec1, w_digit_msec10, w_digit_sec1, w_digit_sec10,
                w_digit_min1, w_digit_min10, w_digit_hour1, w_digit_hour10;
    wire [3:0] w_msec_sec, w_min_hour, w_bcd;
    wire w_1khz;
    wire w_dot_onoff;
    wire [3:0] w_adjust_digit_sel;
    
    clk_div U_Clk_div (
        .clk        (clk       ),
        .rst        (rst       ),
        .o_1khz     (w_1khz    )
    );

    counter #(
        .COUNT   (8)
    ) U_Counter_8(
        .clk    (w_1khz),
        .rst    (rst),
        .sel    (w_digit_sel)
    );

    digit_spliter #(
        .DS_WIDTH (7)
    ) U_DS_MSEC (
        .i_data     (msec           ),
        .adjust_digit_sel   (1'b0),
        .on_off     (1'b1),
        .digit_1    (w_digit_msec1  ),
        .digit_10   (w_digit_msec10 )
    );
    
    digit_spliter #(
        .DS_WIDTH (6)
    ) U_DS_SEC (
        .i_data     (sec           ),
        .adjust_digit_sel   (adjust_digit_sel[3]),
        .on_off     (w_dot_onoff),
        .digit_1    (w_digit_sec1  ),
        .digit_10   (w_digit_sec10 )
    );

    digit_spliter #(
        .DS_WIDTH (6)
    ) U_DS_MIN (
        .i_data     (min           ),
        .adjust_digit_sel   (adjust_digit_sel[2]),
        .on_off     (w_dot_onoff),
        .digit_1    (w_digit_min1  ),
        .digit_10   (w_digit_min10 )
    );

    digit_spliter #(
        .DS_WIDTH (5)
    ) U_DS_HOUR (
        .i_data     (hour          ),
        .adjust_digit_sel   (adjust_digit_sel[1]),
        .on_off     (w_dot_onoff),
        .digit_1    (w_digit_hour1 ),
        .digit_10   (w_digit_hour10)
    );

    dot_point U_DP (
        .msec       (msec),
        .dot_onoff  (w_dot_onoff)
    );

    mux_8x1 U_Mux_MSEC_SEC (
        .sel            (w_digit_sel),
        .digit_1        (w_digit_msec1),
        .digit_10       (w_digit_msec10),
        .digit_100      (w_digit_sec1),
        .digit_1000     (w_digit_sec10),
        .digit_off_1    (4'he),
        .digit_off_10   (4'he),
        .digit_dot      ({3'b111, w_dot_onoff}),
        .digit_off_1000 (4'he),
        .bcd_data       (w_msec_sec)
    );

    mux_8x1 U_Mux_MIN_HOUR (
        .sel            (w_digit_sel),
        .digit_1        (w_digit_min1),
        .digit_10       (w_digit_min10),
        .digit_100      (w_digit_hour1),
        .digit_1000     (w_digit_hour10),
        .digit_off_1    (4'he),
        .digit_off_10   (4'he),
        .digit_dot      ({3'b111, w_dot_onoff}),
        .digit_off_1000 (4'he),
        .bcd_data       (w_min_hour)
    );
    
    mux_2x1 U_Mux_2x1(
        .sel        (sw),
        .first      (w_msec_sec),
        .second     (w_min_hour),
        .o_data     (w_bcd)
    );

    bcd_decoder U_BCD (
        .bcd        (w_bcd      ),
        .fnd_data   (fnd_data   )
    );

    decoder_2x4 U_Decoder_2x4 (
        .sel        (w_digit_sel[1:0]),
        .fnd_com    (fnd_com    )
    );

endmodule
