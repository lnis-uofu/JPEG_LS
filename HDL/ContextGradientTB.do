vsim -voptargs=+acc work.ContextGradientTB

add wave -position insertpoint sim:/ContextGradientTB/*

run -all

