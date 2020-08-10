vsim -voptargs=+acc work.Context_UpdateTB

radix -decimal

add wave -divider {<Top Level>}

add wave -position insertpoint sim:/Context_UpdateTB/*

add wave -divider {<Context Updater>}

add wave -position insertpoint  \
sim:/Context_UpdateTB/context_bias/*

add wave -divider {<Bias Cancel>}

add wave -position insertpoint  \
sim:/Context_UpdateTB/context_bias/bias_cancel/*



