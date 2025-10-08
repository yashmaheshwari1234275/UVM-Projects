// fifo_sequence.sv
class fifo_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_sequence)

    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction

    task body();
        fifo_seq_item item;
        repeat (50) begin
            item = fifo_seq_item::type_id::create("item");
            assert(item.randomize());
            start_item(item);
            finish_item(item);
        end
    endtask
endclass
