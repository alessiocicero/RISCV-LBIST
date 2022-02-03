read_netlist ../gate/NangateOpenCellLibrary.tlib -library
read_netlist ../syn/output/riscv_core_scan.v
run_build_model riscv_core_0_128_1_16_1_1_0_0_0_0_0_0_0_0_0_3_6_15_5_1a110800
run_drc ../syn/output/riscv_core_scan.spf
set_faults -model stuck
add_faults -all
set_patterns -internal
set_atpg -full_seq_atpg
run_atpg -auto_compression
report_summaries > report/atpg/report_summary.txt
