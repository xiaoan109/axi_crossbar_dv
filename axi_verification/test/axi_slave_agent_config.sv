class axi_slave_agent_config extends uvm_object;
    `uvm_object_utils(axi_slave_agent_config)
    //Variable: is_active
    //Used for creating the agent in either passive or active mode
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    //Variable: has_coverage
    //Used for enabling the master agent coverage
    bit has_coverage;

    //Variable: slave_id
    //Gives the slave id
    int slave_id;

    //Variable : max_address
    //Used to store the maximum address value of this slave
    bit [AXI_ADDR_W-1:0] max_address;

    //Variable : min_address
    //Used to store the minimum address value of this slave
    bit [AXI_ADDR_W-1:0] min_address;

    //Member : vif
    // axi virtual interface handle passed from DUT
    axi_vif vif;

    extern function new(string name = "axi_slave_agent_config");
    extern function void do_print(uvm_printer printer);
endclass

function axi_slave_agent_config::new(string name = "axi_slave_agent_config");
    super.new(name);
endfunction

function void axi_slave_agent_config::do_print(uvm_printer printer);
    super.do_print(printer);

    printer.print_string("is_active", is_active.name());
    printer.print_field("has_coverage", has_coverage, $bits(has_coverage), UVM_DEC);
    printer.print_field("slave_id", slave_id, $bits(slave_id), UVM_DEC);
    printer.print_field("min_address", min_address, $bits(min_address), UVM_HEX);
    printer.print_field("max_address", max_address, $bits(max_address), UVM_HEX);

endfunction