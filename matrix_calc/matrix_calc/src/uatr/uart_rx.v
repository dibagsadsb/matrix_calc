// UART接收模块
// 功能：实现UART串行数据接收，支持115200波特率
module uart_rx(
    input clk,              // 系统时钟 (100MHz)
    input rst_n,            // 复位
    input uart_rx,          // 串行输入
    output reg [7:0] rx_data, // 接收到的数据
    output reg rx_ready,    // 数据就绪标志（单周期脉冲）
    output reg rx_error     // 接收错误（帧错误）
);

    // 波特率配置
    parameter CLK_DIV = 868;
    parameter CLK_DIV_2 = 434; // 半位时间，用于采样
    parameter IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
    
    reg [1:0] state;
    reg [9:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] rx_reg;
    reg uart_rx_sync;       // 同步后的输入信号
    
    // 输入同步（防亚稳态）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_rx_sync <= 1'b1;
        end else begin
            uart_rx_sync <= uart_rx;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            rx_ready <= 0;
            rx_error <= 0;
            rx_data <= 0;
            clk_count <= 0;
            bit_index <= 0;
            rx_reg <= 0;
        end else begin
            rx_ready <= 0; // 单周期脉冲
            
            case(state)
                IDLE: begin
                    if (!uart_rx_sync) begin // 检测到起始位
                        state <= START;
                        clk_count <= 0;
                    end
                end
                
                START: begin
                    // 在起始位中间采样，确保是真正的起始位
                    if (clk_count == CLK_DIV_2) begin
                        if (!uart_rx_sync) begin // 确认起始位
                            state <= DATA;
                            clk_count <= 0;
                            bit_index <= 0;
                        end else begin
                            state <= IDLE; // 毛刺，返回空闲
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                DATA: begin
                    if (clk_count >= CLK_DIV - 1) begin
                        clk_count <= 0;
                        rx_reg[bit_index] <= uart_rx_sync; // 采样数据位
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
                    if (clk_count >= CLK_DIV - 1) begin
                        clk_count <= 0;
                        // 检查停止位
                        if (uart_rx_sync) begin
                            rx_data <= rx_reg;
                            rx_ready <= 1;
                            rx_error <= 0;
                        end else begin
                            rx_error <= 1; // 帧错误
                        end
                        state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
            endcase
        end
    end

endmodule