module top;
	bit clk;
	always #10ns clk = ~clk;

	lc3_if lc3if (clk);
   	test tb();
   lc3 dut(lc3if);
endmodule
