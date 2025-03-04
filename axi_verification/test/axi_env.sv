class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)

  // Components
  axi_master_agent  master_agent[4];
  // TODO: Add slave agent
  axi_slave_agent   slave_agent [4];
  // TODO: Add scoreboard
  axi_ms_scoreboard scoreboard;
  // TODO: Add reference model
  // TODO: Add coverage collector

  function new(string name = "axi_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
endclass

function void axi_env::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Create components
  foreach (master_agent[i]) begin
    master_agent[i] = axi_master_agent::type_id::create($sformatf("master_agent[%0d]", i), this);
    uvm_config_db#(int)::set(this, master_agent[i].get_name(), "master_id", i);
  end
  foreach (slave_agent[i]) begin
    slave_agent[i] = axi_slave_agent::type_id::create($sformatf("slave_agent[%0d]", i), this);
    uvm_config_db#(int)::set(this, slave_agent[i].get_name(), "slave_id", i);
  end
  scoreboard = axi_ms_scoreboard::type_id::create("scoreboard", this);
endfunction

function void axi_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // Connect components
  foreach (master_agent[i]) begin
    master_agent[i].analysis_port.connect(scoreboard.ms_before_export);
  end
  foreach (slave_agent[i]) begin
    slave_agent[i].analysis_port.connect(scoreboard.ms_after_export);
  end
endfunction
