vlog signed_adder_subtractor.v in9_reg.v delay_multibit.v adder_tree.v tb_adder_tree.v
vsim -voptargs=+acc tb_adder_tree
add wave *
add wave -position insertpoint  \
sim:/tb_adder_tree/uut/in9_w
add wave -position insertpoint  \
sim:/tb_adder_tree/uut/out_row_delay_inst/data_in \
sim:/tb_adder_tree/uut/out_row_delay_inst/data_out \
sim:/tb_adder_tree/uut/out_row_delay_inst/shift_reg
run -all
