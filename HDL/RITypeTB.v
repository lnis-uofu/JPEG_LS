`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module RITypeTB #(parameter pixel_length = `pixel_length, mode_length = `mode_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE)();

	integer i;

	reg [pixel_length - 1:0] a, b;
	reg [mode_length - 1:0] mode;
	wire RIType, a_b_compare;

	reg [pixel_length - 1:0] a_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] b_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg RIType_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg a_b_compare_test_values [DATA_SAMPLE_SIZE - 1:0];

	RIType RunInterruption (.a(a), .b(b), .mode(mode), .RIType(RIType), .a_b_compare(a_b_compare));

	initial begin

		$readmemb("a_test.mem", a_test_values);
		$readmemb("b_test.mem", b_test_values);
		$readmemb("mode_test.mem", mode_test_values);
		$readmemb("RIType_test.mem", RIType_test_values);
		$readmemb("a_b_compare_test.mem", a_b_compare_test_values);

		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin

			$display("Iteration: %d", i + 1);

			a = a_test_values[i];
			b = b_test_values[i];
			mode = mode_test_values[i];

			#10;

			if(RIType != RIType_test_values[i]) begin
				$display("On iteration %d, RIType was expected to be %d but was calculated as %d", i + 1, RIType_test_values[i], RIType);
				$finish;
			end

			if(a_b_compare_test_values[i] != a_b_compare) begin
				$display("On iteration %d, a_b_compare was expected to be %d but was calculated as %d", i + 1, a_b_compare_test_values[i], a_b_compare);
				$finish;
			end
		end
		$display("TB completed without error");
		$finish;
	end

endmodule
