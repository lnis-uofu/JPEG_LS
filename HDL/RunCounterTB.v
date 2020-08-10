`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module RunCounterTB #(parameter pixel_length = `pixel_length, runcount_length = `runcount_length, mode_length = `mode_length, 
				runvalue_length = `runvalue_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE)();

	integer i;

	reg [pixel_length - 1:0] a;
	reg [pixel_length - 1:0] x;
	reg [runcount_length - 1:0] run_count;
	reg [mode_length - 1:0] mode;
	reg clk, reset, start_enc;

	wire [runcount_length - 1:0] run_count_new;
	wire [runvalue_length - 1:0] run_value;

	reg [pixel_length - 1:0] a_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] x_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [runcount_length - 1:0] run_count_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [runcount_length - 1:0] run_count_new_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [runvalue_length - 1:0] run_value_test_values [DATA_SAMPLE_SIZE - 1:0];

	RunCounter RunCount (.a(a), .x(x), .run_count(run_count), .mode(mode), .run_count_new(run_count_new), .run_value(run_value), .clk(clk), .reset(reset), .start_enc(start_enc) );

	always #5 clk = !clk;

	initial begin
		$readmemb("a_test.mem", a_test_values);
		$readmemb("x_test.mem", x_test_values);
		$readmemb("run_count_test.mem", run_count_test_values);
		$readmemb("mode_test.mem", mode_test_values);
		$readmemb("run_count_new_test.mem", run_count_new_test_values);
		$readmemb("run_value_test.mem", run_value_test_values);

		clk = 0;
		reset = 0;
		start_enc = 0;
		#11;
		reset = 1;
		#10;
		reset = 0;
		#10;

		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin

			$display("Iteration %d", i+1);

			@(posedge clk) a = a_test_values[i];
			x = x_test_values[i];
			run_count = run_count_test_values[i];
			mode = mode_test_values[i];
			
			#5;
			
			if (run_count_new != run_count_new_test_values[i]) begin
				$display("On iteration %d, Run_count_new was expected to be %d but was calculated as %d", i+ 1, run_count_new_test_values[i], run_count_new);
				$finish;
			end

			if (run_value != run_value_test_values[i]) begin
				$display("On iteration %d, Run_value was expected to be %d but was calculated as %d", i + 1, run_value_test_values[i], run_value);
				$finish;
			end
		end
		$display("TB completed without error");
		$finish;
	end

endmodule
