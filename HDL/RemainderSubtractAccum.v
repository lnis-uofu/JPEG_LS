`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 5/1/2020
	DESCRIPTION:  Responsible for keeping track of the accumulated run_count_compare values as this will be passed down the pipeline and is used for run interruption coding
		      of the J[Run Index] values of the run count variable.
======================================================================================================================================================================================================
*/

module RemainderSubtractAccum #(parameter J_length = `J_length, runcount_length = `runcount_length, mode_length = `mode_length)
			       (input [J_length - 1:0] J, input [mode_length - 1:0] mode, input [mode_length - 1:0] previous_mode, input clk, input reset,
				input [runcount_length - 1:0]  run_counter, input [runcount_length - 1:0]  run_counter_compare, input [runcount_length - 1:0] run_count_compare_decision, 
				output reg [runcount_length - 1:0] remainder_subtract, input [runcount_length - 1:0] remainder_subtract_accum);

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/	

	always @ (J or run_counter or mode or previous_mode) begin
		if ((mode == 1 || mode == 3) && previous_mode != 2 && previous_mode != 3) begin
			if(run_counter == run_counter_compare) begin

				remainder_subtract = remainder_subtract_accum + (1 << J);

			end
			else begin
				remainder_subtract = remainder_subtract_accum;
			end
		end
		else if (previous_mode == 2) begin
			if (mode == 1 || mode == 3) begin
				if(run_counter == run_count_compare_decision) begin
					remainder_subtract = run_count_compare_decision;
				end	
				else begin
					remainder_subtract = 0;
				end
			end
			else begin
				remainder_subtract = 0;
			end
		end
		else if (previous_mode == 3 && mode == 1) begin
			if(run_counter == (1 << J)) begin
				remainder_subtract = run_counter;
			end
			else begin
				remainder_subtract = 0;
			end
		end
		else begin
			remainder_subtract = 0;
		end
	end
endmodule