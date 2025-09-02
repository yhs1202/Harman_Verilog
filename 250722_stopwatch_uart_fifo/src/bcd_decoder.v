`timescale 1ns / 1ps

// ��ȣ�� ���� bit �� -> ���� bit ��
module bcd_decoder(
    input       [3:0] bcd,
    output reg  [7:0] fnd_data
);

always @(bcd) begin
    case(bcd)
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
        4'hE: fnd_data = 8'hFF;
        4'hF: fnd_data = 8'h7F;
        default: fnd_data = 8'hc0;
    endcase
end

endmodule
