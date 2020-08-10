`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module ErrorMod_MapTB #(parameter residual_length = `residual_length, modresidual_length = `modresidual_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE)();

	integer i;

	reg [residual_length - 1:0] errValue;
	reg [residual_length - 1:0] errorValue_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [modresidual_length - 1:0] errorModulo_test_values [DATA_SAMPLE_SIZE - 1:0];

	wire [modresidual_length - 1:0] errorModulo;



	ErrorMod_Map moduloReduction (.errValue(errValue), .errorModulo(errorModulo));

	initial begin
		$readmemb("Residual_test.mem", errorValue_test_values);
		$readmemb("Residual_modulo_test.mem", errorModulo_test_values);
	
		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin
		
			$display("Iteration %d", i + 1);

			errValue = errorValue_test_values[i];

			#10;

			if(errorModulo != errorModulo_test_values[i]) begin
				$display("Error Modulo is expected to be: %d, but Error Modulo calculated is: %d", i, errorModulo_test_values[i], errorModulo);
				$finish;
			end
		end
		$display("TB passed without failures");
		$finish;
	end

endmodule
