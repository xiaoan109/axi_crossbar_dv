`timescale 1ns / 10ps
interface axi_if #(
    parameter int AXI_DATA_W = 8,
    parameter int AXI_ADDR_W = 8,
    parameter int AXI_ID_W   = 8,
    parameter int AXI_USER_W = 1
) (
    input bit aclk,
    input bit aresetn,
    input bit srst
);
  // AW Channel
  logic awvalid;
  logic awready;
  logic [AXI_ADDR_W-1:0] awaddr;
  logic [7:0] awlen;
  logic [2:0] awsize;
  logic [1:0] awburst;
  logic awlock;
  logic [3:0] awcache;
  logic [2:0] awprot;
  logic [3:0] awqos;
  logic [3:0] awregion;
  logic [AXI_ID_W-1:0] awid;
  logic [AXI_USER_W-1:0] awuser;
  // W Channel
  logic wvalid;
  logic wready;
  logic wlast;
  logic [AXI_DATA_W-1:0] wdata;
  logic [AXI_DATA_W/8-1:0] wstrb;
  logic [AXI_USER_W-1:0] wuser;
  // B Channel
  logic bvalid;
  logic bready;
  logic [AXI_ID_W-1:0] bid;
  logic [1:0] bresp;
  logic [AXI_USER_W-1:0] buser;
  // AR Channel
  logic arvalid;
  logic arready;
  logic [AXI_ADDR_W-1:0] araddr;
  logic [7:0] arlen;
  logic [2:0] arsize;
  logic [1:0] arburst;
  logic arlock;
  logic [3:0] arcache;
  logic [2:0] arprot;
  logic [3:0] arqos;
  logic [3:0] arregion;
  logic [AXI_ID_W-1:0] arid;
  logic [AXI_USER_W-1:0] aruser;
  // R Channel
  logic rvalid;
  logic rready;
  logic [AXI_ID_W-1:0] rid;
  logic [1:0] rresp;
  logic [AXI_DATA_W-1:0] rdata;
  logic rlast;
  logic [AXI_USER_W-1:0] ruser;


  // master driver clocking block
  clocking m_drv_cb @(posedge aclk);
    output awvalid, awaddr, awlen, awsize, awburst, awlock, awcache,
    awprot, awqos, awregion, awid, awuser, wvalid, wlast, wdata, wstrb, wuser,
    bready, arvalid, araddr, arlen, arsize, arburst, arlock, arcache,
    arprot, arqos, arregion, arid, aruser, rready;
    input awready, wready, bvalid, bid, bresp, buser, arready, rvalid,
    rid, rresp, rdata, rlast, ruser;
  endclocking

  // slave driver clocking block
  clocking s_drv_cb @(posedge aclk);
    input awvalid, awaddr, awlen, awsize, awburst, awlock, awcache,
    awprot, awqos, awregion, awid, awuser, wvalid, wlast, wdata, wstrb, wuser,
    bready, arvalid, araddr, arlen, arsize, arburst, arlock, arcache,
    arprot, arqos, arregion, arid, aruser, rready;
    output awready, wready, bvalid, bid, bresp, buser, arready, rvalid,
    rid, rresp, rdata, rlast, ruser;
  endclocking

  // master monitor clocking block
  clocking m_mon_cb @(posedge aclk);
    input awvalid, awaddr, awlen, awsize, awburst, awlock, awcache,
    awprot, awqos, awregion, awid, awuser, wvalid, wlast, wdata, wstrb, wuser,
    bready, arvalid, araddr, arlen, arsize, arburst, arlock, arcache,
    arprot, arqos, arregion, arid, aruser, rready;
    input awready, wready, bvalid, bid, bresp, buser, arready, rvalid,
    rid, rresp, rdata, rlast, ruser;
  endclocking

  // slave monitor clocking block
  clocking s_mon_cb @(posedge aclk);
    input awvalid, awaddr, awlen, awsize, awburst, awlock, awcache,
        awprot, awqos, awregion, awid, awuser, wvalid, wlast, wdata, wstrb, wuser,
        bready, arvalid, araddr, arlen, arsize, arburst, arlock, arcache,
        arprot, arqos, arregion, arid, aruser, rready;
    input awready, wready, bvalid, bid, bresp, buser, arready, rvalid,
        rid, rresp, rdata, rlast, ruser;
  endclocking

  // modports

  // modport m_drv_mp(clocking m_drv_cb, input aclk, aresetn, srst);
  // modport s_drv_mp(clocking s_drv_cb, input aclk, aresetn, srst);
  // modport m_mon_mp(clocking m_mon_cb, input aclk, aresetn, srst);
  // modport s_mon_mp(clocking s_mon_cb, input aclk, aresetn, srst);


  // TODO: assertions


  //--------------------------------------------------------------------------------------------
  // Assertion properties written for various checks in write address channel
  //--------------------------------------------------------------------------------------------
  //Assertion:   AXI_WA_STABLE_SIGNALS_CHECK
  //Description: All signals must remain stable after AWVALID is asserted until AWREADY IS LOW
  property if_write_address_channel_signals_are_stable;
    @(posedge aclk) disable iff (!aresetn)
    (awvalid==1 && awready==0) |=> ($stable(awid) && $stable(awaddr) && $stable(awlen) && $stable(awsize) && 
                                    $stable(awburst) && $stable(awlock) && $stable(awcache) && $stable(awprot));
  endproperty : if_write_address_channel_signals_are_stable
  AXI_WA_STABLE_SIGNALS_CHECK: assert property (if_write_address_channel_signals_are_stable);
 
  //Assertion:   AXI_WA_UNKNOWN_SIGNALS_CHECK
  //Description: A value of X on signals is not permitted when AWVALID is HIGH
  property if_write_address_channel_signals_are_unknown;
    @(posedge aclk) disable iff (!aresetn)
    (awvalid==1) |-> (!($isunknown(awid)) && !($isunknown(awaddr)) && !($isunknown(awlen)) && !($isunknown(awsize))
                     && !($isunknown(awburst)) && !($isunknown(awlock)) && !($isunknown(awcache)) && !($isunknown(awprot)));
  endproperty : if_write_address_channel_signals_are_unknown
  AXI_WA_UNKNOWN_SIGNALS_CHECK: assert property (if_write_address_channel_signals_are_unknown);

  //Assertion:   AXI_WA_VALID_STABLE_CHECK
  //Description: When AWVALID is asserted, then it must remain asserted until AWREADY is HIGH
  //Assertion stays asserted from the time awvalid becomes high and till awready becomes high using s_until_with keyword
  property axi_write_address_channel_valid_stable_check;
    @(posedge aclk) disable iff (!aresetn)
    $rose(awvalid) |-> awvalid s_until_with awready;
    // $rose(awvalid) |-> (awvalid throughout (##[0:$] awready));
  endproperty : axi_write_address_channel_valid_stable_check
  AXI_WA_VALID_STABLE_CHECK : assert property (axi_write_address_channel_valid_stable_check);


  //--------------------------------------------------------------------------------------------
  // Assertion properties written for various checks in write data channel
  //--------------------------------------------------------------------------------------------
  //Assertion:   AXI_WD_STABLE_SIGNALS_CHECK
  //Description: All signals must remain stable after WVALID is asserted until WREADY IS LOW
  property if_write_data_channel_signals_are_stable;
    @(posedge aclk) disable iff (!aresetn)
    (wvalid==1 && wready==0) |=> ($stable(wdata) && $stable(wstrb) && $stable(wlast) && $stable(wuser));
  endproperty : if_write_data_channel_signals_are_stable
  AXI_WD_STABLE_SIGNALS_CHECK: assert property (if_write_data_channel_signals_are_stable);
 
  //Assertion:   AXI_WD_UNKNOWN_SIGNALS_CHECK
  //Description: A value of X on signals is not permitted when WVALID is HIGH
  property if_write_data_channel_signals_are_unknown;
    @(posedge aclk) disable iff (!aresetn)
    (wvalid == 1) |-> (!($isunknown(wdata)) && !($isunknown(wstrb)) && !($isunknown(wlast)) && !($isunknown(wuser)));
  endproperty : if_write_data_channel_signals_are_unknown
  AXI_WD_UNKNOWN_SIGNALS_CHECK: assert property (if_write_data_channel_signals_are_unknown);

  //Assertion:   AXI_WD_VALID_STABLE_CHECK
  //Description: When WVALID is asserted, then it must remain asserted until WREADY is HIGH
  //Assertion stays asserted from the time wvalid becomes high and till wready becomes high using s_until_with keyword
  property axi_write_data_channel_valid_stable_check;
    @(posedge aclk) disable iff (!aresetn)
    $rose(wvalid) |-> wvalid s_until_with wready;
    // $rose(wvalid) |-> (wvalid throughout (##[0:$] wready));
  endproperty : axi_write_data_channel_valid_stable_check
  AXI_WD_VALID_STABLE_CHECK : assert property (axi_write_data_channel_valid_stable_check);
  
  
  //--------------------------------------------------------------------------------------------
  // Assertion properties written for various checks in write response channel
  //--------------------------------------------------------------------------------------------
  //Assertion:   AXI_WR_STABLE_SIGNALS_CHECK
  //Description: All signals must remain stable after BVALID is asserted until BREADY IS LOW
  property if_write_response_channel_signals_are_stable;
    @(posedge aclk) disable iff(!aresetn)
    bvalid==1 && bready==0 |=> $stable(bid) && $stable(buser) && $stable(bresp); 
  endproperty : if_write_response_channel_signals_are_stable
  AXI_WR_STABLE_SIGNALS_CHECK: assert property (if_write_response_channel_signals_are_stable);

  //Assertion:   AXI_WR_UNKNOWN_SIGNALS_CHECK
  //Description: A value of X on signals is not permitted when BVALID is HIGH
  property if_write_response_channel_signals_are_unknown;
    @(posedge aclk) disable iff(!aresetn)
    bvalid==1 |-> !$isunknown(bid) && !$isunknown(buser) && !$isunknown(bresp);  
  endproperty : if_write_response_channel_signals_are_unknown
  AXI_WR_UNKNOWN_SIGNALS_CHECK: assert property (if_write_response_channel_signals_are_unknown);

  //Assertion:   AXI_WR_VALID_STABLE_CHECK
  //Description: When BVALID is asserted, then it must remain asserted until BREADY is HIGH
  //Assertion stays asserted from the time bvalid becomes high and till bready becomes high using s_until_with keyword
  property axi_write_response_channel_valid_stable_check;
    @(posedge aclk) disable iff(!aresetn)
    $rose(bvalid) |-> bvalid s_until_with bready;
    // $rose(bvalid) |-> (bvalid throughout (##[0:$] bready));
  endproperty : axi_write_response_channel_valid_stable_check
  AXI_WR_VALID_STABLE_CHECK : assert property (axi_write_response_channel_valid_stable_check);
 

  //--------------------------------------------------------------------------------------------
  // Assertion properties written for various checks in read address channel
  //--------------------------------------------------------------------------------------------
  //Assertion:   AXI_RA_STABLE_SIGNALS_CHECK
  //Description: All signals must remain stable after ARVALID is asserted until ARREADY IS LOW
  property if_read_address_channel_signals_are_stable;
    @(posedge aclk) disable iff (!aresetn)
    (arvalid==1 && arready==0) |=> ($stable(arid) && $stable(araddr) && $stable(arlen) && $stable(arsize) && 
                                    $stable(arburst) && $stable(arlock) && $stable(arcache) && $stable(arprot));
  endproperty : if_read_address_channel_signals_are_stable
  AXI_RA_STABLE_SIGNALS_CHECK: assert property (if_read_address_channel_signals_are_stable);
 
  //Assertion:   AXI_RA_UNKNOWN_SIGNALS_CHECK
  //Description: A value of X on signals is not permitted when ARVALID is HIGH
  property if_read_address_channel_signals_are_unknown;
    @(posedge aclk) disable iff (!aresetn)
    (arvalid==1) |-> (!($isunknown(arid)) && !($isunknown(araddr)) && !($isunknown(arlen)) && !($isunknown(arsize))
                     && !($isunknown(arburst)) && !($isunknown(arlock)) && !($isunknown(arcache)) && !($isunknown(arprot)));
  endproperty : if_read_address_channel_signals_are_unknown
  AXI_RA_UNKNOWN_SIGNALS_CHECK: assert property (if_read_address_channel_signals_are_unknown);

  //Assertion:   AXI_RA_VALID_STABLE_CHECK
  //Description: When ARVALID is asserted, then it must remain asserted until ARREADY is HIGH
  //Assertion stays asserted from the time arvalid becomes high and till arready becomes high using s_until_with keyword
  property axi_read_address_channel_valid_stable_check;
    @(posedge aclk) disable iff (!aresetn)
    $rose(arvalid) |-> arvalid s_until_with arready;
    // $rose(arvalid) |-> (arvalid throughout (##[0:$] arready));
  endproperty : axi_read_address_channel_valid_stable_check
  AXI_RA_VALID_STABLE_CHECK : assert property (axi_read_address_channel_valid_stable_check);


  //--------------------------------------------------------------------------------------------
  // Assertion properties written for various checks in read data channel
  //--------------------------------------------------------------------------------------------
  //Assertion:   AXI_RD_STABLE_SIGNALS_CHECK
  //Description: All signals must remain stable after RVALID is asserted until RREADY IS LOW
  property if_read_data_channel_signals_are_stable;
    @(posedge aclk) disable iff (!aresetn)
    (rvalid==1 && rready==0) |=> ($stable(rid) && $stable(rdata) && $stable(rresp) && $stable(rlast) && $stable(ruser));
  endproperty : if_read_data_channel_signals_are_stable
  AXI_RD_STABLE_SIGNALS_CHECK: assert property (if_read_data_channel_signals_are_stable);
 
  //Assertion:   AXI_RD_UNKNOWN_SIGNALS_CHECK
  //Description: A value of X on signals is not permitted when RVALID is HIGH
  property if_read_data_channel_signals_are_unknown;
    @(posedge aclk) disable iff (!aresetn)
    (rvalid==1) |-> (!($isunknown(rid)) && !($isunknown(rdata)) && !($isunknown(rresp))
                    && !($isunknown(rlast)) && !($isunknown(ruser)));
  endproperty : if_read_data_channel_signals_are_unknown
  AXI_RD_UNKNOWN_SIGNALS_CHECK: assert property (if_read_data_channel_signals_are_unknown);

  //Assertion:   AXI_RD_VALID_STABLE_CHECK
  //Description: When RVALID is asserted, then it must remain asserted until RREADY is HIGH
  //Assertion stays asserted from the time rvalid becomes high and till rready becomes high using s_until_with keyword
  property axi_read_data_channel_valid_stable_check;
    @(posedge aclk) disable iff (!aresetn)
    $rose(rvalid) |-> rvalid s_until_with rready;
    // $rose(rvalid) |-> (rvalid throughout (##[0:$] rready));
  endproperty : axi_read_data_channel_valid_stable_check
  AXI_RD_VALID_STABLE_CHECK : assert property (axi_read_data_channel_valid_stable_check);

endinterface
