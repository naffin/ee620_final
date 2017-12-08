package svm_component_wrapper_pkg;
	import svm_component_pkg::*;
virtual class svm_component_wrapper;
	pure virtual function string get_type_name();
	pure virtual function svm_component create_object(string name);
endclass

endpackage
