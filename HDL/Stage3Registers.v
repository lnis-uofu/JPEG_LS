`include "Parameterize_JPEGLS.v"

module Stage3Registers #(parameter pixel_length = `pixel_length, mode_length = `mode_length, Q_length = `Q_length, runcount_length = `runcount_length, 
				   runcountercompare_length = `runcountercompare_length, J_length = `J_length, runindex_length = `runindex_length)
			(input clk, input reset, input [pixel_length - 1:0] x_3, input [pixel_length - 1:0] Px_3, input RIType_3, input [mode_length - 1:0] mode_3, 
			 input sign_3, input [Q_length - 1:0] Q_3, input hit_3, input [runcount_length - 1:0] run_length_3, input [mode_length - 1:0] mode_2,
			 input [runcountercompare_length - 1:0] run_counter_compare_3, input [J_length - 1:0] J_3, input [runindex_length - 1:0] run_index_3, input a_b_compare_3, 
			 output [Q_length - 1:0] Q_4, output [runcountercompare_length - 1:0] run_counter_compare_4, input start_enc_3, input EOF_3,  output do_run_length_adjust_4,
			 output [runcount_length - 1:0] run_length_4, output [pixel_length - 1:0] Px_4, output [pixel_length - 1:0] x_4, output hit_4, 
			 output [runindex_length - 1:0] run_index_4, output a_b_compare_4, output do_run_encoding_4, input [mode_length - 1:0] previous_mode_3,
			 output RIType_4, output [mode_length - 1:0] mode_4, output sign_4, output [J_length - 1:0] J_4, output EOF_4, output start_enc_4,
			 input [J_length - 1:0] J_Comp_3, output [J_length - 1:0] J_Comp_4, input [J_length - 1:0] J_Recurring_Mode_Two_3, output [J_length - 1:0] J_Recurring_Mode_Two_4,
			 input [runcount_length - 1:0] remainder_subtract, output [runcount_length - 1:0] remainder_subtract_accum);

	wire continue_encoding, do_run_encoding;

/*
* if we arent in run mode (regular mode or run interruption mode) then we can continue coding
* this means if a run interruption was detected by the mode module on stage 2 of the pipeline we need
* to send the run length hits to be encoded, so we start saving the values
* values that partain to run coding should always be enabled

if it is mode == 2 on next sample we need to stop the run mode encoding and encode the run_length,

*/
	assign continue_encoding = (mode_3 != (1 || 3)) ? start_enc_3 : 1'b0;	

	//If no run count no need to do run coding, so we will check to see if previous mode_3 was 1
	// if so that means we have at least 1 hit that needs to be encoded
	//if we entered run mode but were previously in normal mode, but no run was encountered because x != run_value
	// then we need to append a 0 in front of the golomb encoded value of the run interruption variable, that is 
	// what the second conditon checks for there
	assign do_run_encoding = ((mode_2 == 2 && mode_3 == 1) || (mode_3 == 2 && previous_mode_3 == 0) || (previous_mode_3 == 2 && mode_3 == 2) || (previous_mode_3 == 3 && mode_3 == 2)) ? 1'b1 : 1'b0;
	

	Register X (.dataIn(x_3), .dataOut(x_4), .enable(continue_encoding), .clk(clk), .reset(reset));
	Register Px (.dataIn(Px_3), .dataOut(Px_4), .enable(continue_encoding), .clk(clk), .reset(reset));

	defparam Q.size = Q_length;
	Register Q (.dataIn(Q_3), .dataOut(Q_4), .enable(start_enc_3), .clk(clk), .reset(reset));

	defparam RIType.size = 1;
	Register RIType (.dataIn(RIType_3), .dataOut(RIType_4), .enable(continue_encoding), .clk(clk), .reset(reset));

	defparam J.size = J_length;
	Register J (.dataIn(J_3), .dataOut(J_4), .enable(start_enc_3), .clk(clk), .reset(reset));

	defparam J_Comp.size = J_length;
	Register J_Comp (.dataIn(J_Comp_3), .dataOut(J_Comp_4), .enable(start_enc_3), .clk(clk), .reset(reset));

	defparam J_Recurring_Mode_Two.size = J_length;
	Register J_Recurring_Mode_Two (.dataIn(J_Recurring_Mode_Two_3), .dataOut(J_Recurring_Mode_Two_4), .enable(start_enc_3), .clk(clk), .reset(reset));

	defparam Mode.size = mode_length;
	Register Mode (.dataIn(mode_3), .dataOut(mode_4), .enable(start_enc_3), .clk(clk), .reset(reset));

	defparam A_B_Compare.size = 1;
	Register A_B_Compare (.dataIn(a_b_compare_3), .dataOut(a_b_compare_4), .enable(continue_encoding), .clk(clk), .reset(reset));

	defparam Sign.size = 1;
	Register Sign (.dataIn(sign_3), .dataOut(sign_4), .enable(continue_encoding), .clk(clk), .reset(reset));

	defparam Hit.size = 1;
	Register Hit (.dataIn(hit_3), .dataOut(hit_4), .enable(start_enc_3), .clk(clk), .reset(reset));

	//run length is the run count
	defparam RunLength.size = runcount_length;
	Register RunLength (.dataIn(run_length_3), .dataOut(run_length_4), .enable(start_enc_3), .clk(clk), .reset(reset));

	defparam RunCounterCompare.size = runcountercompare_length; 
	RegisterVariableReset RunCounterCompare (.dataIn(run_counter_compare_3), .dataOut(run_counter_compare_4), .enable(1'b1), .clk(clk), .reset(reset));

	defparam RunIndex.size = runindex_length;
	Register RunIndex (.dataIn(run_index_3), .dataOut(run_index_4), .enable(start_enc_3), .clk(clk), .reset(reset));

	defparam EOF.size = 1;
	Register EOF (.dataIn(EOF_3), .dataOut(EOF_4), .enable(continue_encoding), .clk(clk), .reset(reset));

	defparam Start_Enc.size = 1;
	Register Start_Enc (.dataIn(start_enc_3), .dataOut(start_enc_4), .enable(1'b1), .clk(clk), .reset(reset));

	defparam Do_Run_Encoding.size = 1;
	Register Do_Run_Encoding (.dataIn(do_run_encoding), .dataOut(do_run_encoding_4), .enable(1'b1), .clk(clk), .reset(reset));

	defparam Do_Run_Length_Adjust.size = 1;
	Register Do_Run_Length_Adjust (.dataIn(mode_2 == 2), .dataOut(do_run_length_adjust_4), .enable(1'b1), .clk(clk), .reset(reset));

	defparam Remainder_Subtract_Accum.size = runcount_length;
	Register Remainder_Subtract_Accum (.dataIn(remainder_subtract), . dataOut(remainder_subtract_accum), .enable(1'b1), .clk(clk), .reset(reset));

endmodule
