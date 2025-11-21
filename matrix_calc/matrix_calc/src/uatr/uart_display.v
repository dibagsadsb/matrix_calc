// UART显示模块（修改版）
module uart_display(
    input clk,
    input rst_n,
    input display_start,     
    input [2:0] rows,       
    input [2:0] cols,       
    input [7:0] matrix [0:4][0:4],
    output reg tx_busy,     
    output reg display_done,
    output reg [7:0] tx_data,
    output reg tx_start,
    input tx_done
);

    parameter IDLE       = 3'd0,
              SEND_TENS  = 3'd1,
              SEND_ONES  = 3'd2,
              SEND_SPACE = 3'd3,
              SEND_NEWLINE = 3'd4,
              DONE       = 3'd5;

    reg [2:0] state;
    reg [2:0] row_idx, col_idx;
    reg [7:0] temp_data;

    // 数字转ASCII
    function [7:0] value_to_ascii;
        input [7:0] value;
        begin
            value_to_ascii = 8'h30 + value;
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx_busy <= 0;
            display_done <= 0;
            tx_start <= 0;
            tx_data <= 0;
            row_idx <= 0;
            col_idx <= 0;
            temp_data <= 0;
        end else begin
            tx_start <= 0;  // 单周期脉冲
            display_done <= 0;

            case(state)
                IDLE: begin
                    tx_busy <= 0;
                    row_idx <= 0;
                    col_idx <= 0;
                    if(display_start) begin
                        tx_busy <= 1;
                        state <= SEND_TENS;
                    end
                end

                SEND_TENS: begin
                    temp_data = matrix[row_idx][col_idx];
                    tx_data <= value_to_ascii(temp_data / 10);
                    tx_start <= 1;
                    state <= SEND_ONES;
                end

                SEND_ONES: begin
                    if(tx_done) begin
                        tx_data <= value_to_ascii(matrix[row_idx][col_idx] % 10);
                        tx_start <= 1;
                        state <= SEND_SPACE;
                    end
                end

                SEND_SPACE: begin
                    if(tx_done) begin
                        if(col_idx < cols - 1) begin
                            tx_data <= 8'h20; // 空格
                            tx_start <= 1;
                            col_idx <= col_idx + 1;
                            state <= SEND_TENS;
                        end else begin
                            state <= SEND_NEWLINE;
                        end
                    end
                end

                SEND_NEWLINE: begin
                    if(tx_done) begin
                        tx_data <= 8'h0A; // LF
                        tx_start <= 1;
                        col_idx <= 0;
                        if(row_idx < rows - 1) begin
                            row_idx <= row_idx + 1;
                            state <= SEND_TENS;
                        end else begin
                            state <= DONE;
                        end
                    end
                end

                DONE: begin
                    if(tx_done) begin
                        display_done <= 1;
                        tx_busy <= 0;
                        if(!display_start) state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
