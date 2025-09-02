`timescale 1ns / 1ps

module btn_debounce (
    input  clk,
    rst,
    i_btn,
    output o_btn,
    hz_1mhz_1us
);

    wire debounce;
    reg [3:0] q_reg, q_next;  // Shift Register

    // Clk divider 1Mhz
    reg [$clog2(100)-1:0] counter;  // 100Mhz -> 1Mhz (/100)
    reg                   r_db_clk;

    assign hz_1mhz_1us = r_db_clk;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter  <= 0;
            r_db_clk <= 0;
        end else begin
            if(counter == (100-1))      // 0~99 (=100-1)
            begin
                counter  <= 0;
                r_db_clk <= 1'b1;
            end else begin
                counter  <= counter + 1;
                r_db_clk <= 1'b0;
            end

        end

    end


    // Shift Register
    always @(posedge r_db_clk, posedge rst) begin
        if (rst) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;
        end
    end

    // Shift Register
    always @(*) begin
        q_next = {i_btn, q_reg[3:1]};
    end

    // debounce = 4bit AND(&)
    assign debounce = &q_reg;

    // Edge Detection

    reg edge_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            edge_reg <= 0;
        end else begin
            edge_reg <= debounce;
        end
    end

    // Invert a 1 tick after debounce signal
    // o_btn = Rising Edged debounce signal
    assign o_btn = ~edge_reg & debounce;


endmodule
