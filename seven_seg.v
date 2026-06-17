`timescale 1ns / 1ps
`include "Definition.h"
    input clk,
	 input rst,
	 input lose,
//    output reg [3:0] select,
    output reg [6:0] seg1,
	 output reg [6:0] seg2,
	 output reg [6:0] seg3,
	 output reg [6:0] seg4
    );

reg [6:0] num0 = 4'b0;

reg [13:7] num1 = 4'b0;

reg [20:14] num2 = 4'b0;

reg [27:21] num3 = 4'b0;

reg [1:0] cnt = 0;

reg [6:0] clk_cnt = 0;
reg sclk = 0;

always@(posedge clk)
begin
	if(clk_cnt == 127)
	begin
		sclk <= ~sclk;
		clk_cnt <= 0;
	end
	else
		clk_cnt <= clk_cnt + 1;
end



// Flush data each time you lose

always @(posedge lose or posedge rst) 
begin
    if (rst) 
    begin
        num0 <= 0;
        num1 <= 0;
        num2 <= 0;
        num3 <= 0;
    end 
    else if (lose) 
    begin
        if (num0 == 9) 
        begin
            num0 <= 0;
            if (num1 == 9) 
            begin
                num1 <= 0;
                if (num2 == 9) 
                begin
                    num2 <= 0;
                    if (num3 == 9)
                        num3 <= 0;
                    else
                        num3 <= num3 + 1;
                end 
                else 
                    num2 <= num2 + 1;
            end 
            else 
                num1 <= num1 + 1;
        end 
        else 
            num0 <= num0 + 1;
    end
end



always@(posedge lose or negedge rst) begin
	case (num0)
		4'b0000 : seg1 <= 7'b1000000;
		4'b0001 : seg1 <= 7'b1111001;
		4'b0010 : seg1 <= 7'b0100100;
		4'b0011 : seg1 <= 7'b0110000;
		4'b0100 : seg1 <= 7'b0011001;
		4'b0101 : seg1 <= 7'b0010010;
		4'b0110 : seg1 <= 7'b0000011;
		4'b0111 : seg1 <= 7'b1111000;
		4'b1000 : seg1 <= 7'b0000000;
		4'b1001 : seg1 <= 7'b0011000;
		default : ;
		endcase
	case (num1)
		4'b0000 : seg2 <= 7'b1000000;
		4'b0001 : seg2 <= 7'b1111001;
		4'b0010 : seg2 <= 7'b0100100;
		4'b0011 : seg2 <= 7'b0110000;
		4'b0100 : seg2 <= 7'b0011001;
		4'b0101 : seg2 <= 7'b0010010;
		4'b0110 : seg2 <= 7'b0000011;
		4'b0111 : seg2 <= 7'b1111000;
		4'b1000 : seg2 <= 7'b0000000;
		4'b1001 : seg2 <= 7'b0011000;
		default : ;
		endcase
	case (num2)
		4'b0000 : seg3 <= 7'b1000000;
		4'b0001 : seg3 <= 7'b1111001;
		4'b0010 : seg3 <= 7'b0100100;
		4'b0011 : seg3 <= 7'b0110000;
		4'b0100 : seg3 <= 7'b0011001;
		4'b0101 : seg3 <= 7'b0010010;
		4'b0110 : seg3 <= 7'b0000011;
		4'b0111 : seg3 <= 7'b1111000;
		4'b1000 : seg3 <= 7'b0000000;
		4'b1001 : seg3 <= 7'b0011000;
		default : ;
		endcase
	case (num3)
		4'b0000 : seg4 <= 7'b1000000;
		4'b0001 : seg4 <= 7'b1111001;
		4'b0010 : seg4 <= 7'b0100100;
		4'b0011 : seg4 <= 7'b0110000;
		4'b0100 : seg4 <= 7'b0011001;
		4'b0101 : seg4 <= 7'b0010010;
		4'b0110 : seg4 <= 7'b0000011;
		4'b0111 : seg4 <= 7'b1111000;
		4'b1000 : seg4 <= 7'b0000000;
		4'b1001 : seg4 <= 7'b0011000;
		default : ;
		endcase
	end
endmodule 
