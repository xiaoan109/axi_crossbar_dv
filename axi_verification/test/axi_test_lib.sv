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
// FILENAME       : axi_test_lib.sv
// Author         : EDA [xxxx.com]
// Created        : 2025-04-24 12:48
// LAST MODIFIED  : 2025-04-24 12:49
// ***********************************************************************
// DESCRIPTION    :
// ***********************************************************************
// $Revision: $
// $Id: $
// ***********************************************************************

// blocking 32b incr burst write and read test
class axi_bk_32b_incr_write_read_test extends axi_base_test;
  `uvm_component_utils(axi_bk_32b_incr_write_read_test)


  function new(string name = "axi_bk_32b_incr_write_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.v_sqr.main_phase", "default_sequence",
                                            axi_bk_32b_incr_write_read_vseq::type_id::get());
  endfunction
endclass

// non-blocking 32b incr burst write and read test
class axi_nbk_32b_incr_write_read_test extends axi_base_test;
  `uvm_component_utils(axi_nbk_32b_incr_write_read_test)

  function new(string name = "axi_nbk_32b_incr_write_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.v_sqr.main_phase", "default_sequence",
                                            axi_nbk_32b_incr_write_read_vseq::type_id::get());
  endfunction
endclass

// blocking 32b incr burst single master random write test
class axi_bk_32b_incr_single_master_random_write_test extends axi_base_test;
  `uvm_component_utils(axi_bk_32b_incr_single_master_random_write_test)

  function new(string name = "axi_bk_32b_incr_single_master_random_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.v_sqr.main_phase", "default_sequence",
                                            axi_bk_32b_incr_single_master_random_write_vseq::type_id::get());
  endfunction
endclass

// blocking 32b incr burst single master random read test
class axi_bk_32b_incr_single_master_random_read_test extends axi_base_test;
  `uvm_component_utils(axi_bk_32b_incr_single_master_random_read_test)

  function new(string name = "axi_bk_32b_incr_single_master_random_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.v_sqr.main_phase", "default_sequence",
                                            axi_bk_32b_incr_single_master_random_read_vseq::type_id::get());
  endfunction
endclass

// non-blocking 32b incr burst single master random write test
class axi_nbk_32b_incr_single_master_random_write_test extends axi_base_test;
  `uvm_component_utils(axi_nbk_32b_incr_single_master_random_write_test)

  function new(string name = "axi_nbk_32b_incr_single_master_random_write_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(
        this, "env.v_sqr.main_phase", "default_sequence",
        axi_nbk_32b_incr_single_master_random_write_vseq::type_id::get());
  endfunction
endclass

// non-blocking 32b incr burst single master random read test
class axi_nbk_32b_incr_single_master_random_read_test extends axi_base_test;
  `uvm_component_utils(axi_nbk_32b_incr_single_master_random_read_test)

  function new(string name = "axi_nbk_32b_incr_single_master_random_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.v_sqr.main_phase", "default_sequence",
                                            axi_nbk_32b_incr_single_master_random_read_vseq::type_id::get());
  endfunction
endclass


// blocking 32b incr burst single master poll write test
class axi_bk_32b_incr_single_master_poll_write_test extends axi_base_test;
  `uvm_component_utils(axi_bk_32b_incr_single_master_poll_write_test)

  function new(string name = "axi_bk_32b_incr_single_master_poll_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.v_sqr.main_phase", "default_sequence",
                                            axi_bk_32b_incr_single_master_poll_write_vseq::type_id::get());
  endfunction
endclass

// blocking 32b incr burst single master poll read test
class axi_bk_32b_incr_single_master_poll_read_test extends axi_base_test;
  `uvm_component_utils(axi_bk_32b_incr_single_master_poll_read_test)

  function new(string name = "axi_bk_32b_incr_single_master_poll_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.v_sqr.main_phase", "default_sequence",
                                            axi_bk_32b_incr_single_master_poll_read_vseq::type_id::get());
  endfunction
endclass

// narrow transfer
// blocking 8b incr burst write and read test
class axi_bk_8b_incr_write_read_test extends axi_base_test;
  `uvm_component_utils(axi_bk_8b_incr_write_read_test)

  function new(string name = "axi_bk_8b_incr_write_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.v_sqr.main_phase", "default_sequence",
                                            axi_bk_8b_incr_write_read_vseq::type_id::get());
  endfunction
endclass

// blocking 16b incr burst write and read test
class axi_bk_16b_incr_write_read_test extends axi_base_test;
  `uvm_component_utils(axi_bk_16b_incr_write_read_test)

  function new(string name = "axi_bk_16b_incr_write_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.v_sqr.main_phase", "default_sequence",
                                            axi_bk_16b_incr_write_read_vseq::type_id::get());
  endfunction
endclass

