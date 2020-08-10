`include "Parameterize_JPEGLS.v"

module Stage5Registers #(parameter modresidual_length = `modresidual_length, k_length = `k_length, mode_length = `mode_length, N_Nn_Compare_length = `N_Nn_Compare_length,
			 	   J_length = `J_length, temp_length = `temp_length, runcount_length = `runcount_length)
			(input clk, input reset, input [modresidual_length - 1:0] errValue_Final_5, input B_N_Compare_5, input [k_length - 1:0] k_5,  
			 input [N_Nn_Compare_length - 1:0] N_Nn_Compare_5, input [J_length - 1:0] J_5, input [temp_length - 1:0] temp_5, input start_enc_5,
			 input RIType_5, output RIType_6, input [mode_length - 1:0] mode_5, input hit_5, input do_run_encoding_5, output [mode_length - 1:0] mode_6, 
			 output [modresidual_length - 1:0] errValue_Final_6, output [k_length - 1:0] k_6, output B_N_Compare_6,  input EOF_5, 
			 output [N_Nn_Compare_length - 1:0] N_Nn_Compare_6, output [J_length - 1:0] J_6, output [temp_length - 1:0] temp_6, output EOF_6, output start_enc_6,
			 output hit_6, output do_run_encoding_6, input [runcount_length - 1:0] run_length_remainder_5, output [runcount_length - 1:0] run_length_remainder_6,
			 input [J_length - 1:0] J_Comp_5, output [J_length - 1:0] J_Comp_6, input [J_length - 1:0] J_Recurring_Mode_Two_5, output [J_length - 1:0] J_Recurring_Mode_Two_6);

	Register ErrValue_Final (.dataIn(errValue_Final_5), .dataOut(errValue_Final_6), .enable(start_enc_5), .clk(clk), .reset(reset));
	
	defparam K.size = k_length;
	Register K (.dataIn(k_5), .dataOut(k_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam B_N_Compare.size = 1;
	Register B_N_Compare (.dataIn(B_N_Compare_5), .dataOut(B_N_Compare_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam Mode.size = mode_length;
	Register Mode (.dataIn(mode_5), .dataOut(mode_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam RIType.size = 1;
	Register RIType (.dataIn(RIType_5), .dataOut(RIType_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam N_Nn_Compare.size = N_Nn_Compare_length;
	Register N_Nn_Compare (.dataIn(N_Nn_Compare_5), .dataOut(N_Nn_Compare_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam J.size = J_length;
	Register J (.dataIn(J_5), .dataOut(J_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam J_Comp.size = J_length;
	Register J_Comp (.dataIn(J_Comp_5), .dataOut(J_Comp_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam J_Recurring_Mode_Two.size = J_length;
	Register J_Recurring_Mode_Two (.dataIn(J_Recurring_Mode_Two_5), .dataOut(J_Recurring_Mode_Two_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam Temp.size = temp_length;
	Register Temp (.dataIn(temp_5), .dataOut(temp_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam EOF.size = 1;
	Register EOF (.dataIn(EOF_5), .dataOut(EOF_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam Start_Enc.size = 1;
	Register Start_Enc (.dataIn(start_enc_5), .dataOut(start_enc_6), .enable(1'b1), .clk(clk), .reset(reset));

	defparam Hit.size = 1;
	Register Hit (.dataIn(hit_5), .dataOut(hit_6), .enable(start_enc_5), .clk(clk), .reset(reset));

	defparam Do_Run_Encoding.size = 1;
	Register Do_Run_Encoding (.dataIn(do_run_encoding_5), .dataOut(do_run_encoding_6), .enable(1'b1), .clk(clk), .reset(reset));
		
	defparam RunLength_Remainder.size = runcount_length;
	Register RunLength_Remainder (.dataIn(run_length_remainder_5), .dataOut(run_length_remainder_6), .enable(start_enc_5), .clk(clk), .reset(reset));

endmodule