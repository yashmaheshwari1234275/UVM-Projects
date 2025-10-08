// fifo_scoreboard.sv
class fifo_scoreboard extends uvm_component;
    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_export #(fifo_seq_item) write_export;
    uvm_analysis_export #(fifo_seq_item) read_export;

    // Reference FIFO model
    fifo_seq_item ref_q[$];

    function new(string name = "fifo_scoreboard", uvm_component parent);
        super.new(name, parent);
        write_export = new("write_export", this);
        read_export  = new("read_export", this);
    endfunction

    // Methods to receive data from monitor
    function void write_write_ap(fifo_seq_item item);
        ref_q.push_back(item);
        `uvm_info("SCOREBOARD", $sformatf("Reference model: Pushed %0h", item.data), UVM_LOW)
    endfunction

    function void write_read_ap(fifo_seq_item item);
        if (ref_q.size() == 0) begin
            `uvm_error("SCOREBOARD", "Read occurred but reference queue is empty!")
            return;
        end

        fifo_seq_item exp_item = ref_q.pop_front();

        if (item.data !== exp_item.data)
            `uvm_error("SCOREBOARD", $sformatf("Data mismatch! Expected %0h, got %0h", exp_item.data, item.data))
        else
            `uvm_info("SCOREBOARD", $sformatf("PASS: %0h matched expected", item.data), UVM_LOW)
    endfunction
endclass
