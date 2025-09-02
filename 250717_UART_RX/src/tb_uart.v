`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/16 14:12:22
// Design Name: 
// Module Name: tb_uart
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


module tb_uart();
    reg clk, reset, rx, tx_start;
    reg [7:0] tx_data;
    reg [7:0] send_data;
    reg [7:0] receive_data;
    wire tx, tx_busy, rx_busy, rx_done;
    wire [7:0] rx_data;

    uart uut (
        .clk(clk),
        .reset(reset),
        .tx_start(rx_done), // from tx_done
        .rx(rx), 
        .tx_data(rx_data), // from rx_data
        .tx(tx),
        .tx_busy(tx_busy),
        .rx_data(rx_data),
        .rx_busy(rx_busy),
        .rx_done(rx_done)
    );

    always #5 clk = ~clk; // 100MHz clock

    initial begin
        #0; clk = 0; reset = 1; tx_start = 0; rx = 1; tx_data = 8'h30; // rx = 1 -> no incoming data (idle state)
        #10; reset = 0; // release reset
        send_data = 8'h30; // Example data to send
        send_uart(send_data); // Send data
        #1000;
        $stop;
    end

    task send_uart(
        input [7:0] send_data
    );
        integer i;
        begin
            rx = 0; // Start bit
            #(104166); // Wait for 1 bit time at 9600 baud rate
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i]; // Send each bit
                #(104166); // Wait for 1 bit time
            end
            // Stop bit
            rx = 1; 
            #(104166);
        end
    endtask

    integer i;
    // task receiver_uart
    task receive_uart();
        begin
            wait(~tx);
            #(104166 / 2);
            #(104166);
            // data bit
            for (i = 0; i < 8; i = i + 1) begin
                receive_data[i] = tx; // Read each bit
                #(104166);
            end
            // Stop bit
            #(104166);
            #(104166 / 2);
        end
    endtask

endmodule