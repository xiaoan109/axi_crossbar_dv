class axi_slave_driver extends uvm_driver #(axi_s_txn);
  `uvm_component_utils(axi_slave_driver)

  // Compoennts
  axi_vif vif;
  int slave_id = -1;

  // Variables
  REQ wr_req;
  REQ rd_req;
  bit [7:0] slave_mem[bit [AXI_ADDR_W-1:0]];


  // UVM Methods
  extern function new(string name = "axi_slave_driver", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  // User Methods
  extern virtual task reset_signals();
  extern virtual task get_and_drive();
  extern virtual task wr_address();
  extern virtual task wr_data();
  extern virtual task wr_response();
  extern virtual task rd_address();
  extern virtual task rd_data_response();
endclass

function axi_slave_driver::new(string name = "axi_slave_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void axi_slave_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(axi_vif)::get(this, "", "vif", vif)) begin
    `uvm_fatal("CFGERR", {"virtual interface must be set for: ", get_type_name()});
  end
  if (!uvm_config_db#(int)::get(this, "", "slave_id", slave_id)) begin
    `uvm_fatal("CFGERR", {"Slave ID must be set for: ", get_type_name()});
  end
  wr_req = REQ::type_id::create("wr_req");
  rd_req = REQ::type_id::create("rd_req");
endfunction

task axi_slave_driver::run_phase(uvm_phase phase);
  fork
    reset_signals();
    get_and_drive();
  join_none
endtask

task axi_slave_driver::reset_signals();
  fork
    forever begin
      @(negedge vif.aresetn);
      `uvm_info("S_DRIVER", "reset_signals ...", UVM_MEDIUM)
      vif.s_drv_cb.awready <= 1'b0;
      vif.s_drv_cb.wready  <= 1'b0;
      vif.s_drv_cb.bvalid  <= 1'b0;
      vif.s_drv_cb.arready <= 1'b0;
      vif.s_drv_cb.rvalid  <= 1'b0;
    end
  join_none
endtask

task axi_slave_driver::get_and_drive();
  @(negedge vif.aresetn);  // wait for reset to be asserted
  @(posedge vif.aresetn);  // wait for reset to be de-asserted
  fork
    forever begin
      wr_address();
      wr_data();
      wr_response();
    end
    forever begin
      rd_address();
      rd_data_response();
    end
  join_none
endtask

task axi_slave_driver::wr_address();
  `uvm_info("S_DRIVER", "Waiting AW Channel", UVM_MEDIUM)
  @(vif.s_drv_cb);
  vif.s_drv_cb.awready <= 1'b1;
  @(vif.s_drv_cb iff vif.s_drv_cb.awvalid == 1'b1);
  //TODO: store transaction ID, address, etc.
  wr_req.op_type = WRITE;
  wr_req.awaddr = vif.s_drv_cb.awaddr;
  wr_req.awlen = vif.s_drv_cb.awlen;
  wr_req.awsize = size_e'(vif.s_drv_cb.awsize);
  wr_req.awburst = burst_e'(vif.s_drv_cb.awburst);
  wr_req.awid = vif.s_drv_cb.awid;
  vif.s_drv_cb.awready <= 1'b0;
endtask

task axi_slave_driver::wr_data();
  // TODO: support unaligned address
  int addr;
  int num_bytes;
  int total_bytes;

  addr = wr_req.awaddr[AXI_ADDR_W-1-2:0];
  num_bytes = (1 << wr_req.awsize);
  total_bytes = num_bytes * (wr_req.awlen + 1);

  `uvm_info("S_DRIVER", "Waiting W Channel", UVM_MEDIUM)

  // TODO: support different burst types
  // TODO: support different data widths
  @(vif.s_drv_cb);
  for (int i = 0; i < wr_req.awlen + 1; i++) begin
    vif.s_drv_cb.wready <= 1'b1;
    @(vif.s_drv_cb iff vif.s_drv_cb.wvalid == 1'b1);
    // TODO: support write strobe
    // slave_mem[addr] = vif.s_drv_cb.wdata;
    wr_req.wdata[i] = vif.s_drv_cb.wdata;
    vif.s_drv_cb.wready <= 1'b0;
  end
endtask

task axi_slave_driver::wr_response();
  `uvm_info("S_DRIVER", "Driving B Channel", UVM_MEDIUM)
  @(vif.s_drv_cb);
  vif.s_drv_cb.bvalid <= 1'b1;
  vif.s_drv_cb.bresp <= OKAY;  // TODO: support different response
  vif.s_drv_cb.buser <= 0;
  vif.s_drv_cb.bid <= wr_req.awid;
  @(vif.s_drv_cb iff vif.s_drv_cb.bready == 1'b1);
  vif.s_drv_cb.bvalid <= 1'b0;
endtask

task axi_slave_driver::rd_address();
  `uvm_info("S_DRIVER", "Waiting AR Channel", UVM_MEDIUM)
  @(vif.s_drv_cb);
  vif.s_drv_cb.arready <= 1'b1;
  @(vif.s_drv_cb iff vif.s_drv_cb.arvalid == 1'b1);
  rd_req.op_type = READ;
  rd_req.araddr = vif.s_drv_cb.araddr;
  rd_req.arlen = vif.s_drv_cb.arlen;
  rd_req.arsize = size_e'(vif.s_drv_cb.arsize);
  rd_req.arburst = burst_e'(vif.s_drv_cb.arburst);
  rd_req.arid = vif.s_drv_cb.arid;
  vif.s_drv_cb.arready <= 1'b0;
endtask

task axi_slave_driver::rd_data_response();
  //TODO: support all features as write channels
  int addr;
  int num_bytes;
  int total_bytes;

  addr = rd_req.awaddr[AXI_ADDR_W-1-2:0];
  num_bytes = (1 << rd_req.arsize);
  total_bytes = num_bytes * (rd_req.arlen + 1);

  `uvm_info("S_DRIVER", "Driving R Channel", UVM_MEDIUM)

  @(vif.s_drv_cb);
  for (int i = 0; i < rd_req.arlen + 1; i++) begin
    vif.s_drv_cb.rvalid <= 1'b1;
    // vif.s_drv_cb.rdata <= slave_mem[addr];
    vif.s_drv_cb.rdata <= $urandom;
    vif.s_drv_cb.rresp <= OKAY;
    vif.s_drv_cb.rid <= rd_req.arid;
    vif.s_drv_cb.ruser <= 0;
    vif.s_drv_cb.rlast <= (i == rd_req.arlen) ? 1'b1 : 1'b0;
    @(vif.s_drv_cb iff vif.s_drv_cb.rready == 1'b1);
    vif.s_drv_cb.rvalid <= 1'b0;
    vif.s_drv_cb.rlast  <= 1'b0;
  end
endtask
