bg// Copyright 2018 Robert Balas <balasr@student.ethz.ch>
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Wrapper for a RI5CY testbench, containing RI5CY, Memory and stdout peripheral
// Contributor: Robert Balas <balasr@student.ethz.ch>

module riscv_wrapper
    #(parameter INSTR_RDATA_WIDTH = 128,
      parameter RAM_ADDR_WIDTH = 20,
      parameter BOOT_ADDR = 'h80,
      parameter PULP_SECURE = 1)
    (input logic         clk_i,
     input logic         rst_ni,

     input logic         fetch_enable_i,
     output logic        tests_passed_o,
     output logic        tests_failed_o,
     output logic [31:0] exit_value_o,
     output logic        exit_valid_o);

    // signals connecting core to memory
    logic                         instr_req;
    logic                         instr_gnt;
    logic                         instr_rvalid;
    logic [31:0]                  instr_addr;
    logic [INSTR_RDATA_WIDTH-1:0] instr_rdata;

    logic                         data_req;
    logic                         data_gnt;
    logic                         data_rvalid;
    logic [31:0]                  data_addr;
    logic                         data_we;
    logic [3:0]                   data_be;
    logic [31:0]                  data_rdata;
    logic [31:0]                  data_wdata;

    // signals to debug unit
    logic                         debug_req_i;

    // irq signals (not used)
    logic                         irq;
    logic [0:4]                   irq_id_in;
    logic                         irq_ack;
    logic [0:4]                   irq_id_out;
    logic                         irq_sec;

    //bist signals
	logic [19:0]		  scan_chain_output;    
	logic [19:0]		  scan_chain_output;
	logic 			test_point;
    // interrupts (only timer for now)
    assign irq_sec     = '0;

    assign debug_req_i = 1'b0;

    // instantiate bist

    lbist
    bist
        (
          .clk                (clk_i),
          .resetn             (rst_ni),
          .test_normal        (),
          .clk_en_i           ('1),
          .scan_chain_output  (),
          .scan_chain_input   (),
          .test_en_i          ('1),
          .test_mode_tp       (),
          .go_nogo            ());

    // instantiate the core
    riscv_core_0_128_1_16_1_1_0_0_0_0_0_0_0_0_0_3_6_15_5_1a110800
    riscv_core_i
        (
         .clk_i                  ( clk_i                 ),
         .rst_ni                 ( rst_ni                ),

         .clock_en_i             ( '1                    ),
         .test_en_i              ( '0                    ),
         .test_mode_tp           (test_point),

         .test_si1                (scan_chain_input[0]),
         .test_si2                (scan_chain_input[1]),
         .test_si3                (scan_chain_input[2]),
         .test_si4                (scan_chain_input[3]),
         .test_si5                (scan_chain_input[4]),
         .test_si6                (scan_chain_input[5]),
         .test_si7                (scan_chain_input[6]),
         .test_si8                (scan_chain_input[7]),
         .test_si9                (scan_chain_input[8]),
         .test_si10               (scan_chain_input[9]),
         .test_si11               (scan_chain_input[10]),
         .test_si12               (scan_chain_input[11]),
         .test_si13               (scan_chain_input[12]),
         .test_si14               (scan_chain_input[13]),
         .test_si15               (scan_chain_input[14]),
         .test_si16               (scan_chain_input[15]),
         .test_si17               (scan_chain_input[16]),
         .test_si18               (scan_chain_input[17]),
         .test_si19               (scan_chain_input[18]),
         .test_si20               (scan_chain_input[19]),

         .test_so1                (scan_chain_output[0]),
         .test_so2                (scan_chain_output[1]),
         .test_so3                (scan_chain_output[2]),
         .test_so4                (scan_chain_output[3]),
         .test_so5                (scan_chain_output[4]),
         .test_so6                (scan_chain_output[5]),
         .test_so7                (scan_chain_output[6]),
         .test_so8                (scan_chain_output[7]),
         //.test_so9                (scan_chain_output[8]),
         //.test_so10               (scan_chain_output[9]),
         .test_so11               (scan_chain_output[10]),
         .test_so12               (scan_chain_output[11]),
         .test_so13               (scan_chain_output[12]),
         .test_so14               (scan_chain_output[13]),
         .test_so15               (scan_chain_output[14]),
         .test_so16               (scan_chain_output[15]),
         .test_so17               (scan_chain_output[16]),
         .test_so18               (scan_chain_output[17]),
         .test_so19               (scan_chain_output[18]),
         .test_so20               (scan_chain_output[19]),

         .boot_addr_i            ( BOOT_ADDR             ),
         .core_id_i              ( 4'h0                  ),
         .cluster_id_i           ( 6'h0                  ),

         .instr_addr_o           ( instr_addr            ),
         .instr_req_o            ( instr_req             ),
         .instr_rdata_i          ( instr_rdata           ),
         .instr_gnt_i            ( instr_gnt             ),
         .instr_rvalid_i         ( instr_rvalid          ),

         .data_addr_o            ( data_addr             ),
         .data_wdata_o           ( data_wdata            ),
         .data_we_o              ( data_we               ),
         .data_req_o             ( data_req              ),
         .data_be_o              ( data_be               ),
         .data_rdata_i           ( data_rdata            ),
         .data_gnt_i             ( data_gnt              ),
         .data_rvalid_i          ( data_rvalid           ),

         .apu_master_req_o       (                       ),
         .apu_master_ready_o     (                       ),
         .apu_master_gnt_i       (                       ),
         .apu_master_operands_o  (                       ),
         .apu_master_op_o        (                       ),
         .apu_master_type_o      (                       ),
         .apu_master_flags_o     (                       ),
         .apu_master_valid_i     (                       ),
         .apu_master_result_i    (                       ),
         .apu_master_flags_i     (                       ),

         .irq_i                  ( irq                   ),
         .irq_id_i               ( irq_id_in             ),
         .irq_ack_o              ( irq_ack               ),
         .irq_id_o               ( irq_id_out            ),
         .irq_sec_i              ( irq_sec               ),

         .sec_lvl_o              ( sec_lvl_o             ),

         .debug_req_i            ( debug_req_i           ),

         .fetch_enable_i         ( fetch_enable_i        ),
         .core_busy_o            ( core_busy_o           ),

         .ext_perf_counters_i    (                       ),
         .fregfile_disable_i     ( 1'b0                  ));
//The scan chain insertion changes the scan data out to a already existing pin
         test_so9 <= data_we;
         test_so10 <= irq_id_out[4];

endmodule // riscv_wrapper
