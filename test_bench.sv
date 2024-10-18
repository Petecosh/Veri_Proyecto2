//`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "multiplicador_32_bits_FP_IEEE.sv"
`include "interfaz.sv"
`include "sequence_item.sv"
`include "secuencia.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agente.sv"
`include "scoreboard.sv"
`include "ambiente.sv"
`include "test.sv"

module tb;

  reg clk;

  always #10 clk =~ clk;
  interfaz _if (clk);

  top dut (.clk(clk),
           .fp_X(_if.fp_X),
           .fp_Y(_if.fp_Y),
           .fp_Z(_if.fp_Z),
           .r_mode(_if.r_mode),
           .ovrf(_if.ovrf),
           .udrf(_if.udrf));

  initial begin
    clk <= 0;
    uvm_config_db#(virtual interfaz)::set(null, "uvm_test_top", "vif", _if);
    run_test();
  end
endmodule