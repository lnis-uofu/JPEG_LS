`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: ErrorMod_Map maps the error value to a range within -128 <= x <= 127. This allows for a modulo reduction of the error value in respect to alpha which plays,
		     a critical part into reducing the bitstream of the outputted data. The mapping is broken into two parts within this module to ensure that the data meets contraints set forth by
		     algorithm. 
======================================================================================================================================================================================================
*/

module ErrorMod_Map #(parameter residual_length = `residual_length, modresidual_length = `modresidual_length)
		     (input [residual_length - 1:0] errValue, output reg [modresidual_length - 1:0] errorModulo);

/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/
	localparam [7:0] alpha = 8'd256;
	localparam [7:0] half_alpha = 8'd128;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/
	reg [modresidual_length - 1:0] errorPartMod;

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/
	always @ (errValue) begin
	
		//if errValue < 0
		if (errValue[residual_length - 1] == 1) errorPartMod = errValue + alpha;
		else errorPartMod = errValue;

		if (errorPartMod >= half_alpha) errorModulo = errorPartMod - alpha;
		else errorModulo = errorPartMod;
	end

endmodule