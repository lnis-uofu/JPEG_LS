`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Context Gradient Mapping based on vectorized context (Q1, Q2, Q3). 
		     Special Vectors:
			1) (0, 0, 0) - Run mode
			2) 365 - Run interruption type with a == b
			3) 366 - Run Interruption Type with a != b
======================================================================================================================================================================================================
*/

module ContextGradient #(parameter quantizedQ_length = `quantizedQ_length, mode_length = `mode_length, mappedQ_length = `mappedQ_length)
			(input [quantizedQ_length - 1:0] D_1, input [quantizedQ_length - 1:0] D_2, input [quantizedQ_length - 1:0] D_3, input RIType, 
			 input [mode_length - 1:0] mode, output reg [mappedQ_length - 1:0] C_t, input sign);

/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/
	//Used to scalar mapping
	localparam [7:0] scalar_One = 8'd81;
	localparam [7:0] scalar_Two = 8'd9;

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [mappedQ_length - 1:0] C_t_1;
	wire [mappedQ_length - 1:0] C_t_2;
	wire [mappedQ_length - 1:0] C_t_3;
	wire [quantizedQ_length - 1:0] abs_Q_2;
	wire [quantizedQ_length - 1:0] abs_Q_3;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/
	reg [quantizedQ_length - 1:0] Q_1_sign;
	reg [quantizedQ_length - 1:0] Q_2_sign;
	reg [quantizedQ_length - 1:0] Q_3_sign;
	reg [mappedQ_length:0] C_t_accum_1;
	reg [mappedQ_length:0] C_t_accum_2;

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign abs_Q_2 = ~Q_2_sign + 1;
	assign abs_Q_3 = ~Q_3_sign + 1;

	assign C_t_1 = (scalar_One * Q_1_sign);
	assign C_t_2 = (Q_2_sign[quantizedQ_length - 1] == 1) ?  ({{4{abs_Q_2[quantizedQ_length - 1]}}, abs_Q_2} * scalar_Two) : (Q_2_sign * scalar_Two);
	assign C_t_3 = (Q_3_sign[quantizedQ_length - 1] == 1) ? abs_Q_3 : Q_3_sign;

	
	always @ (D_1 or D_2 or D_3 or RIType or mode or sign or C_t_1 or C_t_2 or C_t_3) begin
		//mode calculation for Regular mode, Context is between 1 to 364
		if (mode == 0) begin
			if (sign) begin
				Q_1_sign = ~D_1 + 1;
				Q_2_sign = ~D_2 + 1;
				Q_3_sign = ~D_3 + 1;
			end
			else begin
				Q_1_sign = D_1;
				Q_2_sign = D_2;
				Q_3_sign = D_3;
			end
		
			if(Q_2_sign[quantizedQ_length - 1] == 1) C_t_accum_1 = C_t_1 + (~C_t_2 + 1);
			else C_t_accum_1 = C_t_1 + C_t_2;

			if(Q_3_sign[quantizedQ_length - 1] == 1) C_t_accum_2 = C_t_accum_1 + (~C_t_3 + 1);
			else C_t_accum_2 = C_t_accum_1 + C_t_3;

			C_t = C_t_accum_2;
		end
		//Mode calculations for Run interruption mode
		else if ((mode == 2) && (RIType == 1'b0)) C_t = 365;
		else if ((mode == 2) && (RIType == 1'b1)) C_t = 366;
		//Run mode
		else C_t = 0;
	end

endmodule
				