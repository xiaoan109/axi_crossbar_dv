class axi_slave_monitor extends uvm_monitor;
  `uvm_component_utils(axi_slave_monitor)

  // Components
  axi_vif vif;
  int slave_id = -1;


  // Variables
  axi_s_txn wr_trans;
  axi_s_txn rd_trans;
  // Declaring analysis port for the monitor port
  uvm_analysis_port #(axi_s_txn) axi4_slave_write_address_analysis_port;
  uvm_analysis_port #(axi_s_txn) axi4_slave_write_data_analysis_port;
  uvm_analysis_port #(axi_s_txn) axi4_slave_write_response_analysis_port;
  uvm_analysis_port #(axi_s_txn) axi4_slave_read_address_analysis_port;
  uvm_analysis_port #(axi_s_txn) axi4_slave_read_data_analysis_port;
  //Variable: axi4_slave_write_address_fifo_h
  //Declaring handle for uvm_tlm_analysis_fifo for write task
  uvm_tlm_analysis_fifo #(axi_s_txn) axi4_slave_write_address_fifo_h;

  //Variable: axi4_slave_write_data_fifo_h
  //Declaring handle for uvm_tlm_analysis_fifo for write task
  uvm_tlm_analysis_fifo #(axi_s_txn) axi4_slave_write_data_fifo_h;

  //Variable: axi4_slave_read_fifo_h
  //Declaring handle for uvm_tlm_analysis_fifo for read task
  uvm_tlm_analysis_fifo #(axi_s_txn) axi4_slave_read_fifo_h;

  // UVM Methods
  extern function new(string name = "axi_slave_monitor", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  // User Methods
  extern virtual task wr_address_mon();
  extern virtual task wr_data_mon();
  extern virtual task wr_response_mon();
  extern virtual task rd_address_mon();
  extern virtual task rd_data_response_mon();

endclass

function axi_slave_monitor::new(string name = "axi_slave_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void axi_slave_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(axi_vif)::get(this, "", "vif", vif)) begin
    `uvm_fatal("CFGERR", {"virtual interface must be set for: ", get_type_name()});
  end
  if (!uvm_config_db#(int)::get(this, "", "slave_id", slave_id)) begin
    `uvm_fatal("CFGERR", {"Slave ID must be set for: ", get_type_name()});
  end
  axi4_slave_read_address_analysis_port   = new("axi4_slave_read_address_analysis_port", this);
  axi4_slave_read_data_analysis_port      = new("axi4_slave_read_data_analysis_port", this);
  axi4_slave_write_address_analysis_port  = new("axi4_slave_write_address_analysis_port", this);
  axi4_slave_write_data_analysis_port     = new("axi4_slave_write_data_analysis_port", this);
  axi4_slave_write_response_analysis_port = new("axi4_slave_write_response_analysis_port", this);
  axi4_slave_write_address_fifo_h         = new("axi4_slave_write_address_fifo_h", this);
  axi4_slave_write_data_fifo_h            = new("axi4_slave_write_data_fifo_h", this);
  axi4_slave_read_fifo_h                  = new("axi4_slave_read_fifo_h", this);
endfunction

task axi_slave_monitor::run_phase(uvm_phase phase);
  fork
    wr_address_mon();
    wr_data_mon();
    wr_response_mon();
    rd_address_mon();
    rd_data_response_mon();
  join
endtask

task axi_slave_monitor::wr_address_mon();
  forever begin
    axi_s_txn local_wr_addr_trans;
    axi_s_txn wr_trans_clone;
    local_wr_addr_trans = axi_s_txn::type_id::create("local_wr_addr_trans");
    @(vif.s_mon_cb iff vif.s_mon_cb.awvalid == 1'b1 && vif.s_mon_cb.awready == 1'b1) begin
      local_wr_addr_trans.op_type = WRITE;
      local_wr_addr_trans.awaddr  = {2'(slave_id), vif.s_mon_cb.awaddr[AXI_ADDR_W-1-2:0]};
      local_wr_addr_trans.awsize = size_e'(vif.s_mon_cb.awsize);
      local_wr_addr_trans.awlen = vif.s_mon_cb.awlen;
      local_wr_addr_trans.awburst = burst_e'(vif.s_mon_cb.awburst);
      local_wr_addr_trans.awid = vif.s_mon_cb.awid;
      local_wr_addr_trans.awlock = lock_e'(vif.s_mon_cb.awlock);
      local_wr_addr_trans.awcache = cache_e'(vif.s_mon_cb.awcache);
      local_wr_addr_trans.awprot = prot_e'(vif.s_mon_cb.awprot);
      local_wr_addr_trans.awqos = vif.s_mon_cb.awqos;
      local_wr_addr_trans.awregion = vif.s_mon_cb.awregion;
      local_wr_addr_trans.awuser = vif.s_mon_cb.awuser;
      // TODO: check if this is correct
      local_wr_addr_trans.sa = $clog2(vif.s_mon_cb.awid[AXI_ID_W-1:4]);
      local_wr_addr_trans.da = slave_id;
      $cast(wr_trans, local_wr_addr_trans.clone());
      axi4_slave_write_address_fifo_h.write(wr_trans);
      $cast(wr_trans_clone, wr_trans.clone());
      axi4_slave_write_address_analysis_port.write(wr_trans_clone);
    end
  end
endtask

task axi_slave_monitor::wr_data_mon();
  forever begin
    axi_s_txn local_wr_addr_trans;
    axi_s_txn local_wr_data_trans;
    axi_s_txn wr_trans_clone;
    local_wr_addr_trans = axi_s_txn::type_id::create("local_wr_addr_trans");
    local_wr_data_trans = axi_s_txn::type_id::create("local_wr_data_trans");
    begin
      int i = 0;
      forever begin
        @(vif.m_mon_cb iff vif.m_mon_cb.wvalid == 1'b1 && vif.m_mon_cb.wready == 1'b1);
        // TODO : wstrb
        local_wr_data_trans.wstrb[i] = vif.s_mon_cb.wstrb;
        local_wr_data_trans.wdata[i] = vif.s_mon_cb.wdata;
        local_wr_data_trans.wuser = vif.s_mon_cb.wuser;
        local_wr_data_trans.wlast = vif.s_mon_cb.wlast;
        if (local_wr_data_trans.wlast == 1) begin
          i = 0;
          break;
        end
        i++;
      end
    end
    //Getting the write address packet
    axi4_slave_write_address_fifo_h.get(local_wr_addr_trans);
    $cast(wr_trans, local_wr_addr_trans.clone());
    wr_trans.wdata = local_wr_data_trans.wdata;
    wr_trans.wstrb = local_wr_data_trans.wstrb;
    axi4_slave_write_data_fifo_h.write(wr_trans);
    $cast(wr_trans_clone, wr_trans.clone());
    axi4_slave_write_data_analysis_port.write(wr_trans_clone);
  end
endtask

task axi_slave_monitor::wr_response_mon();
  forever begin
    axi_s_txn local_wr_addr_data_trans;
    axi_s_txn local_wr_response_trans;
    axi_s_txn wr_trans_clone;
    local_wr_addr_data_trans = axi_s_txn::type_id::create("local_wr_addr_data_trans");
    local_wr_response_trans  = axi_s_txn::type_id::create("local_wr_response_trans");
    @(vif.m_mon_cb iff vif.m_mon_cb.bvalid == 1'b1 && vif.m_mon_cb.bready == 1'b1);
    local_wr_response_trans.bresp = response_e'(vif.s_mon_cb.bresp);
    local_wr_response_trans.bid   = vif.s_mon_cb.bid;
    local_wr_response_trans.buser = vif.s_mon_cb.buser;
    axi4_slave_write_data_fifo_h.get(local_wr_addr_data_trans);
    if(local_wr_response_trans.bid != local_wr_addr_data_trans.awid) begin
      `uvm_error("S_MONITOR", "Write response ID does not match write address ID")
    end
    $cast(wr_trans, local_wr_addr_data_trans.clone());
    wr_trans.bresp = local_wr_response_trans.bresp;
    wr_trans.bid   = local_wr_response_trans.bid;
    wr_trans.buser = local_wr_response_trans.buser;
    `uvm_info("S_MONITOR", {"collected write transaction:\n", wr_trans.sprint()}, UVM_MEDIUM)
    $cast(wr_trans_clone, wr_trans.clone());
    axi4_slave_write_response_analysis_port.write(wr_trans_clone);
  end
endtask


task axi_slave_monitor::rd_address_mon();
  forever begin
    axi_s_txn local_rd_addr_trans;
    axi_s_txn rd_trans_clone;
    local_rd_addr_trans = axi_s_txn::type_id::create("local_rd_addr_trans");
    @(vif.s_mon_cb iff vif.s_mon_cb.arvalid == 1'b1 && vif.s_mon_cb.arready == 1'b1) begin
      local_rd_addr_trans.op_type = READ;
      local_rd_addr_trans.araddr = {2'(slave_id), vif.s_mon_cb.araddr[AXI_ADDR_W-1-2:0]};
      local_rd_addr_trans.arsize = size_e'(vif.s_mon_cb.arsize);
      local_rd_addr_trans.arlen = vif.s_mon_cb.arlen;
      local_rd_addr_trans.arburst = burst_e'(vif.s_mon_cb.arburst);
      local_rd_addr_trans.arid = vif.s_mon_cb.arid;
      local_rd_addr_trans.arlock = lock_e'(vif.s_mon_cb.arlock);
      local_rd_addr_trans.arcache = cache_e'(vif.s_mon_cb.arcache);
      local_rd_addr_trans.arprot = prot_e'(vif.s_mon_cb.arprot);
      local_rd_addr_trans.arqos = vif.s_mon_cb.arqos;
      local_rd_addr_trans.arregion = vif.s_mon_cb.arregion;
      local_rd_addr_trans.aruser = vif.s_mon_cb.aruser;
      // TODO: check if this is correct
      local_rd_addr_trans.sa = $clog2(vif.s_mon_cb.arid[AXI_ID_W-1:4]);
      local_rd_addr_trans.da = slave_id;
      $cast(rd_trans, local_rd_addr_trans.clone());
      axi4_slave_read_fifo_h.write(rd_trans);
      $cast(rd_trans_clone, rd_trans.clone());
      axi4_slave_read_address_analysis_port.write(rd_trans_clone);
    end
  end
endtask

task axi_slave_monitor::rd_data_response_mon();
  forever begin
    axi_s_txn local_rd_addr_trans;
    axi_s_txn local_rd_data_trans;
    axi_s_txn rd_trans_clone;
    local_rd_addr_trans = axi_s_txn::type_id::create("local_rd_addr_trans");
    local_rd_data_trans = axi_s_txn::type_id::create("local_rd_data_trans");
    begin
      int i = 0;
      forever begin
        @(vif.m_mon_cb iff vif.m_mon_cb.rvalid == 1'b1 && vif.m_mon_cb.rready == 1'b1);
        local_rd_data_trans.rdata[i] = vif.s_mon_cb.rdata;
        local_rd_data_trans.rresp = response_e'(vif.s_mon_cb.rresp);  // TODO: multiple responses?
        local_rd_data_trans.rid = vif.s_mon_cb.rid;
        local_rd_data_trans.ruser = vif.s_mon_cb.ruser;
        local_rd_data_trans.rlast = vif.s_mon_cb.rlast;
        if (local_rd_data_trans.rlast == 1) begin
          i = 0;
          break;
        end
        i++;
      end
      axi4_slave_read_fifo_h.get(local_rd_addr_trans);
      if(local_rd_data_trans.rid != local_rd_addr_trans.arid) begin
        `uvm_error("S_MONITOR", "Read response ID does not match read address ID")
      end
      $cast(rd_trans, local_rd_addr_trans.clone());
      rd_trans.rdata = local_rd_data_trans.rdata;
      rd_trans.rresp = local_rd_data_trans.rresp;
      rd_trans.rid   = local_rd_data_trans.rid;
      rd_trans.ruser = local_rd_data_trans.ruser;
      `uvm_info("S_MONITOR", {"collected read transaction:\n", rd_trans.sprint()}, UVM_MEDIUM)
      $cast(rd_trans_clone, rd_trans.clone());
      axi4_slave_read_data_analysis_port.write(rd_trans_clone);
    end
  end
endtask


