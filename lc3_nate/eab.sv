module eab(IR, Ra, PC, selEAB1, selEAB2, eabOut);
    input [10:0] IR;
    input [15:0] Ra;
    input [15:0] PC;
    input selEAB1;
    input [1:0] selEAB2;
    output [15:0] eabOut;
    
    logic [15:0] adder1, adder2, sext_10_to_0, sext_8_to_0, sext_5_to_0;
    
    assign sext_10_to_0 = {{5{IR[10]}}, IR[10:0]}; 
    assign sext_8_to_0 = {{7{IR[8]}}, IR[8:0]}; 
    assign sext_5_to_0 = {{10{IR[5]}}, IR[5:0]};

	always_comb begin
		case(selEAB2)
			2'b00 :  adder1 <= '0;
			2'b01 :  adder1 <= sext_5_to_0;
			2'b10 :  adder1 <= sext_8_to_0;
			2'b11 :  adder1 <= sext_10_to_0;
		endcase
	end	
	assign adder2 = (selEAB1 == 0)? PC:Ra;

	assign eabOut = adder1 + adder2;

endmodule
