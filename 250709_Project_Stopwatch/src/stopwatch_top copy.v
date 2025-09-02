`timescale 1ns / 1ps
module stopwatch_top (
    input clk,
    input reset,
    input sw,   // sec_msec <> hour_min mode
    input btn_L,
    input btn_R,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [6:0] msec;
    wire [5:0] sec;
    wire [5:0] min;
    wire [4:0] hour;


    wire w_run_stop, w_clear; 
    wire w_btn_L, w_btn_R;

    btn_debounce U_BTN_RUNSTOP (
        .clk(clk),
        .reset(reset),
        .btn_in(btn_L),
        .btn_out(w_btn_L)
    );

    btn_debounce U_BTN_CLEAR (
        .clk(clk),
        .reset(reset),
        .btn_in(btn_R),
        .btn_out(w_btn_R)
    );
    controller U_COUNTROLLER (
        .clk(clk),
        .rst(reset),
        .btn_L(w_btn_L),
        .btn_R(w_btn_R),
        // .btn_U(btm_U),
        // .btn_D(btm_D),
        // .btn_M(btm_M),
        .run_stop(w_run_stop),
        .clear(w_clear)
    );

    fnd_controller U_Fnd_CTRL (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .msec(msec),
        .sec   (sec),
        .min(min),
        .hour(hour),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    stopwatch_datapath U_SW_DP (
        .clk  (clk),
        .reset(reset),
        .run_stop(w_run_stop),
        .clear(w_clear),
        .msec (msec),
        .sec  (sec),
        .min  (min),
        .hour (hour)
    );

endmodule

module stopwatch_datapath (
    input clk,
    input reset,
    input run_stop,
    input clear,
    input sec_inc,
    input min_inc,
    input hour_inc,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_tick_100hz; // tick_gen output
    wire w_tick_msec, w_tick_sec, w_tick_min;


    // hour
    tick_counter #(
        .TICK_COUNT(24),
        .WIDTH(5)
    ) U_HOUR (
        .clk(clk),
        .reset(reset),
        .run_stop(run_stop),
        .clear(clear),
        .i_tick(w_tick_min),
        .o_time(hour),  // output
        .o_tick()  // not used
    );

    // min
    tick_counter #(
        .TICK_COUNT(60),
        .WIDTH(6)
    ) U_MIN (
        .clk(clk),
        .reset(reset),
        .run_stop(run_stop),
        .clear(clear),
        .i_tick(w_tick_sec),
        .o_time(min),  // output
        .o_tick(w_tick_min)
    );

    // sec
    tick_counter #(
        .TICK_COUNT(60),
        .WIDTH(6)
    ) U_SEC (
        .clk(clk),
        .reset(reset),
        .run_stop(run_stop),
        .clear(clear),
        .i_tick(w_tick_msec), // msec dml output dl sec dml dlqfurdmfh emfdjrka.
        .o_time(sec),  // output
        .o_tick(w_tick_sec)
    );

    // msec
    tick_counter #(
        .TICK_COUNT(100),
        .WIDTH(7)
    ) U_MSEC (
        .clk(clk),
        .reset(reset),
        .run_stop(run_stop),
        .clear(clear),
        .i_tick(w_tick_100hz),
        .o_time(msec),  // output
        .o_tick(w_tick_msec)
    );

    // tick_gen
    tick_gen_100hz U_TICK_GEN (
        .clk(clk),
        .reset(reset),
        .o_tick(w_tick_100hz)
    );


endmodule

// tick_counter (ms->100, sec, min->60)
module tick_counter #(
    parameter TICK_COUNT = 100,
    WIDTH = 7
) (
    input clk,
    input reset,
    // input run_stop,
    input clear,
    input inc,
    input dec,
    input i_tick,
    output o_tick,
    output [WIDTH-1:0] o_time
);

    reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;  // otick cnffurdmf dnlgks // dOeh feedback vlfdy

    // real output assign
    assign o_time = counter_reg;
    assign o_tick = tick_reg;  // guswo tick

    // feedback structure
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_reg <= 1'b0;
        end else begin
            counter_reg <= counter_next;
            tick_reg <= tick_next;
        end
    end


    // counter implementation
    always @(*) begin
        counter_next = counter_reg;
        tick_next = tick_reg;
        tick_next = 1'b0;  // o_tick 1 dlsehddks count ehlsrj init.  (dlrj djqtdmaus error!)
        
        // 10ns tick emfdjdhfEoaks tlfgod
        // clear -> tick gkrh dusrhks djqtdma!!!!!!!!
        if (i_tick) begin
            // guswo count qhrh vkseks (ms-> 100, sec -> 60)
            if (counter_reg == TICK_COUNT - 1) begin
                counter_next = 0;
                tick_next = 1'b1;  // cnffurdmf dnlgks?
            end else begin
                counter_next = counter_reg + 1;
                tick_next = 1'b0;  // 100 ro counter gkfEoakek tick.
            end
        end
        if (clear) counter_next = 0;
        else if (inc) counter_next = (counter_reg < TICK_COUNT - 1) ? counter_reg + 1 : 0;
        else if (dec) counter_next = (counter_reg > 0) ? counter_reg - 1 : TICK_COUNT - 1;
    end
endmodule

// tick_gen
module tick_gen_100hz (
    input  clk,
    input run_stop,  //clock -> 1fh default value map
    input clear,
    input  reset,
    output o_tick
);
    assign run_stop = 1;
    parameter FCOUNT = 1_000_000;
    reg [$clog2(FCOUNT)-1:0] counter;
    reg r_tick;

    assign o_tick = r_tick;  // real output
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
            r_tick  <= 0;
        end else begin
            if (run_stop) begin
                if (counter == FCOUNT) begin
                    r_tick  <= 1;
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                    r_tick  <= 1'b0;
                end
            end else if(clear) begin
                counter <= 0;
            end
        end
    end
endmodule
