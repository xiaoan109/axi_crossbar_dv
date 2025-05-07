class axi_master_agent_config extends uvm_object;
    `uvm_object_utils(axi_master_agent_config)
    //Variable: is_active
    //Used for creating the agent in either passive or active mode
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    //Variable: has_coverage
    //Used for enabling the master agent coverage
    bit has_coverage;

    //Variable: master_id
    //Gives the master id
    int master_id;

    //Variable : master_mem
    //Used to store all the data from the slaves
    //Each location of the master memory stores 8 bit data
    bit [MEMORY_WIDTH-1:0] master_mem [((1<<SLAVE_MEMORY_SIZE)+SLAVE_MEMORY_GAP)*NUM_OF_SLAVES-1:0];

    //Variable : master_min_array
    //An associative array used to store the min address ranges of every slave
    //Index - type    - int
    //        stores  - slave number
    //Value - stores the minimum address range of that slave.
    bit [AXI_ADDR_W-1:0] master_min_addr_range_array [int];

    //Variable : master_max_array
    //An associative array used to store the max address ranges of every slave
    //Index - type    - int
    //        stores  - slave number
    //Value - stores the maximum address range of that slave.
    bit [AXI_ADDR_W-1:0] master_max_addr_range_array [int];

    //Member : vif
    // axi virtual interface handle passed from DUT
    axi_vif vif;

    extern function new(string name = "axi_master_agent_config");
    extern function void do_print(uvm_printer printer);
    extern function void master_min_addr_range(int slave_number, bit [AXI_ADDR_W-1:0] slave_min_address_range);
    extern function void master_max_addr_range(int slave_number, bit [AXI_ADDR_W-1:0] slave_max_address_range);

endclass

function axi_master_agent_config::new(string name = "axi_master_agent_config");
    super.new(name);
endfunction

function void axi_master_agent_config::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_string("is_active", is_active.name());
    printer.print_field("has_coverage", has_coverage, $bits(has_coverage), UVM_DEC);
    printer.print_field("master_id", master_id, $bits(master_id), UVM_DEC);
    
    foreach(master_min_addr_range_array[i]) begin
        printer.print_field($sformatf("master_min_addr_range_array[%0d]", i), master_min_addr_range_array[i], $bits(master_min_addr_range_array[i]), UVM_HEX);
        printer.print_field($sformatf("master_max_addr_range_array[%0d]", i), master_max_addr_range_array[i], $bits(master_max_addr_range_array[i]), UVM_HEX);
    end
endfunction

function void axi_master_agent_config::master_min_addr_range(int slave_number, bit [AXI_ADDR_W-1:0] slave_min_address_range);
    master_min_addr_range_array[slave_number] = slave_min_address_range;
endfunction

function void axi_master_agent_config::master_max_addr_range(int slave_number, bit [AXI_ADDR_W-1:0] slave_max_address_range);
    master_max_addr_range_array[slave_number] = slave_max_address_range;
endfunction