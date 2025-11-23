// 顶层模块：矩阵计算系统
// 功能：集成控制FSM、数码管显示、LED状态指示以及UART接口
module matrix_calc_top(
    input clk,               // 系统时钟
    input rst,               // 复位信号，低有效
    input [3:0] dip_switch,  // DIP开关，用于模式选择
    input button_confirm,    // 按钮确认输入
    input uart_rx,           // UART接收端口
    output uart_tx,          // UART发送端口
    output [7:0] leds,       // LED状态指示
    output [6:0] seg_display, // 7段数码管显示
    output tub_sel1          // 数码管位选信号
);

    // ================================
    // 内部信号定义
    // ================================
    wire rst_n = ~rst;

    wire [3:0] state;        // 当前状态
    wire start_calc;         // 开始计算
    wire [3:0] op_type;      // 操作类型
    wire error_flag;         // 错误标志
    wire start_countdown;    // 倒计时启动信号
    wire button_debounced;   // 防抖后按键

    // 计算完成与错误信号（后续会接实际计算模块）
    assign error_flag = 1'b0;
    assign calc_done = 1'b0;

    // UART默认未实现
    assign uart_tx = 1'b0;


    // ================================
    // 防抖模块
    // ================================
    debounce u_debounce (
        .clk(clk),
        .button_in(button_confirm),
        .button_out(button_debounced)
    );


    // ================================
    // FSM 主控制器
    // ================================
controller_fsm u_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .button(button_confirm), // 直接用原始信号
        .mode_sel(dip_switch),
        .calc_done(calc_done),
        .error_in(error_flag),
        .state(state),
        .start_calc(start_calc),
        .op_type(op_type),
        .error_led(leds[7]),
        .start_countdown(start_countdown)
    );


    // ================================
    // 数码管显示
    // ================================
    assign tub_sel1 = 1'b1;  

    seg_display u_seg (
        .clk(clk),
        .state(state),
        .op_type(op_type),
        .seg(seg_display)
    );


    // ================================
    // LED 状态指示
    // ================================
    led_status u_led (
        .state(state),
        .leds(leds[6:0]) // 低7位由状态控制
    );


    // ================================
    // 加一些B、C的接口，但暂时不上版测试，因为功能不齐全
    // 以后若有更改，需在顶层调整
    // ================================

    
    // // 新增寄存器/信号
    // reg [3:0] m_cur, n_cur;        // 当前输入矩阵维度
    // reg [7:0] matrix_buffer[0:4][0:4]; // 当前输入/生成矩阵缓冲
    // reg input_valid;
    // reg gen_mode;                  // 生成模式标志
    // reg [7:0] gen_count, gen_total;
    // reg [7:0] rand_seed;

    // // UART RX 接收完成信号
    // wire rx_done;
    // wire [7:0] rx_data;
    // uart_rx uart_rx_inst(
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .rx(uart_rx),
    //     .rx_data(rx_data),
    //     .rx_done(rx_done)
    // );

    // // 接收数据处理逻辑
    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         m_cur <= 0; n_cur <= 0; input_valid <= 0; gen_mode <= 0; gen_count <= 0; rand_seed <= 8'd1;
    //     end else if(rx_done) begin
    //         if(m_cur == 0 && rx_data>=1 && rx_data<=5) m_cur <= rx_data;
    //         else if(n_cur == 0 && rx_data>=1 && rx_data<=5) n_cur <= rx_data;
    //         else if(gen_mode==0) begin
    //             matrix_buffer[(gen_count/n_cur)][(gen_count%n_cur)] <= (rx_data <= 9) ? rx_data : 0;
    //             gen_count <= gen_count + 1;
    //             if(gen_count >= m_cur*n_cur) input_valid <= 1;
    //         end else begin
    //             gen_total <= rx_data; // 用户输入生成矩阵数量
    //             gen_mode <= 1;
    //             gen_count <= 0;
    //         end
    //     end
    // end





endmodule
