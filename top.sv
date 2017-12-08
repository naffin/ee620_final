module top;
	bit clk;
	always #10ns clk = ~clk;

	lc3_if lc3if (clk);
   	test tb();
endmodule
