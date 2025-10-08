// fifo_monitor.sv
class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)
    virtual fifo_if vif;

    // One analysis port for both write/read events
    uvm_analysis_port #(fifo_seq_item) write_ap;
    uvm_analysis_port #(fifo_seq_item) read_ap;

    function new(string name = "fifo_monitor", uvm_component parent);
        super.new(name, parent);
        write_ap = new("write_ap", this);
        read_ap  = new("read_ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        fork
            monitor_write();
            monitor_read();
        join_none
    endtask

    task monitor_write();
        fifo_seq_item item;
        forever begin
            @(posedge vif.wr_clk);
            if (vif.wr_en && !vif.full) begin
                item = fifo_seq_item::type_id::create("wr_item");
                item.data = vif.wr_data;
                write_ap.write(item);
                `uvm_info("MON", $sformatf("Captured WRITE: %0h", item.data), UVM_LOW)
            end
        end
    endtask

    task monitor_read();
        fifo_seq_item item;
        forever begin
            @(posedge vif.rd_clk);
            if (vif.rd_en && !vif.empty) begin
                item = fifo_seq_item::type_id::create("rd_item");
                item.data = vif.rd_data;
                read_ap.write(item);
                `uvm_info("MON", $sformatf("Captured READ: %0h", item.data), UVM_LOW)
            end
        end
    endtask
endclass
