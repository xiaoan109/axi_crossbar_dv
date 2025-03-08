class axi_slave_driver extends uvm_driver #(axi_s_txn);
  `uvm_component_utils(axi_slave_driver)

  // Compoennts
  axi_vif vif;
  int slave_id = -1;
  uvm_seq_item_pull_port #(axi_s_txn) wr_seq_item_port;
  uvm_seq_item_pull_port #(axi_s_txn) rd_seq_item_port;

  // Variables
  REQ wr_req;
  REQ rd_req;

  bit [7:0] i = 0;
  bit [7:0] j = 0;
  bit [7:0] a = 0;
  int wr_idx = 0;
  int rd_idx = 0;


  bit [AXI_ID_W-1 : 0] mem_awid[2**8];
  bit [AXI_ADDR_W-1:0] mem_waddr[2**8];
  bit [7 : 0] mem_wlen[2**8];
  bit [2 : 0] mem_wsize[2**8];
  bit [1 : 0] mem_wburst[2**8];
  bit mem_wlast[2**8];

  bit [AXI_ID_W-1 : 0] mem_arid[2**8];
  bit [AXI_ADDR_W-1:0] mem_raddr[2**8];
  bit [7 : 0] mem_rlen[2**8];
  bit [2 : 0] mem_rsize[2**8];
  bit [1 : 0] mem_rburst[2**8];

  //Declaring handle for uvm_tlm_analysis_fifo's for all the five channels
  uvm_tlm_fifo #(axi_s_txn) axi4_slave_write_addr_fifo_h;
  uvm_tlm_fifo #(axi_s_txn) axi4_slave_write_data_in_fifo_h;
  uvm_tlm_fifo #(axi_s_txn) axi4_slave_write_response_fifo_h;
  uvm_tlm_fifo #(axi_s_txn) axi4_slave_write_data_out_fifo_h;
  uvm_tlm_fifo #(axi_s_txn) axi4_slave_read_addr_fifo_h;
  uvm_tlm_fifo #(axi_s_txn) axi4_slave_read_data_in_fifo_h;
  //Declaring Semaphore handles for writes and reads
  semaphore semaphore_write_key;
  semaphore semaphore_read_key;

  // UVM Methods
  extern function new(string name = "axi_slave_driver", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  // User Methods
  extern virtual task reset_signals();
  extern virtual task get_and_drive();
  extern virtual task wr_address(REQ wr_req);
  extern virtual task wr_data(REQ wr_req);
  extern virtual task wr_response(REQ wr_req);
  extern virtual task rd_address(REQ rd_req);
  extern virtual task rd_data_response(REQ rd_req);
  extern virtual task dummy_write_memory(REQ wr_req);
  extern virtual task dummy_read_memory(REQ rd_req);
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
  wr_seq_item_port                 = new("wr_seq_item_port", this);
  rd_seq_item_port                 = new("rd_seq_item_port", this);
  axi4_slave_write_addr_fifo_h     = new("axi4_slave_write_addr_fifo_h", this, 16);
  axi4_slave_write_data_in_fifo_h  = new("axi4_slave_write_data_in_fifo_h", this, 16);
  axi4_slave_write_response_fifo_h = new("axi4_slave_write_response_fifo_h", this, 16);
  axi4_slave_write_data_out_fifo_h = new("axi4_slave_write_data_out_fifo_h", this, 16);
  axi4_slave_read_addr_fifo_h      = new("axi4_slave_read_addr_fifo_h", this, 16);
  axi4_slave_read_data_in_fifo_h   = new("axi4_slave_read_data_in_fifo_h", this, 16);
  semaphore_write_key              = new(1);
  semaphore_read_key               = new(1);
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
  fork
    forever begin : WRITE_TASK
      process addr_tx;
      process data_tx;
      process response_tx;

      wr_seq_item_port.get_next_item(wr_req);
      // writting the req into write data and response fifo's
      axi4_slave_write_data_in_fifo_h.put(wr_req);
      axi4_slave_write_response_fifo_h.put(wr_req);
      fork
        begin : WRITE_ADDRESS_CHANNEL
          axi_s_txn local_slave_addr_tx;
          addr_tx = process::self();
          wr_address(wr_req);
          $cast(local_slave_addr_tx, wr_req.clone());
          // putting write address data into address fifo
          if (axi4_slave_write_addr_fifo_h.is_full) begin
            `uvm_error("S_DRIVER", $sformatf(
                       "WRITE_ADDR_THREAD::Cannot put into FIFO as WRITE_FIFO is FULL"));
          end else begin
            axi4_slave_write_addr_fifo_h.put(local_slave_addr_tx);
          end
        end

        begin : WRITE_DATA_CHANNEL
          axi_s_txn local_slave_data_tx;
          data_tx = process::self();
          semaphore_write_key.get(1);
          axi4_slave_write_data_in_fifo_h.get(local_slave_data_tx);
          wr_data(local_slave_data_tx);
          axi4_slave_write_data_out_fifo_h.put(local_slave_data_tx);
          semaphore_write_key.put(1);
        end

        begin : WRITE_RESPONSE_CHANNEL
          axi_s_txn local_slave_addr_tx;
          axi_s_txn local_slave_data_tx;
          axi_s_txn local_slave_response_tx;
          axi_s_txn packet;
          response_tx = process::self();
          semaphore_write_key.get(1);
          axi4_slave_write_response_fifo_h.get(local_slave_response_tx);
          wr_response(local_slave_response_tx);

          //check for fifo empty if not get the data 
          if (axi4_slave_write_addr_fifo_h.is_empty) begin
            `uvm_error("S_DRIVER", $sformatf(
                       "WRITE_RESP_THREAD::Cannot get write addr data from FIFO as WRITE_ADDR_FIFO is EMPTY"
                       ));
          end else begin
            axi4_slave_write_addr_fifo_h.get(local_slave_addr_tx);
            `uvm_info("DEBUG_FIFO", $sformatf("fifo_size = %0d", axi4_slave_write_addr_fifo_h.size()
                      ), UVM_HIGH)
            `uvm_info("DEBUG_FIFO", $sformatf("fifo_used = %0d", axi4_slave_write_addr_fifo_h.used()
                      ), UVM_HIGH)
          end
          axi4_slave_write_data_out_fifo_h.get(local_slave_data_tx);
          $cast(packet, local_slave_addr_tx.clone());
          packet.wdata = local_slave_data_tx.wdata;
          packet.wstrb = local_slave_data_tx.wstrb;
          packet.bid   = local_slave_response_tx.bid;
          packet.bresp = local_slave_response_tx.bresp;
          //calling task memory write to store the data into slave memory
          dummy_write_memory(packet);
          semaphore_write_key.put(1);
        end
      join_any
      addr_tx.await();
      wr_seq_item_port.item_done();
    end
    forever begin : READ_TASK
      process rd_addr;
      process rd_data;
      rd_seq_item_port.get_next_item(rd_req);
      axi4_slave_read_data_in_fifo_h.put(rd_req);
      fork
        begin : READ_ADDRESS_CHANNEL
          axi_s_txn local_slave_addr_tx;
          rd_addr = process::self();
          rd_address(rd_req);
          $cast(local_slave_addr_tx, rd_req.clone());
          if (axi4_slave_read_addr_fifo_h.is_full) begin
            `uvm_error("S_DRIVER", $sformatf(
                       "READ_ADDR_THREAD::Cannot put into FIFO as READ_FIFO is FULL"));
          end else begin
            axi4_slave_read_addr_fifo_h.put(local_slave_addr_tx);
          end
        end

        begin : READ_DATA_CHANNEL
          axi_s_txn local_slave_raddr_tx;
          axi_s_txn local_slave_rdata_tx;
          axi_s_txn packet;
          rd_data = process::self();
          semaphore_read_key.get(1);
          //Waiting for the read address thread to complete
          rd_addr.await();
          axi4_slave_read_data_in_fifo_h.get(local_slave_rdata_tx);
          rd_data_response(local_slave_rdata_tx);
          //Getting teh sampled read address from read address fifo
          axi4_slave_read_addr_fifo_h.get(local_slave_raddr_tx);
          $cast(packet, local_slave_raddr_tx.clone());
          packet.rdata = local_slave_rdata_tx.rdata;
          packet.rresp = local_slave_rdata_tx.rresp;
          packet.rid   = local_slave_rdata_tx.rid;
          dummy_read_memory(packet);
          semaphore_read_key.put(1);
        end
      join_any
      rd_addr.await();
      rd_seq_item_port.item_done();
    end
  join
endtask

task axi_slave_driver::wr_address(REQ wr_req);
  `uvm_info("S_DRIVER", "Waiting AW Channel", UVM_MEDIUM)
  @(vif.s_drv_cb iff vif.s_drv_cb.awvalid == 1'b1);
  mem_awid[i]  = vif.s_drv_cb.awid;
  mem_waddr[i] = vif.s_drv_cb.awaddr;
  mem_wlen[i] = vif.s_drv_cb.awlen;
  mem_wsize[i] = vif.s_drv_cb.awsize;
  mem_wburst[i] = vif.s_drv_cb.awburst;
  wr_req.op_type = WRITE;
  wr_req.awaddr = mem_waddr[i];
  wr_req.awlen = mem_wlen[i];
  wr_req.awsize = size_e'(mem_wsize[i]);
  wr_req.awburst = burst_e'(mem_wburst[i]);
  wr_req.awid = mem_awid[i];
  i++;
  vif.s_drv_cb.awready <= 1'b1;
  @(vif.s_drv_cb);
  vif.s_drv_cb.awready <= 1'b0;
endtask

task axi_slave_driver::wr_data(REQ wr_req);
  `uvm_info("S_DRIVER", "Waiting W Channel", UVM_MEDIUM)

  // TODO: support different burst types
  // TODO: support different data widths (narrow transfer)
  @(vif.s_drv_cb iff vif.s_drv_cb.wvalid == 1'b1);
  vif.s_drv_cb.wready <= 1'b1;
  for (int s = 0; s < (mem_wlen[a] + 1); s++) begin
    @(vif.s_drv_cb);
    // TODO: support write strobe
    // slave_mem[addr] = vif.s_drv_cb.wdata;
    wr_req.wdata[s] = vif.s_drv_cb.wdata;
    wr_req.wstrb[s] = vif.s_drv_cb.wstrb;
    if (s == mem_wlen[a]) begin
      mem_wlast[a] = vif.s_drv_cb.wlast;
      wr_req.wlast = vif.s_drv_cb.wlast;
      if (wr_req.wlast == 1'b1) begin
        vif.s_drv_cb.wready <= 1'b0;
        break;
      end
    end
  end
  a++;
endtask

task axi_slave_driver::wr_response(REQ wr_req);
  `uvm_info("S_DRIVER", "Driving B Channel", UVM_MEDIUM)
  @(vif.s_drv_cb);
  vif.s_drv_cb.bid <= mem_awid[wr_idx];
  wr_req.bid = mem_awid[wr_idx];
  //Checks all the conditions satisfied are not to send OKAY RESP
  //1. Resp has to send only wlast is high.
  //2. Size shouldn't more than DBW.
  //3. fifo shouldn't get full.
  if(mem_wlast[wr_idx] == 1 && mem_wsize[wr_idx] <= AXI_DATA_W/OUTSTANDING_FIFO_DEPTH && !axi4_slave_write_addr_fifo_h.is_full()) begin
    vif.s_drv_cb.bresp <= OKAY;
    wr_req.bresp = OKAY;
  end else begin
    vif.s_drv_cb.bresp <= SLVERR;
    wr_req.bresp = SLVERR;
  end
  vif.s_drv_cb.buser  <= wr_req.buser;
  vif.s_drv_cb.bvalid <= 1'b1;
  wr_idx++;
  @(vif.s_drv_cb iff vif.s_drv_cb.bready == 1'b1);
  vif.s_drv_cb.bvalid <= 1'b0;
endtask

task axi_slave_driver::rd_address(REQ rd_req);
  `uvm_info("S_DRIVER", "Waiting AR Channel", UVM_MEDIUM)
  @(vif.s_drv_cb iff vif.s_drv_cb.arvalid == 1'b1);
  mem_arid[j]   = vif.s_drv_cb.arid;
  mem_raddr[j]  = vif.s_drv_cb.araddr;
  mem_rlen[j]   = vif.s_drv_cb.arlen;
  mem_rsize[j]  = vif.s_drv_cb.arsize;
  mem_rburst[j] = vif.s_drv_cb.arburst;
  vif.s_drv_cb.arready <= 1'b1;
  rd_req.op_type = READ;
  rd_req.arid = mem_arid[j];
  rd_req.araddr = mem_raddr[j];
  rd_req.arlen = mem_rlen[j];
  rd_req.arsize = size_e'(mem_rsize[j]);
  rd_req.arburst = burst_e'(mem_rburst[j]);
  j++;
  @(vif.s_drv_cb);
  vif.s_drv_cb.arready <= 1'b0;
endtask

task axi_slave_driver::rd_data_response(REQ rd_req);
  `uvm_info("S_DRIVER", "Driving R Channel", UVM_MEDIUM)

  @(vif.s_drv_cb);
  rd_req.rid = mem_arid[rd_idx];
  // TODO: How to randomize rdata w/o manual assignment?
  for (int i = 0; i < mem_rlen[rd_idx] + 1; i++) begin
    rd_req.rdata[i] = $urandom;
  end

  for (int i1 = 0; i1 < mem_rlen[rd_idx] + 1; i1++) begin
    vif.s_drv_cb.rid   <= mem_arid[rd_idx];
    vif.s_drv_cb.rdata <= rd_req.rdata[i1];
    if (mem_rsize[rd_idx] <= AXI_DATA_W / OUTSTANDING_FIFO_DEPTH) begin
      vif.s_drv_cb.rresp <= rd_req.rresp;
    end else begin
      vif.s_drv_cb.rresp <= SLVERR;
      rd_req.rresp = SLVERR;
    end
    vif.s_drv_cb.ruser  <= rd_req.ruser;
    vif.s_drv_cb.rvalid <= 1'b1;
    if (mem_rlen[rd_idx] == i1) begin
      vif.s_drv_cb.rlast <= 1'b1;
    end else begin
      vif.s_drv_cb.rlast <= 1'b0;
    end

    @(vif.s_drv_cb iff vif.s_drv_cb.rready == 1'b1);
    vif.s_drv_cb.rvalid <= 1'b0;
    vif.s_drv_cb.rlast  <= 1'b0;
  end
  rd_idx++;
endtask


task axi_slave_driver::dummy_write_memory(REQ wr_req);
  wr_req.sa = $clog2(wr_req.awid[AXI_ID_W-1:4]);
  wr_req.da = slave_id;
  `uvm_info("S_DRIVER", {"Dummy Write Memory:\n", wr_req.sprint()}, UVM_MEDIUM)
endtask

task axi_slave_driver::dummy_read_memory(REQ rd_req);
  rd_req.sa = $clog2(rd_req.arid[AXI_ID_W-1:4]);
  rd_req.da = slave_id;
  `uvm_info("S_DRIVER", {"Dummy Read Memory:\n", rd_req.sprint()}, UVM_MEDIUM)
endtask
