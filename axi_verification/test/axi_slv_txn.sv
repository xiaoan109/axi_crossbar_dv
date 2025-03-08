class axi_slv_txn #(
    int AXI_DATA_W = 8,
    int AXI_ADDR_W = 8,
    int AXI_ID_W   = 8,
    int AXI_USER_W = 8
) extends uvm_sequence_item;

  typedef axi_slv_txn#(AXI_DATA_W, AXI_ADDR_W, AXI_ID_W) this_type_t;
  `uvm_object_param_utils(this_type_t)

  rand tx_type_e                     op_type;
  // Write transaction
  bit             [  AXI_ADDR_W-1:0] awaddr;
  size_e                             awsize;
  bit             [             7:0] awlen;
  burst_e                            awburst;
  bit             [    AXI_ID_W-1:0] awid;
  lock_e                             awlock;
  cache_e                            awcache;
  prot_e                             awprot;
  bit             [             3:0] awqos;
  bit             [             3:0] awregion;
  bit             [  AXI_USER_W-1:0] awuser;
  bit             [  AXI_DATA_W-1:0] wdata    [$:1<<8];
  bit             [AXI_DATA_W/8-1:0] wstrb    [$:1<<8];
  bit             [  AXI_USER_W-1:0] wuser;
  bit                                wlast;
  rand response_e                    bresp;
  rand bit        [    AXI_ID_W-1:0] bid;
  rand bit        [  AXI_USER_W-1:0] buser;
  // Read transaction
  bit             [  AXI_ADDR_W-1:0] araddr;
  size_e                             arsize;
  bit             [             7:0] arlen;
  burst_e                            arburst;
  bit             [    AXI_ID_W-1:0] arid;
  lock_e                             arlock;
  cache_e                            arcache;
  prot_e                             arprot;
  bit             [             3:0] arqos;
  bit             [             3:0] arregion;
  bit             [  AXI_USER_W-1:0] aruser;
  rand bit        [  AXI_DATA_W-1:0] rdata    [$:1<<8];
  rand bit        [    AXI_ID_W-1:0] rid;
  rand response_e                    rresp;
  rand bit        [  AXI_USER_W-1:0] ruser;
  bit                                rlast;

  // bit rvalid;

  // crossbar needed
  rand bit        [             1:0] sa;
  rand bit        [             1:0] da;

  //Constraint : rdata_val_c
  //Adding constraint to restrict the read data based on awlength
  constraint rdata_val_c {
    rdata.size() == arlen + 1;
    rdata.size() != 0;
  }

  //Constraint : rresp_val_c
  //Adding constraint to select the type of read response
  constraint rresp_val_c {soft rresp == OKAY;}

  // crossbar
  constraint sa_val_c {sa inside {[0 : 3]};}

  constraint da_val_c {da inside {[0 : 3]};}

  extern function new(string name = "axi_slv_txn");
  extern function void do_copy(uvm_object rhs);
  extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function string convert2string();
endclass

function axi_slv_txn::new(string name = "axi_slv_txn");
  super.new(name);
endfunction

function void axi_slv_txn::do_copy(uvm_object rhs);
  this_type_t axi_slave_tx_copy_obj;

  if (!$cast(axi_slave_tx_copy_obj, rhs)) begin
    `uvm_fatal("do_copy", "cast of the rhs object failed")
  end

  super.do_copy(rhs);
  //WRITE ADDRESS CHANNEL
  awaddr   = axi_slave_tx_copy_obj.awaddr;
  awid     = axi_slave_tx_copy_obj.awid;
  awlen    = axi_slave_tx_copy_obj.awlen;
  awsize   = axi_slave_tx_copy_obj.awsize;
  awburst  = axi_slave_tx_copy_obj.awburst;
  awlock   = axi_slave_tx_copy_obj.awlock;
  awcache  = axi_slave_tx_copy_obj.awcache;
  awqos    = axi_slave_tx_copy_obj.awqos;
  awprot   = axi_slave_tx_copy_obj.awprot;
  awregion = axi_slave_tx_copy_obj.awregion;
  //WRITE DATA CHANNEL
  wdata    = axi_slave_tx_copy_obj.wdata;
  wstrb    = axi_slave_tx_copy_obj.wstrb;
  //WRITE RESPONSE CHANNEL
  bid      = axi_slave_tx_copy_obj.bid;
  bresp    = axi_slave_tx_copy_obj.bresp;
  //READ ADDRESS CHANNEL
  araddr   = axi_slave_tx_copy_obj.araddr;
  arid     = axi_slave_tx_copy_obj.arid;
  arlen    = axi_slave_tx_copy_obj.arlen;
  arsize   = axi_slave_tx_copy_obj.arsize;
  arburst  = axi_slave_tx_copy_obj.arburst;
  arregion = axi_slave_tx_copy_obj.arregion;
  arlock   = axi_slave_tx_copy_obj.arlock;
  arcache  = axi_slave_tx_copy_obj.arcache;
  arqos    = axi_slave_tx_copy_obj.arqos;
  arprot   = axi_slave_tx_copy_obj.arprot;
  arregion = axi_slave_tx_copy_obj.arregion;
  //READ DATA CHANNEL
  rid      = axi_slave_tx_copy_obj.rid;
  rdata    = axi_slave_tx_copy_obj.rdata;
  rresp    = axi_slave_tx_copy_obj.rresp;
  //OTHERS
  op_type  = axi_slave_tx_copy_obj.op_type;
  sa       = axi_slave_tx_copy_obj.sa;
  da       = axi_slave_tx_copy_obj.da;
endfunction

function bit axi_slv_txn::do_compare(uvm_object rhs, uvm_comparer comparer);
  this_type_t axi_slave_tx_compare_obj;

  if (!$cast(axi_slave_tx_compare_obj, rhs)) begin
    `uvm_fatal("FATAL_axi_SLAVE_TX_DO_COMPARE_FAILED", "cast of the rhs object failed")
    return 0;
  end

  return super.do_compare(
      axi_slave_tx_compare_obj, comparer
  ) &&
  //WRITE ADDRESS CHANNEL
  awaddr  == axi_slave_tx_compare_obj.awaddr  &&
  awid    == axi_slave_tx_compare_obj.awid    &&
  awlen   == axi_slave_tx_compare_obj.awlen   &&
  awsize  == axi_slave_tx_compare_obj.awsize  &&
  awburst == axi_slave_tx_compare_obj.awburst &&
  awlock  == axi_slave_tx_compare_obj.awlock  &&
  awcache == axi_slave_tx_compare_obj.awcache &&
  awqos   == axi_slave_tx_compare_obj.awqos   &&
  awprot  == axi_slave_tx_compare_obj.awprot  &&
  //WRITE DATA CHANNEL
  wdata == axi_slave_tx_compare_obj.wdata && wstrb == axi_slave_tx_compare_obj.wstrb &&
  //WRITE RESPONSE CHANNEL
  bid == axi_slave_tx_compare_obj.bid && bresp == axi_slave_tx_compare_obj.bresp &&
  //READ ADDRESS CHANNEL
  araddr  == axi_slave_tx_compare_obj.araddr   &&
  arid    == axi_slave_tx_compare_obj.arid     &&
  arlen   == axi_slave_tx_compare_obj.arlen    &&
  arsize  == axi_slave_tx_compare_obj.arsize   &&
  arburst == axi_slave_tx_compare_obj.arburst  &&
  arlock  == axi_slave_tx_compare_obj.arlock   &&
  arcache == axi_slave_tx_compare_obj.arcache  &&
  arqos   == axi_slave_tx_compare_obj.arqos    &&
  arregion== axi_slave_tx_compare_obj.arregion &&
  arprot  == axi_slave_tx_compare_obj.arprot   &&
  //READ DATA CHANNEL
  rid   == axi_slave_tx_compare_obj.rid   &&
  rdata == axi_slave_tx_compare_obj.rdata &&
  rresp == axi_slave_tx_compare_obj.rresp &&
  //OTHERS
  op_type == axi_slave_tx_compare_obj.op_type &&
  sa == axi_slave_tx_compare_obj.sa && da == axi_slave_tx_compare_obj.da;
endfunction

function void axi_slv_txn::do_print(uvm_printer printer);
  printer.print_string("tx_type", op_type.name());
  if (op_type == WRITE) begin
    //`uvm_info("------------------------------------------WRITE_ADDRESS_CHANNEL","------------------------------------",UVM_LOW);
    printer.print_field("awid", awid, $bits(awid), UVM_HEX);
    printer.print_field("awaddr", awaddr, $bits(awaddr), UVM_HEX);
    printer.print_field("awlen", awlen, $bits(awlen), UVM_DEC);
    printer.print_string("awsize", awsize.name());
    printer.print_string("awburst", awburst.name());
    printer.print_string("awlock", awlock.name());
    printer.print_string("awcache", awcache.name());
    printer.print_string("awprot", awprot.name());
    printer.print_field("awqos", awqos, $bits(awqos), UVM_HEX);
    //`uvm_info("------------------------------------------WRITE_DATA_CHANNEL","---------------------------------------",UVM_LOW);
    foreach (wdata[i]) begin
      printer.print_field($sformatf("wdata[%0d]", i), wdata[i], $bits(wdata[i]), UVM_HEX);
    end
    foreach (wstrb[i]) begin
      printer.print_field($sformatf("wstrb[%0d]", i), wstrb[i], $bits(wstrb[i]), UVM_BIN);
    end
    // printer.print_field("wlast",wlast,$bits(wlast),UVM_DEC);
    //`uvm_info("------------------------------------------WRITE_RESPONSE_CHANNEL","-----------------------------------",UVM_LOW);
    printer.print_field("bid", bid, $bits(bid), UVM_HEX);
    printer.print_string("bresp", bresp.name());
  end else if (op_type == READ) begin
    //`uvm_info("------------------------------------------READ_ADDRESS_CHANNEL","-------------------------------------",UVM_LOW);
    printer.print_field("arid", arid, $bits(arid), UVM_HEX);
    printer.print_field("araddr", araddr, $bits(araddr), UVM_HEX);
    printer.print_field("arlen", arlen, $bits(arlen), UVM_DEC);
    printer.print_string("arsize", arsize.name());
    printer.print_string("arburst", arburst.name());
    printer.print_string("arlock", arlock.name());
    printer.print_string("arcache", arcache.name());
    printer.print_string("arprot", arprot.name());
    printer.print_field("arqos", arqos, $bits(arqos), UVM_HEX);
    //`uvm_info("------------------------------------------READ_DATA_CHANNEL","----------------------------------------",UVM_LOW);
    printer.print_field("rid", rid, $bits(rid), UVM_HEX);
    foreach (rdata[i]) begin
      printer.print_field($sformatf("rdata[%0d]", i), rdata[i], $bits(rdata[i]), UVM_HEX);
    end
    printer.print_string("rresp", rresp.name());
  end
  printer.print_field("sa", sa, $bits(sa), UVM_DEC);
  printer.print_field("da", da, $bits(da), UVM_DEC);
endfunction

function string axi_slv_txn::convert2string();
  string s;
  string s_tmp;
  s = super.convert2string();
  if (op_type == WRITE) begin
    s = {s, $sformatf("awid: %0h\n", awid)};
    s = {s, $sformatf("awaddr: %0h\n", awaddr)};
    s = {s, $sformatf("awlen: %0h\n", awlen)};
    s = {s, $sformatf("awsize: %s\n", awsize.name())};
    s = {s, $sformatf("awburst: %s\n", awburst.name())};
    s = {s, $sformatf("awlock: %s\n", awlock.name())};
    s = {s, $sformatf("awcache: %s\n", awcache.name())};
    s = {s, $sformatf("awprot: %s\n", awprot.name())};
    s = {s, $sformatf("awqos: %0h\n", awqos)};
    s = {s, $sformatf("awregion: %0h\n", awregion)};
    // s = {s, $sformatf("wdata: %p\n", wdata)};
    // s = {s, $sformatf("wstrb: %p\n", wstrb)};
    $swriteh(s_tmp, "wdata: %p\n", wdata);
    s = {s, s_tmp};
    $swriteb(s_tmp, "wstrb: %p\n", wstrb);
    s = {s, s_tmp};
    s = {s, $sformatf("bid: %0h\n", bid)};
    s = {s, $sformatf("bresp: %s\n", bresp.name())};
  end else if (op_type == READ) begin
    s = {s, $sformatf("arid: %0h\n", arid)};
    s = {s, $sformatf("araddr: %0h\n", araddr)};
    s = {s, $sformatf("arlen: %0h\n", arlen)};
    s = {s, $sformatf("arsize: %s\n", arsize.name())};
    s = {s, $sformatf("arburst: %s\n", arburst.name())};
    s = {s, $sformatf("arlock: %s\n", arlock.name())};
    s = {s, $sformatf("arcache: %s\n", arcache.name())};
    s = {s, $sformatf("arprot: %s\n", arprot.name())};
    s = {s, $sformatf("arqos: %0h\n", arqos)};
    s = {s, $sformatf("arregion: %0h\n", arregion)};
    s = {s, $sformatf("rid: %0h\n", rid)};
    // s = {s, $sformatf("rdata: %p\n", rdata)};
    $swriteh(s_tmp, "rdata: %p\n", rdata);
    s = {s, s_tmp};
    s = {s, $sformatf("rresp: %s\n", rresp.name())};
  end
  s = {s, $sformatf("sa: %0h\n", sa)};
  s = {s, $sformatf("da: %0h\n", da)};
  return s;
endfunction

