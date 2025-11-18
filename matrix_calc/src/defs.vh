// File: defs.vh
// 矩阵计算工程的全局参数定义
// 在所有使用本文件参数的 .v 文件中加入：`include "defs.vh"

// 矩阵最大尺寸（行/列）
`define MATRIX_MAX_SIZE           4       // 支持 4x4 矩阵
`define MATRIX_WIDTH              8       // 矩阵的每个元素是 8-bit 数据

// UART 配置
`define UART_BAUD                 115200  // 串口波特率
`define CLK_FREQ                  100_000_000  // FPGA 板子主时钟 100MHz

// ========== 状态机定义 ==========（关键修改）
`define STATE_WIDTH               4       // 新增：状态位宽定义
`define STATE_IDLE                4'd0    // 空闲
`define STATE_MENU                4'd1    // 菜单显示
`define STATE_INPUT               4'd2    // 用户输入
`define STATE_GENERATE            4'd3    // 产生测试矩阵
`define STATE_DISPLAY             4'd4    // 显示结果
`define STATE_COMPUTE             4'd5    // 运算执行
`define STATE_ERROR               4'd6    // 系统错误
`define STATE_STORE               4'd7    // 存储矩阵
`define STATE_SELECT              4'd8    // 选择操作数
`define STATE_WAIT                4'd9    // 倒计时等待

// 相关参数定义（可扩展）
`define DEBOUNCE_DELAY            20_000_000   // 按键去抖延迟

// UART 相关参数
`define UART_START_BIT            1'b0
`define UART_STOP_BIT             1'b1
`define UART_DATA_BITS            8
`define UART_PARITY_ENABLE        0