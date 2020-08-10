`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module TempCalculationTB #(parameter A_length = `A_length, N_length = `N_length, temp_length = `temp_length,
				     DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE, mode_length = `mode_length)();

	integer i;

	reg [A_length - 1:0] A_Select;
	reg [N_length - 1:0] N_Select;
	reg RIType;
	reg [mode_length - 1:0] mode;

	wire [temp_length - 1:0] temp;

	reg [A_length - 1:0] A_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [N_length - 1:0] N_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [temp_length - 1:0] temp_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg RIType_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1:0];

	Temp_Calculation temp_calc (.A_Select(A_Select), .N_Select(N_Select), .RIType(RIType), .temp(temp), .mode(mode));

	initial begin

		$readmemb("A_test.mem", A_test_values);
		$readmemb("N_test.mem", N_test_values);
		$readmemb("Temp_test.mem", temp_test_values);
		$readmemb("RIType_test.mem", RIType_test_values);
		$readmemb("mode_test.mem", mode_test_values);
		
		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin

			$display("Iteration i", i + 1);		

			A_Select = A_test_values[i];
			N_Select = N_test_values[i];
			RIType = RIType_test_values[i];
			mode = mode_test_values[i];
		
			#10;

			if (temp_test_values[i] != temp) begin
				$display("Temp was expected to be %d, but was calculated as %d", temp_test_values[i], temp);
				$finish;
			end
		end
		
		$display("TB completed without error");
		$finish;
	end

endmodule


