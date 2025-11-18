// 控制模块：主状态机 FSM（带错误倒计时）
module controller_fsm(
    input clk,              // 系统时钟
    input rst_n,            // 异步复位，低有效
    input button,           // 按键确认
    input [3:0] mode_sel,   // 模式选择
    input calc_done,        // 运算完成信号
    input error_in,         // 错误输入
    input countdown_done,   // 新增：倒计时完成信号
    output reg [3:0] state, // 当前状态
    output reg start_calc,  // 启动计算信号
    output reg [3:0] op_type, // 当前操作类型
    output reg error_led,   // 错误指示 LED
    output reg start_countdown // 新增：启动倒计时信号
);

    // 状态编码（保持不变）
    parameter S0_IDLE       = 4'd0,
              S1_MENU       = 4'd1,
              S2_INPUT      = 4'd2,
              S3_GEN        = 4'd3,
              S4_DISPLAY    = 4'd4,
              S5_COMPUTE    = 4'd5,
              S6_ERROR      = 4'd6,
              S7_STORE      = 4'd7,
              S8_SELECT     = 4'd8,
              S9_WAIT       = 4'd9;

    reg [3:0] next_state;

    // 状态寄存器更新（保持不变）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0_IDLE;
        else
            state <= next_state;
    end

    // ----------------------------
    // 下一状态逻辑（关键修改）
    // ----------------------------
    always @(*) begin
        next_state = state;
        case(state)
            S0_IDLE: next_state = S1_MENU;
            S1_MENU: begin
                if(button) begin
                    case(mode_sel)
                        4'b0001: next_state = S2_INPUT;
                        4'b0010: next_state = S3_GEN;
                        4'b0100: next_state = S4_DISPLAY;
                        4'b1000: next_state = S8_SELECT; // 运算先进入选择操作数
                        default: next_state = S1_MENU;
                    endcase
                end
            end
            
            S2_INPUT:  next_state = S7_STORE;
            S7_STORE:  next_state = S1_MENU; // 存储完成回菜单
            
            S8_SELECT: begin
                if (error_in) 
                    next_state = S9_WAIT;    // 选择错误进入倒计时
                else 
                    next_state = S5_COMPUTE; // 选择正确开始计算
            end
            
            S3_GEN:    next_state = S1_MENU;
            S4_DISPLAY: next_state = S1_MENU;
            
            S5_COMPUTE: begin
                if (error_in)
                    next_state = S9_WAIT;    // 计算错误进入倒计时
                else if (calc_done)
                    next_state = S4_DISPLAY; // 计算完成显示结果
                else
                    next_state = S5_COMPUTE;
            end
            
            S6_ERROR:  next_state = S9_WAIT; // 错误状态直接进入倒计时
            
            S9_WAIT: begin
                if (button) 
                    next_state = S8_SELECT;  // 倒计时内按键：重新选择操作数
                else if (countdown_done)
                    next_state = S1_MENU;    // 倒计时结束：回菜单
                else
                    next_state = S9_WAIT;    // 继续倒计时
            end
            
            default:   next_state = S1_MENU;
        endcase
    end

    // ----------------------------
    // 输出逻辑（修改）
    // ----------------------------
    always @(*) begin
        start_calc = (state == S5_COMPUTE);
        error_led  = (state == S6_ERROR) || (state == S9_WAIT); // 错误和倒计时都亮LED
        start_countdown = (state == S9_WAIT); // 启动倒计时
        
        // 操作类型输出
        if (state == S8_SELECT || state == S9_WAIT)
            op_type = {1'b0, mode_sel[2:0]}; // 选择和倒计时期间保持操作类型
        else
            op_type = 4'd0;
    end

endmodule