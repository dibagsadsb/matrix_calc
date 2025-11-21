// UART数据解析模块
// 功能：解析从串口接收的矩阵数据（维度 + 元素）
module uart_parser(
    input clk,
    input rst_n,
    input [7:0] rx_data,    // 接收到的字节
    input rx_ready,         // 数据就绪
    input parser_start,     // 开始解析
    output reg [2:0] rows,  // 解析出的行数
    output reg [2:0] cols,  // 解析出的列数
    output reg [3:0] matrix_data [0:4][0:4], // 解析出的矩阵
    output reg data_valid,  // 数据有效
    output reg parser_busy, // 解析忙标志
    output reg parse_error  // 解析错误
);

    parameter IDLE = 3'd0, WAIT_ROWS = 3'd1, WAIT_COLS = 3'd2, 
              WAIT_DATA = 3'd3, DONE = 3'd4, ERROR = 3'd5;
    
    reg [2:0] state;
    reg [2:0] row_idx, col_idx;

    // ASCII字符转换
    function [3:0] ascii_to_value;
        input [7:0] ascii;
        begin
            if (ascii >= 8'h30 && ascii <= 8'h39) // '0'-'9'
                ascii_to_value = ascii - 8'h30;
            else
                ascii_to_value = 4'hF; // 无效值
        end
    endfunction
    
    integer i, j;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            data_valid <= 0;
            parser_busy <= 0;
            parse_error <= 0;
            rows <= 0;
            cols <= 0;
            row_idx <= 0;
            col_idx <= 0;
            // 初始化矩阵
            for (i=0; i<5; i=i+1)
                for (j=0; j<5; j=j+1)
                    matrix_data[i][j] <= 0;
        end else begin
            data_valid <= 0; // 单周期脉冲
            
            case(state)
                IDLE: begin
                    parser_busy <= 0;
                    parse_error <= 0;
                    if (parser_start) begin
                        state <= WAIT_ROWS;
                        parser_busy <= 1;
                        rows <= 0;
                        cols <= 0;
                        row_idx <= 0;
                        col_idx <= 0;
                    end
                end
                
                WAIT_ROWS: begin
                    if (rx_ready) begin
                        if (rx_data >= 8'h31 && rx_data <= 8'h35) begin // '1'-'5'
                            rows <= ascii_to_value(rx_data);
                            state <= WAIT_COLS;
                        end else begin
                            state <= ERROR;
                        end
                    end
                end
                
                WAIT_COLS: begin
                    if (rx_ready) begin
                        if (rx_data >= 8'h31 && rx_data <= 8'h35) begin // '1'-'5'
                            cols <= ascii_to_value(rx_data);
                            row_idx <= 0;
                            col_idx <= 0;
                            state <= WAIT_DATA;
                        end else begin
                            state <= ERROR;
                        end
                    end
                end
                
                WAIT_DATA: begin
                    if (rx_ready) begin
                        // 接收单个矩阵元素
                        if (rx_data >= 8'h30 && rx_data <= 8'h39) begin // '0'-'9'
                            matrix_data[row_idx][col_idx] <= ascii_to_value(rx_data);
                            
                            // 更新行列索引
                            if (col_idx == cols - 1) begin
                                col_idx <= 0;
                                if (row_idx == rows - 1) begin
                                    state <= DONE;  // 接收完最后一行最后一列，进入 DONE
                                end else begin
                                    row_idx <= row_idx + 1;
                                end
                            end else begin
                                col_idx <= col_idx + 1;
                            end
                        end else begin
                            state <= ERROR;
                        end
                    end
                end

                DONE: begin
                    data_valid <= 1;       // 输出单周期有效信号

                    // 补0操作：不足的元素补0
                    integer i, j;
                    for(i = 0; i < 5; i = i + 1) begin
                        for(j = 0; j < 5; j = j + 1) begin
                            if(i >= parsed_rows || j >= parsed_cols)
                                parsed_matrix[i][j] <= 0;
                        end
                    end

                    parser_busy <= 0;
                    if (!parser_start) begin
                        state <= IDLE;     // parser_start 下降沿返回 IDLE
                    end
                end

                
                ERROR: begin
                    parse_error <= 1;
                    parser_busy <= 0;
                    if (!parser_start) state <= IDLE;
                end
            endcase
        end
    end

endmodule
