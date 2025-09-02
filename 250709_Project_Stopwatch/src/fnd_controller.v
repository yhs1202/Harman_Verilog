`timescale 1ns / 1ps
module fnd_controller (
    input clk,
    input reset,
    input sw,
    input [6:0] msec, // msec 
    input [5:0] sec,    // sec
    input [5:0] min, // min 
    input [4:0] hour,    // hour
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    /* wire */
    wire [3:0] w_digit_hour_1;
    wire [3:0] w_digit_hour_10;
    wire [3:0] w_digit_min_1;
    wire [3:0] w_digit_min_10;

    wire [3:0] w_digit_msec_1;
    wire [3:0] w_digit_msec_10;
    wire [3:0] w_digit_sec_1;
    wire [3:0] w_digit_sec_10;
    wire [3:0] w_bcd;

    wire [2:0] w_digit_sel;
    wire w_1khz;


    wire [3:0] w_mux81_first, w_mux81_second;
    

    wire w_dot; // comp dptj skrksms output


    mux_2x1 U_MUX_2x1 (
        .sel(sw),
        .hour_min(w_mux81_second),
        .sec_msec(w_mux81_first),
        .bcd_data(w_bcd)
    );

    // hour
    digit_spliter #(
        .DS_WIDTH(5)
    ) U_HOUR_DS (
        .i_data(hour),
        .digit_1(w_digit_hour_1),
        .digit_10(w_digit_hour_10)
    );
    // minute
    digit_spliter #(
        .DS_WIDTH(6)
    ) U_MIN_DS (
        .i_data(min),
        .digit_1(w_digit_min_1),
        .digit_10(w_digit_min_10)
    );

    // second
    digit_spliter #(
        .DS_WIDTH(6)
    ) U_SEC_DS (
        .i_data(sec),
        .digit_1(w_digit_sec_1),
        .digit_10(w_digit_sec_10)
    );
    // msecond
    digit_spliter #(
        .DS_WIDTH(7)
    ) U_MSEC_DS (
        .i_data(msec),
        .digit_1(w_digit_msec_1),
        .digit_10(w_digit_msec_10)
    );
    bcd_decoder U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );
    dot_comparator U_DOT_COMP (
        .msec(msec),
        .dot(w_dot)
    );
    mux_8x1 U_Mux_8x1_first (
        .sel(w_digit_sel),
        .digit_1(w_digit_msec_1),
        .digit_10(w_digit_msec_10),
        .digit_100(w_digit_sec_1),
        .digit_1000(w_digit_sec_10),
        .digit_off_1(4'he),
        .digit_off_10(4'he),
        .digit_off_100({3'b111, w_dot}),
        .digit_off_1000(4'he),
        .bcd_data(w_mux81_first)
    );
    mux_8x1 U_Mux_8x1_second (
        .sel(w_digit_sel),
        .digit_1(w_digit_min_1),
        .digit_10(w_digit_min_10),
        .digit_100(w_digit_hour_1),
        .digit_1000(w_digit_hour_10),
        .digit_off_1(4'he),
        .digit_off_10(4'he),
        .digit_off_100({3'b111, w_dot}),
        .digit_off_1000(4'he),
        .bcd_data(w_mux81_second)
    );
    decoder_2x4 U_Decoder_Fnd_com (
        .sel(w_digit_sel[1:0]), // gkdnl 2bit tkdyd
        .fnd_com(fnd_com)
    );
    counter_8 U_Counter_8 (
        .clk(w_1khz),
        .reset(reset),
        .digit_sel(w_digit_sel)
    );
    clk_div U_CLK_DIV (
        .clk(clk),
        .reset(reset),
        .o_1khz(w_1khz)
    );
endmodule

/* number, dot */
module dot_comparator (
    input [6:0] msec, // msec
    output dot
);
   assign dot = (msec >= 50) ? 1'b1 : 1'b0; //  1~49 = 0, 50~99 = 1

endmodule


// select signal in 8x1 mux
module counter_8 (
    input clk,
    input reset,
    output [2:0] digit_sel // revised to 2bit -> 3bit (counter4 -> counter8)
);
    reg [2:0] r_counter; // revised

    assign digit_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            // digit_sel <= 1'b0;
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule


module mux_8x1 (
    input [2:0] sel, // 2bit -> 3bit
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
    always @(*) begin
        case (sel)
            3'b000:   bcd_data = digit_1;
            3'b001:   bcd_data = digit_10;
            3'b010:   bcd_data = digit_100;
            3'b011:   bcd_data = digit_1000;
            3'b100:   bcd_data = digit_off_1;
            3'b101:   bcd_data = digit_off_10;
            3'b110:   bcd_data = digit_off_100;
            3'b111:   bcd_data = digit_off_1000;
            default: bcd_data = digit_1;
        endcase
    end

endmodule


module mux_2x1 (
    input sel,
    input [3:0] hour_min,
    input [3:0] sec_msec,

    output [3:0] bcd_data
);
    assign bcd_data = sel ? sec_msec : hour_min;

endmodule


/* BCD Display */
module digit_spliter #(
    parameter DS_WIDTH = 7
)(
    input  [DS_WIDTH-1:0] i_data,
    output [3:0] digit_1,
    output [3:0] digit_10
);

    assign digit_1 = i_data % 10;
    assign digit_10 = i_data / 10 % 10;
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


module bcd_decoder (
    input      [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(bcd) begin
        case (bcd)
            4'h0: fnd_data = 8'hc0;
            4'h1: fnd_data = 8'hf9;
            4'h2: fnd_data = 8'ha4;
            4'h3: fnd_data = 8'hb0;
            4'h4: fnd_data = 8'h99;
            4'h5: fnd_data = 8'h92;
            4'h6: fnd_data = 8'h82;
            4'h7: fnd_data = 8'hf8;
            4'h8: fnd_data = 8'h80;
            4'h9: fnd_data = 8'h90;
            4'he: fnd_data = 8'hff;
            4'hf: fnd_data = 8'h7f;
            default: fnd_data = 8'hff;
        endcase
    end
endmodule


/* clk generate */
module clk_div (
    input clk,
    input reset,
    output reg o_1khz
);
    // 100MHz -> 1kHz (10e8->10e3) 100,000 -> 0~99999 (17bit)
    // counter -> 17bit
    reg [16:0] r_counter;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
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