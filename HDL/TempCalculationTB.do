vsim -voptargs=+acc work.TempCalculationTB

add wave -position insertpoint sim:/TempCalculationTB/temp_calc/*

bp ./TempCalculationTB.v 44

run -all

run 100ns


