// LED状态显示模块（独立版）
// 功能：根据FSM状态控制相应LED指示系统状态
module led_status(
    input [3:0] state,    // FSM状态编码（4位）
    output reg [7:0] leds // LED输出，每位对应一个状态
);

    always @(*) begin
        leds = 8'b0; // 默认所有LED熄灭
        case(state)
            4'd0: leds[0] = 1'b1; // S0_IDLE 空闲状态，点亮LED0
            4'd1: leds[1] = 1'b1; // S1_MENU 菜单状态，点亮LED1
            4'd2: leds[2] = 1'b1; // S2_INPUT 用户输入，点亮LED2
            4'd3: leds[3] = 1'b1; // S3_GEN 生成矩阵，点亮LED3
            4'd4: leds[4] = 1'b1; // S4_DISPLAY 显示结果，点亮LED4
            4'd5: leds[5] = 1'b1; // S5_COMPUTE 计算执行，点亮LED5
            4'd6: leds[7] = 1'b1; // S6_ERROR 系统错误，点亮LED7
            4'd7: leds[6] = 1'b1; // S7_STORE 存储数据，点亮LED6
            4'd8: leds[6] = 1'b1; // S8_SELECT 选择操作数，点亮LED3（与S6复用）
            4'd9: leds[7] = 1'b1; // S9_WAIT 倒计时等待，点亮LED2（与S7复用）
            default: leds = 8'b0;  // 未定义状态全部熄灭
        endcase
    end

endmodule