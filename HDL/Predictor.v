`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Predcitor of pixel x based on gradients. Mathematically ensures that a hyperplane is formed by the prediciton to ensure linearity in the design.
	  	     Depending on the mode of operation either x is predicted using a MED_PREDICTOR or formulated based on RIType.
======================================================================================================================================================================================================
*/
module Predictor #(parameter pixel_length = `pixel_length, mode_length = `mode_length)
		  (input [pixel_length - 1:0] a, input [pixel_length - 1:0] b, input [pixel_length - 1:0] c, input [mode_length - 1:0] mode, 
		   input RIType, output reg [pixel_length - 1:0] x_prediction); 

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/
	wire [pixel_length - 1:0] minimum;
	wire [pixel_length - 1:0] maximum;

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/
	assign maximum = (a >= b) ? a : b;
	assign minimum = (a <= b) ? a : b;

	always @ (a or b or c or mode or RIType) begin
		if (mode == 0) begin
			if (c >= maximum) x_prediction = minimum;
			else if (c <= minimum) x_prediction = maximum;
			else x_prediction = a + b - c;
		end
		else if (mode == 2) begin
			if (RIType) x_prediction = a;
			else x_prediction = b;
		end
		else x_prediction = 0;
	end
endmodule
