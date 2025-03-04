// sequence lib
class axi_base_sequence extends uvm_sequence #(axi_m_txn);
  `uvm_object_utils(axi_base_sequence)
  int master_id = -1;
  static bit [3:0] id[4]; // only lower 4 bits are used

  function new(string name = "axi_base_sequence");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

endclass

// blocking write sequence
class axi_bk_wr_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_bk_wr_sequence)

  function new(string name = "axi_wr_sequence");
    super.new(name);
  endfunction

  extern virtual task pre_start();
  extern virtual task body();
endclass

task axi_bk_wr_sequence::pre_start();
  if (!uvm_config_db#(int)::get(get_sequencer().get_parent(), "", "master_id", master_id)) begin
    `uvm_fatal("CFGERR", {"Port ID must be set for: ", get_type_name()});
  end
endtask

task axi_bk_wr_sequence::body();
  `uvm_info("WR_SEQ", "Starting Blocking Write sequence", UVM_MEDIUM)
  `uvm_create(req);
  // TODO: unaligned address
  req.set_addr_align();
  start_item(req);
  // TODO: different burst types
  assert (req.randomize() with {
    awburst == INCR;
    awlen == 1;
    awsize == _4_BYTES;
    op_type == WRITE;
    transfer_type == BLOCKING_WRITE;
    // awaddr == 64;  //temp
    sa == master_id[1:0];  //temp
    // da == 1;  //temp
  });
  // TODO: masked id
  req.awid = {4'h1 << req.sa, id[master_id]};
  finish_item(req);
  id[master_id]++;
endtask

// blocking read sequence
class axi_bk_rd_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_bk_rd_sequence)

  function new(string name = "axi_rd_sequence");
    super.new(name);
  endfunction

  extern virtual task pre_start();
  extern virtual task body();
endclass

task axi_bk_rd_sequence::pre_start();
  // TODO: use config_db to set num_of_transfers from test
  if (!uvm_config_db#(int)::get(get_sequencer().get_parent(), "", "master_id", master_id)) begin
    `uvm_fatal("CFGERR", {"Port ID must be set for: ", get_type_name()});
  end
endtask

task axi_bk_rd_sequence::body();
  `uvm_info("RD_SEQ", "Starting Blocking Read sequence", UVM_MEDIUM)
  `uvm_create(req);
  // TODO: unaligned address
  req.set_addr_align();
  start_item(req);
  // TODO: different burst types
  assert (req.randomize() with {
    arburst == INCR;
    arlen == 1;
    arsize == _4_BYTES;
    op_type == READ;
    transfer_type == BLOCKING_READ;
    // araddr == 64;  //temp
    sa == master_id[1:0];  //temp
    // da == 1;  //temp
  });
  // TODO: masked id
  req.arid = {4'h1 << req.sa, id[master_id]};
  finish_item(req);
  id[master_id]++;
endtask

// non-blocking write sequence
class axi_nbk_wr_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_nbk_wr_sequence)

  function new(string name = "axi_nb_wr_sequence");
    super.new(name);
  endfunction

  extern virtual task pre_start();
  extern virtual task body();
endclass

task axi_nbk_wr_sequence::pre_start();
  if (!uvm_config_db#(int)::get(get_sequencer().get_parent(), "", "master_id", master_id)) begin
    `uvm_fatal("CFGERR", {"Port ID must be set for: ", get_type_name()});
  end
endtask

task axi_nbk_wr_sequence::body();
  `uvm_info("WR_SEQ", "Starting Non-Blocking Write sequence", UVM_MEDIUM)
  `uvm_create(req);
  req.set_addr_align();
  start_item(req);
  assert (req.randomize() with {
    awburst == INCR;
    awlen == 1;
    awsize == _4_BYTES;
    op_type == WRITE;
    transfer_type == NON_BLOCKING_WRITE;
    sa == master_id[1:0];  //temp
  });
  req.awid = {4'h1 << req.sa, id[master_id]};
  finish_item(req);
  id[master_id]++;
endtask

// non-blocking read sequence
class axi_nbk_rd_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_nbk_rd_sequence)

  function new(string name = "axi_nbk_rd_sequence");
    super.new(name);
  endfunction

  extern virtual task pre_start();
  extern virtual task body();
endclass

task axi_nbk_rd_sequence::pre_start();
  if (!uvm_config_db#(int)::get(get_sequencer().get_parent(), "", "master_id", master_id)) begin
    `uvm_fatal("CFGERR", {"Port ID must be set for: ", get_type_name()});
  end
endtask

task axi_nbk_rd_sequence::body();
  `uvm_info("RD_SEQ", "Starting Non-Blocking Read sequence", UVM_MEDIUM)
  `uvm_create(req);
  req.set_addr_align();
  start_item(req);
  assert (req.randomize() with {
    arburst == INCR;
    arlen == 1;
    arsize == _4_BYTES;
    op_type == READ;
    transfer_type == NON_BLOCKING_READ;
    sa == master_id[1:0];  //temp
  });
  req.arid = {4'h1 << req.sa, id[master_id]};
  finish_item(req);
  id[master_id]++;
endtask

// virtual sequence
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

class axi_bk_read_after_write_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_bk_read_after_write_vseq)

  extern function new(string name = "axi_bk_read_after_write_vseq");
  extern virtual task body();
endclass

// virtual sequence: blocking read after write
function axi_bk_read_after_write_vseq::new(string name = "axi_bk_read_after_write_vseq");
  super.new(name);
endfunction

task axi_bk_read_after_write_vseq::body();
  axi_bk_wr_sequence wr_seq[4];
  axi_bk_rd_sequence rd_seq[4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();
  for (int i = 0; i < 4; i++) begin
    fork
      automatic int j = i;
      `uvm_do_on(wr_seq[j], p_sequencer.wr_sequencer[j]);
    join_none
  end
  wait fork;
  #100ns;
  for (int i = 0; i < 4; i++) begin
    fork
      automatic int j = i;
      `uvm_do_on(rd_seq[j], p_sequencer.rd_sequencer[j]);
    join_none
  end
  wait fork;
  #100ns;
endtask

// virtual sequence: non-blocking read after write

class axi_nbk_read_after_write_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_nbk_read_after_write_vseq)

  extern function new(string name = "axi_nbk_read_after_write_vseq");
  extern virtual task body();
endclass

function axi_nbk_read_after_write_vseq::new(string name = "axi_nbk_read_after_write_vseq");
  super.new(name);
endfunction

task axi_nbk_read_after_write_vseq::body();
  axi_nbk_wr_sequence wr_seq[4];
  axi_nbk_rd_sequence rd_seq[4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();
  for (int i = 0; i < 4; i++) begin
    fork
      automatic int j = i;
      `uvm_do_on(wr_seq[j], p_sequencer.wr_sequencer[j]);
    join_none
  end
  wait fork;
  #100ns;
  for (int i = 0; i < 4; i++) begin
    fork
      automatic int j = i;
      `uvm_do_on(rd_seq[j], p_sequencer.rd_sequencer[j]);
    join_none
  end
  wait fork;
  #100ns;
endtask

// virtual sequence: blocking single master write
class axi_bk_single_master_write_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_bk_single_master_write_vseq)

  extern function new(string name = "axi_bk_single_master_write_vseq");
  extern virtual task body();
endclass

function axi_bk_single_master_write_vseq::new(string name = "axi_bk_single_master_write_vseq");
  super.new(name);
endfunction

task axi_bk_single_master_write_vseq::body();
  axi_bk_wr_sequence wr_seq;
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();
  for (int i = 0; i < 4; i++) begin
    repeat (4) begin
      `uvm_do_on(wr_seq, p_sequencer.wr_sequencer[i]);
    end
    #100ns;
  end
endtask

// virtual sequence: blocking single master read
class axi_bk_single_master_read_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_bk_single_master_read_vseq)

  extern function new(string name = "axi_bk_single_master_read_vseq");
  extern virtual task body();
endclass

function axi_bk_single_master_read_vseq::new(string name = "axi_bk_single_master_read_vseq");
  super.new(name);
endfunction

task axi_bk_single_master_read_vseq::body();
  axi_bk_rd_sequence rd_seq;
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();
  for (int i = 0; i < 4; i++) begin
    repeat (4) begin
      `uvm_do_on(rd_seq, p_sequencer.rd_sequencer[i]);
    end
    #100ns;
  end
endtask


// virtual sequence: non-blocking single master write
class axi_nbk_single_master_write_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_nbk_single_master_write_vseq)

  extern function new(string name = "axi_nbk_single_master_write_vseq");
  extern virtual task body();
endclass

function axi_nbk_single_master_write_vseq::new(string name = "axi_nbk_single_master_write_vseq");
  super.new(name);
endfunction

task axi_nbk_single_master_write_vseq::body();
  axi_nbk_wr_sequence wr_seq;
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();
  for (int i = 0; i < 4; i++) begin
    repeat (4) begin
      `uvm_do_on(wr_seq, p_sequencer.wr_sequencer[i]);
    end
    #100ns;
  end
endtask

// virtual sequence: non-blocking single master read
class axi_nbk_single_master_read_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_nbk_single_master_read_vseq)

  extern function new(string name = "axi_nbk_single_master_read_vseq");
  extern virtual task body();
endclass

function axi_nbk_single_master_read_vseq::new(string name = "axi_nbk_single_master_read_vseq");
  super.new(name);
endfunction

task axi_nbk_single_master_read_vseq::body();
  axi_nbk_rd_sequence rd_seq;
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();
  for (int i = 0; i < 4; i++) begin
    repeat (4) begin
      `uvm_do_on(rd_seq, p_sequencer.rd_sequencer[i]);
    end
    #100ns;
  end
endtask


