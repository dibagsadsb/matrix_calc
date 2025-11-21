// 矩阵转置模块
// 功能：实现矩阵的转置运算 A(m×n) -> C(n×m)
module mat_transpose(
    input clk,
    input rst_n, 
    input start,
    input [2:0] rows,       // 原矩阵行数
    input [2:0] cols,       // 原矩阵列数
    input [3:0] A [0:4][0:4], // 输入矩阵
    output reg [3:0] C [0:4][0:4], // 转置矩阵
    output reg done
);

    reg [2:0] state;
    reg [2:0] i, j;
    
    parameter IDLE=0, CALC=1, DONE=2;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            done <= 0;
            i <= 0; j <= 0;
            for (int i=0; i<5; i=i+1)
                for (int j=0; j<5; j=j+1)
                    C[i][j] <= 0;
        end else begin
            case(state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        state <= CALC;
                        i <= 0; j <= 0;
                    end
                end
                
                CALC: begin
                    if (i < rows) begin
                        if (j < cols) begin
                            // 转置操作：C[j][i] = A[i][j]
                            C[j][i] <= A[i][j];
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