
module marioReg 	(updateX, updateY, 
						drM, drStage1, right, LEDR); 
						
	output reg [7:0] updateX, updateY; 
	input drM, drStage1; 
	input right; 
	output LEDR; 
	reg [7:0] initialx; 
	reg [7:0] initialy;
	
	initial initialx = 10'd4; 
	initial initialy = 10'd89;
	
	reg check; 
	initial check = 0;
	reg update; 
	initial update = 0; 
	reg stop;
	initial stop = 1; 
	
	always@(*) begin
		if (drStage1 && stop) begin
			updateX = initialx; 
			updateY = initialy; 
			stop = 0; 
			//update = 1; 
		end
		else if (drM && right) begin
			updateX = initialx + 8'b00000001;
			update = 1; 
						check = 1; 
		end
		
		else if (update) begin
			initialx = updateX;
			initialy = updateY; 
			update = 0; 
		end
	end
	
	assign LEDR = check; 
endmodule 	