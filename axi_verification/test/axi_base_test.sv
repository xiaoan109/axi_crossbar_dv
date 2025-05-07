// base sanity test
class axi_base_test extends uvm_test;
  `uvm_component_utils(axi_base_test)

  // Components
  axi_env env;
  // Variable: e_cfg_h
  // Declaring environment config handle
  axi_env_config env_cfg;
  // axi_vif
  axi_vif mst_vif[];
  axi_vif slv_vif[];

  function new(string name = "axi_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual task shutdown_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual function void setup_axi_vif();
  extern virtual function void setup_axi_env_cfg();
  extern virtual function void setup_axi_master_agent_cfg();
  extern virtual local function void set_and_display_master_config();
  extern virtual function void setup_axi_slave_agent_cfg();
  extern virtual local function void set_and_display_slave_config();
endclass

function void axi_base_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
  // Setup the environemnt cfg
  setup_axi_env_cfg();
  // Create components
  env   = axi_env::type_id::create("env", this);
  uvm_config_db#(uvm_object_wrapper)::set(this, "env.v_sqr.main_phase", "default_sequence",
    axi_base_vseq::type_id::get());
endfunction

function void axi_base_test::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);

  if (uvm_report_enabled(UVM_DEBUG, UVM_INFO, "TOPOLOGY")) begin
    uvm_root::get().print_topology();
  end

  if (uvm_report_enabled(UVM_DEBUG, UVM_INFO, "FACTORY")) begin
    uvm_factory::get().print();
  end

endfunction

task axi_base_test::main_phase(uvm_phase phase);
  uvm_objection objection;
  super.main_phase(phase);
  objection = phase.get_objection();
  objection.set_drain_time(this, 10us);
endtask

task axi_base_test::shutdown_phase(uvm_phase phase);
  super.shutdown_phase(phase);
  // phase.raise_objection(this);
  // env.scoreboard.wait_for_done();
  // phase.drop_objection(this);
endtask : shutdown_phase

function void axi_base_test::report_phase(uvm_phase phase);
  super.report_phase(phase);
  // `uvm_info("SB_REPORT", {"\n", env.scoreboard.convert2string()}, UVM_MEDIUM);
  // if (env.scoreboard.get_mismatches() == 0) begin
  //   `uvm_info("TEST_PASSED", "No mismatches", UVM_LOW)
  // end else begin
  //   `uvm_info("TEST_FAILED", $sformatf("mismatches: %d", env.scoreboard.get_mismatches()), UVM_LOW)
  // end
endfunction : report_phase

function void axi_base_test::setup_axi_vif();
  mst_vif = new[env_cfg.num_of_masters];
  foreach(mst_vif[i]) begin
    if (!uvm_config_db#(axi_vif)::get(this, "", $sformatf("mst_vif[%0d]", i), mst_vif[i])) begin
      `uvm_fatal("CFGERR", {"Virtual interface must be set for: ", get_full_name()})
    end else begin
      env_cfg.axi_mst_agent_cfg[i].vif = mst_vif[i];
    end
  end

  slv_vif = new[env_cfg.num_of_slaves];
  foreach(slv_vif[i]) begin
    if (!uvm_config_db#(axi_vif)::get(this, "", $sformatf("slv_vif[%0d]", i), slv_vif[i])) begin
      `uvm_fatal("CFGERR", {"Virtual interface must be set for: ", get_full_name()})
    end else begin
      env_cfg.axi_slv_agent_cfg[i].vif = slv_vif[i];
    end
  end
endfunction

//--------------------------------------------------------------------------------------------
// Function: setup_axi_env_cfg
// Setup the environment configuration with the required values
// and store the handle into the config_db
//--------------------------------------------------------------------------------------------
function void axi_base_test:: setup_axi_env_cfg();
  env_cfg = axi_env_config::type_id::create("env_cfg");

  env_cfg.has_scoreboard = 1;
  env_cfg.has_virtual_sqr = 1;
  env_cfg.num_of_masters = NUM_OF_MASTERS;
  env_cfg.num_of_slaves = NUM_OF_SLAVES;

  // Setup the axi4_master agent cfg
  setup_axi_master_agent_cfg();
  set_and_display_master_config();

  // Setup the axi4_slave agent cfg
  setup_axi_slave_agent_cfg();
  set_and_display_slave_config();

  // env_cfg.write_read_mode_h = WRITE_READ_DATA;

  // Setup axi vif
  setup_axi_vif();

  // set method for axi_env_cfg
  uvm_config_db #(axi_env_config)::set(this,"*","axi_env_config",env_cfg);
  `uvm_info(get_type_name(),$sformatf("\nAXI_ENV_CONFIG\n%s",env_cfg.sprint()),UVM_LOW);
endfunction


//--------------------------------------------------------------------------------------------
// Function: setup_axi_master_agent_cfg
// Setup the axi4_master agent configuration with the required values
// and store the handle into the config_db
//--------------------------------------------------------------------------------------------
function void axi_base_test::setup_axi_master_agent_cfg();
  bit [AXI_ADDR_W-1:0]local_min_address;
  bit [AXI_ADDR_W-1:0]local_max_address;
  env_cfg.axi_mst_agent_cfg = new[env_cfg.num_of_masters];
  foreach(env_cfg.axi_mst_agent_cfg[i])begin
    env_cfg.axi_mst_agent_cfg[i] = axi_master_agent_config::type_id::create($sformatf("axi_mst_agent_cfg[%0d]",i));
    env_cfg.axi_mst_agent_cfg[i].master_id = i;
    if(MASTER_AGENT_ACTIVE === 1) begin
      env_cfg.axi_mst_agent_cfg[i].is_active = uvm_active_passive_enum'(UVM_ACTIVE);
    end
    else begin
      env_cfg.axi_mst_agent_cfg[i].is_active = uvm_active_passive_enum'(UVM_PASSIVE);
    end
    env_cfg.axi_mst_agent_cfg[i].has_coverage = 1;
    // env_cfg.axi_mst_agent_cfg[i].qos_mode_type = QOS_MODE_DISABLE;
  end

  for(int i =0; i<NUM_OF_MASTERS; i++) begin
    if(i == 0) begin
      env_cfg.axi_mst_agent_cfg[i].master_min_addr_range(i,0);
      local_min_address = env_cfg.axi_mst_agent_cfg[i].master_min_addr_range_array[i];
      env_cfg.axi_mst_agent_cfg[i].master_max_addr_range(i,2**(SLAVE_MEMORY_SIZE)-1 );
      local_max_address = env_cfg.axi_mst_agent_cfg[i].master_max_addr_range_array[i];
    end
    else begin
      env_cfg.axi_mst_agent_cfg[i].master_min_addr_range(i,local_max_address + SLAVE_MEMORY_GAP);
      local_min_address = env_cfg.axi_mst_agent_cfg[i].master_min_addr_range_array[i];
      env_cfg.axi_mst_agent_cfg[i].master_max_addr_range(i,local_max_address+ 2**(SLAVE_MEMORY_SIZE)-1 +
        SLAVE_MEMORY_GAP);
      local_max_address = env_cfg.axi_mst_agent_cfg[i].master_max_addr_range_array[i];
    end
  end
endfunction

//--------------------------------------------------------------------------------------------
// Using this function for setting the master config to database
//--------------------------------------------------------------------------------------------
function void axi_base_test::set_and_display_master_config();
  foreach(env_cfg.axi_mst_agent_cfg[i])begin
    uvm_config_db#(axi_master_agent_config)::set(this,"*env*",$sformatf("master_agent_config[%0d]",i),env_cfg.axi_mst_agent_cfg[i]);
    `uvm_info(get_type_name(),$sformatf("\nAXI_MASTER_CONFIG[%0d]\n%s",i,env_cfg.axi_mst_agent_cfg[i].sprint()),UVM_LOW);
  end
endfunction

//--------------------------------------------------------------------------------------------
// Function: setup_axi4_slave_agents_cfg
// Setup the axi4_slave agent(s) configuration with the required values
// and store the handle into the config_db
//--------------------------------------------------------------------------------------------
function void axi_base_test::setup_axi_slave_agent_cfg();
  env_cfg.axi_slv_agent_cfg = new[env_cfg.num_of_slaves];
  foreach(env_cfg.axi_slv_agent_cfg[i])begin
    env_cfg.axi_slv_agent_cfg[i] = axi_slave_agent_config::type_id::create($sformatf("axi_slv_agent_cfg[%0d]",i));
    env_cfg.axi_slv_agent_cfg[i].slave_id = i;
    env_cfg.axi_slv_agent_cfg[i].min_address = env_cfg.axi_mst_agent_cfg[i].master_min_addr_range_array[i];
    env_cfg.axi_slv_agent_cfg[i].max_address = env_cfg.axi_mst_agent_cfg[i].master_max_addr_range_array[i];
    // env_cfg.axi_slv_agent_cfg[i].maximum_transactions = 3;
    // env_cfg.axi_slv_agent_cfg[i].read_data_mode = RANDOM_DATA_MODE;
    // env_cfg.axi_slv_agent_cfg[i].slave_response_mode = RESP_IN_ORDER;
    // env_cfg.axi_slv_agent_cfg[i].qos_mode_type = QOS_MODE_DISABLE;

    if(SLAVE_AGENT_ACTIVE === 1) begin
      env_cfg.axi_slv_agent_cfg[i].is_active = uvm_active_passive_enum'(UVM_ACTIVE);
    end
    else begin
      env_cfg.axi_slv_agent_cfg[i].is_active = uvm_active_passive_enum'(UVM_PASSIVE);
    end
    env_cfg.axi_slv_agent_cfg[i].has_coverage = 1;
  end
endfunction

//--------------------------------------------------------------------------------------------
// Using this function for setting the slave config to database
//--------------------------------------------------------------------------------------------
function void axi_base_test::set_and_display_slave_config();
  foreach(env_cfg.axi_slv_agent_cfg[i])begin
    uvm_config_db #(axi_slave_agent_config)::set(this,"*env*",$sformatf("slave_agent_config[%0d]",i), env_cfg.axi_slv_agent_cfg[i]);
    // uvm_config_db #(read_data_type_mode_e)::set(this,"*","read_data_mode",env_cfg.axi_slv_agent_cfg[i].read_data_mode);
    `uvm_info(get_type_name(),$sformatf("\nAXI_SLAVE_CONFIG[%0d]\n%s",i,env_cfg.axi_slv_agent_cfg[i].sprint()),UVM_LOW);
  end
endfunction


