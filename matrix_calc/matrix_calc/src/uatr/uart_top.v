// UART顶层模块
// 功能：集成所有UART功能，提供统一接口
module uart_top(
    input clk,
    input rst_n,
    // 外部UART接口
    input uart_rx_pin,
    output uart_tx_pin,
    // 矩阵数据接收
    input parser_start,
    output [2:0] parsed_rows,
    output [2:0] parsed_cols,
    output [3:0] parsed_matrix [0:4][0:4],
    output parser_data_valid,
    output parser_busy,
    output parser_error,
    // 矩阵数据显示
    input display_start,
    input [2:0] display_rows,
    input [2:0] display_cols,
    input [7:0] display_matrix [0:4][0:4],
    output display_busy,
    output display_done
);

    // UART RX/TX信号
    wire [7:0] rx_data;
    wire rx_ready;
    wire rx_error;
    wire [7:0] tx_data;
    wire tx_start;
    wire tx_done;
    wire tx_busy;
    
    // 实例化UART收发模块
    uart_rx u_rx(
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(uart_rx_pin),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .rx_error(rx_error)
    );
    
    uart_tx u_tx(
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .uart_tx(uart_tx_pin)
    );
    
    // 实例化数据解析模块
    uart_parser u_parser(
        .clk(clk),
        .rst_n(rst_n),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .parser_start(parser_start),
        .rows(parsed_rows),
        .cols(parsed_cols),
        .matrix_data(parsed_matrix),
        .data_valid(parser_data_valid),
        .parser_busy(parser_busy),
        .parse_error(parser_error)
    );
    
    // 实例化显示模块
    uart_display u_display(
        .clk(clk),
        .rst_n(rst_n),
        .display_start(display_start),
        .rows(display_rows),
        .cols(display_cols),
        .matrix(display_matrix),
        .tx_busy(display_busy),
        .display_done(display_done),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_done(tx_done)
    );

endmodule