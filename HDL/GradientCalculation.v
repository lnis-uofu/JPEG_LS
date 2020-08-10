`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Calculates graident of pixels based on context. Strictly combinational logic.
======================================================================================================================================================================================================
*/
module GradientCalculation #(parameter pixel_length = `pixel_length, Q_length = `Q_length)
			    (input [pixel_length - 1:0] a, input [pixel_length - 1:0] b, input [pixel_length - 1:0] c, input [pixel_length - 1:0] d, 
			     output [Q_length - 1:0] Q_1, output [Q_length - 1:0] Q_2, output [Q_length - 1:0] Q_3);

	assign Q_1 = d - b;
	assign Q_2 = b - c;
	assign Q_3 = c - a;

endmodule
