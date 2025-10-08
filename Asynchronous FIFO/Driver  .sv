// fifo_driver.sv
class fifo_driver extends uvm_driver #(fifo_seq_item);
    `uvm_component_utils(fifo_driver)
    virtual fifo_if vif;

    function new(string name = "fifo_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fifo_seq_item item;
        forever begin
            seq_item_port.get_next_item(item);
            drive_write(item);
            seq_item_port.item_done();
        end
    endtask

    task drive_write(fifo_seq_item item);
        @(posedge vif.wr_clk);
        if (!vif.full) begin
            vif.wr_en   <= 1;
            vif.wr_data <= item.data;
        end
        @(posedge vif.wr_clk);
        vif.wr_en <= 0;
    endtask
endclass
