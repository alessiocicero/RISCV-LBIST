// Copyright 2017 Embecosm Limited <www.embecosm.com>
// Copyright 2018 Robert Balas <balasr@student.ethz.ch>
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Top level wrapper for a RI5CY testbench
// Contributor: Robert Balas <balasr@student.ethz.ch>
//              Jeremy Bennett <jeremy.bennett@embecosm.com>

module tb_top
    #(parameter INSTR_RDATA_WIDTH = 128,
      parameter RAM_ADDR_WIDTH = 22,
      parameter BOOT_ADDR  = 'h80);

    // comment to record execution trace
    `define TRACE_EXECUTION

    const time CLK_PHASE_HI       = 5ns;
    const time CLK_PHASE_LO       = 5ns;
    const time CLK_PERIOD         = CLK_PHASE_HI + CLK_PHASE_LO;
    const time STIM_APPLICATION_DEL = CLK_PERIOD * 0.1;
    const time RESP_ACQUISITION_DEL = CLK_PERIOD * 0.9;
    const time RESET_DEL = STIM_APPLICATION_DEL;
    const int  RESET_WAIT_CYCLES  = 4;


    // clock and reset for tb
    logic                   clk   = 'b1;
    logic                   rst_n = 'b0;

    // cycle counter
    int unsigned            cycle_cnt_q;

    // testbench result
    logic                   tests_passed;
    logic                   tests_failed;
    logic                   exit_valid;
    logic [31:0]            exit_value;

    // signals for ri5cy
    logic                   fetch_enable;

    // signals for bist
    logic                   test_normal_sig;
    logic                   go_nogo_sig;
    logic                   reset_state = '0;
    logic                   wait_state = '0;
    logic                   running_state = '0;
    logic                   evaluate_state = '0;
    logic                   bist_result = '0;

    // make the core start fetching instruction immediately
    assign fetch_enable = '1;

    // allow vcd dump
    initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("riscy_tb.vcd");
            $dumpvars(0, tb_top);
        end
    end

    // we either load the provided firmware or execute a small test program that
    // doesn't do more than an infinite loop with some I/O
    initial begin: load_prog
        automatic string firmware;
        automatic int prog_size = 6;

        if($value$plusargs("firmware=%s", firmware)) begin
            if($test$plusargs("verbose"))
                $display("[TESTBENCH] %t: loading firmware %0s ...",
                         $time, firmware);
            $readmemh(firmware, riscv_wrapper_gate.ram_i.dp_ram_i.mem);

        end else begin
            $display("No firmware specified");
            $finish;
        end
    end

    // clock generation
    initial begin: clock_gen
        forever begin
            #CLK_PHASE_HI clk = 1'b0;
            #CLK_PHASE_LO clk = 1'b1;
        end
    end: clock_gen

    // reset generation
    initial begin: reset_gen
        rst_n          = 1'b0;

        // wait a few cycles
        repeat (RESET_WAIT_CYCLES) begin
            @(posedge clk); //TODO: was posedge, see below
        end

        // start running
        #RESET_DEL rst_n = 1'b1;
        if($test$plusargs("verbose"))
            $display("reset deasserted", $time);

    end: reset_gen

    // set timing format
    initial begin: timing_format
        $timeformat(-9, 0, "ns", 9);
    end: timing_format

    // abort after n cycles, if we want to
    always_ff @(posedge clk, negedge rst_n) begin
        automatic int maxcycles;
        if($value$plusargs("maxcycles=%d", maxcycles)) begin
            if (~rst_n) begin
                cycle_cnt_q <= 0;
            end else begin
                cycle_cnt_q     <= cycle_cnt_q + 1;
                if (cycle_cnt_q >= maxcycles) begin
                    $fatal(2, "Simulation aborted due to maximum cycle limit");
                end
            end
        end
    end

    // check if we succeded
   always_ff @(posedge clk, negedge rst_n) begin
        if (tests_passed) begin
            $display("ALL TESTS PASSED");
            $finish;
        end
        if (tests_failed) begin
            $display("TEST(S) FAILED!");
            $finish;
        end
        if (exit_valid) begin
            if (exit_value == 0)
                $display("EXIT SUCCESS");
            else
                $display("EXIT FAILURE: %d", exit_value);
            $finish;
        end
    end


//Controller of our BIST test
   always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            test_normal_sig <= '0;
            reset_state <= '1;
            wait_state <= '0;
            running_state <= '0;
            evaluate_state <= '0;
        end else begin
            if(reset_state) begin
                reset_state <='0;
                wait_state <='1;
                test_normal_sig <='1;
            end
            if (wait_state) begin
                if(go_nogo_sig == '1) begin
                    $display("test started");
                    wait_state <='0;
                    running_state <= '1;
                end
            end
            if (running_state) begin
               if(go_nogo_sig == '1) begin
                    $display("test finished");
                    running_state <='0;
                    evaluate_state <= '1;
                end
            end
            if (evaluate_state) begin
                evaluate_state <='0;
                test_normal_sig <='0;
               if(go_nogo_sig == '1) begin
                    $display("LBIST result OK");
                    bist_result <= '1;
                    
                end else begin
                    $display("LBIST result NOT OK");
                    bist_result <='0;
                    $finish;
                end
            end
        end
    end
    //PoliTo: Memory map check
    always_ff @(posedge clk, negedge rst_n) begin
	   if (tb_top.riscv_wrapper_i.riscv_core_i.load_store_unit_i.data_we_ex_i == 1'h1) begin
	       if (tb_top.riscv_wrapper_i.data_req == 1'h1 && tb_top.riscv_wrapper_i.data_we == 1'h1) begin
	           if (tb_top.riscv_wrapper_i.riscv_core_i.load_store_unit_i.data_addr_o < 32'h200000 || tb_top.riscv_wrapper_i.riscv_core_i.load_store_unit_i.data_addr_o > 32'h240000) begin
		          $display("MEMORY MAP WARNING: Writing OUTSIDE DRAM at address %h, time %t", tb_top.riscv_wrapper_i.riscv_core_i.load_store_unit_i.data_addr_o, $realtime); 
        	end 
	   end
    end

    // wrapper for riscv, the memory system and stdout peripheral
    riscv_wrapper
        #(.INSTR_RDATA_WIDTH (INSTR_RDATA_WIDTH),
          .RAM_ADDR_WIDTH (RAM_ADDR_WIDTH),
          .BOOT_ADDR (BOOT_ADDR),
          .PULP_SECURE (1))

    riscv_wrapper_gate
        (.clk_i          ( clk          ),
         .rst_ni         ( rst_n        ),
         .fetch_enable_i ( fetch_enable ),
         .tests_passed_o ( tests_passed ),
         .tests_failed_o ( tests_failed ),
         .exit_valid_o   ( exit_valid   ),
         .exit_value_o   ( exit_value   ),
         .test_normal    ( test_normal_sig ),
         .go_nogo        ( go_nogo_sig));

`ifndef VERILATOR
    initial begin
        assert (INSTR_RDATA_WIDTH == 128 || INSTR_RDATA_WIDTH == 32)
            else $fatal("invalid INSTR_RDATA_WIDTH, choose 32 or 128");
    end
`endif

endmodule // tb_top
