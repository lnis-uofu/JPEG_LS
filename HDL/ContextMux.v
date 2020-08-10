`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: This module allows the selection of the context variables dependent on the context variable value (Q). If the context is the same as the subsequent context in order to hide
		     stalls the previous context evaluated variables (feedback variables) will need to be passed back through for evaluation. In this situation these feedback variables are also fed
		     back to the context memory and instead of reading the memory we write the memory with the feedback variables.
======================================================================================================================================================================================================
*/
module ContextMux #(parameter Q_length = `Q_length, A_length = `A_length, B_length = `B_length, C_length = `C_length, N_length = `N_length, Nn_length = `Nn_length)
		   (input [Q_length - 1:0] Q_Feedback, input [A_length - 1:0] A_Feedback, input [B_length - 1:0] B_Feedback, input [C_length - 1:0] C_Feedback, 
		    input [N_length - 1:0] N_Feedback, input [Nn_length - 1:0] Nn_Feedback, input [Q_length - 1:0] Q_4, input [A_length - 1:0] A_4, 
		    input [B_length - 1:0] B_4, input [C_length - 1:0] C_4, input [N_length - 1:0] N_4, input [Nn_length - 1:0] Nn_4, output reg  [Nn_length - 1:0] Nn_Select_4,
	            output reg [Q_length - 1:0] Q_Select_4, output reg [A_length - 1:0] A_Select_4, output reg [B_length - 1:0] B_Select_4, 
		    output reg [C_length - 1:0] C_Select_4, output reg [N_length - 1:0] N_Select_4, input [Q_length - 1:0] Q_Updated, 
		    input [A_length - 1:0] A_Updated, input [B_length - 1:0] B_Updated, input [C_length - 1:0] C_Updated, input [N_length - 1:0] N_Updated,
		    input [Nn_length - 1:0] Nn_Updated, input useFeedbackValues);

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/
		
	always @ (*) begin
		if (Q_Feedback == Q_4) begin
			Q_Select_4 = Q_Feedback;
			A_Select_4 = A_Feedback;
			B_Select_4 = B_Feedback;
			C_Select_4 = C_Feedback;
			N_Select_4 = N_Feedback;
			Nn_Select_4 = Nn_Feedback;
		end 
		else if (useFeedbackValues) begin
			Q_Select_4 = Q_Updated;
			A_Select_4 = A_Updated;
			B_Select_4 = B_Updated;
			C_Select_4 = C_Updated;
			N_Select_4 = N_Updated;
			Nn_Select_4 = Nn_Updated;
		end
		else begin
			Q_Select_4 = Q_4;
			A_Select_4 = A_4;
			B_Select_4 = B_4;
			C_Select_4 = C_4;
			N_Select_4 = N_4;
			Nn_Select_4 = Nn_4;
		end
	end

endmodule
