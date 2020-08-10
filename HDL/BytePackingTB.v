`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module BytePackingTB #(parameter encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width, dataOut_length = `dataOut_length,
			         DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE, remaindervalue_length = `remaindervalue_length, ENCODED_BITSTREAM_SIZE = `ENCODED_BITSTREAM_SIZE) ();

	integer i, j, a, h, clk_counter;
	integer handle1;
	integer bitAccumTotal;

	reg [ENCODED_BITSTREAM_SIZE - 1:0] dataOut_accum;
	//Single value range only in systemverilog
	reg [ENCODED_BITSTREAM_SIZE - 1:0] dataOut_accum_test [1:0];

	reg clk;
	reg reset; 

	reg start; 

	reg start_enc;
	reg start_enc_test_values [DATA_SAMPLE_SIZE - 1:0];

 	reg [encodedpixel_width - 1:0] encoded_pixel;
 	reg [encodedpixel_width - 1:0] temp_pixel_value;
	reg [encodedpixel_width - 1:0] encoded_pixel_test_values [DATA_SAMPLE_SIZE - 1:0]; 
	
        reg [encodedlength_width - 1:0] encoded_length;
	reg [encodedlength_width - 1:0] encoded_length_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg [remaindervalue_length - 1:0] remainder_value;
	reg [remaindervalue_length - 1:0] remainder_value_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg EOF; 
		   
	reg limit_overflow;
	reg limit_overflow_test_values [DATA_SAMPLE_SIZE - 1:0];

	wire dataReady;

	wire [dataOut_length - 1:0] dataOut;
	reg [dataOut_length - 1:0] dataOut_test_values [DATA_SAMPLE_SIZE - 1:0];

	wire [encodedlength_width - 1:0] data_Sample_Size;
	reg [encodedlength_width - 1:0] data_Sample_Size_test_values [DATA_SAMPLE_SIZE - 1:0];

	wire endOfDataStream;

	BitPackerUnrolled Packer (.clk(clk), .reset(reset), .start(start), .start_enc(start_enc), .encoded_pixel(encoded_pixel), .encoded_length(encoded_length),
		          .EOF(EOF), .limit_overflow(limit_overflow), .dataReady(dataReady), .dataOut(dataOut), .data_Sample_Size(data_Sample_Size),
			  .remainder_value(remainder_value), .endOfDataStream(endOfDataStream));

	always #5 clk = ~clk;

	initial begin

		$readmemb("encoded_length_test.mem", encoded_length_test_values);
		$readmemb("encoded_value_test.mem", encoded_pixel_test_values);
		$readmemb("limit_overflow_test.mem", limit_overflow_test_values);
		$readmemb("start_enc_test.mem", start_enc_test_values);
		$readmemb("remainder_value_test.mem", remainder_value_test_values);
		$readmemb("encoded_bitstream_test.mem", dataOut_accum_test);

		clk = 0;
		reset = 1;
		clk_counter = 0;
		start = 0;
		#20;
		reset = 0;
		#25;

		start = 1;

		#10;
		
		start = 0;

		clk_counter = 0;
		bitAccumTotal = 0;
		h = 0;
		#60;

		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin
			$display("Iteration %d", i + 1);

			//start_enc = start_enc_test_values[i];
			@(posedge clk) start_enc = 1;
			encoded_length = encoded_length_test_values[i];
			temp_pixel_value = encoded_pixel_test_values[i];
			limit_overflow = limit_overflow_test_values[i];
			remainder_value = remainder_value_test_values[i];
			for(a = 0; a < encoded_length; a = a + 1) begin
				encoded_pixel[encodedpixel_width - 1 - a] = temp_pixel_value[encoded_length - 1 - a]; 
			end
			
			if(i < DATA_SAMPLE_SIZE - 1) EOF = 0;
			else EOF = 1;

			#5;
		
			if(dataReady) begin
				bitAccumTotal = bitAccumTotal + data_Sample_Size;
				for(j = 0; j < data_Sample_Size; j = j + 1) begin
					dataOut_accum[h] = dataOut[dataOut_length - 1 - j];
					h = h + 1;
				end
			end

		end
		$fdisplay(handle1, dataOut_accum); 
		$fclose(handle1);
		$display("Data output:         %b", dataOut_accum);
		$display("Data expected output %b", dataOut_accum_test[0]);

		for(i = 0; i < ENCODED_BITSTREAM_SIZE; i = i + 1) begin
			if(dataOut_accum[i] != dataOut_accum_test[0][i]) begin
				$display("On index %d, dataOut_accum was expected to be %b, but dataOut_accum was calculated as %b", i + 1, dataOut_accum_test[0][i], dataOut_accum[i]);
				$finish;
			end
		end
		$display("TB completed without error, file generated");
		$finish;

	end

endmodule