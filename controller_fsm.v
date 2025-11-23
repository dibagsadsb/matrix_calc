// 主控制器模块：有限状态机，带倒计时功能
module controller_fsm(
    input clk,              // 系统时钟
    input rst_n,            // 异步复位，低电平有效
    input button,           // 确认按钮
    input [3:0] mode_sel,   // 模式选择
    input calc_done,        // 计算完成信号
    input error_in,         // 错误输入
    output reg [3:0] state, // 当前状态
    output reg start_calc,  // 开始计算信号
    output reg [3:0] op_type, // 当前操作类型
    output reg error_led,   // 错误指示灯LED
    output reg start_countdown, // 启动倒计时信号
    output countdown_done       // 导出倒计时完成信号

    // //用于矩阵模块的接口
    // output reg start_input,      // FSM 控制输入矩阵
    // output reg start_gen,        // FSM 控制生成矩阵
    // output reg start_display     // FSM 控制显示矩阵到 UART

);

    // 状态编码定义
    parameter S0_IDLE       = 4'd0,  // 空闲状态
              S1_MENU       = 4'd1,  // 菜单显示
              S2_INPUT      = 4'd2,  // 输入状态
              S3_GEN        = 4'd3,  // 生成状态
              S4_DISPLAY    = 4'd4,  // 显示状态
              S5_COMPUTE    = 4'd5,  // 计算状态
              S6_ERROR      = 4'd6,  // 错误状态
              S7_STORE      = 4'd7,  // 存储状态
              S8_SELECT     = 4'd8,  // 选择计算方式
              S9_WAIT       = 4'd9;  // 倒计时等待

    reg [3:0] next_state;
    reg [25:0] wait_timer;  // 1 秒倒计时（100 MHz）

    // 状态寄存器更新
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0_IDLE;
        else
            state <= next_state;
    end

    // 倒计时计数器逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wait_timer <= 0;
        end else if (state == S9_WAIT) begin
            if (wait_timer >= 100_000_000 - 1)
                wait_timer <= 0;
            else
                wait_timer <= wait_timer + 1;
        end else begin
            wait_timer <= 0; 
        end
    end

    // 倒计时完成信号
    wire countdown_done_internal;
    assign countdown_done_internal = 
        (state == S9_WAIT) && (wait_timer >= 100_000_000 - 1);

    assign countdown_done = countdown_done_internal;

    // ----------------------------
    // 下一状态逻辑（组合逻辑）
    // ----------------------------
    always @(*) begin
        next_state = state; // 默认保持

        case(state)

            S0_IDLE: begin
                next_state = S1_MENU;
            end

            S1_MENU: begin
                if(button) begin
                    case(mode_sel)
                        4'b0001: next_state = S2_INPUT;   // 输入
                        4'b0010: next_state = S3_GEN;     // 生成
                        4'b0100: next_state = S4_DISPLAY; // 显示
                        4'b1000: next_state = S8_SELECT;  // 进入计算方式选择
                        default: next_state = S1_MENU;
                    endcase
                end
            end

            S2_INPUT:  next_state = S7_STORE;
            S7_STORE:  next_state = S1_MENU;

            // 选择计算方法
            S8_SELECT: begin
                if (error_in)
                    next_state = S6_ERROR;
                else if (button)        // 必须按按钮才进入计算
                    next_state = S5_COMPUTE;
            end

            S3_GEN:     next_state = S1_MENU;
            S4_DISPLAY: next_state = S1_MENU;

            S5_COMPUTE: begin
                if (error_in)
                    next_state = S6_ERROR;
                else if (calc_done)
                    next_state = S4_DISPLAY;
            end

            S6_ERROR: next_state = S9_WAIT;

            S9_WAIT: begin
                if (button)
                    next_state = S8_SELECT;       // 返回选择界面
                else if (countdown_done_internal)
                    next_state = S1_MENU;         // 自动返回菜单
            end

            default: next_state = S1_MENU;

        endcase
    end


    // ----------------------------
    // 输出逻辑
    // ----------------------------
    always @(*) begin
        start_calc       = (state == S5_COMPUTE);
        error_led        = (state == S6_ERROR) || (state == S9_WAIT);
        start_countdown  = (state == S9_WAIT);

        

        // 默认无操作
        op_type = 4'b0000;

        // 只有在菜单、选择、计算或显示状态才显示 op_type
        if ( state == S8_SELECT ) begin
            case(mode_sel)
                4'b0001: op_type = 4'b0001; // 转置
                4'b0010: op_type = 4'b0010; // 加法
                4'b0100: op_type = 4'b0100; // 标量乘法
                4'b1000: op_type = 4'b1000; // 矩阵乘法
                4'b1111: op_type = 4'b1111; // 卷积
                default: op_type = 4'b0000; // 非法或无操作
            endcase
        end
    end







    // //输出逻辑需要更改
    // // ----------------------------
    // // 输出逻辑
    // // ----------------------------
    // always @(*) begin
    //     // 默认输出
    //     start_calc      = 0;
    //     error_led       = 0;
    //     start_countdown = 0;
    //     op_type         = 4'b0000;
    //     // <<< 新增/修改：FSM 控制矩阵模块
    //     start_input     = 0;
    //     start_gen       = 0;
    //     start_display   = 0;

    //     error_led = (state == S6_ERROR) || (state == S9_WAIT);
    //     start_countdown = (state == S9_WAIT);

    //     case(state)
    //         S2_INPUT: start_input = 1;   // <<< FSM 控制输入矩阵
    //         S3_GEN:   start_gen   = 1;   // <<< FSM 控制生成矩阵
    //         S5_COMPUTE: start_calc = 1;  // <<< FSM 控制计算模块
    //         S4_DISPLAY: start_display = 1; // <<< FSM 控制 UART 输出
    //         default: ;
    //     endcase

    //     // op_type 显示运算类型
    //     if (state == S1_MENU || state == S8_SELECT || state == S5_COMPUTE || state == S4_DISPLAY) begin
    //         case(mode_sel)
    //             4'b0001: op_type = 4'b0001; // 转置
    //             4'b0010: op_type = 4'b0010; // 加法
    //             4'b0100: op_type = 4'b0100; // 标量乘法
    //             4'b1000: op_type = 4'b1000; // 矩阵乘法
    //             4'b1111: op_type = 4'b1111; // 卷积
    //             default: op_type = 4'b0000;
    //         endcase
    //     end
    // end

endmodule
