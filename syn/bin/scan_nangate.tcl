set GATE_PATH			../output
set LOG_PATH			../log

set TECH 			NangateOpenCell
set TOPLEVEL			riscv_core

set search_path [ join "../techlib/ $search_path" ]
set search_path [ join "$GATE_PATH $search_path" ]

source ../bin/$TECH.dc_setup_scan.tcl


read_ddc $TOPLEVEL.ddc
#link
#check_design
create_logic_port -direction in test_mode_tp
compile_ultra -incremental -gate_clock -scan -no_autoungroup


set_dft_clock_gating_pin [get_cells * -hierarchical -filter "@ref_name =~ SNPS_CLOCK_GATE*"] -pin_name TE


report_area
#set_dft_configuration -scan_compression enable
set_dft_configuration -testability enable
set test_default_scan_style multiplexed_flip_flop
set_scan_element false NangateOpenCellLibrary/DLH_X1

### Set pins functionality ###
set_dft_signal -view existing_dft -type Constant -active_state 1 -port test_mode_tp
set_dft_signal -view spec -type TestMode -active_state 1 -port test_mode_tp

set_dft_signal  -view existing_dft -type ScanEnable -port test_en_i
set_dft_signal  -view spec -type ScanEnable -port test_en_i 

#set_dft_configuration -testability enable
#set_testability_configuration -target core_wrapper

#configure global automatic
set_testability_configuration -control_signal test_mode_tp -test_points_per_scan_cell 18
#enable and configure
set_testability_configuration -target random_resistant -random_pattern_count 1100

set_testability_configuration -target x_blocking

set_scan_configuration -chain_count 20
#set_scan_configuration -chain_count 1
#set_scan_compression_configuration -chain_count 10

#preview test points
create_test_protocol -infer_asynch -infer_clock
dft_drc
#preview_dft
##Added to preview the test points
run_test_point_analysis > ../reports/test_point_analyisis.txt
preview_dft -test_points all > ../reports/preview_test_points.txt

insert_dft

streaming_dft_planner

change_names -rules verilog -hierarchy

#report_scan_path -test_mode all
report_area
report_area > ../reports/report_area.txt
report_clock_gating
report_clock_gating > ../reports/report_clock_gating.txt
report_power 
report_power > ../reports/report_power.txt

#report delle scan chain raggruppate in tabella
report_scan_path -view existing_dft -chain all -test_mode all
report_scan_path -view existing_dft -chain all -test_mode all > ../reports/simulation_result20.txt

write -hierarchy -format verilog -output "${GATE_PATH}/${TOPLEVEL}_scan.v"
write_sdf -version 3.0 "${GATE_PATH}/${TOPLEVEL}_scan.sdf"
write_sdc "${GATE_PATH}/${TOPLEVEL}_scan.sdc"
write_test_protocol -output "${GATE_PATH}/${TOPLEVEL}_scan.spf" -test_mode Internal_scan
write_test_protocol -output "${GATE_PATH}/${TOPLEVEL}_scancompress.spf" -test_mode ScanCompression_mode

#quit
