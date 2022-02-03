#!/bin/bash

cd $( dirname $0)
#added by me
cd ..

root_dir=${PWD}
cd - &>/dev/null

run_dir=${root_dir}/sim/run
firmware_path=${root_dir}/sim/sbst.hex
mkdir -p ${run_dir}

cd ${run_dir}

### GATE LEVEL VERSION #########

#rm -rf work_gate
vcom -work work_gate ${root_dir}/src/flipflop.vhd
vcom -work work_gate ${root_dir}/src/mux2to1.vhd
vcom -work work_gate ${root_dir}/src/lfsr.vhd
vcom -work work_gate ${root_dir}/src/misr.vhd
vcom -work work_gate ${root_dir}/src/bist_controller.vhd
vcom -work work_gate ${root_dir}/src/bist.vhd

vlog -work work_gate +define+functional ${root_dir}/gate/NangateOpenCellLibrary.v
vlog -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" ${root_dir}/syn/output/riscv_core_scan.v
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583 ${root_dir}/rtl/include/riscv_config.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583 ${root_dir}/tb/core/fpnew/src/fpnew_pkg.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583 ${root_dir}/rtl/include/apu_core_package.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583 ${root_dir}/rtl/include/riscv_defines.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583 ${root_dir}/rtl/include/riscv_tracer_defines.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583 ${root_dir}/tb/tb_riscv/include/perturbation_defines.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583 ${root_dir}/tb/tb_riscv/riscv_perturbation.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583 ${root_dir}/tb/tb_riscv/riscv_random_stall.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583 ${root_dir}/tb/tb_riscv/riscv_random_interrupt_generator.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583	${root_dir}/tb/core/riscv_wrapper_gate.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583	${root_dir}/tb/core/dp_ram.sv
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583	${root_dir}/tb/core/cluster_clock_gating.sv 
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583	${root_dir}/tb/core/tb_top.sv +vcd
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583	${root_dir}/tb/core/mm_ram.sv 
vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583	${root_dir}/tb/verilator-model/ram.sv

vopt -work work_gate -debugdb -fsmdebug "+acc" tb_top -o tb_top_vopt

vsim -c -t "10 ps" -novopt work_gate.tb_top "+firmware=${firmware_path}" -do ${root_dir}/sim/tb_simulation_script_nogui.tcl


