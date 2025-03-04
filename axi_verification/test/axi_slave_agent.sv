class axi_slave_agent extends uvm_agent;
  `uvm_component_utils(axi_slave_agent)

  axi_slave_driver driver;
  axi_slave_monitor monitor;
  uvm_analysis_port #(axi_s_txn) analysis_port;

  axi_vif vif;
  int slave_id = -1;

  extern function new(string name = "axi_slave_agent", uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
endclass

function axi_slave_agent::new(string name = "axi_slave_agent", uvm_component parent);
  super.new(name, parent);
endfunction

function void axi_slave_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(axi_vif)::get(this, "", "vif", vif)) begin
    `uvm_fatal("CFGERR", {"Virtual interface must be set for: ", get_full_name()})
  end
  if (!uvm_config_db#(int)::get(this, "", "slave_id", slave_id)) begin
    `uvm_fatal("CFGERR", {"Slave ID must be set for: ", get_full_name()})
  end
  // TODO: change is_active to cfg.is_active
  uvm_config_db#(axi_vif)::set(this, "driver", "vif", vif);
  uvm_config_db#(axi_vif)::set(this, "monitor", "vif", vif);
  uvm_config_db#(int)::set(this, "driver", "slave_id", slave_id);
  uvm_config_db#(int)::set(this, "monitor", "slave_id", slave_id);
  monitor = axi_slave_monitor::type_id::create("monitor", this);
  if (is_active == UVM_ACTIVE) begin
    driver = axi_slave_driver::type_id::create("driver", this);
  end
  analysis_port = new("analysis_port", this);
endfunction

function void axi_slave_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // TODO: connect monitor to scoreboard
  monitor.mon2scb.connect(analysis_port);
endfunction
