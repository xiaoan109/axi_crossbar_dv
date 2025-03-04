UVM_HOME=D:/Tools/questasim64_2021.1/verilog_src/uvm-1.2
UVM_DPI_HOME=D:/Tools/questasim64_2021.1/uvm-1.2/win64
verbosity=UVM_MEDIUM
test=axi_base_test
plus=
FILELIST=filelist.f
TOP=tb_top
REPO_ROOT=..
RTL_PATH=$(REPO_ROOT)/src
TEST_PATH=$(REPO_ROOT)/test
PACKAGE_PATH=$(TEST_PATH)/packages
INCLUDE_PATH=+incdir+$(TEST_PATH)
WAVE_DO_FILE=wave.do
SUPPRESS_MULTI_DRIVEN=-suppress 3839
SEED=random

help:
	@echo "[filelist]: create filelist.f"
	@echo "[work]: create work lib"
	@echo "[compile]: compile verilog & system verilog files in FILELIST"
	@echo "[run]: start simulation in questasim batch mode"
	@echo "[rung]: start simulation in questasim gui mode"

all: filelist work compile run

filelist:
	rm $(FILELIST) -rf
	find $(RTL_PATH) -name "*.sv" >> $(REPO_ROOT)/sim/filelist.f
	find $(PACKAGE_PATH) -name "*globals_pkg.sv" >> $(REPO_ROOT)/sim/filelist.f
	find $(PACKAGE_PATH) -name "*stimulus_pkg.sv" >> $(REPO_ROOT)/sim/filelist.f
	find $(PACKAGE_PATH) -name "*env_pkg.sv" >> $(REPO_ROOT)/sim/filelist.f
	find $(PACKAGE_PATH) -name "*test_pkg.sv" >> $(REPO_ROOT)/sim/filelist.f
	find $(TEST_PATH) -name "tb_top.sv" >> $(REPO_ROOT)/sim/filelist.f

work:
	vlib work

compile: filelist
	vlog  +incdir+${UVM_HOME}/src ${UVM_HOME}/src/uvm_pkg.sv -f $(FILELIST) $(INCLUDE_PATH) -l comp.log

run:
	vsim -voptargs="+acc" $(SUPPRESS_MULTI_DRIVEN) -sv_seed $(SEED) -c -classdebug -sv_lib ${UVM_DPI_HOME}/uvm_dpi work.$(TOP) -do "run -all; quit" -l sim.log +UVM_VERBOSITY=$(verbosity) +UVM_TESTNAME=$(test) +$(plus)

rung:
	vsim -voptargs="+acc" $(SUPPRESS_MULTI_DRIVEN) -sv_seed $(SEED) -classdebug -sv_lib ${UVM_DPI_HOME}/uvm_dpi work.$(TOP) -do "do wave.do" -l sim.log +UVM_VERBOSITY=$(verbosity) +UVM_TESTNAME=$(test) +$(plus) 

clean:
	rm -rf work *.log transcript $(FILELIST) *.wlf

.PHONY: filelist work compile run rung clean
