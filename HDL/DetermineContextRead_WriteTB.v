`include "Parameterize_JPEGLS.v"
`include "DetermineContextRead_Write.v"

module DetermineContextRead_WriteTB #(parameter Q_length = `Q_length, Context_rw = `Context_rw)();

	reg start_enc_feedback, start_enc;
	reg clk, reset;
	reg [Q_length - 1:0] Q_Feedback;
	reg [Q_length - 1:0] Q;
	reg [Context_rw - 1:0] determineWrite;

	wire [Context_rw - 1:0] write_Context_Memory;
	wire read_Context_Memory;


	DetermineContextRead_Write RW (.Q_Feedback(Q_Feedback),.Q(Q), .determineWrite(determineWrite), .write_Context_Memory(write_Context_Memory), .read_Context_Memory(read_Context_Memory), .start_enc_feedback(start_enc_feedback), .start_enc(start_enc),
				       .clk(clk), .reset(reset));


	always #5 clk = !clk;


	initial begin
	
		reset = 0;
		clk = 0;
		start_enc = 0; start_enc_feedback = 0;
		Q = 1; Q_Feedback = 1;
		determineWrite = 0;
		#11;
		reset = 1;
		#10;
		reset = 0;
		#10;
		start_enc = 1;
		#60;
		
		//Test for not reading context memory if past 2 cycles of start enc and Q Feedback == Q, we have to wait 2 cycles since the feedback value wont return to us till 2 cycles later, we do not want a false positive
		if(read_Context_Memory == 1) begin
			$display("Memory should not be read when Q_Feedback == Q");
			$finish;
		end

		#10;

		Q = 10;

		#10;

		if(read_Context_Memory == 0) begin
			$display("Memory should be read when Q_Feedback != Q");
			$finish;
		end

		determineWrite = 1;
		#10;

		if(write_Context_Memory != 0) begin
			$display("Start_Enc_Feedback value is not set, so we should not be writing to memory");
			$finish;
		end

		start_enc_feedback = 1;
		#10;

		if(write_Context_Memory != 1) begin
			$display("Start_Enc_Feedback value is  set, we should be writing to memory");
			$finish;
		end

		$display("TB completed without error");
		$finish;
		
	end
endmodule 