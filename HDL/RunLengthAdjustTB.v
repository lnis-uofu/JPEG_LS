`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module RunLengthAdjustTB #(parameter runindex_length = `runindex_length, runcount_length = `runcount_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE)();

	integer i;

	reg [runcount_length - 1:0] run_length;
	reg [runcount_length - 1:0] run_length_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg [runcount_length - 1:0] remainder_subtract_accum;
	reg [runcount_length - 1:0] remainder_subtract_accum_test_values [DATA_SAMPLE_SIZE - 1:0];
	
	wire [runcount_length - 1:0] run_length_remainder;
	reg [runcount_length - 1:0] run_length_remainder_test_values [DATA_SAMPLE_SIZE - 1:0];

	RunLengthAdjust AdjustRL (.run_length(run_length), .remainder_subtract_accum(remainder_subtract_accum), .run_length_remainder(run_length_remainder));

	initial begin
			
		$readmemb("Run_count_output_test.mem", run_length_test_values);
		$readmemb("Run_count_remainder_test.mem",run_length_remainder_test_values);
		$readmemb("remainder_subtract_accum_test.mem", remainder_subtract_accum_test_values);

		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin
			
			$display("Iteration %d", i + 1);

			run_length = run_length_test_values [i];
			remainder_subtract_accum = remainder_subtract_accum_test_values[i];

			#10;
		
			if (run_length_remainder != run_length_remainder_test_values[i]) begin
				$display("Run length remainder was expected to be %d, but was calculated as %d", run_length_remainder_test_values[i], run_length_remainder);
				$finish;
			end
				
		end

		$display("TB completed without error");
		$finish;

	end

endmodule
		

