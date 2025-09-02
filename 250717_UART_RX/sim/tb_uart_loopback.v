`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/17 14:37:26
// Design Name: 
// Module Name: tb_uart_loopback
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


// PC <> FPGA UART Loopback Testbench
module tb_uart_loopback();
    reg clk, reset, rx; //, tx_start;
    reg [7:0] send_data;
    reg [7:0] receive_data;
    wire tx, tx_busy, rx_busy, rx_done, tx_done;
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
        #0; clk = 0; reset = 1; rx = 1; // rx = 1 -> no incoming data (idle state)
        #10; reset = 0; // release reset
        send_data = 8'h30; // Example data to send
        send_uart(send_data); // Send data
        // # (104166 * 10); // Wait for 10 bits (1 start + 8 data + 1 stop)
        // @(!tx_busy); // Wait until tx is not busy
        // wait (rx_done); // Wait for transmission to complete
        receive_uart(); // Receive data
        if (receive_data == send_data) begin
            $display("Data received successfully: %h", receive_data);
        end else begin
            $display("Data mismatch! Sent: %h, Received: %h", send_data, receive_data);
        end
        #1000;
        $stop;
    end

    // task tx-> rx send
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
    
    // task rx -> tx receive
    task receive_uart(
    );
        integer i;
        begin
            // Check if tx is low (start bit)
            if (tx == 0) begin
                #(104166/2); // Wait for half a bit time to ensure start bit is stable
                #(104166); // Wait for 1 bit time
                for (i = 0; i < 8; i = i + 1) begin
                    receive_data[i] = tx; // Read each bit from tx
                    #(104166); // Wait for 1 bit time
                end
            end
            // Stop bit
            #(104166); // Wait for stop bit
            #(104166/2); // Wait for half a bit time to ensure stop bit is stable
        end
    endtask
endmodule
