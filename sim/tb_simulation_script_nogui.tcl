#vcd dumpports /tb_top/riscv_wrapper_gate/riscv_core_i/* -file riscv_dumpports_100_nogui.vcd
vcd dumpports /tb_top/riscv_wrapper_gate/lbist/bist_port/* -file lbist_dumpport_nogui.vcd
#log -r /*
#((153+1)*10000 + 153)*10=15401530
run 15404000 ns
#run 400 ns
quit

