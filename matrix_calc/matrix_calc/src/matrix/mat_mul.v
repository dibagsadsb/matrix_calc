// 矩阵乘法模块  
// 功能：实现两个矩阵的乘法运算 A(m×n) × B(n×p) = C(m×p)
// 要求：矩阵A的列数必须等于矩阵B的行数
module mat_mul(
    input clk,
    input rst_n, 
    input start,
    input [2:0] rows_A,     // 矩阵A行数m
    input [2:0] cols_A,     // 矩阵A列数n
    input [2:0] cols_B,     // 矩阵B列数p
    input [3:0] A [0:4][0:4],
    input [3:0] B [0:4][0:4], 
    output reg [7:0] C [0:4][0:4], // 结果矩阵
    output reg done,
    output reg error        // 错误：维度不满足乘法要求
);

    reg [2:0] state;
    reg [2:0] i, j, k;
    reg [7:0] sum;
    
    parameter IDLE=0, CHECK=1, CALC=2, DONE=3;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            done <= 0;
            error <= 0;
            i <= 0; j <= 0; k <= 0;
            sum <= 0;
            // 清零结果矩阵
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
                    // 检查：cols_A必须等于rows_B（这里rows_B用cols_A表示）
                    if (cols_A > 0 && rows_A <= 5 && cols_B <= 5) begin
                        state <= CALC;
                        i <= 0; j <= 0; k <= 0;
                        sum <= 0;
                    end else begin
                        error <= 1;
                        state <= DONE;
                    end
                end
                
                CALC: begin
                    if (i < rows_A) begin
                        if (j < cols_B) begin
                            if (k < cols_A) begin
                                // 累加：sum += A[i][k] * B[k][j]
                                sum <= sum + A[i][k] * B[k][j];
                                k <= k + 1;
                            end else begin
                                // 完成C[i][j]的计算
                                C[i][j] <= sum;
                                sum <= 0;
                                k <= 0;
                                j <= j + 1;
                            end
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