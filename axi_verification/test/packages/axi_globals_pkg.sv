package axi_globals_pkg;

  parameter int AXI_ADDR_W = 8;
  parameter int AXI_DATA_W = 32;
  parameter int AXI_ID_W = 8;
  parameter int AXI_USER_W = 8;
  parameter int MST0_ID_MASK = 'h10;
  parameter int MST1_ID_MASK = 'h20;
  parameter int MST2_ID_MASK = 'h40;
  parameter int MST3_ID_MASK = 'h80;
  parameter int SLV0_START_ADDR = 0;
  parameter int SLV0_END_ADDR = (1 << AXI_ADDR_W) / 4 - 1;
  parameter int SLV1_START_ADDR = (1 << AXI_ADDR_W) / 4;
  parameter int SLV1_END_ADDR = (1 << AXI_ADDR_W) / 2 - 1;
  parameter int SLV2_START_ADDR = (1 << AXI_ADDR_W) / 2;
  parameter int SLV2_END_ADDR = (3 * (1 << AXI_ADDR_W)) / 4 - 1;
  parameter int SLV3_START_ADDR = 3 * (1 << AXI_ADDR_W) / 4;
  parameter int SLV3_END_ADDR = (1 << AXI_ADDR_W) - 1;


  typedef enum bit {
    READ,
    WRITE
  } tx_type_e;

  typedef enum bit [1:0] {
    FIXED,
    INCR,
    WRAP,
    RESERVED
  } burst_e;

  typedef enum bit [2:0] {
    _1_BYTE    = 3'b000,
    _2_BYTES   = 3'b001,
    _4_BYTES   = 3'b010,
    _8_BYTES   = 3'b011,
    _16_BYTES  = 3'b100,
    _32_BYTES  = 3'b101,
    _64_BYTES  = 3'b110,
    _128_BYTES = 3'b111
  } size_e;

  typedef enum bit {
    NORMAL_ACCESS    = 1'b0,
    EXCLUSIVE_ACCESS = 1'b1
  } lock_e;

  typedef enum bit [3:0] {
    BUFFERABLE,
    MODIFIABLE,
    OTHER_ALLOCATE,
    ALLOCATE
  } cache_e;

  typedef enum bit [2:0] {
    NORMAL_SECURE_DATA               = 3'b000,
    NORMAL_SECURE_INSTRUCTION        = 3'b001,
    NORMAL_NONSECURE_DATA            = 3'b010,
    NORMAL_NONSECURE_INSTRUCTION     = 3'b011,
    PRIVILEGED_SECURE_DATA           = 3'b100,
    PRIVILEGED_SECURE_INSTRUCTION    = 3'b101,
    PRIVILEGED_NONSECURE_DATA        = 3'b110,
    PRIVILEGED_NONSECURE_INSTRUCTION = 3'b111
  } prot_e;

  typedef enum bit [1:0] {
    OKAY,
    EXOKAY,
    SLVERR,
    DECERR
  } response_e;

  typedef enum bit [1:0] {
    BLOCKING_WRITE     = 2'b00,
    BLOCKING_READ      = 2'b01,
    NON_BLOCKING_WRITE = 2'b10,
    NON_BLOCKING_READ  = 2'b11
  } transfer_type_e;

endpackage
