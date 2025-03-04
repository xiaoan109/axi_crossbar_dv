// AXI multistream scoreboard
class axi_ms_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_ms_scoreboard)
  `uvm_analysis_imp_decl(_before)
  `uvm_analysis_imp_decl(_after)

  // Components
  uvm_analysis_imp_before #(axi_m_txn, axi_ms_scoreboard) ms_before_export;
  uvm_analysis_imp_after #(axi_s_txn, axi_ms_scoreboard) ms_after_export;
  uvm_in_order_class_comparator #(axi_s_txn) wr_comparator[4];  // 4 slave agents
  uvm_in_order_class_comparator #(axi_s_txn) rd_comparator[4];  // 4 slave agents

  // Variables
  int count = 0;
  realtime timeout = 10us;

  extern function new(string name = "axi_ms_scoreboard", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void write_before(axi_m_txn txn);
  extern virtual function void write_after(axi_s_txn txn);
  extern virtual task wait_for_done();
  extern virtual function void set_timeout(realtime t);
  extern virtual function realtime get_timeout();
  extern virtual function string convert2string();
  extern virtual function int get_matches();
  extern virtual function int get_mismatches();
endclass

function axi_ms_scoreboard::new(string name = "axi_ms_scoreboard", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void axi_ms_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
  ms_before_export = new("ms_before_export", this);
  ms_after_export  = new("ms_after_export", this);
  foreach (wr_comparator[i]) begin
    wr_comparator[i] = uvm_in_order_class_comparator#(axi_s_txn)::type_id::create(
        $sformatf("wr_comparator_%0d", i), this);
  end
  foreach (rd_comparator[i]) begin
    rd_comparator[i] = uvm_in_order_class_comparator#(axi_s_txn)::type_id::create(
        $sformatf("rd_comparator_%0d", i), this);
  end
endfunction

function void axi_ms_scoreboard::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction

function void axi_ms_scoreboard::write_before(axi_m_txn txn);
  axi_s_txn s_txn;
  s_txn          = axi_s_txn::type_id::create("s_txn", this);
  // Can not copy directly because of the different types
  //WRITE ADDRESS CHANNEL
  s_txn.awid     = txn.awid;
  s_txn.awaddr   = txn.awaddr;
  s_txn.awlen    = txn.awlen;
  s_txn.awsize   = txn.awsize;
  s_txn.awburst  = txn.awburst;
  s_txn.awlock   = txn.awlock;
  s_txn.awcache  = txn.awcache;
  s_txn.awprot   = txn.awprot;
  s_txn.awqos    = txn.awqos;
  //WRITE DATA CHANNEL
  s_txn.wdata    = txn.wdata;
  s_txn.wstrb    = txn.wstrb;
  //WRITE RESPONSE CHANNEL
  s_txn.bid      = txn.bid;
  s_txn.bresp    = txn.bresp;
  //READ ADDRESS CHANNEL
  s_txn.arid     = txn.arid;
  s_txn.araddr   = txn.araddr;
  s_txn.arlen    = txn.arlen;
  s_txn.arsize   = txn.arsize;
  s_txn.arburst  = txn.arburst;
  s_txn.arlock   = txn.arlock;
  s_txn.arcache  = txn.arcache;
  s_txn.arprot   = txn.arprot;
  s_txn.arqos    = txn.arqos;
  s_txn.arregion = txn.arregion;
  //READ DATA CHANNEL
  s_txn.rid      = txn.rid;
  s_txn.rdata    = txn.rdata;
  s_txn.rresp    = txn.rresp;
  //OTHERS
  s_txn.op_type  = txn.op_type;
  s_txn.sa       = txn.sa;
  s_txn.da       = txn.da;
  if (s_txn.op_type == WRITE) begin
    wr_comparator[s_txn.da].before_export.write(s_txn);
  end else begin
    rd_comparator[s_txn.da].before_export.write(s_txn);
  end
  count++;
endfunction

function void axi_ms_scoreboard::write_after(axi_s_txn txn);
  if (txn.op_type == WRITE) begin
    wr_comparator[txn.da].after_export.write(txn);
  end else begin
    rd_comparator[txn.da].after_export.write(txn);
  end
  count--;
endfunction

task axi_ms_scoreboard::wait_for_done();
  fork
    begin
      fork
        wait (count == 0);
        begin
          #timeout;
          `uvm_warning("TIMEOUT", $sformatf("Scoreboard has %0d unprocessed expected objects", count
                       ))
        end
      join_any
      disable fork;
    end
  join
endtask

function void axi_ms_scoreboard::set_timeout(realtime t);
  timeout = t;
endfunction

function realtime axi_ms_scoreboard::get_timeout();
  return timeout;
endfunction

function string axi_ms_scoreboard::convert2string();
  foreach (wr_comparator[i]) begin
    convert2string = {
      convert2string,
      $sformatf(
          "Write Comparator[%0d] Matches =  %0d, Mismatches = %0d\n",
          i,
          wr_comparator[i].m_matches,
          wr_comparator[i].m_mismatches
      )
    };
  end
  foreach (rd_comparator[i]) begin
    convert2string = {
      convert2string,
      $sformatf(
          "Read Comparator[%0d] Matches =  %0d, Mismatches = %0d\n",
          i,
          rd_comparator[i].m_matches,
          rd_comparator[i].m_mismatches
      )
    };
  end
endfunction

function int axi_ms_scoreboard::get_matches();
  int total_matches = 0;
  foreach (wr_comparator[i]) begin
    total_matches += wr_comparator[i].m_matches;
  end
  foreach (rd_comparator[i]) begin
    total_matches += rd_comparator[i].m_matches;
  end
  return total_matches;
endfunction

function int axi_ms_scoreboard::get_mismatches();
  int total_mismatches = 0;
  foreach (wr_comparator[i]) begin
    total_mismatches += wr_comparator[i].m_mismatches;
  end
  foreach (rd_comparator[i]) begin
    total_mismatches += rd_comparator[i].m_mismatches;
  end
  return total_mismatches;
endfunction


