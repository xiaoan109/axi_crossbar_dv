class axi_mst_txn #(
    int AXI_DATA_W = 8,
    int AXI_ADDR_W = 8,
    int AXI_ID_W   = 8,
    int AXI_USER_W = 8
) extends uvm_sequence_item;

  typedef axi_mst_txn#(AXI_DATA_W, AXI_ADDR_W, AXI_ID_W) this_type_t;
  `uvm_object_param_utils(this_type_t)

  rand tx_type_e                          op_type;
  rand transfer_type_e                    transfer_type;  // Blocking or Non-blocking
  // Write transaction
  rand bit             [  AXI_ADDR_W-1:0] awaddr;
  rand size_e                             awsize;
  rand bit             [             7:0] awlen;
  rand burst_e                            awburst;
  rand bit             [    AXI_ID_W-1:0] awid;
  rand lock_e                             awlock;
  rand cache_e                            awcache;
  rand prot_e                             awprot;
  rand bit             [             3:0] awqos;
  rand bit             [             3:0] awregion;
  rand bit             [  AXI_USER_W-1:0] awuser;
  rand bit             [  AXI_DATA_W-1:0] wdata                                       [$:1<<8];
  rand bit             [AXI_DATA_W/8-1:0] wstrb                                       [$:1<<8];
  rand bit             [  AXI_USER_W-1:0] wuser;
  bit                                     wlast;
  response_e                              bresp;
  bit                  [    AXI_ID_W-1:0] bid;
  bit                  [  AXI_USER_W-1:0] buser;
  // Read transaction
  rand bit             [  AXI_ADDR_W-1:0] araddr;
  rand size_e                             arsize;
  rand bit             [             7:0] arlen;
  rand burst_e                            arburst;
  rand bit             [    AXI_ID_W-1:0] arid;
  rand lock_e                             arlock;
  rand cache_e                            arcache;
  rand prot_e                             arprot;
  rand bit             [             3:0] arqos;
  rand bit             [             3:0] arregion;
  rand bit             [  AXI_USER_W-1:0] aruser;
  bit                  [  AXI_DATA_W-1:0] rdata                                       [$:1<<8];
  bit                  [    AXI_ID_W-1:0] rid;
  response_e                              rresp;
  bit                                     rlast;
  bit                  [  AXI_USER_W-1:0] ruser;


  // crossbar needed
  rand bit             [             1:0] sa;
  rand bit             [             1:0] da;


  // AW channel
  constraint awsize_val_c {(1 << awsize) << 3 <= AXI_DATA_W;}

  constraint awburst_val_c {awburst != RESERVED;}

  constraint awlen_val_c {
    solve awburst before awlen;

    if (awburst == FIXED)
    awlen inside {[0 : 15]};
    else
    if (awburst == WRAP) awlen inside {1, 3, 7, 15};
  }

  constraint awaddr_range_c {
    da == 0 -> awaddr inside {[0 : (1 << AXI_ADDR_W) / 4 - 1]};
    da == 1 -> awaddr inside {[(1 << AXI_ADDR_W) / 4 : (1 << AXI_ADDR_W) / 2 - 1]};
    da == 2 -> awaddr inside {[(1 << AXI_ADDR_W) / 2 : (3 * (1 << AXI_ADDR_W)) / 4 - 1]};
    da == 3 -> awaddr inside {[(3 * (1 << AXI_ADDR_W)) / 4 : (1 << AXI_ADDR_W) - 1]};
  }

  constraint awaddr_val_c {
    solve awburst before awaddr;
    solve awsize before awaddr;

    // wrap burst address alignment
    if (awburst == WRAP) awaddr == (awaddr / (1 << awsize)) * (1 << awsize);
  }

  constraint awaddr_val_align_c {
    solve awsize before awaddr;

    awaddr == (awaddr / (1 << awsize)) * (1 << awsize);
  }

  constraint awaddr_val_unalign_c {
    solve awsize before awaddr;

    awaddr != (awaddr / (1 << awsize)) * (1 << awsize);
  }

  constraint awlock_val_c {soft awlock == NORMAL_ACCESS;}

  constraint awcache_val_c {soft awcache == BUFFERABLE;}

  constraint awprot_val_c {soft awprot == NORMAL_SECURE_DATA;}

  constraint awqos_val_c {soft awqos == 0;}

  constraint awregion_val_c {soft awregion == 0;}



  // W channel
  constraint wdata_val_c {
    solve awlen before wdata;

    wdata.size() == awlen + 1;
  }

  constraint wstrb_val_c {
    solve awlen before wstrb;

    wstrb.size() == awlen + 1;
  }

  constraint wstrb_val_no_zero_c {foreach (wstrb[i]) wstrb[i] != 0;}

  constraint wstrb_val_ones_c {foreach (wstrb[i]) $countones(wstrb[i]) == 2 ** awsize;}

  // AR channel
  constraint arsize_val_c {(1 << arsize) << 3 <= AXI_DATA_W;}

  constraint arburst_val_c {arburst != RESERVED;}

  constraint arlen_val_c {
    solve arburst before arlen;

    if (arburst == FIXED)
    arlen inside {[0 : 15]};
    else
    if (arburst == WRAP) arlen inside {1, 3, 7, 15};
  }

  constraint araddr_range_c {
    da == 0 -> araddr inside {[0 : (1 << AXI_ADDR_W) / 4 - 1]};
    da == 1 -> araddr inside {[(1 << AXI_ADDR_W) / 4 : (1 << AXI_ADDR_W) / 2 - 1]};
    da == 2 -> araddr inside {[(1 << AXI_ADDR_W) / 2 : (3 * (1 << AXI_ADDR_W)) / 4 - 1]};
    da == 3 -> araddr inside {[(3 * (1 << AXI_ADDR_W)) / 4 : (1 << AXI_ADDR_W) - 1]};
  }

  constraint araddr_val_c {
    solve arburst before araddr;
    solve arsize before araddr;

    // wrap burst address alignment
    if (arburst == WRAP) araddr == (araddr / (1 << arsize)) * (1 << arsize);
  }

  constraint araddr_val_align_c {
    solve arsize before araddr;

    araddr == (araddr / (1 << arsize)) * (1 << arsize);
  }

  constraint araddr_val_unalign_c {
    solve arsize before araddr;

    araddr != (araddr / (1 << arsize)) * (1 << arsize);
  }

  constraint arlock_val_c {soft arlock == NORMAL_ACCESS;}

  constraint arcache_val_c {soft arcache == BUFFERABLE;}

  constraint arprot_val_c {soft arprot == NORMAL_SECURE_DATA;}

  constraint arqos_val_c {soft arqos == 0;}

  constraint arregion_val_c {soft arregion == 0;}


  // crossbar
  constraint sa_val_c {sa inside {[0 : 3]};}

  constraint da_val_c {da inside {[0 : 3]};}

  extern function new(string name = "axi_mst_txn");
  extern function void do_copy(uvm_object rhs);
  extern function void post_randomize();
  extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function string convert2string();
  extern function void set_addr_default();
  extern function void set_addr_align();
  extern function void set_addr_unalign();
endclass

function axi_mst_txn::new(string name = "axi_mst_txn");
  super.new(name);
endfunction

function void axi_mst_txn::do_copy(uvm_object rhs);
  this_type_t axi_mst_txn_copy_obj;

  if (!$cast(axi_mst_txn_copy_obj, rhs)) begin
    `uvm_fatal("do_copy", "cast of the rhs object failed")
  end
  super.do_copy(rhs);

  //WRITE ADDRESS CHANNEL
  awid          = axi_mst_txn_copy_obj.awid;
  awaddr        = axi_mst_txn_copy_obj.awaddr;
  awlen         = axi_mst_txn_copy_obj.awlen;
  awsize        = axi_mst_txn_copy_obj.awsize;
  awburst       = axi_mst_txn_copy_obj.awburst;
  awlock        = axi_mst_txn_copy_obj.awlock;
  awcache       = axi_mst_txn_copy_obj.awcache;
  awprot        = axi_mst_txn_copy_obj.awprot;
  awqos         = axi_mst_txn_copy_obj.awqos;
  //WRITE DATA CHANNEL
  wdata         = axi_mst_txn_copy_obj.wdata;
  wstrb         = axi_mst_txn_copy_obj.wstrb;
  //WRITE RESPONSE CHANNEL
  bid           = axi_mst_txn_copy_obj.bid;
  bresp         = axi_mst_txn_copy_obj.bresp;
  //READ ADDRESS CHANNEL
  arid          = axi_mst_txn_copy_obj.arid;
  araddr        = axi_mst_txn_copy_obj.araddr;
  arlen         = axi_mst_txn_copy_obj.arlen;
  arsize        = axi_mst_txn_copy_obj.arsize;
  arburst       = axi_mst_txn_copy_obj.arburst;
  arlock        = axi_mst_txn_copy_obj.arlock;
  arcache       = axi_mst_txn_copy_obj.arcache;
  arprot        = axi_mst_txn_copy_obj.arprot;
  arqos         = axi_mst_txn_copy_obj.arqos;
  arregion      = axi_mst_txn_copy_obj.arregion;
  //READ DATA CHANNEL
  rid           = axi_mst_txn_copy_obj.rid;
  rdata         = axi_mst_txn_copy_obj.rdata;
  rresp         = axi_mst_txn_copy_obj.rresp;
  //OTHERS
  op_type       = axi_mst_txn_copy_obj.op_type;
  transfer_type = axi_mst_txn_copy_obj.transfer_type;
  sa            = axi_mst_txn_copy_obj.sa;
  da            = axi_mst_txn_copy_obj.da;
endfunction

function bit axi_mst_txn::do_compare(uvm_object rhs, uvm_comparer comparer);
  this_type_t axi_mst_txn_compare_obj;

  if (!$cast(axi_mst_txn_compare_obj, rhs)) begin
    `uvm_fatal("FATAL_axi_MASTER_TX_DO_COMPARE_FAILED", "cast of the rhs object failed")
    return 0;
  end

  return super.do_compare(
      axi_mst_txn_compare_obj, comparer
  ) &&
  //WRITE ADDRESS CHANNEL
  awid    == axi_mst_txn_compare_obj.awid    &&
  awaddr  == axi_mst_txn_compare_obj.awaddr  &&
  awlen   == axi_mst_txn_compare_obj.awlen   &&
  awsize  == axi_mst_txn_compare_obj.awsize  &&
  awburst == axi_mst_txn_compare_obj.awburst &&
  awlock  == axi_mst_txn_compare_obj.awlock  &&
  awcache == axi_mst_txn_compare_obj.awcache &&
  awprot  == axi_mst_txn_compare_obj.awprot  &&
  awqos   == axi_mst_txn_compare_obj.awqos   &&
  //WRITE DATA CHANNEL
  wdata == axi_mst_txn_compare_obj.wdata && wstrb == axi_mst_txn_compare_obj.wstrb &&
  //WRITE RESPONSE CHANNEL
  bid == axi_mst_txn_compare_obj.bid && bresp == axi_mst_txn_compare_obj.bresp &&
  //READ ADDRESS CHANNEL
  arid    == axi_mst_txn_compare_obj.arid    &&
  araddr  == axi_mst_txn_compare_obj.araddr  &&
  arlen   == axi_mst_txn_compare_obj.arlen   &&
  arsize  == axi_mst_txn_compare_obj.arsize  &&
  arburst == axi_mst_txn_compare_obj.arburst &&
  arlock  == axi_mst_txn_compare_obj.arlock  &&
  arcache == axi_mst_txn_compare_obj.arcache &&
  arprot  == axi_mst_txn_compare_obj.arprot  &&
  arqos   == axi_mst_txn_compare_obj.arqos   &&
  //READ DATA CHANNEL
  rid   == axi_mst_txn_compare_obj.rid   &&
  rdata == axi_mst_txn_compare_obj.rdata &&
  rresp == axi_mst_txn_compare_obj.rresp &&
  //OTHERS
  op_type == axi_mst_txn_compare_obj.op_type &&
  sa == axi_mst_txn_compare_obj.sa && da == axi_mst_txn_compare_obj.da;
endfunction

function void axi_mst_txn::do_print(uvm_printer printer);
  printer.print_string("tx_type", op_type.name());
  if (op_type == WRITE) begin
    //`uvm_info("------------------------------------------WRITE_ADDRESS_CHANNEL","-------------------------------------",UVM_LOW);
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
      // MSHA: printer.print_field($sformatf("wstrb[%0d]",i),wstrb[i],$bits(wstrb[i]),UVM_HEX);
      printer.print_field($sformatf("wstrb[%0d]", i), wstrb[i], $bits(wstrb[i]), UVM_BIN);
    end

    //`uvm_info("-----------------------------------------WRITE_RESPONSE_CHANNEL","------------------------------------",UVM_LOW);
    printer.print_field("bid", bid, $bits(bid), UVM_HEX);
    printer.print_string("bresp", bresp.name());
  end

  if (op_type == READ) begin
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
  printer.print_string("transfer_type", transfer_type.name());
  printer.print_field("sa", sa, $bits(sa), UVM_DEC);
  printer.print_field("da", da, $bits(da), UVM_DEC);
endfunction

// For wstrb
function void axi_mst_txn::post_randomize();
  int start_addr;
  int size;  // transfer size in bytes
  int data_bytes;  // data bus width in bytes
  int aligned_addr;
  int burst_length;
  int contaniner_size;
  int address_1;
  int address_N[];
  int lower_wrap_boundary;
  int upper_wrap_boundary;
  int lower_byte_lane;
  int upper_byte_lane;

  start_addr = awaddr;
  size = (1 << awsize);
  data_bytes = AXI_DATA_W / 8;
  burst_length = awlen + 1;
  contaniner_size = size * burst_length;
  aligned_addr = (int'(start_addr / size)) * size;
  address_1 = start_addr;
  address_N = new[burst_length];

  if (awburst == FIXED) begin
    for (int i = 0; i < burst_length; i++) begin
      address_N[i] = start_addr;
    end
  end else if (awburst == INCR) begin
    for (int i = 0; i < burst_length; i++) begin
      address_N[i] = aligned_addr + (i * size);
    end
  end else if (awburst == WRAP) begin
    start_addr = aligned_addr;
    lower_wrap_boundary = (int'(start_addr / contaniner_size)) * contaniner_size;
    upper_wrap_boundary = lower_wrap_boundary + contaniner_size;
    for (int i = 0; i < burst_length; i++) begin
      address_N[i] = aligned_addr + (i * size);
      if (address_N[i] >= upper_wrap_boundary) begin
        address_N[i] = lower_wrap_boundary;
        for (int j = i + 1; j < burst_length; j++) begin
          address_N[j] = start_addr + (j * size) - contaniner_size;
        end
        break;
      end
    end
  end

  foreach (wstrb[i]) begin
    wstrb[i] = 0;
    if (i == 0) begin
      lower_byte_lane = start_addr - (int'(start_addr / data_bytes)) * data_bytes;
      upper_byte_lane = aligned_addr + (size - 1) - (int'(start_addr / data_bytes)) * data_bytes;
      for (int j = lower_byte_lane; j <= upper_byte_lane; j++) begin
        wstrb[i][j] = 1;
        // $display(
        //     "FIRST TRANSFER     i=%d,j=%d,start_address=%d,lower_byte_lane=%d,upper_byte_lane=%d",
        //     i, j, start_addr, lower_byte_lane, upper_byte_lane);
      end
    end else begin
      lower_byte_lane = address_N[i] - (int'(address_N[i] / data_bytes)) * data_bytes;
      upper_byte_lane = lower_byte_lane + size - 1;
      for (int j = lower_byte_lane; j <= upper_byte_lane; j++) begin
        wstrb[i][j] = 1;
        // $display(
        //     "REMAINING TRANSFER i=%d,j=%d,next_address=%d,lower_byte_lane=%d,upper_byte_lane=%d",
        //     i, j, address_N[i], lower_byte_lane, upper_byte_lane);
      end
    end
  end
endfunction

function string axi_mst_txn::convert2string();
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
  s = {s, $sformatf("transfer_type: %s\n", transfer_type.name())};
  s = {s, $sformatf("sa: %0h\n", sa)};
  s = {s, $sformatf("da: %0h\n", da)};
  return s;
endfunction

function void axi_mst_txn::set_addr_default();
  awaddr_val_align_c.constraint_mode(0);
  awaddr_val_unalign_c.constraint_mode(0);
  awaddr_val_c.constraint_mode(1);
  araddr_val_align_c.constraint_mode(0);
  araddr_val_unalign_c.constraint_mode(0);
  araddr_val_c.constraint_mode(1);
endfunction

function void axi_mst_txn::set_addr_align();
  awaddr_val_align_c.constraint_mode(1);
  awaddr_val_unalign_c.constraint_mode(0);
  awaddr_val_c.constraint_mode(0);
  araddr_val_align_c.constraint_mode(1);
  araddr_val_unalign_c.constraint_mode(0);
  araddr_val_c.constraint_mode(0);
endfunction

function void axi_mst_txn::set_addr_unalign();
  awaddr_val_align_c.constraint_mode(0);
  awaddr_val_unalign_c.constraint_mode(1);
  awaddr_val_c.constraint_mode(0);
  araddr_val_align_c.constraint_mode(0);
  araddr_val_unalign_c.constraint_mode(1);
  araddr_val_c.constraint_mode(0);
endfunction
