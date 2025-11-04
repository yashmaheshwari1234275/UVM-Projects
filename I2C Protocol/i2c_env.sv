//=================== i2c_env.sv ===================//
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "i2c_agent.sv"
`include "i2c_scoreboard.sv"

class i2c_env extends uvm_env;
  `uvm_component_utils(i2c_env)

  i2c_agent       agt;
  i2c_scoreboard  sb;

  function new(string name="i2c_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = i2c_agent::type_id::create("agt", this);
    sb  = i2c_scoreboard::type_id::create("sb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    // Connect monitor output to scoreboard input (observed data)
    agt.mon.mon_ap.connect(sb.mon_port);

    // Connect driver expected data to scoreboard (expected queue)
    if (agt.is_active == UVM_ACTIVE)
      agt.drv.drv_ap.connect(sb.exp_port);
  endfunction

endclass
