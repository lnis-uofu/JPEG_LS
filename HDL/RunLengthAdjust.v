`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Run length adjust subtracts the extra runlength of less than rg, assuming a hit was not created at the last point of the runlength. Run index of less than 4 is removed
		     from the possible values since if the runlength is is 4 or less (index 0 + 1 + 2 + 3) then we cannot have a run length remainder of less than rg since rg is 4 at this point.
======================================================================================================================================================================================================
*/

module RunLengthAdjust #(parameter runindex_length = `runindex_length, runcount_length = `runcount_length)
		        (input [runcount_length - 1:0] run_length, input [runcount_length - 1:0] remainder_subtract_accum, output [runcount_length - 1:0] run_length_remainder);
	
/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/
	assign run_length_remainder = run_length - remainder_subtract_accum;

endmodule
