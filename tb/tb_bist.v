module tb_bist ();
	wire clk;
	wire rstn;
	wire test_normal;
	wire go_nogo;
	wire [31:0]pi;
	wire [31:0]po;
	wire [31:0]pi_gen;
	clk_gen CG(
		.clk(clk),
		.rstn(rstn));
	test_controller TC(
		.clk(clk),
		.rstn(rstn),
		.test_normal(test_normal),
		.go_nogo(go_nogo));
	bist BST(
		.clk(clk),
		.rstn(rstn),
		.test_normal(test_normal),
		.pi(pi);
		.po(po);
		.pi_gen(pi_gen);
		.go_nogo(go_nogo));
	/*
	riscv_core UUT(
		);
	*/
			

endmodule


