
`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module RiceEncodingTB #(parameter DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE, modresidual_length = `modresidual_length, k_length = `k_length, mode_length = `mode_length, 
				    J_length = `J_length, unary_length = `unary_length, remaindervalue_length = `remaindervalue_length, encodedpixel_width = `encodedpixel_width, 
				    encodedlength_width = `encodedlength_width, N_Nn_Compare_length = `N_Nn_Compare_length, runcount_length = `runcount_length) ();

	integer i;
	integer encoded_pixel_compare_value;

	reg clk, reset;

	reg [modresidual_length - 1:0] errValue;
	reg [modresidual_length - 1:0] errValue_test_values [DATA_SAMPLE_SIZE - 1:0];
	
	reg B_N_Compare; 
	reg B_N_Compare_test_values [DATA_SAMPLE_SIZE - 1:0]; 

	reg [k_length - 1:0] k; 
	reg [k_length - 1:0] k_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg [N_Nn_Compare_length - 1:0] N_Nn_Compare; 
	reg [N_Nn_Compare_length - 1:0] N_Nn_Compare_test_values [DATA_SAMPLE_SIZE - 1:0]; 
			
	reg [mode_length - 1:0] mode; 
	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1:0]; 

	reg RIType;
	reg RIType_test_values [DATA_SAMPLE_SIZE - 1:0]; 

	reg [J_length - 1:0] J; 
	reg [J_length - 1:0] J_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg [J_length - 1:0] J_Comp; 
	reg [J_length - 1:0] J_Comp_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg [J_length - 1:0] J_Recurring_Mode_Two; 
	reg [J_length - 1:0] J_Recurring_Mode_Two_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg hit;
	reg hit_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg [runcount_length - 1:0] run_length;
	reg [runcount_length - 1:0] run_length_test_values [DATA_SAMPLE_SIZE - 1:0];
		        
	reg do_run_encoding;
	reg do_run_encoding_test_values [DATA_SAMPLE_SIZE - 1:0];

	wire [unary_length - 1:0] unary;
	reg [unary_length - 1:0] unary_test_values [DATA_SAMPLE_SIZE - 1:0];

	wire [remaindervalue_length - 1:0] remainder_value; 
	reg [remaindervalue_length - 1:0] remainder_value_test_values [DATA_SAMPLE_SIZE - 1:0]; 

	wire [encodedpixel_width - 1:0] encoded_pixel; 
	reg [encodedpixel_width - 1:0] encoded_pixel_test_values [DATA_SAMPLE_SIZE - 1:0]; 
		        
	wire [encodedlength_width - 1:0] encoded_length;
	reg [encodedlength_width - 1:0] encoded_length_test_values [DATA_SAMPLE_SIZE - 1:0];

	wire limit_overflow;
	reg limit_overflow_test_values [DATA_SAMPLE_SIZE - 1:0];

	RiceEncoding coder (.errValue(errValue), .B_N_Compare(B_N_Compare), .k(k), .N_Nn_Compare(N_Nn_Compare), .mode(mode), .RIType(RIType), 
			      .J(J), .hit(hit), .unary(unary), .remainder_value(remainder_value), .encoded_pixel(encoded_pixel), 
		              .encoded_length(encoded_length), .limit_overflow(limit_overflow), .run_length(run_length), .do_run_encoding(do_run_encoding),
			    .J_Recurring_Mode_Two(J_Recurring_Mode_Two), .J_Comp(J_Comp), .clk(clk), .reset(reset));

	always #5 clk = !clk;

	initial begin
		$readmemb("Residual_modulo_test.mem", errValue_test_values);
		$readmemb("B_N_Compare_test.mem", B_N_Compare_test_values);
		$readmemb("k_test.mem", k_test_values);
		$readmemb("N_Nn_Compare_test.mem", N_Nn_Compare_test_values);
		$readmemb("mode_test.mem", mode_test_values);
		$readmemb("RIType_test.mem", RIType_test_values);
		$readmemb("J_value_test.mem", J_test_values);
		$readmemb("hit_test.mem", hit_test_values);
		$readmemb("unary_value_test.mem", unary_test_values);
		$readmemb("remainder_value_test.mem", remainder_value_test_values);
		$readmemb("encoded_length_test.mem", encoded_length_test_values);
		$readmemb("encoded_value_test.mem", encoded_pixel_test_values);
		$readmemb("limit_overflow_test.mem", limit_overflow_test_values);
		//$readmemb("do_run_encoding_test.mem", do_run_encoding_test_values);
		$readmemb("Run_count_remainder_test.mem", run_length_test_values);
		$readmemb("J_Comp_value_test.mem", J_Comp_test_values);
		$readmemb("J_recurring_mode_two_value_test.mem", J_Recurring_Mode_Two_test_values);

		$display("Initializing Values");

		clk = 0;
		reset = 0;
		#11;
		reset = 1;
		#10;
		reset = 0;
		#10;

		$display("Starting TB");

		for (i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin

			$display("Iteration %d", i + 1);		

			@(posedge clk) errValue = errValue_test_values[i];
			B_N_Compare = B_N_Compare_test_values[i];
			k = k_test_values[i];
			N_Nn_Compare = N_Nn_Compare_test_values[i];
			mode = mode_test_values[i];
			RIType = RIType_test_values[i];
			J = J_test_values[i];
			hit = hit_test_values [i];
			run_length = run_length_test_values[i];
			J_Comp = J_Comp_test_values[i];
			J_Recurring_Mode_Two = J_Recurring_Mode_Two_test_values[i];

			if(mode_test_values[i+1] == 2 && mode == 1) do_run_encoding = 1;
			else if (((mode == 2 && mode_test_values[i-1] == 0) || (mode == 2 && mode_test_values[i-1] == 2)) && i >= 2) do_run_encoding = 1;
			else do_run_encoding = 0;

			#1;			

			if (unary != unary_test_values[i]) begin
				$display("Unary was expected to be %b, but unary was calculated as %b", unary_test_values[i], unary);
				$finish;
			end

			if (remainder_value != remainder_value_test_values[i]) begin
				$display("Remainder value was expected to be %b, but remainder value was calculated as %b", remainder_value_test_values[i], remainder_value);
				$finish;
			end

			encoded_pixel_compare_value = encoded_pixel;
			if (encoded_pixel_compare_value != encoded_pixel_test_values[i]) begin
				$display("Encoded pixel was expected to be %b, but encoded pixel was calculated as %b", encoded_pixel_test_values[i], encoded_pixel_compare_value);
				$finish;
			end

			if (encoded_length != encoded_length_test_values[i]) begin
				$display("Encoded length was expected to be %b, but encoded length was calculated as %b", encoded_length_test_values[i], encoded_length);
				$finish;
			end

			if (limit_overflow != limit_overflow_test_values[i]) begin
				$display("Limit overflow was expected to be %b, but limit overflow was calculated as %b", limit_overflow_test_values[i], limit_overflow);
				$finish;
			end
		end

		$display("TB Complete without error");
		$finish;
	end
endmodule