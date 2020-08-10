`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module PredictionResidualTB #(parameter pixel_length = `pixel_length, C_length = `C_length, mode_length = `mode_length, 
					residual_length = `residual_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE)();

	integer i;

	reg [pixel_length - 1:0] Px;
	reg [pixel_length - 1:0] x;
	reg sign;
	reg [C_length - 1:0] C;
	reg [mode_length - 1:0] mode;
	reg RIType;
	reg a_b_compare;

	reg [residual_length - 1:0] x_residual_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] x_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg sign_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [C_length - 1:0] C_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg a_b_compare_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] Px_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg RIType_test_values [DATA_SAMPLE_SIZE - 1:0];	


	wire [residual_length - 1:0] x_residual;

	 PredictionResidual Residual_X (.x_prediction(Px), .x(x), .sign(sign), .C(C), .mode(mode), .RIType(RIType), .a_b_compare(a_b_compare), .x_residual(x_residual));
	
	initial begin
		$readmemb("Residual_test.mem", x_residual_test_values);
		$readmemb("C_test.mem", C_test_values);
		$readmemb("a_b_compare_test.mem", a_b_compare_test_values);
		$readmemb("Px_test.mem", Px_test_values);
		$readmemb("RIType_test.mem", RIType_test_values);
		$readmemb("mode_test.mem", mode_test_values);
		$readmemb("sign_test.mem", sign_test_values);
		$readmemb("x_test.mem", x_test_values);

		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin

			$display("Iteration %d", i + 1);
			Px = Px_test_values[i];
			x = x_test_values[i];
			sign = sign_test_values[i];
			C = C_test_values[i];
			mode = mode_test_values[i];
			RIType = RIType_test_values[i];
			a_b_compare = a_b_compare_test_values[i];
		
			#10;
			if(x_residual != x_residual_test_values[i]) begin
				$display("x_residual for index %d is incorrect, x_residual expected is: %d, but x_residual computed is: %d", i, x_residual_test_values[i], x_residual);
				$finish;
			end
		end
		$display("TB pass with no failures");
		$finish;
	end

endmodule
