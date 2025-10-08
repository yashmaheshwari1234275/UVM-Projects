// fifo_agent.sv
class fifo_agent extends uvm_agent;
    `uvm_component_utils(fifo_agent)
    virtual fifo_if vif;
    fifo_driver   drv;
    fifo_monitor  mon;
    uvm_sequencer #(fifo_seq_item) seqr;

    function new(string name = "fifo_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        drv  = fifo_driver::type_id::create("drv", this);
        mon  = fifo_monitor::type_id::create("mon", this);
        seqr = uvm_sequencer#(fifo_seq_item)::type_id::create("seqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass
