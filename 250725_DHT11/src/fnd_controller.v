`timescale 1ns / 1ps

module fnd_controller(
    input        clk,
    input        rst,
    input  [7:0] msec,
    input  [7:0] sec,
    input  [7:0] min,
    input  [7:0] hour,
    input        sw,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    
    wire [2:0] w_digit_sel;
    wire [3:0] w_digit_msec1, w_digit_msec10, w_digit_sec1, w_digit_sec10,
                w_digit_min1, w_digit_min10, w_digit_hour1, w_digit_hour10;
    wire [3:0] w_msec_sec, w_min_hour, w_bcd;
    wire w_1khz;
    wire w_dot_onoff;
    
    clk_div U_Clk_div (
        .clk        (clk       ),
        .rst        (rst       ),
        .o_1khz     (w_1khz    )
    );

    counter #(
        .COUNT   (8)
    ) U_Counter_8(
        .clk    (w_1khz),
        .rst    (rst),
        .sel    (w_digit_sel)
    );

    digit_spliter #(
        .DS_WIDTH (8)
    ) U_DS_MSEC (
        .i_data     (msec           ),
        .digit_1    (w_digit_msec1  ),
        .digit_10   (w_digit_msec10 )
    );
    
    digit_spliter #(
        .DS_WIDTH (8)
    ) U_DS_SEC (
        .i_data     (sec           ),
        .digit_1    (w_digit_sec1  ),
        .digit_10   (w_digit_sec10 )
    );

    digit_spliter #(
        .DS_WIDTH (8)
    ) U_DS_MIN (
        .i_data     (min           ),
        .digit_1    (w_digit_min1  ),
        .digit_10   (w_digit_min10 )
    );

    digit_spliter #(
        .DS_WIDTH (8)
    ) U_DS_HOUR (
        .i_data     (hour          ),
        .digit_1    (w_digit_hour1 ),
        .digit_10   (w_digit_hour10)
    );

    dot_point U_DP (
        .msec       (msec),
        .dot_onoff  (w_dot_onoff)
    );

    mux_8x1 U_Mux_MSEC_SEC (
        .sel            (w_digit_sel),
        .digit_1        (w_digit_msec1),
        .digit_10       (w_digit_msec10),
        .digit_100      (w_digit_sec1),
        .digit_1000     (w_digit_sec10),
        .digit_off_1    (4'he),
        .digit_off_10   (4'he),
        .digit_dot      ({3'b111, w_dot_onoff}),
        .digit_off_1000 (4'he),
        .bcd_data       (w_msec_sec)
    );

    mux_8x1 U_Mux_MIN_HOUR (
        .sel            (w_digit_sel),
        .digit_1        (w_digit_min1),
        .digit_10       (w_digit_min10),
        .digit_100      (w_digit_hour1),
        .digit_1000     (w_digit_hour10),
        .digit_off_1    (4'he),
        .digit_off_10   (4'he),
        .digit_dot      ({3'b111, w_dot_onoff}),
        .digit_off_1000 (4'he),
        .bcd_data       (w_min_hour)
    );
    
    mux_2x1 U_Mux_2x1(
        .sel        (sw),
        .first      (w_msec_sec),
        .second     (w_min_hour),
        .o_data     (w_bcd)
    );

    bcd_decoder U_BCD (
        .bcd        (w_bcd      ),
        .fnd_data   (fnd_data   )
    );

    decoder_2x4 U_Decoder_2x4 (
        .sel        (w_digit_sel[1:0]),
        .fnd_com    (fnd_com    )
    );

endmodule


module clk_div (
    input clk,
    input rst,
    output reg o_1khz
);
    // 100MHz -> 1kHz (10e8->10e3) 100,000 -> 0~99999 (17bit)
    // counter -> 17bit
    reg [16:0] r_counter;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            o_1khz <= 1'b0;
        end else begin
            if (r_counter == 100000 - 1) begin
                r_counter <= 0;
                o_1khz <= 1'b1;
            end else begin    
                // 99999->100000 : o_1khz = 1
                r_counter <= r_counter + 1;  // until 100000
                o_1khz <= 1'b0;
            end
        end

    end
endmodule

module counter_4 (
    input clk,
    input rst,
    output [1:0] digit_sel
);
    reg [1:0] r_counter;

    assign digit_sel = r_counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            // digit_sel <= 1'b0;
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule

module decoder_2x4 (
    input [1:0] sel,
    output reg [3:0] fnd_com
);
    always @(sel) begin
        case (sel)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b0000;
        endcase
    end

endmodule

module mux_4x1 (
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output reg [3:0] bcd_data
);
    always @(*) begin
        case (sel)
            2'b00:   bcd_data = digit_1;
            2'b01:   bcd_data = digit_10;
            2'b10:   bcd_data = digit_100;
            2'b11:   bcd_data = digit_1000;
            default: bcd_data = digit_1;
        endcase
    end

endmodule

module digit_spliter (
    input  [13:0] count,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1 = count % 10;
    assign digit_10 = count / 10 % 10;
    assign digit_100 = count / 100 % 10;
    assign digit_1000 = count / 1000 % 10;

endmodule


module bcd_decoder (
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
