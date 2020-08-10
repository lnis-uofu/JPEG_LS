`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module k_calculationTB #(parameter N_length = `N_length, A_length = `A_length, mode_length = `mode_length, temp_length = `temp_length, 
				   k_length = `k_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE)();

	integer i;

	reg [N_length - 1:0] N;
	reg [N_length - 1:0] N_test_values [DATA_SAMPLE_SIZE - 1 : 0];
	
	reg [A_length - 1:0] A;
	reg [A_length - 1:0] A_test_values [DATA_SAMPLE_SIZE - 1 : 0];

	reg [mode_length - 1:0] mode;
	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1 : 0];

	reg RIType;
	reg RIType_test_values [DATA_SAMPLE_SIZE - 1 : 0];

	reg [temp_length - 1:0] temp;
	reg [temp_length - 1:0] temp_test_values [DATA_SAMPLE_SIZE - 1 : 0];

	wire [k_length - 1:0] k;
	reg [k_length - 1:0] k_final [DATA_SAMPLE_SIZE - 1 : 0];

	reg [k_length - 1:0] k_inc;
	

	k_calculation_unrolled k_calc (.N(N), .A(A), .mode(mode), .RIType(RIType), .temp(temp), .k_inc(k_inc), .k(k));

	initial begin
		k_inc = 0;

		$readmemb("RIType_test.mem", RIType_test_values);
		$readmemb("mode_test.mem", mode_test_values);
		$readmemb("N_test.mem", N_test_values);
		$readmemb("A_test.mem", A_test_values);
		$readmemb("Temp_test.mem", temp_test_values);
		$readmemb("k_test.mem", k_final);

		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin
			$display("Iteration: %d", i+1);
			
			mode = mode_test_values[i];
			N = N_test_values[i];
			A = A_test_values[i];
			RIType = RIType_test_values[i];
			temp = temp_test_values[i];

			#10;
			if(k_final[i] != k) begin
				$display("On iteration %d k was expected to be: %d, but k was calculated as: %d", i + 1, k_final[i], k);
				$finish;
			end
		end
		$display("Testbench completed without error");
		$finish;		
	end

endmodule

