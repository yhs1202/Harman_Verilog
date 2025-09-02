`timescale 1ns / 1ps
module counter (
    input clk,
    input reset,
    
    input stop,
    input rev,

    input btn_L, btn_R, 
    // input btn_U, btn_D,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire [13:0] w_count;
    wire w_run_stop, w_clear, w_tick_10hz;
    wire o_run_stop, o_clear;

    btn_debounce U_BTN_RUNSTOP_DEBOUNCE (
        .clk(clk),
        .reset(reset),
        .btn_in(btn_R),
        .btn_out(o_run_stop)
    );
    btn_debounce U_CLEAR_DEBOUNCE (
        .clk(clk),
        .reset(reset),
        .btn_in(btn_L),
        .btn_out(o_clear)
    );
    controller U_Controller (
        .clk(clk),
        .rst(reset),
        .btn_L(o_clear),
        .btn_R(o_run_stop),
        // controller output
        // .btn_U(btn_U),
        // .btn_D(btn_D),
        .run_stop(w_run_stop),
        .clear(w_clear)
    );

    counter_10000 U_Counter_10000 (
        .clk  (clk),
        .reset(reset),
        .tick (w_tick_10hz),
        .clear (w_clear),
        .stop(stop),
        .rev(rev),

        .count(w_count)
    );
    fnd_controller U_Fnd_CTRL (
        // .sum({w_carry, w_sum}), // 1+8 bit -> 9bit
        // .digit_sel(btn),
        .count(w_count),
        .clk(clk),
        .reset(reset),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );
    tick_gen_10hz U_TICK_GEN_10HZ (
        .clk_in (clk),
        .reset  (reset),
        .run_stop  (w_run_stop),
        .clear  (w_clear),
        .tick_10hz (w_tick_10hz)
    );
endmodule


module counter_10000 (
    input clk,
    input reset,
    input tick,
    input clear,

    input stop,
    input rev,

    output [13:0] count
);


    reg [$clog2(10000)-1:0] c_counter, n_counter;
    assign count = c_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_counter <= 0;
        end else begin
            c_counter <= n_counter;
        end
    end

    always @(*) begin
        n_counter = c_counter;
        if (tick) begin // 10ns width 100ms period tick
            if (c_counter == (10000-1)) begin
                n_counter = 0;
            end else n_counter = c_counter + 1;
        end
        if (clear) begin
            n_counter = 0;
        end
    end
    
endmodule


// module clk_div_tick (
//     input clk_in,
//     input reset,
//     input run_stop,
//     output reg clk_out
// );
//     parameter DIV = 10;
//     localparam WIDTH = $clog2(DIV);
//     reg [WIDTH-1:0] r_count;

//     always @(posedge clk_in, posedge reset) begin
//         if (reset) begin
//             r_count <= 0;
//             clk_out <= 1'b0;
//         end else if (run_stop) begin
//             if (r_count == DIV - 1) begin
//                 r_count <= 0;
//             end else begin
//                 r_count <= r_count + 1;
//             end

//             if (r_count == (DIV / 2) - 1) begin
//                 clk_out <= 1'b1;
//             end else if (r_count == DIV - 1) begin
//                 clk_out <= 1'b0;
//             end
//         end
//     end

// endmodule

module tick_gen_10hz (
    input clk_in, reset,
    input run_stop, clear,
    output reg tick_10hz
);
    parameter DIV = 10_000_000;
    localparam WIDTH = $clog2(DIV);
    reg [WIDTH-1:0] r_count;

    always @(posedge clk_in, posedge reset) begin
        if (reset) begin
            r_count <= 0;
            tick_10hz <= 1'b0;
        end else if(run_stop) begin
            // tick gen if r_count == 9_999_999
            if (r_count == DIV - 1) begin
                r_count <= 0;
                tick_10hz <= 1'b1;
            end else begin
                r_count <= r_count + 1;
                tick_10hz <= 1'b0;
            end
        end else if (clear) begin
            r_count <= 0;
        end
    end
endmodule