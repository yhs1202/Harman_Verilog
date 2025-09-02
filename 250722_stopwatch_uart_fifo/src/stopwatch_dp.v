`timescale 1ns / 1ps

module stopwatch_dp(
    input           clk,
    input           rst,
    input           clear,
    input           run_stop,
    output [6:0]    msec,
    output [5:0]    sec,
    output [5:0]    min,
    output [4:0]    hour
);
    wire w_tick_100hz, w_tick_msec, w_tick_sec, w_tick_min;

    tick_gen U_TICK_GEN_100hz (
        .clk        (clk            ),
        .rst        (rst            ),
        .run_stop   (run_stop       ),
        .clear      (clear          ),
        .o_tick     (w_tick_100hz   )
    );

    tick_counter #(
        .TICK_COUNT (100),
        .WIDTH      (7  )
    ) U_MSEC (
        .clk        (clk            ),
        .rst        (rst            ),
        .clear      (clear          ),
        .i_tick     (w_tick_100hz   ),
        .o_tick     (w_tick_msec    ),
        .o_time     (msec           )
    );

    tick_counter #(
        .TICK_COUNT (60),
        .WIDTH      (6 )
    ) U_SEC (
        .clk        (clk            ),
        .rst        (rst            ),
        .clear      (clear          ),
        .i_tick     (w_tick_msec    ),
        .o_tick     (w_tick_sec     ),
        .o_time     (sec            )
    );

    tick_counter #(
        .TICK_COUNT (60),
        .WIDTH      (6 )
    ) U_MIN (
        .clk        (clk            ),
        .rst        (rst            ),
        .clear      (clear          ),
        .i_tick     (w_tick_sec     ),
        .o_tick     (w_tick_min     ),
        .o_time     (min            )
    );

    tick_counter #(
        .TICK_COUNT (24),
        .WIDTH      (5 )
    ) U_HOUR (
        .clk        (clk            ),
        .rst        (rst            ),
        .clear      (clear          ),
        .i_tick     (w_tick_min     ),
        .o_tick     (               ),
        .o_time     (hour           )
    );

endmodule
