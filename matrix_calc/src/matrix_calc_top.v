// 顶层模块：矩阵计算系统
// 功能：整合控制 FSM、数码管显示、LED 状态指示，以及 UART 接口
module matrix_calc_top(
    input clk,               // 系统时钟
    input rst_n,             // 复位信号，低有效
    input [3:0] dip_switch,  // DIP 开关，用于模式选择
    input button_confirm,    // 按键确认输入
    input uart_rx,           // UART 接收端口
    output uart_tx,          // UART 发送端口
    output [7:0] leds,       // LED 状态指示
    output [6:0] seg_display // 7 段数码管显示
);
 
    // 内部信号
    wire [3:0] state;        // 当前状态机状态（改为4位）
    wire start_calc;         // FSM 发出的开始计算信号
    wire calc_done;          // 运算完成标志
    wire error_flag;         // 系统错误标志
    wire [3:0] op_type;      // 运算类型信号
    wire countdown_done;     // 倒计时完成信号
    wire start_countdown;    // 启动倒计时信号

    // 控制 FSM 模块
    controller_fsm u_ctrl (
        .clk(clk), 
        .rst_n(rst_n),
        .button(button_confirm),  // 按键输入
        .mode_sel(dip_switch),    // 模式选择
        .calc_done(calc_done),    // 计算完成输入
        .error_in(error_flag),    // 错误输入
        .countdown_done(countdown_done),  // 倒计时完成输入
        .state(state),            // 输出当前状态
        .start_calc(start_calc),  // 输出开始计算信号
        .op_type(op_type),        // 输出运算类型
        .error_led(leds[7]),     // 错误LED单独控制
        .start_countdown(start_countdown) // 输出启动倒计时
    );

    // 数码管显示模块
    seg_display u_seg (
        .clk(clk),
        .state(state),           // 根据状态显示对应信息
        .op_type(op_type),       // 运算类型输入
        .seg(seg_display)
    );

    // LED 指示模块
    led_status u_led (
        .state(state),           // 根据状态点亮对应 LED
        .leds(leds[6:0])         // 只控制前7个LED，LED7由FSM单独控制
    );

    // 其他模块（UART、存储、运算）B 和 C 实现
    // 这里需要连接 calc_done, error_flag, countdown_done 等信号

endmodule