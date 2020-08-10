`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module ContextGradientTB #(parameter quantizedQ_length = `quantizedQ_length, mode_length = `mode_length, 
				     mappedQ_length = `mappedQ_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE) ();

	integer i;

	localparam [7:0] scalar_One = 8'd81;
	localparam [7:0] scalar_Two = 8'd9;

	reg [quantizedQ_length - 1:0] D_1, D_2, D_3;
	reg RIType;
	reg [mode_length - 1:0] mode;
	reg sign;

	wire [mappedQ_length - 1:0] C_t;

	reg [quantizedQ_length - 1:0] D_1_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [quantizedQ_length - 1:0] D_2_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [quantizedQ_length - 1:0] D_3_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg RIType_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [mappedQ_length - 1:0] C_t_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg sign_test_values [DATA_SAMPLE_SIZE - 1:0];

	ContextGradient ContextMapping (.D_1(D_1), .D_2(D_2), .D_3(D_3), .RIType(RIType), .mode(mode), .C_t(C_t), .sign(sign));

	initial begin

		$readmemb("D_1_gradient_quant_test.mem", D_1_test_values);
		$readmemb("D_2_gradient_quant_test.mem", D_2_test_values);
		$readmemb("RIType_test.mem", RIType_test_values);
		$readmemb("mode_test.mem", mode_test_values);
		$readmemb("C_t_test.mem", C_t_test_values);
		$readmemb("D_3_gradient_quant_test.mem", D_3_test_values);
		$readmemb("sign_test.mem", sign_test_values);

		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin

			$display("Iteration %d", i + 1);
			
			D_1 = D_1_test_values[i];
			D_2 = D_2_test_values[i];
			D_3 = D_3_test_values[i];
			mode = mode_test_values[i];
			sign = sign_test_values[i];
			RIType = RIType_test_values[i];

			#5;
			
			if(C_t != C_t_test_values[i]) begin
				$display("On iteration %d, C_t was expected to be %d but C_t was calculated as %d", i + 1, C_t_test_values[i], C_t);
				$finish;
			end
		end

		$display("Simulation passed with no errors");
		$finish;
	end
endmodule