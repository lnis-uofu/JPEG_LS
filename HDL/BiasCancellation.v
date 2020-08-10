`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 5/1/2020
	DESCRIPTION:  Bias Cancellation is the computional engine for the updating of Context parameters based on various conditons.


		      The bit lengths of A[Q], B[Q], C[Q] and N[Q] for 8-bit images are 13, 7, 8 and 7

		      N: Number of occurances of a context (unsigned, 7 bits, 64 max)
		      A: Magnitude (abs value) of total quantized error (unsigned, 14 bits, max 8192 (128*64))
		      B: Signed Quantized error value (signed, 8 bits, max -63 or 0)
		      C: Bias Cancellation Value (signed, 8 bits, max )
		      Nn: Negiatve threshold counter for Run Interruption coding (unsigned, 7 bits, max 64)
		   
======================================================================================================================================================================================================
*/
module BiasCancellation #(parameter A_length = `A_length, B_length = `B_length, C_length = `C_length, N_length = `N_length, Nn_length = `Nn_length, mode_length = `mode_length,
				    modresidual_length = `modresidual_length)
			(input [A_length - 1:0] A, input [B_length - 1:0] B, input [C_length - 1:0] C, input [N_length - 1:0] N, input [Nn_length - 1:0] Nn, 
			 input resetFlag, input [mode_length - 1:0] mode, input [modresidual_length - 1:0] errValue,  input RIType,
			 output reg [B_length - 1:0] B_new, output reg [A_length - 1:0] A_new, output reg [C_length - 1:0] C_new, output reg [N_length - 1:0] N_new, output reg [Nn_length - 1:0] Nn_new);

/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/
	localparam [7:0] MIN_C = 8'b10000000; //-128
	localparam [7:0] MAX_C = 8'd127;


/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/
	wire [modresidual_length - 1:0] absErrValue;
	wire [B_length + 1:0] B_Twos_Comp;
	wire [B_length + 1:0] BShiftValue;
	wire [B_length + 1:0] B_Shift_Negative;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/
	reg [N_length - 1:0] N_After_Flag;
	reg [Nn_length - 1:0] Nn_After_Flag;
	reg [B_length + 1:0] B_After_Flag;
	reg [C_length - 1:0] C_After_Flag;

	reg [B_length + 1:0] B_Accum;
	reg [A_length - 1:0] A_Accum;

	reg [B_length + 1:0] B_Added_With_N;
	reg [B_length + 1:0] B_Sub_With_N;

	reg [Nn_length - 1:0] Nn_Accum;
	reg [N_length - 1:0] N_Div;

	reg [B_length + 1:0] B_Complement_1;
	reg [B_length + 1:0] B_Complement_2;
	reg B_Is_Negative_1, B_Is_Negative_2; 
	reg B_N_Compare_1, B_N_Compare_2;
	reg [N_length - 1:0] N_Negative_1;
	reg [N_length - 1:0] N_Negative_2;


/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/	
	assign absErrValue = (errValue[7]) ? (~errValue) + 1 : errValue;
	assign B_Twos_Comp = ~B_Accum + 1;
	assign BShiftValue = (1 + B_Twos_Comp) >> 1;
	assign B_Shift_Negative = ~BShiftValue + 1;
	
	always @ (A or B or C or N or Nn or resetFlag or mode or errValue or RIType or B_Shift_Negative) begin
		B_Added_With_N = 0;
		B_Sub_With_N = 0;
		B_Complement_1 = 0;
		B_Is_Negative_1 = 0;
		B_N_Compare_1 = 0;
		N_Negative_1 = 0;
		B_Complement_2 = 0;
		B_Is_Negative_2 = 0;
		B_N_Compare_2 = 0;
		N_Negative_2 = 0;
		N_Negative_1 = 0;
		B_After_Flag = 0;
		C_After_Flag = 0;
		N_After_Flag = 0;
		Nn_After_Flag = 0;
		B_Accum = 0;
		A_Accum = 0;
		Nn_Accum = 0;
		B_new = 0;
		C_new = 0;
		N_new = 0;
		Nn_new = 0;

		if (mode == 0) begin
			//update B which is the accumulated residual
			B_Accum = {{2{B[B_length - 1]}}, B} + {errValue[7], errValue}; //B_accum can be negative or positve, max positive is 255 therefore it will need to be a signed value of 9 bits
			A_Accum = A + absErrValue; //update A which is the accumulated sum of absolute value of residuals

			if (resetFlag) begin
				N_After_Flag = N >> 1; // N/2
				A_new = A_Accum >> 1; // A/2
				if (B_Accum[B_length + 1] == 0) B_After_Flag = B_Accum >> 1; // B/2
				else B_After_Flag = B_Shift_Negative;
			end
			else begin
				N_After_Flag = N;
				A_new = A_Accum;
				B_After_Flag = B_Accum;
			end

			N_new = N_After_Flag + 1;
			//N_Negative_1 = ~(N_new) +1;

			if(B_After_Flag[B_length + 1] == 1) begin
				B_Complement_1 = ~B_After_Flag + 1;
				B_Is_Negative_1 = 1;
			end
			else begin
				B_Complement_1 = B_After_Flag;
				B_Is_Negative_1 = 0;
			end

			if(B_Is_Negative_1 == 1 && (B_Complement_1 >= N_new)) B_N_Compare_1 = 1;
			else B_N_Compare_1 = 0;
			
		
			//bias cancellation for next pixel
			if (B_N_Compare_1 == 1) begin
				B_Added_With_N = B_After_Flag + N_new; 
				if (C[C_length - 1] == 0 || C > MIN_C) C_new = C - 1;
				else C_new = C;

				//N_Negative_2 = ~(N_new) +1;

				if(B_Added_With_N[B_length + 1] == 1) begin
					B_Complement_2 = ~B_Added_With_N + 1;
					B_Is_Negative_2 = 1;
				end
				else begin
					B_Complement_2 = B_Added_With_N;
					B_Is_Negative_2 = 0;
				end

				if(B_Is_Negative_2 == 1 && (B_Complement_2 >= N_new)) B_N_Compare_2 = 1;
				else B_N_Compare_2 = 0;
				
				if (B_N_Compare_2 == 1) B_new = (~N_new + 1) + 1  ;
				else B_new = B_Added_With_N;
			end
			else if (B_After_Flag[B_length + 1] == 0 && B_After_Flag != 0) begin
				B_Sub_With_N = B_After_Flag + (~N_new + 1);

				if (C < MAX_C || C[C_length - 1] == 1) C_new = C + 1;
				else C_new = C;

				if (B_Sub_With_N[B_length + 1] == 0 && B_Sub_With_N != 8'b0) B_new = 0; 
				else B_new = B_Sub_With_N;
			end
			else begin
				B_new = B_After_Flag;
				C_new = C;
			end
			
		end
		else if (mode == 2) begin		
			if(errValue [modresidual_length - 1])  Nn_Accum = Nn + 1;
			else Nn_Accum = Nn;
			A_Accum = A + (absErrValue - RIType);
			
			if (resetFlag) begin
				N_Div = N >> 1; // N/2
				A_new = A_Accum >> 1; // A/2
				Nn_new = Nn_Accum >> 1; //Nn/2
			
			end
			else begin
				N_Div = N;
				A_new = A_Accum;
				Nn_new = Nn_Accum;
			end
			N_new = N_Div + 1;
		end
		else begin
			A_new = A;
			B_new = B;
			C_new = C;
			N_new = N;
			Nn_new = Nn;
		end
	end

endmodule
