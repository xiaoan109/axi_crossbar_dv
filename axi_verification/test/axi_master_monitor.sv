class axi_master_monitor extends uvm_monitor;
  `uvm_component_utils(axi_master_monitor)

  // Components
  axi_vif vif;
  int master_id = -1;
  uvm_analysis_port #(axi_m_txn) mon2scb;
  axi_m_txn wr_trans;
  axi_m_txn rd_trans;
  axi_m_txn wr_trans_clone;
  axi_m_txn rd_trans_clone;
  uvm_event reset_event = uvm_event_pool::get_global("reset");
  //Declaring handle for uvm_tlm_analysis_fifo for write task
  uvm_tlm_analysis_fifo #(axi_m_txn) axi4_master_write_address_fifo_h;
  //Declaring handle for uvm_tlm_analysis_fifo for write task
  uvm_tlm_analysis_fifo #(axi_m_txn) axi4_master_write_data_fifo_h;
  //Declaring handle for uvm_tlm_analysis_fifo for read task
  uvm_tlm_analysis_fifo #(axi_m_txn) axi4_master_read_fifo_h;

  // UVM Methods
  extern function new(string name = "axi_master_monitor", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  // User Methods
  extern virtual task detect_reset();
  extern virtual task wr_address_mon();
  extern virtual task wr_data_mon();
  extern virtual task wr_response_mon();
  extern virtual task rd_address_mon();
  extern virtual task rd_data_response_mon();
endclass

function axi_master_monitor::new(string name = "axi_master_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void axi_master_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(axi_vif)::get(this, "", "vif", vif)) begin
    `uvm_fatal("CFGERR", {"virtual interface must be set for: ", get_type_name()});
  end
  if (!uvm_config_db#(int)::get(this, "", "master_id", master_id)) begin
    `uvm_fatal("CFGERR", {"Master ID must be set for: ", get_type_name()});
  end
  mon2scb = new("mon2scb", this);
  axi4_master_write_address_fifo_h = new("axi4_master_write_address_fifo_h", this);
  axi4_master_write_data_fifo_h = new("axi4_master_write_data_fifo_h", this);
  axi4_master_read_fifo_h = new("axi4_master_read_fifo_h", this);
endfunction

task axi_master_monitor::run_phase(uvm_phase phase);
  fork
    detect_reset();
    wr_address_mon();
    wr_data_mon();
    wr_response_mon();
    rd_address_mon();
    rd_data_response_mon();
  join_none
endtask

task axi_master_monitor::detect_reset();
  forever begin
    @(vif.aresetn);
    assert (!$isunknown(vif.aresetn));
    if (vif.aresetn == 1'b0) begin
      reset_event.trigger();
    end else begin
      reset_event.reset(.wakeup(1));
    end
  end
endtask

task axi_master_monitor::wr_address_mon();
  forever begin
    axi_m_txn local_wr_addr_trans;
    local_wr_addr_trans = axi_m_txn::type_id::create("local_wr_addr_trans");
    @(vif.m_mon_cb iff vif.m_mon_cb.awvalid == 1'b1 && vif.m_mon_cb.awready == 1'b1);
    local_wr_addr_trans.op_type = WRITE;
    local_wr_addr_trans.awaddr = vif.m_mon_cb.awaddr;
    local_wr_addr_trans.awsize = size_e'(vif.m_mon_cb.awsize);
    local_wr_addr_trans.awlen = vif.m_mon_cb.awlen;
    local_wr_addr_trans.awburst = burst_e'(vif.m_mon_cb.awburst);
    local_wr_addr_trans.awid = vif.m_mon_cb.awid;
    local_wr_addr_trans.sa = master_id;
    local_wr_addr_trans.da = vif.m_mon_cb.awaddr[AXI_ADDR_W-1:AXI_ADDR_W-2]; // TODO: check if this is correct
    $cast(wr_trans, local_wr_addr_trans.clone());
    axi4_master_write_address_fifo_h.write(wr_trans);
  end
endtask

task axi_master_monitor::wr_data_mon();
  forever begin
    axi_m_txn local_wr_addr_trans;
    axi_m_txn local_wr_data_trans;
    local_wr_addr_trans = axi_m_txn::type_id::create("local_wr_addr_trans");
    local_wr_data_trans = axi_m_txn::type_id::create("local_wr_data_trans");
    begin
      int i = 0;
      forever begin
        @(vif.m_mon_cb iff vif.m_mon_cb.wvalid == 1'b1 && vif.m_mon_cb.wready == 1'b1);
        // TODO : wstrb
        local_wr_data_trans.wstrb[i] = vif.m_mon_cb.wstrb;
        local_wr_data_trans.wdata[i] = vif.m_mon_cb.wdata;
        local_wr_data_trans.wlast = vif.m_mon_cb.wlast;
        if (local_wr_data_trans.wlast == 1) begin
          i = 0;
          break;
        end
        i++;
      end
    end
    axi4_master_write_address_fifo_h.get(local_wr_addr_trans);
    $cast(wr_trans, local_wr_addr_trans.clone());
    wr_trans.wdata = local_wr_data_trans.wdata;
    wr_trans.wstrb = local_wr_data_trans.wstrb;
    axi4_master_write_data_fifo_h.write(wr_trans);
  end
endtask

task axi_master_monitor::wr_response_mon();
  forever begin
    axi_m_txn local_wr_addr_data_trans;
    axi_m_txn local_wr_response_trans;
    local_wr_addr_data_trans = axi_m_txn::type_id::create("local_wr_addr_data_trans");
    local_wr_response_trans  = axi_m_txn::type_id::create("local_wr_response_trans");
    @(vif.m_mon_cb iff vif.m_mon_cb.bvalid == 1'b1 && vif.m_mon_cb.bready == 1'b1);
    local_wr_response_trans.bresp = response_e'(vif.m_mon_cb.bresp);
    // TODO: check if the id is the same as the one we sent
    local_wr_response_trans.bid   = vif.m_mon_cb.bid;
    axi4_master_write_data_fifo_h.get(local_wr_addr_data_trans);
    $cast(wr_trans, local_wr_addr_data_trans);
    wr_trans.bresp = local_wr_response_trans.bresp;
    wr_trans.bid   = local_wr_response_trans.bid;
    `uvm_info("M_MONITOR", {"colloected write transaction:\n", wr_trans.sprint()}, UVM_MEDIUM)
    $cast(wr_trans_clone, wr_trans.clone());
    mon2scb.write(wr_trans_clone);
  end
endtask

task axi_master_monitor::rd_address_mon();
  forever begin
    axi_m_txn local_rd_addr_trans;
    local_rd_addr_trans = axi_m_txn::type_id::create("local_rd_addr_trans");
    @(vif.m_mon_cb iff vif.m_mon_cb.arvalid == 1'b1 && vif.m_mon_cb.arready == 1'b1);
    local_rd_addr_trans.op_type = READ;
    local_rd_addr_trans.araddr = vif.m_mon_cb.araddr;
    local_rd_addr_trans.arsize = size_e'(vif.m_mon_cb.arsize);
    local_rd_addr_trans.arlen = vif.m_mon_cb.arlen;
    local_rd_addr_trans.arburst = burst_e'(vif.m_mon_cb.arburst);
    local_rd_addr_trans.arid = vif.m_mon_cb.arid;
    local_rd_addr_trans.sa = master_id;
    local_rd_addr_trans.da = vif.m_mon_cb.araddr[AXI_ADDR_W-1:AXI_ADDR_W-2]; // TODO: check if this is correct
    $cast(rd_trans, local_rd_addr_trans.clone());
    axi4_master_read_fifo_h.write(rd_trans);
  end
endtask

task axi_master_monitor::rd_data_response_mon();
  forever begin
    axi_m_txn local_rd_addr_trans;
    axi_m_txn local_rd_data_trans;
    local_rd_addr_trans = axi_m_txn::type_id::create("local_rd_addr_trans");
    local_rd_data_trans = axi_m_txn::type_id::create("local_rd_data_trans");
    begin
      int i = 0;
      forever begin
        @(vif.m_mon_cb iff vif.m_mon_cb.rvalid == 1'b1 && vif.m_mon_cb.rready == 1'b1);
        local_rd_data_trans.rdata[i] = vif.m_mon_cb.rdata;
        local_rd_data_trans.rresp = response_e'(vif.m_mon_cb.rresp);  // TODO: multiple responses?
        // TODO: check if the id is the same as the one we sent
        local_rd_data_trans.rid = vif.m_mon_cb.rid;
        local_rd_data_trans.rlast = vif.m_mon_cb.rlast;
        if (local_rd_data_trans.rlast == 1) begin
          i = 0;
          break;
        end
        i++;
      end
      axi4_master_read_fifo_h.get(local_rd_addr_trans);
      $cast(rd_trans, local_rd_addr_trans.clone());
      rd_trans.rdata = local_rd_data_trans.rdata;
      rd_trans.rresp = local_rd_data_trans.rresp;
      rd_trans.rid   = local_rd_data_trans.rid;
      `uvm_info("M_MONITOR", {"collected read transaction:\n", rd_trans.sprint()}, UVM_MEDIUM)
      $cast(rd_trans_clone, rd_trans.clone());
      mon2scb.write(rd_trans_clone);
    end
  end
endtask

