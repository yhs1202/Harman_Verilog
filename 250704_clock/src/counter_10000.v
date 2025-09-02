`timescale 1ns / 1ps


module clock (
    input clk,
    input reset,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire [6:0] w_msec; // rev need (msec, 7bit)
    wire [5:0] w_sec; // rev need (sec, 6bit)
    wire w_10hz;
    wire w_sec_tick;

    Counter_clock U_COUNTER_ms (
        .clk  (w_10hz),
        .reset(reset),
        .count(w_msec),
        .o_tick(w_sec_tick)
    );
    Counter_clock U_COUNTER_sec (
        .clk  (w_sec_tick),
        .reset(reset),
        .count(w_sec),
        .o_tick()
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
    clk_div_tick U_CLK_DIV (
        .clk_in (clk),
        .reset  (reset),
        .clk_out(w_10hz)
    );
endmodule

module Counter_clock #(
    parameter CLOCK_COUNT = 100
)(
    input clk,
    input reset,
    output [$clog2(CLOCK_COUNT)-1:0] count,
    output reg o_tick
);

    reg [$clog2(CLOCK_COUNT)-1:0] r_counter;
    assign count = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            o_tick <= 1'b0;
        end else begin
            if (r_counter == CLOCK_COUNT - 1) begin
                r_counter <= 0;
                o_tick <= 1'b1;
            end
            r_counter <= r_counter + 1;
            o_tick <= 1'b0;
        end
    end
endmodule


module clk_div_tick (
    input clk_in,
    input reset,
    output reg clk_out
);
    parameter DIV = 100_000;
    localparam WIDTH = $clog2(DIV);
    reg [WIDTH-1:0] r_count;

    // always @(posedge clk_in, posedge reset) begin
    //     if (reset) begin
    //         r_count <= 0;
    //         clk_out <= 1'b0
    //     end else begin
    //         if (r_count == DIV - 1) begin
    //             r_count <= 0;
    //             clk_out <= 1'b1;
    //         end else begin
    //             r_count <= r_count + 1;
    //             clk_out <= 1'b0;
    //         end
    //     end
    // end

    always @(posedge clk_in, posedge reset) begin
        if (reset) begin
            r_count <= 0;
            clk_out <= 1'b0;
        end else begin
            if (r_count == DIV - 1) begin
                r_count <= 0;
            end else begin
                r_count <= r_count + 1;
            end

            if (r_count == (DIV / 2) - 1) begin
                clk_out <= 1'b1;
            end else if (r_count == DIV - 1) begin
                clk_out <= 1'b0;
            end
        end
    end

endmodule
