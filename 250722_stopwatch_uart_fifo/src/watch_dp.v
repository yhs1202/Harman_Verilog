`timescale 1ns / 1ps

module watch_dp(
    input           clk,
    input           rst,
    input  [3:0]    adjust_digit_sel,
    input           clear,
    input           inc,
    input           dec,
    output [6:0]    msec,
    output [5:0]    sec,
    output [5:0]    min,
    output [4:0]    hour
);
    wire w_tick_100hz, w_tick_msec, w_tick_sec, w_tick_min;
    wire [4:0] w_hour;

    assign hour = w_hour;

    tick_gen U_TICK_GEN_100hz (
        .clk        (clk            ),
        .rst        (rst            ),
        .clear      (clear          ),
        .run_stop   (1'b1           ),
        .o_tick     (w_tick_100hz   )
    );

    tick_counter_watch #(
        .TICK_COUNT (100),
        .WIDTH      (7  )
    ) U_MSEC (
        .clk        (clk            ),
        .rst        (rst            ),
        .en         (1'b0           ),
        .clear      (clear          ),
        .inc        (inc            ),
        .dec        (dec            ),
        .i_tick     (w_tick_100hz   ),
        .o_tick     (w_tick_msec    ),
        .o_time     (msec           )
    );

    tick_counter_watch #(
        .TICK_COUNT (60),
        .WIDTH      (6 )
    ) U_SEC (
        .clk        (clk            ),
        .rst        (rst            ),
        .en         (adjust_digit_sel[3]),
        .clear      (clear          ),
        .inc        (inc            ),
        .dec        (dec            ),
        .i_tick     (w_tick_msec    ),
        .o_tick     (w_tick_sec     ),
        .o_time     (sec            )
    );

    tick_counter_watch #(
        .TICK_COUNT (60),
        .WIDTH      (6 )
    ) U_MIN (
        .clk        (clk            ),
        .rst        (rst            ),
        .en         (adjust_digit_sel[2]),
        .clear      (clear          ),
        .inc        (inc            ),
        .dec        (dec            ),
        .i_tick     (w_tick_sec     ),
        .o_tick     (w_tick_min     ),
        .o_time     (min            )
    );

    tick_counter_watch #(
        .TICK_COUNT (24),
        .WIDTH      (5 )
    ) U_HOUR (
        .clk        (clk            ),
        .rst        (rst            ),
        .en         (adjust_digit_sel[1]),
        .clear      (clear          ),
        .inc        (inc            ),
        .dec        (dec            ),
        .i_tick     (w_tick_min     ),
        .o_tick     (               ),
        .o_time     (w_hour         )
    );

endmodule
