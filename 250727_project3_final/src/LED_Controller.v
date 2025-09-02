`timescale 1ns / 1ps

module LED_Controller
(
    input clk, rst,
    input sw_2, sw_3,
    input cmd_L, cmd_m,
    input [3:0] i_led_data, 

    output reg [8:0] o_led_data

);

    always @(posedge clk, posedge rst) 
    begin
        if(rst)  o_led_data <= 9'b0;
        else
        begin
            if((sw_2 == 1'b1 && sw_3 == 1'b1) || (cmd_L == 1'b1 && cmd_m == 1'b1))
            begin
                case(i_led_data)
                    0 :  o_led_data <= 9'b000000000;
                    1 :  o_led_data <= 9'b000000001;
                    2 :  o_led_data <= 9'b000000010;
                    3 :  o_led_data <= 9'b000000100;
                    4 :  o_led_data <= 9'b000001000;
                    5 :  o_led_data <= 9'b000010000;
                    6 :  o_led_data <= 9'b000100000;
                    7 :  o_led_data <= 9'b001000000;
                    8 :  o_led_data <= 9'b010000000;
                    9 :  o_led_data <= 9'b100000000;
                    default : o_led_data <= 9'b000000000;
                endcase
            end
            else o_led_data <= 9'b0;
        end
    end
endmodule
