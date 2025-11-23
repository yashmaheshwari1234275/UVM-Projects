`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

class apb_driver extends uvm_driver #(apb_seq_item);

  virtual apb_if vif;

  `uvm_component_utils(apb_driver)

  function new(string name="apb_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("APB_DRV", "Virtual interface not found for driver")
  endfunction

  task run_phase(uvm_phase phase);
    apb_seq_item tr;
    forever begin
      seq_item_port.get_next_item(tr);
      drive_transfer(tr);
      seq_item_port.item_done();
    end
  endtask

  task drive_transfer(apb_seq_item tr);
    vif.P_selx   <= 1'b1;
    vif.P_enable <= 1'b0;
    vif.P_write  <= tr.P_write;
    vif.P_addr   <= tr.P_addr;
    vif.P_wdata  <= tr.P_wdata;

    @(posedge vif.P_clk);

    vif.P_enable <= 1'b1;

    @(posedge vif.P_clk);
    wait(vif.P_ready == 1'b1);

    tr.P_rdata  = vif.P_rdata;
    tr.P_slverr = vif.P_slverr;
    tr.P_ready  = vif.P_ready;

    @(posedge vif.P_clk);

    vif.P_selx   <= 1'b0;
    vif.P_enable <= 1'b0;
  endtask

endclass

`endif
