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


endinterface
