`ifndef APB_SCOREBOARD_SV
`define APB_SCOREBOARD_SV

class apb_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(apb_scoreboard)

  uvm_analysis_imp #(apb_seq_item, apb_scoreboard) sb_imp;

  bit [31:0] mem_model [0:31];

  function new(string name="apb_scoreboard", uvm_component parent=null);
    super.new(name, parent);
    sb_imp = new("sb_imp", this);
  endfunction

  function void write(apb_seq_item trans);

    if(trans.P_write == 1) begin
      mem_model[trans.P_addr] = trans.P_wdata;
      `uvm_info("APB_SCB",
                $sformatf("WRITE: Addr=%0d Data=%0h",
                          trans.P_addr, trans.P_wdata),
                UVM_LOW)
    end 
    else begin
      bit [31:0] expected = mem_model[trans.P_addr];

      if(trans.P_rdata !== expected) begin
        `uvm_error("APB_SCB",
                   $sformatf("READ MISMATCH: Addr=%0d Expected=%0h Got=%0h",
                              trans.P_addr, expected, trans.P_rdata))
      end
      else begin
        `uvm_info("APB_SCB",
                  $sformatf("READ OK: Addr=%0d Data=%0h",
                            trans.P_addr, trans.P_rdata),
                  UVM_LOW)
      end
    end
  endfunction

endclass

`endif
