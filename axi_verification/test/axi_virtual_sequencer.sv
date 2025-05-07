class axi_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(axi_virtual_sequencer)

  typedef uvm_sequencer#(axi_m_txn) axi_master_sequencer;
  typedef uvm_sequencer#(axi_s_txn) axi_slave_sequencer;

  axi_master_sequencer m_wr_sequencer[];
  axi_master_sequencer m_rd_sequencer[];
  axi_slave_sequencer  s_wr_sequencer[];
  axi_slave_sequencer  s_rd_sequencer[];

  axi_env_config env_cfg;

  function new(string name = "axi_virtual_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_wr_sequencer  = new[env_cfg.num_of_masters];
    m_rd_sequencer = new[env_cfg.num_of_masters];
    s_wr_sequencer = new[env_cfg.num_of_slaves];
    s_rd_sequencer = new[env_cfg.num_of_slaves];
  endfunction

endclass
