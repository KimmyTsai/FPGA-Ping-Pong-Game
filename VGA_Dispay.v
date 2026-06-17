`timescale 1ns / 1ps
`include "Definition.h"

module VGA_Dispay(
    input mode,
    input clk,
    input to_left,
    input to_right,
    input [3:0] bar_move_speed,
    output reg hs,
    output reg vs,
    output reg [3:0] Red,
    output reg [3:0] Green,
    output reg [3:0] Blue,
    output reg lose
);

// VGA 參數區
parameter PAL = 640;   // Pixels/Active Line
parameter LAF = 480;   // Lines/Active Frame
parameter PLD = 800;   // Pixel/Line Divider
parameter LFD = 521;   // Line/Frame Divider
parameter HPW = 96;    // Horizontal synchro Pulse Width
parameter HFP = 16;    
parameter VPW = 2;     // Verical synchro Pulse Width
parameter VFP = 10;

parameter UP_BOUND   = 10;
parameter DOWN_BOUND = 480;  
parameter LEFT_BOUND = 20;  
parameter RIGHT_BOUND = 630;

// Ball radius
parameter ball_r = 10;

reg [9:0] Hcnt;
reg [9:0] Vcnt;
reg clk_25M = 0;

reg h_speed = `RIGHT;
reg v_speed = `UP;

// bar位置
reg [9:0] up_pos    = 400;
reg [9:0] down_pos  = 430;
reg [9:0] left_pos  = 230;
reg [9:0] right_pos = 430;  

// 球心位置
reg [9:0] ball_x_pos = 330;
reg [9:0] ball_y_pos = 390;

// 1) 產生 25MHz clock
always@(posedge clk) begin
    clk_25M <= ~clk_25M;
end

// 2) 水平/垂直同步信號產生 (hs, vs)
always@(posedge clk_25M) begin
    // Hcnt 遞增
    if(Hcnt == PLD - 1) begin
        Hcnt <= 0;
        // Vcnt 遞增
        if(Vcnt == LFD - 1)
            Vcnt <= 0;
        else
            Vcnt <= Vcnt + 1;
    end
    else begin
        Hcnt <= Hcnt + 1;
    end

    // 產生 hs
    if(Hcnt == (PAL - 1 + HFP))
        hs <= 1'b0;
    else if(Hcnt == (PAL - 1 + HFP + HPW))
        hs <= 1'b1;

    // 產生 vs
    if(Vcnt == (LAF - 1 + VFP))
        vs <= 1'b0;
    else if(Vcnt == (LAF - 1 + VFP + VPW))
        vs <= 1'b1;
end

// 3) 顯示 bar 與 ball
always@(posedge clk_25M) begin
    // 顯示 bar
    if( (Vcnt >= up_pos) && (Vcnt <= down_pos) &&
        (Hcnt >= left_pos) && (Hcnt <= right_pos) )
    begin
        Red   <= 4'b1111;
        Green <= 4'b1111;
        Blue  <= 4'b1111;
    end
    // 顯示 ball
    else if( (Hcnt - ball_x_pos)*(Hcnt - ball_x_pos) + 
             (Vcnt - ball_y_pos)*(Vcnt - ball_y_pos) <= (ball_r * ball_r) )
    begin
        case(mode)
            2'd0: begin
                Red   <= (Hcnt[9:6] + Vcnt[9:6]) & 4'b1111;
                Green <= (Hcnt[5:3] + Vcnt[5:3]) & 4'b1111;
                Blue  <= (Hcnt[2:0] + Vcnt[2:0]) & 4'b1111;
            end
            2'd1: begin
                Red   <= Hcnt[7:4];
                Green <= Hcnt[7:4];
                Blue  <= Hcnt[7:4];
            end
        endcase
    end
    else begin
        Red   <= 4'b0000;
        Green <= 4'b0000;
        Blue  <= 4'b0000;
    end
end

// 4) 每逢 vs 正緣，更新 bar/ball 座標
always@(posedge vs) begin
    // 移動 bar，並檢查邊界
    if(to_left && left_pos > LEFT_BOUND) begin
        left_pos  <= left_pos  - bar_move_speed*4;
        right_pos <= right_pos - bar_move_speed*4;
    end
    else if(to_right && right_pos < RIGHT_BOUND) begin
        left_pos  <= left_pos  + bar_move_speed*4;
        right_pos <= right_pos + bar_move_speed*4;
    end

    // 限制 bar 不超過螢幕邊界
    if(left_pos < LEFT_BOUND) begin
        left_pos  <= LEFT_BOUND;
        right_pos <= LEFT_BOUND + (right_pos - left_pos);
    end
    if(right_pos > RIGHT_BOUND) begin
        right_pos <= RIGHT_BOUND;
        left_pos  <= RIGHT_BOUND - (right_pos - left_pos);
    end

    // 移動 ball
    if(v_speed == `UP)
        ball_y_pos <= ball_y_pos - bar_move_speed;
    else
        ball_y_pos <= ball_y_pos + bar_move_speed;

    if(h_speed == `RIGHT)
        ball_x_pos <= ball_x_pos + bar_move_speed;
    else
        ball_x_pos <= ball_x_pos - bar_move_speed;
end

// 5) 每逢 vs 負緣，檢查碰撞/邊界
always@(negedge vs) begin
    // 上邊界
    if(ball_y_pos <= UP_BOUND) begin
        v_speed <= `DOWN;
        lose    <= 0;
    end
    // 撞到 bar
    else if( (ball_y_pos >= (up_pos - ball_r)) &&
             (ball_x_pos <= right_pos) &&
             (ball_x_pos >= left_pos) )
    begin
        v_speed <= `UP;
    end
    // 球低於 bar 下緣
    else if(ball_y_pos >= down_pos && ball_y_pos < (DOWN_BOUND - ball_r)) begin
        lose <= 1;
    end
    // 下邊界
    else if(ball_y_pos >= (DOWN_BOUND - ball_r + 1)) begin
        v_speed <= `UP;
    end

    // 左右邊界
    if(ball_x_pos <= LEFT_BOUND) begin
        h_speed <= `RIGHT;
    end
    else if(ball_x_pos >= RIGHT_BOUND) begin
        h_speed <= `LEFT;
    end
end

endmodule

