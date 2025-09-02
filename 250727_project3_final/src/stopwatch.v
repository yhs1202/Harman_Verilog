`timescale 1ns / 1ps

module stopwatch (
    input clk,
    input rst,
    input btn_L,
    btn_R,

    output [3:0] sw_w_led,
    output [6:0] sw_w_msec,
    output [5:0] sw_w_sec,
    output [5:0] sw_w_min,
    output [4:0] sw_w_hour
);

    wire w_clear, w_run_stop;
    wire w_tick_led;

    stopwatch_dp U_SW_DP (
        .clk    (clk),
        .rst    (rst),
        .runstop(w_run_stop),
        .clear  (w_clear),

        .led (sw_w_led),
        .msec(sw_w_msec),
        .sec (sw_w_sec),
        .min (sw_w_min),
        .hour(sw_w_hour)
    );

    stopwatch_cu U_STOPWATCH_CU (
        .clk    (clk),
        .rst    (rst),
        .runstop(btn_R),
        .clear  (btn_L),

        .o_run_stop(w_run_stop),
        .o_clear   (w_clear)
    );

endmodule


module stopwatch_cu (
    input clk,
    rst,
    input clear,
    runstop,

    output o_run_stop,
    o_clear
);


    // FSM

    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;

    reg [2:0] current_state, next_state;
    reg c_clear, n_clear;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state <= STOP;
            c_clear       <= 1'b0;
        end else begin
            current_state <= next_state;
            c_clear       <= n_clear;
        end
    end

    always @(*) begin

        next_state = current_state;
        n_clear    = c_clear;

        case (current_state)
            STOP: begin

                n_clear = 1'b0;  // Clear 찍먹

                if (runstop == 1'b1) begin
                    next_state = RUN;
                end else if (clear == 1'b1) begin
                    next_state = CLEAR;
                end
            end

            RUN: begin
                if (runstop == 1'b1) begin
                    next_state = STOP;
                end
            end

            CLEAR: begin
                next_state = STOP;
                n_clear    = 1'b1;
            end

            default: next_state = current_state;
        endcase
    end

    assign o_run_stop = (current_state == RUN) ? 1'b1 : 0;
    assign o_clear    = c_clear;

endmodule


module stopwatch_dp (
    input clk,
    input rst,
    input runstop,
    clear,

    output [3:0] led,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire w_tick_100hz, w_tick_msec, w_tick_sec, w_tick_min, w_tick_led;
    wire w_runstop_tick, w_clear_tick;


    // hour tick counter
    tick_counter #(
        .TICK_COUNT(24),
        .WIDTH(5)
    ) U_HOUR (
        .clk   (clk),
        .rst   (rst),
        .i_tick(w_tick_min),
        .clear (clear),

        .o_time(hour),
        .o_tick()
    );

    // min tick counter
    tick_counter #(
        .TICK_COUNT(60),
        .WIDTH(6)
    ) U_MIN (
        .clk   (clk),
        .rst   (rst),
        .i_tick(w_tick_sec),
        .clear (clear),

        .o_time(min),
        .o_tick(w_tick_min)
    );

    // sec tick counter
    tick_counter #(
        .TICK_COUNT(60),
        .WIDTH(6)
    ) U_SEC (
        .clk   (clk),
        .rst   (rst),
        .i_tick(w_tick_msec),
        .clear (clear),

        .o_time(sec),
        .o_tick(w_tick_sec)
    );

    // msec tick counter
    tick_counter #(
        .TICK_COUNT(100),
        .WIDTH(7)
    ) U_MSEC (
        .clk   (clk),
        .rst   (rst),
        .i_tick(w_tick_100hz),
        .clear (clear),

        .o_time(msec),
        .o_tick(w_tick_msec)
    );

    // LED counter
    tick_counter #(
        .TICK_COUNT(10),
        .WIDTH(4)
    ) U_LED_DATA (
        .clk   (clk),
        .rst   (rst),
        .i_tick(w_tick_led),
        .clear (clear),

        .o_time(led),
        .o_tick()

    );
    // LED tick counter
    tick_counter #(
        .TICK_COUNT(10),
        .WIDTH(4)
    ) U_LED (
        .clk   (clk),
        .rst   (rst),
        .i_tick(w_tick_100hz),
        .clear (clear),

        .o_time(),
        .o_tick(w_tick_led)
    );

    // generate 100hz tick
    tick_gen_100hz U_TICK_GEN (
        .clk   (clk),
        .rst   (rst),
        .run   (runstop),
        .clear (clear),
        .o_tick(w_tick_100hz)
    );

endmodule


module tick_counter #(
    parameter TICK_COUNT = 100,
              WIDTH      = 7     // msec (0~99) = Need 7bit
) (
    input clk,
    input rst,
    input i_tick,
    input clear,

    output [WIDTH-1:0] o_time,
    output             o_tick

);

    reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    assign o_time = counter_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_reg    <= 1'b0;
        end else begin
            counter_reg <= counter_next;
            tick_reg    <= tick_next;
        end
    end


    always @(*) begin

        counter_next = counter_reg;
        // tick_next    = tick_reg;    
        tick_next    = 1'b0;

        if(i_tick)                                  // if i_tick = 1 then counter inc
            begin
            if (counter_reg == TICK_COUNT - 1) begin
                counter_next = 0;
                tick_next    = 1'b1;
            end else begin
                counter_next = counter_reg + 1;
                tick_next    = 1'b0;
            end
        end

        if (clear) counter_next = 0;

    end
endmodule


module tick_gen_100hz #(
    parameter FCOUNT = 1_000_000 - 1
) (
    input clk,
    input rst,
    input run,
    input clear,            // 만약 안쓰는 경우가 있다면 초기값 넣어놔야 한다.

    output o_tick
);

    reg [$clog2(FCOUNT):0] counter;
    reg                    r_tick;

    assign o_tick = r_tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 0;
            r_tick  <= 0;
        end else begin

            r_tick <= 1'b0;

            if (run) begin
                if (counter == FCOUNT) begin
                    counter <= 0;
                    r_tick  <= 1'b1;
                end else begin
                    counter <= counter + 1;
                end
            end else if (clear) begin
                counter <= 0;
            end

        end
    end

endmodule
