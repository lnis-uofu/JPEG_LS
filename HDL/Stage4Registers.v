`include "Parameterize_JPEGLS.v"

module Stage4Registers #(parameter Q_length = `Q_length, A_length = `A_length, B_length = `B_length, C_length = `C_length, N_length = `N_length, Nn_length = `Nn_length, 
				   temp_length = `temp_length, J_length = `J_length, residual_length = `residual_length, mode_length = `mode_length, k_length = `k_length,
				   runcount_length = `runcount_length, runindex_length = `runindex_length)
			(input clk, input reset, input [Q_length - 1:0] Q_4, input [A_length - 1:0] A_4, input [B_length - 1:0] B_4, input [C_length - 1:0] C_4, 
			 input [N_length - 1:0] N_4, input [residual_length - 1:0] x_residual_4, input [mode_length - 1:0] mode_4, input resetFlag_4,  input start_enc_4,
			 input [J_length - 1:0] J_4, input RIType_4, input [Nn_length - 1:0] Nn_4, input [temp_length - 1:0] temp_4, output RIType_5,
			 output [Q_length - 1:0] Q_5, output [A_length - 1:0] A_5, output [B_length - 1:0] B_5,  output [Nn_length - 1:0] Nn_5, input EOF_4, input hit_4,
			 input do_run_encoding_4, output [C_length - 1:0] C_5, output [N_length - 1:0] N_5, output [residual_length - 1:0] x_residual_5, 
			 output [mode_length - 1:0] mode_5, output resetFlag_5, output [temp_length - 1:0] temp_5, output [J_length - 1:0] J_5,
			 output [k_length - 1:0] k_value_5, output EOF_5, output start_enc_5, output hit_5, output do_run_encoding_5,
			 input do_run_length_adjust_4, output do_run_length_adjust_5, input [runcount_length - 1:0] run_length_4, output [runcount_length - 1:0] run_length_5,
			 input [runindex_length - 1:0] run_index_4, output [runindex_length - 1:0] run_index_5, input [N_length - 1:0] N_Select_4, output [N_length - 1:0] N_Select_5,
			 input [runcount_length - 1:0] remainder_subtract_accum_4, output [runcount_length - 1:0] remainder_subtract_accum_5, input [J_length - 1:0] J_Comp_4,
			 output [J_length - 1:0] J_Comp_5, input [J_length - 1:0] J_Recurring_Mode_Two_4, output [J_length - 1:0] J_Recurring_Mode_Two_5);

	defparam Q.size = Q_length;
	Register Q (.dataIn(Q_4), .dataOut(Q_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam A.size = A_length;
	Register A (.dataIn(A_4), .dataOut(A_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam B.size = B_length;
	Register B (.dataIn(B_4), .dataOut(B_5), .enable(start_enc_4), .clk(clk), .reset(reset));
 
	defparam C.size = C_length;
	Register C (.dataIn(C_4), .dataOut(C_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam N.size = N_length;
	Register N (.dataIn(N_4), .dataOut(N_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam N_Select.size = N_length;
	Register N_Select (.dataIn(N_Select_4), .dataOut(N_Select_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam Nn.size = Nn_length;
	Register Nn (.dataIn(Nn_4), .dataOut(Nn_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam Temp.size = temp_length;
	Register Temp (.dataIn(temp_4), .dataOut(temp_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam J.size = J_length;
	Register J (.dataIn(J_4), .dataOut(J_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam J_Comp.size = J_length;
	Register J_Comp (.dataIn(J_Comp_4), .dataOut(J_Comp_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam J_Recurring_Mode_Two.size = J_length;
	Register J_Recurring_Mode_Two (.dataIn(J_Recurring_Mode_Two_4), .dataOut(J_Recurring_Mode_Two_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam X_Residual.size = residual_length;
	Register X_Residual (.dataIn(x_residual_4), .dataOut(x_residual_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam Mode.size = mode_length;
	Register Mode (.dataIn(mode_4), .dataOut(mode_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam RIType.size = 1;
	Register RIType (.dataIn(RIType_4), .dataOut(RIType_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam ResetFlag.size = 1;
	Register ResetFlag (.dataIn(resetFlag_4), .dataOut(resetFlag_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam K_Value.size = k_length;
	Register K_Value (.dataIn(4'b0), .dataOut(k_value_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam EOF.size = 1;
	Register EOF (.dataIn(EOF_4), .dataOut(EOF_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam Start_Enc.size = 1;
	Register Start_Enc (.dataIn(start_enc_4), .dataOut(start_enc_5), .enable(1'b1), .clk(clk), .reset(reset));

	defparam Hit.size = 1;
	Register Hit (.dataIn(hit_4), .dataOut(hit_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam Do_Run_Encoding.size = 1;
	Register Do_Run_Encoding (.dataIn(do_run_encoding_4), .dataOut(do_run_encoding_5), .enable(1'b1), .clk(clk), .reset(reset));

	defparam Do_Run_Length_Adjust.size = 1;
	Register Do_Run_Length_Adjust (.dataIn(do_run_length_adjust_4), .dataOut(do_run_length_adjust_5), .enable(1'b1), .clk(clk), .reset(reset));

	defparam RunLength.size = runcount_length;
	Register RunLength (.dataIn(run_length_4), .dataOut(run_length_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam RunIndex.size = runindex_length;
	Register RunIndex (.dataIn(run_index_4), .dataOut(run_index_5), .enable(start_enc_4), .clk(clk), .reset(reset));

	defparam Remainder_Subtract_Accum.size = runcount_length;
	Register Remainder_Subtract_Accum (.dataIn(remainder_subtract_accum_4), .dataOut(remainder_subtract_accum_5), .enable(1'b1), .clk(clk), .reset(reset));


endmodule
