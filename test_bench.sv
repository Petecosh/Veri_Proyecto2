//`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "multiplicador_32_bits_FP_IEEE.sv"
`include "interfaz.sv"
`include "sequence_item.sv"
`include "secuencia.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agente.sv"
`include "scoreboard.sv"
`include "ambiente.sv"
`include "test.sv"

module tb;   // Modulo testbench

  reg clk;   // Reloj

  always #10 clk =~ clk;  // El reloj cambia cada 10 ciclos de simulacion
  interfaz _if (clk);     // Interfaz del DUT

  top dut (.clk(clk),            // Instancia del DUT, se conecta a la interfaz
           .fp_X(_if.fp_X),      // Input fp_X
           .fp_Y(_if.fp_Y),      // Input fp_Y
           .fp_Z(_if.fp_Z),      // Output fp_Z
           .r_mode(_if.r_mode),  // Modo de redondeo
           .ovrf(_if.ovrf),      // Bandera de overflow
           .udrf(_if.udrf));     // Bandera de underflow

  initial begin                  // Initial begin
    clk <= 0;                    // Reloj en 0
    uvm_config_db#(virtual interfaz)::set(null, "uvm_test_top", "vif", _if); // Agregar interfaz al config_db
    run_test();                  // Correr el test
  end

  property exp_unos;
    @(posedge clk)
    ((fp_X[30:23] == 8'hff) || (fp_Y[30:23] == 8'hff)) |-> (fp_Z[30:0] == (NaN || inf));
  endproperty

  property exp_cero;
    @(posedge clk)
    ((fp_X[30:23] == 8'h00) || (fp_Y[30:23] == 8'h00)) |-> (fp_Z[30:0] == zero); 
  endproperty

  property prop_overflow;
    @(posedge clk)
    (ovrf) |-> (fp_Z[30:0] == inf);
  endproperty

  property prop_underflow;
    @(posedge clk)
    (udrf) |-> (fp_Z[30:0] == zero); 
  endproperty

  assert property(exp_unos) else `uvm_error("TB", $sformatf("Propiedad exp_unos no cumplida, fp_X: %h fp_Y: %h fp_Z: %h", fp_X, fp_Y, fp_Z), UVM_HIGH);
  assert property(exp_cero) else `uvm_error("TB", $sformatf("Propiedad exp_cero no cumplida, fp_X: %h fp_Y: %h fp_Z: %h", fp_X, fp_Y, fp_Z), UVM_HIGH);
  assert property(prop_overflow) else `uvm_error("TB", $sformatf("Propiedad prop_overflow no cumplida, fp_X: %h fp_Y: %h fp_Z: %h", fp_X, fp_Y, fp_Z), UVM_HIGH);
  assert property(prop_underflow) else `uvm_error("TB", $sformatf("Propiedad prop_underflow no cumplida, fp_X: %h fp_Y: %h fp_Z: %h", fp_X, fp_Y, fp_Z), UVM_HIGH);
endmodule