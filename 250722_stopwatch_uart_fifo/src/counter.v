`timescale 1ns / 1ps

module counter #(
    parameter COUNT = 4
)(
    input        clk,
    input        rst,
    output      [$clog2(COUNT)-1:0] sel
);
    reg [$clog2(COUNT)-1:0] r_counter;

    assign sel = r_counter;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            r_counter <= 0;
        end
        else begin
            r_counter <= r_counter + 1;
        end
    end

endmodule
