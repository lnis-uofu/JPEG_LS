`timescale 1ns/1ns
`include "BiasCancellation.v"
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 5/1/2020
	DESCRIPTION:  Context Update performs the update of context variables for a specific context number. If the context was chosen it may introduce bias at a later date so bias cancellation
		      values are calculated (C). Values such as N and A are used in prediction residual and Golomb coding calculates so a precise definition of context values
		      is needed for accurate encoding. To hide pipeline stalls, along with provide the error modulo mapped value for bias cancellation purposes,
		      the error modulo reduction was put into this module. Error modulo reduction is a key component for encoding compression as we are able to reduce the size of the
		      TSGD residual via an alpha threshold.


		      The bit lengths of A[Q], B[Q], C[Q] and N[Q]/Nn[Q] for 8-bit images are 13, 9, 9 and 7

		      N: Number of occurances of a context (unsigned, 7 bits, 64 max)
		      A: Magnitude (abs value) of total quantized error (unsigned, 13 bits, max 8192)
		      B: Signed Quantized error value (signed, 8 bits, max 64) 
		      C: Bias Cancellation Value (signed, 8 bits, max 127(-128))
		      Nn: Run Interruption Count, incremented when Errval is less than 0 (unsigned, 7 bits, 64 max)
		   
		      NOTE: Since B is signed and the rest of the context variables are unsigned we need to be careful with comparison values. To compare we need to always treat B as positive
			    and if B is found negative (B[B_length] == 1) then we need to invert to positive in order to do the comparison and a placeholder value will indiciate that B was initially
			    negative.

			    B_N_Compare is checking 2 * B <= -N for MErrval used in Golomb Coding
			    N is normally from 0 < N <= 64 so to ensure that we can meet the range of -64 <= N <= 64 we need to extend N to 2's complement form with the correct length. In order
			    to do that we need to do -2^(n-1) <= N <= 2^(n-1) - 1, where n is number of bits. If n is 7 the max positive is 63 therefore if n is 8 we can meet this range.
			    N_length is 7 normally so we just need to do N_length + 1
======================================================================================================================================================================================================
*/
module Context_Update #(parameter A_length = `A_length, B_length = `B_length, C_length = `C_length, N_length = `N_length, Nn_length = `Nn_length,
				  modresidual_length = `modresidual_length, mode_length = `mode_length, N_Nn_Compare_length = `N_Nn_Compare_length,
				  Context_rw = `Context_rw, Q_length = `Q_length)
		       (input [A_length - 1:0] A, input [B_length - 1:0] B, input [C_length - 1:0] C, input [N_length - 1:0] N, input [Nn_length - 1:0] Nn,
		        input [modresidual_length - 1:0] errModulo, input resetFlag, input [mode_length - 1:0] mode, output [B_length - 1:0] B_new, output [Q_length - 1:0] Q_new,
			output [A_length - 1:0] A_new, output [C_length - 1:0] C_new, output reg [N_Nn_Compare_length - 1:0] N_Nn_Compare, input RIType, input [Q_length - 1:0] Q,
		        output [Nn_length - 1:0] Nn_New, output [N_length - 1:0] N_new, output reg B_N_Compare, output reg [Context_rw - 1:0] write_New_Context);

/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/
	localparam [7:0] alpha = 8'd255;
	localparam [6:0] half_alpha = 7'd128;


/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/
	wire [N_length + 1: 0] N_Twos_Comp;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/
	reg [B_length : 0] B_Shift;
	reg [B_length : 0] B_Twos_Comp;
	reg B_Is_Negative;
	reg [N_length + 1:0] N_Negative;


/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/
	BiasCancellation bias_cancel (.A(A), .B(B), .C(C), .N(N), .Nn(Nn), .B_new(B_new), .A_new(A_new), .C_new(C_new), .N_new(N_new), .mode(mode),
					.resetFlag(resetFlag), .errValue(errModulo), .RIType(RIType), .Nn_new(Nn_New));


/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign N_Twos_Comp = {1'b0, N};
	assign Q_new = Q;

	always @ (A or B or C or N or Nn or mode or resetFlag) begin
		B_Shift = 0;
		N_Negative = 0;
		B_N_Compare = 0;
		N_Nn_Compare = 0;
		write_New_Context = 0;

		if (mode == 0) begin
			B_Shift = B << 1;
			N_Negative = ~(N_Twos_Comp) +1;

			if(B_Shift[B_length] == 1) begin
				B_Is_Negative = 1;
				B_Twos_Comp = ~B_Shift + 1;
			end
			else begin
				B_Is_Negative = 0;
				B_Twos_Comp = B_Shift;
			end

			if(B_Is_Negative == 1 && (B_Twos_Comp >= N_Twos_Comp)) B_N_Compare = 1;
			else B_N_Compare = 0;

			write_New_Context  = 1;
		end
		else if (mode == 2) begin
			if((Nn << 1) < N) N_Nn_Compare = 0;
			else if ((Nn << 1) >= N) N_Nn_Compare = 1;
			else N_Nn_Compare = 2;

			write_New_Context = mode;
		end
	end

endmodule
