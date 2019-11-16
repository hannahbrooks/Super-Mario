//Creators: Hannah Brooks, Wasif Butt
//if you steal this ill eat ur ass ©

module project
	(
		CLOCK_50,						//	On Board 50 MHz
		SW,						
		KEY,								// On Board Keys
		LEDR,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   							//	VGA Blue[9:0]
	);

	input			CLOCK_50;			//	50 MHz
	input	[3:0]	KEY;					
	input [9:0] SW;
	output [9:0] LEDR; 
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;					//	VGA Blue[7:0]
	
	//reset
	wire resetn;
	assign resetn = KEY[0];
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	//****************************************************************************************************
	assign LEDR[6:0] = px [6:0]; 
	//assign LEDR[9] = done; 
	assign LEDR[8] = drM; 
	assign LEDR[7] = drStage1;
	
	//movement input wires
	wire right, left, up; 
	assign right = ~KEY[1]; 
	
	//VGA input controlling wires 
	reg [23:0] colour;
	reg [7:0] x, y;
	//wire [6:0] y;
	
	//draw controls
	wire resetAddress, writeEn;
	wire drM, drStage1; //draw
	wire erM; //erase 
	wire [23:0] marioColour, stage1Colour; //colours
	wire [7:0] Mariox, Marioy, lvl1bkgx, lvl1bkgy; //x y controls 
	wire moveRight, moveLeft, moveUp; //draw in direction
	wire [7:0] px, py; 
	
	//counters 
	//wire [7:0] xcount, ycount; 
	wire done; 
	reg [14:0] address; 
	wire [14:0] outAddress; 
	
	//rate divider enable 
	wire go; 
	
	//accessing memories to draw images
	mario drawMario(address, CLOCK_50, marioColour);
	test_bb stage1(address, CLOCK_50, stage1Colour);
	
	always @(*) begin
		if (resetAddress) 
			address <= 0; 
		else 
			address <= outAddress;
			
			
		if(drM) begin
			if (marioColour == 24'b111111111111111111111111) begin
				address <= outAddress + (py*10'd120) + px; 
				colour <= stage1Colour; 
			end
			else begin
				colour <= marioColour;
				address <= outAddress; 
			end
				
			x <= Mariox;
			y <= Marioy;
		end
		else if (drStage1 || erM)  begin
			colour <= stage1Colour;
			x <= lvl1bkgx;
			y <= lvl1bkgy;
		end
//		else if (erM) begin
//			colour <= stage1Colour;
//			x <= Mariox;
//			y <= Marioy;
//		end
	end
	
	//FSM/control
	control_FSM yeet(CLOCK_50, resetn, go, right, resetAddress, drM, erM, drStage1, moveRight, done, writeEn, KEY[2]); 
	
	//datapath
	drawStuff fuckme(CLOCK_50, drM, erM, drStage1, done, outAddress, Mariox, Marioy, lvl1bkgx, lvl1bkgy, px, py);
	
	//movement registers 
	marioReg iwantdie(px, py, drM, drStage1, right, LEDR[9]); 
						
	//refresh rate divider 
	rateDivider yote(go, CLOCK_50); 
	
	//*****************************************************************************************************
	
	/*reg [4:0] current_state, next_state; 
	reg enable; 
	
	assign LEDR[7:0] = ycount; 
	
	/*localparam draw_mario = 69'd1,
				 waitYeet 	= 69'd2; 
	
	always @(*)
	begin: state_table 
		case(current_state)
			waitYeet: next_state = KEY[1] ? waitYeet : draw_mario; 
			draw_mario: begin
				if (ycount < 69'd16)
					next_state = draw_mario; 
				else 
					next_state = waitYeet; 
			end
			default: next_state = waitYeet;
		endcase 
	end
	
	always @(posedge CLOCK_50) 
		begin: logic
	
		enable = 0;
		
		case (current_state)
			
			waitYeet: begin
				enable = 0;
			end
			draw_mario: begin
				enable = 1; 
				end
		endcase 
		end
	
	always@(posedge CLOCK_50)
    begin: state_FFs
        current_state <= next_state; 
    end // state_FFS*/
	
	/*wire ld_x, ld_y, ld_r,ld_b; 
	reg [3:0] counter; 
	reg [7:0] xcounter;
	
	wire marioDone;
	wire [7:0] x_mario;
	wire [6:0] y_, y_mario;
	reg marioEn;
	reg [4:0] current_Draw, next_Draw;
	
	assign marioAddress = (y*15'd160) + x;
	mario marioROM_inst(marioAddress, CLOCK50, colourMario); // instantiate mario, need to rename something unique like marioROM i think
	drawMario drawMario_inst(.clk(CLOCK50), .enable(marioEn), .xCount(x_mario[4:0]), .yCount(y_mario[4:0]), .address(marioAddress), .done(marioDone));
	
	parameter RESET=4'b0000;
	parameter DISPLAY_MARIO=4'b0011;

	// control c0(CLOCK_50, resetn, KEY[3], KEY[1], KEY[2], counter, ld_x, ld_y, writeEn, ld_b, xcounter); 
	//datapath d0(CLOCK_50, resetn, SW[6:0], ld_y, ld_x, writeEn, ld_b, x, y, counter, colour, SW[9:7], xcounter);
	
	always @ (*)
	begin
	case (current_Draw)
		DISPLAY_MARIO:		begin
						if (marioEn) begin
							if (marioDone) begin
								next_Draw <= DISPLAY_MARIO;
								end
							else next_Draw <= DISPLAY_MARIO;
							end
						end

	endcase
	end
	
	always @ (posedge CLOCK_50)
	begin
		if (current_Draw==DISPLAY_MARIO) begin
			marioEn <= 1;
			end
		else marioEn <= 0;
		if (current_Draw == DISPLAY_MARIO) begin
			if (marioEn) begin
				x <= x_mario;
				y <= y_mario;
				colour <= colourMario;
				writeEn <= marioEn;
			end
			end
	end
	
	/*always @ (posedge CLOCK_50)				
	begin
		if (current_Draw == DISPLAY_MARIO) begin
			if (marioEn) begin
				x <= x_mario;
				y <= y_mario;
				colour <= colourMario;
				writeEn <= marioEn;
			end
			end
		end*/

	

	
endmodule

/*module control (clk, enable, ycounter, xcounter); 
	input clk, enable, 
	localparam 	 setXwait   = 5'd1,
					 setX 		= 5'd2,
                setY       = 5'd3,
                setYwait   = 5'd4,
                Plot		   = 5'd6,
					 setBlack   = 5'd7,
					 blackLoop  = 5'd8,
					 Wait  		= 5'd9;
	
	reg [3:0] current_state, next_state; 
	
	always@(*)
   begin: state_table 
			case (current_state)
				Wait: next_state = loadP ? setXwait : Wait; 
				setXwait : begin
					if (loadX == 0)
						next_state = setX; 
					else if (loadP == 0)
						next_state = setY; 
					else 
						next_state = setXwait; 
				end
				setX: begin
					if (loadP == 0)
						next_state = setY; 
					else 
						next_state = setX;  
				end
				setY: begin
					next_state = setYwait; 
				end
				setYwait: begin 
					next_state = loadP ? Plot : setYwait; 
				end
				Plot: begin
					if (counter == 4'b1111)
						next_state = Wait; 
					else 
						next_state = Plot; 
				end
				setBlack: begin 
					next_state = loadB ? blackLoop : setBlack; 
				end
				blackLoop: begin
					if(xcounter == 8'd160) 
						next_state = Wait; 
					else 
						next_state = blackLoop; 
				end
			default: next_state = Wait; 
        endcase
    end // state_table
	 
	always@(posedge clk)
	begin: logic
	
		ld_x = 0;
		ld_y = 0;
		ld_r = 0;
		ld_b = 0;
		
		case (current_state)
			
			setX: begin
				ld_r = 0;
				ld_y = 0;
				ld_x = 1;
			end
			
			setY: begin
				ld_r = 0;
				ld_x = 0;
				ld_y = 1; 
			end
			
			Plot: begin 
				ld_r = 1; 
			end
			setBlack: begin 
				ld_b = 1; 
				ld_r = 1; 
			end
			
		endcase 
	end
	
	 // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= setXwait;
			else if (!loadB)
				current_state <= setBlack; 
        else
            current_state <= next_state;
    end // state_FFS
endmodule

/*module datapath (
	input clk, resetn,
	input [6:0] datain,
	input ld_y, ld_x, ld_r, ld_b,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [3:0] counter,
	output reg [2:0] colour,
	input [2:0] inC,
	output reg [7:0] xcounter
	);
	
	reg [7:0] px;
	reg [6:0] py; 
	reg [7:0] ycounter;
	initial ycounter = 8'b0;
	
	always @(posedge clk) begin		
		if (!resetn) begin
			px <= 0;
			py <= 0;
			counter <= 0;
			colour <= 0; 
			x <= 0;
			y <= 0; 
		end
		else begin
			if (ld_x) begin
				px <= {1'b0, datain[6:0]};
				counter <= 0;
			end
			else if (ld_y) begin 
				py <= datain[6:0];
				counter <= 0;
			end
			else if (ld_b) begin
				if (ycounter == 8'd120) begin
					xcounter <= xcounter + 1; 
					ycounter <= 8'd0; 
				end
				else if (ycounter < 8'd120)
					ycounter <= ycounter + 1; 
					
				x <= xcounter; 
				y <= ycounter; 
				colour <= 3'b000; 
			end
			else if (ld_r && !ld_b) begin 
				if (counter < 4'b1111)
					counter <= counter + 1; 
				else if (counter == 4'b1111) 
					counter <= 0; 
					
				x <= px + counter[1:0];
				y <= py + counter[3:2];
				colour <= inC; 
			end
		end 
	end
	
	 
 endmodule */

/*module drawMario (clk, enable, xCount, yCount, address, done);
	input clk;
	input enable;
	output reg done;
	output 	reg [4:0]xCount;
	output 	reg [4:0]yCount;
	output reg [9:0]address;	
	
	initial begin
	xCount = 0;
	yCount = 0;
	address = 2;
	end
	
	always @ (posedge clk)
	begin
	if (enable) begin
		if (xCount < 5'd12)
				xCount <= xCount +1;
				if (yCount == 5'd16) done<=1;
		else if (xCount==5'd12) begin
			if (yCount<5'd16) begin
				xCount<=0;
				yCount<=yCount+1;
				end
			end
		address <= address+10'b1;
		end
	else begin 
		done <= 0; 
		xCount = 0;
		yCount = 0;
		address = 2;
		end
	end
endmodule*/


