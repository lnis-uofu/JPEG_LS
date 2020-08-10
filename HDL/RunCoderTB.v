`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module RunCoderTB #(parameter runcount_length = `runcount_length, runindex_length = `runindex_length, mode_length = `mode_length, J_length = `J_length, 
			      runcountercompare_length = `runcountercompare_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE)();

	integer i, j, run_accum_index;

	reg [runcount_length - 1:0] run_counter;
	wire hit;
	reg [runcountercompare_length - 1:0] run_counter_compare;
	reg [runindex_length - 1:0] run_index_compare;
	reg [runindex_length - 1:0] run_index;
	reg [mode_length - 1:0] mode;
	reg hit_compare;
	reg clk,reset;

	wire [runcount_length - 1:0] run_length;
	reg [runcount_length - 1:0] remainder_subtract_accum;
	wire [runcount_length - 1:0] remainder_subtract;
	wire [runcountercompare_length - 1:0] run_counter_compare_new;
	wire [runindex_length - 1:0] run_index_new;
	wire [J_length - 1:0] J;
	wire [J_length - 1:0] J_Comp;
	wire [J_length - 1:0] J_Recurring_Mode_2;
	reg start_enc;

	always #5 clk = !clk;

	reg [runindex_length - 1:0] run_index_input_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [runindex_length - 1:0] run_index_output_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg hit_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [runcount_length - 1:0] run_count_output_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [runcountercompare_length - 1:0] run_count_compare_output_test_values[DATA_SAMPLE_SIZE - 1:0];
	reg [runcountercompare_length - 1:0] run_count_compare_input_test_values[DATA_SAMPLE_SIZE - 1:0];
	reg [J_length - 1:0] J_values [DATA_SAMPLE_SIZE - 1:0];
	reg [J_length - 1:0] J_Comp_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [J_length - 1:0] J_recurring_mode_two_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [runcount_length - 1:0] remainder_subtract_accum_test_values [DATA_SAMPLE_SIZE - 1:0];
	

	RunCoder Run_Coder (.run_counter(run_counter), .run_counter_compare(run_counter_compare), .run_index(run_index), . hit(hit), .mode(mode),
			    .clk(clk), .reset(reset), .run_length(run_length), .run_counter_compare_new(run_counter_compare_new), .remainder_subtract_accum(remainder_subtract_accum),
			    .run_index_new(run_index_new), .J(J), .J_Comp(J_Comp), .J_Recurring_Mode_2(J_Recurring_Mode_2), .start_enc(start_enc, .remainder_subtract(remainder_subtract));

	initial begin
		
		clk = 0;
		reset = 0;
		#11;
		reset = 1;
		#10;
		reset = 0;
		#10;

		$readmemb("Run_index_output_test.mem", run_index_output_test_values);
		$readmemb("Run_index_input_test.mem", run_index_input_test_values);
		$readmemb("Run_count_output_test.mem", run_count_output_test_values);
		$readmemb("mode_test.mem", mode_test_values);
		$readmemb("Run_count_compare_input_test.mem",run_count_compare_input_test_values);
		$readmemb("Run_count_compare_output_test.mem",run_count_compare_output_test_values);
		$readmemb("hit_test.mem", hit_test_values);
		$readmemb("J_value_test.mem", J_values);
		$readmemb("J_Comp_value_test.mem", J_Comp_test_values);
		$readmemb("J_recurring_mode_two_value_test.mem", J_recurring_mode_two_test_values);
		$readmemb("remainder_subtract_accum_test.mem", remainder_subtract_accum_test_values);	

		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin
			$display("Iteration i", i + 1);

			@(posedge clk) run_counter = run_count_output_test_values[i];
			 run_index = run_index_input_test_values[i];
			 run_counter_compare = run_count_compare_input_test_values[i];
			 mode = mode_test_values[i];
			 remainder_subtract_accum = remainder_subtract_accum_test_values[i];
			 start_enc = 1;

			#1;
	
			if(run_index_new != run_index_output_test_values[i]) begin
				$display("Run Index Output was expected to be %d, but we calculated as %d", run_index_output_test_values[i], run_index_new);
				$finish;
			end

			if(hit != hit_test_values[i]) begin
				$display("Hit was expected to be %d, but we calculated as %d", hit_test_values[i], hit);
				$finish;
			end

			if(run_length != run_count_output_test_values[i]) begin
				$display("Run length was expected to be %d, but we calculated as %d", run_count_output_test_values[i], run_length);
				$finish;
			end

			if(run_counter_compare_new != run_count_compare_output_test_values[i]) begin
				$display("Run counter compare output was expected to be %d, but we calculated as %d", run_count_compare_output_test_values[i], run_counter_compare_new);
				$finish;
			end

			if (J != J_values[i]) begin
				$display("J was expected to be %d, but we calculated as %d", J_values[i], J);
				$finish;
			end

			if (i > 0) begin
				if(mode_test_values[i-1] == 2 && mode == 2) begin
					if (J_Recurring_Mode_2 != J_recurring_mode_two_test_values[i]) begin
						$display("J was expected to be %d, but we calculated as %d", J_values[i], J_Recurring_Mode_2);
						$finish;
					end
				end
			end

			if (J_Comp != J_Comp_test_values[i]) begin
				$display("J_Comp was expected to be %d, but we calculated as %d", J_Comp_test_values[i], J);
				$finish;
			end
		
		end


		$display("TB Completed without error");
		$finish;
	end

endmodule
