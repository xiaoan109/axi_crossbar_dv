class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)

  // Components
  axi_master_agent master_agent[];
  axi_slave_agent  slave_agent [];
  axi_scoreboard  scoreboard;

  axi_virtual_sequencer v_sqr;

  axi_env_config env_cfg;
  // Handle for axi_master agent configuration
  axi_master_agent_config master_agent_cfg[];
  // Handle for axi_slave agent configuration
  axi_slave_agent_config slave_agent_cfg[];
  // TODO: Add reference model


  function new(string name = "axi_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
endclass

function void axi_env::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // configs
  if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",env_cfg)) begin
    `uvm_fatal("FATAL_ENV_AGENT_CONFIG", $sformatf("Couldn't get the env_agent_config from config_db"))
  end

  master_agent_cfg = new[env_cfg.num_of_masters];
  foreach(master_agent_cfg[i]) begin
    if(!uvm_config_db#(axi_master_agent_config)::get(this,"",$sformatf("master_agent_config[%0d]",i),master_agent_cfg[i])) begin
      `uvm_fatal("FATAL_MA_AGENT_CONFIG", $sformatf("Couldn't get the master_agent_config[%0d] from config_db",i))
    end
  end

  slave_agent_cfg = new[env_cfg.num_of_slaves];
  foreach(slave_agent_cfg[i]) begin
    if(!uvm_config_db#(axi_slave_agent_config)::get(this,"",$sformatf("slave_agent_config[%0d]",i),slave_agent_cfg[i])) begin
      `uvm_fatal("FATAL_SA_AGENT_CONFIG", $sformatf("Couldn't get the slave_agent_config[%0d] from config_db",i))
    end
  end

  // Create components
  master_agent = new[env_cfg.num_of_masters];
  foreach (master_agent[i]) begin
    master_agent[i] = axi_master_agent::type_id::create($sformatf("master_agent[%0d]", i), this);
  end

  slave_agent = new[env_cfg.num_of_slaves];
  foreach (slave_agent[i]) begin
    slave_agent[i] = axi_slave_agent::type_id::create($sformatf("slave_agent[%0d]", i), this);
  end

  if(env_cfg.has_virtual_sqr) begin
    v_sqr = axi_virtual_sequencer::type_id::create("v_sqr",this);
  end

  if(env_cfg.has_scoreboard) begin
    scoreboard = axi_scoreboard::type_id::create("scoreboard", this);
  end

  // send cfg
  foreach(master_agent[i]) begin
    master_agent[i].cfg = master_agent_cfg[i];
  end

  foreach(slave_agent[i]) begin
    slave_agent[i].cfg = slave_agent_cfg[i];
  end

  v_sqr.env_cfg = env_cfg;
endfunction

function void axi_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // Connect components
  foreach (master_agent[i]) begin
    master_agent[i].monitor.axi4_master_write_address_analysis_port.connect(
      scoreboard.master_analysis_imp_h1);
    master_agent[i].monitor.axi4_master_write_data_analysis_port.connect(
      scoreboard.master_analysis_imp_h2);
    master_agent[i].monitor.axi4_master_write_response_analysis_port.connect(
      scoreboard.master_analysis_imp_h3);
    master_agent[i].monitor.axi4_master_read_address_analysis_port.connect(
      scoreboard.master_analysis_imp_h4);
    master_agent[i].monitor.axi4_master_read_data_analysis_port.connect(
      scoreboard.master_analysis_imp_h5);
  end

  foreach (slave_agent[i]) begin
    slave_agent[i].monitor.axi4_slave_write_address_analysis_port.connect(
      scoreboard.slave_analysis_imp_h1);
    slave_agent[i].monitor.axi4_slave_write_data_analysis_port.connect(
      scoreboard.slave_analysis_imp_h2);
    slave_agent[i].monitor.axi4_slave_write_response_analysis_port.connect(
      scoreboard.slave_analysis_imp_h3);
    slave_agent[i].monitor.axi4_slave_read_address_analysis_port.connect(
      scoreboard.slave_analysis_imp_h4);
    slave_agent[i].monitor.axi4_slave_read_data_analysis_port.connect(
      scoreboard.slave_analysis_imp_h5);
  end

  if(env_cfg.has_virtual_sqr) begin
    foreach(master_agent[i]) begin
      v_sqr.m_wr_sequencer[i] = master_agent[i].wr_sequencer;
      v_sqr.m_rd_sequencer[i] = master_agent[i].rd_sequencer;
    end
    foreach(slave_agent[i]) begin
      v_sqr.s_wr_sequencer[i] = slave_agent[i].wr_sequencer;
      v_sqr.s_rd_sequencer[i] = slave_agent[i].rd_sequencer;
    end
  end

endfunction
