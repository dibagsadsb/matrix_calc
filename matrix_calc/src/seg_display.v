// 七段数码管显示模块（支持运算类型显示）
module seg_display(
    input clk,               // 系统时钟
    input [3:0] state,       // FSM 状态输入
    input [3:0] op_type,     // 新增：运算类型输入
    output reg [6:0] seg     // 七段数码管输出（a-g）
);

    // ----------------------------
    // 倒计时计数寄存器
    // ----------------------------
    reg [25:0] clk_count;    // 时钟计数，用于产生 1 秒节拍（假设 100 MHz）
    reg [3:0] sec_count;     // 秒计数（支持 0~9 秒倒计时）

    always @(posedge clk) begin
        if(state == 4'd9) begin
            if(clk_count >= 100_000_000 - 1) begin
                clk_count <= 0;
                if(sec_count != 0)
                    sec_count <= sec_count - 1;
            end else begin
                clk_count <= clk_count + 1;
            end
        end else begin
            clk_count <= 0;
            sec_count <= 4'd9;
        end
    end

    // ----------------------------
    // 数码管显示逻辑（关键修改）
    // ----------------------------
    always @(*) begin
        if(state == 4'd9) begin
            // 等待状态显示倒计时数字
            case(sec_count)
                4'd9: seg = 7'b0001110; // 9
                4'd8: seg = 7'b0000000; // 8
                4'd7: seg = 7'b0000110; // 7
                4'd6: seg = 7'b0100000; // 6
                4'd5: seg = 7'b0010010; // 5
                4'd4: seg = 7'b0110000; // 4
                4'd3: seg = 7'b0000110; // 3
                4'd2: seg = 7'b0010010; // 2
                4'd1: seg = 7'b1001111; // 1
                4'd0: seg = 7'b0000001; // 0
                default: seg = 7'b1111111;
            endcase
        end else if(state == 4'd8) begin
            // 新增：在选择操作数状态显示运算类型
            case(op_type)
                4'b0001: seg = 7'b0000111; // T - 转置
                4'b0010: seg = 7'b0001000; // A - 加法  
                4'b0100: seg = 7'b0000011; // B - 标量乘法
                4'b1000: seg = 7'b1000110; // C - 矩阵乘法
                default: seg = 7'b1111111; // 默认全灭
            endcase
        end else begin
            // 其他状态根据FSM状态显示字符
            case(state)
                4'd0: seg = 7'b1111110; // I - 空闲（S0_IDLE）
                4'd1: seg = 7'b0110000; // n - 菜单（S1_MENU）
                4'd2: seg = 7'b1000000; // A - 用户输入（S2_INPUT）
                4'd3: seg = 7'b0001000; // G - 生成矩阵（S3_GEN）
                4'd4: seg = 7'b0001001; // d - 显示结果（S4_DISPLAY）
                4'd5: seg = 7'b0000010; // C - 运算执行（S5_COMPUTE）
                4'd6: seg = 7'b0000110; // E - 系统错误（S6_ERROR）
                4'd7: seg = 7'b0100001; // S7_STORE - 存储
                default: seg = 7'b1111111; // 其他状态全灭
            endcase
        end
    end

endmodule