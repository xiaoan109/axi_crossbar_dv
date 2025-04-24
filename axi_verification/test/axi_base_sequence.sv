//  ===========================
//  |  M   A   S   T   E   R  |
//  ===========================

//  master base sequence
class axi_master_base_sequence extends uvm_sequence #(axi_m_txn);
  `uvm_object_utils(axi_master_base_sequence)
  int master_id = -1;
  static bit [3:0] wr_id[4];  // only lower 4 bits are used
  static bit [3:0] rd_id[4];  // only lower 4 bits are used
  rand int dest = -1;

  function new(string name = "axi_master_base_sequence");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  task body();
    req = axi_m_txn::type_id::create("req");
  endtask

endclass

//  ========================
//  |  S   L   A   V   E   |
//  ========================

// slave base sequence
class axi_slave_base_sequence extends uvm_sequence #(axi_s_txn);
  `uvm_object_utils(axi_slave_base_sequence)
  int slave_id = -1;

  function new(string name = "axi_base_sequence");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  task body();
    req = axi_s_txn::type_id::create("req");
  endtask

endclass

//  ==================================================================
//  |  V   I   R   T   U   A   L  --  S   E   Q   U   E   N   C   E  |
//  ==================================================================

// virtual sequence: base virutal sequence
class axi_base_vseq extends uvm_sequence;
  `uvm_object_utils(axi_base_vseq)
  `uvm_declare_p_sequencer(axi_virtual_sequencer)
  uvm_event reset_event = uvm_event_pool::get_global("reset");

  extern function new(string name = "axi_base_vseq");
  extern virtual task body();
endclass

function axi_base_vseq::new(string name = "axi_base_vseq");
  super.new(name);
  set_automatic_phase_objection(1);
endfunction

task axi_base_vseq::body();
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();
  `uvm_info("VSEQ", "Base virtual sequence end", UVM_MEDIUM)
endtask
