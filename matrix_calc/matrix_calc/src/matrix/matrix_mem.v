// 修改后的矩阵存储模块 - 支持同时输出两个矩阵
module matrix_mem(
    input clk,
    input rst_n,
    input write_en,         // 写使能
    input read_en_A,        // 读使能A  
    input read_en_B,        // 读使能B
    input [2:0] rows_A,     // 矩阵A维度
    input [2:0] cols_A,     // 矩阵A维度
    input [2:0] rows_B,     // 矩阵B维度  
    input [2:0] cols_B,     // 矩阵B维度
    input [1:0] mat_id_A,   // 矩阵A标识
    input [1:0] mat_id_B,   // 矩阵B标识
    input [3:0] data_in [0:4][0:4], // 写入的矩阵数据
    output reg [3:0] data_out_A [0:4][0:4], // 矩阵A输出
    output reg [3:0] data_out_B [0:4][0:4], // 矩阵B输出
    output reg ready,       // 操作完成
    output reg error        // 错误标志
);

    // 矩阵存储结构：5种行×5种列×2个矩阵×5×5元素
    reg [3:0] memory [0:4][0:4][0:1][0:4][0:4]; 
    reg [1:0] mat_count [0:4][0:4]; // 每种规格的矩阵计数
    
    reg [2:0] state;
    parameter IDLE=0, WRITE=1, READ=2, DONE=3;
    
    // 初始化
    integer i, j;
    initial begin
        for (i=0; i<5; i=i+1)
            for (j=0; j<5; j=j+1)
                mat_count[i][j] <= 0;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            ready <= 0;
            error <= 0;
            // 初始化输出矩阵
            for (int i=0; i<5; i=i+1)
                for (int j=0; j<5; j=j+1) begin
                    data_out_A[i][j] <= 0;
                    data_out_B[i][j] <= 0;
                end
        end else begin
            case(state)
                IDLE: begin
                    ready <= 0;
                    error <= 0;
                    if (write_en) state <= WRITE;
                    else if (read_en_A || read_en_B) state <= READ;
                end
                
                WRITE: begin
                    // 写入逻辑保持不变
                    if (mat_count[rows_A-1][cols_A-1] < 2 || mat_id_A < mat_count[rows_A-1][cols_A-1]) begin
                        for (int i=0; i<rows_A; i=i+1)
                            for (int j=0; j<cols_A; j=j+1)
                                memory[rows_A-1][cols_A-1][mat_id_A][i][j] <= data_in[i][j];
                        
                        if (mat_id_A >= mat_count[rows_A-1][cols_A-1])
                            mat_count[rows_A-1][cols_A-1] <= mat_id_A + 1;
                            
                        state <= DONE;
                    end else begin
                        error <= 1;
                        state <= DONE;
                    end
                end
                
                READ: begin
                    // 读取矩阵A
                    if (read_en_A && !write_en) begin
                        for (int i=0;i<5;i++)
                            for (int j=0;j<5;j++)
                                data_out_A[i][j] = (i<rows_A && j<cols_A) ? memory[rows_A-1][cols_A-1][mat_id_A][i][j] : 0;
                    end

                    // 读取矩阵B
                    if (read_en_B && !write_en) begin
                        for (int i=0;i<5;i++)
                            for (int j=0;j<5;j++)
                                data_out_B[i][j] = (i<rows_B && j<cols_B) ? memory[rows_B-1][cols_B-1][mat_id_B][i][j] : 0;
                    end

                    state <= DONE;
                end
                
                DONE: begin
                    ready <= 1;
                    if (!write_en && !read_en_A && !read_en_B) state <= IDLE;
                end
            endcase
        end
    end

endmodule