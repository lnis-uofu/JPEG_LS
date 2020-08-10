//Top Level Module

`timescale 1ns/1ns
`include "JPEG_FSM.v"
`include "Stage1Registers.v"
`include "GradientQuantization.v"
`include "RIType.v"
`include "ModeDetermination.v"
`include "RunCounter.v"
`include "Stage2Registers.v"
`include "ContextGradient.v"
`include "Predictor.v"
`include "RunCoder.v"
`include "Stage3Registers.v"
`include "NUpdate.v"
`include "ContextMux.v"
`include "PredictionResidual.v"
`include "Temp_Calculation.v"
`include "Stage4Registers.v"
`include "Context_Update.v"
`include "k_calculation.v"
`include "Stage5Registers.v"
//`include "GolombEncoding.v"
`include "RiceEncoding.v"
`include "BitPackerUnrolled.v"
`include "Stage6Registers.v"
`include "Parameterize_JPEGLS.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Lossless JPEG Encoder Implementation. 7 stage pipeline with minimal stalls. Input is pixel data, output is variable size pixel data which has been encoded. In the 
		     case of a long run mode the maximum output size is 32 bits. Compression runs (2~3):1.
======================================================================================================================================================================================================
*/

module JPEGLS_Final #(parameter pixel_length = `pixel_length, colindex_length = `colindex_length, mode_length = `mode_length, runcount_length = `runcount_length,
			   runvalue_length = `runvalue_length, quantizedQ_length = `quantizedQ_length, mappedQ_length = `mappedQ_length,
			   J_length = `J_length, A_length = `A_length, B_length = `B_length, C_length = `C_length, N_length = `N_length, Nn_length = `Nn_length,
			   residual_length = `residual_length, modresidual_length = `modresidual_length, temp_length = `temp_length, k_length = `k_length,
			   N_Nn_Compare_length = `N_Nn_Compare_length, encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width,
			   unary_length = `unary_length, remaindervalue_length = `remaindervalue_length, dataOut_length = `dataOut_length, runindex_length = `runindex_length,
			   runcountercompare_length = `runcountercompare_length, Q_length = `Q_length, Context_rw = `Context_rw)
		(input [pixel_length - 1:0] pixelIn, input [pixel_length - 1:0] prevPixelIn, input clk, input reset, input start, 
		 input [A_length - 1: 0] A_in, input [B_length - 1:0] B_in, input [C_length - 1:0] C_in, input [N_length - 1:0] N_in, input [N_length - 1:0] Nn_in, input [Q_length - 1:0] Q_in,
		 output [A_length - 1: 0] A_out, output [B_length - 1:0] B_out, output [C_length - 1:0] C_out, output [N_length - 1:0] N_out, output [N_length - 1:0] Nn_out, output [Q_length - 1:0] Q_out,
		 output dataReady, output [dataOut_length - 1:0] dataOut, output [Context_rw - 1:0] write_Context_Memory, output read_Context_Memory,
		 output read_MEM_ONE, output read_MEM_TWO, output read_PREV_MEM_ONE, output read_PREV_MEM_TWO, output [colindex_length - 1:0] col_index, output start_enc_context,
		 output [colindex_length - 1:0] prev_col_index, output [encodedlength_width - 1:0] dataSize, output endOfDataStream, output [mode_length - 1:0] mode_context);

/*
======================================================================================================================================================================================================
	First stage pipeline:
	1) GET_DATA FSM
	2) 3 Pixel Memorys (each hold a row)
	The memories will have to be 135 bytes wide -> 405 bytes total
======================================================================================================================================================================================================
*/
	wire [pixel_length - 1:0] a_1;
	wire [pixel_length - 1:0] b_1;
	wire [pixel_length - 1:0] c_1;
	wire [pixel_length - 1:0] d_1;
	wire [pixel_length - 1:0] x_1;
	wire start_enc_1, EOF_1, EOL_1;

	GetDataFSM GetSampleDataFSM (.clk(clk), .reset(reset), .start(start), .pixelIn(pixelIn), .prevPixelIn(prevPixelIn), .a(a_1), .b(b_1), .c(c_1),
			 	     .d(d_1), .x(x_1), .start_enc(start_enc_1), .read_MEM_ONE(read_MEM_ONE), .read_MEM_TWO(read_MEM_TWO),
				     .read_PREV_MEM_ONE(read_PREV_MEM_ONE), .read_PREV_MEM_TWO(read_PREV_MEM_TWO), .col_index(col_index), .prev_col_index(prev_col_index),
			 	     .EOL(EOL_1), .EOF(EOF_1));

	/* synopsys translate_off  */
	//Memories for this module will be located outside for easier communicaiton with external modules
	//They will be 2 memories, 135 word size, 1 deep, 8 bits per index
	/* synopsys translate_on  */

/*
======================================================================================================================================================================================================
	First to Second Stage pipeline registers
======================================================================================================================================================================================================
*/

	wire [pixel_length - 1:0] a_2;
	wire [pixel_length - 1:0] b_2;
	wire [pixel_length - 1:0] c_2;
	wire [pixel_length - 1:0] d_2;
	wire [pixel_length - 1:0] x_2;
	wire EOL_2, EOF_2, start_enc_2;

	Stage1Registers Stage_1_to_2 (.clk(clk), .reset(reset), .a_1(a_1), .b_1(b_1), .c_1(c_1), .d_1(d_1), .x_1(x_1), .EOL_1(EOL_1), .EOF_1(EOF_1),
				      .a_2(a_2), .b_2(b_2), .c_2(c_2), .d_2(d_2), .x_2(x_2), .EOL_2(EOL_2), .EOF_2(EOF_2), .start_enc_1(start_enc_1), .start_enc_2(start_enc_2));

/*
======================================================================================================================================================================================================
	Second stage pipeline:
	1) Gradient Quantization - Lower the range of contexts
	2) RIType - Is a>b or b < a, for Run interruption coding
	3) Mode Determination - Determines if Regular, Run, or Run Interruption mode
	4) Run Counter - Run Mode Counter
======================================================================================================================================================================================================
*/
	wire sign_2, RIType_2, a_b_compare_2;
	wire [mode_length - 1:0] mode_2;
	wire [runcount_length - 1:0] run_count_2;
	wire [runvalue_length - 1:0] run_value_2;
	wire [quantizedQ_length - 1:0] Q_1_2;
	wire [quantizedQ_length - 1:0] Q_2_2;
	wire [quantizedQ_length - 1:0] Q_3_2;

	//Output from next stage (feedback)
	wire [runcount_length - 1:0] run_count_3;

	GradientQuantization Quantizer (.a(a_2), .b(b_2), .c(c_2), .d(d_2), .D_1(Q_1_2), .D_2(Q_2_2), .D_3(Q_3_2), .sign(sign_2));
	RIType RunInterruptionType (.a(a_2), .b(b_2), .RIType(RIType_2), .mode(mode_2), .a_b_compare(a_b_compare_2));
	ModeDetermination ModeType (.a(a_2), .b(b_2), .c(c_2), .d(d_2), .x(x_2), .EOL(EOL_2), .mode(mode_2), .clk(clk), .reset(reset), .start_enc(start_enc_2));
	RunCounter RunCounting (.a(a_2), .x(x_2), .run_count(run_count_3), .mode(mode_2), .run_count_new(run_count_2), .run_value(run_value_2),
				.clk(clk), .reset(reset), .start_enc(start_enc_2));

/*
======================================================================================================================================================================================================
	Second to Third Stage pipeline registers
======================================================================================================================================================================================================
*/

	wire sign_3, RIType_3, a_b_compare_3, start_enc_3, EOF_3;
	wire [mode_length - 1:0] mode_3;
	wire [runvalue_length - 1:0] run_value_3;
	wire [quantizedQ_length - 1:0] Q_1_3;
	wire [quantizedQ_length - 1:0] Q_2_3;
	wire [quantizedQ_length - 1:0] Q_3_3;
	wire [pixel_length - 1:0] a_3;
	wire [pixel_length - 1:0] b_3;
	wire [pixel_length - 1:0] c_3;
	wire [pixel_length - 1:0] x_3;

	Stage2Registers Stage_2_to_3 (.clk(clk), .reset(reset), .sign_2(sign_2), .RIType_2(RIType_2), .mode_2(mode_2), .a_2(a_2), .b_2(b_2), .c_2(c_2), .x_2(x_2), .EOF_2(EOF_2), .EOF_3(EOF_3),
					.run_count_2(run_count_2), .run_value_2(run_value_2), .Q_1_2(Q_1_2), .Q_2_2(Q_2_2), .Q_3_2(Q_3_2), .a_b_compare_2(a_b_compare_2),
					.sign_3(sign_3), .RIType_3(RIType_3), .mode_3(mode_3), .run_count_3(run_count_3), .a_b_compare_3(a_b_compare_3),
					.run_value_3(run_value_3), .Q_1_3(Q_1_3), .Q_2_3(Q_2_3), .Q_3_3(Q_3_3), .a_3(a_3), .b_3(b_3), .c_3(c_3), .x_3(x_3),
					.start_enc_2(start_enc_2), .start_enc_3(start_enc_3));

/*
======================================================================================================================================================================================================
	Third stage pipeline:
	1) Context Determination - Takes the quantized gradients and determines the context number
	2) Predictor - Predicts values for x based on context
	3) Run Length Coder - Determines Run length index (how many 1's to encode) and the remainder
======================================================================================================================================================================================================
*/
	wire [mappedQ_length - 1:0] C_t_3;
	wire [pixel_length - 1:0] Px_3;
	wire [J_length - 1:0] J_3;
	wire [runindex_length - 1:0] run_index_3;
	wire [runcount_length - 1:0] run_length_3;
	wire [runcountercompare_length - 1:0] run_counter_compare_3;
	wire [mode_length - 1:0] previous_mode_3;
	wire hit_3;
	wire [J_length - 1:0] J_Comp_3;
	wire [J_length - 1:0] J_Recurring_Mode_Two_3;
	wire [runcount_length - 1:0] remainder_subtract_accum_3;

	//Feedback from pipleine registers
	wire [runindex_length - 1:0] run_index_4;
	wire [runcountercompare_length - 1:0] run_counter_compare_4;

	wire [runcount_length - 1:0] remainder_subtract_accum_4;

	ContextGradient Context_Number (.D_1(Q_1_3), . D_2(Q_2_3), .D_3(Q_3_3), .RIType(RIType_3), .mode(mode_3), .C_t(C_t_3), .sign(sign_3));	
	Predictor Predictor_x (.a(a_3), .b(b_3), .c(c_3), .mode(mode_3), .RIType(RIType_3), .x_prediction(Px_3));
	RunCoder Run_Coder (.run_counter(run_count_3), .run_counter_compare(run_counter_compare_4), .run_index(run_index_4), .hit(hit_3), .J(J_3), .J_Comp(J_Comp_3), .mode(mode_3), 
		            .run_index_new(run_index_3), .run_length(run_length_3), .run_counter_compare_new(run_counter_compare_3), .clk(clk), .reset(reset), .start_enc(start_enc_3),
			    .previous_mode(previous_mode_3), .remainder_subtract_accum(remainder_subtract_accum_4), .remainder_subtract(remainder_subtract_accum_3), .J_Recurring_Mode_2(J_Recurring_Mode_Two_3));

/*
======================================================================================================================================================================================================
	Third to Fourth Stage pipeline registers and Context Memory
	//Need to figure out how to reset the run values when run_interruption mode is occured and not set when mode is regular
======================================================================================================================================================================================================
*/
	wire [Q_length - 1:0] Q_4;
	wire [pixel_length - 1:0] Px_4;
	wire [pixel_length - 1:0] x_4, a_4;
	wire [J_length - 1:0] J_4;
	wire [runcount_length - 1:0] run_length_4;
	wire [A_length - 1:0] A;
	wire [B_length - 1:0] B;
	wire [C_length - 1:0] C;
	wire [N_length - 1:0] N;
	wire [Nn_length - 1:0] Nn;
	wire RIType_4, sign_4, a_b_compare_4, EOF_4, start_enc_4, do_run_encoding_4, hit_4, do_run_length_adjust_4;
	wire [mode_length - 1:0] mode_4;
	wire [J_length - 1:0] J_Comp_4; 
	wire [J_length - 1:0] J_Recurring_Mode_Two_4;

	//Feedback from next stage(S)
	wire [Q_length - 1:0] Q_Feedback;
	wire [A_length - 1:0] A_Feedback;
	wire [B_length - 1:0] B_Feedback;
	wire [C_length - 1:0] C_Feedback;
	wire [N_length - 1:0] N_Feedback;
	wire [Nn_length - 1:0] Nn_Feedback;
	wire [Context_rw - 1:0] write_New_Context;
	wire start_enc_5, start_enc_6;

	//Saved feedback
	wire [Q_length - 1:0] Q_Updated;
	wire [A_length - 1:0] A_Updated;
	wire [B_length - 1:0] B_Updated;
	wire [C_length - 1:0] C_Updated;
	wire [N_length - 1:0] N_Updated;
	wire [Nn_length - 1:0] Nn_Updated;
	wire useFeedbackValues;
	

	//Put external to the module
	/* synopsys translate_off */
	/*ContextMemory ContextMemory (.A(A), .B(B), .C(C), .N(N), .A_Feedback(A_Feedback), .B_Feedback(B_Feedback), .C_Feedback(C_Feedback), 
				       .N_Feedback(N_Feedback), .Q(C_t_3), .Q_Feedback(Q_Feedback), .clk(clk), .reset(reset)); */
	/* synopsys translate_on */
	Stage3Registers Stage_3_to_4 (.clk(clk), .reset(reset), .x_3(x_3), .Px_3(Px_3), .Q_3(C_t_3), .hit_3(hit_3), .run_length_3(run_length_3), .sign_3(sign_3), .RIType_3(RIType_3), 
				      .a_b_compare_3(a_b_compare_3), .J_3(J_3), .mode_3(mode_3), .run_index_3(run_index_3), .Q_4(Q_4), .EOF_3(EOF_3), .EOF_4(EOF_4), .mode_2(mode_2),
				      .run_counter_compare_4(run_counter_compare_4), .a_b_compare_4(a_b_compare_4), .run_length_4(run_length_4), .Px_4(Px_4), .x_4(x_4), .hit_4(hit_4), 
				      .run_index_4(run_index_4), .sign_4(sign_4), .mode_4(mode_4), .RIType_4(RIType_4), .J_4(J_4), .start_enc_3(start_enc_3), .start_enc_4(start_enc_4),
				      .do_run_encoding_4(do_run_encoding_4), .do_run_length_adjust_4(do_run_length_adjust_4), .run_counter_compare_3(run_counter_compare_3),
				      .J_Comp_3(J_Comp_3), .J_Comp_4(J_Comp_4), .previous_mode_3(previous_mode_3), .J_Recurring_Mode_Two_3(J_Recurring_Mode_Two_3),
				      .J_Recurring_Mode_Two_4(J_Recurring_Mode_Two_4), .remainder_subtract(remainder_subtract_accum_3), .remainder_subtract_accum(remainder_subtract_accum_4));
	
	DetermineContextRead_Write ContextRead_Write (.Q_Write(Q_out), .A_Write(A_out), .B_Write(B_out), .C_Write(C_out), .N_Write(N_out), .Nn_Write(Nn_out),
						      .Q(C_t_3), .Q_Feedback(Q_Feedback), .A_Feedback(A_Feedback), .B_Feedback(B_Feedback), .C_Feedback(C_Feedback), 
						      .N_Feedback(N_Feedback), .Nn_Feedback(Nn_Feedback), .determineWrite(write_New_Context), .start_enc(start_enc_3),
						      .write_Context_Memory(write_Context_Memory), .read_Context_Memory(read_Context_Memory), .Q_Read(Q_in), .clk(clk),
						      .reset(reset),.Q_Updated(Q_Updated), .A_Updated(A_Updated), .B_Updated(B_Updated), .start_enc_feedback(start_enc_5),
						      .C_Updated(C_Updated), .N_Updated(N_Updated), .Nn_Updated(Nn_Updated), .useFeedbackValues(useFeedbackValues));


/*
======================================================================================================================================================================================================
	Fourth stage pipeline:
	1) Context Selection Mux - Depending on if the new context equals the previous context we will choose which one to use
	2) Prediction Error - This is the prediction residual module
	3) N Update - Increment N and look to see if we need to reset
	4) Temp Calculation - Temp variable used for Run Interruption Coding
======================================================================================================================================================================================================
*/
	wire [residual_length - 1:0] x_residual_4;
	wire [N_length - 1:0] N_4;
	wire [temp_length - 1:0] temp_4;
	wire resetFlag_4;
	wire [A_length - 1:0] A_Select_4;
	wire [B_length - 1:0] B_Select_4;
	wire [C_length - 1:0] C_Select_4;
 	wire [N_length - 1:0] N_Select_4;
	wire [Nn_length - 1:0] Nn_Select_4;
	wire [Q_length - 1:0] Q_Select_4;

	NUpdate Updater (.N(N_Select_4), .N_New(N_4), .resetFlag(resetFlag_4));
	ContextMux ContextDecision (.Q_Feedback(Q_Feedback), .A_Feedback(A_Feedback), .B_Feedback(B_Feedback), .C_Feedback(C_Feedback), .N_Feedback(N_Feedback), .Nn_Feedback(Nn_Feedback),
				    .Q_4(Q_4), .A_4(A_in), .B_4(B_in), .C_4(C_in), .N_4(N_in), .Nn_4(Nn_in), .Q_Select_4(Q_Select_4), .A_Select_4(A_Select_4), .B_Select_4(B_Select_4),
				    .C_Select_4(C_Select_4), .N_Select_4(N_Select_4), .Nn_Select_4(Nn_Select_4), .Q_Updated(Q_Updated), .A_Updated(A_Updated), .B_Updated(B_Updated),
				    .C_Updated(C_Updated), .N_Updated(N_Updated), .Nn_Updated(Nn_Updated), .useFeedbackValues(useFeedbackValues));
	PredictionResidual Residual (.x_prediction(Px_4), .x(x_4), .sign(sign_4), .C(C_Select_4), .mode(mode_4), .a_b_compare(a_b_compare_4), .RIType(RIType_4), .x_residual(x_residual_4));
	Temp_Calculation temp_calculation (.A_Select(A_Select_4), .N_Select(N_Select_4), .RIType(RIType_4), .mode(mode_4), .temp(temp_4));


/*
======================================================================================================================================================================================================
	Fourth to Fifth Stage pipeline registers
	//K_inc is jus to feed a constant input into k so it can be incremented from 0
======================================================================================================================================================================================================
*/
	
	wire [Q_length - 1:0] Q_5;
	wire [A_length - 1:0] A_5;
	wire [B_length - 1:0] B_5;
	wire [C_length - 1:0] C_5;
	wire [N_length - 1:0] N_5;
	wire [N_length - 1:0] N_Select_5;
	wire [Nn_length - 1:0] Nn_5;
	wire [J_length - 1:0] J_5;
	wire [residual_length - 1:0] x_residual_5;
	wire resetFlag_5, RIType_5, EOF_5, do_run_encoding_5, do_run_length_adjust_5;
	wire [mode_length - 1:0] mode_5;
	wire [k_length - 1:0] k_value_5;
	wire [temp_length - 1:0] temp_5;
	wire hit_5;
	wire [runcount_length - 1:0] run_length_5;
	wire [runindex_length - 1:0] run_index_5;
	wire [runcount_length - 1:0] remainder_subtract_accum_5;
	wire [J_length - 1:0]  J_Comp_5;
	wire [J_length - 1:0] J_Recurring_Mode_Two_5;

	Stage4Registers stage_4_to_5 (.clk(clk), .reset(reset), .A_4(A_Select_4), .B_4(B_Select_4), .C_4(C_Select_4), .N_4(N_Select_4), .Nn_4(Nn_Select_4), .Q_4(Q_Select_4), .RIType_4(RIType_4), .temp_4(temp_4),
				      .J_4(J_4), .x_residual_4(x_residual_4), .mode_4(mode_4), .resetFlag_4(resetFlag_4), .Q_5(Q_5), .A_5(A_5), .B_5(B_5), .RIType_5(RIType_5), .k_value_5(k_value_5), .hit_4(hit_4),
				      .C_5(C_5), .N_5(N_5),  .Nn_5(Nn_5), .x_residual_5(x_residual_5), .mode_5(mode_5), .resetFlag_5(resetFlag_5), .temp_5(temp_5), .J_5(J_5), .EOF_4(EOF_4), .EOF_5(EOF_5),
				      .start_enc_4(start_enc_4), .start_enc_5(start_enc_5), .hit_5(hit_5), .do_run_encoding_4(do_run_encoding_4), .do_run_encoding_5(do_run_encoding_5),
				      .run_length_4(run_length_4), .run_length_5(run_length_5), .do_run_length_adjust_4(do_run_length_adjust_4), .do_run_length_adjust_5(do_run_length_adjust_5),
				      .run_index_4(run_index_4), .run_index_5(run_index_5), .N_Select_4(N_Select_4), .N_Select_5(N_Select_5), .remainder_subtract_accum_4(remainder_subtract_accum_4),
				      .remainder_subtract_accum_5(remainder_subtract_accum_5), .J_Comp_4(J_Comp_4), .J_Comp_5(J_Comp_5), .J_Recurring_Mode_Two_4(J_Recurring_Mode_Two_4),
				      .J_Recurring_Mode_Two_5(J_Recurring_Mode_Two_5));
/*
======================================================================================================================================================================================================
	Fifth stage pipeline:
	1) Context Update - Updates the rest of the parameters/bias cancellation
	2) Error Modulo - Reduce the residual modulo alpha
	3) k Calculation - Golomb Paramter Calculation
======================================================================================================================================================================================================
*/

	wire [k_length - 1:0] k_5;
	wire [modresidual_length - 1:0] errValue_Final_5;
	wire B_N_Compare_5;
	wire [N_Nn_Compare_length - 1:0] N_Nn_Compare_5;
	wire [runcount_length - 1:0] run_length_remainder_5;

	assign mode_context = mode_5;
	assign start_enc_context = start_enc_5;

	Context_Update Context_Variable_Update (.A(A_5), .B(B_5), .C(C_5), .N(N_5), .Nn(Nn_5), .resetFlag(resetFlag_5), .B_new(B_Feedback), .Nn_New(Nn_Feedback), .mode(mode_5),
						.A_new(A_Feedback), .C_new(C_Feedback), .N_new(N_Feedback), .errModulo(errValue_Final_5), .B_N_Compare(B_N_Compare_5), .RIType(RIType_5),
						.write_New_Context(write_New_Context), .N_Nn_Compare(N_Nn_Compare_5), .Q(Q_5), .Q_new(Q_Feedback));
	ErrorMod_Map mod_map (.errValue(x_residual_5), .errorModulo(errValue_Final_5));
	k_calculation_unrolled Golomb_k (.N(N_Select_5), .A(A_5), .mode(mode_5), .RIType(RIType_5), .temp(temp_5), .k_inc(k_value_5), .k(k_5));
	RunLengthAdjust RLAdjust (.run_length(run_length_5), .run_length_remainder(run_length_remainder_5), .remainder_subtract_accum(remainder_subtract_accum_5));

/*
======================================================================================================================================================================================================
	Fifth to Sixth Stage pipeline registers
======================================================================================================================================================================================================
*/


	wire [k_length - 1:0] k_6;
	wire B_N_Compare_6, RIType_6, EOF_6, do_run_encoding_6;
	wire [mode_length - 1:0] mode_6;
	wire [modresidual_length - 1:0] errValue_Final_6;
	wire [N_Nn_Compare_length - 1:0] N_Nn_Compare_6;
	wire [J_length - 1:0] J_6;
	wire [temp_length - 1:0] temp_6;
	wire hit_6;
	wire [runcount_length - 1:0] run_length_remainder_6;
	wire [J_length - 1:0] J_Comp_6;
	wire [J_length - 1:0] J_Recurring_Mode_Two_6;

	Stage5Registers stage_5_to_6 (.clk(clk), .reset(reset), .errValue_Final_5(errValue_Final_5), .k_5(k_5), .B_N_Compare_5(B_N_Compare_5), .temp_5(temp_5), .N_Nn_Compare_5(N_Nn_Compare_5),
				      .J_5(J_5), .mode_5(mode_5), .RIType_5(RIType_5), .RIType_6(RIType_6), .errValue_Final_6(errValue_Final_6), .k_6(k_6), .B_N_Compare_6(B_N_Compare_6), .hit_5(hit_5),
				      .N_Nn_Compare_6(N_Nn_Compare_6), .J_6(J_6), .mode_6(mode_6), .temp_6(temp_6), .EOF_5(EOF_5), .EOF_6(EOF_6), .start_enc_5(start_enc_5), .start_enc_6(start_enc_6),
				      .hit_6(hit_6), .do_run_encoding_5(do_run_encoding_5), .do_run_encoding_6(do_run_encoding_6), .run_length_remainder_5(run_length_remainder_5),
				      .run_length_remainder_6(run_length_remainder_6), .J_Comp_5(J_Comp_5), .J_Comp_6(J_Comp_6), .J_Recurring_Mode_Two_5(J_Recurring_Mode_Two_5),
				      .J_Recurring_Mode_Two_6(J_Recurring_Mode_Two_6));

/*
======================================================================================================================================================================================================
	Sixth stage pipeline:
	1) Rice Encoder - Also does the map error value
======================================================================================================================================================================================================
*/

	wire [unary_length - 1:0] unary_6;
	wire [remaindervalue_length - 1:0] remainder_value_6;
	wire [encodedpixel_width - 1:0] encoded_pixel_6;
	wire [encodedlength_width - 1:0] encoded_length_6;
	wire limit_overflow_6;
	

	RiceEncoding RiceEncoder (.errValue(errValue_Final_6), .B_N_Compare(B_N_Compare_6), .k(k_6), .unary(unary_6), .remainder_value(remainder_value_6), .J(J_6), .mode(mode_6),
				    .N_Nn_Compare(N_Nn_Compare_6), .encoded_pixel(encoded_pixel_6), .encoded_length(encoded_length_6), .limit_overflow(limit_overflow_6), .hit(hit_6),
				    .run_length(run_length_remainder_6), .do_run_encoding(do_run_encoding_6), .RIType(RIType_6), .J_Comp(J_Comp_6), .J_Recurring_Mode_Two(J_Recurring_Mode_Two_6),
				  .clk(clk), .reset(reset));

/*
======================================================================================================================================================================================================
	Sixth to Seventh Stage pipeline registers
======================================================================================================================================================================================================
*/
	wire start_enc_7, EOF_7, limit_overflow_7;
	wire [encodedpixel_width - 1:0] encoded_pixel_7;
	wire [encodedlength_width - 1:0] encoded_length_7;
	wire [remaindervalue_length - 1:0] remainder_value_7;
	wire [J_length - 1:0] J_7;
	wire [mode_length - 1:0] mode_7;

	Stage6Registers stage_6_to_7 (.clk(clk), .reset(reset), .encoded_pixel_6(encoded_pixel_6), .encoded_length_6(encoded_length_6), .EOF_6(EOF_6), .limit_overflow_6(limit_overflow_6),
				      .encoded_pixel_7(encoded_pixel_7), .encoded_length_7(encoded_length_7), .EOF_7(EOF_7), .limit_overflow_7(limit_overflow_7), .do_run_encoding_6(do_run_encoding_6),
				      .start_enc_6(start_enc_6), .start_enc_7(start_enc_7), .remainder_value_6(remainder_value_6), .remainder_value_7(remainder_value_7),
				      .mode_6(mode_6), .mode_7(mode_7), .J_6(J_6), .J_7(J_7));

/*
======================================================================================================================================================================================================
	Seventh stage pipeline:
	1) Bit Packer - Outputs 1 to 32 bits depending on length of encoding, mode, limit, overflow, run_index, remainder, golomb code, etc...
======================================================================================================================================================================================================
*/

	wire dataReady_7;
	wire [dataOut_length - 1:0] dataOut_7;
	wire [encodedlength_width - 1:0] dataSize_7;
	wire endOfDataStream_7;
	wire [encodedpixel_width - 1:0] encoded_pixel_shifted;

	assign encoded_pixel_shifted = encoded_pixel_7 << (encodedpixel_width - encoded_length_7);

	BitPackerUnrolled outputBP (.clk(clk), .reset(reset), .start(start), .start_enc(start_enc_7), .encoded_pixel(encoded_pixel_shifted), .encoded_length(encoded_length_7), .EOF(EOF_7), .limit_overflow(limit_overflow_7),
		       	            .dataReady(dataReady_7), .dataOut(dataOut_7), .data_Sample_Size(dataSize_7), .remainder_value(remainder_value_7), .endOfDataStream(endOfDataStream_7), .J(J_7), .mode(mode_7));

/*
======================================================================================================================================================================================================
	Seventh to Output Stage pipeline registers
======================================================================================================================================================================================================
*/

	Stage7Registers stage_7_to_out (.dataReady_7(dataReady_7), .dataOut_7(dataOut_7), .dataSize_7(dataSize_7), .endOfDataStream_7(endOfDataStream_7), .dataReady(dataReady), .dataOut(dataOut),
			 		.dataSize(dataSize), .endOfDataStream(endOfDataStream), .clk(clk), .reset(reset), .start_enc_7(start_enc_7));

endmodule
