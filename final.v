`timescale 1ns / 1ps

module final(
    input mclk,
    input rst,
	 input mode,

    // Keypad 接腳
    input [3:0] keypadCol,         
    output [3:0] keypadRow,
	 //
	 output [7:0] dot_row,
	 output [7:0] dot_col,
    // 移動速度
    input [3:0] bar_move_speed,

    // VGA 訊號輸出
    output HSync,
    output [3:0] OutBlue,
    output [3:0] OutGreen,
    output [3:0] OutRed,
    output VSync,

    // 七段顯示器輸出
    output [6:0] seg1,
    output [6:0] seg2,
    output [6:0] seg3,
    output [6:0] seg4
);

// 1) 透過 checkkeypad 得到 key_val (4 bits)
wire [3:0] key_val;

checkkeypad u_ck (
    .clk(mclk),
    .rst(~rst),
    .keypadCol(keypadCol),
    .keypadRow(keypadRow),  // 由此模組驅動 4 條 row

    // dot-matrix 保留
    .dot_row(dot_row),
    .dot_col(dot_col),

    // 對外輸出掃描到的鍵
    .key_val(key_val)
);

// 2) 產生 to_left、to_right
wire to_left, to_right;

// 最左下(4'h0)為左鍵
assign to_left  = (key_val == 4'hf);
// 最右下(4'h7)為右鍵
assign to_right = (key_val == 4'h0);

// 3) 帶入 VGA_Dispay
wire lose;

VGA_Dispay u_VGA_Disp (
	 .mode(mode),
    .clk(mclk),
    .to_left(to_left),
    .to_right(to_right),
    .bar_move_speed(bar_move_speed),
    .hs(HSync),
    .vs(VSync),
    .Red(OutRed),
    .Green(OutGreen),
    .Blue(OutBlue),
    .lose(lose),
);

// 4) 分數顯示(七段顯示器)模組
seven_seg score_board(
    .clk(mclk),
    .rst(rst),
    .lose(lose),
    .seg1(seg1),
    .seg2(seg2),
    .seg3(seg3),
    .seg4(seg4)
);

endmodule

