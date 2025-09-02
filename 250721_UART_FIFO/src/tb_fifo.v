`timescale 1ns / 1ps
module tb_fifo ();

    reg clk, rst, push, pop;
    reg  [7:0] w_data; // push data
    wire [7:0] r_data; // pop data
    wire full, empty;

    fifo dut (
        .clk(clk),
        .rst(rst),
        .push(push),
        .pop(pop),
        .w_data(w_data),
        .full(full),
        .empty(empty),
        .r_data(r_data)
    );

    always #5 clk = ~clk;

    integer i;
    reg rand_push;
    reg rand_pop;
    reg [7:0] compare_data[0:16-1];  // fifo 크기만큼 설정
    integer push_count, pop_count;  // push  count, pop count,

    initial begin
        #0;
        clk = 0;
        rst = 1;
        push = 0;
        pop = 0;
        w_data = 0;
        #20;
        rst = 0;
        // full test
        for (i = 0; i < 17; i = i + 1) begin
            #10;
            push = 1;
            w_data = i;
        end
        #10;
        push = 0;
        // empty test
        for (i = 0; i < 17; i = i + 1) begin
            #10;
            pop = 1;
        end
        #10;
        pop = 0;
        // push & pop test
        for (i = 0; i < 20; i = i + 1) begin
            #10;
            push = 1;
            pop = 1;
            w_data = i + 1;
        end
        #10;
        push = 0;
        #10;
        pop = 0; 
    // random push, pop
    push_count = 0;
    pop_count = 0;
    @(negedge clk);

    for (i = 0; i < 100; i = i + 1) begin
        // random push
        w_data = $random % 256; // 0~255 random data, w_data is 8-bit
        rand_push = $random % 2; // 0 or 1
        if (!full && rand_push) begin
            push = 1;
            compare_data[push_count] = w_data; // store pushed data for comparison

            if(push_count == 15) begin
                push_count = 0; // reset count if it exceeds fifo size
            end else push_count = push_count + 1;
            // @(negedge clk); // wait for clk to change
            // push = 0;
        end else begin
            push = 0;
        end

        // random pop
        rand_pop = $random % 2; // 0 or 1
        if (!empty && rand_pop) begin
            pop = 1;

            // check if the popped data matches the expected data
            #1 // read data after one clock cycle;
            if(r_data == compare_data[pop_count]) begin
                $display("pass");
            end else begin
                $display("fail: expected %d, got %d", compare_data[pop_count], r_data);
            end
            if(pop_count == 15) begin
                pop_count = 0; // reset count if it exceeds fifo size
            end else pop_count = pop_count + 1;
        end else begin
            pop = 0;
        end
        @(negedge clk);
    end        
        push = rand_push;
        pop = rand_pop;
        $stop;
    end
endmodule
