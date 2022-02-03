#!/bin/bash

cd $( dirname $0)
#added by me
cd ..

root_dir=${PWD}
cd - &>/dev/null

run_dir=${root_dir}/sim/run

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
vlog -work work_gate -cover t -novopt -timescale "1 ns/ 10 ps" ${root_dir}/syn/output/riscv_core_scan.v
#vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 1 ps" -suppress 2577 -suppress 2583  \
#	${root_dir}/gate/riscv_core.v \
#	${root_dir}/rtl/include/riscv_config.sv \
#	${root_dir}/tb/core/fpnew/src/fpnew_pkg.sv \
#	${root_dir}/rtl/include/apu_core_package.sv \
#	${root_dir}/rtl/include/riscv_tracer_defines.sv \
#	${root_dir}/tb/tb_riscv/include/perturbation_defines.sv \
#	${root_dir}/tb/tb_riscv/riscv_perturbation.sv \

vlog -sv -work work_gate -cover t -novopt -timescale "1 ns/ 10 ps" -suppress 2577 -suppress 2583	${root_dir}/syn_lbist/riscv_wrapper_gate.sv


#vopt -work work_gate -debugdb -fsmdebug "+acc" tb_top -o tb_top_vopt

#vsim -t "10 ps" -novopt work_gate.tb_top -do ${root_dir}/sim/tb_simulation_script.tcl

#exit #(SKIP RTL)
### RTL VERSION #################

#rm -rf work_rtl

#vlib  work_rtl
#
#vlog -sv -work work_rtl +acc=rnbpc -cover t +incdir+${root_dir}/rtl/include  -suppress 2577 -suppress 2583 \
#	${root_dir}/tb/core/fpnew/src/fpnew_pkg.sv \
#	${root_dir}/rtl/include/apu_core_package.sv \
#	${root_dir}/rtl/include/riscv_defines.sv \
#	${root_dir}/rtl/include/riscv_tracer_defines.sv \
#	${root_dir}/tb/tb_riscv/include/perturbation_defines.sv \
#	${root_dir}/rtl/riscv_if_stage.sv \
#	${root_dir}/rtl/riscv_hwloop_controller.sv \
#	${root_dir}/rtl/riscv_tracer.sv \
#	${root_dir}/rtl/riscv_prefetch_buffer.sv \
#	${root_dir}/rtl/riscv_hwloop_regs.sv \
 # ${root_dir}/rtl/riscv_int_controller.sv \
#	${root_dir}/rtl/riscv_cs_registers.sv \
#	${root_dir}/rtl/riscv_register_file.sv \
#	${root_dir}/rtl/riscv_load_store_unit.sv \
#	${root_dir}/rtl/riscv_id_stage.sv \
#	#${root_dir}/rtl/riscv_core.sv \
 # ${root_dir}/syn/output/riscv_core_scan.sv \
#	${root_dir}/rtl/riscv_compressed_decoder.sv \
#	${root_dir}/rtl/riscv_fetch_fifo.sv \
#	${root_dir}/rtl/riscv_alu_div.sv \
#	${root_dir}/rtl/riscv_prefetch_L0_buffer.sv \
#	${root_dir}/rtl/riscv_decoder.sv \
#	${root_dir}/rtl/riscv_mult.sv \
#	${root_dir}/rtl/register_file_test_wrap.sv \
#	${root_dir}/rtl/riscv_L0_buffer.sv \
#	${root_dir}/rtl/riscv_ex_stage.sv \
#	${root_dir}/rtl/riscv_alu_basic.sv \
#	${root_dir}/rtl/riscv_pmp.sv \
#	${root_dir}/rtl/riscv_apu_disp.sv \
#	${root_dir}/rtl/riscv_alu.sv \
#	${root_dir}/rtl/riscv_controller.sv \
#	${root_dir}/tb/tb_riscv/riscv_random_stall.sv \
#	${root_dir}/tb/tb_riscv/riscv_random_interrupt_generator.sv \
#	${root_dir}/tb/core/riscv_wrapper.sv \
#	${root_dir}/tb/core/dp_ram.sv \
#	${root_dir}/tb/core/cluster_clock_gating.sv \
#	${root_dir}/tb/core/tb_top.sv \
#	${root_dir}/tb/core/mm_ram.sv
#
#vopt -work work_rtl -debugdb -fsmdebug "+acc=rnbpc" tb_top -o tb_top_vopt

