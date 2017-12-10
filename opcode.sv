package Opcode_pkg;
	typedef enum bit [3:0] {
		ADD	= 4'b0001,
		AND	= 4'b0101,
		NOT	= 4'b1001,
		BR 	= 4'b0000,
		JMP	= 4'b1100,
		JSR	= 4'b0100,
		LD	= 4'b0010,
		LDI	= 4'b1010,
		LDR	= 4'b0110,
		LEA	= 4'b1110,
		ST	= 4'b0011,
		STI	= 4'b1011,
		STR	= 4'b0111,
		TRAP= 4'b1111,
		RTI	= 4'b1000,
		RESERVED = 4'b1101
	} Opcode;
endpackage
