`include "Register.v"
`include "Parameterize_JPEGLS.v"

module Stage2Registers #(parameter pixel_length = `pixel_length, runcount_length = `runcount_length, runvalue_length = `runvalue_length, quantizedQ_length = `quantizedQ_length, mode_length = `mode_length)
		        (input clk, input reset, input sign_2, input RIType_2, input [mode_length - 1:0] mode_2, input [runcount_length - 1:0] run_count_2, input [runvalue_length - 1:0] run_value_2, 
			 input a_b_compare_2, input start_enc_2, input [pixel_length - 1:0] a_2, input [pixel_length - 1:0] b_2, input [pixel_length - 1:0] c_2, input [pixel_length - 1:0] x_2, 
			 input [quantizedQ_length - 1:0] Q_1_2, input [quantizedQ_length - 1:0] Q_2_2, input [quantizedQ_length - 1:0] Q_3_2, input EOF_2,
			 output sign_3, output RIType_3, output [mode_length - 1:0] mode_3, output [runcount_length - 1:0] run_count_3, output [runvalue_length - 1:0] run_value_3, 
			 output a_b_compare_3, output [pixel_length - 1:0] a_3, output [pixel_length - 1:0] b_3, output [pixel_length - 1:0] c_3, output [pixel_length - 1:0] x_3, 
			 output [quantizedQ_length - 1:0] Q_1_3, output [quantizedQ_length - 1:0] Q_2_3, output [quantizedQ_length - 1:0] Q_3_3, output EOF_3, output start_enc_3);

	defparam sign.size = 1;
	Register sign (.dataIn(sign_2), .dataOut(sign_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	defparam RIType.size = 1;
	Register RIType (.dataIn(RIType_2), .dataOut(RIType_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	defparam mode.size = mode_length;
	Register mode (.dataIn(mode_2), .dataOut(mode_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	defparam A_B_Compare.size = 1;
	Register A_B_Compare (.dataIn(a_b_compare_2), .dataOut(a_b_compare_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	defparam run_count.size = runcount_length;
	Register run_count (.dataIn(run_count_2), .dataOut(run_count_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	defparam run_value.size = runvalue_length;
	Register run_value (.dataIn(run_value_2), .dataOut(run_value_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	Register a (.dataIn(a_2), .dataOut(a_3), .enable(start_enc_2), .clk(clk), .reset(reset));
	Register b (.dataIn(b_2), .dataOut(b_3), .enable(start_enc_2), .clk(clk), .reset(reset));
	Register c (.dataIn(c_2), .dataOut(c_3), .enable(start_enc_2), .clk(clk), .reset(reset));
	Register x (.dataIn(x_2), .dataOut(x_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	defparam Q_1.size = quantizedQ_length;
	Register Q_1 (.dataIn(Q_1_2), .dataOut(Q_1_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	defparam Q_2.size = quantizedQ_length;
	Register Q_2 (.dataIn(Q_2_2), .dataOut(Q_2_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	defparam Q_3.size = quantizedQ_length;
	Register Q_3 (.dataIn(Q_3_2), .dataOut(Q_3_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	defparam EOF.size = 1;
	Register EOF (.dataIn(EOF_2), .dataOut(EOF_3), .enable(start_enc_2), .clk(clk), .reset(reset));

	defparam Start_Enc.size = 1;
	Register Start_Enc (.dataIn(start_enc_2), .dataOut(start_enc_3), .enable(1'b1), .clk(clk), .reset(reset));

endmodule
