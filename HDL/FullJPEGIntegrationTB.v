`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

//image = [0,0,90,74,68,50,43,205,64,145,145,145,100,145,145,145];

module FullJPEGIntegrationTB #(parameter pixel_length = `pixel_length, dataOut_length = `dataOut_length, encodedlength_width =`encodedlength_width, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE,
			     		 ENCODED_BITSTREAM_SIZE = `ENCODED_BITSTREAM_SIZE, Q_length = `Q_length, A_length = `A_length, B_length = `B_length, C_length = `C_length, 
			    		 N_length = `N_length, Nn_length = `Nn_length, CONTEXT_MEM_DEPTH = `CONTEXT_MEM_DEPTH, Context_rw = `Context_rw, colindex_length = `colindex_length,
			 	         HEADER_MARKER_SIZE = `HEADER_MARKER_SIZE) ();
	//(311*135*4)/2
	localparam TOTAL_BYTES_MEM = 335880;

	/* 622 rows per mem (depth)
	   135 * 8 bits per row = 1104
	*/

	integer i, j, h;
	integer MEM_ONE_OFFSET, MEM_TWO_OFFSET;
	integer MEM_PREV_ONE_OFFSET, MEM_PREV_TWO_OFFSET;
	integer handle1;
	integer dataAccumTotal;

	wire [pixel_length - 1:0] pixelIn;
	wire [pixel_length - 1:0] prevPixelIn;
	reg clk; 
	reg reset; 
	reg start; 
	wire read_MEM_ONE, read_MEM_TWO;
	wire read_PREV_MEM_ONE, read_PREV_MEM_TWO; 
	wire dataReady; 
	wire [dataOut_length - 1:0] dataOut; 
	wire [encodedlength_width - 1:0] dataSize;

	reg [pixel_length - 1:0] pixelInDelay;
	reg [pixel_length - 1:0] prevPixelInDelay;

	reg [ENCODED_BITSTREAM_SIZE - 1:0] dataOut_accum;
	//Single value range only in systemverilog
	reg [ENCODED_BITSTREAM_SIZE - 1:0] dataOut_accum_test [1:0];

	reg [A_length - 1: 0] A_in;
	reg [B_length - 1:0] B_in;
	reg [C_length - 1:0] C_in;
	reg [N_length - 1:0] N_in;
	reg [N_length - 1:0] Nn_in;

 	wire [Q_length - 1:0] Q_in;
	wire [A_length - 1: 0] A_out;
	wire [B_length - 1:0] B_out;
	wire [C_length - 1:0] C_out;
	wire [N_length - 1:0] N_out;
	wire [N_length - 1:0] Nn_out;
	wire [Q_length - 1:0] Q_out;

	wire [Context_rw - 1:0] write_Context_Memory;
	wire read_Context_Memory;

	wire [colindex_length - 1:0] col_index;
	wire [colindex_length - 1:0] prev_col_index;

	JPEGLS_Final JPEGLS_ENCODER (.pixelIn(pixelIn), .prevPixelIn(prevPixelIn), .read_MEM_ONE(read_MEM_ONE), .read_MEM_TWO(read_MEM_TWO), .read_PREV_MEM_ONE(read_PREV_MEM_ONE), 
				     .read_PREV_MEM_TWO(read_PREV_MEM_TWO), .col_index(col_index), .prev_col_index(prev_col_index), .clk(clk), .reset(reset), .dataReady(dataReady),
	         		     .dataOut(dataOut), .dataSize(dataSize), .start(start), .endOfDataStream(endOfDataStream),  .A_in(A_in), .B_in(B_in), .C_in(C_in), .N_in(N_in),
				     .Nn_in(Nn_in), .Q_in(Q_in), .A_out(A_out), .B_out(B_out), .C_out(C_out), .N_out(N_out), .Nn_out(Nn_out), .Q_out(Q_out), .write_Context_Memory(write_Context_Memory),
				     .read_Context_Memory(read_Context_Memory));

	always #5 clk = ~clk;

	reg [pixel_length - 1:0] MEM_ONE [TOTAL_BYTES_MEM - 1:0];
	reg [pixel_length - 1:0] MEM_TWO [TOTAL_BYTES_MEM - 1:0];

	reg [A_length - 1:0] A_MEM [CONTEXT_MEM_DEPTH - 1:0];
	reg [B_length - 1:0] B_MEM [CONTEXT_MEM_DEPTH - 1:0];
	reg [C_length - 1:0] C_MEM [CONTEXT_MEM_DEPTH - 1:0];
	reg [N_length - 1:0] N_MEM [CONTEXT_MEM_DEPTH - 1:0];
	reg [Nn_length - 1:0] Nn_MEM [1:0];

	assign #5 prevPixelIn = prevPixelInDelay;
	assign #5 pixelIn = pixelInDelay;

	initial begin
		$readmemb("image_one_final_data.mem", MEM_ONE);
		$readmemb("image_two_final_data.mem", MEM_TWO);
		$readmemb("final_encoded_bitstream_test.mem", dataOut_accum_test);


		for(i = 0; i < CONTEXT_MEM_DEPTH; i = i + 1) begin
			A_MEM[i] = 4;
			B_MEM[i] = 0;
			C_MEM[i] = 0;
			N_MEM[i] = 1;
		end
		
		Nn_MEM[1] = 0; Nn_MEM[0] = 0;
		
		reset = 0; start = 0; clk = 0; pixelInDelay = 0; prevPixelInDelay = 0; h = 0;
		A_in = 0; B_in = 0; C_in = 0; N_in = 0; Nn_in = 0;
		MEM_ONE_OFFSET = 0; MEM_TWO_OFFSET = 0; dataAccumTotal = 0;
		MEM_PREV_ONE_OFFSET = 0; MEM_PREV_TWO_OFFSET = 0;

		#10;
		reset = 1;
		#10;
		reset = 0;
		#10;
		start = 1;
		#100;
		start = 0;
	end


	always @ (posedge clk) begin
		if(read_MEM_ONE) pixelInDelay = MEM_ONE[(MEM_ONE_OFFSET * 135) + col_index];
		else if(read_PREV_MEM_ONE) prevPixelInDelay = MEM_ONE[(MEM_PREV_ONE_OFFSET * 135) + prev_col_index];

		if(MEM_ONE_OFFSET == 0 && col_index == 135 && read_MEM_ONE) begin
			MEM_ONE_OFFSET = MEM_ONE_OFFSET + 1;
		end
		else if(col_index == 136 && read_MEM_ONE) begin
			MEM_ONE_OFFSET = MEM_ONE_OFFSET + 1;
		end

		if(prev_col_index == 135 && read_PREV_MEM_ONE) begin
			MEM_PREV_ONE_OFFSET = MEM_PREV_ONE_OFFSET + 1;
		end
	end


	always @ (posedge clk) begin
		if(read_MEM_TWO) pixelInDelay = MEM_TWO[(MEM_TWO_OFFSET * 135) + col_index];
		else if(read_PREV_MEM_TWO) prevPixelInDelay = MEM_TWO[(MEM_PREV_TWO_OFFSET * 135) + prev_col_index];

		if(col_index == 136 && read_MEM_TWO) begin
			MEM_TWO_OFFSET = MEM_TWO_OFFSET + 1;
		end

		if(prev_col_index == 135 && read_PREV_MEM_TWO) begin
			MEM_PREV_TWO_OFFSET = MEM_PREV_TWO_OFFSET + 1;
		end
	end

	always @ (posedge clk) begin
		if (dataReady) begin
			if(dataAccumTotal >= HEADER_MARKER_SIZE) begin
				for(j = 0; j < dataSize; j = j + 1) begin
					dataOut_accum[ENCODED_BITSTREAM_SIZE - 1 - h] = dataOut[dataOut_length - 1 - j];
					h = h + 1;
				end
			end

			dataAccumTotal = dataAccumTotal + dataSize;
		end
	end

	//Simulated Memories
	always @ (posedge clk) begin

		//normal mode write
		if(write_Context_Memory == 1) begin
			A_MEM[Q_out] <= A_out;
			B_MEM[Q_out] <= B_out;
			C_MEM[Q_out] <= C_out;
			N_MEM[Q_out] <= N_out;
		end
		//run interruption non end of line mode write
		else if (write_Context_Memory == 2) begin
			A_MEM[Q_out] <= A_out;
			N_MEM[Q_out] <= N_out;
			Nn_MEM[Q_out - 365] <= Nn_out;
		end

		if(read_Context_Memory) begin
			A_in <= A_MEM[Q_in];
			B_in <= B_MEM[Q_in];
			C_in <= C_MEM[Q_in];
			N_in <= N_MEM[Q_in];
			if (Q_in <= 364) Nn_in <= 0;
			else Nn_in <= Nn_MEM[Q_in - 365];
		end

	end

	always @ (dataAccumTotal) begin
		if((dataAccumTotal >= ENCODED_BITSTREAM_SIZE + HEADER_MARKER_SIZE)) begin
	
		
			$display("Data output:         %b", dataOut_accum);
			$display("Data expected output %b", dataOut_accum_test[0]);
	

			for(i = 0; i < ENCODED_BITSTREAM_SIZE; i = i + 1) begin
				if(dataOut_accum[ENCODED_BITSTREAM_SIZE - i] != dataOut_accum_test[0][ENCODED_BITSTREAM_SIZE - i]) begin
					$display("On index %d, dataOut_accum was expected to be %b, but dataOut_accum was calculated as %b", i, dataOut_accum_test[0][ENCODED_BITSTREAM_SIZE - i], dataOut_accum[ENCODED_BITSTREAM_SIZE - i]);
					$finish;
				end
			end

			$display("TB completed without error, file generated");
			$finish;
		end
	end

	/*always @ (endOfDataStream) begin
		if(endOfDataStream) begin
	
		
			$display("Data output:         %b", dataOut_accum);
			$display("Data expected output %b", dataOut_accum_test[0]);
	

			for(i = ENCODED_BITSTREAM_SIZE - 1; i >= 0; i = i - 1) begin
				if(dataOut_accum[i] != dataOut_accum_test[0][i]) begin
					$display("On index %d, dataOut_accum was expected to be %b, but dataOut_accum was calculated as %b", i, dataOut_accum_test[0][i], dataOut_accum[i]);
					$finish;
				end
			end

			$display("TB completed without error, file generated");
			$finish;
		end
	end*/
	
endmodule