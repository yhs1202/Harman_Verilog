`timescale 1ns / 1ps

module btn_debounce(
    input       clk,
    input       rst,
    input       i_btn,
    output      o_btn
);
    // clk divider 1Mhz
    reg [$clog2(100)-1:0] counter;
    reg r_db_clk;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            counter <= 0;
            r_db_clk <= 0;
        end
        else begin
            if(counter == (100 - 1)) begin
                counter <= 1'b0;
                r_db_clk <= 1'b1;
            end
            else begin
                counter <= counter + 1;
                r_db_clk <= 1'b0;
            end
        end
    end

    wire debounce;
    reg [3:0] q_reg, q_next;
    reg edge_reg;

    // shift register
    always @(posedge r_db_clk, posedge rst) begin
        if(rst) begin
            q_reg <= 0;
        end
        else begin
            q_reg <= q_next;
        end
    end

    // shift register
    always @(*) begin
        q_next = {i_btn, q_reg[3:1]};
    end

    // 4input AND logic
    assign debounce = &q_reg;

    // delay 1 clk
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            edge_reg <= 0;
        end
        else begin
            edge_reg <= debounce;
        end
    end

    // generate tick
    assign o_btn = ~edge_reg & debounce;

endmodule
