`timescale 1ns / 1ps
module btn_debounce(
    input clk, reset,
    input btn_in,
    output btn_out
    );

    // clk divider 1MHz
    // 100M (currnt)-> divide to 100 
    reg [$clog2(100)-1:0] counter;
    reg r_debounce_clk;
    wire debounce;
    reg [3:0] q_reg, q_next;    // for SR

    // clk divide
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
            r_debounce_clk <= 0;
        end 
        else begin
            if (counter == 100-1) begin
                counter <= 0;
                r_debounce_clk <= 1;
            end else begin
                    counter <= counter + 1;
                    r_debounce_clk <= 1'b0;
                end
        end
    end

    // SR
    always @(posedge r_debounce_clk, posedge reset) begin
       if (reset) begin
        q_reg <= 0;
       end else begin
        q_reg <= q_next;
       end
    end

    // SR
    always @(*) begin
        q_next = {btn_in, q_reg[3:1]};
    end

    // AND4
    assign debounce = &q_reg;

    // debounce -> 1clk delay(FF) (Q5)
    reg edge_reg;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_reg <= 0;
        end else begin
            edge_reg <= debounce;
        end
    end

    // posedge detector
    assign btn_out = ~edge_reg & debounce;
endmodule
