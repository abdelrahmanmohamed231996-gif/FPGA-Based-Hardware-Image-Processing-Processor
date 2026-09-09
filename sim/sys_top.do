vlog ../rtl/*
vlog *.v
vsim -voptargs=+acc system_top_tb
add wave *
run -all