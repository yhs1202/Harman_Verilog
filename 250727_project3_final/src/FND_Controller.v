`timescale 1ns / 1ps

module FND_Controller (
    input        clk,
    input        reset,
    input        sw_1,
    sw_3,
    input        cmd_s,
    cmd_L,
    input [23:0] data,

    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [3:0] w_digit_msec_1, w_digit_msec_10, w_digit_sec_1, w_digit_sec_10;
    wire [3:0] w_digit_min_1, w_digit_min_10, w_digit_hour_1, w_digit_hour_10;

    wire [3:0] w_bcd, w_bcd_msec_sec, w_bcd_min_hour, w_bcd_sec_min;
    wire [2:0] w_digit_sel;
    wire w_dot_onoff;
    wire o_1khz;

    wire [6:0] msec = data[6:0];
    wire [5:0] sec = data[12:7];
    wire [5:0] min = data[18:13];
    wire [4:0] hour = data[23:19];

    BCD_Decoder U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

    dot_comp U_DOT_COMP1 (
        .msec(msec),
        .dot_onoff(w_dot_onoff)
    );

    mux_8x1 U_Mux_8x1_msec_sec (
        .sel(w_digit_sel),
        .digit_1(w_digit_msec_1),
        .digit_10(w_digit_msec_10),
        .digit_100(w_digit_sec_1),
        .digit_1000(w_digit_sec_10),

        .digit_off_1(4'he),
        .digit_off_10(4'he),
        .digit_off_100({3'b111, w_dot_onoff}),
        .digit_off_1000(4'he),

        .bcd_data(w_bcd_msec_sec)
    );

    mux_8x1 U_Mux_8x1_min_hour (
        .sel(w_digit_sel),
        .digit_1(w_digit_min_1),
        .digit_10(w_digit_min_10),
        .digit_100(w_digit_hour_1),
        .digit_1000(w_digit_hour_10),

        .digit_off_1(4'he),
        .digit_off_10(4'he),
        .digit_off_100({3'b111, w_dot_onoff}),
        .digit_off_1000(4'he),

        .bcd_data(w_bcd_min_hour)
    );

    mux_8x1 U_Mux_8x1_min_sec (
        .sel(w_digit_sel),
        .digit_1(w_digit_sec_1),
        .digit_10(w_digit_sec_10),
        .digit_100(w_digit_min_1),
        .digit_1000(w_digit_min_10),

        .digit_off_1({3'b111, w_dot_onoff}),
        .digit_off_10(4'he),
        .digit_off_100({3'b111, w_dot_onoff}),
        .digit_off_1000(4'he),

        .bcd_data(w_bcd_sec_min)
    );

    mux_2x1 U_Mux_2x1 (
        .i_sw_1(sw_1),
        .i_sw_3(sw_3),
        .cmd_s(cmd_s),
        .cmd_L(cmd_L),
        .i_bcd_msec_sec(w_bcd_msec_sec),
        .i_bcd_min_hour(w_bcd_min_hour),
        .i_bcd_sec_min(w_bcd_sec_min),

        .bcd_data_second_mux(w_bcd)
    );



    digit_spliter #(
        .DS_WIDTH(7)
    ) U_DS_msec (
        .i_data  (msec),            // DS_msec
        .digit_1 (w_digit_msec_1),
        .digit_10(w_digit_msec_10)
    );

    digit_spliter #(
        .DS_WIDTH(6)
    ) U_DS_sec (
        .i_data  (sec),            // DS_sec
        .digit_1 (w_digit_sec_1),
        .digit_10(w_digit_sec_10)
    );

    digit_spliter #(
        .DS_WIDTH(6)
    ) U_DS_min (
        .i_data  (min),            // DS_min
        .digit_1 (w_digit_min_1),
        .digit_10(w_digit_min_10)
    );

    digit_spliter #(
        .DS_WIDTH(5)
    ) U_DS_hour (
        .i_data  (hour),            // DS_hour
        .digit_1 (w_digit_hour_1),
        .digit_10(w_digit_hour_10)
    );

    clk_div U_CLK_DIV (
        .clk(clk),
        .reset(reset),
        .o_1khz(w_1khz)
    );

    counter_8 U_Counter_8 (
        .clk(w_1khz),
        .reset(reset),
        .digit_sel(w_digit_sel)
    );

    Decoder_2x4 U_DECODER_Fnd_com (
        .sel    (w_digit_sel[1:0]),  // 하위 2비트를 고정해줘야 함
        .fnd_com(fnd_com)
    );
endmodule



module dot_comp (
    input [6:0] msec,

    output dot_onoff
);

    assign dot_onoff = (msec >= 50) ? 1'b1 : 1'b0;

endmodule


module digit_spliter #(
    parameter DS_WIDTH = 7
) (
    input [DS_WIDTH-1:0] i_data,
    output [3:0] digit_1,
    output [3:0] digit_10
);

    assign digit_1  = i_data % 10;
    assign digit_10 = i_data / 10 % 10;

endmodule


module clk_div (
    input      clk,
    input      reset,
    output reg o_1khz
);
    reg [16:0] r_counter;  // FF 17개 사용


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


module counter_8 (
    input  /* wire */       clk,       // No define type -> wire on Verilog
    input                   reset,
    output            [2:0] digit_sel
);

    reg [2:0] r_counter;

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


module Decoder_2x4 (
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


module mux_8x1 (
    input [2:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    input [3:0] digit_off_1,
    input [3:0] digit_off_10,
    input [3:0] digit_off_100,
    input [3:0] digit_off_1000,

    output reg [3:0] bcd_data
);
    always @(*)              // * = all input
    begin
        case (sel)
            3'b000: bcd_data = digit_1;
            3'b001: bcd_data = digit_10;
            3'b010: bcd_data = digit_100;
            3'b011: bcd_data = digit_1000;

            3'b100:  bcd_data = digit_off_1;
            3'b101:  bcd_data = digit_off_10;
            3'b110:  bcd_data = digit_off_100;
            3'b111:  bcd_data = digit_off_1000;
            default: bcd_data = digit_1;
        endcase
    end

endmodule

module mux_2x1 (
    input       i_sw_1,
    i_sw_3,
    input       cmd_s,
    cmd_L,
    input [3:0] i_bcd_msec_sec,
    input [3:0] i_bcd_min_hour,
    input [3:0] i_bcd_sec_min,

    output reg [3:0] bcd_data_second_mux
);

    always @(*)              // * = all input
    begin
        if (i_sw_3 || cmd_L) begin
            bcd_data_second_mux = i_bcd_sec_min;
        end else begin
            case (i_sw_1 || cmd_s)
                1'b0: bcd_data_second_mux = i_bcd_msec_sec;
                1'b1: bcd_data_second_mux = i_bcd_min_hour;
                default: bcd_data_second_mux = i_bcd_msec_sec;
            endcase
        end
    end
endmodule

module BCD_Decoder (
    input      [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(bcd) begin
        case (bcd)
            0:       fnd_data = 8'hc0;
            1:       fnd_data = 8'hf9;
            2:       fnd_data = 8'ha4;
            3:       fnd_data = 8'hb0;
            4:       fnd_data = 8'h99;
            5:       fnd_data = 8'h92;
            6:       fnd_data = 8'h82;
            7:       fnd_data = 8'hf8;
            8:       fnd_data = 8'h80;
            9:       fnd_data = 8'h90;
            4'he:    fnd_data = 8'hff;
            4'hf:    fnd_data = 8'h7f;
            default: fnd_data = 8'hff;
        endcase
    end
endmodule
