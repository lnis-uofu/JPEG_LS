`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 6/21/2020
	DESCRIPTION: Combinational logic block whos responsibility is to determine the read/write process of the context values. Feedback values decision is used for read since the 
		     Q and Q_Feedback are two clock cycles apart, Q data that is fedback will be needed for next cycle and cant read/write same location on same clock cycle so we store the data,
		     write, but dont read, and save a variable telling the context mux to used saved updated values from feedback.

	Write has 2 bits:
	Bit 1: For regular mode we need up update A, B, C, N
	Bit 2: For run interruption mode we need to update A, N, Nn
======================================================================================================================================================================================================
*/
module DetermineContextRead_Write #(parameter Q_length = `Q_length, A_length = `A_length, B_length = `B_length, C_length = `C_length, N_length = `N_length,
					      Nn_length = `Nn_length, Context_rw = `Context_rw)
				   (input [Q_length - 1:0] Q_Feedback, input [A_length - 1:0] A_Feedback, input [B_length - 1:0] B_Feedback, 
				    input [C_length - 1:0] C_Feedback, input [N_length - 1:0] N_Feedback, input [Nn_length - 1:0] Nn_Feedback, input [Q_length - 1:0] Q,
				    input [Context_rw - 1:0] determineWrite, output reg [Context_rw - 1:0] write_Context_Memory, output reg read_Context_Memory,
				    output [Q_length - 1:0] Q_Write, output [A_length - 1:0] A_Write, output [B_length - 1:0] B_Write, output [C_length - 1:0] C_Write, 
				    output [N_length - 1:0] N_Write, output [Nn_length - 1:0] Nn_Write, input start_enc, output [Q_length - 1:0] Q_Read,
				    output useFeedbackValues, input clk, input reset, output [Q_length - 1:0] Q_Updated, output [A_length - 1:0] A_Updated, 
				    output [B_length - 1:0] B_Updated, output [C_length - 1:0] C_Updated, output [N_length - 1:0] N_Updated, output [Nn_length - 1:0] Nn_Updated,
				    input start_enc_feedback);

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire useFeedbackValuesDecision;
	wire [1:0] start_enc_count_out;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	reg [1:0] start_enc_count_in;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/

/* Context Mux covers the case of sequential contexts being the same but if Q_Feedback and Q from 2 clock cycles (2 image samples)
   are equal than we need to pass the feedback parameters to the context mux, since it takes a clock cycle to write to memory and we
   need the updated parameters during the current clock cycle. Aka if we wrote to memory the data would be ready after we need it.
*/
	defparam UseFeedbackValues.size = 1;
	Register UseFeedbackValues (.dataIn(useFeedbackValuesDecision), .dataOut(useFeedbackValues), .enable(start_enc), .clk(clk), .reset(reset));

	defparam Q_Update.size = Q_length;
	Register Q_Update (.dataIn(Q_Feedback), .dataOut(Q_Updated), .enable(start_enc), .clk(clk), .reset(reset));

	defparam A.size = A_length;
	Register A (.dataIn(A_Feedback), .dataOut(A_Updated), .enable(start_enc), .clk(clk), .reset(reset));

	defparam B.size = B_length;
	Register B (.dataIn(B_Feedback), .dataOut(B_Updated), .enable(start_enc), .clk(clk), .reset(reset));
 
	defparam C.size = C_length;
	Register C (.dataIn(C_Feedback), .dataOut(C_Updated), .enable(start_enc), .clk(clk), .reset(reset));

	defparam N.size = N_length;
	Register N (.dataIn(N_Feedback), .dataOut(N_Updated), .enable(start_enc), .clk(clk), .reset(reset));

	defparam Nn.size = Nn_length;
	Register Nn (.dataIn(Nn_Feedback), .dataOut(Nn_Updated), .enable(start_enc), .clk(clk), .reset(reset));

	defparam Start_Enc_Count.size = 2;
	Register Start_Enc_Count (.dataIn(start_enc_count_in), .dataOut(start_enc_count_out), .enable(start_enc), .clk(clk), .reset(reset));

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign Q_Write = Q_Feedback;
	assign A_Write = A_Feedback;
	assign B_Write = B_Feedback;
	assign C_Write = C_Feedback;
	assign N_Write = N_Feedback;
	assign Nn_Write = Nn_Feedback;
	assign Q_Read = Q;
		//Q!=0 needed to rid of a false positive on reset
	assign useFeedbackValuesDecision = (Q == Q_Feedback && start_enc_count_out > 2 && Q != 0) ? 1 : 0;
	

// dont need to read if context memories have the same context number, just need to use the feedback values
	always @ (Q or Q_Feedback or determineWrite or start_enc or useFeedbackValuesDecision or start_enc_feedback) begin
		
		write_Context_Memory = 0;
		read_Context_Memory = 0;

		if (start_enc) begin
			if (useFeedbackValuesDecision) read_Context_Memory = 0;
			else read_Context_Memory = 1;
		end
	
		if(start_enc_feedback) begin
			write_Context_Memory = determineWrite;
		end
	end

/* 
======================================================================================================================================================================================================
	SEQUENTIAL LOGIC
======================================================================================================================================================================================================
*/

	always @ (posedge clk) begin
		if (start_enc && start_enc_count_out <= 2) begin
			start_enc_count_in = start_enc_count_out + 1;
		end
		else start_enc_count_in = start_enc_count_out;
	end


endmodule 
