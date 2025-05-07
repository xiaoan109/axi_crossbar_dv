package axi_env_pkg;

  import uvm_pkg::*;

  import axi_globals_pkg::*;
  import axi_stimulus_pkg::*;

  // `include "axi_master_agent_config.sv"
  // `include "axi_slave_agent_config.sv"
  // `include "axi_env_config.sv"

  `include "axi_master_driver.sv"
  `include "axi_master_monitor.sv"
  typedef uvm_sequencer#(axi_m_txn) axi_master_sequencer;
  `include "axi_master_coverage.sv"
  `include "axi_master_agent.sv"

  `include "axi_slave_driver.sv"
  `include "axi_slave_monitor.sv"
  typedef uvm_sequencer#(axi_s_txn) axi_slave_sequencer;
  `include "axi_slave_coverage.sv"
  `include "axi_slave_agent.sv"

  // `include "axi_ms_scoreboard.sv"
  `include "axi_scoreboard.sv"

  `include "axi_env.sv"
endpackage
