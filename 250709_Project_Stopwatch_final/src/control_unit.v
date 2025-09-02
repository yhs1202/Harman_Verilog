`timescale 1ns / 1ps

module control_unit(
    input       clk,
    input       rst,
    input       btn_L,
    input       btn_R,
    input       enable,
    output      run_stop,
    output      clear
);
    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;

    reg [2:0] c_state, n_state;
    reg c_clear, n_clear;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            c_state <= STOP;
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
            STOP: begin
                n_clear = 1'b0;
                if(btn_R) begin 
                    n_state = RUN;
                end
                else if(btn_L) begin
                    n_state = CLEAR;
                end
                else begin
                    n_state = c_state;
                end
            end
            RUN: begin
                if(btn_R) begin 
                    n_state = STOP;
                end
                else if(btn_L) begin
                    n_state = CLEAR;
                end
                else begin
                    n_state = c_state;
                end
            end
            CLEAR: begin
                n_state = STOP;
                n_clear = 1'b1;
            end
            default: n_state = c_state;
        endcase
        end
    end

    assign run_stop = (c_state == RUN) ? 1'b1: 0;
    assign clear = c_clear;

endmodule
