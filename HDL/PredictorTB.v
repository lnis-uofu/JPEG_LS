`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module PredictorTB #(parameter pixel_length = `pixel_length, mode_length = `mode_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE)();

	integer i;
	
	reg [pixel_length - 1:0] a, b, c;
	reg [mode_length - 1:0] mode;
	reg RIType;
	
	wire [pixel_length - 1:0] Px;

	reg [pixel_length - 1:0] a_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] b_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] c_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg RIType_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] Px_test_values [DATA_SAMPLE_SIZE - 1:0];

	Predictor Predict (.a(a), .b(b), .c(c), .mode(mode), .RIType(RIType), .x_prediction(Px));

	initial begin
		$readmemb("a_test.mem", a_test_values);
		$readmemb("b_test.mem", b_test_values);
		$readmemb("c_test.mem", c_test_values);
		$readmemb("mode_test.mem", mode_test_values);
		$readmemb("RIType_test.mem", RIType_test_values);
		$readmemb("Px_test.mem", Px_test_values);

		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin
			
			$display("Iteration %d", i + 1);

			a = a_test_values[i];
			b = b_test_values[i];
			c = c_test_values[i];
			mode = mode_test_values[i];
			RIType = RIType_test_values[i];
		
			#10;

			if(Px != Px_test_values[i]) begin
				$display("Px was expected to be %d, but was calculated as %d", Px_test_values[i], Px);
				$finish;
			end
		end
		$display("TB completed without error");
		$finish;
	end

endmodule