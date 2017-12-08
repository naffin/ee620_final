package Scoreboard_pkg;
	import Transaction_pkg::*;
class Scoreboard;

	function void check_control(input Transaction t);
	endfunction
	
	function void check_regFile(input Transaction t);
	endfunction

	function void check(input Transaction t);
		check_control(t);
		check_regFile(t);	
	endfunction
endclass // Scoreboard
endpackage
