`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION:  Prediction Residual is computed based off prediction and actual value of pixel along with mode of operation. The principle among doing so is that the residual is
		      modeled by a TSGD which ensures probability of error is minimal. Therefore we can reduce the range of values needed to predict these values and is well suited 
		      for Golumb coding. Residual modulo arithmetic is seperated into next stage of pipeline to reduce latency. C is bias cancellation.
======================================================================================================================================================================================================
*/
module PredictionResidual #(parameter pixel_length = `pixel_length, C_length = `C_length, mode_length = `mode_length, residual_length = `residual_length)
			   (input [pixel_length - 1:0] x_prediction, input [pixel_length - 1:0] x, input sign, input [C_length - 1:0] C, 
			    input [mode_length - 1:0] mode, input RIType, input a_b_compare, output reg [residual_length - 1:0] x_residual);

/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/
	localparam [pixel_length - 1:0] Range = 8'd255;

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [C_length - 1:0] C_Twos_Comp;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	reg [residual_length - 1:0] errValue;
	reg [residual_length - 1:0] x_prediction_clip;

	//signed
	reg [residual_length:0] x_prediction_bias_cancel;

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign C_Twos_Comp = ~C + 1;

	//so here we need to comput residual between prediction and x, if negative then take absolute value
	always @ (x_prediction or x or sign or C or mode or RIType or a_b_compare) begin
		

		//regular mode coding
		if(mode == 0) begin
			if (sign == 0) x_prediction_bias_cancel = {2'b0,x_prediction} + {{2{C[C_length - 1]}},C};
			else x_prediction_bias_cancel = {2'b0,x_prediction} + {{2{C_Twos_Comp[C_length - 1]}}, C_Twos_Comp};

			if(x_prediction_bias_cancel[residual_length] == 1) begin
				x_prediction_clip = 0;
			end
			else if (x_prediction_bias_cancel >= Range) begin
				x_prediction_clip = Range;
			end
			else x_prediction_clip = x_prediction_bias_cancel;

			errValue = ({1'b0,x} - x_prediction_clip);

			//flip sign if context was negative
			if (sign) x_residual = ~errValue + 1;
			else x_residual = errValue;
		end
		//run interruption coding
		else if(mode == 2) begin
			errValue = x - x_prediction;
			if((~RIType) & a_b_compare) x_residual = (~errValue) + 1;
			else x_residual = errValue;
		end
		else x_residual = 0;
	end

endmodule

