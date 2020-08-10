/* verilog_memcomp Version: p1.0.7-EAC */
/* common_memcomp Version: p1.0.0-EAC */
/* lang compiler Version: 4.8.2-EAC Sep 10 2015 14:35:29 */
//
//       CONFIDENTIAL AND PROPRIETARY SOFTWARE OF ARM PHYSICAL IP, INC.
//      
//       Copyright (c) 1993 - 2020 ARM Physical IP, Inc.  All Rights Reserved.
//      
//       Use of this Software is subject to the terms and conditions of the
//       applicable license agreement with ARM Physical IP, Inc.
//       In addition, this Software is protected by patents, copyright law 
//       and international treaties.
//      
//       The copyright notice(s) in this Software does not indicate actual or
//       intended publication of this Software.
//
//      Verilog model for Synchronous Two-Port Register File
//
//       Instance Name:              Context_Memory
//       Words:                      368
//       Bits:                       7
//       Mux:                        4
//       Drive:                      6
//       Write Mask:                 Off
//       Write Thru:                 Off
//       Extra Margin Adjustment:    On
//       Redundany:                  Off
//       Test Muxes                  Off
//       Power Gating:               Off
//       Retention:                  On
//       Pipeline:                   Off
//       Read Disturb Test:	        Off
//       
//       Creation Date:  Fri Apr  3 11:11:04 2020
//       Version: 	r3p0
//
//      Modeling Assumptions: This model supports full gate level simulation
//          including proper x-handling and timing check behavior.  Unit
//          delay timing is included in the model. Back-annotation of SDF
//          (v3.0 or v2.1) is supported.  SDF can be created utilyzing the delay
//          calculation views provided with this generator and supported
//          delay calculators.  All buses are modeled [MSB:LSB].  All 
//          ports are padded with Verilog primitives.
//
//      Modeling Limitations: None.
//
//      Known Bugs: None.
//
//      Known Work Arounds: N/A
//
`timescale 1 ns/1 ps
`define ARM_MEM_PROP 1.000
`define ARM_MEM_RETAIN 1.000
`define ARM_MEM_PERIOD 3.000
`define ARM_MEM_WIDTH 1.000
`define ARM_MEM_SETUP 1.000
`define ARM_MEM_HOLD 0.500
`define ARM_MEM_COLLISION 3.000

module datapath_latch_Context_Memory (CLK,Q_update,SE,SI,D,DFTRAMBYP,mem_path,XQ,Q);
	input CLK,Q_update,SE,SI,D,DFTRAMBYP,mem_path,XQ;
	output Q;

	reg    D_int;
	reg    Q;

   //  Model PHI2 portion
   always @(CLK or SE or SI or D) begin
      if (CLK == 1'b0) begin
         if (SE==1'b1)
           D_int=SI;
         else if (SE==1'bx)
           D_int=1'bx;
         else
           D_int=D;
      end
   end

   // model output side of RAM latch
   always @(posedge Q_update or posedge XQ) begin
      if (XQ==1'b0) begin
         if (DFTRAMBYP==1'b1)
           Q=D_int;
         else
           Q=mem_path;
      end
      else
        Q=1'bx;
   end
endmodule // datapath_latch_Context_Memory

// If ARM_UD_MODEL is defined at Simulator Command Line, it Selects the Fast Functional Model
`ifdef ARM_UD_MODEL

// Following parameter Values can be overridden at Simulator Command Line.

// ARM_UD_DP Defines the delay through Data Paths, for Memory Models it represents BIST MUX output delays.
`ifdef ARM_UD_DP
`else
`define ARM_UD_DP #0.001
`endif
// ARM_UD_CP Defines the delay through Clock Path Cells, for Memory Models it is not used.
`ifdef ARM_UD_CP
`else
`define ARM_UD_CP
`endif
// ARM_UD_SEQ Defines the delay through the Memory, for Memory Models it is used for CLK->Q delays.
`ifdef ARM_UD_SEQ
`else
`define ARM_UD_SEQ #0.01
`endif

`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module Context_Memory (VDDCE, VDDPE, VSSE, QA, CLKA, CENA, AA, CLKB, CENB, AB, DB,
    STOV, EMAA, EMASA, EMAB, RET1N);
`else
module Context_Memory (QA, CLKA, CENA, AA, CLKB, CENB, AB, DB, STOV, EMAA, EMASA, EMAB,
    RET1N);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 7;
  parameter WORDS = 368;
  parameter MUX = 4;
  parameter MEM_WIDTH = 28; // redun block size 4, 12 on left, 16 on right
  parameter MEM_HEIGHT = 92;
  parameter WP_SIZE = 7 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 0;
  parameter UPMS_WIDTH = 1;
  parameter ROWS = 92;

  output [6:0] QA;
  input  CLKA;
  input  CENA;
  input [8:0] AA;
  input  CLKB;
  input  CENB;
  input [8:0] AB;
  input [6:0] DB;
  input  STOV;
  input [2:0] EMAA;
  input  EMASA;
  input [2:0] EMAB;
  input  RET1N;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

`ifdef POWER_PINS
  reg bad_VDDCE;
  reg bad_VDDPE;
  reg bad_VSSE;
  reg bad_power;
`endif
  wire corrupt_power;
  reg pre_charge_st;
  reg pre_charge_st_a;
  reg pre_charge_st_b;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [27:0] mem [0:91];
  reg [27:0] row, row_t;
  reg LAST_CLKA;
  reg [27:0] row_mask;
  reg [27:0] new_data;
  reg [27:0] data_out;
  reg [6:0] readLatch0;
  reg [6:0] shifted_readLatch0;
  reg [6:0] readLatch1;
  reg [6:0] shifted_readLatch1;
  reg LAST_CLKB;
  wire [6:0] QA_int;
  reg XQA, QA_update;
  reg [6:0] mem_path;
  reg XDB_sh, DB_sh_update;
  wire [6:0] DB_int_bmux;
  reg [6:0] writeEnable;
  real previous_CLKA;
  real previous_CLKB;
  initial previous_CLKA = 0;
  initial previous_CLKB = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;
  reg clk0_int;
  reg clk1_int;

  wire [6:0] QA_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire [8:0] AA_;
  reg [8:0] AA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire [8:0] AB_;
  reg [8:0] AB_int;
  wire [6:0] DB_;
  reg [6:0] DB_int;
  reg [6:0] XDB_int;
  wire  STOV_;
  reg  STOV_int;
  wire [2:0] EMAA_;
  reg [2:0] EMAA_int;
  wire  EMASA_;
  reg  EMASA_int;
  wire [2:0] EMAB_;
  reg [2:0] EMAB_int;
  wire  RET1N_;
  reg  RET1N_int;

  assign QA[0] = QA_[0]; 
  assign QA[1] = QA_[1]; 
  assign QA[2] = QA_[2]; 
  assign QA[3] = QA_[3]; 
  assign QA[4] = QA_[4]; 
  assign QA[5] = QA_[5]; 
  assign QA[6] = QA_[6]; 
  assign CLKA_ = CLKA;
  assign CENA_ = CENA;
  assign AA_[0] = AA[0];
  assign AA_[1] = AA[1];
  assign AA_[2] = AA[2];
  assign AA_[3] = AA[3];
  assign AA_[4] = AA[4];
  assign AA_[5] = AA[5];
  assign AA_[6] = AA[6];
  assign AA_[7] = AA[7];
  assign AA_[8] = AA[8];
  assign CLKB_ = CLKB;
  assign CENB_ = CENB;
  assign AB_[0] = AB[0];
  assign AB_[1] = AB[1];
  assign AB_[2] = AB[2];
  assign AB_[3] = AB[3];
  assign AB_[4] = AB[4];
  assign AB_[5] = AB[5];
  assign AB_[6] = AB[6];
  assign AB_[7] = AB[7];
  assign AB_[8] = AB[8];
  assign DB_[0] = DB[0];
  assign DB_[1] = DB[1];
  assign DB_[2] = DB[2];
  assign DB_[3] = DB[3];
  assign DB_[4] = DB[4];
  assign DB_[5] = DB[5];
  assign DB_[6] = DB[6];
  assign STOV_ = STOV;
  assign EMAA_[0] = EMAA[0];
  assign EMAA_[1] = EMAA[1];
  assign EMAA_[2] = EMAA[2];
  assign EMASA_ = EMASA;
  assign EMAB_[0] = EMAB[0];
  assign EMAB_[1] = EMAB[1];
  assign EMAB_[2] = EMAB[2];
  assign RET1N_ = RET1N;

`ifdef POWER_PINS
  assign corrupt_power = bad_power;
`else
  assign corrupt_power = 1'b0;
`endif

   `ifdef ARM_FAULT_MODELING
     Context_Memory_error_injection u1(.CLK(CLKA_), .Q_out(QA_), .A(AA_int), .CEN(CENA_int), .Q_in(QA_int));
  `else
  assign `ARM_UD_SEQ QA_ = (RET1N_ | pre_charge_st) & ~corrupt_power ? ((QA_int)) : {7{1'bx}};
  `endif

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial
  begin
    #0;
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
  end
`endif
  always @ (EMAA_) begin
  	if(EMAA_ < 2) 
   	$display("Warning: Set Value for EMAA doesn't match Default value 2 in %m at %0t", $time);
  end
  always @ (EMASA_) begin
  	if(EMASA_ < 0) 
   	$display("Warning: Set Value for EMASA doesn't match Default value 0 in %m at %0t", $time);
  end
  always @ (EMAB_) begin
  	if(EMAB_ < 2) 
   	$display("Warning: Set Value for EMAB doesn't match Default value 2 in %m at %0t", $time);
  end

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval==1'bx || bitval==1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
	$readmemb(filename, memld);
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
        row_mask =  ( {3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[6], 3'b000, wordtemp[5], 3'b000, wordtemp[4],
          3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1], 3'b000, wordtemp[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
    end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
      data_out = (row >> mux_address);
      mem_path = {data_out[24], data_out[20], data_out[16], data_out[12], data_out[8],
        data_out[4], data_out[0]};
        	#0;
        	XQA = 1'b0; QA_update = 1'b1;
   	$fdisplay(dump_file_desc, "%b", mem_path);
  end
  	end
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [8:0] load_addr;
	input [6:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
        row_mask =  ( {3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[6], 3'b000, wordtemp[5], 3'b000, wordtemp[4],
          3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1], 3'b000, wordtemp[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
  end
  endtask

task dumpaddr;
	output [6:0] dump_data;
	input [8:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  Atemp = dump_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
      data_out = (row >> mux_address);
      mem_path = {data_out[24], data_out[20], data_out[16], data_out[12], data_out[8],
        data_out[4], data_out[0]};
        	#0;
        	XQA = 1'b0; QA_update = 1'b1;
   	dump_data = mem_path;
  	end
  end
  endtask


  task ReadA;
  begin
    if (RET1N_int == 1'bx || RET1N_int == 1'bz) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0 && CENA_int == 1'b0) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0) begin
      // no cycle in retention mode
    end else if (^{(EMAA_int), (EMASA_int)} == 1'bx) begin
  if(isBitX(EMASA_int)) begin 
        XQA = 1'b1; QA_update = 1'b1;
  end
  if(isBitX(EMAA_int)) begin
        XQA = 1'b1; QA_update = 1'b1;
  end
    end else if (^{CENA_int, (STOV_int && !CENA_int), RET1N_int} == 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if ((AA_int >= WORDS) && (CENA_int == 1'b0)) begin
        XQA = 0 ? 1'b0 : 1'b1; QA_update = 0 ? 1'b0 : 1'b1;
    end else if (CENA_int == 1'b0 && (^AA_int) == 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if (CENA_int == 1'b0) begin
      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (row_address > 91)
        row = {28{1'bx}};
      else
        row = mem[row_address];
      data_out = (row >> mux_address);
      mem_path = {data_out[24], data_out[20], data_out[16], data_out[12], data_out[8],
        data_out[4], data_out[0]};
        	#0;
        	XQA = 1'b0; QA_update = 1'b1;
    end
  end
  endtask

  task WriteB;
  begin
    if (RET1N_int == 1'bx || RET1N_int == 1'bz) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0 && CENB_int == 1'b0) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0) begin
      // no cycle in retention mode
    end else if (^{(EMAB_int)} == 1'bx) begin
  if(isBitX(EMAB_int)) begin
      failedWrite(1);
  end
    end else if (^{CENB_int, (STOV_int && !CENB_int), RET1N_int} == 1'bx) begin
      failedWrite(1);
    end else if ((AB_int >= WORDS) && (CENB_int == 1'b0)) begin
    end else if (CENB_int == 1'b0 && (^AB_int) == 1'bx) begin
      failedWrite(1);
    end else if (CENB_int == 1'b0) begin
      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (row_address > 91)
        row = {28{1'bx}};
      else
        row = mem[row_address];
        writeEnable = ~ {7{CENB_int}};
      row_mask =  ( {3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
        3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
      new_data =  ( {3'b000, DB_int[6], 3'b000, DB_int[5], 3'b000, DB_int[4], 3'b000, DB_int[3],
        3'b000, DB_int[2], 3'b000, DB_int[1], 3'b000, DB_int[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
    end
  end
  endtask
  always @ (CENA_ or CLKA_) begin
  	if(CLKA_ == 1'b0) begin
  		CENA_p2 = CENA_;
  	end
  end

`ifdef POWER_PINS
  always @ (VDDCE) begin
      if (VDDCE != 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDCE should be powered down after VDDPE, Illegal power down sequencing in %m at %0t", $time);
       end
        $display("In PowerDown Mode in %m at %0t", $time);
        failedWrite(0);
      end
      if (VDDCE == 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDPE should be powered up after VDDCE in %m at %0t", $time);
        $display("Illegal power up sequencing in %m at %0t", $time);
       end
        failedWrite(0);
      end
  end
`endif
`ifdef POWER_PINS
  always @ (RET1N_ or VDDPE or VDDCE or VSSE) begin
`else     
  always @ RET1N_ begin
`endif
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && RET1N_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_a == 1'b1 && (CENA_ == 1'bx || CLKA_ == 1'bx)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`endif
    if (RET1N_ == 1'bx || RET1N_ == 1'bz) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b0 && CENA_p2 == 1'b0 ) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b1 && CENA_p2 == 1'b0 ) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
        $display("Warning: Illegal value for VDDPE %b in %m at %0t", VDDPE, $time);
        failedWrite(0);
    end else if (RET1N_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_a = 1;
      pre_charge_st = 1;
    end else if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (RET1N_ == 1'b0) begin
`endif
        XQA = 1'b1; QA_update = 1'b1;
      CENA_int = 1'bx;
      AA_int = {9{1'bx}};
      STOV_int = 1'bx;
      EMAA_int = {3{1'bx}};
      EMASA_int = 1'bx;
      RET1N_int = 1'bx;
`ifdef POWER_PINS
    end else if (RET1N_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_a == 1'b1) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
    #0;
      XQA = 1'b1; QA_update = 1'b1;
      CENA_int = 1'bx;
      AA_int = {9{1'bx}};
      STOV_int = 1'bx;
      EMAA_int = {3{1'bx}};
      EMASA_int = 1'bx;
      RET1N_int = 1'bx;
    end
    #0;
    RET1N_int = RET1N_;
    QA_update = 1'b0;
  end


  always @ CLKA_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE == 1'bx || VDDCE == 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE == 1'bx || VDDPE == 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE == 1'bx || VSSE == 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
`ifdef POWER_PINS
  if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
`ifdef POWER_PINS
  end else if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
  end else if (VSSE != 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((CLKA_ == 1'bx || CLKA_ == 1'bz) && RET1N_ != 1'b0) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
`ifdef POWER_PINS
    end else if ((VDDCE == 1'bx || VDDCE == 1'bz)) begin
       XQA = 1'b0; QA_update = 1'b0; 
`endif
    end else if ((CLKA_ == 1'b1 || CLKA_ == 1'b0) && LAST_CLKA == 1'bx) begin
       XQA = 1'b0; QA_update = 1'b0; 
    end else if (CLKA_ == 1'b1 && LAST_CLKA == 1'b0) begin
`ifdef POWER_PINS
  if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
  end else begin
      CENA_int = CENA_;
      STOV_int = STOV_;
      EMAA_int = EMAA_;
      EMASA_int = EMASA_;
      RET1N_int = RET1N_;
      if (CENA_int != 1'b1) begin
        AA_int = AA_;
      end
      clk0_int = 1'b0;
      CENA_int = CENA_;
      STOV_int = STOV_;
      EMAA_int = EMAA_;
      EMASA_int = EMASA_;
      RET1N_int = RET1N_;
      if (CENA_int != 1'b1) begin
        AA_int = AA_;
      end
      clk0_int = 1'b0;
    ReadA;
    if (CENA_int == 1'b0) previous_CLKA = $realtime;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOV_int==1'b1 || STOV_int==1'b1) && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int != 1'b1 && CENB_int 
       != 1'b1) && is_contention(AA_int, AB_int, 1'b1, 1'b0)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
      end
  end
    end else if (CLKA_ == 1'b0 && LAST_CLKA == 1'b1) begin
      QA_update = 1'b0;
      XQA = 1'b0;
    end
  end
    LAST_CLKA = CLKA_;
  end



  datapath_latch_Context_Memory uDQA0 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[1]), .D(QA_int[1]), .DFTRAMBYP(1'b0), .mem_path(mem_path[0]), .XQ(XQA), .Q(QA_int[0]));
  datapath_latch_Context_Memory uDQA1 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[2]), .D(QA_int[2]), .DFTRAMBYP(1'b0), .mem_path(mem_path[1]), .XQ(XQA), .Q(QA_int[1]));
  datapath_latch_Context_Memory uDQA2 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(1'b0), .D(1'b0), .DFTRAMBYP(1'b0), .mem_path(mem_path[2]), .XQ(XQA|1'b0), .Q(QA_int[2]));
  datapath_latch_Context_Memory uDQA3 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(1'b0), .D(1'b0), .DFTRAMBYP(1'b0), .mem_path(mem_path[3]), .XQ(XQA|1'b0), .Q(QA_int[3]));
  datapath_latch_Context_Memory uDQA4 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[3]), .D(QA_int[3]), .DFTRAMBYP(1'b0), .mem_path(mem_path[4]), .XQ(XQA), .Q(QA_int[4]));
  datapath_latch_Context_Memory uDQA5 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[4]), .D(QA_int[4]), .DFTRAMBYP(1'b0), .mem_path(mem_path[5]), .XQ(XQA), .Q(QA_int[5]));
  datapath_latch_Context_Memory uDQA6 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[5]), .D(QA_int[5]), .DFTRAMBYP(1'b0), .mem_path(mem_path[6]), .XQ(XQA), .Q(QA_int[6]));



  always @ (CENB_ or CLKB_) begin
  	if(CLKB_ == 1'b0) begin
  		CENB_p2 = CENB_;
  	end
  end

`ifdef POWER_PINS
  always @ (RET1N_ or VDDPE or VDDCE or VSSE) begin
`else     
  always @ RET1N_ begin
`endif
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && RET1N_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_b == 1'b1 && (CENB_ == 1'bx || CLKB_ == 1'bx)) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`endif
    if (RET1N_ == 1'bx || RET1N_ == 1'bz) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b0 && CENB_p2 == 1'b0 ) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b1 && CENB_p2 == 1'b0 ) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
        $display("Warning: Illegal value for VDDPE %b in %m at %0t", VDDPE, $time);
        failedWrite(1);
    end else if (RET1N_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_b = 1;
      pre_charge_st = 1;
    end else if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(1);
      end
`else     
    if (RET1N_ == 1'b0) begin
`endif
      CENB_int = 1'bx;
      AB_int = {9{1'bx}};
      DB_int = {7{1'bx}};
      STOV_int = 1'bx;
      EMAB_int = {3{1'bx}};
      RET1N_int = 1'bx;
`ifdef POWER_PINS
    end else if (RET1N_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_b == 1'b1) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
    #0;
      CENB_int = 1'bx;
      AB_int = {9{1'bx}};
      DB_int = {7{1'bx}};
      STOV_int = 1'bx;
      EMAB_int = {3{1'bx}};
      RET1N_int = 1'bx;
    end
    #0;
    RET1N_int = RET1N_;
    QA_update = 1'b0;
    DB_sh_update = 1'b0; 
  end

  always @ CLKB_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE == 1'bx || VDDCE == 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE == 1'bx || VDDPE == 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE == 1'bx || VSSE == 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
`ifdef POWER_PINS
  if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
`ifdef POWER_PINS
  end else if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
  end else if (VSSE != 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((CLKB_ == 1'bx || CLKB_ == 1'bz) && RET1N_ != 1'b0) begin
      failedWrite(0);
       DB_sh_update = 1'b1;  XDB_sh = 1'b1;
`ifdef POWER_PINS
    end else if ((VDDCE == 1'bx || VDDCE == 1'bz)) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
`endif
    end else if ((CLKB_ == 1'b1 || CLKB_ == 1'b0) && LAST_CLKB == 1'bx) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
       XDB_int = {7{1'b0}};
    end else if (CLKB_ == 1'b1 && LAST_CLKB == 1'b0) begin
  if (RET1N_ == 1'b0) begin
  end else begin
      CENB_int = CENB_;
      STOV_int = STOV_;
      EMAB_int = EMAB_;
      RET1N_int = RET1N_;
      if (CENB_int != 1'b1) begin
        AB_int = AB_;
        DB_int = DB_;
      end
      clk1_int = 1'b0;
      CENB_int = CENB_;
      STOV_int = STOV_;
      EMAB_int = EMAB_;
      RET1N_int = RET1N_;
      if (CENB_int != 1'b1) begin
        AB_int = AB_;
        DB_int = DB_;
      end
      clk1_int = 1'b0;
    WriteB;
    if (CENB_int == 1'b0) previous_CLKB = $realtime;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOV_int==1'b1 || STOV_int==1'b1) && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int != 1'b1 && CENB_int 
       != 1'b1) && is_contention(AA_int, AB_int, 1'b1, 1'b0)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
      end
     end
    end else if (CLKB_ == 1'b0 && LAST_CLKB == 1'b1) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
  end
  end
    LAST_CLKB = CLKB_;
  end






// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
	always @ (VDDCE or VDDPE or VSSE) begin
		if (VDDCE == 1'bx || VDDCE == 1'bz) begin
			$display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
        XQA = 1'b1; QA_update = 1'b1;
        XDB_sh = 1'b1; DB_sh_update = 1'b1;
			failedWrite(0);
			bad_VDDCE = 1'b1;
		end else begin
			bad_VDDCE = 1'b0;
		end
		if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
			$display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
        XQA = 1'b1; QA_update = 1'b1;
        XDB_sh = 1'b1; DB_sh_update = 1'b1;
			failedWrite(0);
			bad_VDDPE = 1'b1;
		end else begin
			bad_VDDPE = 1'b0;
		end
		if (VSSE != 1'b0) begin
			$display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
        XQA = 1'b1; QA_update = 1'b1;
        XDB_sh = 1'b1; DB_sh_update = 1'b1;
			failedWrite(0);
			bad_VSSE = 1'b1;
		end else begin
			bad_VSSE = 1'b0;
		end
		bad_power = bad_VDDCE | bad_VDDPE | bad_VSSE ;
	end
`endif

  function row_contention;
    input [8:0] aa;
    input [8:0] ab;
    input  wena;
    input  wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) == 1'b1 && (& wenb) == 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[8:2] == ab[8:2]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [8:0] aa;
    input [8:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [8:0] aa;
    input [8:0] ab;
    input  wena;
    input  wenb;
    reg result;
  begin
    if ((& wena) == 1'b1 && (& wenb) == 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction


endmodule
`endcelldefine
`else
// If ARM_NEG_MODEL is defined at Simulator Command Line, it Selects the NEGATIVE Model
`ifdef ARM_NEG_MODEL

`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module Context_Memory (VDDCE, VDDPE, VSSE, QA, CLKA, CENA, AA, CLKB, CENB, AB, DB,
    STOV, EMAA, EMASA, EMAB, RET1N);
`else
module Context_Memory (QA, CLKA, CENA, AA, CLKB, CENB, AB, DB, STOV, EMAA, EMASA, EMAB,
    RET1N);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 7;
  parameter WORDS = 368;
  parameter MUX = 4;
  parameter MEM_WIDTH = 28; // redun block size 4, 12 on left, 16 on right
  parameter MEM_HEIGHT = 92;
  parameter WP_SIZE = 7 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 0;
  parameter UPMS_WIDTH = 1;
  parameter ROWS = 92;

  output [6:0] QA;
  input  CLKA;
  input  CENA;
  input [8:0] AA;
  input  CLKB;
  input  CENB;
  input [8:0] AB;
  input [6:0] DB;
  input  STOV;
  input [2:0] EMAA;
  input  EMASA;
  input [2:0] EMAB;
  input  RET1N;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

`ifdef POWER_PINS
  reg bad_VDDCE;
  reg bad_VDDPE;
  reg bad_VSSE;
  reg bad_power;
`endif
  wire corrupt_power;
  reg pre_charge_st;
  reg pre_charge_st_a;
  reg pre_charge_st_b;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [27:0] mem [0:91];
  reg [27:0] row, row_t;
  reg LAST_CLKA;
  reg [27:0] row_mask;
  reg [27:0] new_data;
  reg [27:0] data_out;
  reg [6:0] readLatch0;
  reg [6:0] shifted_readLatch0;
  reg [6:0] readLatch1;
  reg [6:0] shifted_readLatch1;
  reg LAST_CLKB;
  wire [6:0] QA_int;
  reg XQA, QA_update;
  reg [6:0] mem_path;
  reg XDB_sh, DB_sh_update;
  wire [6:0] DB_int_bmux;
  reg [6:0] writeEnable;
  real previous_CLKA;
  real previous_CLKB;
  initial previous_CLKA = 0;
  initial previous_CLKB = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;

  reg NOT_CENA, NOT_AA8, NOT_AA7, NOT_AA6, NOT_AA5, NOT_AA4, NOT_AA3, NOT_AA2, NOT_AA1;
  reg NOT_AA0, NOT_CENB, NOT_AB8, NOT_AB7, NOT_AB6, NOT_AB5, NOT_AB4, NOT_AB3, NOT_AB2;
  reg NOT_AB1, NOT_AB0, NOT_DB6, NOT_DB5, NOT_DB4, NOT_DB3, NOT_DB2, NOT_DB1, NOT_DB0;
  reg NOT_STOV, NOT_EMAA2, NOT_EMAA1, NOT_EMAA0, NOT_EMASA, NOT_EMAB2, NOT_EMAB1, NOT_EMAB0;
  reg NOT_RET1N;
  reg NOT_CONTA, NOT_CLKA_PER, NOT_CLKA_MINH, NOT_CLKA_MINL, NOT_CONTB, NOT_CLKB_PER;
  reg NOT_CLKB_MINH, NOT_CLKB_MINL;
  reg clk0_int;
  reg clk1_int;

  wire [6:0] QA_;
 wire  CLKA_;
 wire  dCLKA;
  wire  CENA_;
 wire  dCENA;
  reg  CENA_int;
  reg  CENA_p2;
  wire [8:0] AA_;
 wire [8:0] dAA;
  reg [8:0] AA_int;
 wire  CLKB_;
 wire  dCLKB;
  wire  CENB_;
 wire  dCENB;
  reg  CENB_int;
  reg  CENB_p2;
  wire [8:0] AB_;
 wire [8:0] dAB;
  reg [8:0] AB_int;
  wire [6:0] DB_;
 wire [6:0] dDB;
  reg [6:0] DB_int;
  reg [6:0] XDB_int;
  wire  STOV_;
 wire  dSTOV;
  reg  STOV_int;
  wire [2:0] EMAA_;
 wire [2:0] dEMAA;
  reg [2:0] EMAA_int;
  wire  EMASA_;
 wire  dEMASA;
  reg  EMASA_int;
  wire [2:0] EMAB_;
 wire [2:0] dEMAB;
  reg [2:0] EMAB_int;
  wire  RET1N_;
 wire  dRET1N;
  reg  RET1N_int;

  buf B0(QA[0], QA_[0]);
  buf B1(QA[1], QA_[1]);
  buf B2(QA[2], QA_[2]);
  buf B3(QA[3], QA_[3]);
  buf B4(QA[4], QA_[4]);
  buf B5(QA[5], QA_[5]);
  buf B6(QA[6], QA_[6]);
  buf B7(CLKA_, dCLKA);
  buf B8(CENA_, dCENA);
  buf B9(AA_[0],dAA[0]);
  buf B10(AA_[1],dAA[1]);
  buf B11(AA_[2],dAA[2]);
  buf B12(AA_[3],dAA[3]);
  buf B13(AA_[4],dAA[4]);
  buf B14(AA_[5],dAA[5]);
  buf B15(AA_[6],dAA[6]);
  buf B16(AA_[7],dAA[7]);
  buf B17(AA_[8],dAA[8]);
  buf B18(CLKB_, dCLKB);
  buf B19(CENB_, dCENB);
  buf B20(AB_[0],dAB[0]);
  buf B21(AB_[1],dAB[1]);
  buf B22(AB_[2],dAB[2]);
  buf B23(AB_[3],dAB[3]);
  buf B24(AB_[4],dAB[4]);
  buf B25(AB_[5],dAB[5]);
  buf B26(AB_[6],dAB[6]);
  buf B27(AB_[7],dAB[7]);
  buf B28(AB_[8],dAB[8]);
  buf B29(DB_[0],dDB[0]);
  buf B30(DB_[1],dDB[1]);
  buf B31(DB_[2],dDB[2]);
  buf B32(DB_[3],dDB[3]);
  buf B33(DB_[4],dDB[4]);
  buf B34(DB_[5],dDB[5]);
  buf B35(DB_[6],dDB[6]);
  buf B36(STOV_, dSTOV);
  buf B37(EMAA_[0],dEMAA[0]);
  buf B38(EMAA_[1],dEMAA[1]);
  buf B39(EMAA_[2],dEMAA[2]);
  buf B40(EMASA_, dEMASA);
  buf B41(EMAB_[0],dEMAB[0]);
  buf B42(EMAB_[1],dEMAB[1]);
  buf B43(EMAB_[2],dEMAB[2]);
  buf B44(RET1N_, dRET1N);

`ifdef POWER_PINS
  assign corrupt_power = bad_power;
`else
  assign corrupt_power = 1'b0;
`endif

  assign QA_ = (RET1N_ | pre_charge_st) & ~corrupt_power ? ((QA_int)) : {7{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial
  begin
    #0;
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
  end
`endif
  always @ (EMAA_) begin
  	if(EMAA_ < 2) 
   	$display("Warning: Set Value for EMAA doesn't match Default value 2 in %m at %0t", $time);
  end
  always @ (EMASA_) begin
  	if(EMASA_ < 0) 
   	$display("Warning: Set Value for EMASA doesn't match Default value 0 in %m at %0t", $time);
  end
  always @ (EMAB_) begin
  	if(EMAB_ < 2) 
   	$display("Warning: Set Value for EMAB doesn't match Default value 2 in %m at %0t", $time);
  end

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval==1'bx || bitval==1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
	$readmemb(filename, memld);
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
        row_mask =  ( {3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[6], 3'b000, wordtemp[5], 3'b000, wordtemp[4],
          3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1], 3'b000, wordtemp[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
    end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
      data_out = (row >> mux_address);
      mem_path = {data_out[24], data_out[20], data_out[16], data_out[12], data_out[8],
        data_out[4], data_out[0]};
        	#0;
        	XQA = 1'b0; QA_update = 1'b1;
   	$fdisplay(dump_file_desc, "%b", mem_path);
  end
  	end
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [8:0] load_addr;
	input [6:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
        row_mask =  ( {3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[6], 3'b000, wordtemp[5], 3'b000, wordtemp[4],
          3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1], 3'b000, wordtemp[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
  end
  endtask

task dumpaddr;
	output [6:0] dump_data;
	input [8:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  Atemp = dump_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
      data_out = (row >> mux_address);
      mem_path = {data_out[24], data_out[20], data_out[16], data_out[12], data_out[8],
        data_out[4], data_out[0]};
        	#0;
        	XQA = 1'b0; QA_update = 1'b1;
   	dump_data = mem_path;
  	end
  end
  endtask


  task ReadA;
  begin
    if (RET1N_int == 1'bx || RET1N_int == 1'bz) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0 && CENA_int == 1'b0) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0) begin
      // no cycle in retention mode
    end else if (^{(EMAA_int), (EMASA_int)} == 1'bx) begin
  if(isBitX(EMASA_int)) begin 
        XQA = 1'b1; QA_update = 1'b1;
  end
  if(isBitX(EMAA_int)) begin
        XQA = 1'b1; QA_update = 1'b1;
  end
    end else if (^{CENA_int, (STOV_int && !CENA_int), RET1N_int} == 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if ((AA_int >= WORDS) && (CENA_int == 1'b0)) begin
        XQA = 0 ? 1'b0 : 1'b1; QA_update = 0 ? 1'b0 : 1'b1;
    end else if (CENA_int == 1'b0 && (^AA_int) == 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if (CENA_int == 1'b0) begin
      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (row_address > 91)
        row = {28{1'bx}};
      else
        row = mem[row_address];
      data_out = (row >> mux_address);
      mem_path = {data_out[24], data_out[20], data_out[16], data_out[12], data_out[8],
        data_out[4], data_out[0]};
        	#0;
        	XQA = 1'b0; QA_update = 1'b1;
    end
  end
  endtask

  task WriteB;
  begin
    if (RET1N_int == 1'bx || RET1N_int == 1'bz) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0 && CENB_int == 1'b0) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0) begin
      // no cycle in retention mode
    end else if (^{(EMAB_int)} == 1'bx) begin
  if(isBitX(EMAB_int)) begin
      failedWrite(1);
  end
    end else if (^{CENB_int, (STOV_int && !CENB_int), RET1N_int} == 1'bx) begin
      failedWrite(1);
    end else if ((AB_int >= WORDS) && (CENB_int == 1'b0)) begin
    end else if (CENB_int == 1'b0 && (^AB_int) == 1'bx) begin
      failedWrite(1);
    end else if (CENB_int == 1'b0) begin
      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (row_address > 91)
        row = {28{1'bx}};
      else
        row = mem[row_address];
        writeEnable = ~ {7{CENB_int}};
      row_mask =  ( {3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
        3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
      new_data =  ( {3'b000, DB_int[6], 3'b000, DB_int[5], 3'b000, DB_int[4], 3'b000, DB_int[3],
        3'b000, DB_int[2], 3'b000, DB_int[1], 3'b000, DB_int[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
    end
  end
  endtask
  always @ (CENA_ or CLKA_) begin
  	if(CLKA_ == 1'b0) begin
  		CENA_p2 = CENA_;
  	end
  end

`ifdef POWER_PINS
  always @ (VDDCE) begin
      if (VDDCE != 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDCE should be powered down after VDDPE, Illegal power down sequencing in %m at %0t", $time);
       end
        $display("In PowerDown Mode in %m at %0t", $time);
        failedWrite(0);
      end
      if (VDDCE == 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDPE should be powered up after VDDCE in %m at %0t", $time);
        $display("Illegal power up sequencing in %m at %0t", $time);
       end
        failedWrite(0);
      end
  end
`endif
`ifdef POWER_PINS
  always @ (RET1N_ or VDDPE or VDDCE or VSSE) begin
`else     
  always @ RET1N_ begin
`endif
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && RET1N_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_a == 1'b1 && (CENA_ == 1'bx || CLKA_ == 1'bx)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`endif
    if (RET1N_ == 1'bx || RET1N_ == 1'bz) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b0 && CENA_p2 == 1'b0 ) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b1 && CENA_p2 == 1'b0 ) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
        $display("Warning: Illegal value for VDDPE %b in %m at %0t", VDDPE, $time);
        failedWrite(0);
    end else if (RET1N_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_a = 1;
      pre_charge_st = 1;
    end else if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (RET1N_ == 1'b0) begin
`endif
        XQA = 1'b1; QA_update = 1'b1;
      CENA_int = 1'bx;
      AA_int = {9{1'bx}};
      STOV_int = 1'bx;
      EMAA_int = {3{1'bx}};
      EMASA_int = 1'bx;
      RET1N_int = 1'bx;
`ifdef POWER_PINS
    end else if (RET1N_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_a == 1'b1) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
    #0;
      XQA = 1'b1; QA_update = 1'b1;
      CENA_int = 1'bx;
      AA_int = {9{1'bx}};
      STOV_int = 1'bx;
      EMAA_int = {3{1'bx}};
      EMASA_int = 1'bx;
      RET1N_int = 1'bx;
    end
    #0;
    RET1N_int = RET1N_;
    QA_update = 1'b0;
  end


  always @ CLKA_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE == 1'bx || VDDCE == 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE == 1'bx || VDDPE == 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE == 1'bx || VSSE == 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
`ifdef POWER_PINS
  if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
`ifdef POWER_PINS
  end else if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
  end else if (VSSE != 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((CLKA_ == 1'bx || CLKA_ == 1'bz) && RET1N_ != 1'b0) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
`ifdef POWER_PINS
    end else if ((VDDCE == 1'bx || VDDCE == 1'bz)) begin
       XQA = 1'b0; QA_update = 1'b0; 
`endif
    end else if ((CLKA_ == 1'b1 || CLKA_ == 1'b0) && LAST_CLKA == 1'bx) begin
       XQA = 1'b0; QA_update = 1'b0; 
    end else if (CLKA_ == 1'b1 && LAST_CLKA == 1'b0) begin
`ifdef POWER_PINS
  if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
  end else begin
      CENA_int = CENA_;
      STOV_int = STOV_;
      EMAA_int = EMAA_;
      EMASA_int = EMASA_;
      RET1N_int = RET1N_;
      if (CENA_int != 1'b1) begin
        AA_int = AA_;
      end
      clk0_int = 1'b0;
      CENA_int = CENA_;
      STOV_int = STOV_;
      EMAA_int = EMAA_;
      EMASA_int = EMASA_;
      RET1N_int = RET1N_;
      if (CENA_int != 1'b1) begin
        AA_int = AA_;
      end
      clk0_int = 1'b0;
    ReadA;
    if (CENA_int == 1'b0) previous_CLKA = $realtime;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOV_int==1'b1 || STOV_int==1'b1) && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int != 1'b1 && CENB_int 
       != 1'b1) && is_contention(AA_int, AB_int, 1'b1, 1'b0)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
      end
  end
    end else if (CLKA_ == 1'b0 && LAST_CLKA == 1'b1) begin
      QA_update = 1'b0;
      XQA = 1'b0;
    end
  end
    LAST_CLKA = CLKA_;
  end

  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;
  initial cont_flag0_int = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if (CENA_int == 1'bx || RET1N_int == 1'bx || (STOV_int && !CENA_int) == 1'bx || 
      clk0_int == 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if (CENA_int == 1'b0 && (^AA_int) == 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if  (cont_flag0_int == 1'bx && (CENA_int != 1'b1 && CENB_int != 1'b1) && is_contention(AA_int, AB_int, 1'b1, 1'b0)) begin
      cont_flag0_int = 1'b0;
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
    end else begin
      #0;
      ReadA;
   end
      #0;
        QA_update = 1'b0;
    globalNotifier0 = 1'b0;
  end



  datapath_latch_Context_Memory uDQA0 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[1]), .D(QA_int[1]), .DFTRAMBYP(1'b0), .mem_path(mem_path[0]), .XQ(XQA), .Q(QA_int[0]));
  datapath_latch_Context_Memory uDQA1 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[2]), .D(QA_int[2]), .DFTRAMBYP(1'b0), .mem_path(mem_path[1]), .XQ(XQA), .Q(QA_int[1]));
  datapath_latch_Context_Memory uDQA2 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(1'b0), .D(1'b0), .DFTRAMBYP(1'b0), .mem_path(mem_path[2]), .XQ(XQA|1'b0), .Q(QA_int[2]));
  datapath_latch_Context_Memory uDQA3 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(1'b0), .D(1'b0), .DFTRAMBYP(1'b0), .mem_path(mem_path[3]), .XQ(XQA|1'b0), .Q(QA_int[3]));
  datapath_latch_Context_Memory uDQA4 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[3]), .D(QA_int[3]), .DFTRAMBYP(1'b0), .mem_path(mem_path[4]), .XQ(XQA), .Q(QA_int[4]));
  datapath_latch_Context_Memory uDQA5 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[4]), .D(QA_int[4]), .DFTRAMBYP(1'b0), .mem_path(mem_path[5]), .XQ(XQA), .Q(QA_int[5]));
  datapath_latch_Context_Memory uDQA6 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[5]), .D(QA_int[5]), .DFTRAMBYP(1'b0), .mem_path(mem_path[6]), .XQ(XQA), .Q(QA_int[6]));



  always @ (CENB_ or CLKB_) begin
  	if(CLKB_ == 1'b0) begin
  		CENB_p2 = CENB_;
  	end
  end

`ifdef POWER_PINS
  always @ (RET1N_ or VDDPE or VDDCE or VSSE) begin
`else     
  always @ RET1N_ begin
`endif
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && RET1N_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_b == 1'b1 && (CENB_ == 1'bx || CLKB_ == 1'bx)) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`endif
    if (RET1N_ == 1'bx || RET1N_ == 1'bz) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b0 && CENB_p2 == 1'b0 ) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b1 && CENB_p2 == 1'b0 ) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
        $display("Warning: Illegal value for VDDPE %b in %m at %0t", VDDPE, $time);
        failedWrite(1);
    end else if (RET1N_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_b = 1;
      pre_charge_st = 1;
    end else if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(1);
      end
`else     
    if (RET1N_ == 1'b0) begin
`endif
      CENB_int = 1'bx;
      AB_int = {9{1'bx}};
      DB_int = {7{1'bx}};
      STOV_int = 1'bx;
      EMAB_int = {3{1'bx}};
      RET1N_int = 1'bx;
`ifdef POWER_PINS
    end else if (RET1N_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_b == 1'b1) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
    #0;
      CENB_int = 1'bx;
      AB_int = {9{1'bx}};
      DB_int = {7{1'bx}};
      STOV_int = 1'bx;
      EMAB_int = {3{1'bx}};
      RET1N_int = 1'bx;
    end
    #0;
    RET1N_int = RET1N_;
    QA_update = 1'b0;
    DB_sh_update = 1'b0; 
  end

  always @ CLKB_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE == 1'bx || VDDCE == 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE == 1'bx || VDDPE == 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE == 1'bx || VSSE == 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
`ifdef POWER_PINS
  if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
`ifdef POWER_PINS
  end else if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
  end else if (VSSE != 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((CLKB_ == 1'bx || CLKB_ == 1'bz) && RET1N_ != 1'b0) begin
      failedWrite(0);
       DB_sh_update = 1'b1;  XDB_sh = 1'b1;
`ifdef POWER_PINS
    end else if ((VDDCE == 1'bx || VDDCE == 1'bz)) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
`endif
    end else if ((CLKB_ == 1'b1 || CLKB_ == 1'b0) && LAST_CLKB == 1'bx) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
       XDB_int = {7{1'b0}};
    end else if (CLKB_ == 1'b1 && LAST_CLKB == 1'b0) begin
  if (RET1N_ == 1'b0) begin
  end else begin
      CENB_int = CENB_;
      STOV_int = STOV_;
      EMAB_int = EMAB_;
      RET1N_int = RET1N_;
      if (CENB_int != 1'b1) begin
        AB_int = AB_;
        DB_int = DB_;
      end
      clk1_int = 1'b0;
      CENB_int = CENB_;
      STOV_int = STOV_;
      EMAB_int = EMAB_;
      RET1N_int = RET1N_;
      if (CENB_int != 1'b1) begin
        AB_int = AB_;
        DB_int = DB_;
      end
      clk1_int = 1'b0;
    WriteB;
    if (CENB_int == 1'b0) previous_CLKB = $realtime;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOV_int==1'b1 || STOV_int==1'b1) && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int != 1'b1 && CENB_int 
       != 1'b1) && is_contention(AA_int, AB_int, 1'b1, 1'b0)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
      end
     end
    end else if (CLKB_ == 1'b0 && LAST_CLKB == 1'b1) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
  end
  end
    LAST_CLKB = CLKB_;
  end

  reg globalNotifier1;
  initial globalNotifier1 = 1'b0;
  initial cont_flag1_int = 1'b0;

  always @ globalNotifier1 begin
    if ($realtime == 0) begin
    end else if (CENB_int == 1'bx || RET1N_int == 1'bx || (STOV_int && !CENB_int) == 1'bx || 
      clk1_int == 1'bx) begin
      failedWrite(1);
    end else if (CENB_int == 1'b0 && (^AB_int) == 1'bx) begin
        failedWrite(1);
    end else if  (cont_flag1_int == 1'bx && (CENA_int != 1'b1 && CENB_int != 1'b1) && is_contention(AA_int, AB_int, 1'b1, 1'b0)) begin
      cont_flag1_int = 1'b0;
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
    end else begin
      #0;
      WriteB;
   end
      #0;
    globalNotifier1 = 1'b0;
  end






// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
	always @ (VDDCE or VDDPE or VSSE) begin
		if (VDDCE == 1'bx || VDDCE == 1'bz) begin
			$display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
        XQA = 1'b1; QA_update = 1'b1;
        XDB_sh = 1'b1; DB_sh_update = 1'b1;
			failedWrite(0);
			bad_VDDCE = 1'b1;
		end else begin
			bad_VDDCE = 1'b0;
		end
		if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
			$display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
        XQA = 1'b1; QA_update = 1'b1;
        XDB_sh = 1'b1; DB_sh_update = 1'b1;
			failedWrite(0);
			bad_VDDPE = 1'b1;
		end else begin
			bad_VDDPE = 1'b0;
		end
		if (VSSE != 1'b0) begin
			$display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
        XQA = 1'b1; QA_update = 1'b1;
        XDB_sh = 1'b1; DB_sh_update = 1'b1;
			failedWrite(0);
			bad_VSSE = 1'b1;
		end else begin
			bad_VSSE = 1'b0;
		end
		bad_power = bad_VDDCE | bad_VDDPE | bad_VSSE ;
	end
`endif

  function row_contention;
    input [8:0] aa;
    input [8:0] ab;
    input  wena;
    input  wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) == 1'b1 && (& wenb) == 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[8:2] == ab[8:2]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [8:0] aa;
    input [8:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [8:0] aa;
    input [8:0] ab;
    input  wena;
    input  wenb;
    reg result;
  begin
    if ((& wena) == 1'b1 && (& wenb) == 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction

   wire contA_flag = (CENA_int != 1'b1  && CENB_ != 1'b1) && ((is_contention(AB_, AA_int, 1'b0, 1'b1)));
   wire contB_flag = (CENB_int != 1'b1  && CENA_ != 1'b1) && ((is_contention(AA_, AB_int, 1'b1, 1'b0)));

  always @ NOT_CENA begin
    CENA_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA8 begin
    AA_int[8] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA7 begin
    AA_int[7] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA6 begin
    AA_int[6] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA5 begin
    AA_int[5] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA4 begin
    AA_int[4] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA3 begin
    AA_int[3] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA2 begin
    AA_int[2] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA1 begin
    AA_int[1] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA0 begin
    AA_int[0] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CENB begin
    CENB_int = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB8 begin
    AB_int[8] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB7 begin
    AB_int[7] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB6 begin
    AB_int[6] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB5 begin
    AB_int[5] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB4 begin
    AB_int[4] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB3 begin
    AB_int[3] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB2 begin
    AB_int[2] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB1 begin
    AB_int[1] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB0 begin
    AB_int[0] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB6 begin
    DB_int[6] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB5 begin
    DB_int[5] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB4 begin
    DB_int[4] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB3 begin
    DB_int[3] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB2 begin
    DB_int[2] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB1 begin
    DB_int[1] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB0 begin
    DB_int[0] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_STOV begin
    STOV_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAA2 begin
    EMAA_int[2] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAA1 begin
    EMAA_int[1] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAA0 begin
    EMAA_int[0] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMASA begin
    EMASA_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAB2 begin
    EMAB_int[2] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAB1 begin
    EMAB_int[1] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAB0 begin
    EMAB_int[0] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_RET1N begin
    RET1N_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end

  always @ NOT_CONTA begin
    cont_flag0_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_PER begin
    clk0_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_MINH begin
    clk0_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_MINL begin
    clk0_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CONTB begin
    cont_flag1_int = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_PER begin
    clk1_int = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_MINH begin
    clk1_int = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_MINL begin
    clk1_int = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end



  wire contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq0, contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq1;
  wire contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq0, contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq1;
  wire contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq0, contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq1;
  wire contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq0, contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq1;
  wire STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq0, STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq0;
  wire STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq0, STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq0;
  wire STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq0, STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq0;
  wire STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq0, STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq0;
  wire STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq1, STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq1;
  wire STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq1, STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq1;
  wire STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq1, STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq1;
  wire STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq1, STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq1;
  wire STOVeq0aRET1Neq1aCENAeq0, STOVeq1aRET1Neq1aCENAeq0, contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq0;
  wire contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq1, contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq0;
  wire contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq1, contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq0;
  wire contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq1, contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq0;
  wire contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq1, STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq0;
  wire STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq1, STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq0;
  wire STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq1, STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq0;
  wire STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq1, STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq0;
  wire STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq1, STOVeq1aRET1Neq1, STOVeq0aRET1Neq1aCENBeq0;
  wire STOVeq1aRET1Neq1aCENBeq0, RET1Neq1, RET1Neq1aCENAeq0, RET1Neq1aCENBeq0;


  assign contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq0 = RET1N&&!EMAA[2]&&!EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq1 = RET1N&&!EMAA[2]&&!EMAA[1]&&EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq0 = RET1N&&!EMAA[2]&&EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq1 = RET1N&&!EMAA[2]&&EMAA[1]&&EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq0 = RET1N&&EMAA[2]&&!EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq1 = RET1N&&EMAA[2]&&!EMAA[1]&&EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq0 = RET1N&&EMAA[2]&&EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq1 = RET1N&&EMAA[2]&&EMAA[1]&&EMAA[0] && contA_flag;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq0 = !STOV&&RET1N&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq0 = !STOV&&RET1N&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq0 = !STOV&&RET1N&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq0 = !STOV&&RET1N&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq0 = !STOV&&RET1N&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq0 = !STOV&&RET1N&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq0 = !STOV&&RET1N&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq0 = !STOV&&RET1N&&EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq1 = !STOV&&RET1N&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq1 = !STOV&&RET1N&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq1 = !STOV&&RET1N&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq1 = !STOV&&RET1N&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq1 = !STOV&&RET1N&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq1 = !STOV&&RET1N&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq1 = !STOV&&RET1N&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq1 = !STOV&&RET1N&&EMAA[2]&&EMAA[1]&&EMAA[0]&&EMASA;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq0 = RET1N&&!EMAB[2]&&!EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq1 = RET1N&&!EMAB[2]&&!EMAB[1]&&EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq0 = RET1N&&!EMAB[2]&&EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq1 = RET1N&&!EMAB[2]&&EMAB[1]&&EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq0 = RET1N&&EMAB[2]&&!EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq1 = RET1N&&EMAB[2]&&!EMAB[1]&&EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq0 = RET1N&&EMAB[2]&&EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq1 = RET1N&&EMAB[2]&&EMAB[1]&&EMAB[0] && contB_flag;
  assign STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq0 = !STOV&&RET1N&&!EMAB[2]&&!EMAB[1]&&!EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq1 = !STOV&&RET1N&&!EMAB[2]&&!EMAB[1]&&EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq0 = !STOV&&RET1N&&!EMAB[2]&&EMAB[1]&&!EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq1 = !STOV&&RET1N&&!EMAB[2]&&EMAB[1]&&EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq0 = !STOV&&RET1N&&EMAB[2]&&!EMAB[1]&&!EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq1 = !STOV&&RET1N&&EMAB[2]&&!EMAB[1]&&EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq0 = !STOV&&RET1N&&EMAB[2]&&EMAB[1]&&!EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq1 = !STOV&&RET1N&&EMAB[2]&&EMAB[1]&&EMAB[0];

  assign STOVeq0aRET1Neq1aCENAeq0 = !STOV&&RET1N&&!CENA;
  assign STOVeq1aRET1Neq1aCENAeq0 = STOV&&RET1N&&!CENA;
  assign STOVeq0aRET1Neq1aCENBeq0 = !STOV&&RET1N&&!CENB;
  assign STOVeq1aRET1Neq1aCENBeq0 = STOV&&RET1N&&!CENB;

  assign STOVeq1aRET1Neq1 = STOV&&RET1N;
  assign RET1Neq1 = RET1N;
  assign RET1Neq1aCENAeq0 = RET1N&&!CENA;
  assign RET1Neq1aCENBeq0 = RET1N&&!CENB;

  specify

    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge CLKA, `ARM_MEM_PERIOD, NOT_CLKA_PER);
   `else
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq1aRET1Neq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
   `endif

   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge CLKB, `ARM_MEM_PERIOD, NOT_CLKB_PER);
   `else
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq0, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq1, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq0, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq1, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq0, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq1, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq0, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq1, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq1aRET1Neq1, `ARM_MEM_PERIOD, NOT_CLKB_PER);
   `endif


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge CLKA, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINH);
       $width(negedge CLKA, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINL);
   `else
       $width(posedge CLKA &&& STOVeq0aRET1Neq1aCENAeq0, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINH);
       $width(posedge CLKA &&& STOVeq1aRET1Neq1aCENAeq0, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINH);
       $width(negedge CLKA &&& STOVeq0aRET1Neq1aCENAeq0, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINL);
       $width(negedge CLKA &&& STOVeq1aRET1Neq1aCENAeq0, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINL);
   `endif

   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge CLKB, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINH);
       $width(negedge CLKB, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINL);
   `else
       $width(posedge CLKB &&& STOVeq0aRET1Neq1aCENBeq0, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINH);
       $width(posedge CLKB &&& STOVeq1aRET1Neq1aCENBeq0, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINH);
       $width(negedge CLKB &&& STOVeq0aRET1Neq1aCENBeq0, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINL);
       $width(negedge CLKB &&& STOVeq1aRET1Neq1aCENBeq0, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINL);
   `endif


    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq0, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA,,,dCLKB,dCLKA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq1, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA,,,dCLKB,dCLKA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq0, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA,,,dCLKB,dCLKA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq1, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA,,,dCLKB,dCLKA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq0, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA,,,dCLKB,dCLKA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq1, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA,,,dCLKB,dCLKA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq0, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA,,,dCLKB,dCLKA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq1, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA,,,dCLKB,dCLKA);

    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq0, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB,,,dCLKA,dCLKB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq1, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB,,,dCLKA,dCLKB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq0, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB,,,dCLKA,dCLKB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq1, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB,,,dCLKA,dCLKB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq0, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB,,,dCLKA,dCLKB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq1, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB,,,dCLKA,dCLKB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq0, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB,,,dCLKA,dCLKB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq1, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB,,,dCLKA,dCLKB);

    $setuphold(posedge CLKA &&& RET1Neq1, posedge CENA, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_CENA,,,dCLKA,dCENA);
    $setuphold(posedge CLKA &&& RET1Neq1, negedge CENA, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_CENA,,,dCLKA,dCENA);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA8,,,dCLKA,dAA[8]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA7,,,dCLKA,dAA[7]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA6,,,dCLKA,dAA[6]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA5,,,dCLKA,dAA[5]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA4,,,dCLKA,dAA[4]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA3,,,dCLKA,dAA[3]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA2,,,dCLKA,dAA[2]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA1,,,dCLKA,dAA[1]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA0,,,dCLKA,dAA[0]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA8,,,dCLKA,dAA[8]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA7,,,dCLKA,dAA[7]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA6,,,dCLKA,dAA[6]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA5,,,dCLKA,dAA[5]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA4,,,dCLKA,dAA[4]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA3,,,dCLKA,dAA[3]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA2,,,dCLKA,dAA[2]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA1,,,dCLKA,dAA[1]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA0,,,dCLKA,dAA[0]);
    $setuphold(posedge CLKB &&& RET1Neq1, posedge CENB, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_CENB,,,dCLKB,dCENB);
    $setuphold(posedge CLKB &&& RET1Neq1, negedge CENB, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_CENB,,,dCLKB,dCENB);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB8,,,dCLKB,dAB[8]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB7,,,dCLKB,dAB[7]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB6,,,dCLKB,dAB[6]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB5,,,dCLKB,dAB[5]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB4,,,dCLKB,dAB[4]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB3,,,dCLKB,dAB[3]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB2,,,dCLKB,dAB[2]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB1,,,dCLKB,dAB[1]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB0,,,dCLKB,dAB[0]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB8,,,dCLKB,dAB[8]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB7,,,dCLKB,dAB[7]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB6,,,dCLKB,dAB[6]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB5,,,dCLKB,dAB[5]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB4,,,dCLKB,dAB[4]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB3,,,dCLKB,dAB[3]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB2,,,dCLKB,dAB[2]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB1,,,dCLKB,dAB[1]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB0,,,dCLKB,dAB[0]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB6,,,dCLKB,dDB[6]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB5,,,dCLKB,dDB[5]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB4,,,dCLKB,dDB[4]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB3,,,dCLKB,dDB[3]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB2,,,dCLKB,dDB[2]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB1,,,dCLKB,dDB[1]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB0,,,dCLKB,dDB[0]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB6,,,dCLKB,dDB[6]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB5,,,dCLKB,dDB[5]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB4,,,dCLKB,dDB[4]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB3,,,dCLKB,dDB[3]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB2,,,dCLKB,dDB[2]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB1,,,dCLKB,dDB[1]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB0,,,dCLKB,dDB[0]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge STOV, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_STOV,,,dCLKA,dSTOV);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge STOV, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_STOV,,,dCLKA,dSTOV);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge STOV, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_STOV,,,dCLKB,dSTOV);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge STOV, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_STOV,,,dCLKB,dSTOV);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge EMAA[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA2,,,dCLKA,dEMAA[2]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge EMAA[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA1,,,dCLKA,dEMAA[1]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge EMAA[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA0,,,dCLKA,dEMAA[0]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge EMAA[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA2,,,dCLKA,dEMAA[2]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge EMAA[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA1,,,dCLKA,dEMAA[1]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge EMAA[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA0,,,dCLKA,dEMAA[0]);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge EMASA, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMASA,,,dCLKA,dEMASA);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge EMASA, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMASA,,,dCLKA,dEMASA);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge EMAB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB2,,,dCLKB,dEMAB[2]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge EMAB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB1,,,dCLKB,dEMAB[1]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge EMAB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB0,,,dCLKB,dEMAB[0]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge EMAB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB2,,,dCLKB,dEMAB[2]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge EMAB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB1,,,dCLKB,dEMAB[1]);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge EMAB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB0,,,dCLKB,dEMAB[0]);
    $setuphold(negedge RET1N, negedge CENA, 0.000, `ARM_MEM_HOLD, NOT_RET1N,,,dRET1N,dCENA);
    $setuphold(posedge RET1N, negedge CENA, 0.000, `ARM_MEM_HOLD, NOT_RET1N,,,dRET1N,dCENA);
    $setuphold(negedge RET1N, negedge CENB, 0.000, `ARM_MEM_HOLD, NOT_RET1N,,,dRET1N,dCENB);
    $setuphold(posedge RET1N, negedge CENB, 0.000, `ARM_MEM_HOLD, NOT_RET1N,,,dRET1N,dCENB);
    $setuphold(posedge CENB, negedge RET1N, 0.000, `ARM_MEM_HOLD, NOT_RET1N,,,dCENB,dRET1N);
    $setuphold(posedge CENA, negedge RET1N, 0.000, `ARM_MEM_HOLD, NOT_RET1N,,,dCENA,dRET1N);
    $setuphold(posedge CENB, posedge RET1N, 0.000, `ARM_MEM_HOLD, NOT_RET1N,,,dCENB,dRET1N);
    $setuphold(posedge CENA, posedge RET1N, 0.000, `ARM_MEM_HOLD, NOT_RET1N,,,dCENA,dRET1N);
  endspecify


endmodule
`endcelldefine
`else
`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module Context_Memory (VDDCE, VDDPE, VSSE, QA, CLKA, CENA, AA, CLKB, CENB, AB, DB,
    STOV, EMAA, EMASA, EMAB, RET1N);
`else
module Context_Memory (QA, CLKA, CENA, AA, CLKB, CENB, AB, DB, STOV, EMAA, EMASA, EMAB,
    RET1N);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 7;
  parameter WORDS = 368;
  parameter MUX = 4;
  parameter MEM_WIDTH = 28; // redun block size 4, 12 on left, 16 on right
  parameter MEM_HEIGHT = 92;
  parameter WP_SIZE = 7 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 0;
  parameter UPMS_WIDTH = 1;
  parameter ROWS = 92;

  output [6:0] QA;
  input  CLKA;
  input  CENA;
  input [8:0] AA;
  input  CLKB;
  input  CENB;
  input [8:0] AB;
  input [6:0] DB;
  input  STOV;
  input [2:0] EMAA;
  input  EMASA;
  input [2:0] EMAB;
  input  RET1N;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

`ifdef POWER_PINS
  reg bad_VDDCE;
  reg bad_VDDPE;
  reg bad_VSSE;
  reg bad_power;
`endif
  wire corrupt_power;
  reg pre_charge_st;
  reg pre_charge_st_a;
  reg pre_charge_st_b;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [27:0] mem [0:91];
  reg [27:0] row, row_t;
  reg LAST_CLKA;
  reg [27:0] row_mask;
  reg [27:0] new_data;
  reg [27:0] data_out;
  reg [6:0] readLatch0;
  reg [6:0] shifted_readLatch0;
  reg [6:0] readLatch1;
  reg [6:0] shifted_readLatch1;
  reg LAST_CLKB;
  wire [6:0] QA_int;
  reg XQA, QA_update;
  reg [6:0] mem_path;
  reg XDB_sh, DB_sh_update;
  wire [6:0] DB_int_bmux;
  reg [6:0] writeEnable;
  real previous_CLKA;
  real previous_CLKB;
  initial previous_CLKA = 0;
  initial previous_CLKB = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;

  reg NOT_CENA, NOT_AA8, NOT_AA7, NOT_AA6, NOT_AA5, NOT_AA4, NOT_AA3, NOT_AA2, NOT_AA1;
  reg NOT_AA0, NOT_CENB, NOT_AB8, NOT_AB7, NOT_AB6, NOT_AB5, NOT_AB4, NOT_AB3, NOT_AB2;
  reg NOT_AB1, NOT_AB0, NOT_DB6, NOT_DB5, NOT_DB4, NOT_DB3, NOT_DB2, NOT_DB1, NOT_DB0;
  reg NOT_STOV, NOT_EMAA2, NOT_EMAA1, NOT_EMAA0, NOT_EMASA, NOT_EMAB2, NOT_EMAB1, NOT_EMAB0;
  reg NOT_RET1N;
  reg NOT_CONTA, NOT_CLKA_PER, NOT_CLKA_MINH, NOT_CLKA_MINL, NOT_CONTB, NOT_CLKB_PER;
  reg NOT_CLKB_MINH, NOT_CLKB_MINL;
  reg clk0_int;
  reg clk1_int;

  wire [6:0] QA_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire [8:0] AA_;
  reg [8:0] AA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire [8:0] AB_;
  reg [8:0] AB_int;
  wire [6:0] DB_;
  reg [6:0] DB_int;
  reg [6:0] XDB_int;
  wire  STOV_;
  reg  STOV_int;
  wire [2:0] EMAA_;
  reg [2:0] EMAA_int;
  wire  EMASA_;
  reg  EMASA_int;
  wire [2:0] EMAB_;
  reg [2:0] EMAB_int;
  wire  RET1N_;
  reg  RET1N_int;

  buf B45(QA[0], QA_[0]);
  buf B46(QA[1], QA_[1]);
  buf B47(QA[2], QA_[2]);
  buf B48(QA[3], QA_[3]);
  buf B49(QA[4], QA_[4]);
  buf B50(QA[5], QA_[5]);
  buf B51(QA[6], QA_[6]);
  buf B52(CLKA_, CLKA);
  buf B53(CENA_, CENA);
  buf B54(AA_[0], AA[0]);
  buf B55(AA_[1], AA[1]);
  buf B56(AA_[2], AA[2]);
  buf B57(AA_[3], AA[3]);
  buf B58(AA_[4], AA[4]);
  buf B59(AA_[5], AA[5]);
  buf B60(AA_[6], AA[6]);
  buf B61(AA_[7], AA[7]);
  buf B62(AA_[8], AA[8]);
  buf B63(CLKB_, CLKB);
  buf B64(CENB_, CENB);
  buf B65(AB_[0], AB[0]);
  buf B66(AB_[1], AB[1]);
  buf B67(AB_[2], AB[2]);
  buf B68(AB_[3], AB[3]);
  buf B69(AB_[4], AB[4]);
  buf B70(AB_[5], AB[5]);
  buf B71(AB_[6], AB[6]);
  buf B72(AB_[7], AB[7]);
  buf B73(AB_[8], AB[8]);
  buf B74(DB_[0], DB[0]);
  buf B75(DB_[1], DB[1]);
  buf B76(DB_[2], DB[2]);
  buf B77(DB_[3], DB[3]);
  buf B78(DB_[4], DB[4]);
  buf B79(DB_[5], DB[5]);
  buf B80(DB_[6], DB[6]);
  buf B81(STOV_, STOV);
  buf B82(EMAA_[0], EMAA[0]);
  buf B83(EMAA_[1], EMAA[1]);
  buf B84(EMAA_[2], EMAA[2]);
  buf B85(EMASA_, EMASA);
  buf B86(EMAB_[0], EMAB[0]);
  buf B87(EMAB_[1], EMAB[1]);
  buf B88(EMAB_[2], EMAB[2]);
  buf B89(RET1N_, RET1N);

`ifdef POWER_PINS
  assign corrupt_power = bad_power;
`else
  assign corrupt_power = 1'b0;
`endif

   `ifdef ARM_FAULT_MODELING
     Context_Memory_error_injection u1(.CLK(CLKA_), .Q_out(QA_), .A(AA_int), .CEN(CENA_int), .Q_in(QA_int));
  `else
  assign QA_ = (RET1N_ | pre_charge_st) & ~corrupt_power ? ((QA_int)) : {7{1'bx}};
  `endif

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial
  begin
    #0;
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
  end
`endif
  always @ (EMAA_) begin
  	if(EMAA_ < 2) 
   	$display("Warning: Set Value for EMAA doesn't match Default value 2 in %m at %0t", $time);
  end
  always @ (EMASA_) begin
  	if(EMASA_ < 0) 
   	$display("Warning: Set Value for EMASA doesn't match Default value 0 in %m at %0t", $time);
  end
  always @ (EMAB_) begin
  	if(EMAB_ < 2) 
   	$display("Warning: Set Value for EMAB doesn't match Default value 2 in %m at %0t", $time);
  end

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval==1'bx || bitval==1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
	$readmemb(filename, memld);
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
        row_mask =  ( {3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[6], 3'b000, wordtemp[5], 3'b000, wordtemp[4],
          3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1], 3'b000, wordtemp[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
    end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
      data_out = (row >> mux_address);
      mem_path = {data_out[24], data_out[20], data_out[16], data_out[12], data_out[8],
        data_out[4], data_out[0]};
        	#0;
        	XQA = 1'b0; QA_update = 1'b1;
   	$fdisplay(dump_file_desc, "%b", mem_path);
  end
  	end
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [8:0] load_addr;
	input [6:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
        row_mask =  ( {3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[6], 3'b000, wordtemp[5], 3'b000, wordtemp[4],
          3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1], 3'b000, wordtemp[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
  end
  endtask

task dumpaddr;
	output [6:0] dump_data;
	input [8:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
     if (CENA_ == 1'b1 && CENB_ == 1'b1) begin
	  Atemp = dump_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {7{1'b1}};
      data_out = (row >> mux_address);
      mem_path = {data_out[24], data_out[20], data_out[16], data_out[12], data_out[8],
        data_out[4], data_out[0]};
        	#0;
        	XQA = 1'b0; QA_update = 1'b1;
   	dump_data = mem_path;
  	end
  end
  endtask


  task ReadA;
  begin
    if (RET1N_int == 1'bx || RET1N_int == 1'bz) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0 && CENA_int == 1'b0) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0) begin
      // no cycle in retention mode
    end else if (^{(EMAA_int), (EMASA_int)} == 1'bx) begin
  if(isBitX(EMASA_int)) begin 
        XQA = 1'b1; QA_update = 1'b1;
  end
  if(isBitX(EMAA_int)) begin
        XQA = 1'b1; QA_update = 1'b1;
  end
    end else if (^{CENA_int, (STOV_int && !CENA_int), RET1N_int} == 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if ((AA_int >= WORDS) && (CENA_int == 1'b0)) begin
        XQA = 0 ? 1'b0 : 1'b1; QA_update = 0 ? 1'b0 : 1'b1;
    end else if (CENA_int == 1'b0 && (^AA_int) == 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if (CENA_int == 1'b0) begin
      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (row_address > 91)
        row = {28{1'bx}};
      else
        row = mem[row_address];
      data_out = (row >> mux_address);
      mem_path = {data_out[24], data_out[20], data_out[16], data_out[12], data_out[8],
        data_out[4], data_out[0]};
        	#0;
        	XQA = 1'b0; QA_update = 1'b1;
    end
  end
  endtask

  task WriteB;
  begin
    if (RET1N_int == 1'bx || RET1N_int == 1'bz) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0 && CENB_int == 1'b0) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int == 1'b0) begin
      // no cycle in retention mode
    end else if (^{(EMAB_int)} == 1'bx) begin
  if(isBitX(EMAB_int)) begin
      failedWrite(1);
  end
    end else if (^{CENB_int, (STOV_int && !CENB_int), RET1N_int} == 1'bx) begin
      failedWrite(1);
    end else if ((AB_int >= WORDS) && (CENB_int == 1'b0)) begin
    end else if (CENB_int == 1'b0 && (^AB_int) == 1'bx) begin
      failedWrite(1);
    end else if (CENB_int == 1'b0) begin
      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (row_address > 91)
        row = {28{1'bx}};
      else
        row = mem[row_address];
        writeEnable = ~ {7{CENB_int}};
      row_mask =  ( {3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
        3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
      new_data =  ( {3'b000, DB_int[6], 3'b000, DB_int[5], 3'b000, DB_int[4], 3'b000, DB_int[3],
        3'b000, DB_int[2], 3'b000, DB_int[1], 3'b000, DB_int[0]} << mux_address);
      row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
    end
  end
  endtask
  always @ (CENA_ or CLKA_) begin
  	if(CLKA_ == 1'b0) begin
  		CENA_p2 = CENA_;
  	end
  end

`ifdef POWER_PINS
  always @ (VDDCE) begin
      if (VDDCE != 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDCE should be powered down after VDDPE, Illegal power down sequencing in %m at %0t", $time);
       end
        $display("In PowerDown Mode in %m at %0t", $time);
        failedWrite(0);
      end
      if (VDDCE == 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDPE should be powered up after VDDCE in %m at %0t", $time);
        $display("Illegal power up sequencing in %m at %0t", $time);
       end
        failedWrite(0);
      end
  end
`endif
`ifdef POWER_PINS
  always @ (RET1N_ or VDDPE or VDDCE or VSSE) begin
`else     
  always @ RET1N_ begin
`endif
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && RET1N_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_a == 1'b1 && (CENA_ == 1'bx || CLKA_ == 1'bx)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`endif
    if (RET1N_ == 1'bx || RET1N_ == 1'bz) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b0 && CENA_p2 == 1'b0 ) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b1 && CENA_p2 == 1'b0 ) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
        $display("Warning: Illegal value for VDDPE %b in %m at %0t", VDDPE, $time);
        failedWrite(0);
    end else if (RET1N_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_a = 1;
      pre_charge_st = 1;
    end else if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (RET1N_ == 1'b0) begin
`endif
        XQA = 1'b1; QA_update = 1'b1;
      CENA_int = 1'bx;
      AA_int = {9{1'bx}};
      STOV_int = 1'bx;
      EMAA_int = {3{1'bx}};
      EMASA_int = 1'bx;
      RET1N_int = 1'bx;
`ifdef POWER_PINS
    end else if (RET1N_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_a == 1'b1) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
    #0;
      XQA = 1'b1; QA_update = 1'b1;
      CENA_int = 1'bx;
      AA_int = {9{1'bx}};
      STOV_int = 1'bx;
      EMAA_int = {3{1'bx}};
      EMASA_int = 1'bx;
      RET1N_int = 1'bx;
    end
    #0;
    RET1N_int = RET1N_;
    QA_update = 1'b0;
  end


  always @ CLKA_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE == 1'bx || VDDCE == 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE == 1'bx || VDDPE == 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE == 1'bx || VSSE == 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
`ifdef POWER_PINS
  if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
`ifdef POWER_PINS
  end else if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
  end else if (VSSE != 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((CLKA_ == 1'bx || CLKA_ == 1'bz) && RET1N_ != 1'b0) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
`ifdef POWER_PINS
    end else if ((VDDCE == 1'bx || VDDCE == 1'bz)) begin
       XQA = 1'b0; QA_update = 1'b0; 
`endif
    end else if ((CLKA_ == 1'b1 || CLKA_ == 1'b0) && LAST_CLKA == 1'bx) begin
       XQA = 1'b0; QA_update = 1'b0; 
    end else if (CLKA_ == 1'b1 && LAST_CLKA == 1'b0) begin
`ifdef POWER_PINS
  if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
  end else begin
      CENA_int = CENA_;
      STOV_int = STOV_;
      EMAA_int = EMAA_;
      EMASA_int = EMASA_;
      RET1N_int = RET1N_;
      if (CENA_int != 1'b1) begin
        AA_int = AA_;
      end
      clk0_int = 1'b0;
      CENA_int = CENA_;
      STOV_int = STOV_;
      EMAA_int = EMAA_;
      EMASA_int = EMASA_;
      RET1N_int = RET1N_;
      if (CENA_int != 1'b1) begin
        AA_int = AA_;
      end
      clk0_int = 1'b0;
    ReadA;
    if (CENA_int == 1'b0) previous_CLKA = $realtime;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOV_int==1'b1 || STOV_int==1'b1) && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int != 1'b1 && CENB_int 
       != 1'b1) && is_contention(AA_int, AB_int, 1'b1, 1'b0)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
      end
  end
    end else if (CLKA_ == 1'b0 && LAST_CLKA == 1'b1) begin
      QA_update = 1'b0;
      XQA = 1'b0;
    end
  end
    LAST_CLKA = CLKA_;
  end

  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;
  initial cont_flag0_int = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if (CENA_int == 1'bx || RET1N_int == 1'bx || (STOV_int && !CENA_int) == 1'bx || 
      clk0_int == 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if (CENA_int == 1'b0 && (^AA_int) == 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if  (cont_flag0_int == 1'bx && (CENA_int != 1'b1 && CENB_int != 1'b1) && is_contention(AA_int, AB_int, 1'b1, 1'b0)) begin
      cont_flag0_int = 1'b0;
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
    end else begin
      #0;
      ReadA;
   end
      #0;
        QA_update = 1'b0;
    globalNotifier0 = 1'b0;
  end



  datapath_latch_Context_Memory uDQA0 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[1]), .D(QA_int[1]), .DFTRAMBYP(1'b0), .mem_path(mem_path[0]), .XQ(XQA), .Q(QA_int[0]));
  datapath_latch_Context_Memory uDQA1 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[2]), .D(QA_int[2]), .DFTRAMBYP(1'b0), .mem_path(mem_path[1]), .XQ(XQA), .Q(QA_int[1]));
  datapath_latch_Context_Memory uDQA2 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(1'b0), .D(1'b0), .DFTRAMBYP(1'b0), .mem_path(mem_path[2]), .XQ(XQA|1'b0), .Q(QA_int[2]));
  datapath_latch_Context_Memory uDQA3 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(1'b0), .D(1'b0), .DFTRAMBYP(1'b0), .mem_path(mem_path[3]), .XQ(XQA|1'b0), .Q(QA_int[3]));
  datapath_latch_Context_Memory uDQA4 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[3]), .D(QA_int[3]), .DFTRAMBYP(1'b0), .mem_path(mem_path[4]), .XQ(XQA), .Q(QA_int[4]));
  datapath_latch_Context_Memory uDQA5 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[4]), .D(QA_int[4]), .DFTRAMBYP(1'b0), .mem_path(mem_path[5]), .XQ(XQA), .Q(QA_int[5]));
  datapath_latch_Context_Memory uDQA6 (.CLK(CLKA), .Q_update(QA_update), .SE(1'b0), .SI(QA_int[5]), .D(QA_int[5]), .DFTRAMBYP(1'b0), .mem_path(mem_path[6]), .XQ(XQA), .Q(QA_int[6]));



  always @ (CENB_ or CLKB_) begin
  	if(CLKB_ == 1'b0) begin
  		CENB_p2 = CENB_;
  	end
  end

`ifdef POWER_PINS
  always @ (RET1N_ or VDDPE or VDDCE or VSSE) begin
`else     
  always @ RET1N_ begin
`endif
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && RET1N_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_b == 1'b1 && (CENB_ == 1'bx || CLKB_ == 1'bx)) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`endif
    if (RET1N_ == 1'bx || RET1N_ == 1'bz) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b0 && CENB_p2 == 1'b0 ) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ == 1'b1 && CENB_p2 == 1'b0 ) begin
      failedWrite(1);
        XQA = 1'b1; QA_update = 1'b1;
    end
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
        $display("Warning: Illegal value for VDDPE %b in %m at %0t", VDDPE, $time);
        failedWrite(1);
    end else if (RET1N_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_b = 1;
      pre_charge_st = 1;
    end else if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(1);
      end
`else     
    if (RET1N_ == 1'b0) begin
`endif
      CENB_int = 1'bx;
      AB_int = {9{1'bx}};
      DB_int = {7{1'bx}};
      STOV_int = 1'bx;
      EMAB_int = {3{1'bx}};
      RET1N_int = 1'bx;
`ifdef POWER_PINS
    end else if (RET1N_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_b == 1'b1) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
    #0;
      CENB_int = 1'bx;
      AB_int = {9{1'bx}};
      DB_int = {7{1'bx}};
      STOV_int = 1'bx;
      EMAB_int = {3{1'bx}};
      RET1N_int = 1'bx;
    end
    #0;
    RET1N_int = RET1N_;
    QA_update = 1'b0;
    DB_sh_update = 1'b0; 
  end

  always @ CLKB_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE == 1'bx || VDDCE == 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE == 1'bx || VDDPE == 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE == 1'bx || VSSE == 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
`ifdef POWER_PINS
  if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
`ifdef POWER_PINS
  end else if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
  end else if (VSSE != 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((CLKB_ == 1'bx || CLKB_ == 1'bz) && RET1N_ != 1'b0) begin
      failedWrite(0);
       DB_sh_update = 1'b1;  XDB_sh = 1'b1;
`ifdef POWER_PINS
    end else if ((VDDCE == 1'bx || VDDCE == 1'bz)) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
`endif
    end else if ((CLKB_ == 1'b1 || CLKB_ == 1'b0) && LAST_CLKB == 1'bx) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
       XDB_int = {7{1'b0}};
    end else if (CLKB_ == 1'b1 && LAST_CLKB == 1'b0) begin
  if (RET1N_ == 1'b0) begin
  end else begin
      CENB_int = CENB_;
      STOV_int = STOV_;
      EMAB_int = EMAB_;
      RET1N_int = RET1N_;
      if (CENB_int != 1'b1) begin
        AB_int = AB_;
        DB_int = DB_;
      end
      clk1_int = 1'b0;
      CENB_int = CENB_;
      STOV_int = STOV_;
      EMAB_int = EMAB_;
      RET1N_int = RET1N_;
      if (CENB_int != 1'b1) begin
        AB_int = AB_;
        DB_int = DB_;
      end
      clk1_int = 1'b0;
    WriteB;
    if (CENB_int == 1'b0) previous_CLKB = $realtime;
    #0;
      if (((previous_CLKA == previous_CLKB) || ((STOV_int==1'b1 || STOV_int==1'b1) && CLKA_ == 1'b1 && CLKB_ == 1'b1)) && (CENA_int != 1'b1 && CENB_int 
       != 1'b1) && is_contention(AA_int, AB_int, 1'b1, 1'b0)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
      end
     end
    end else if (CLKB_ == 1'b0 && LAST_CLKB == 1'b1) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
  end
  end
    LAST_CLKB = CLKB_;
  end

  reg globalNotifier1;
  initial globalNotifier1 = 1'b0;
  initial cont_flag1_int = 1'b0;

  always @ globalNotifier1 begin
    if ($realtime == 0) begin
    end else if (CENB_int == 1'bx || RET1N_int == 1'bx || (STOV_int && !CENB_int) == 1'bx || 
      clk1_int == 1'bx) begin
      failedWrite(1);
    end else if (CENB_int == 1'b0 && (^AB_int) == 1'bx) begin
        failedWrite(1);
    end else if  (cont_flag1_int == 1'bx && (CENA_int != 1'b1 && CENB_int != 1'b1) && is_contention(AA_int, AB_int, 1'b1, 1'b0)) begin
      cont_flag1_int = 1'b0;
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
    end else begin
      #0;
      WriteB;
   end
      #0;
    globalNotifier1 = 1'b0;
  end






// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
	always @ (VDDCE or VDDPE or VSSE) begin
		if (VDDCE == 1'bx || VDDCE == 1'bz) begin
			$display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
        XQA = 1'b1; QA_update = 1'b1;
        XDB_sh = 1'b1; DB_sh_update = 1'b1;
			failedWrite(0);
			bad_VDDCE = 1'b1;
		end else begin
			bad_VDDCE = 1'b0;
		end
		if (RET1N_ == 1'b1 && VDDPE != 1'b1) begin
			$display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
        XQA = 1'b1; QA_update = 1'b1;
        XDB_sh = 1'b1; DB_sh_update = 1'b1;
			failedWrite(0);
			bad_VDDPE = 1'b1;
		end else begin
			bad_VDDPE = 1'b0;
		end
		if (VSSE != 1'b0) begin
			$display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
        XQA = 1'b1; QA_update = 1'b1;
        XDB_sh = 1'b1; DB_sh_update = 1'b1;
			failedWrite(0);
			bad_VSSE = 1'b1;
		end else begin
			bad_VSSE = 1'b0;
		end
		bad_power = bad_VDDCE | bad_VDDPE | bad_VSSE ;
	end
`endif

  function row_contention;
    input [8:0] aa;
    input [8:0] ab;
    input  wena;
    input  wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) == 1'b1 && (& wenb) == 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[8:2] == ab[8:2]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [8:0] aa;
    input [8:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [8:0] aa;
    input [8:0] ab;
    input  wena;
    input  wenb;
    reg result;
  begin
    if ((& wena) == 1'b1 && (& wenb) == 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction

   wire contA_flag = (CENA_int != 1'b1  && CENB_ != 1'b1) && ((is_contention(AB_, AA_int, 1'b0, 1'b1)));
   wire contB_flag = (CENB_int != 1'b1  && CENA_ != 1'b1) && ((is_contention(AA_, AB_int, 1'b1, 1'b0)));

  always @ NOT_CENA begin
    CENA_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA8 begin
    AA_int[8] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA7 begin
    AA_int[7] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA6 begin
    AA_int[6] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA5 begin
    AA_int[5] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA4 begin
    AA_int[4] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA3 begin
    AA_int[3] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA2 begin
    AA_int[2] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA1 begin
    AA_int[1] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA0 begin
    AA_int[0] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CENB begin
    CENB_int = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB8 begin
    AB_int[8] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB7 begin
    AB_int[7] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB6 begin
    AB_int[6] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB5 begin
    AB_int[5] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB4 begin
    AB_int[4] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB3 begin
    AB_int[3] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB2 begin
    AB_int[2] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB1 begin
    AB_int[1] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB0 begin
    AB_int[0] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB6 begin
    DB_int[6] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB5 begin
    DB_int[5] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB4 begin
    DB_int[4] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB3 begin
    DB_int[3] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB2 begin
    DB_int[2] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB1 begin
    DB_int[1] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB0 begin
    DB_int[0] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_STOV begin
    STOV_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAA2 begin
    EMAA_int[2] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAA1 begin
    EMAA_int[1] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAA0 begin
    EMAA_int[0] = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMASA begin
    EMASA_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAB2 begin
    EMAB_int[2] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAB1 begin
    EMAB_int[1] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAB0 begin
    EMAB_int[0] = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_RET1N begin
    RET1N_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end

  always @ NOT_CONTA begin
    cont_flag0_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_PER begin
    clk0_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_MINH begin
    clk0_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_MINL begin
    clk0_int = 1'bx;
    if ( globalNotifier0 == 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CONTB begin
    cont_flag1_int = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_PER begin
    clk1_int = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_MINH begin
    clk1_int = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_MINL begin
    clk1_int = 1'bx;
    if ( globalNotifier1 == 1'b0 ) globalNotifier1 = 1'bx;
  end



  wire contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq0, contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq1;
  wire contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq0, contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq1;
  wire contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq0, contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq1;
  wire contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq0, contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq1;
  wire STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq0, STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq0;
  wire STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq0, STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq0;
  wire STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq0, STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq0;
  wire STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq0, STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq0;
  wire STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq1, STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq1;
  wire STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq1, STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq1;
  wire STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq1, STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq1;
  wire STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq1, STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq1;
  wire STOVeq0aRET1Neq1aCENAeq0, STOVeq1aRET1Neq1aCENAeq0, contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq0;
  wire contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq1, contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq0;
  wire contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq1, contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq0;
  wire contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq1, contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq0;
  wire contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq1, STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq0;
  wire STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq1, STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq0;
  wire STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq1, STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq0;
  wire STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq1, STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq0;
  wire STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq1, STOVeq1aRET1Neq1, STOVeq0aRET1Neq1aCENBeq0;
  wire STOVeq1aRET1Neq1aCENBeq0, RET1Neq1, RET1Neq1aCENAeq0, RET1Neq1aCENBeq0;


  assign contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq0 = RET1N&&!EMAA[2]&&!EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq1 = RET1N&&!EMAA[2]&&!EMAA[1]&&EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq0 = RET1N&&!EMAA[2]&&EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq1 = RET1N&&!EMAA[2]&&EMAA[1]&&EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq0 = RET1N&&EMAA[2]&&!EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq1 = RET1N&&EMAA[2]&&!EMAA[1]&&EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq0 = RET1N&&EMAA[2]&&EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq1 = RET1N&&EMAA[2]&&EMAA[1]&&EMAA[0] && contA_flag;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq0 = !STOV&&RET1N&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq0 = !STOV&&RET1N&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq0 = !STOV&&RET1N&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq0 = !STOV&&RET1N&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq0 = !STOV&&RET1N&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq0 = !STOV&&RET1N&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq0 = !STOV&&RET1N&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq0 = !STOV&&RET1N&&EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq1 = !STOV&&RET1N&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq1 = !STOV&&RET1N&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq1 = !STOV&&RET1N&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq1 = !STOV&&RET1N&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq1 = !STOV&&RET1N&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq1 = !STOV&&RET1N&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq1 = !STOV&&RET1N&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMASA;
  assign STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq1 = !STOV&&RET1N&&EMAA[2]&&EMAA[1]&&EMAA[0]&&EMASA;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq0 = RET1N&&!EMAB[2]&&!EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq1 = RET1N&&!EMAB[2]&&!EMAB[1]&&EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq0 = RET1N&&!EMAB[2]&&EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq1 = RET1N&&!EMAB[2]&&EMAB[1]&&EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq0 = RET1N&&EMAB[2]&&!EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq1 = RET1N&&EMAB[2]&&!EMAB[1]&&EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq0 = RET1N&&EMAB[2]&&EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq1 = RET1N&&EMAB[2]&&EMAB[1]&&EMAB[0] && contB_flag;
  assign STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq0 = !STOV&&RET1N&&!EMAB[2]&&!EMAB[1]&&!EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq1 = !STOV&&RET1N&&!EMAB[2]&&!EMAB[1]&&EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq0 = !STOV&&RET1N&&!EMAB[2]&&EMAB[1]&&!EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq1 = !STOV&&RET1N&&!EMAB[2]&&EMAB[1]&&EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq0 = !STOV&&RET1N&&EMAB[2]&&!EMAB[1]&&!EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq1 = !STOV&&RET1N&&EMAB[2]&&!EMAB[1]&&EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq0 = !STOV&&RET1N&&EMAB[2]&&EMAB[1]&&!EMAB[0];
  assign STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq1 = !STOV&&RET1N&&EMAB[2]&&EMAB[1]&&EMAB[0];

  assign STOVeq0aRET1Neq1aCENAeq0 = !STOV&&RET1N&&!CENA;
  assign STOVeq1aRET1Neq1aCENAeq0 = STOV&&RET1N&&!CENA;
  assign STOVeq0aRET1Neq1aCENBeq0 = !STOV&&RET1N&&!CENB;
  assign STOVeq1aRET1Neq1aCENBeq0 = STOV&&RET1N&&!CENB;

  assign STOVeq1aRET1Neq1 = STOV&&RET1N;
  assign RET1Neq1 = RET1N;
  assign RET1Neq1aCENAeq0 = RET1N&&!CENA;
  assign RET1Neq1aCENBeq0 = RET1N&&!CENB;

  specify

    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b0)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b0 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b0 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b0 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (RET1N == 1'b1 && CENA == 1'b0 && EMAA[2] == 1'b1 && EMAA[1] == 1'b1 && EMAA[0] == 1'b1 && EMASA == 1'b1)
       (posedge CLKA => (QA[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge CLKA, `ARM_MEM_PERIOD, NOT_CLKA_PER);
   `else
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq0, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq0aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq0aEMAA0eq1aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq0aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq0aEMAA1eq1aEMAA0eq1aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq0aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq0aEMAA0eq1aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq0aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq0aRET1Neq1aEMAA2eq1aEMAA1eq1aEMAA0eq1aEMASAeq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
       $period(posedge CLKA &&& STOVeq1aRET1Neq1, `ARM_MEM_PERIOD, NOT_CLKA_PER);
   `endif

   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge CLKB, `ARM_MEM_PERIOD, NOT_CLKB_PER);
   `else
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq0, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq0aEMAB0eq1, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq0, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq0aEMAB1eq1aEMAB0eq1, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq0, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq0aEMAB0eq1, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq0, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq0aRET1Neq1aEMAB2eq1aEMAB1eq1aEMAB0eq1, `ARM_MEM_PERIOD, NOT_CLKB_PER);
       $period(posedge CLKB &&& STOVeq1aRET1Neq1, `ARM_MEM_PERIOD, NOT_CLKB_PER);
   `endif


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge CLKA, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINH);
       $width(negedge CLKA, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINL);
   `else
       $width(posedge CLKA &&& STOVeq0aRET1Neq1aCENAeq0, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINH);
       $width(posedge CLKA &&& STOVeq1aRET1Neq1aCENAeq0, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINH);
       $width(negedge CLKA &&& STOVeq0aRET1Neq1aCENAeq0, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINL);
       $width(negedge CLKA &&& STOVeq1aRET1Neq1aCENAeq0, `ARM_MEM_WIDTH, 0, NOT_CLKA_MINL);
   `endif

   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge CLKB, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINH);
       $width(negedge CLKB, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINL);
   `else
       $width(posedge CLKB &&& STOVeq0aRET1Neq1aCENBeq0, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINH);
       $width(posedge CLKB &&& STOVeq1aRET1Neq1aCENBeq0, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINH);
       $width(negedge CLKB &&& STOVeq0aRET1Neq1aCENBeq0, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINL);
       $width(negedge CLKB &&& STOVeq1aRET1Neq1aCENBeq0, `ARM_MEM_WIDTH, 0, NOT_CLKB_MINL);
   `endif


    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq0, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq0aEMAA0eq1, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq0, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq0aEMAA1eq1aEMAA0eq1, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq0, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq0aEMAA0eq1, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq0, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge CLKB &&& contA_RET1Neq1aCENAeq0aEMAA2eq1aEMAA1eq1aEMAA0eq1, posedge CLKA, `ARM_MEM_COLLISION, 0.000, NOT_CONTA);

    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq0, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq0aEMAB0eq1, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq0, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq0aEMAB1eq1aEMAB0eq1, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq0, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq0aEMAB0eq1, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq0, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge CLKA &&& contB_RET1Neq1aCENBeq0aEMAB2eq1aEMAB1eq1aEMAB0eq1, posedge CLKB, `ARM_MEM_COLLISION, 0.000, NOT_CONTB);

    $setuphold(posedge CLKA &&& RET1Neq1, posedge CENA, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_CENA);
    $setuphold(posedge CLKA &&& RET1Neq1, negedge CENA, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_CENA);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA8);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA7);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA6);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA5);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA4);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA3);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA2);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA1);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge AA[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA0);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA8);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA7);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA6);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA5);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA4);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA3);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA2);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA1);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge AA[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AA0);
    $setuphold(posedge CLKB &&& RET1Neq1, posedge CENB, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_CENB);
    $setuphold(posedge CLKB &&& RET1Neq1, negedge CENB, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_CENB);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB8);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB7);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB6);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB5);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB4);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB3);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB2);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB1);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge AB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB0);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB8);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB7);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB6);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB5);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB4);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB3);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB2);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB1);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge AB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_AB0);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB6);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB5);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB4);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB3);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB2);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB1);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge DB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB0);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB6);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB5);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB4);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB3);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB2);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB1);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge DB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_DB0);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge STOV, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_STOV);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge STOV, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_STOV);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge STOV, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_STOV);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge STOV, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_STOV);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge EMAA[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA2);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge EMAA[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA1);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge EMAA[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA0);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge EMAA[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA2);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge EMAA[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA1);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge EMAA[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAA0);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, posedge EMASA, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMASA);
    $setuphold(posedge CLKA &&& RET1Neq1aCENAeq0, negedge EMASA, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMASA);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge EMAB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB2);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge EMAB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB1);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, posedge EMAB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB0);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge EMAB[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB2);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge EMAB[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB1);
    $setuphold(posedge CLKB &&& RET1Neq1aCENBeq0, negedge EMAB[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_EMAB0);
    $setuphold(negedge RET1N, negedge CENA, 0.000, `ARM_MEM_HOLD, NOT_RET1N);
    $setuphold(posedge RET1N, negedge CENA, 0.000, `ARM_MEM_HOLD, NOT_RET1N);
    $setuphold(negedge RET1N, negedge CENB, 0.000, `ARM_MEM_HOLD, NOT_RET1N);
    $setuphold(posedge RET1N, negedge CENB, 0.000, `ARM_MEM_HOLD, NOT_RET1N);
    $setuphold(posedge CENB, negedge RET1N, 0.000, `ARM_MEM_HOLD, NOT_RET1N);
    $setuphold(posedge CENA, negedge RET1N, 0.000, `ARM_MEM_HOLD, NOT_RET1N);
    $setuphold(posedge CENB, posedge RET1N, 0.000, `ARM_MEM_HOLD, NOT_RET1N);
    $setuphold(posedge CENA, posedge RET1N, 0.000, `ARM_MEM_HOLD, NOT_RET1N);
  endspecify


endmodule
`endcelldefine
`endif
`endif
`timescale 1ns/1ps
module Context_Memory_error_injection (Q_out, Q_in, CLK, A, CEN);
   output [6:0] Q_out;
   input [6:0] Q_in;
   input CLK;
   input [8:0] A;
   input CEN;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter NO_RED_FAULT = 2'd0;
   reg [6:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [16:0] fault_table [91:0];
   reg [16:0] fault_entry;
initial
begin
   `ifdef DUT
      `define pre_pend_path TB.DUT_inst.CHIP
   `else
       `define pre_pend_path TB.CHIP
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST.u1.add_fault(9'd310,3'd4,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
      input [8:0] address;
      input [2:0] bitPlace;
      input [1:0] fault_type;
      input [1:0] red_fault;
 
      integer i;
      reg done;
   begin
      done = 1'b0;
      i = 0;
      while ((!done) && i < 91)
      begin
         fault_entry = fault_table[i];
         if (fault_entry[0] == 1'b0 || fault_entry[0] == 1'bx)
         begin
            fault_entry[0] = 1'b1;
            fault_entry[2:1] = red_fault;
            fault_entry[4:3] = fault_type;
            fault_entry[7:5] = bitPlace;
            fault_entry[16:8] = address;
            fault_table[i] = fault_entry;
            done = 1'b1;
         end
         i = i+1;
      end
   end
   endtask
//This task removes all fault entries injected by user
task remove_all_faults;
   integer i;
begin
   for (i = 0; i < 92; i=i+1)
   begin
      fault_entry = fault_table[i];
      fault_entry[0] = 1'b0;
      fault_table[i] = fault_entry;
   end
end
endtask
task bit_error;
// This task is used to inject error in memory and should be called
// only from current module.
//
// This task injects error depending upon fault type to particular bit
// of the output
   inout [6:0] q_int;
   input [1:0] fault_type;
   input [2:0] bitLoc;
begin
   if (fault_type == 2'd0)
      q_int[bitLoc] = 1'b0;
   else if (fault_type == 2'd1)
      q_int[bitLoc] = 1'b1;
   else
      q_int[bitLoc] = ~q_int[bitLoc];
end
endtask
task error_injection_on_output;
// This function goes through error injection table for every
// read cycle and corrupts Q output if fault for the particular
// address is present in fault table
//
// If fault is redundant column is detected, this task corrupts
// Q output in read cycle
//
// If fault is repaired using repair bus, this task does not
// courrpt Q output in read cycle
//
   output [6:0] Q_output;
   reg list_complete;
   integer i;
   reg [4:0] FRA_reg;
   reg [6:0] row_address;
   reg [1:0] column_address;
   reg [2:0] bitPlace;
   reg [1:0] fault_type;
   reg [1:0] red_fault;
   reg valid;
   reg [2:0] msb_bit_calc;
begin
   entry_found = 1'b0;
   list_complete = 1'b0;
   i = 0;
   Q_output = Q_in;
   while(!list_complete)
   begin
      fault_entry = fault_table[i];
      {row_address, column_address, bitPlace, fault_type, red_fault, valid} = fault_entry;
      FRA_reg = row_address/4;
      i = i + 1;
      if (valid == 1'b1)
      begin
         if (red_fault == NO_RED_FAULT)
         begin
            if (row_address == A[8:2] && column_address == A[1:0])
            begin
               if (bitPlace < 3)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 3 )
                  bit_error(Q_output,fault_type, bitPlace);
            end
         end
      end
      else
         list_complete = 1'b1;
      end
   end
   endtask
   always @ (Q_in or CLK or A or CEN)
   begin
   if (CEN == 1'b0)
      error_injection_on_output(Q_out);
   else
      Q_out = Q_in;
   end
endmodule
