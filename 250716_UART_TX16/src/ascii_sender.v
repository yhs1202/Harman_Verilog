`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/16 11:54:42
// Design Name: 
// Module Name: ascii_sender
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ascii_sender(
    input clk,
    input reset,
    input start,
    input tx_busy,
    output sent_start,
    output [7:0] ascii_data
);

    parameter IDLE = 0, SEND = 1;
    
    reg state;
    reg r_send; // r_send = 1 -> sending
    reg [2:0] send_count;
    reg [7:0] ascii_data_reg [0:4];

    assign ascii_data = ascii_data_reg[send_count];
    assign sent_start = r_send;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            send_count <= 0;
            r_send <= 0;    // sent tick
            ascii_data_reg[0] <= "h";
            ascii_data_reg[1] <= "e";
            ascii_data_reg[2] <= "l";
            ascii_data_reg[3] <= "l";
            ascii_data_reg[4] <= "o";
        end else begin
            case (state)
                IDLE: begin 
                    send_count <= 0;
                    r_send <= 0; // Reset send signal
                    if (start) begin
                        state <= SEND;
                        r_send <= 1;
                    end
                end
                SEND: begin 
                    r_send <= 0;
                    // busy rk EjTsmsep dlal rk qkRNldjqjfla
                    if (!tx_busy && !r_send) begin
                        send_count <= send_count + 1;
                        r_send <= 1; // Set send signal to high to start sending data
                        if (send_count == 3'h4) begin
                            send_count <= 0;
                            r_send <= 0;
                            state <= IDLE;
                        end else state <= SEND; // Continue sending
                    end
                end
            endcase
        end
    end
endmodule
