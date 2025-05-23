package axi_stimulus_pkg;

  import uvm_pkg::*;

  import axi_globals_pkg::*;

  `include "axi_mst_txn.sv"
  `include "axi_slv_txn.sv"

  typedef virtual axi_if #(AXI_DATA_W, AXI_ADDR_W, AXI_ID_W, AXI_USER_W) axi_vif;
  typedef axi_mst_txn#(AXI_DATA_W, AXI_ADDR_W, AXI_ID_W, AXI_USER_W) axi_m_txn;
  typedef axi_slv_txn#(AXI_DATA_W, AXI_ADDR_W, AXI_ID_W, AXI_USER_W) axi_s_txn;

  `include "axi_master_agent_config.sv"
  `include "axi_slave_agent_config.sv"
  `include "axi_env_config.sv"
  `include "axi_virtual_sequencer.sv"
  `include "axi_base_sequence.sv"
  `include "axi_seq_lib.sv"

endpackage
