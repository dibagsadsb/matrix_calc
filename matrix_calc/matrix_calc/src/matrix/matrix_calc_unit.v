// 矩阵计算总控模块
// 功能：根据操作类型调用不同的矩阵运算模块
module matrix_calc_unit(
    input clk,
    input rst_n,
    input start,            // 开始计算
    input [3:0] op_type,    // 操作类型：0001=转置, 0010=加法, 0100=标乘, 1000=乘法
    input [2:0] rows_A,     // 矩阵A行数
    input [2:0] cols_A,     // 矩阵A列数  
    input [2:0] rows_B,     // 矩阵B行数（用于乘法和加法）
    input [2:0] cols_B,     // 矩阵B列数
    input [3:0] scalar,     // 标量值（用于标量乘法）
    input [3:0] mat_A [0:4][0:4], // 输入矩阵A
    input [3:0] mat_B [0:4][0:4], // 输入矩阵B
    output reg [7:0] result [0:4][0:4], // 计算结果
    output reg [2:0] result_rows, // 结果行数
    output reg [2:0] result_cols, // 结果列数
    output reg done,        // 计算完成
    output reg error        // 计算错误
);

    // 各运算模块的输出信号
    wire add_done, mul_done, scalar_done, transpose_done;
    wire add_error, mul_error;
    wire [7:0] add_result [0:4][0:4];
    wire [7:0] mul_result [0:4][0:4]; 
    wire [7:0] scalar_result [0:4][0:4];
    wire [3:0] transpose_result [0:4][0:4];
    
    // 实例化所有运算模块
    mat_add u_mat_add(
        .clk(clk),
        .rst_n(rst_n),
        .start(start && op_type == 4'b0010),
        .rows(rows_A),
        .cols(cols_A),
        .A(mat_A),
        .B(mat_B),
        .C(add_result),
        .done(add_done),
        .error(add_error)
    );
    
    mat_mul u_mat_mul(
        .clk(clk),
        .rst_n(rst_n), 
        .start(start && op_type == 4'b1000),
        .rows_A(rows_A),
        .cols_A(cols_A),
        .cols_B(cols_B),
        .A(mat_A),
        .B(mat_B),
        .C(mul_result),
        .done(mul_done),
        .error(mul_error)
    );
    
    mat_scalar_mult u_scalar_mult(
        .clk(clk),
        .rst_n(rst_n),
        .start(start && op_type == 4'b0100),
        .rows(rows_A),
        .cols(cols_A),
        .scalar(scalar),
        .A(mat_A),
        .C(scalar_result),
        .done(scalar_done)
    );
    
    mat_transpose u_transpose(
        .clk(clk),
        .rst_n(rst_n),
        .start(start && op_type == 4'b0001),
        .rows(rows_A),
        .cols(cols_A),
        .A(mat_A),
        .C(transpose_result),
        .done(transpose_done)
    );
    
    // 结果选择和维度设置
    always @(*) begin
    // 默认值
    done = 0;
    error = 0;
    result_rows = 0;
    result_cols = 0;

    case(op_type)
        4'b0001: begin // 转置
            done = transpose_done;
            result_rows = cols_A;
            result_cols = rows_A;
            for (int i=0;i<5;i++)
                for (int j=0;j<5;j++)
                    result[i][j] = (i<cols_A && j<rows_A) ? transpose_result[i][j] : 0;
        end
        4'b0010: begin // 加法
            done = add_done;
            error = add_error;
            result_rows = rows_A;
            result_cols = cols_A;
            for (int i=0;i<5;i++)
                for (int j=0;j<5;j++)
                    result[i][j] = add_result[i][j];
        end
        4'b0100: begin // 标量乘法
            done = scalar_done;
            result_rows = rows_A;
            result_cols = cols_A;
            for (int i=0;i<5;i++)
                for (int j=0;j<5;j++)
                    result[i][j] = scalar_result[i][j];
        end
        4'b1000: begin // 矩阵乘法
            done = mul_done;
            error = mul_error;
            result_rows = rows_A;
            result_cols = cols_B;
            for (int i=0;i<5;i++)
                for (int j=0;j<5;j++)
                    result[i][j] = mul_result[i][j];
        end
        default: begin
            done = 0;
            error = 1;
        end
    endcase
end


endmodule