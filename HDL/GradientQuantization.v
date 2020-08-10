`timescale 1ns/1ns
`include "GradientCalculation.v"
`include "ContextSign.v"
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Quantization of gradients based on thresholds. TSGD tails merged and sign of context determined. Quantized Q is signed.
======================================================================================================================================================================================================
*/

module GradientQuantization #(parameter pixel_length = `pixel_length, quantizedQ_length = `quantizedQ_length, Q_length = `Q_length)
			     (input [pixel_length - 1:0] a, input [pixel_length - 1:0] b, input [pixel_length - 1:0] c, input [pixel_length - 1:0] d,
			      output reg [quantizedQ_length - 1:0] D_1, output reg [quantizedQ_length - 1:0] D_2, output reg [quantizedQ_length - 1:0] D_3, output sign);


/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/
	localparam T1 = 6'd3;
	localparam T2 = 6'd7;
	localparam T3 = 6'd21;
	/*localparam Negative_T1 = 6'd61;
	localparam Negative_T2 = 6'd57;
	localparam Negative_T3 = 6'd43;
	*/

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [Q_length - 1:0] Q_1;
	wire [Q_length - 1:0] Q_2;
	wire [Q_length - 1:0] Q_3;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	reg [Q_length - 1:0] abs_Q_1;
	reg [Q_length - 1:0] abs_Q_2;
	reg [Q_length - 1:0] abs_Q_3;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION DECLARATION
======================================================================================================================================================================================================
*/

	GradientCalculation gradient (.a(a), .b(b), .c(c), .d(d), .Q_1(Q_1), .Q_2(Q_2), .Q_3(Q_3));
	ContextSign context_sign (.Q_1(Q_1), .Q_2(Q_2), .Q_3(Q_3), .sign(sign));

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign Q_1_is_negative = Q_1[Q_length - 1] == 1;
	assign Q_2_is_negative = Q_2[Q_length - 1] == 1;
	assign Q_3_is_negative = Q_3[Q_length - 1] == 1;

	//ENSURED PARALLEL LOGIC HERE (AVOID PRIORITY)
	//need to account for positive and negative
	always @ (a or b or c or d) begin
		//2's complement here (needed for all context numbers)
		if (Q_1_is_negative) abs_Q_1 = (~Q_1) + 1;
		else abs_Q_1 = Q_1;

	
		if (abs_Q_1 == 0) D_1 = Q_1;
		else begin
			if (Q_1_is_negative) begin
				if (abs_Q_1 == (T1-2) || abs_Q_1 == (T1-1)) D_1 = 15; // -1
				else if (abs_Q_1 >= T1 && abs_Q_1 <= (T2-1)) D_1 = 14; //-2
				else if (abs_Q_1 >= T2 && abs_Q_1 <= (T3-1)) D_1 = 13; // -3
				else D_1 = 12; //-4
			end
			else begin
				if (abs_Q_1 == (T1-2) || abs_Q_1 == (T1-1)) D_1 = 1;
				else if (abs_Q_1 >= T1 && abs_Q_1 <= (T2-1)) D_1 = 2;
				else if (abs_Q_1 >= T2 && abs_Q_1 <= (T3-1)) D_1 = 3; 
				else D_1 = 4; 
			end
		end
	
		if (Q_2_is_negative) abs_Q_2 = (~Q_2) + 1;
		else abs_Q_2 = Q_2;

		if (abs_Q_2 == 0) D_2 = Q_2;	
		else begin
			if (Q_2_is_negative) begin
				if (abs_Q_2 == (T1-2) || abs_Q_2 == (T1-1)) D_2 = 15; // -1
				else if (abs_Q_2 >= T1 && abs_Q_2 <= (T2-1)) D_2 = 14; //-2
				else if (abs_Q_2 >= T2 && abs_Q_2 <= (T3-1)) D_2 = 13; // -3
				else D_2 = 12; //-4
			end
			else begin
				if (abs_Q_2 == (T1-2) || abs_Q_2 == (T1-1)) D_2 = 1;
				else if (abs_Q_2 >= T1 && abs_Q_2 <= (T2-1)) D_2 = 2;
				else if (abs_Q_2 >= T2 && abs_Q_2 <= (T3-1)) D_2 = 3; 
				else D_2 = 4; 
			end
		end

		if (Q_3_is_negative) abs_Q_3 = (~Q_3) + 1;
		else abs_Q_3 = Q_3;

		if (abs_Q_3 == 0) D_3 = Q_3;
		else begin
			if (Q_3_is_negative) begin
				if (abs_Q_3 == (T1-2) || abs_Q_3 == (T1-1)) D_3 = 15; // -1
				else if (abs_Q_3 >= T1 && abs_Q_3 <= (T2-1)) D_3 = 14; //-2
				else if (abs_Q_3 >= T2 && abs_Q_3 <= (T3-1)) D_3 = 13; // -3
				else D_3 = 12; //-4
			end
			else begin
				if (abs_Q_3 == (T1-2) || abs_Q_3 == (T1-1)) D_3 = 1;
				else if (abs_Q_3 >= T1 && abs_Q_3 <= (T2-1)) D_3 = 2;
				else if (abs_Q_3 >= T2 && abs_Q_3 <= (T3-1)) D_3 = 3; 
				else D_3 = 4; 
			end
		end
	end

endmodule
