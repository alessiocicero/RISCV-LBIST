read_netlist ../gate/NangateOpenCellLibrary.tlib -library
read_netlist ../syn/output/riscv_core_scan.v
run_build_model riscv_core_0_128_1_16_1_1_0_0_0_0_0_0_0_0_0_3_6_15_5_1a110800
#add_clocks 0 clk_i
#add_clocks 0 rst_ni
add_pi_constraints 0 debug_req_i
run_drc ../syn/output/riscv_core_scan.spf
#set_patterns -external run/riscv_dumpports_100.vcd.fixed -sensitive -strobe_period {10 ns} -strobe_offset {72 ns}
set_faults -model stuck
add_faults -all
set_patterns -random
set_random_patterns -clock clk_i
set_random_patterns -length 10000
run_fault_sim
set_faults -summary verbose -fault_coverage
report_summaries
report_summaries > ./report/report_random_nomask.txt

