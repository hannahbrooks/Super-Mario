
module drawStuff (clk, 
						drM, erM, drStage1, 
						done, address, 
						Mariox, Marioy, lvl1bkgx, lvl1bkgy,
						px, py);
						
	input clk, drM, erM, drStage1;
	output reg [14:0] address; 
	reg [7:0] ycountMario, xcountMario; 
	reg [7:0] ybkg1, xbkg1; 
	output reg done; 
	output reg [7:0] Mariox, Marioy, lvl1bkgx, lvl1bkgy;
	//output reg [7:0] y; 
	
	input [7:0] px, py; 
	initial address = 0; 
	initial done = 0; 
	

	always @(posedge clk) begin
		
		if (done) begin 
			done <= 0;
		end
		
		else if (drM) begin
				if (ycountMario < 10'd16 && xcountMario == 10'd11) begin
					ycountMario <= ycountMario + 1; 
					xcountMario <= 0; 
				end
				else if (xcountMario < 10'd12) begin
					xcountMario <= xcountMario + 1;
				end
				
				if ((xcountMario != 12) && (ycountMario != 16) && !done) begin
					Mariox <= xcountMario + px;
					Marioy <= ycountMario + py;
					address <= address + 1;
					//done <= 0; 
				end
				
				if(ycountMario == 10'd15 && xcountMario == 10'd11) begin
					done <= 1; 
					address <= 0;
					ycountMario <= 0; 
					xcountMario <= 0;
				end
			end	

		else if (drStage1 || erM) begin
			if (ybkg1 < 10'd120 && xbkg1 == 10'd159) begin
				ybkg1 <= ybkg1 +1; 
				xbkg1 <= 0; 
				end
			else if (xbkg1 < 10'd160) begin
				xbkg1 <= xbkg1 + 1;
			end
			
			if((ybkg1 != 10'd121) && (xbkg1 != 10'd160) && !done) begin
				address <= address + 1;
				lvl1bkgx <= xbkg1; 
				lvl1bkgy <= ybkg1; 
				//done <= 0; 
			end 

			if(ybkg1 == 10'd120 && xbkg1 == 10'd0) begin
				done <= 1;
				address <= 0;
				ybkg1 <= 0; 
				xbkg1 <= 0;
			end
		end
	end

	
endmodule 