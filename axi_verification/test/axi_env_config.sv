// env config
class axi_env_config extends uvm_object;
    `uvm_object_utils(axi_env_config)
    bit has_scoreboard = 1;
    bit has_virtual_sqr = 1;
    int num_of_masters;
    int num_of_slaves;

    axi_master_agent_config axi_mst_agent_cfg[];
    axi_slave_agent_config axi_slv_agent_cfg[];

    extern function new(string name = "axi_env_config");
    extern function void do_print(uvm_printer printer);

endclass


function axi_env_config::new(string name = "axi_env_config");
    super.new(name);
endfunction 

function void axi_env_config::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("has_scoreboard", has_scoreboard, 1, UVM_DEC);
    printer.print_field("has_virtual_sqr", has_virtual_sqr ,1, UVM_DEC);
    printer.print_field("num_of_masters", num_of_masters, $bits(num_of_masters), UVM_HEX);
    printer.print_field("num_of_slaves", num_of_slaves, $bits(num_of_slaves), UVM_HEX);
endfunction