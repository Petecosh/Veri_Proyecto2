interface interfaz (input bit clk);
  logic [2:0] r_mode;  // Modo de redondeo
  logic [32:0] fp_X;   // Input fp_X
  logic [32:0] fp_Y;   // Input fp_Y
  logic [32:0] fp_Z;   // Output fp_Z
  logic ovrf;          // Bandera de overflow
  logic udrf;          // Bandera de underflow
endinterface