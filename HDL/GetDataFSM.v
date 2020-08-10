`timescale 1ns/1ns
`include "context_reg.v"
`include "index_reg.v"
`include "prev_index_reg.v"
`include "Parameterize_JPEGLS.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: MEALY FSM whose responsiblity is interfacing the pixel memory to the JPEG encoder. It is ensuring correct context formation of current/previous rows of pixels and
		     start of the encoding when these conditons are met. In addition it keeps track of where in the pixel context we are and ensures EOF and EOL identifiers are made accordingly.
======================================================================================================================================================================================================
*/

module GetDataFSM #(parameter pixel_length = `pixel_length, colindex_length = `colindex_length, rowindex_length = `rowindex_length, 
			      num_of_memories = `num_of_memories, depthindex_length = `depthindex_length)
		(input clk, input reset, input start, input [pixel_length - 1:0] pixelIn, input [pixel_length - 1:0] prevPixelIn, output reg start_enc, 
		 output reg EOF, output [pixel_length - 1:0] a,  output [pixel_length - 1:0] b,  output [pixel_length - 1:0] c,  output [pixel_length - 1:0] d,  
		 output [pixel_length - 1:0] x, output reg read_MEM_ONE, output reg read_MEM_TWO, output reg read_PREV_MEM_ONE, output reg read_PREV_MEM_TWO,
		 output [colindex_length - 1:0] col_index, output [colindex_length -1:0] prev_col_index, output reg EOL);


/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/
	/*
	Actually 311 rows and 240 column but they are 0 addressed. 
	Due to nature of how data is read and columns are incremented they becomes aligned with a 1 index, not 0 index.
	*/

	localparam FINAL_COLUMN = 135;
	localparam FINAL_ROW = 310;
	localparam FINAL_DEPTH = 239;

	//for TB
	//localparam FINAL_DEPTH = 10;

/* 
======================================================================================================================================================================================================
	FSM ONE-HOT CODE
======================================================================================================================================================================================================
*/

	parameter [1:0] 	//synopsys enum code
				IDLE 				= 2'd0,
				GET_DATA_ROW_ONE		= 2'd1,
		   	        GET_DATA			= 2'd2;

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [num_of_memories - 1:0] read_MEM; //1 -> FIFO 0 , 2 -> FIFO 1
	wire [num_of_memories -1:0] read_Prev_MEM;
	wire [rowindex_length - 1:0] row_index;
	wire [pixel_length - 1:0] prev_A, prev_B, prev_D, two_prev_B;
	wire [pixel_length - 1:0] dataToB, dataToC, dataToA, dataMuxC;

	wire [pixel_length - 1:0] XtoA, BtoA, Din;
	wire [pixel_length - 1:0] saveB, saveA, saveD, saveC;
	wire [pixel_length - 1:0] shiftBtoC, shiftDtoB, BInputData;

	wire [depthindex_length - 1:0] depth_index;

	wire FSM_is_started;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	//State variables
	reg [1:0] state;
	reg [1:0] next;

	//State Space
	reg increment_row, increment_col, reset_col, reset_row, increment_mem, reset_mem, increment_prev_mem, reset_prev_mem;
	reg increment_prev_col, reset_prev_col, increment_depth, reset_depth;
	
	//Used for shifting context
	reg shiftXtoA, loadBtoC, loadDtoB;

	//Used for loading in context for startup of a row
	reg  loadPrevBtoA, save_Prev_B, save_Prev_C;

	//Used in demultiplexer to tell where to save the current/previous pixel data (what context we are trying to get)
	reg [1:0] savePixelContext; 
	reg [1:0] savePrevPixelContext;

	//Enables memories to be read
	reg read_pixel, read_prev_pixel;

	//Save pixels read from memory to X and D
	reg [pixel_length - 1:0] dataToD;

	//Needed for the start of each row
	reg reset_x;

	reg enable_c, enable_b, enable_d, enable_x, enable_a, enable_two_prev_b, enable_prev_a, enable_prev_b, enable_prev_d, enable_load_prev_a;

	reg FSM_started;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/

	//Used for determining where in image we are
	defparam row.size = 9;
	index_reg row (.clk(clk), .reset(reset_row | reset), .increment(increment_row), .index(row_index));
	index_reg col (.clk(clk), .reset(reset_col | reset), .increment(increment_col), .index(col_index));
	index_reg depth (.clk(clk), .reset(reset_depth | reset), .increment(increment_depth), .index(depth_index));

	//needs to be reset to column 3
	prev_index_reg prev_col (.clk(clk), .reset(reset_prev_col | reset), .increment(increment_prev_col), .index(prev_col_index));

	//these tell us which memory to read from
	defparam read_Memory_Index.size = 2;
	index_reg read_Memory_Index (.clk(clk), .reset(reset_mem | reset), .increment(increment_mem), .index(read_MEM));

	defparam read_Prev_Memory_Index.size = 2;
	index_reg read_Prev_Memory_Index (.clk(clk), .reset(reset_prev_mem | reset), .increment(increment_prev_mem), .index(read_Prev_MEM)); //for the previous row data

	//Current context variables
	context_reg context_c (.clk(clk), .reset(reset), .enable(enable_c), .dataIn(dataMuxC), .dataOut(c));
	context_reg context_b (.clk(clk), .reset(reset), .enable(enable_b), .dataIn(BInputData), .dataOut(b));
	context_reg context_d (.clk(clk), .reset(reset), .enable(enable_d), .dataIn(Din), .dataOut(d));
	context_reg context_x (.clk(clk), .reset(reset | reset_x), .enable(enable_x), .dataIn(pixelIn), .dataOut(x));
	context_reg context_a (.clk(clk), .reset(reset), .enable(enable_a | enable_load_prev_a), .dataIn(dataToA), .dataOut(a));

	//These are saved to avoid the shift cycle of the deisgn for loadup on the start of a new line
	context_reg context_two_prev_b (.clk(clk), .reset(reset), .enable(enable_two_prev_b), .dataIn(prev_B), .dataOut(two_prev_B)); //save for two rows, load into c on column 0 row 2 (0,1,2)
	context_reg prev_a (.clk(clk), .reset(reset), .enable(enable_prev_a), .dataIn(saveA), .dataOut(prev_A));
	context_reg prev_b (.clk(clk), .reset(reset), .enable(enable_prev_b), .dataIn(saveB), .dataOut(prev_B));
	context_reg prev_d (.clk(clk), .reset(reset), .enable(enable_prev_d), .dataIn(saveD), .dataOut(prev_D));

	defparam FSMStarted.size = 1;
	Register FSMStarted (.dataIn(FSM_started), .dataOut(FSM_is_started), .enable(1'b1), .clk(clk), .reset(reset));

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/
	assign BInputData = (col_index == FINAL_COLUMN + 2) ? dataToB : shiftDtoB;	

	assign dataToA = (col_index <= FINAL_COLUMN) ? XtoA : BtoA;

	//used
	assign Din = (col_index <= FINAL_COLUMN) ? prevPixelIn : prev_D;

	assign dataMuxC = (col_index <= FINAL_COLUMN) ? shiftBtoC : dataToC;

	//used
	assign XtoA = ({8{shiftXtoA}}) & x;

	//used
	assign BtoA = {8{loadPrevBtoA}} & prev_B;


	//used (for saving previous row context)
	assign saveA = x;


	assign saveB = x;


	assign saveC = x;


	assign saveD = x;

	//used
	assign dataToB = ({8{save_Prev_B}}) & prev_B;

	//used
	assign dataToC = {8{save_Prev_C}} & two_prev_B;
 
	//These are for when the column in not 0 we can just shift data to the left 
	//used
	assign shiftBtoC = {8{loadBtoC}} & b;
	
	//used
	assign shiftDtoB = {8{loadDtoB}} & d;

	always @ (savePixelContext) begin
		shiftXtoA = 1'b0;
		enable_x = 1'b0;
		enable_a = 1'b0;
		if(savePixelContext) begin
			enable_x = 1'b1;
			if (col_index > 1) begin
				shiftXtoA = 1'b1;
				enable_a = 1'b1;
			end
		end
	end

	always @ (savePrevPixelContext) begin
		case (savePrevPixelContext) //synopsys full_case parallel_case
			2'b01: begin
				enable_d = 1'b1;
				enable_b = 1'b1;
				enable_c = 1'b1;
				enable_load_prev_a = 1'b1;
				save_Prev_B = 1'b1;
				save_Prev_C = 1'b1;
				loadPrevBtoA = 1'b1;
			end
			2'b10: begin
				enable_d = 1'b1;
				enable_b = 1'b1;
				enable_c = 1'b1;
				loadBtoC = 1'b1;
				loadDtoB = 1'b1;
			end
			2'b11: begin
				enable_d = 1'b0;
				enable_b = 1'b1;
				enable_c = 1'b1;
				loadBtoC = 1'b1;
				loadDtoB = 1'b1;
			end
			default: begin
					enable_d = 1'b0;
					enable_b = 1'b0;
					enable_load_prev_a = 1'b0;
					enable_c = 1'b0;
					//enable_two_prev_b = 1'b0;
					save_Prev_B = 1'b0;
					save_Prev_C = 1'b0;
					loadPrevBtoA = 1'b0;
					loadBtoC = 1'b0;
					loadDtoB = 1'b0;
					dataToD = 8'b0;
					//savePrevBforC = 1'b0;
				end
		endcase
	end

	always @ (read_pixel) begin
		read_MEM_ONE = 1'b0;
		read_MEM_TWO = 1'b0;
		if (read_pixel) begin
			case (read_MEM) //synopsys full_case
				2'b00: read_MEM_ONE = 1'b1;
				2'b01: read_MEM_TWO = 1'b1;
			endcase
		end
	end

	always @ (read_prev_pixel) begin
		read_PREV_MEM_ONE = 1'b0;
		read_PREV_MEM_TWO = 1'b0;
		if (read_prev_pixel) begin
			case (read_Prev_MEM) //synopsys full_case
				2'b00: read_PREV_MEM_ONE = 1'b1;
				2'b01: read_PREV_MEM_TWO = 1'b1;
			endcase
		end
	end
			


/* 
======================================================================================================================================================================================================
	FSM COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/
	always @ (state or start or x or col_index) begin
		//Needed for full case statement SYSGEN error in DC if not used, also rids inferred latches
		start_enc = 1'b0;
		next = 2'b00;
		read_pixel = 1'b0;
		read_prev_pixel = 1'b0;
		increment_col = 1'b0;
		increment_prev_col = 1'b0;
		increment_mem = 1'b0;
		increment_prev_mem = 1'b0;
		increment_row = 1'b0;
		increment_depth = 1'b0;
		reset_depth = 1'b0;
		reset_prev_col = 1'b0;
		reset_col = 1'b0;
		reset_mem = 1'b0;
		reset_prev_mem = 1'b0;
		reset_row = 1'b0;
		savePixelContext =  1'b0;
		savePrevPixelContext =  2'b00;
		EOL = 1'b0;
		EOF = 1'b0;
		enable_prev_a = 1'b0;
		enable_prev_b = 1'b0;
		enable_prev_d = 1'b0;
		enable_two_prev_b = 1'b0;
		reset_x = 1'b0;
		enable_b = 1'b0;
		enable_c = 1'b0;
		FSM_started = 0;

		case(state) //synopsys full_case parallel_case

/*
============================================================================================================================================================
IDLE: This state waits for the initial start sequence signal. When the start sequence signal is recieved it enables the dual port RF Port A (read port)
      and reads the first pixel of the frame. We also increment the column so as to be ready for the next pixel. After reading the first pixel
      we store it and read the second pixel to get it ready for saving. After reading the second pixel we move to the encoding for the first row
      state. Otherwise we stay in the idle state.
============================================================================================================================================================
*/

			IDLE:				if(start & !FSM_is_started) begin
								read_pixel = 1'b1; 
								increment_col = 1'b1; 
								next = IDLE;
								FSM_started = 1;
							end
							else if (start & FSM_is_started) begin
								read_pixel = 1'b1;
								savePixelContext = 1;
								increment_col = 1'b1; 
								next = GET_DATA_ROW_ONE;
								FSM_started = 0;
							end
							else next = IDLE;

/*
=============================================================================================================================================================
GET_DATA_ROW_ONE: This is for processing the first row of data. It is different since the context paramters other than a will always be 0. The data is saved
		  from the load that is achieved in IDLE state. for the first start_enc and second start_enc we will need to save context pixels a,b, and d
		  We will need to save the current pixel X to A via a shift. 
		  The state will remain here until we reach the EOL (column 136 to column 137). From here we will reset the column index, increment the row, 
		  and increment the memory index we want to read from, since we will be toggling between the two memories to avoid pipeline stalls. 
		  Save Pixel for C is important as in column 0 for every row starting with row 2 we need to save the previous a to c. The previous a 
		  in the previous row was b from 2 rows ago, so instead of keeping 3 memories we save the first b (x) for row 2.
=============================================================================================================================================================
*/

			GET_DATA_ROW_ONE:		begin	
								if (col_index == 8'd2) begin
									savePixelContext = 1; 
									enable_prev_b = 1'b1;
									enable_prev_a = 1'b1;
									increment_col = 1'b1;
									next = GET_DATA_ROW_ONE;
									read_pixel = 1'b1;	
									start_enc = 1;
								end 		
								else if (col_index == 8'd3) begin
									enable_prev_d = 1'b1;
									savePixelContext = 1; 
									increment_col = 1'b1;
									next = GET_DATA_ROW_ONE;
									read_pixel = 1'b1;	
									start_enc = 1;
								end					
								else if (col_index >= 8'd4 && col_index <= FINAL_COLUMN) begin
									savePixelContext = 1; 
									increment_col = 1'b1;
									next = GET_DATA_ROW_ONE;
									read_pixel = 1'b1;	
									start_enc = 1;
								end
								else if (col_index == FINAL_COLUMN + 1) begin
									savePixelContext = 1; 
									increment_col = 1'b1;
									next = GET_DATA_ROW_ONE;
									start_enc = 1;
									EOL = 1;
								end
								else if (col_index == (FINAL_COLUMN + 2)) begin
									next = GET_DATA;
									reset_col = 1'b1;
									increment_row = 1'b1;
									increment_mem = 1'b1; //current mem index memory 2 now
									//also need to load previous context variables into current b, d
									savePrevPixelContext = 2'b01;
									
									enable_two_prev_b = 1'b1;
								end
							end

/*
=============================================================================================================================================================
GET_DATA: This state is the bulk of the computation time, after we have done the specific context conditions of the first row for each image, we 
	  stay in this state to grab the remainder of the context variables. X needs to be updated each time the column is reset to the base parallel 
	  condition. It follows to read the pixel then start the encoding after saving the read pixel into x. This is done until data reaches the end of 
	  the column index, in which it resets and increments the row (and if at the end of the rows for the image we increment depth). Once we reach 
	  the final row/depth combination we reset the image. Just as in the first row, we will save the first pixels to the context previous pixel
	  registers to avoid a startup in loading the context pixels from memory at the beginning for each row. At the reset of all the columns and 
	  increment of the row/depth we will shift the previous pixel context registers to the current pixel context registers.
=============================================================================================================================================================
*/
				
			GET_DATA:			begin
								if(col_index == 8'd0) begin
									increment_col = 1'b1;
									read_pixel = 1'b1; //read from memory 2 here, we will save the data after read in GET_B
									read_prev_pixel = 1'b1;
									increment_prev_col = 1'b1;
									next = GET_DATA;
								end
								else if (col_index == 8'd1) begin
									savePixelContext = 1'b1; //save data to X and start encoding
									read_pixel = 1'b1;
									increment_col = 1'b1; 
									next = GET_DATA;
								end
								else if (col_index == 8'd2) begin
									savePixelContext = 1'b1; //save data to X and start encoding
									savePrevPixelContext = 2'b10;
									read_pixel = 1'b1;
									read_prev_pixel = 1'b1;
									enable_prev_b = 1'b1;
									enable_prev_a = 1'b1;
									increment_col = 1'b1; 
									read_prev_pixel = 1'b1;
									increment_prev_col = 1'b1;
									start_enc = 1;
									next = GET_DATA;
								end
								else if (col_index == 8'd3) begin
									savePixelContext = 1'b1; //save data to X and start encoding
									savePrevPixelContext = 2'b10;
									read_pixel = 1'b1;
									read_prev_pixel = 1'b1;
									enable_prev_d = 1'b1;
									increment_col = 1'b1; 
									read_prev_pixel = 1'b1;
									increment_prev_col = 1'b1;
									start_enc = 1;
									next = GET_DATA;
								end
								else if (col_index >= 8'd4 && col_index <= (FINAL_COLUMN - 1)) begin
									savePixelContext = 1'b1;
									savePrevPixelContext = 2'b10;
									start_enc = 1;
									read_pixel = 1'b1;
									read_prev_pixel = 1'b1;
									increment_col = 1'b1;
									increment_prev_col = 1'b1;
									next = GET_DATA; //now we dont need to load all context, just load new context to D and shift the rest
								end
								else if (col_index == FINAL_COLUMN) begin
									savePrevPixelContext = 2'b11;
									savePixelContext = 1'b1;
									start_enc = 1;
									read_pixel = 1'b1;
									increment_col = 1'b1;
									next = GET_DATA;
								end
								else if (col_index == FINAL_COLUMN + 1) begin
									savePixelContext = 1'b1;
									savePrevPixelContext = 2'b11;
									start_enc = 1;
									read_pixel = 1'b1;
									increment_col = 1'b1;
									next = GET_DATA;

									if(row_index < FINAL_ROW && depth_index <= FINAL_DEPTH) EOL = 1;
									else if(row_index <= FINAL_ROW && depth_index < FINAL_DEPTH) EOL = 1;
									else if (row_index >= FINAL_ROW && depth_index >= FINAL_DEPTH) begin
										EOL = 1'b1;
										EOF = 1'b1;
									end
								end
								else if (col_index == FINAL_COLUMN + 2 && row_index < FINAL_ROW) begin
									next = GET_DATA;
									reset_col = 1'b1;
									reset_prev_col = 1'b1;
									if (read_Prev_MEM == 2'b00) increment_prev_mem = 1'b1;
									else reset_prev_mem = 1'b1;
									if (read_MEM == 2'b00) increment_mem = 1'b1; 
									else reset_mem = 1'b1;
									//also need to load previous context variables into current b, d
									savePrevPixelContext = 2'b01;
									increment_row = 1'b1;
								
									enable_two_prev_b = 1'b1;
									save_Prev_C = 1'b1;
								end
								else if (col_index == (FINAL_COLUMN + 2) && row_index >= FINAL_ROW && depth_index <= (FINAL_DEPTH - 1)) begin
									next = GET_DATA;
									reset_col = 1'b1;
									reset_prev_col = 1'b1;
									if (read_Prev_MEM == 2'b00) increment_prev_mem = 1'b1;
									else reset_prev_mem = 1'b1;
									if (read_MEM == 2'b00) increment_mem = 1'b1; 
									else reset_mem = 1'b1;
									//also need to load previous context variables into current b, d
									savePrevPixelContext = 2'b01;
									increment_depth = 1'b1;
									reset_row = 1'b1;

									enable_two_prev_b = 1'b1;
									save_Prev_C = 1'b1;
								end
								else begin
									reset_col = 1'b1;
									reset_prev_col = 1'b1;
									reset_row = 1'b1;
									reset_depth = 1'b1;
									next = IDLE;
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
		if(reset) state <= IDLE;
		else state <= next;
	end


endmodule    
