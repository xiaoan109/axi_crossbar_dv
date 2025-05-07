class axi_master_agent extends uvm_agent;
  `uvm_component_utils(axi_master_agent)

  axi_master_driver driver;
  axi_master_monitor monitor;
  axi_master_sequencer wr_sequencer;
  axi_master_sequencer rd_sequencer;
  axi_master_coverage coverage;

  axi_master_agent_config cfg;

  // axi_vif vif;
  // int master_id = -1;

  extern function new(string name = "axi_master_agent", uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
endclass

function axi_master_agent::new(string name = "axi_master_agent", uvm_component parent);
  super.new(name, parent);
endfunction

function void axi_master_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  // if (!uvm_config_db#(axi_vif)::get(this, "", "vif", vif)) begin
  //   `uvm_fatal("CFGERR", {"Virtual interface must be set for: ", get_full_name()})
  // end
  // if (!uvm_config_db#(int)::get(this, "", "master_id", master_id)) begin
  //   `uvm_fatal("CFGERR", {"Master ID must be set for: ", get_full_name()})
  // end
  monitor = axi_master_monitor::type_id::create("monitor", this);
  uvm_config_db#(axi_vif)::set(this, "monitor", "vif", cfg.vif);
  uvm_config_db#(int)::set(this, "monitor", "master_id", cfg.master_id);

  if (cfg.is_active == UVM_ACTIVE) begin
    driver = axi_master_driver::type_id::create("driver", this);
    wr_sequencer = axi_master_sequencer::type_id::create("wr_sequencer", this);
    rd_sequencer = axi_master_sequencer::type_id::create("rd_sequencer", this);
    uvm_config_db#(axi_vif)::set(this, "driver", "vif", cfg.vif);
    uvm_config_db#(int)::set(this, "*", "master_id", cfg.master_id); // config_db for driver & seq
  end

  if(cfg.has_coverage) begin
    coverage = axi_master_coverage::type_id::create("coverage", this);
  end
endfunction

function void axi_master_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if (cfg.is_active == UVM_ACTIVE) begin
    driver.wr_seq_item_port.connect(wr_sequencer.seq_item_export);
    driver.rd_seq_item_port.connect(rd_sequencer.seq_item_export);
  end
  if(cfg.has_coverage) begin
    monitor.axi4_master_write_address_analysis_port.connect(coverage.analysis_export);
    monitor.axi4_master_write_data_analysis_port.connect(coverage.analysis_export);
    monitor.axi4_master_write_response_analysis_port.connect(coverage.analysis_export);
    monitor.axi4_master_read_address_analysis_port.connect(coverage.analysis_export);
    monitor.axi4_master_read_data_analysis_port.connect(coverage.analysis_export);
  end
endfunction
