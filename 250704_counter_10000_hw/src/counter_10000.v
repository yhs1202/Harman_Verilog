`timescale 1ns / 1ps


module counter (
    input clk,
    input reset,

    input stop,
    input rev,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire [13:0] w_count;
    wire w_10hz;

    counter_10000 U_Counter_10000 (
        .clk  (w_10hz),
        .reset(reset),

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
    clk_div_tick U_CLK_DIV (
        .clk_in (clk),
        .reset  (reset),
        .clk_out(w_10hz)
    );
endmodule


module counter_10000 (
    input clk,
    input reset,

    input stop,
    input rev,

    output [13:0] count
);

    reg [$clog2(10000-1):0] r_counter;
    assign count = r_counter;


    // priority : reset(clear) -> run/stop -> decrease/increase
    always @(posedge clk, posedge reset) begin
        // sw1
        if (reset) begin
            r_counter <= 0;
        end 
        // sw0
        else if (stop) begin
            r_counter <= r_counter;
        end
        // sw2_decrease
        else if (rev) begin
         r_counter <= (r_counter > 0 ? r_counter - 1 : 9999);
        end
        // sw2_increase
        else r_counter <= (r_counter < 9999 ? r_counter + 1 : 0);
    end
endmodule


module clk_div_tick (
    input clk_in,
    input reset,
    output reg clk_out
);
    parameter DIV = 10;
    localparam WIDTH = $clog2(DIV);
    reg [WIDTH-1:0] r_count;

    always @(posedge clk_in, posedge reset) begin
        if (reset) begin
            r_count <= 0;
            clk_out <= 1'b0;
        end else begin
            // rev need
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
