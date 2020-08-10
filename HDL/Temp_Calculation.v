`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Calculates auxiliary variable, temp, which is used during golomb coding of run interruption samples. 
		     Temp is replacing the variable A in the golomb value k calculation.
======================================================================================================================================================================================================
*/
module Temp_Calculation #(parameter A_length = `A_length, N_length = `N_length, temp_length = `temp_length, mode_length = `mode_length)
			 (input [A_length - 1:0] A_Select, input [N_length - 1:0] N_Select, input RIType, 
			  input [mode_length - 1:0] mode, output [temp_length - 1:0] temp);

	assign temp = (mode != 2) ? 0 : (RIType) ? A_Select + {7'b0, (N_Select >> 1)} : A_Select;

endmodule
