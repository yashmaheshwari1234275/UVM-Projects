`ifndef APB_MONITOR_SV
`define APB_MONITOR_SV

class apb_monitor extends uvm_monitor;

  virtual apb_if.MON_MP vif;

  uvm_analysis_port #(apb_seq_item) mon_ap;

  `uvm_component_utils(apb_monitor)

  function new(string name="apb_monitor", uvm_component parent=null);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual apb_if.MON_MP)::get(this, "", "vif", vif))
      `uvm_fatal("APB_MON", "Monitor interface not found!")
  endfunction


  // ------------------------------------------------------
  // Main Monitoring Task
  // ------------------------------------------------------
  task run_phase(uvm_phase phase);
    apb_seq_item trans;

    forever begin
      @(posedge vif.P_clk);

      // Detect SETUP phase
      if(vif.P_selx && !vif.P_enable) begin
        trans = apb_seq_item::type_id::create("trans");

        trans.P_addr   = vif.P_addr;
        trans.P_write  = vif.P_write;
        trans.P_wdata  = vif.P_wdata;

        // Move to ACCESS phase
        @(posedge vif.P_clk);

        if(vif.P_enable) begin
          wait(vif.P_ready == 1'b1);

          // Capture slave response
          trans.P_rdata  = vif.P_rdata;
          trans.P_slverr = vif.P_slverr;
          trans.P_ready  = vif.P_ready;

          // Send to scoreboard
          mon_ap.write(trans);
        end
      end
    end

  endtask

endclass

`endif
