`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Module determines number of iterations through a speicifc run mode. Used for encoding run states which is the ideal case for minimzation of frame. Need to ensure
		     correct reseting of run count dependent on the current/previous mode. If the current mode is run interruption by end of line (mode == 3) we can still count the run
		     extenstion of the current pixel, but the next iteration needs to have the run count reset. Therefore, an intermedient signal of run_count_current is added, along with a
		     previous mode register to keep track of this specific condition.
======================================================================================================================================================================================================
*/

module RunCounter #(parameter pixel_length = `pixel_length, runcount_length = `runcount_length, mode_length = `mode_length, runvalue_length = `runvalue_length)
		   (input [pixel_length - 1:0] a, input [pixel_length - 1:0] x, input [runcount_length - 1:0] run_count, input [mode_length - 1:0] mode,
		    output reg [runcount_length - 1:0] run_count_new, output reg [runvalue_length - 1:0] run_value, input clk, input reset, input start_enc);

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [mode_length - 1:0] previous_mode;
	wire [runcount_length - 1:0] run_count_current;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/

	defparam Previous_Mode.size = mode_length;
	Register Previous_Mode (.dataIn(mode), .dataOut(previous_mode), .enable(start_enc), .clk(clk), .reset(reset));	

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign run_count_current = (previous_mode == 3) ? 0 : run_count;

	always @ (a or x or run_count or mode or run_count_current) begin


		run_value = x;
		case (mode) //synopsys full_case parallel_case
		1: begin
				if (x == a) run_count_new = run_count_current + 1;
				else run_count_new = 0;
		   end
		//need to reset run count if run mode is interrupted but need to keep run count 
		2: 	begin
				run_count_new = 0;
			end
		3: begin
				if (x == a) run_count_new = run_count_current + 1;
				else run_count_new = 0;
		   end
		default: 	run_count_new = 0;
		endcase
	end

endmodule
	
