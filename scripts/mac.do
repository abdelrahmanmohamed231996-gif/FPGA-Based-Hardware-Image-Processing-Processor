vlog mac_mult_array.v tb_mac_mult_array.v
vsim -voptargs=+acc tb_mac_mult_array
add wave *
run -all
