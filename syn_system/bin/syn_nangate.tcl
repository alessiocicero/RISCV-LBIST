set ROOT_PATH                    ../..
set RISCV_PATH              	$ROOT_PATH
set FPUNEW                      $ROOT_PATH/tb/core/fpnew
set GATE_PATH			../standalone
set LOG_PATH			../log

set TECH NangateOpenCell


#set search_path [ join "$RISCV_PATH/rtl/include $search_path" ]
set search_path [ join "/data/libraries/LIB065 $search_path" ]
set search_path [ join "/data/libraries/NangateOpenCellLibrary_PDKv1_3_v2010_12/fix_scan $search_path" ]
set search_path [ join "/data/libraries/pdt2002 $search_path" ]
set search_path [ join "../techlib/ $search_path" ]
#set search_path [ join "[getenv 'SYNOPSYS'] $search_path" ]

set synthetic_library dw_foundation.sldb
source ../bin/$TECH.dc_setup_synthesis.tcl

#analyze -format verilog  -work work ${RISCV_PATH}/syn/output/riscv_core_scan.v
analyze -format vhdl  -work work ${RISCV_PATH}/src/flipflop.vhd
analyze -format vhdl  -work work ${RISCV_PATH}/src/mux2to1.vhd
analyze -format vhdl  -work work ${RISCV_PATH}/src/lfsr.vhd
analyze -format vhdl  -work work ${RISCV_PATH}/src/misr.vhd
analyze -format vhdl  -work work ${RISCV_PATH}/src/bist_controller.vhd
analyze -format vhdl  -work work ${RISCV_PATH}/src/bist.vhd
#analyze -format sverilog  -work work ${RISCV_PATH}/syn_lbist/riscv_wrapper_gate.sv


set TOPLEVEL		bist


elaborate $TOPLEVEL -work work 

link
uniquify
check_design 

create_clock -name MY_CLK -period 10 clk
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] clk]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]


compile_ultra -no_autoungroup

#write -hierarchy -format verilog -output "${GATE_PATH}/${TOPLEVEL}.v"


report_area > ../report/report_area.txt
report_timing > ../report/report_timing.txt
report_power > ../report/report_power.txt
