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
endmodule