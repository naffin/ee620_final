############################################################################
## Purpose: Makefile for Chap_6_Randomization/homework_solution
## Author: Chris Spear
##
## REVISION HISTORY:
## $Log: Makefile,v $
## Revision 1.1  2011/05/29 19:10:04  tumbush.tumbush
## Check into cloud repository
##
## Revision 1.2  2011/03/20 20:16:58  Greg
## Fixed path of Makefile
##
## Revision 1.1  2011/03/20 19:09:52  Greg
## Initial check in
##
############################################################################
TRANSACTION_FILES = opcode.sv transaction.sv
DRIVER_FILES = scoreboard.sv driver_cbs.sv driver_cbs_scb.sv driver.sv
ENV_FILES =  generator.sv environment.sv lc3_if.sv
SVM_FILES = svm_component.sv svm_component_wrapper.sv svm_factory.sv svm_component_reg.sv   
TEST_FILES = test_base.sv test.sv
VERILOG_FILES = ${TRANSACTION_FILES} ${DRIVER_FILES} ${ENV_FILES} ${SVM_FILES} ${TEST_FILES} top.sv	
TOPLEVEL = top

help:
	@echo "Make targets:"
	@echo "> make questa_gui   	# Compile and run with Questa in GUI mode"
	@echo "> make questa_batch 	# Compile and run with Questa in batch mode"
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
	vsim +TESTNAME=${TESTNAME} -novopt -classdebug -t ns -do "view wave;do wave.do;run -all" ${TOPLEVEL}

questa_batch: work
	vsim +TESTNAME=${TESTNAME} -c -novopt -t ns -do "run -all" ${TOPLEVEL}

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
