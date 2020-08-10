`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Run Interruption Type Determination. If run interruption was encountered by mode == 2 then we need to determine RIType (context 366 or 367) based on a and b. a_b_compare is 
		     computed here and fed down the pipeline (needed for Prediction Residual to invert negative signal) to reduce fanout restrictions due to joule heating i.e. extra wiring.
======================================================================================================================================================================================================
*/

module RIType #(parameter pixel_length = `pixel_length, mode_length = `mode_length)
	       (input [pixel_length - 1:0] a, input [pixel_length - 1:0] b, input [mode_length - 1:0] mode, output reg RIType, output reg a_b_compare);

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/	

	always @ (a or b or mode) begin	
		if (mode == 2) begin
			if (a == b) begin
				RIType = 1;
				a_b_compare = 0;
			end
			else begin
				RIType = 0;
				if (a > b) a_b_compare = 1;
				else a_b_compare = 0;
			end
		end
		//Keep 0 so power isnt lost in dynamic switching
		else begin
			RIType = 0;
			a_b_compare = 0;
		end
	end
endmodule
