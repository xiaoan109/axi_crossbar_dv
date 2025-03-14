class axi_master_driver extends uvm_driver #(axi_m_txn);
  `uvm_component_utils(axi_master_driver)

  // Components
  axi_vif vif;
  int master_id = -1;
  uvm_seq_item_pull_port #(REQ, RSP) wr_seq_item_port;
  uvm_seq_item_pull_port #(REQ, RSP) rd_seq_item_port;

  // Variables
  REQ wr_req;
  REQ rd_req;
  //Declaring handle for uvm_tlm_analysis_fifo for write task
  uvm_tlm_analysis_fifo #(axi_m_txn) axi4_master_write_fifo_h;
  //Variable: axi4_master_write_resp_fifo_h
  //Declaring handle for uvm_tlm_analysis_fifo for write task
  uvm_tlm_analysis_fifo #(axi_m_txn) axi4_master_write_resp_fifo_h;
  //Variable: axi4_master_read_fifo_h
  //Declaring handle for uvm_tlm_analysis_fifo for read task
  uvm_tlm_analysis_fifo #(axi_m_txn) axi4_master_read_fifo_h;
  //Used to assign keys to this semaphore and
  //to take keys from the semaphore
  //Used to block the process from happening until the key is put
  semaphore write_data_channel_key;
  //Used to assign keys to this semaphore and
  //to take keys from the semaphore
  //Used to block the process from happening until the key is put
  semaphore write_response_channel_key;
  //Used to assign keys to this semaphore and
  //to take keys from the semaphore
  //Used to block the process from happening until the key is put
  semaphore read_channel_key;

  // UVM Methods
  extern function new(string name = "axi_master_driver", uvm_component parent = null);
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
endclass

function axi_master_driver::new(string name = "axi_master_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void axi_master_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(axi_vif)::get(this, "", "vif", vif)) begin
    `uvm_fatal("CFGERR", {"virtual interface must be set for: ", get_type_name()});
  end
  if (!uvm_config_db#(int)::get(this, "", "master_id", master_id)) begin
    `uvm_fatal("CFGERR", {"Master ID must be set for: ", get_type_name()});
  end
  wr_seq_item_port              = new("wr_seq_item_port", this);
  rd_seq_item_port              = new("rd_seq_item_port", this);
  axi4_master_write_fifo_h      = new("axi4_master_write_fifo_h", this);
  axi4_master_write_resp_fifo_h = new("axi4_master_write_resp_fifo_h", this);
  axi4_master_read_fifo_h       = new("axi4_master_read_fifo_h", this);
  read_channel_key              = new(1);
  write_data_channel_key        = new(1);
  write_response_channel_key    = new(1);
endfunction

task axi_master_driver::run_phase(uvm_phase phase);
  fork
    reset_signals();
    get_and_drive();
  join_none
endtask

task axi_master_driver::reset_signals();
  fork
    forever begin
      @(negedge vif.aresetn);
      `uvm_info("M_DRIVER", "reset_signals ...", UVM_MEDIUM)
      vif.m_drv_cb.awvalid <= 1'b0;
      vif.m_drv_cb.wvalid  <= 1'b0;
      vif.m_drv_cb.bready  <= 1'b0;
      vif.m_drv_cb.arvalid <= 1'b0;
      vif.m_drv_cb.rready  <= 1'b0;
    end
  join_none
endtask

task axi_master_driver::get_and_drive();
  fork
    forever begin : WRITE_TASK
      wr_seq_item_port.get_next_item(wr_req);
      if (master_id inside {-1, wr_req.sa}) begin
        if (wr_req.transfer_type == BLOCKING_WRITE) begin
          wr_address(wr_req);
          wr_data(wr_req);
          wr_response(wr_req);
        end else if (wr_req.transfer_type == NON_BLOCKING_WRITE) begin
          //Used to control the fork_join process
          //Use Case is fork_join process should wait for write address to complete.
          process write_address_process;
          //Used to control the fork_join process
          process write_data_process;
          //Used to control the fork_join process
          process write_response_process;

          if (!axi4_master_write_fifo_h.is_full()) begin
            axi4_master_write_fifo_h.write(wr_req);
          end else begin
            `uvm_error("M_DRIVER", $sformatf(
                       "WRITE_TASK::Cannot write into FIFO as WRITE_FIFO IS FULL"));
          end

          if (!axi4_master_write_resp_fifo_h.is_full()) begin
            axi4_master_write_resp_fifo_h.write(wr_req);
          end else begin
            `uvm_error("M_DRIVER", $sformatf(
                       "WRITE_TASK::Cannot write into FIFO as WRITE_RESP_FIFO IS FULL"));
          end

          fork
            begin : WRITE_ADDRESS_CHANNEL
              write_address_process = process::self();
              wr_address(wr_req);
            end

            begin : WRITE_DATA_CHANNEL
              REQ local_master_data_tx;
              write_data_process = process::self();
              write_data_channel_key.get(1);
              if (!axi4_master_write_fifo_h.is_empty()) begin
                axi4_master_write_fifo_h.get(local_master_data_tx);
              end else begin
                `uvm_error("M_DRIVER", $sformatf(
                           "WRITE_DATA_THREAD::Cannot peek into FIFO as WRITE_FIFO IS EMPTY"));
              end
              wr_data(local_master_data_tx);
              write_data_channel_key.put(1);
            end

            begin : WRITE_RESPONSE_CHANNEL
              REQ local_master_response_tx;
              write_response_process = process::self();
              write_response_channel_key.get(1);
              if (!axi4_master_write_resp_fifo_h.is_empty()) begin
                axi4_master_write_resp_fifo_h.get(local_master_response_tx);
              end else begin
                `uvm_error("M_DRIVER", $sformatf(
                           "WRITE_RESPONSE_THREAD::Cannot peek into FIFO as WRITE_FIFO IS EMPTY"));
              end
              wr_response(local_master_response_tx);
              write_response_channel_key.put(1);
            end
          join_any
          //Waiting for write address channel to complete
          //As we don't have control on fork-join_any or fork-join_none processes,
          //the await method makes sure that it waits for the write address to complete
          write_address_process.await();
        end
      end
      wr_seq_item_port.item_done();
    end
    forever begin : READ_TASK
      rd_seq_item_port.get_next_item(rd_req);
      if (master_id inside {-1, rd_req.sa}) begin
        if (!axi4_master_read_fifo_h.is_full()) begin
          axi4_master_read_fifo_h.write(rd_req);
        end else begin
          `uvm_error("M_DRIVER", $sformatf("READ_TASK::Cannot write into FIFO as READ_FIFO IS FULL"
                     ));
        end
        if (rd_req.transfer_type == BLOCKING_READ) begin
          rd_address(rd_req);
          rd_data_response(rd_req);
        end else if (rd_req.transfer_type == NON_BLOCKING_READ) begin
          //Used to control the fork_join process
          //Use Case is fork_join process should wait for read address to complete.
          process read_address_process;
          //Used to control he fork_join process
          process read_data_process;
          fork
            begin : READ_ADDRESS_CHANNEL
              read_address_process = process::self();
              rd_address(rd_req);
            end

            begin : READ_DATA_CHANNEL
              REQ local_master_data_tx;
              read_data_process = process::self();
              read_channel_key.get(1);
              if (!axi4_master_read_fifo_h.is_empty()) begin
                axi4_master_read_fifo_h.get(local_master_data_tx);
              end else begin
                `uvm_error("M_DRIVER", $sformatf(
                           "READ_DATA_THREAD::Cannot read from read fifo, as it is empty"));
              end
              rd_data_response(local_master_data_tx);
              read_channel_key.put(1);
            end
          join_any
          //Waiting for read address channel to complete
          //As we don't have control on fork-join_any or fork-join_none processes,
          //the await method makes sure that it waits for the read address to complete
          read_address_process.await();
        end
      end
      rd_seq_item_port.item_done();
    end
  join
endtask


task axi_master_driver::wr_address(REQ wr_req);
  `uvm_info("M_DRIVER", "Driving AW Channel", UVM_MEDIUM)
  @(vif.m_drv_cb);
  vif.m_drv_cb.awvalid <= 1'b1;
  vif.m_drv_cb.awaddr <= wr_req.awaddr;
  vif.m_drv_cb.awlen <= wr_req.awlen;
  vif.m_drv_cb.awsize <= wr_req.awsize;
  vif.m_drv_cb.awburst <= wr_req.awburst;
  vif.m_drv_cb.awlock <= wr_req.awlock;
  vif.m_drv_cb.awcache <= wr_req.awcache;
  vif.m_drv_cb.awprot <= wr_req.awprot;
  vif.m_drv_cb.awqos <= wr_req.awqos;
  vif.m_drv_cb.awregion <= wr_req.awregion;
  vif.m_drv_cb.awid <= wr_req.awid;
  vif.m_drv_cb.awuser <= wr_req.awuser;
  @(vif.m_drv_cb iff vif.m_drv_cb.awready == 1'b1);
  vif.m_drv_cb.awvalid <= 1'b0;
endtask

task axi_master_driver::wr_data(REQ wr_req);
  `uvm_info("M_DRIVER", "Driving W Channel", UVM_MEDIUM)
  @(vif.m_drv_cb);
  for (int i = 0; i < wr_req.awlen + 1; i++) begin
    vif.m_drv_cb.wvalid <= 1'b1;
    vif.m_drv_cb.wdata  <= wr_req.wdata[i];
    vif.m_drv_cb.wstrb  <= wr_req.wstrb[i];
    vif.m_drv_cb.wuser  <= wr_req.wuser;
    vif.m_drv_cb.wlast  <= (i == wr_req.awlen) ? 1'b1 : 1'b0;
    @(vif.m_drv_cb iff vif.m_drv_cb.wready == 1'b1);
    vif.m_drv_cb.wvalid <= 1'b0;
    vif.m_drv_cb.wlast  <= 1'b0;
  end
endtask

task axi_master_driver::wr_response(REQ wr_req);
  `uvm_info("M_DRIVER", "Waiting B Channel", UVM_MEDIUM)
  @(vif.m_drv_cb iff vif.m_drv_cb.bvalid == 1'b1);
  vif.m_drv_cb.bready <= 1'b1;
  wr_req.bresp = response_e'(vif.m_drv_cb.bresp);
  wr_req.bid   = vif.m_drv_cb.bid;
  wr_req.buser = vif.m_drv_cb.buser;
  @(vif.m_drv_cb);
  vif.m_drv_cb.bready <= 1'b0;
endtask

task axi_master_driver::rd_address(REQ rd_req);
  `uvm_info("M_DRIVER", "Driving AR Channel", UVM_MEDIUM)
  @(vif.m_drv_cb);
  vif.m_drv_cb.arvalid <= 1'b1;
  vif.m_drv_cb.araddr <= rd_req.araddr;
  vif.m_drv_cb.arlen <= rd_req.arlen;
  vif.m_drv_cb.arsize <= rd_req.arsize;
  vif.m_drv_cb.arburst <= rd_req.arburst;
  vif.m_drv_cb.arlock <= rd_req.arlock;
  vif.m_drv_cb.arcache <= rd_req.arcache;
  vif.m_drv_cb.arprot <= rd_req.arprot;
  vif.m_drv_cb.arqos <= rd_req.arqos;
  vif.m_drv_cb.arregion <= rd_req.arregion;
  vif.m_drv_cb.arid <= rd_req.arid;
  vif.m_drv_cb.aruser <= rd_req.aruser;
  @(vif.m_drv_cb iff vif.m_drv_cb.arready == 1'b1);
  vif.m_drv_cb.arvalid <= 1'b0;
endtask

task axi_master_driver::rd_data_response(REQ rd_req);
  static reg [7:0] i;
  `uvm_info("M_DRIVER", "Waiting R Channel", UVM_MEDIUM)
  @(vif.m_drv_cb iff vif.m_drv_cb.rvalid == 1'b1);
  vif.m_drv_cb.rready <= 1'b1;
  forever begin
    @(vif.m_drv_cb iff vif.m_drv_cb.rvalid == 1'b1);
    rd_req.rid = vif.m_drv_cb.rid;
    rd_req.rdata[i] = vif.m_drv_cb.rdata;
    rd_req.rresp = response_e'(vif.rresp);  // TODO: multiple responses ?
    rd_req.ruser = vif.m_drv_cb.ruser;
    i++;
    if (vif.m_drv_cb.rlast == 1) begin
      i = 0;
      vif.m_drv_cb.rready <= 1'b0;
      break;
    end
  end
endtask





