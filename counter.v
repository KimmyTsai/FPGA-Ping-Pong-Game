module counter(clk,reset,d_clk,d_clk2);
input clk,reset;
output reg d_clk,d_clk2;
reg [31:0] count; 
reg [31:0] count2; 
always @(posedge clk or negedge reset)
begin
 if(!reset)
 begin
  count = 32'd0;
  d_clk = 1'b0;
 end
 else
 begin
  if(count == 32'd250000)
  begin
   d_clk = ~d_clk;
   count = 32'd0;
  end
  else
  begin
   count <= count + 32'd1;
  end
 end
end

always @(posedge clk)
 begin
  if(count2 == 32'd250000)
  begin
   d_clk2 = ~d_clk2;
   count2 = 32'd0;
  end
  else
  begin
   count2 <= count2 + 32'd1;
  end
 end
endmodule