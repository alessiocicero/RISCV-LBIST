// Copyright 2018 Robert Balas <balasr@student.ethz.ch>
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
     output logic        exit_valid_o,
     
     input logic         test_normal,
     output logic        go_nogo);

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

    // scan chains
    logic [19:0]                  scan_chain_input_sig;
    logic [19:0]                  scan_chain_output_sig;

    // signals form bist to riscv
    logic                         test_mode_tp_sig;
    logic                         test_en_i_sig;
    logic			  clk_en_i_sig;
	logic			  clk_mem_i;

	//logic irq_sig ;
       //logic [0:4] irq_id_in_sig ;

       logic  [INSTR_RDATA_WIDTH-1:0] instr_rdata_sig  ;       
       //logic  instr_gnt_sig    ;        
       //logic  instr_rvalid_sig  ;       

       //logic  [31:0] data_rdata_sig     ;      
       //logic  data_gnt_sig        ;    
       //logic  data_rvalid_sig      ;    

       logic irq_sec_sig   ;
		logic irq_sig;

       logic debug_req_i_sig;

	// signals to zero
       assign irq_sig 	='0;
       //assign irq_id_in_sig = 5'h0;

       assign  instr_rdata_sig         = 128'h1;
       //assign  instr_gnt_sig            ='0;
       //assign  instr_rvalid_sig         ='1;

       //assign  data_rdata_sig           =32'h0;
       //assign  data_gnt_sig            ='0;
       //assign  data_rvalid_sig          ='1;

    // interrupts (only timer for now)
       assign irq_sec_sig    = '0;

       //assign debug_req_i_sig = 1'b0;

       assign test_mode_tp_sig = test_normal;

       //assign clk_en_i_sig = test_normal;

	   assign clk_mem_i = clk_i & ~test_normal;

    // instantiate bist

    bist
    lbist
        (
          .clk                (clk_i),
          .resetn             (rst_ni),
          .test_normal        (test_normal),
		  .pi				  (debug_req_i),
          // .clk_en_i           (clk_en_i_sig),
          .scan_chain_output  (scan_chain_output_sig),
          .scan_chain_input   (scan_chain_input_sig),
          .test_en_i          (test_en_i_sig),
          // .test_mode_tp       (test_mode_tp_sig),
	      .muxed_pi           (debug_req_i_sig),
          .go_nogo            (go_nogo));


    // instantiate the core
    riscv_core_0_128_1_16_1_1_0_0_0_0_0_0_0_0_0_3_6_15_5_1a110800
    riscv_core_i
        (
         .clk_i                  ( clk_i                 ),
         .rst_ni                 ( rst_ni                ),

         .clock_en_i             ( '1                    ),
         .test_en_i              ( test_en_i_sig         ),                   
         .test_mode_tp           (test_mode_tp_sig       ),

         .test_si1                (scan_chain_input_sig[0]),
         .test_si2                (scan_chain_input_sig[1]),
         .test_si3                (scan_chain_input_sig[2]),
         .test_si4                (scan_chain_input_sig[3]),
         .test_si5                (scan_chain_input_sig[4]),
         .test_si6                (scan_chain_input_sig[5]),
         .test_si7                (scan_chain_input_sig[6]),
         .test_si8                (scan_chain_input_sig[7]),
         .test_si9                (scan_chain_input_sig[8]),
         .test_si10               (scan_chain_input_sig[9]),
         .test_si11               (scan_chain_input_sig[10]),
         .test_si12               (scan_chain_input_sig[11]),
         .test_si13               (scan_chain_input_sig[12]),
         .test_si14               (scan_chain_input_sig[13]),
         .test_si15               (scan_chain_input_sig[14]),
         .test_si16               (scan_chain_input_sig[15]),
         .test_si17               (scan_chain_input_sig[16]),
         .test_si18               (scan_chain_input_sig[17]),
         .test_si19               (scan_chain_input_sig[18]),
         .test_si20               (scan_chain_input_sig[19]),

         .test_so1                (scan_chain_output_sig[0]),
         .test_so2                (scan_chain_output_sig[1]),
         .test_so3                (scan_chain_output_sig[2]),
         .test_so4                (scan_chain_output_sig[3]),
         .test_so5                (scan_chain_output_sig[4]),
         .test_so6                (scan_chain_output_sig[5]),
         .test_so7                (scan_chain_output_sig[6]),
         .test_so8                (scan_chain_output_sig[7]),
         //.test_so9                (scan_chain_output_sig[8]),
         //.test_so10                (scan_chain_output_sig[9]),
         .test_so11               (scan_chain_output_sig[10]),
         .test_so12               (scan_chain_output_sig[11]),
         .test_so13               (scan_chain_output_sig[12]),
         .test_so14               (scan_chain_output_sig[13]),
         .test_so15               (scan_chain_output_sig[14]),
         .test_so16               (scan_chain_output_sig[15]),
         .test_so17               (scan_chain_output_sig[16]),
         .test_so18               (scan_chain_output_sig[17]),
         .test_so19               (scan_chain_output_sig[18]),
         .test_so20               (scan_chain_output_sig[19]),

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
         .apu_master_gnt_i       (                      ),
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

         .debug_req_i            ( debug_req_i_sig           ),

         .fetch_enable_i         ( fetch_enable_i        ),
         .core_busy_o            ( core_busy_o           ),

         .ext_perf_counters_i    (                       ),
         .fregfile_disable_i     ( 1'b0                  ));

    // this handles read to RAM and memory mapped pseudo peripherals

    mm_ram
        #(.RAM_ADDR_WIDTH (RAM_ADDR_WIDTH),
          .INSTR_RDATA_WIDTH (INSTR_RDATA_WIDTH))
    ram_i
        (.clk_i          ( clk_mem_i                          ),
         .rst_ni         ( rst_ni                         ),

         .instr_req_i    ( instr_req                      ),
         .instr_addr_i   ( instr_addr[RAM_ADDR_WIDTH-1:0] ),
         .instr_rdata_o  ( instr_rdata                    ),
         .instr_rvalid_o ( instr_rvalid                   ),
         .instr_gnt_o    ( instr_gnt                      ),

         .data_req_i     ( data_req                       ),
         .data_addr_i    ( data_addr                      ),
         .data_we_i      ( data_we                        ),
         .data_be_i      ( data_be                        ),
         .data_wdata_i   ( data_wdata                     ),
         .data_rdata_o   ( data_rdata                     ),
         .data_rvalid_o  ( data_rvalid                    ),
         .data_gnt_o     ( data_gnt                       ),

         .irq_id_i       ( irq_id_out                     ),
         .irq_ack_i      ( irq_ack                        ),
         .irq_id_o       ( irq_id_in                      ),
         .irq_o          ( irq                            ),

         .pc_core_id_i   ( riscv_core_i.pc_id             ),

         .tests_passed_o ( tests_passed_o                 ),
         .tests_failed_o ( tests_failed_o                 ),
         .exit_valid_o   ( exit_valid_o                   ),
         .exit_value_o   ( exit_value_o                   ));

//The scan chain insertion changes the scan data out to a already existing pin
         assign scan_chain_output_sig[8] = data_we;
         assign scan_chain_output_sig[9] = irq_id_out[4];

endmodule // riscv_wrapper
