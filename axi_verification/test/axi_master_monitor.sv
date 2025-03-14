class axi_master_monitor extends uvm_monitor;
  `uvm_component_utils(axi_master_monitor)

  // Components
  axi_vif vif;
  int master_id = -1;
  axi_m_txn wr_trans;
  axi_m_txn rd_trans;
  uvm_event reset_event = uvm_event_pool::get_global("reset");
  // Declaring analysis port for the monitor port
  uvm_analysis_port #(axi_m_txn) axi4_master_read_address_analysis_port;
  uvm_analysis_port #(axi_m_txn) axi4_master_read_data_analysis_port;
  uvm_analysis_port #(axi_m_txn) axi4_master_write_address_analysis_port;
  uvm_analysis_port #(axi_m_txn) axi4_master_write_data_analysis_port;
  uvm_analysis_port #(axi_m_txn) axi4_master_write_response_analysis_port;
  //Declaring handle for uvm_tlm_analysis_fifo for write task
  uvm_tlm_analysis_fifo #(axi_m_txn) axi4_master_write_address_fifo_h;
  //Declaring handle for uvm_tlm_analysis_fifo for write task
  uvm_tlm_analysis_fifo #(axi_m_txn) axi4_master_write_data_fifo_h;
  //Declaring handle for uvm_tlm_analysis_fifo for read task
  uvm_tlm_analysis_fifo #(axi_m_txn) axi4_master_read_fifo_h;

  // Queue for storing the transactions when response ID does not match address ID
  axi_m_txn write_addr_data_buffer[$];
  axi_m_txn write_response_buffer[$];
  axi_m_txn read_addr_buffer[$];
  axi_m_txn read_data_response_buffer[$];

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
  axi4_master_read_address_analysis_port   = new("axi4_master_read_address_analysis_port", this);
  axi4_master_read_data_analysis_port      = new("axi4_master_read_data_analysis_port", this);
  axi4_master_write_address_analysis_port  = new("axi4_master_write_address_analysis_port", this);
  axi4_master_write_data_analysis_port     = new("axi4_master_write_data_analysis_port", this);
  axi4_master_write_response_analysis_port = new("axi4_master_write_response_analysis_port", this);
  axi4_master_write_address_fifo_h         = new("axi4_master_write_address_fifo_h", this);
  axi4_master_write_data_fifo_h            = new("axi4_master_write_data_fifo_h", this);
  axi4_master_read_fifo_h                  = new("axi4_master_read_fifo_h", this);
endfunction

task axi_master_monitor::run_phase(uvm_phase phase);
  fork
    detect_reset();
    wr_address_mon();
    wr_data_mon();
    wr_response_mon();
    rd_address_mon();
    rd_data_response_mon();
  join
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
    axi_m_txn wr_trans_clone;
    local_wr_addr_trans = axi_m_txn::type_id::create("local_wr_addr_trans");
    @(vif.m_mon_cb iff vif.m_mon_cb.awvalid == 1'b1 && vif.m_mon_cb.awready == 1'b1);
    local_wr_addr_trans.op_type = WRITE;
    local_wr_addr_trans.transfer_type = transfer_type_e'(vif.m_mon_cb.awuser); // user signal to indicate transfer type
    local_wr_addr_trans.awaddr = vif.m_mon_cb.awaddr;
    local_wr_addr_trans.awsize = size_e'(vif.m_mon_cb.awsize);
    local_wr_addr_trans.awlen = vif.m_mon_cb.awlen;
    local_wr_addr_trans.awburst = burst_e'(vif.m_mon_cb.awburst);
    local_wr_addr_trans.awid = vif.m_mon_cb.awid;
    local_wr_addr_trans.awlock = lock_e'(vif.m_mon_cb.awlock);
    local_wr_addr_trans.awcache = cache_e'(vif.m_mon_cb.awcache);
    local_wr_addr_trans.awprot = prot_e'(vif.m_mon_cb.awprot);
    local_wr_addr_trans.awqos = vif.m_mon_cb.awqos;
    local_wr_addr_trans.awregion = vif.m_mon_cb.awregion;
    local_wr_addr_trans.awuser = vif.m_mon_cb.awuser;
    local_wr_addr_trans.sa = master_id;
    local_wr_addr_trans.da = vif.m_mon_cb.awaddr[AXI_ADDR_W-1:AXI_ADDR_W-2]; // TODO: check if this is correct
    $cast(wr_trans, local_wr_addr_trans.clone());
    axi4_master_write_address_fifo_h.write(wr_trans);
    $cast(wr_trans_clone, wr_trans.clone());
    axi4_master_write_address_analysis_port.write(wr_trans_clone);
  end
endtask

task axi_master_monitor::wr_data_mon();
  forever begin
    axi_m_txn local_wr_addr_trans;
    axi_m_txn local_wr_data_trans;
    axi_m_txn wr_trans_clone;
    local_wr_addr_trans = axi_m_txn::type_id::create("local_wr_addr_trans");
    local_wr_data_trans = axi_m_txn::type_id::create("local_wr_data_trans");
    begin
      int i = 0;
      forever begin
        @(vif.m_mon_cb iff vif.m_mon_cb.wvalid == 1'b1 && vif.m_mon_cb.wready == 1'b1);
        // TODO : wstrb
        local_wr_data_trans.wstrb[i] = vif.m_mon_cb.wstrb;
        local_wr_data_trans.wdata[i] = vif.m_mon_cb.wdata;
        local_wr_data_trans.wuser = vif.m_mon_cb.wuser;
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
    $cast(wr_trans_clone, wr_trans.clone());
    axi4_master_write_data_analysis_port.write(wr_trans_clone);
  end
endtask

task axi_master_monitor::wr_response_mon();
  forever begin
    axi_m_txn local_wr_addr_data_trans;
    axi_m_txn local_wr_response_trans;
    axi_m_txn wr_trans_clone;
    int loop_count;
    int i;
    bit [AXI_ID_W-1:0] id_before_reorder[$];
    bit [AXI_ID_W-1:0] id_after_reorder[$];
    local_wr_addr_data_trans = axi_m_txn::type_id::create("local_wr_addr_data_trans");
    local_wr_response_trans  = axi_m_txn::type_id::create("local_wr_response_trans");
    @(vif.m_mon_cb iff vif.m_mon_cb.bvalid == 1'b1 && vif.m_mon_cb.bready == 1'b1);
    local_wr_response_trans.bresp = response_e'(vif.m_mon_cb.bresp);
    local_wr_response_trans.bid   = vif.m_mon_cb.bid;
    local_wr_response_trans.buser = vif.m_mon_cb.buser;
    axi4_master_write_data_fifo_h.get(local_wr_addr_data_trans);

    // TODO: this only works for out of order transactions in certain case, i.e. (ID: 0x21, 0x22, 0x20)
    // currently dose not support case like (ID: 0x22, 0x20, 0x21)
    // add line 220, may work well now
    if (local_wr_response_trans.bid != local_wr_addr_data_trans.awid) begin
      `uvm_error("M_MONITOR", "Write response ID does not match write address ID")
      `uvm_info("DEBUG_QUEUE",
                $sformatf("write_addr_data_buffer.size() = %0d, write_response_buffer.size() = %0d",
                          write_addr_data_buffer.size(), write_response_buffer.size()), UVM_HIGH)
      if (write_addr_data_buffer.size() > 0) begin
        if (write_addr_data_buffer[0].awid == local_wr_response_trans.bid) begin
          foreach (write_response_buffer[i]) begin
            id_before_reorder.push_back(write_response_buffer[i].bid);
          end
          id_before_reorder.push_back(local_wr_response_trans.bid);
          foreach (write_addr_data_buffer[i]) begin
            id_after_reorder.push_back(write_addr_data_buffer[i].awid);
          end
          id_after_reorder.push_back(local_wr_addr_data_trans.awid);
          `uvm_info("DEBUG_OOO", $sformatf("Write ID before reorder: %0p", id_before_reorder),
                    UVM_HIGH)
          `uvm_info("DEBUG_OOO", $sformatf("Write ID after reorder: %0p", id_after_reorder),
                    UVM_HIGH)
          // Earliest ID
          $cast(wr_trans, write_addr_data_buffer.pop_front().clone());
          wr_trans.bresp = local_wr_response_trans.bresp;
          wr_trans.bid   = local_wr_response_trans.bid;
          wr_trans.buser = local_wr_response_trans.buser;
          `uvm_info("M_MONITOR", {"collected write transaction:\n", wr_trans.sprint()}, UVM_MEDIUM)
          $cast(wr_trans_clone, wr_trans.clone());
          axi4_master_write_response_analysis_port.write(wr_trans_clone);

          // Pending ID
          loop_count = write_response_buffer.size();
          i = 0;
          repeat (loop_count) begin
            int idx[$];
            if (i == loop_count - 1) begin
              idx = write_response_buffer.find_index() with (item.bid == local_wr_addr_data_trans.awid);
            end else begin
              idx = write_response_buffer.find_index() with (item.bid == write_addr_data_buffer[0].awid);
            end
            if (idx.size() > 0) begin
              if (i == loop_count - 1) begin
                $cast(wr_trans, local_wr_addr_data_trans.clone());
              end else begin
                $cast(wr_trans, write_addr_data_buffer.pop_front().clone());
              end
              wr_trans.bresp = write_response_buffer[idx[0]].bresp;
              wr_trans.bid   = write_response_buffer[idx[0]].bid;
              wr_trans.buser = write_response_buffer[idx[0]].buser;
              write_response_buffer.delete(idx[0]);
              `uvm_info("M_MONITOR", {"collected write transaction:\n", wr_trans.sprint()},
                        UVM_MEDIUM)
              $cast(wr_trans_clone, wr_trans.clone());
              axi4_master_write_response_analysis_port.write(wr_trans_clone);
            end else begin
              write_addr_data_buffer.push_back(local_wr_addr_data_trans);
            end
            i++;
          end
        end else begin
          write_addr_data_buffer.push_back(local_wr_addr_data_trans);
          write_response_buffer.push_back(local_wr_response_trans);
        end
      end else begin
        write_addr_data_buffer.push_back(local_wr_addr_data_trans);
        write_response_buffer.push_back(local_wr_response_trans);
      end
    end else begin
      $cast(wr_trans, local_wr_addr_data_trans.clone());
      wr_trans.bresp = local_wr_response_trans.bresp;
      wr_trans.bid   = local_wr_response_trans.bid;
      wr_trans.buser = local_wr_response_trans.buser;
      `uvm_info("M_MONITOR", {"collected write transaction:\n", wr_trans.sprint()}, UVM_MEDIUM)
      $cast(wr_trans_clone, wr_trans.clone());
      axi4_master_write_response_analysis_port.write(wr_trans_clone);
    end
  end
endtask

task axi_master_monitor::rd_address_mon();
  forever begin
    axi_m_txn local_rd_addr_trans;
    axi_m_txn rd_trans_clone;
    local_rd_addr_trans = axi_m_txn::type_id::create("local_rd_addr_trans");
    @(vif.m_mon_cb iff vif.m_mon_cb.arvalid == 1'b1 && vif.m_mon_cb.arready == 1'b1);
    local_rd_addr_trans.op_type = READ;
    local_rd_addr_trans.transfer_type = transfer_type_e'(vif.m_mon_cb.aruser); // user signal to indicate transfer type
    local_rd_addr_trans.araddr = vif.m_mon_cb.araddr;
    local_rd_addr_trans.arsize = size_e'(vif.m_mon_cb.arsize);
    local_rd_addr_trans.arlen = vif.m_mon_cb.arlen;
    local_rd_addr_trans.arburst = burst_e'(vif.m_mon_cb.arburst);
    local_rd_addr_trans.arid = vif.m_mon_cb.arid;
    local_rd_addr_trans.arlock = lock_e'(vif.m_mon_cb.arlock);
    local_rd_addr_trans.arcache = cache_e'(vif.m_mon_cb.arcache);
    local_rd_addr_trans.arprot = prot_e'(vif.m_mon_cb.arprot);
    local_rd_addr_trans.arqos = vif.m_mon_cb.arqos;
    local_rd_addr_trans.arregion = vif.m_mon_cb.arregion;
    local_rd_addr_trans.aruser = vif.m_mon_cb.aruser;
    local_rd_addr_trans.sa = master_id;
    local_rd_addr_trans.da = vif.m_mon_cb.araddr[AXI_ADDR_W-1:AXI_ADDR_W-2]; // TODO: check if this is correct
    $cast(rd_trans, local_rd_addr_trans.clone());
    axi4_master_read_fifo_h.write(rd_trans);
    $cast(rd_trans_clone, rd_trans.clone());
    axi4_master_read_address_analysis_port.write(rd_trans_clone);
  end
endtask

task axi_master_monitor::rd_data_response_mon();
  forever begin
    axi_m_txn local_rd_addr_trans;
    axi_m_txn local_rd_data_trans;
    axi_m_txn rd_trans_clone;
    int loop_count;
    int j;
    bit [AXI_ID_W-1:0] id_before_reorder[$];
    bit [AXI_ID_W-1:0] id_after_reorder[$];
    local_rd_addr_trans = axi_m_txn::type_id::create("local_rd_addr_trans");
    local_rd_data_trans = axi_m_txn::type_id::create("local_rd_data_trans");
    begin
      int i = 0;
      forever begin
        @(vif.m_mon_cb iff vif.m_mon_cb.rvalid == 1'b1 && vif.m_mon_cb.rready == 1'b1);
        local_rd_data_trans.rdata[i] = vif.m_mon_cb.rdata;
        local_rd_data_trans.rresp = response_e'(vif.m_mon_cb.rresp);  // TODO: multiple responses?
        local_rd_data_trans.rid = vif.m_mon_cb.rid;
        local_rd_data_trans.ruser = vif.m_mon_cb.ruser;
        local_rd_data_trans.rlast = vif.m_mon_cb.rlast;
        if (local_rd_data_trans.rlast == 1) begin
          i = 0;
          break;
        end
        i++;
      end
      axi4_master_read_fifo_h.get(local_rd_addr_trans);

      if (local_rd_data_trans.rid != local_rd_addr_trans.arid) begin
        `uvm_error("M_MONITOR", "Read response ID does not match read address ID")
        `uvm_info("DEBUG_QUEUE",
                  $sformatf("read_addr_buffer.size() = %0d, read_data_response_buffer.size() = %0d",
                            read_addr_buffer.size(), read_data_response_buffer.size()), UVM_HIGH)
        if (read_addr_buffer.size() > 0) begin
          if (read_addr_buffer[0].arid == local_rd_data_trans.rid) begin
            foreach (read_data_response_buffer[k]) begin
              id_before_reorder.push_back(read_data_response_buffer[k].rid);
            end
            id_before_reorder.push_back(local_rd_data_trans.rid);
            foreach (read_addr_buffer[k]) begin
              id_after_reorder.push_back(read_addr_buffer[k].arid);
            end
            id_after_reorder.push_back(local_rd_addr_trans.arid);

            `uvm_info("DEBUG_OOO", $sformatf("Read ID before reorder: %0p", id_before_reorder),
                      UVM_HIGH)
            `uvm_info("DEBUG_OOO", $sformatf("Read ID after reorder: %0p", id_after_reorder),
                      UVM_HIGH)
            // Earliest ID
            $cast(rd_trans, read_addr_buffer.pop_front().clone());
            rd_trans.rdata = local_rd_data_trans.rdata;
            rd_trans.rresp = local_rd_data_trans.rresp;
            rd_trans.rid   = local_rd_data_trans.rid;
            rd_trans.ruser = local_rd_data_trans.ruser;
            `uvm_info("M_MONITOR", {"collected read transaction:\n", rd_trans.sprint()}, UVM_MEDIUM)
            $cast(rd_trans_clone, rd_trans.clone());
            axi4_master_read_data_analysis_port.write(rd_trans_clone);

            // Pending ID
            loop_count = read_data_response_buffer.size();
            j = 0;
            repeat (loop_count) begin
              int idx[$];
              if (j == loop_count - 1) begin
                idx = read_data_response_buffer.find_index() with (item.rid == local_rd_addr_trans.arid);
              end else begin
                idx = read_data_response_buffer.find_index() with (item.rid == read_addr_buffer[0].arid);
              end
              if (idx.size() > 0) begin
                if (i == loop_count - 1) begin
                  $cast(rd_trans, local_rd_addr_trans.clone());
                end else begin
                  $cast(rd_trans, read_addr_buffer.pop_front().clone());
                end
                rd_trans.rdata = read_data_response_buffer[idx[0]].rdata;
                rd_trans.rresp = read_data_response_buffer[idx[0]].rresp;
                rd_trans.rid   = read_data_response_buffer[idx[0]].rid;
                rd_trans.buser = read_data_response_buffer[idx[0]].ruser;
                read_data_response_buffer.delete(idx[0]);
                `uvm_info("M_MONITOR", {"collected read transaction:\n", rd_trans.sprint()},
                          UVM_MEDIUM)
                $cast(rd_trans_clone, rd_trans.clone());
                axi4_master_read_data_analysis_port.write(rd_trans_clone);
              end else begin
                read_addr_buffer.push_back(local_rd_addr_trans);
              end
              j++;
            end
          end else begin
            read_addr_buffer.push_back(local_rd_addr_trans);
            read_data_response_buffer.push_back(local_rd_data_trans);
          end
        end else begin
          read_addr_buffer.push_back(local_rd_addr_trans);
          read_data_response_buffer.push_back(local_rd_data_trans);
        end
      end else begin
        $cast(rd_trans, local_rd_addr_trans.clone());
        rd_trans.rdata = local_rd_data_trans.rdata;
        rd_trans.rresp = local_rd_data_trans.rresp;
        rd_trans.rid   = local_rd_data_trans.rid;
        rd_trans.ruser = local_rd_data_trans.ruser;
        `uvm_info("M_MONITOR", {"collected read transaction:\n", rd_trans.sprint()}, UVM_MEDIUM)
        $cast(rd_trans_clone, rd_trans.clone());
        axi4_master_read_data_analysis_port.write(rd_trans_clone);
      end
    end
  end
endtask

