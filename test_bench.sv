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
  bit [30:0] inf_tb;      // Valor especial infinito para comparacion
  bit [30:0] zero_tb;     // Valor especial cero para comparacion
  bit [30:0] NaN_tb;      // Valor especial NaN para comparacion

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
    inf_tb = 31'b11111111_00000000000000000000000;  // Valor especial infinito
    zero_tb = 31'b00000000_00000000000000000000000; // Valor especial cero
    NaN_tb = 31'b11111111_10000000000000000000000;  // Valor especial NaN
    uvm_config_db#(virtual interfaz)::set(null, "uvm_test_top", "vif", _if); // Agregar interfaz al config_db
    run_test();                  // Correr el test
  end

  property cero_por_inf;
    @(posedge clk)
    (((_if.fp_X[30:0]==zero_tb) && (_if.fp_Y[30:0]==inf_tb)) || ((_if.fp_X[30:0]==zero_tb) && (_if.fp_Y[30:0]==inf_tb))) |-> (_if.fp_Z[30:0] == NaN_tb);
  endproperty

  property exp_unos;
    @(posedge clk)
    ((_if.fp_X[30:23] == 8'hff) || (_if.fp_Y[30:23] == 8'hff)) |-> ((_if.fp_Z[30:0] == NaN_tb) || (_if.fp_Z[30:0] == inf_tb));
  endproperty

  property exp_cero;
    @(posedge clk)
    (((_if.fp_X[30:23] == 8'h00) || (_if.fp_Y[30:23] == 8'h00)) && ((_if.fp_X[30:0]!=NaN_tb) && (_if.fp_Y[30:0]!=NaN_tb))) |-> (_if.fp_Z[30:0] == zero_tb); 
  endproperty

  property prop_overflow;
    @(posedge clk)
    (_if.ovrf) |-> ((_if.fp_Z[30:0] == NaN_tb) || (_if.fp_Z[30:0] == inf_tb));
  endproperty

  property prop_underflow;
    @(posedge clk)
    (_if.udrf) |-> (_if.fp_Z[30:0] == zero_tb);
  endproperty

  assert property(cero_por_inf) else $display("TB, Propiedad cero_por_inf no cumplida, fp_X: %h fp_Y: %h fp_Z: %h", _if.fp_X, _if.fp_Y, _if.fp_Z); 
  assert property(exp_unos) else $display("TB, Propiedad exp_unos no cumplida, fp_X: %h fp_Y: %h fp_Z: %h", _if.fp_X, _if.fp_Y, _if.fp_Z);
  assert property(exp_cero) else $display("TB, Propiedad exp_cero no cumplida, fp_X: %h fp_Y: %h fp_Z: %h", _if.fp_X, _if.fp_Y, _if.fp_Z);
  assert property(prop_overflow) else $display("TB, Propiedad prop_overflow no cumplida, fp_X: %h fp_Y: %h fp_Z: %h", _if.fp_X, _if.fp_Y, _if.fp_Z);
  assert property(prop_underflow) else $display("TB, Propiedad prop_underflow no cumplida, fp_X: %h fp_Y: %h fp_Z: %h", _if.fp_X, _if.fp_Y, _if.fp_Z);
endmodule