`timescale 1ns / 1ps
module control_unit_watch(
    input           clk,
    input           rst,
    input           btn_L,
    input           btn_R,
    input           enable,
    output [3:0]    adjust_digit_sel,
    output          clear
);

    parameter   IDLE = 4'b0000,
                CLEAR = 4'b0001,
                SET_HOUR = 4'b0010,
                SET_MIN = 4'b0100,
                SET_SEC = 4'b1000;

    reg [3:0] c_state, n_state;
    reg c_clear, n_clear;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            c_state <= IDLE;
            c_clear <= 1'b0;
        end
        else begin
            c_state <= n_state;
            c_clear <= n_clear;
        end
    end

    always @(*) begin
        n_state = c_state; // prevent latch
        n_clear = c_clear;

        if (enable) begin
            case (c_state)
            IDLE: begin
                n_clear = 1'b0;
                if (btn_R) n_state = SET_HOUR;
                else if (btn_L) n_state = CLEAR;
            end
            
            SET_HOUR: begin
                if (btn_R) n_state = SET_MIN;
                else if (btn_L) begin
                    n_state = CLEAR;
                end
            end

            SET_MIN: begin
                if (btn_R) n_state = SET_SEC;
                else if (btn_L) n_state = CLEAR;
            end

            SET_SEC: begin
                if (btn_R) n_state = IDLE;
                else if (btn_L) n_state = CLEAR;
            end
            CLEAR: begin
                n_state = IDLE;
                n_clear = 1'b1;
            end
            default: n_state = c_state;
        endcase
        end
    end

    assign clear = c_clear;
    assign adjust_digit_sel = c_state;
endmodule
