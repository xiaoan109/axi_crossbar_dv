class axi_slave_monitor extends uvm_monitor;
  `uvm_component_utils(axi_slave_monitor)

  // Components
  axi_vif vif;
  int slave_id = -1;
  uvm_analysis_port #(axi_s_txn) mon2scb;
  axi_s_txn wr_trans;
  axi_s_txn rd_trans;
  axi_s_txn wr_trans_clone;
  axi_s_txn rd_trans_clone;

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
  wr_trans = axi_s_txn::type_id::create("wr_trans");
  rd_trans = axi_s_txn::type_id::create("rd_trans");
  mon2scb  = new("mon2scb", this);
endfunction

task axi_slave_monitor::run_phase(uvm_phase phase);
  fork
    wr_address_mon();
    wr_data_mon();
    wr_response_mon();
    rd_address_mon();
    rd_data_response_mon();
  join_none
endtask

task axi_slave_monitor::wr_address_mon();
  forever begin
    @(vif.s_mon_cb iff vif.s_mon_cb.awvalid == 1'b1 && vif.s_mon_cb.awready == 1'b1) begin
      wr_trans.op_type = WRITE;
      wr_trans.awaddr = {2'(slave_id), vif.s_mon_cb.awaddr[AXI_ADDR_W-1-2:0]};
      wr_trans.awsize = size_e'(vif.s_mon_cb.awsize);
      wr_trans.awlen = vif.s_mon_cb.awlen;
      wr_trans.awburst = burst_e'(vif.s_mon_cb.awburst);
      wr_trans.awid = vif.s_mon_cb.awid;
      // TODO: check if this is correct
      wr_trans.sa = $clog2(vif.s_mon_cb.awid[AXI_ID_W-1:4]);
      wr_trans.da = slave_id;
    end
  end
endtask

task axi_slave_monitor::wr_data_mon();
  forever begin

    for (int i = 0; i < wr_trans.awlen + 1; i++) begin
      @(vif.s_mon_cb iff vif.s_mon_cb.wvalid == 1'b1 && vif.s_mon_cb.wready == 1'b1);
      // TODO : wstrb
      wr_trans.wstrb[i] = vif.s_mon_cb.wstrb;
      wr_trans.wdata[i] = vif.s_mon_cb.wdata;
    end
  end
endtask

task axi_slave_monitor::wr_response_mon();
  forever begin
    @(vif.s_mon_cb iff vif.s_mon_cb.bvalid == 1'b1 && vif.s_mon_cb.bready == 1'b1) begin
      wr_trans.bresp = response_e'(vif.s_mon_cb.bresp);
      // TODO: check if the id is the same as the one we sent
      wr_trans.bid   = vif.s_mon_cb.bid;
      `uvm_info("S_MONITOR", {"collected write transaction:\n", wr_trans.sprint()}, UVM_MEDIUM)
      $cast(wr_trans_clone, wr_trans.clone());
      mon2scb.write(wr_trans_clone);
    end
  end
endtask


task axi_slave_monitor::rd_address_mon();
  forever begin
    @(vif.s_mon_cb iff vif.s_mon_cb.arvalid == 1'b1 && vif.s_mon_cb.arready == 1'b1) begin
      rd_trans.op_type = READ;
      rd_trans.araddr = {2'(slave_id), vif.s_mon_cb.araddr[AXI_ADDR_W-1-2:0]};
      rd_trans.arsize = size_e'(vif.s_mon_cb.arsize);
      rd_trans.arlen = vif.s_mon_cb.arlen;
      rd_trans.arburst = burst_e'(vif.s_mon_cb.arburst);
      rd_trans.arid = vif.s_mon_cb.arid;
      // TODO: check if this is correct
      rd_trans.sa = $clog2(vif.s_mon_cb.arid[AXI_ID_W-1:4]);
      rd_trans.da = slave_id;
    end
  end
endtask

task axi_slave_monitor::rd_data_response_mon();
  forever begin
    for (int i = 0; i < rd_trans.arlen + 1; i++) begin
      @(vif.s_mon_cb iff vif.s_mon_cb.rvalid == 1'b1 && vif.s_mon_cb.rready == 1'b1);
      rd_trans.rdata[i] = vif.s_mon_cb.rdata;
      rd_trans.rresp = response_e'(vif.s_mon_cb.rresp);  // TODO: multiple responses?
      // TODO: check if the id is the same as the one we sent
      rd_trans.rid = vif.s_mon_cb.rid;
      if (i == rd_trans.arlen) begin
        `uvm_info("S_MONITOR", {"collected read transaction:\n", rd_trans.sprint()}, UVM_MEDIUM)
        $cast(rd_trans_clone, rd_trans.clone());
        mon2scb.write(rd_trans_clone);
      end
    end
  end
endtask

