// UART发送模块
// 功能：实现UART串行数据发送，支持115200波特率
// 协议：1起始位 + 8数据位 + 1停止位，无校验位
module uart_tx(
    input clk,              // 系统时钟 (100MHz)
    input rst_n,            // 复位
    input [7:0] tx_data,    // 要发送的数据
    input tx_start,         // 开始发送信号
    output reg tx_busy,     // 发送忙标志
    output reg tx_done,     // 发送完成标志
    output reg uart_tx      // 串行输出
);

    // 波特率配置：100MHz / 115200 ≈ 868
    parameter CLK_DIV = 868;
    parameter IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
    
    reg [1:0] state;
    reg [9:0] clk_count;    // 波特率分频计数器
    reg [2:0] bit_index;    // 数据位索引 (0-7)
    reg [7:0] tx_reg;       // 发送数据寄存器
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx_busy <= 0;
            tx_done <= 0;
            uart_tx <= 1'b1;
            clk_count <= 0;
            bit_index <= 0;
            tx_reg <= 0;
        end else begin
            tx_done <= 0; // 单周期脉冲
            
            case(state)
                IDLE: begin
                    uart_tx <= 1'b1; // 空闲高电平
                    tx_busy <= 0;
                    if (tx_start) begin
                        state <= START;
                        tx_busy <= 1;
                        tx_reg <= tx_data;
                        clk_count <= 0;
                    end
                end
                
                START: begin
                    uart_tx <= 1'b0; // 起始位
                    if (clk_count >= CLK_DIV - 1) begin
                        clk_count <= 0;
                        state <= DATA;
                        bit_index <= 0;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                DATA: begin
                    uart_tx <= tx_reg[bit_index]; // 发送数据位
                    if (clk_count >= CLK_DIV - 1) begin
                        clk_count <= 0;
                        if (bit_index == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                STOP: begin
                    uart_tx <= 1'b1; // 停止位
                    if (clk_count >= CLK_DIV - 1) begin
                        clk_count <= 0;
                        state <= IDLE;
                        tx_done <= 1;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
            endcase
        end
    end

endmodule