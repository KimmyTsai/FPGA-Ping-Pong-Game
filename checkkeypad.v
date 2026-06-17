`define TimeExpire      32'd2500
`define TimeExpire_KEY  32'd250000

module checkkeypad(
    input  clk,
    input  rst,
    input  [3:0] keypadCol,
    output reg [3:0] keypadRow,
    output [3:0] key_val,
    output reg [7:0] dot_row,
    output reg [7:0] dot_col
);

// 內部暫存與計時
reg [3:0]  keypadBuf;      
reg [31:0] keypadDelay;
reg [2:0]  row_count;
reg [31:0] clk_count;

// 將掃描結果輸出到 key_val
assign key_val = keypadBuf;

// 鍵盤掃描
always@(posedge clk or negedge rst) begin
    if(!rst) begin
        keypadRow   <= 4'b1110;
        keypadBuf   <= 4'b0000;
        keypadDelay <= 32'd0;
    end
    else begin
        if(keypadDelay == `TimeExpire_KEY) begin
            keypadDelay <= 32'd0;
            case({keypadRow,keypadCol})
                8'b1110_1110 : keypadBuf <= 4'h7;
                8'b1110_1101 : keypadBuf <= 4'h4;
                8'b1110_1011 : keypadBuf <= 4'h1;
                8'b1110_0111 : keypadBuf <= 4'h0;
                8'b1101_1110 : keypadBuf <= 4'h8;
                8'b1101_1101 : keypadBuf <= 4'h5;
                8'b1101_1011 : keypadBuf <= 4'h2;
                8'b1101_0111 : keypadBuf <= 4'ha;
                8'b1011_1110 : keypadBuf <= 4'h9;
                8'b1011_1101 : keypadBuf <= 4'h6;
                8'b1011_1011 : keypadBuf <= 4'h3;
                8'b1011_0111 : keypadBuf <= 4'hb;
                8'b0111_1110 : keypadBuf <= 4'hc;
                8'b0111_1101 : keypadBuf <= 4'hd;
                8'b0111_1011 : keypadBuf <= 4'he;
                8'b0111_0111 : keypadBuf <= 4'hf;
                default: keypadBuf <= 4'h7;
            endcase

            // 下一個掃描 Row
            case(keypadRow)
                4'b1110: keypadRow <= 4'b1101;
                4'b1101: keypadRow <= 4'b1011;
                4'b1011: keypadRow <= 4'b0111;
                4'b0111: keypadRow <= 4'b1110;
            endcase
        end
        else begin
            keypadDelay <= keypadDelay + 32'd1;
        end
    end
end

// dot-matrix 顯示 (若需要)

always@(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		dot_row<=8'b0;
		dot_col<=8'b0;
		row_count<=3'd0;
		clk_count<=32'd0;
	end
	else
	begin
		if(clk_count == `TimeExpire)
		begin
			clk_count<=32'd0;
			row_count<=row_count+3'd1;
			case(row_count)
				3'd0: dot_row<=8'b01111111;
				3'd1: dot_row<=8'b10111111;
				3'd2: dot_row<=8'b11011111;
				3'd3: dot_row<=8'b11101111;
				3'd4: dot_row<=8'b11110111;
				3'd5: dot_row<=8'b11111011;
				3'd6: dot_row<=8'b11111101;
				3'd7: dot_row<=8'b11111110;
			endcase
			
			case(keypadBuf)
			4'h0:
			begin
				case(row_count)
					3'd0: dot_col<=8'b11111111;
					3'd1: dot_col<=8'b00011001;
					3'd2: dot_col<=8'b00011001;
					3'd3: dot_col<=8'b00101001;
					3'd4: dot_col<=8'b00101001;
					3'd5: dot_col<=8'b01001001;
					3'd6: dot_col<=8'b10001111;
					3'd7: dot_col<=8'b00000000;
				endcase
			end
			4'h7:
			begin
				case(row_count)
					3'd0: dot_col<=8'b00000000;
					3'd1: dot_col<=8'b00000000;
					3'd2: dot_col<=8'b00000000;
					3'd3: dot_col<=8'b00000000;
					3'd4: dot_col<=8'b00000000;
					3'd5: dot_col<=8'b00000000;
					3'd6: dot_col<=8'b00000000;
					3'd7: dot_col<=8'b00000000;
				endcase
			end
			4'hf:
			begin
				case(row_count)
					3'd0: dot_col<=8'b01111111;
					3'd1: dot_col<=8'b01000000;
					3'd2: dot_col<=8'b01000000;
					3'd3: dot_col<=8'b01000000;
					3'd4: dot_col<=8'b01000000;
					3'd5: dot_col<=8'b01000000;
					3'd6: dot_col<=8'b01000000;
					3'd7: dot_col<=8'b01000000;
				endcase
			end
			endcase
		end
		else
		begin
			clk_count<=clk_count+32'd1;
		end
	end
end

endmodule


