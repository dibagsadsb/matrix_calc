// 标量乘法模块
// 功能：实现标量与矩阵的乘法运算 scalar × A(m×n) = C(m×n)
module mat_scalar_mult(
    input clk,
    input rst_n,
    input start,
    input [2:0] rows,       // 矩阵行数
    input [2:0] cols,       // 矩阵列数
    input [3:0] scalar,     // 标量值 (0-9)
    input [3:0] A [0:4][0:4], // 输入矩阵
    output reg [7:0] C [0:4][0:4], // 结果矩阵
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
                            // 标量乘法：C[i][j] = scalar × A[i][j]
                            C[i][j] <= scalar * A[i][j];
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