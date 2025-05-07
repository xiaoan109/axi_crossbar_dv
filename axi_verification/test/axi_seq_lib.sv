// ***********************************************************************
// *****************
// ***** ***********
// *****   *********       Copyright (c) 2025  NB
// *****     *******               (BJ     group)
// *****       *****         XXXXX           Confidential
// *****     *******             All rights reserved
// *****   *********
// ***** ***********
// *****************
// ***********************************************************************
// PROJECT        :
// FILENAME       : axi_seq_lib.sv
// Author         : EDA [xxxx.com]
// Created        : 2025-04-24 12:56
// LAST MODIFIED  : 2025-04-24 13:25
// ***********************************************************************
// DESCRIPTION    :
// ***********************************************************************
// $Revision: $
// $Id: $
// ***********************************************************************
// sequence lib
//  ===========================
//  |  M   A   S   T   E   R  |
//  ===========================
// blocking 32b incr burst write sequence
class axi_master_bk_32b_incr_wr_sequence extends axi_master_base_sequence;
  `uvm_object_utils(axi_master_bk_32b_incr_wr_sequence)

  function new(string name = "axi_master_bk_32b_incr_wr_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_master_bk_32b_incr_wr_sequence::body();
  `uvm_info("WR_SEQ", "Starting Blocking 32b INCR Write sequence", UVM_MEDIUM)
  super.body();
  // TODO: unaligned address
  req.set_addr_align();
  start_item(req);
  // TODO: different burst types
  assert (req.randomize() with {
        awburst == INCR;
        awsize == _4_BYTES;
        op_type == WRITE;
        transfer_type == BLOCKING_WRITE;
        awuser == BLOCKING_WRITE; // user signal to indicate transfer type for monitor
        sa == master_id[1:0];
        if (dest != -1) da == dest[1:0];
      });
  req.awid = {4'h1 << req.sa, wr_id[master_id]};
  finish_item(req);
  wr_id[master_id]++;
endtask

// blocking 32b incr burst read sequence
class axi_master_bk_32b_incr_rd_sequence extends axi_master_base_sequence;
  `uvm_object_utils(axi_master_bk_32b_incr_rd_sequence)

  function new(string name = "axi_master_bk_32b_incr_rd_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass

task axi_master_bk_32b_incr_rd_sequence::body();
  `uvm_info("RD_SEQ", "Starting Blocking Read sequence", UVM_MEDIUM)
  super.body();
  // TODO: unaligned address
  req.set_addr_align();
  start_item(req);
  assert (req.randomize() with {
        arburst == INCR;
        arsize == _4_BYTES;
        op_type == READ;
        transfer_type == BLOCKING_READ;
        aruser == BLOCKING_READ;
        sa == master_id[1:0];
        if (dest != -1) da == dest[1:0];
      });
  req.arid = {4'h1 << req.sa, rd_id[master_id]};
  finish_item(req);
  rd_id[master_id]++;
endtask

// non-blocking 32b incr burst write sequence
class axi_master_nbk_32b_incr_wr_sequence extends axi_master_base_sequence;
  `uvm_object_utils(axi_master_nbk_32b_incr_wr_sequence)

  function new(string name = "axi_master_nbk_32b_incr_wr_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_master_nbk_32b_incr_wr_sequence::body();
  `uvm_info("WR_SEQ", "Starting Non-Blocking Write sequence", UVM_MEDIUM)
  super.body();
  req.set_addr_align();
  start_item(req);
  assert (req.randomize() with {
        awburst == INCR;
        awsize == _4_BYTES;
        op_type == WRITE;
        transfer_type == NON_BLOCKING_WRITE;
        awuser == NON_BLOCKING_WRITE;
        sa == master_id[1:0];
        if (dest != -1) da == dest[1:0];
      });
  req.awid = {4'h1 << req.sa, wr_id[master_id]};
  finish_item(req);
  wr_id[master_id]++;
endtask

// non-blocking 32b incr burst read sequence
class axi_master_nbk_32b_incr_rd_sequence extends axi_master_base_sequence;
  `uvm_object_utils(axi_master_nbk_32b_incr_rd_sequence)

  function new(string name = "axi_master_nbk_32b_incr_rd_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_master_nbk_32b_incr_rd_sequence::body();
  `uvm_info("RD_SEQ", "Starting Non-Blocking Read sequence", UVM_MEDIUM)
  super.body();
  req.set_addr_align();
  start_item(req);
  assert (req.randomize() with {
        arburst == INCR;
        arsize == _4_BYTES;
        op_type == READ;
        transfer_type == NON_BLOCKING_READ;
        aruser == NON_BLOCKING_READ;
        sa == master_id[1:0];
        if (dest != -1) da == dest[1:0];
      });
  if (dest != -1) begin
    req.da = dest[1:0];
  end
  req.arid = {4'h1 << req.sa, rd_id[master_id]};
  finish_item(req);
  rd_id[master_id]++;
endtask

// narrow transfer
// blocking 8b incr burst write sequence
class axi_master_bk_8b_incr_wr_sequence extends axi_master_base_sequence;
  `uvm_object_utils(axi_master_bk_8b_incr_wr_sequence)

  function new(string name = "axi_master_bk_8b_incr_wr_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_master_bk_8b_incr_wr_sequence::body();
  `uvm_info("WR_SEQ", "Starting Non-Blocking Write sequence", UVM_MEDIUM)
  super.body();
  req.set_addr_align();
  start_item(req);
  assert (req.randomize() with {
        awburst == INCR;
        awsize == _1_BYTE;
        op_type == WRITE;
        transfer_type == BLOCKING_WRITE;
        awuser == BLOCKING_WRITE;
        sa == master_id[1:0];
        if (dest != -1) da == dest[1:0];
      });
  req.awid = {4'h1 << req.sa, wr_id[master_id]};
  finish_item(req);
  wr_id[master_id]++;
endtask

// blocking 8b incr burst read sequence
class axi_master_bk_8b_incr_rd_sequence extends axi_master_base_sequence;
  `uvm_object_utils(axi_master_bk_8b_incr_rd_sequence)

  function new(string name = "axi_master_bk_8b_incr_rd_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_master_bk_8b_incr_rd_sequence::body();
  `uvm_info("RD_SEQ", "Starting Non-Blocking Read sequence", UVM_MEDIUM)
  super.body();
  req.set_addr_align();
  start_item(req);
  assert (req.randomize() with {
        arburst == INCR;
        arsize == _1_BYTE;
        op_type == READ;
        transfer_type == BLOCKING_READ;
        aruser == BLOCKING_READ;
        sa == master_id[1:0];
        if (dest != -1) da == dest[1:0];
      });
  req.arid = {4'h1 << req.sa, rd_id[master_id]};
  finish_item(req);
  rd_id[master_id]++;
endtask

// blocking 16b incr burst write sequence
class axi_master_bk_16b_incr_wr_sequence extends axi_master_base_sequence;
  `uvm_object_utils(axi_master_bk_16b_incr_wr_sequence)

  function new(string name = "axi_master_bk_16b_incr_wr_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_master_bk_16b_incr_wr_sequence::body();
  `uvm_info("WR_SEQ", "Starting Non-Blocking Write sequence", UVM_MEDIUM)
  super.body();
  req.set_addr_align();
  start_item(req);
  assert (req.randomize() with {
        awburst == INCR;
        awsize == _2_BYTES;
        op_type == WRITE;
        transfer_type == BLOCKING_WRITE;
        awuser == BLOCKING_WRITE;
        sa == master_id[1:0];
        if (dest != -1) da == dest[1:0];
      });
  req.awid = {4'h1 << req.sa, wr_id[master_id]};
  finish_item(req);
  wr_id[master_id]++;
endtask

// blocking 16b incr burst read sequence
class axi_master_bk_16b_incr_rd_sequence extends axi_master_base_sequence;
  `uvm_object_utils(axi_master_bk_16b_incr_rd_sequence)

  function new(string name = "axi_master_bk_16b_incr_rd_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_master_bk_16b_incr_rd_sequence::body();
  `uvm_info("RD_SEQ", "Starting Non-Blocking Read sequence", UVM_MEDIUM)
  super.body();
  req.set_addr_align();
  start_item(req);
  assert (req.randomize() with {
        arburst == INCR;
        arsize == _2_BYTES;
        op_type == READ;
        transfer_type == BLOCKING_READ;
        aruser == BLOCKING_READ;
        sa == master_id[1:0];
        if (dest != -1) da == dest[1:0];
      });
  req.arid = {4'h1 << req.sa, rd_id[master_id]};
  finish_item(req);
  rd_id[master_id]++;
endtask

//  ========================
//  |  S   L   A   V   E   |
//  ========================
// blocking write sequence
class axi_slave_bk_wr_sequence extends axi_slave_base_sequence;
  `uvm_object_utils(axi_slave_bk_wr_sequence)

  function new(string name = "axi_wr_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_slave_bk_wr_sequence::body();
  `uvm_info("WR_SEQ", "Starting Blocking Write sequence", UVM_MEDIUM)
  super.body();
  start_item(req);
  assert (req.randomize());
  finish_item(req);
endtask

// blocking read sequence
class axi_slave_bk_rd_sequence extends axi_slave_base_sequence;
  `uvm_object_utils(axi_slave_bk_rd_sequence)

  function new(string name = "axi_rd_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_slave_bk_rd_sequence::body();
  `uvm_info("RD_SEQ", "Starting Blocking Read sequence", UVM_MEDIUM)
  super.body();
  start_item(req);
  assert (req.randomize());
  finish_item(req);
endtask

// non-blocking write sequence
class axi_slave_nbk_wr_sequence extends axi_slave_base_sequence;
  `uvm_object_utils(axi_slave_nbk_wr_sequence)

  function new(string name = "axi_nb_wr_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_slave_nbk_wr_sequence::body();
  `uvm_info("WR_SEQ", "Starting Non-Blocking Write sequence", UVM_MEDIUM)
  super.body();
  start_item(req);
  assert (req.randomize());
  finish_item(req);
endtask

// non-blocking read sequence
class axi_slave_nbk_rd_sequence extends axi_slave_base_sequence;
  `uvm_object_utils(axi_slave_nbk_rd_sequence)

  function new(string name = "axi_nbk_rd_sequence");
    super.new(name);
  endfunction

  extern virtual task body();
endclass


task axi_slave_nbk_rd_sequence::body();
  `uvm_info("RD_SEQ", "Starting Non-Blocking Read sequence", UVM_MEDIUM)
  super.body();
  start_item(req);
  assert (req.randomize());
  finish_item(req);
endtask




//  ==================================================================
//  |  V   I   R   T   U   A   L  --  S   E   Q   U   E   N   C   E  |
//  ==================================================================
// virtual sequence: blocking 32b incr burst write and read
class axi_bk_32b_incr_write_read_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_bk_32b_incr_write_read_vseq)

  extern function new(string name = "axi_bk_32b_incr_write_read_vseq");
  extern virtual task body();
endclass

function axi_bk_32b_incr_write_read_vseq::new(string name = "axi_bk_32b_incr_write_read_vseq");
  super.new(name);
endfunction

task axi_bk_32b_incr_write_read_vseq::body();
  axi_master_bk_32b_incr_wr_sequence m_wr_seq[4];
  axi_master_bk_32b_incr_rd_sequence m_rd_seq[4];
  axi_slave_bk_wr_sequence  s_wr_seq[4];
  axi_slave_bk_rd_sequence  s_rd_seq[4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();


  fork
    begin : T1_SL_WR
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_wr_seq[j], p_sequencer.s_wr_sequencer[j])
          end
        join_none
      end
    end
    begin : T2_SL_RD
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_rd_seq[j], p_sequencer.s_rd_sequencer[j])
          end
        join_none
      end
    end
  join_none



  fork
    begin : T1_WRITE
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          repeat (2) begin
            `uvm_do_on(m_wr_seq[j], p_sequencer.m_wr_sequencer[j])
          end
        join_none
      end
    end
    begin : T2_READ
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          repeat (3) begin
            `uvm_do_on(m_rd_seq[j], p_sequencer.m_rd_sequencer[j])
          end
        join_none
      end
    end
  join

endtask

// virtual sequence: non-blocking 32b incr burst write and read
class axi_nbk_32b_incr_write_read_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_nbk_32b_incr_write_read_vseq)

  extern function new(string name = "axi_nbk_32b_incr_write_read_vseq");
  extern virtual task body();
endclass

function axi_nbk_32b_incr_write_read_vseq::new(string name = "axi_nbk_32b_incr_write_read_vseq");
  super.new(name);
endfunction

task axi_nbk_32b_incr_write_read_vseq::body();
  axi_master_nbk_32b_incr_wr_sequence m_wr_seq[4];
  axi_master_nbk_32b_incr_rd_sequence m_rd_seq[4];
  axi_slave_nbk_wr_sequence  s_wr_seq[4];
  axi_slave_nbk_rd_sequence  s_rd_seq[4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();

  fork
    begin : T1_SL_WR
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_wr_seq[j], p_sequencer.s_wr_sequencer[j])
          end
        join_none
      end
    end
    begin : T2_SL_RD
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_rd_seq[j], p_sequencer.s_rd_sequencer[j])
          end
        join_none
      end
    end
  join_none



  fork
    begin : T1_WRITE
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          repeat (2) begin
            `uvm_do_on(m_wr_seq[j], p_sequencer.m_wr_sequencer[j])
          end
        join_none
      end
    end
    begin : T2_READ
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          repeat (3) begin
            `uvm_do_on(m_rd_seq[j], p_sequencer.m_rd_sequencer[j])
          end
        join_none
      end
    end
  join
endtask

// virtual sequence: blocking 32b incr burst single master random write
class axi_bk_32b_incr_single_master_random_write_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_bk_32b_incr_single_master_random_write_vseq)

  extern function new(string name = "axi_bk_32b_incr_single_master_random_write_vseq");
  extern virtual task body();
endclass

function axi_bk_32b_incr_single_master_random_write_vseq::new(
    string name = "axi_bk_32b_incr_single_master_random_write_vseq");
  super.new(name);
endfunction

task axi_bk_32b_incr_single_master_random_write_vseq::body();
  axi_master_bk_32b_incr_wr_sequence m_wr_seq;
  axi_slave_bk_wr_sequence  s_wr_seq [4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();

  fork
    begin : T1_SL_WR
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_wr_seq[j], p_sequencer.s_wr_sequencer[j])
          end
        join_none
      end
    end
  join_none

  #100ns;


  fork
    begin : T1_WRITE
      for (int i = 0; i < 4; i++) begin
        repeat (16) begin
          `uvm_do_on(m_wr_seq, p_sequencer.m_wr_sequencer[i])
        end
      end
      #100ns;
    end
  join

endtask

// virtual sequence: blocking 32b incr burst single master random read
class axi_bk_32b_incr_single_master_random_read_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_bk_32b_incr_single_master_random_read_vseq)

  extern function new(string name = "axi_bk_32b_incr_single_master_random_read_vseq");
  extern virtual task body();
endclass

function axi_bk_32b_incr_single_master_random_read_vseq::new(
    string name = "axi_bk_32b_incr_single_master_random_read_vseq");
  super.new(name);
endfunction

task axi_bk_32b_incr_single_master_random_read_vseq::body();
  axi_master_bk_32b_incr_rd_sequence m_rd_seq;
  axi_slave_bk_rd_sequence  s_rd_seq [4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();



  fork
    begin : T1_SL_RD
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_rd_seq[j], p_sequencer.s_rd_sequencer[j])
          end
        join_none
      end
    end
  join_none


  fork
    begin : T1_READ
      for (int i = 0; i < 4; i++) begin
        repeat (16) begin
          `uvm_do_on(m_rd_seq, p_sequencer.m_rd_sequencer[i])
        end
      end
      #100ns;
    end
  join
endtask


// virtual sequence: non-blocking 32b incr burst single master random write
class axi_nbk_32b_incr_single_master_random_write_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_nbk_32b_incr_single_master_random_write_vseq)

  extern function new(string name = "axi_nbk_32b_incr_single_master_random_write_vseq");
  extern virtual task body();
endclass

function axi_nbk_32b_incr_single_master_random_write_vseq::new(
    string name = "axi_nbk_32b_incr_single_master_random_write_vseq");
  super.new(name);
endfunction

task axi_nbk_32b_incr_single_master_random_write_vseq::body();
  axi_master_nbk_32b_incr_wr_sequence m_wr_seq;
  axi_slave_nbk_wr_sequence  s_wr_seq [4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();

  fork
    begin : T1_SL_WR
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_wr_seq[j], p_sequencer.s_wr_sequencer[j])
          end
        join_none
      end
    end
  join_none


  fork
    begin : T1_WRITE
      for (int i = 0; i < 4; i++) begin
        repeat (16) begin
          `uvm_do_on(m_wr_seq, p_sequencer.m_wr_sequencer[i])
        end
      end
      #100ns;
    end
  join
endtask

// virtual sequence: non-blocking 32b incr single master random read
class axi_nbk_32b_incr_single_master_random_read_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_nbk_32b_incr_single_master_random_read_vseq)

  extern function new(string name = "axi_nbk_32b_incr_single_master_random_read_vseq");
  extern virtual task body();
endclass

function axi_nbk_32b_incr_single_master_random_read_vseq::new(
    string name = "axi_nbk_32b_incr_single_master_random_read_vseq");
  super.new(name);
endfunction

task axi_nbk_32b_incr_single_master_random_read_vseq::body();
  axi_master_nbk_32b_incr_rd_sequence m_rd_seq;
  axi_slave_nbk_rd_sequence  s_rd_seq [4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();



  fork
    begin : T1_SL_RD
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_rd_seq[j], p_sequencer.s_rd_sequencer[j])
          end
        join_none
      end
    end
  join_none


  fork
    begin : T1_READ
      for (int i = 0; i < 4; i++) begin
        repeat (16) begin
          `uvm_do_on(m_rd_seq, p_sequencer.m_rd_sequencer[i])
        end
      end
      #100ns;
    end
  join
endtask


// virtual sequence: blocking 32b incr burst single master poll write
class axi_bk_32b_incr_single_master_poll_write_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_bk_32b_incr_single_master_poll_write_vseq)

  extern function new(string name = "axi_bk_32b_incr_single_master_poll_write_vseq");
  extern virtual task body();
endclass

function axi_bk_32b_incr_single_master_poll_write_vseq::new(
    string name = "axi_bk_32b_incr_single_master_poll_write_vseq");
  super.new(name);
endfunction

task axi_bk_32b_incr_single_master_poll_write_vseq::body();
  axi_master_bk_32b_incr_wr_sequence m_wr_seq;
  axi_slave_bk_wr_sequence  s_wr_seq [4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();

  fork
    begin : T1_SL_WR
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_wr_seq[j], p_sequencer.s_wr_sequencer[j])
          end
        join_none
      end
    end
  join_none

  #100ns;

  fork
    begin : T1_WRITE
      for (int i = 0; i < 4; i++) begin
        for (int j = 0; j < 4; j++) begin
          repeat (4) begin
            `uvm_do_on_with(m_wr_seq, p_sequencer.m_wr_sequencer[i], {m_wr_seq.dest == j;})
          end
        end
      end
      #100ns;
    end
  join

endtask

// virtual sequence: blocking 32b incr burst single master poll read
class axi_bk_32b_incr_single_master_poll_read_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_bk_32b_incr_single_master_poll_read_vseq)

  extern function new(string name = "axi_bk_32b_incr_single_master_poll_read_vseq");
  extern virtual task body();
endclass

function axi_bk_32b_incr_single_master_poll_read_vseq::new(
    string name = "axi_bk_32b_incr_single_master_poll_read_vseq");
  super.new(name);
endfunction

task axi_bk_32b_incr_single_master_poll_read_vseq::body();
  axi_master_bk_32b_incr_rd_sequence m_rd_seq;
  axi_slave_bk_rd_sequence  s_rd_seq [4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();

  fork
    begin : T1_SL_RD
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_rd_seq[j], p_sequencer.s_rd_sequencer[j])
          end
        join_none
      end
    end
  join_none

  #100ns;

  fork
    begin : T1_READ
      for (int i = 0; i < 4; i++) begin
        for (int j = 0; j < 4; j++) begin
          repeat (4) begin
            `uvm_do_on_with(m_rd_seq, p_sequencer.m_rd_sequencer[i], {m_rd_seq.dest == j;})
          end
        end
      end
      #100ns;
    end
  join

endtask


// narrow transfer
// virtual sequence: blocking 8b incr burst write and read
class axi_bk_8b_incr_write_read_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_bk_8b_incr_write_read_vseq)

  extern function new(string name = "axi_bk_8b_incr_write_read_vseq");
  extern virtual task body();
endclass

function axi_bk_8b_incr_write_read_vseq::new(string name = "axi_bk_8b_incr_write_read_vseq");
  super.new(name);
endfunction

task axi_bk_8b_incr_write_read_vseq::body();
  axi_master_bk_8b_incr_wr_sequence m_wr_seq[4];
  axi_master_bk_8b_incr_rd_sequence m_rd_seq[4];
  axi_slave_bk_wr_sequence  s_wr_seq[4];
  axi_slave_bk_rd_sequence  s_rd_seq[4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();


  fork
    begin : T1_SL_WR
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_wr_seq[j], p_sequencer.s_wr_sequencer[j])
          end
        join_none
      end
    end
    begin : T2_SL_RD
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_rd_seq[j], p_sequencer.s_rd_sequencer[j])
          end
        join_none
      end
    end
  join_none



  fork
    begin : T1_WRITE
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          repeat (2) begin
            `uvm_do_on(m_wr_seq[j], p_sequencer.m_wr_sequencer[j])
          end
        join_none
      end
    end
    begin : T2_READ
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          repeat (3) begin
            `uvm_do_on(m_rd_seq[j], p_sequencer.m_rd_sequencer[j])
          end
        join_none
      end
    end
  join

endtask

// virtual sequence: blocking 16b incr burst write and read
class axi_bk_16b_incr_write_read_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_bk_16b_incr_write_read_vseq)

  extern function new(string name = "axi_bk_16b_incr_write_read_vseq");
  extern virtual task body();
endclass

function axi_bk_16b_incr_write_read_vseq::new(string name = "axi_bk_16b_incr_write_read_vseq");
  super.new(name);
endfunction

task axi_bk_16b_incr_write_read_vseq::body();
  axi_master_bk_16b_incr_wr_sequence m_wr_seq[4];
  axi_master_bk_16b_incr_rd_sequence m_rd_seq[4];
  axi_slave_bk_wr_sequence  s_wr_seq[4];
  axi_slave_bk_rd_sequence  s_rd_seq[4];
  reset_event.wait_on();  // wait for reset
  reset_event.wait_off();


  fork
    begin : T1_SL_WR
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_wr_seq[j], p_sequencer.s_wr_sequencer[j])
          end
        join_none
      end
    end
    begin : T2_SL_RD
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          forever begin
            `uvm_do_on(s_rd_seq[j], p_sequencer.s_rd_sequencer[j])
          end
        join_none
      end
    end
  join_none



  fork
    begin : T1_WRITE
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          repeat (2) begin
            `uvm_do_on(m_wr_seq[j], p_sequencer.m_wr_sequencer[j])
          end
        join_none
      end
    end
    begin : T2_READ
      for (int i = 0; i < 4; i++) begin
        fork
          automatic int j = i;
          repeat (3) begin
            `uvm_do_on(m_rd_seq[j], p_sequencer.m_rd_sequencer[j])
          end
        join_none
      end
    end
  join

endtask

