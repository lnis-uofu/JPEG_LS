`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Mode Determination:
			0) Regular Mode - Q_1 != 0 || Q_2 != 0 || Q_3 !=0
			1) Run Mode - (Q_1 = Q_2 = Q_3 = 0, and x = a) && !EOL
			2) Run Interruption Mode - Q_1 = Q_2 = Q_3 = 0, and x != a
			3) EOL Interruption Mode - (Q_1 = Q_2 = Q_3 = 0, and x = a) && EOL(Do not need to encode sample if EOL and still meets run mode criteria) 	

		     Creates basis for prediction/residual Golumb encoding. Depending on gradient critieria a mode is selected.	
		     EOL breaks run mode and brings the same to run interruption mode. Run interruption with x != a takes presendence over x == a && EOL since even if its EOL the x != a would still
		     interrupt the run mode.
======================================================================================================================================================================================================
*/

module ModeDetermination #(parameter pixel_length = `pixel_length, quantizedQ_length = `quantizedQ_length, Q_length = `Q_length, mode_length = `mode_length)
			  (input [pixel_length - 1:0] a, input [pixel_length - 1:0] b, input [pixel_length - 1:0] c, input [pixel_length - 1:0] d, 
			   input [pixel_length - 1:0] x, input EOL, output reg [mode_length - 1:0] mode,
			   input clk, input reset, input start_enc);

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [Q_length - 1:0] Q_1;
	wire [Q_length - 1:0] Q_2;
	wire [Q_length - 1:0] Q_3;
	
	wire [mode_length - 1:0] previous_mode;
	wire [mode_length - 1:0] current_mode;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/

	defparam Previous_Mode.size = mode_length;
	Register Previous_Mode (.dataIn(current_mode), .dataOut(previous_mode), .clk(clk), .reset(reset), .enable(start_enc));

	GradientCalculation gradient (.a(a), .b(b), .c(c), .d(d), .Q_1(Q_1), .Q_2(Q_2), .Q_3(Q_3));

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign current_mode = mode;

	always @ (a or b or c or d or x or EOL or previous_mode) begin
		if (previous_mode == 1) begin
			if (x != a) mode = 2;
			else if (x == a && !EOL) mode = 1;
			else if (x == a && EOL) mode = 3;
		end
		else begin
			if (Q_1 == 0 && Q_2 == 0 && Q_3 == 0 && x == a && !EOL) mode = 1;
			else if (Q_1 == 0 && Q_2 == 0 && Q_3 == 0 && x != a) mode = 2;
			else if (EOL && Q_1 == 0 && Q_2 == 0 && Q_3 == 0 && x == a) mode = 3;
			else mode = 0;
		end
	end
endmodule
		
