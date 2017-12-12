TRANSACTION_FILES = opcode.sv transaction.sv assert_macros.sv
COVERAGE_FILES = coverage_base.sv coverage.sv
DRIVER_FILES = checker.sv scoreboard.sv driver_cbs.sv driver_cbs_scb.sv driver.sv
ENV_FILES =  generator.sv environment.sv lc3_if.sv
SVM_FILES = svm_component.sv svm_component_wrapper.sv svm_factory.sv svm_component_reg.sv   
TEST_FILES = test_base.sv test_reset.sv test.sv
TAYLOR_FILES = ./lc3_taylor/datapath.sv ./lc3_taylor/controller.sv ./lc3_taylor/lc3.sv monitor_taylor.sv ./lc3_taylor/datapath_asserts.sv ./lc3_taylor/controller_asserts.sv ./lc3_taylor/bindfiles.sv
NATE_FILES = lc3_nate/lc3.sv monitor_nate.sv
DUT_FILES = ${NATE_FILES}
ifeq (${DUT},taylor)
	DUT_FILES = ${TAYLOR_FILES}
endif
VERILOG_FILES = ${TRANSACTION_FILES} ${COVERAGE_FILES} ${DUT_FILES} ${DRIVER_FILES} ${ENV_FILES} ${SVM_FILES} ${TEST_FILES} top.sv	
TOPLEVEL = top bindfiles
NUM_TRANS = 0
PLUS_ARGS = +TESTNAME=${TESTNAME} +NUM_TRANS=${NUM_TRANS}
QUESTA_OPTS = -novopt -t ns
GUI_OPTS = -classdebug -do "view wave;do wave.do;"
BATCH_OPTS = -c -do "coverage save -onexit ${TESTNAME}_${NUM_TRANS}.ucdb;run -all"


help:
	@echo "Make targets:"
	@echo "> make questa_gui TEST_NAME=\"<Test_name>\" [DUT=<name>] [NUM_TRANS=<value> unbounded if ommited]"
	@echo ""
	@echo "> make questa_batch TEST_NAME=\"<Test_name>\" [DUT=<name>] [NUM_TRANS=<value> unbounded if ommited]"
	@echo ""
	@echo "> make clean        	# Clean up all intermediate files"
	@echo "> make tar          	# Create a tar file for the current directory"
	@echo "> make help         	# This message"

#############################################################################
# VCS section
VCS_FLAGS = -sverilog -debug  -l comp.log
vcs:	simv
	./simv -l sim.log

simv:   ${VERILOG_FILES} clean
	mkdir work
	vhdlan ${VHDL_FILES}
	vlogan ${VCS_FLAGS} ${VERILOG_FILES}
	vcs ${TOPLEVEL}

#############################################################################
# Questa section
questa_gui: work
	vsim ${PLUS_ARGS} ${QUESTA_OPTS} ${GUI_OPTS} ${TOPLEVEL}

questa_batch: work
	vsim ${PLUS_ARGS} ${QUESTA_OPTS} ${BATCH_OPTS} ${TOPLEVEL}

work: ${VERILOG_FILES}
	vlib work
	vmap work work
	vlog ${VERILOG_FILES} 

#############################################################################
# Housekeeping

DIR = $(shell basename `pwd`)

tar:	clean
	cd ..; \
	tar cvf ${DIR}.tar ${DIR}

clean:
	@# VCS Stuff
	@rm -rf simv* csrc* *.log *.key vcdplus.vpd *.log .vcsmx_rebuild vc_hdrs.h .vlogan*
	@# Questa stuff
	@rm -rf work transcript vsim.wlf
	@# Unix stuff
	@rm -rf  *~ core.*
