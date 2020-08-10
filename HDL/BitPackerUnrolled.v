`timescale 1ns/1ns
`include "CounterRegister.v"
`include "BitPackerFunction.v"
`include "Parameterize_JPEGLS.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 5/18/2020
	DESCRIPTION: MEALY FSM whose responsiblity is interfacing the encoded data for the JPEG encoder to an external module for collecting the variable length output data. The FSM will ensure
		     that header and footer senteniels are specified for the decoder to detect the beginning and end of CNN encoded output.

		NOTE: Limit Overflow Encoding always results in 32 bits. This ensures that an even number of bytes is always used.
======================================================================================================================================================================================================
*/

module BitPackerUnrolled #(parameter encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width, dataOut_length = `dataOut_length,
			     MAX_LOAD_SIZE = `MAX_LOAD_SIZE, HEADER_MARKER_SIZE = `HEADER_MARKER_SIZE, FOOTER_MARKER_SIZE = `FOOTER_MARKER_SIZE,
			     header_counter_size = `header_counter_size, footer_counter_size = `footer_counter_size, remaindervalue_length = `remaindervalue_length,
			     J_length = `J_length, mode_length = `mode_length)
		  	  (input clk, input reset, input start, input start_enc, input [encodedpixel_width - 1:0] encoded_pixel, input [encodedlength_width - 1:0] encoded_length,
		  	   input EOF, input [remaindervalue_length - 1:0] remainder_value, input limit_overflow, output dataReady, output reg [dataOut_length - 1:0] dataOut, 
		  	   output reg [encodedlength_width - 1:0] data_Sample_Size, output reg endOfDataStream, input [J_length - 1:0] J, input [mode_length - 1:0] mode);

/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/

	/* 
		FF D8 - Start of image (SOI) marker
		FF F7 - Start of JPEG LS Frame (SOF) marker
		FF DA - Start of scan (SOC) marker
	*/
	localparam [HEADER_MARKER_SIZE - 1:0] HEADER_MARKER = 'hFFD8FFF7FFDA;

	/*
		 FF D9 - End of Image (EOI) marker
	*/
	localparam [FOOTER_MARKER_SIZE - 1:0] FOOTER_MARKER = 'hFFD9;

	localparam BYTE_LENGTH = 8;

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [header_counter_size - 1:0] header_counter;
	wire [footer_counter_size - 1:0] footer_counter;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/


	reg decrement_header_counter;
	reg reset_header_counter;
	reg [header_counter_size - 1:0] in_header_counter;

	//need a counter to count the clock cycles, 
	reg decrement_footer_counter;
	reg reset_footer_counter;
	reg [footer_counter_size - 1:0] in_footer_counter;
	
	reg sentenielReady;
	reg sendData;
	wire dataFuncitonReady;

	wire [3:0] previous_byteoverflow_encoded_data_length;
	wire [3:0] current_byteoverflow_data_length;

	wire [7:0] previous_byteoverflow_data;
	wire [7:0] current_byteoverflow_data;

	wire [7:0] current_byteoverflow_data_overflow;
	wire [7:0] current_byteoverflow_data_no_overflow;

	wire [3:0] current_byteoverflow_data_length_overflow;
	wire [3:0] current_byteoverflow_data_length_no_overflow;

	wire [dataOut_length - 1:0] final_encoded_pixel;
	wire [encodedlength_width - 1:0] final_encoded_length;

	wire [dataOut_length - 1:0] final_encoded_pixel_overflow;
	wire [dataOut_length - 1:0] final_encoded_pixel_no_overflow;

	wire [encodedlength_width - 1:0] final_encoded_length_no_overflow;
	wire [encodedlength_width - 1:0] final_encoded_length_limit;

	reg [2:0] state, next;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/

	defparam Header_Counter.default_Value = HEADER_MARKER_SIZE;
	defparam Header_Counter.size = header_counter_size;
	CounterRegister Header_Counter (.dataIn(in_header_counter), .dataOut(header_counter), .enable(decrement_header_counter), .reset(reset | reset_header_counter), .clk(clk));

	defparam Footer_Counter.default_Value = FOOTER_MARKER_SIZE;
	defparam Footer_Counter.size = footer_counter_size;
	CounterRegister Footer_Counter (.dataIn(in_footer_counter), .dataOut(footer_counter), .enable(decrement_header_counter), .reset(reset | reset_header_counter), .clk(clk));


	defparam Previous_Byte_Overflow_Length.size = 4;
	Register Previous_Byte_Overflow_Length (.dataIn(current_byteoverflow_data_length), .dataOut(previous_byteoverflow_encoded_data_length), .clk(clk), .reset(reset), .enable(start_enc));

	defparam Previous_Byte_Overflow_Data.size = 8;
	Register Previous_Byte_Overflow_Data (.dataIn(current_byteoverflow_data), .dataOut(previous_byteoverflow_data), .clk(clk), .reset(reset), .enable(start_enc));
	

	BitPackerFunciton BPFunction (.encoded_pixel(encoded_pixel), .encoded_length(encoded_length), .previous_byteoverflow_encoded_data_length(previous_byteoverflow_encoded_data_length), 
			   	      .final_encoded_pixel(final_encoded_pixel_no_overflow), .final_encoded_length(final_encoded_length_no_overflow), .current_byteoverflow_data_length(current_byteoverflow_data_length_no_overflow),
				      .previous_encoded_data(previous_byteoverflow_data), .current_overflow_data(current_byteoverflow_data_no_overflow), .dataReady(dataFuncitonReady));
	
	LimitOverflowEncoding LOEnding ( .encoded_pixel(encoded_pixel), .previous_byteoverflow_encoded_data_length(previous_byteoverflow_encoded_data_length), .remainder_value(remainder_value),
					 .current_byteoverflow_data_length(current_byteoverflow_data_length_overflow), .previous_encoded_data(previous_byteoverflow_data), 
					 .current_overflow_data(current_byteoverflow_data_overflow), .final_encoded_pixel(final_encoded_pixel_overflow), .J(J), .mode(mode),
					 .final_encoded_length_limit(final_encoded_length_limit), .encoded_length(encoded_length));

	//LimitOverflowOneCounter (.remainder_value(remainder_value), .previous_one_run(



/* 
======================================================================================================================================================================================================
	FSM NATURAL CODE
======================================================================================================================================================================================================
*/

	localparam [2:0]	IDLE				 	 = 3'b000,
				START				 	 = 3'b001,
				WAIT_TO_ENCODE	 		 	 = 3'b010,
				LOAD_DATA_OUT				 = 3'b011,
				END 	 				 = 3'b100;

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/
	//If we need to send data out because encoding is active then we will tell the external modules data is ready to be sampled
	assign dataReady = (start_enc | sentenielReady) & sendData;

	assign final_encoded_pixel = (limit_overflow) ? final_encoded_pixel_overflow : final_encoded_pixel_no_overflow;
	assign final_encoded_length = (limit_overflow) ? 32 : final_encoded_length_no_overflow;

	assign current_byteoverflow_data_length = (limit_overflow) ? current_byteoverflow_data_length_overflow : current_byteoverflow_data_length_no_overflow;
	assign current_byteoverflow_data = (limit_overflow) ? current_byteoverflow_data_overflow : current_byteoverflow_data_no_overflow;

/* 
======================================================================================================================================================================================================
	FSM COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/
	always @ (start or encoded_pixel or encoded_length or EOF or limit_overflow or header_counter or footer_counter or state or final_encoded_pixel or final_encoded_length or
		  dataFuncitonReady or start_enc or final_encoded_length_limit or final_encoded_pixel_overflow) begin
		next = 0;
		decrement_header_counter = 0;
		reset_header_counter = 0;
		reset_footer_counter = 0;
		dataOut = 0;
		data_Sample_Size = 0;
		in_header_counter = header_counter;
		in_footer_counter = footer_counter;
		decrement_footer_counter = 0;
		endOfDataStream = 0;
		sentenielReady = 0;
		sendData = 0;
		

		case (state) /* synopsys full_case parallel_case */
/*
============================================================================================================================================================
IDLE:   This state waits for the initial start sequence signal. When the start sequence signal is recieved it moves to the start sequence of 
	sending the header marker.
============================================================================================================================================================
*/
			IDLE: 					     begin
									if(start) next = START;
									else next = IDLE;
								     end

/*
============================================================================================================================================================
START:   This state performs the sequence of sending the header marker for the current CNN output. Once the sequence is completed we will reset
	 the header_counter to a default value specified in order to be ready for the next video input.
============================================================================================================================================================
*/

			START:					     begin
									sendData = 1;
									if (header_counter == HEADER_MARKER_SIZE) begin
										decrement_header_counter = 1;
										in_header_counter = header_counter - 32;
										next = START;
										dataOut = HEADER_MARKER[HEADER_MARKER_SIZE - 1: HEADER_MARKER_SIZE - 1 - 31];
										data_Sample_Size = 32;
										sentenielReady = 1;
									end
									else begin
										next = WAIT_TO_ENCODE;
										reset_header_counter = 1;
										dataOut[dataOut_length - 1: dataOut_length - 1 - 15] = HEADER_MARKER[HEADER_MARKER_SIZE - 1 - 32:0];
										data_Sample_Size = 16;
										sentenielReady = 1;
									end
								     end
/*
============================================================================================================================================================
WAIT_TO_ENCODE:	This state will wait for the windup sequence of the JPEG_LS to be performed and when the first encoding is specified via start_enc
		it will break into the sequence of pushing the incoming encoded data out. Otherwise it will wait until the start sequence is specified.
============================================================================================================================================================
*/
			WAIT_TO_ENCODE:				     begin
									if (start_enc) begin
										if(limit_overflow) begin 
											sendData = 1;
											next = LOAD_DATA_OUT;
											dataOut = final_encoded_pixel_overflow;
											data_Sample_Size = final_encoded_length_limit;
										end
										else begin
											sendData = dataFuncitonReady;
											next = LOAD_DATA_OUT;
											dataOut = final_encoded_pixel;
											data_Sample_Size = final_encoded_length;
										end
									end
									else begin
										next = WAIT_TO_ENCODE;
									end
								     end
/*
============================================================================================================================================================
LOAD_DATA_OUT:	This is the primary stage of the FSM. Will encompass loading encoded data out until the final EOF marker is met. Once the EOF marker is met
		the sequence will branch to the footer_marker to ensure the EOF is specified for the decoder. In the case of run mode in which
		a hit is not made, the stage will wait for the next hit to be processed.
============================================================================================================================================================
*/
			LOAD_DATA_OUT:				     begin
									if (start_enc) begin
										if(limit_overflow) begin
											sendData = 1;
											dataOut = final_encoded_pixel_overflow;
											data_Sample_Size = final_encoded_length_limit;
										end
										else begin
											sendData = dataFuncitonReady;
											dataOut = final_encoded_pixel;
											data_Sample_Size = final_encoded_length;
										end
										if(EOF) next = END;
										else next = LOAD_DATA_OUT;
									end
									else next = LOAD_DATA_OUT;
								     end

/*
============================================================================================================================================================
END:    This state performs the sequence of sending the footer marker for the current CNN output. Once the sequence is completed we will reset
	the footer counter to a default value specified in order to be ready for the next video input.
============================================================================================================================================================
*/
									
			END:					     begin
									sendData = 1;
									if (footer_counter == FOOTER_MARKER_SIZE) begin
										decrement_footer_counter = 1;
										in_footer_counter = footer_counter - 16;
										next = END;
										dataOut[dataOut_length - 1: dataOut_length - FOOTER_MARKER_SIZE] = FOOTER_MARKER;
										data_Sample_Size = 16;
										endOfDataStream = 1;
										sentenielReady = 1;
									end
									else begin
										next = IDLE;
										reset_footer_counter = 1;
										data_Sample_Size = 0;
										sentenielReady = 1;
									end
								     end							
		endcase
	end

/* 
======================================================================================================================================================================================================
	FSM SEQUENTIAL LOGIC
======================================================================================================================================================================================================
*/

	always @ (posedge clk) begin
		if (reset) begin
			state <= IDLE;
		end
		else begin
			state <= next;
		end
	end
endmodule