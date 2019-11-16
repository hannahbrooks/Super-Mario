
module control_FSM	(
							clk, reset, go, right,
							resetAddress, drM, erM, drStage1, moveRight, 
							done, 
							writeEn, enable);
							
	input clk, reset, enable, go, right; 
	//input [7:0] ycount, xcount; 
	reg keepGoing; 
	
	input done; 
	output reg resetAddress, drM, erM, drStage1, writeEn, moveRight; 
		
	reg [10:0] current_state, next_state; 
	
	localparam	nothing			= 10'd0,
					drawstage1 		= 10'd1,
					waitmario		= 10'd2,
					drawmario		= 10'd3,
					erasemarioWait	= 10'd4,
					erasemario		= 10'd5; 
					
	always @(*)
	begin: state_table 
		case(current_state)
			nothing: next_state = enable ? nothing : drawstage1; //wait state 
			drawstage1: //draws level one 
			begin
				if (done)
					next_state = waitmario; 
				else 
					next_state = drawstage1;
			end
			
			waitmario: next_state = ~enable ? waitmario : drawmario;
			
			drawmario: //draws mario
			begin
				if (done && right && go)
					next_state = erasemario;
				else 
					next_state = drawmario; 
			end
			
			erasemarioWait: next_state = right ? drawmario : drawmario;
			
			erasemario:
			begin
				if(done && go) 
					next_state = erasemarioWait; 
				else 
					next_state = erasemario; 
			end

			default: next_state = drawstage1;
		endcase
	end
	
	always@(posedge clk) 
	begin: logic
	
		drM = 0;
		writeEn = 0; 
		drStage1 = 0;
		resetAddress = 0; 
		moveRight = 0; 
		erM = 0;
		keepGoing = 0;
		
		case(current_state)
		
		nothing: begin 
			resetAddress = 1;
			writeEn = 0;	
		end
		drawstage1: begin
			drStage1 = 1;
			writeEn = 1; 
		end
		waitmario: begin 
			writeEn = 0; 
			resetAddress = 1; 
		end
		drawmario: begin
			drM = 1; 
			writeEn = 1; 
		end
		erasemario: begin
			erM = 1;
			writeEn = 1;
		end
		erasemarioWait: begin
			keepGoing = 1;
		end
		
		endcase
	end
	
	always@(posedge clk)
    begin: state_FFs
		if (!reset)
			current_state <= drawstage1;
//		else if (right) begin 
//			if (done && right && erM) 
//				current_state <= erasemarioWait;
//			else if (done && right && keepGoing && go) 
//				current_state <= drawmario;
//			else 
//				current_state <= erasemario;
//		end
		else
        current_state <= next_state; 
    end 

endmodule 