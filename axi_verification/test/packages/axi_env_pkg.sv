package axi_env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import axi_globals_pkg::*;
  import axi_stimulus_pkg::*;


  `include "axi_master_driver.sv"
  `include "axi_master_monitor.sv"
  typedef uvm_sequencer#(axi_m_txn) axi_master_sequencer;
  `include "axi_master_agent.sv"
  
  `include "axi_slave_driver.sv"
  `include "axi_slave_monitor.sv"
  typedef uvm_sequencer#(axi_s_txn) axi_slave_sequencer;
  `include "axi_slave_agent.sv"

  // `include "axi_ms_scoreboard.sv"
  `include "axi4_scoreboard.sv"

  `include "axi_env.sv"
endpackage
