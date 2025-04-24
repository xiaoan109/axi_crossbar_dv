// base sanity test
class axi_base_test extends uvm_test;
  `uvm_component_utils(axi_base_test)

  // Components
  axi_env env;
  axi_virtual_sequencer v_sqr;

  function new(string name = "axi_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual task shutdown_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
endclass

function void axi_base_test::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Create components
  env   = axi_env::type_id::create("env", this);
  v_sqr = axi_virtual_sequencer::type_id::create("v_sqr", this);
  uvm_config_db#(uvm_object_wrapper)::set(this, "v_sqr.main_phase", "default_sequence",
                                          axi_base_vseq::type_id::get());
endfunction

function void axi_base_test::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  // Connect components
  foreach (v_sqr.m_wr_sequencer[i]) begin
    v_sqr.m_wr_sequencer[i] = env.master_agent[i].wr_sequencer;
  end
  foreach (v_sqr.m_rd_sequencer[i]) begin
    v_sqr.m_rd_sequencer[i] = env.master_agent[i].rd_sequencer;
  end
  foreach (v_sqr.s_wr_sequencer[i]) begin
    v_sqr.s_wr_sequencer[i] = env.slave_agent[i].wr_sequencer;
  end
  foreach (v_sqr.s_rd_sequencer[i]) begin
    v_sqr.s_rd_sequencer[i] = env.slave_agent[i].rd_sequencer;
  end
endfunction

function void axi_base_test::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);

  if (uvm_report_enabled(UVM_DEBUG, UVM_INFO, "TOPOLOGY")) begin
    uvm_root::get().print_topology();
  end

  if (uvm_report_enabled(UVM_DEBUG, UVM_INFO, "FACTORY")) begin
    uvm_factory::get().print();
  end

endfunction

task axi_base_test::main_phase(uvm_phase phase);
  uvm_objection objection;
  super.main_phase(phase);
  objection = phase.get_objection();
  objection.set_drain_time(this, 10us);
endtask

task axi_base_test::shutdown_phase(uvm_phase phase);
  super.shutdown_phase(phase);
  // phase.raise_objection(this);
  // env.scoreboard.wait_for_done();
  // phase.drop_objection(this);
endtask : shutdown_phase

function void axi_base_test::report_phase(uvm_phase phase);
  super.report_phase(phase);
  // `uvm_info("SB_REPORT", {"\n", env.scoreboard.convert2string()}, UVM_MEDIUM);
  // if (env.scoreboard.get_mismatches() == 0) begin
  //   `uvm_info("TEST_PASSED", "No mismatches", UVM_LOW)
  // end else begin
  //   `uvm_info("TEST_FAILED", $sformatf("mismatches: %d", env.scoreboard.get_mismatches()), UVM_LOW)
  // end
endfunction : report_phase

