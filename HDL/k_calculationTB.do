vsim -voptargs=+acc work.k_calculationTB

add wave -position insertpoint sim:/k_calculationTB/k_calc/*

run -all
