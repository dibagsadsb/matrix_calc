// 七段数码管显示模块（完全重写版）
module seg_display(
    input clk,                 // 系统时钟
    input [3:0] state,         // 当前状态
    input [3:0] op_type,       // 已确认的计算方式
    output reg [6:0] seg       // 七段数码管
);

    // 状态编码（与你的 FSM 一致）
    localparam S0_IDLE    = 4'd0,
               S1_MENU    = 4'd1,
               S2_INPUT   = 4'd2,
               S3_GEN     = 4'd3,
               S4_DISPLAY = 4'd4,
               S5_COMPUTE = 4'd5,
               S6_ERROR   = 4'd6,
               S7_STORE   = 4'd7,
               S8_SELECT  = 4'd8,
               S9_WAIT    = 4'd9;

    // ----------------------------
    // 倒计时计数器：只在 WAIT 状态运行
    // ----------------------------
    reg [25:0] clk_count = 0;
    reg [3:0]  sec_count = 9;

    always @(posedge clk) begin
        if(state == S9_WAIT) begin
            if(clk_count >= 100_000_000 - 1) begin
                clk_count <= 0;
                if(sec_count != 0)
                    sec_count <= sec_count - 1;
            end
            else
                clk_count <= clk_count + 1;
        end
        else begin
            clk_count <= 0;
            sec_count <= 9;
        end
    end

    // ----------------------------
    // 七段数码管编码（共阳极）倒计时
    // ----------------------------
    function [6:0] seg_num(input [3:0] n);
        case(n)
            4'd9: seg_num = 7'b1111011;
            4'd8: seg_num = 7'b1111111;
            4'd7: seg_num = 7'b1110000;
            4'd6: seg_num = 7'b1011111;
            4'd5: seg_num = 7'b1011011;
            4'd4: seg_num = 7'b0110011;
            4'd3: seg_num = 7'b1111001;
            4'd2: seg_num = 7'b1101101;
            4'd1: seg_num = 7'b0110000;
            4'd0: seg_num = 7'b1111110;
            default: seg_num = 7'b0000000;
        endcase
    endfunction

    // 字母段码
    function [6:0] seg_char(input [3:0] op);
        case(op)
            4'b0001: seg_char = 7'b0000111; // T 转置
            4'b0010: seg_char = 7'b1110111; // A 加法
            4'b0100: seg_char = 7'b0011111; // B 标量乘法
            4'b1000: seg_char = 7'b1001110; // C 矩阵乘法
            4'b1111: seg_char = 7'b1111110; //D 卷积
            default: seg_char = 7'b0000000;
        endcase
    endfunction

    // ----------------------------
    // 最终显示逻辑（核心）
    // ----------------------------
    always @(*) begin
        case(state)

            // 倒计时状态：显示数字 9 → 0
            S9_WAIT: begin
                seg = seg_num(sec_count);
            end

            // 计算中 / 显示结果：显示已确认的 op_type
            S5_COMPUTE,
            S4_DISPLAY: begin
                seg = seg_char(op_type);
            end

            // 其它状态全部不显示
            default: begin
                seg = 7'b0000000;
            end
        endcase
    end

endmodule
