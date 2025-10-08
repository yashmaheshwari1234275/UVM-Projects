// fifo_seq_item.sv
class fifo_seq_item extends uvm_sequence_item;
    rand bit [7:0] data;
    `uvm_object_utils(fifo_seq_item)

    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("data=%0h", data);
    endfunction
endclass
