`timescale 1ns / 1ps
module tb_RAM_ip();


    reg clk;
    reg [7:0] addr;
    reg [7:0] wr_data;
    reg write_en;
    wire [7:0] rd_data;

    // Instantiate the RAM_IP module
    RAM_IP uut (
        .clk(clk),
        .addr(addr),
        .wr_data(wr_data),
        .write_en(write_en),
        .rd_data(rd_data)
    );

    always #5 clk = ~clk; // 10 ns clock period
    
    initial begin
        // Initialize inputs
        clk = 0;
        addr = 0;
        wr_data = 0;
        write_en = 0;

        // Write data to RAM

        #5; write_en = 1; addr = 10; wr_data = 8'h0a;
        #10; addr = 11; wr_data = 8'h0b;
        #10; addr = 31; wr_data = 8'h0c;
        #10; addr = 32; wr_data = 8'h0d;
        #10; write_en = 0; addr = 10;
        #10; addr = 11;
        #10; addr = 31;
        #10; addr = 32;
        #10; addr = 10;
        // Finish simulation
        $finish;
    end
endmodule

