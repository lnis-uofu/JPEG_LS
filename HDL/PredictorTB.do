vsim -voptargs=+acc work.PredictorTB

add wave -position insertpoint sim:/PredictorTB/*

run -all

