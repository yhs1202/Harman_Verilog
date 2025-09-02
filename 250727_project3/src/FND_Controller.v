`timescale 1ns / 1ps

module FND_Controller (
    input clk,
    input reset,
    input [8:0] counter,

    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_bcd;
    wire [1:0] w_digit_sel;
    wire w_1khz;

    BCD_Decoder U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

    mux_4x1 U_Mux_4x1 (
        .sel(w_digit_sel),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .bcd_data(w_bcd)
    );

    digit_spliter U_DS (
        .i_data(counter),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    clk_div U_CLK_DIV (
        .clk(clk),
        .reset(reset),
        .o_1khz(w_1khz)
    );

    counter_4 U_Counter_4 (
        .clk(w_1khz),
        .reset(reset),
        .digit_sel(w_digit_sel)
    );

    mux_2x4 U_Mux_Fnd_com (
        .sel(w_digit_sel),
        .fnd_com(fnd_com)
    );
endmodule

module digit_spliter (
    input  [8:0] i_data,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1 = i_data % 10;  // Parallel work
    assign digit_10 = i_data / 10 % 10;
    assign digit_100 = i_data / 100 % 10;
    assign digit_1000 = i_data / 1000 % 10;
endmodule


module clk_div (
    input      clk,
    input      reset,
    output reg o_1khz
);
    reg [16:0] r_counter;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            o_1khz <= 1'b0;
        end else begin
            if (r_counter == 100_000 - 1) begin
                r_counter <= 0;
                o_1khz <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;  // Every Clock Plus 1 on Posedge
                o_1khz    <= 1'b0;
            end
        end
    end
endmodule


module counter_4 (
    input  /* wire */       clk,       // No define type -> wire on Verilog
    input                   reset,
    output            [1:0] digit_sel
);

    reg [1:0] r_counter;

    assign digit_sel = r_counter;

    // always's Ouput = reg type always.
    always @(posedge clk, posedge reset)        // Always Watching Condition, Sensitivity list.
    begin
        if (reset) begin
            r_counter <= 0;  // initialization.
        end else begin
            r_counter <= r_counter + 1;  // Operation.
        end
    end

endmodule


module mux_2x4 (
    input      [1:0] sel,
    output reg [3:0] fnd_com
);
    always @(sel) begin
        case (sel)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1110;
        endcase
    end
endmodule

module mux_4x1 (
    input      [1:0] sel,
    input      [3:0] digit_1,
    input      [3:0] digit_10,
    input      [3:0] digit_100,
    input      [3:0] digit_1000,
    output reg [3:0] bcd_data
);

    always @(*)              // * = all input
    begin
        case (sel)
            2'b00:   bcd_data = digit_1;
            2'b01:   bcd_data = digit_10;
            2'b10:   bcd_data = digit_100;
            2'b11:   bcd_data = digit_1000;
            default: bcd_data = digit_1;
        endcase
    end
endmodule

module BCD_Decoder (
    input      [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(bcd) begin
        case (bcd)
            0: fnd_data = 8'hc0;
            1: fnd_data = 8'hf9;
            2: fnd_data = 8'ha4;
            3: fnd_data = 8'hb0;
            4: fnd_data = 8'h99;
            5: fnd_data = 8'h92;
            6: fnd_data = 8'h82;
            7: fnd_data = 8'hf8;
            8: fnd_data = 8'h80;
            9: fnd_data = 8'h90;
            default: fnd_data = 8'hff;
        endcase
    end
endmodule



