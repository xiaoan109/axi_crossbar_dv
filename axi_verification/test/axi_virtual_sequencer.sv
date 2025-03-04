class axi_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(axi_virtual_sequencer)

  typedef uvm_sequencer#(axi_m_txn) axi_master_sequencer;

  axi_master_sequencer wr_sequencer[4];
  axi_master_sequencer rd_sequencer[4];

  function new(string name = "axi_virtual_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
