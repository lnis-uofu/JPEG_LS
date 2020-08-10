vsim -voptargs=+acc work.FullJPEGIntegrationTB

add wave -divider {<Top Level>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/*

add wave -divider {<Get Data FSM>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/GetSampleDataFSM/*

add wave -divider {<Stage 1 Pipeline Registers>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Stage_1_to_2/*

add wave -divider {<Gradient Quantizer>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Quantizer/*

add wave -divider {<RIType>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/RunInterruptionType/*

add wave -divider {<Mode Type>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/ModeType/*

add wave -divider {<Run Counter>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/RunCounting/*

add wave -divider {<Stage 2 Pipeline Registers>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Stage_2_to_3/*

add wave -divider {<Context Gradient>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Context_Number/*

add wave -divider {<Predictor>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Predictor_x/*

add wave -divider {<Run Coder>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Run_Coder/*

add wave -divider {<Stage 3 Pipeline Registers>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Stage_3_to_4/*

add wave -divider {<DetermineContextRead_Write>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/ContextRead_Write/*

add wave -divider {<N Update>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Updater/*

add wave -divider {<Context Mux>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/ContextDecision/*

add wave -divider {<Prediction Residual>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Residual/*

add wave -divider {<Temp Calculation>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/temp_calculation/*

add wave -divider {<Stage 4 Pipeline Registers>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/stage_4_to_5/*

add wave -divider {<Context Update>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Context_Variable_Update/*

add wave -divider {<Bias Cancel>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Context_Variable_Update/bias_cancel/*

add wave -divider {<Error Modulo>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/mod_map/*

add wave -divider {<K Calculation>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/Golomb_k/*

add wave -divider {<Run Length Adjust>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/RLAdjust/*

add wave -divider {<Stage 5 Pipeline Registers>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/stage_5_to_6/*

add wave -divider {<Golomb Encoder>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/RiceEncoder/*

add wave -divider {<Stage 6 Registers>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/stage_6_to_7/*

add wave -divider {<Bit Packer>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/outputBP/*

add wave -divider {<Bit Packer Function>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/outputBP/BPFunction/*

add wave -divider {<Stage 7 Registers>}

add wave -position insertpoint sim:/FullJPEGIntegrationTB/JPEGLS_ENCODER/stage_7_to_out/*




