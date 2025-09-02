`timescale 1ns / 1ps

module indicator_led(
    input               clk,
    input               rst,
    input               sec_hour,           // sw[0]
    input               sw_w,               // sw[1]
    input      [3:0]    adjust_digit_sel,   // Btn_R
    output reg [6:0]    led
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            led <= 0;
        end
        else begin
            case (sec_hour)
                1'b0: begin
                    led[0] <= 1'b1;
                    led[1] <= 1'b0;
                end
                1'b1: begin
                    led[0] <= 1'b0;
                    led[1] <= 1'b1;
                end
                default: begin
                    led[0] <= 1'b1;
                    led[1] <= 1'b1;
                end
            endcase

            case (sw_w)
                1'b0: begin
                    led[2] <= 1'b1;
                    led[3] <= 1'b0;
                end
                1'b1: begin
                    led[2] <= 1'b0;
                    led[3] <= 1'b1;
                end
                default: begin
                    led[2] <= 1'b1;
                    led[3] <= 1'b1;
                end
            endcase
            
            case (adjust_digit_sel)
                4'b0010: begin
                    led[4] <= 1'b1;
                    led[5] <= 1'b0;
                    led[6] <= 1'b0;
                end
                4'b0100: begin
                    led[4] <= 1'b0;
                    led[5] <= 1'b1;
                    led[6] <= 1'b0;
                end
                4'b1000: begin
                    led[4] <= 1'b0;
                    led[5] <= 1'b0;
                    led[6] <= 1'b1;
                end
                4'b0001: begin
                    led[4] <= 1'b1;
                    led[5] <= 1'b1;
                    led[6] <= 1'b1;
                end
                default: begin
                    led[4] <= 1'b0;
                    led[5] <= 1'b0;
                    led[6] <= 1'b0;
                end
            endcase
        end
    end
    
endmodule
