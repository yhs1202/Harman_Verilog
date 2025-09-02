`timescale 1ns / 1ps

module clk_div(
    input       clk,
    input       rst,
    output reg  o_1khz
);

    reg [16:0] r_counter; // upto 99999 
    
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            r_counter <= 17'b0;
            o_1khz <= 1'b0;
        end
        else begin
            if(r_counter == 100_000 - 1) begin
                r_counter <= 17'b0;
                o_1khz <= 1'b1;
            end
            else begin
                r_counter <= r_counter + 1'b1;
                o_1khz <= 1'b0;
            end
        end
    end
    
endmodule
