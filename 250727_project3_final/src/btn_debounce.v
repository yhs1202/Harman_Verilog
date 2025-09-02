`timescale 1ns / 1ps

module btn_debounce (
    input  clk,
    rst,
    i_btn,
    output o_btn
);

    wire debounce;
    reg [3:0] q_reg, q_next;  // Shift Register 4 x D-FF

    // START Clk divider 1Mhz
    reg  [$clog2(100000)-1:0] counter;  // 100Mhz -> 1Mhz (/100)

    reg                       r_db_clk_1Mhz;



    // 1) 외부 비동기 입력
    wire                      async_btn = i_btn;

    // 2) 첫 번째 플립플롭: 메타안정 해소를 시도
    reg                       sync_ff1;
    always @(posedge clk or posedge rst) begin
        if (rst) sync_ff1 <= 1'b0;
        else sync_ff1 <= async_btn;
    end

    // 3) 두 번째 플립플롭: 안정된 신호 최종 출력
    reg sync_ff2;
    always @(posedge clk or posedge rst) begin
        if (rst) sync_ff2 <= 1'b0;
        else sync_ff2 <= sync_ff1;
    end

    // 4) 이제 sync_ff2를 시스템 로직에서 사용
    wire btn_sync = sync_ff2;




    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 0;
            r_db_clk_1Mhz <= 0;
        end else begin
            if(counter == (100000-1))      // 0~99 (=100-1)
            begin
                counter <= 0;
                r_db_clk_1Mhz <= ~r_db_clk_1Mhz;
                //  r_db_clk_1Mhz <= 1'b1;
            end else begin
                counter <= counter + 1;
                //  r_db_clk_1Mhz <= 1'b0;
            end
        end
    end
    // END Clk divider 1Mhz 



    // Shift Register
    always @(posedge r_db_clk_1Mhz, posedge rst)                  // r_db_clk_1Mhz = 1Mhz, clk = 100Mhz
    begin
        if (rst) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;
        end
    end

    // Shift Register
    always @(*) begin
        q_next = {btn_sync, q_reg[3:1]};
    end

    // debounce = 4bit AND(&)
    assign debounce = &q_reg;

    // Edge Detection

    reg edge_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            edge_reg <= 0;
        end else begin
            edge_reg <= debounce;
        end
    end

    // Invert a 1 tick after debounce signal
    // o_btn = Rising Edged debounce signal
    assign o_btn = ~edge_reg & debounce;


endmodule
