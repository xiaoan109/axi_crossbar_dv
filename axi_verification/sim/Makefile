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
testlist_name=$(REPO_ROOT)/testlists/testlist.f
# Setting the default test folder to test name 
ifndef test_folder
override test_folder = $(test)
endif

.IGNORE:
	compile
	compile_cov
	run
	run_cov
# WE can also use the target where we WANT the silent mode 
.SILENT:
	compile
	compile_cov
	run
	run_cov
	help

help:
	echo "[filelist]: create filelist.f"
	echo "[work]: create work lib"
	echo "[compile]: compile verilog & system verilog files in FILELIST"
	echo "[run]: start simulation in questasim batch mode"
	echo "[rung]: start simulation in questasim gui mode"

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
	vlog  +incdir+$(UVM_HOME)/src \
		$(UVM_HOME)/src/uvm_pkg.sv \
		-f $(FILELIST) $(INCLUDE_PATH) \
		-l comp.log
	make compile_war_err

compile_cov: filelist
	vlog  +incdir+$(UVM_HOME)/src \
		$(UVM_HOME)/src/uvm_pkg.sv \
		-f $(FILELIST) $(INCLUDE_PATH) \
		-l comp.log \
		+acc \
		+cover \
		+fcover	
	make compile_war_err

run:
	mkdir $(test_folder)
	vsim -voptargs=+acc=npr $(SUPPRESS_MULTI_DRIVEN) \
		-sv_seed $(SEED) -c \
		-classdebug -sv_lib $(UVM_DPI_HOME)/uvm_dpi \
		work.$(TOP) -do "log -r /*; add wave -r /*; run -all; exit" \
		-l  $(test_folder)/$(test).log \
		+UVM_VERBOSITY=$(verbosity) \
		+UVM_TESTNAME=$(test) \
		+$(plus) \
		-wlf $(test_folder)/waveform.wlf
	# For checking and reporting compilation errors	
	make simulate_war_err

rung:
	mkdir $(test_folder)
	vsim -voptargs=+acc=npr $(SUPPRESS_MULTI_DRIVEN) \
		-sv_seed $(SEED) -classdebug \
		-sv_lib $(UVM_DPI_HOME)/uvm_dpi \
		work.$(TOP) -do "do wave.do" \
		-l  $(test_folder)/$(test).log \
		+UVM_VERBOSITY=$(verbosity) \
		+UVM_TESTNAME=$(test) \
		+$(plus) 

run_cov:
	mkdir $(test_folder)
	vsim -voptargs=+acc=npr $(SUPPRESS_MULTI_DRIVEN) \
		-sv_seed $(SEED) -c \
		-assertdebug \
		-classdebug -sv_lib $(UVM_DPI_HOME)/uvm_dpi \
		work.$(TOP) -do "log -r /*; add wave -r /*; coverage save -onexit -assert -directive -cvg -codeAll $(test_folder)/$(test)_coverage.ucdb; run -all; exit" \
		-l  $(test_folder)/$(test).log \
		+UVM_VERBOSITY=$(verbosity) \
		+UVM_TESTNAME=$(test) \
		+$(plus) \
		-sva \
		-coverage \
		-wlf $(test_folder)/waveform.wlf
	# For checking and reporting simulation errors
	make simulate_war_err
	# For coverage report in HTML format 
	vcover report -html $(test_folder)/$(test)_coverage.ucdb -output $(test_folder)/html_cov_report -details

regression:
	python regression_handling.py $(testlist_name)
	make merge_cov_report


view_wave:
	vsim -view $(test_folder)/waveform.wlf -do wave.do &

view_cov:
	vsim -viewcov $(test_folder)/$(test)_coverage.ucdb &

merge_cov_report:
	mkdir merged
	vcover merge merged/merged_coverage.ucdb -64 */*.ucdb
	vcover report -html merged/merged_coverage.ucdb -output merged/merged_cov_html_report -details

view_cov_merged:
	vsim -viewcov merged/merged_coverage.ucdb &



compile_war_err:
	echo "";
	echo "-----------------------------------------------------------------";
	echo "------------------- Compilation Report --------------------------";
	echo "";
	grep "^** " comp.log;
	echo "";
	grep "^Error" comp.log;
	echo "";
	echo "Log file path: comp.log"
	echo "";
	echo "-----------------------------------------------------------------";
	echo "-----------------------------------------------------------------";
	echo "";

simulate_war_err:
	echo "";
	echo "-----------------------------------------------------------------";
	echo "-------------------- Simulation Report --------------------------";
	echo "";
	echo "Simulator Errors";
	grep "Error" $(test_folder)/$(test).log;
	echo "";
	echo "UVM Fatal";
	grep "UVM_FATAL" $(test_folder)/$(test).log;
	echo "";
	echo "UVM Errors";
	grep "UVM_ERROR" $(test_folder)/$(test).log;
	echo "";
	echo "UVM Warnings";
	grep "UVM_WARNING" $(test_folder)/$(test).log;
	echo "";
	echo "Testname: $(test)"
	echo "";
	echo "Log file path: $(test_folder)/$(test).log"
	echo "";
	echo "Waveform: vsim -view $(test_folder)/waveform.wlf &"
	echo "";
	echo "Coverage report: firefox $(test_folder)/html_cov_report/index.html &"
	echo "";
	echo "-----------------------------------------------------------------";
	echo "-----------------------------------------------------------------";
	echo "";

clean:
	rm -rf work *.log transcript $(FILELIST) *.wlf
	rm -rf *_test* merged

.PHONY: filelist work compile compile_cov run rung run_cov clean
