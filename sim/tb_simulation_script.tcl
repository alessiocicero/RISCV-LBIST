add wave sim:/tb_top/riscv_wrapper_gate/ram_i/*
add wave sim:/tb_top/riscv_wrapper_gate/*
#add wave sim:/tb_top/riscv_wrapper_gate/lbist/lfsr_port/*
#add wave sim:/tb_top/riscv_wrapper_gate/lbist/misr_port/*
#add wave sim:/tb_top/riscv_wrapper_gate/lbist/bist_port/*
add wave sim:/tb_top/riscv_wrapper_gate/lbist/*
add wave sim:/tb_top/riscv_wrapper_gate/lbist/bist_port/*
vcd dumpports /tb_top/riscv_wrapper_gate/riscv_core_i/* -file riscv_dumpports_100.vcd
vcd dumpports /tb_top/riscv_wrapper_gate/lbist/bist_port/* -file lbist_dumpport.vcd

#100 Vettori:
run 154090 ns

#10 Vettori:
#run 17000 ns
#run 3500 ns
