// 矩阵加法模块
// 功能：实现两个同维度矩阵的加法运算
// 输入：两个相同维度的矩阵A和B (m×n)
// 输出：结果矩阵C = A + B (m×n)
module mat_add(
    input clk,
    input rst_n,
    input start,            // 开始计算信号
    input [2:0] rows,       // 矩阵行数m (1-5)
    input [2:0] cols,       // 矩阵列数n (1-5)  
    input [3:0] A [0:4][0:4], // 矩阵A，5×5最大
    input [3:0] B [0:4][0:4], // 矩阵B，5×5最大
    output reg [7:0] C [0:4][0:4], // 结果矩阵C（可能超过4bit）
    output reg done,        // 计算完成标志
    output reg error        // 错误标志（维度不匹配）
);

    // 状态定义
    reg [2:0] state;
    reg [2:0] i, j;
    
    parameter IDLE = 3'd0, CHECK = 3'd1, CALC = 3'd2, DONE = 3'd3;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            done <= 0;
            error <= 0;
            i <= 0;
            j <= 0;
            // 初始化结果矩阵
            for (int i=0; i<5; i=i+1)
                for (int j=0; j<5; j=j+1)
                    C[i][j] <= 0;
        end else begin
            case(state)
                IDLE: begin
                    done <= 0;
                    error <= 0;
                    if (start) state <= CHECK;
                end
                
                CHECK: begin
                    // 检查矩阵维度是否匹配
                    if (rows > 0 && rows <= 5 && cols > 0 && cols <= 5) begin
                        state <= CALC;
                        i <= 0;
                        j <= 0;
                    end else begin
                        error <= 1;
                        state <= DONE;
                    end
                end
                
                CALC: begin
                    if (i < rows) begin
                        if (j < cols) begin
                            // 矩阵加法：C[i][j] = A[i][j] + B[i][j]
                            C[i][j] <= A[i][j] + B[i][j];
                            j <= j + 1;
                        end else begin
                            j <= 0;
                            i <= i + 1;
                        end
                    end else begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    done <= 1;
                    if (!start) state <= IDLE;
                end
            endcase
        end
    end

endmodule