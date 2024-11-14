class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)  // Registrar en la fabrica

  // Funcion constructora
  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  bit sign_sc;             // Signo calculado por el scoreboard
  bit [15:0] exp_sc;       // Exponente calculado por el scoreboard
  bit [23:0] frac_X;       // Fraccion del valor fp_X
  bit [23:0] frac_Y;       // Fraccion del valor fp_Y
  bit [47:0] frac_sc;      // Fraccion de resultado Z calculada sin normalizar
  bit [31:0] sc_result;    // Resultado de la multiplicacion calculado por el scoreboard
  bit [30:0] inf;          // Valor especial infinito para comparacion
  bit [30:0] zero;         // Valor especial cero para comparacion
  bit [30:0] NaN;          // Valor especial NaN para comparacion

  bit [26:0] frc_Z_norm;   // Fraccion de resultado Z normalizado
  bit sticky_bit;          // Sticky bit

  bit [31:0] result_aux;   // Resultado auxiliar para guardar en un array
  [31:0] almacen[$];       // Array para guardar en un CSV

  uvm_analysis_imp #(item_seq, scoreboard) m_analysis_imp;  // Puerto de analisis

  // Funcion de fase Build, se inicializa el puerto de analisis
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  virtual function write(item_seq item_sc);                 // Funcion de escritura del scoreboard

    inf = 31'b11111111_00000000000000000000000;             // Valor especial infinito
    zero = 31'b00000000_00000000000000000000000;            // Valor especial cero
    NaN = 31'b11111111_10000000000000000000000;             // Valor especial NaN

    sign_sc = item_sc.fp_X[31] ^ item_sc.fp_Y[31];          // Calculo del signo para Z
    exp_sc = item_sc.fp_X[30:23] + item_sc.fp_Y[30:23] - 8'b0111_1111; // Calculo del exponente para resultado z

    frac_X = {1'b1, item_sc.fp_X[22:0]};     // Obtener la fraccion del valor fp_X
    frac_Y = {1'b1, item_sc.fp_Y[22:0]};     // Obtener la fraccion del valor fp_Y

    frac_sc = frac_X * frac_Y;               // Multiplicar las fracciones X * Y, se obtiene secuencia de 47 bits

    if (frac_sc[47] == 1) begin              // Si el primer bit de la fraccion sin normalizar es 1...
      frac_sc = frac_sc >> 1;                // Correr 1 vez a la derecha la fraccion sin normalizar
      exp_sc[7:0] = exp_sc[7:0] + 1;         // Al exponente calculado se le suma 1
    end else begin                           // Si ese no es el caso...   
      frac_sc = {frac_sc[46:1], 1'b0};       // Tomar los bits 46:1 y concatenar un 0 al final
    end

    // Logica de OR
    if (frac_sc[21:0] == 0) begin            // Si los bits 21:0 son cero...
        sticky_bit = 0;                      // Sticky bit en cero
    end else begin                           // Si ese no es el caso
        sticky_bit = 1;                      // Sticky bit en 1
    end

    frc_Z_norm = {frac_sc[47:22], (frac_sc[23] | sticky_bit)};   // Calcular fraccion de resultado Z normalizado

    `uvm_info("SCBD", $sformatf("fp_X = %h, fp_Y = %h, fp_Z = %h, r_mode = %h, ovrf = %h, udrf = %h", 
                                 item_sc.fp_X, item_sc.fp_Y, item_sc.fp_Z, item_sc.r_mode, item_sc.ovrf, item_sc.udrf), UVM_LOW)

    case (item_sc.r_mode)  // Case para modo de redondeo

      0: begin                                                 // Modo de redondeo 0
          if (frc_Z_norm[1]) begin                             // Si el round bit es 1...
            if (frc_Z_norm[0]) begin                           // Si el (guard ^ sticky bit) es 1..
              frc_Z_norm[24:2] = frc_Z_norm[24:2] + 1'b1;      // Se suma 1, se redondea
            end else begin                                     // Si el (guard ^ sticky bit) no es 1..
                if (frc_Z_norm[2] == 1'b1) begin               // Pero el round bit es 1...
                  frc_Z_norm[24:2] = frc_Z_norm[24:2] + 1'b1;  // Redondea hacia arriba solo si es impar
                end
            end
          end 
      end

      1: begin                                                 // Modo de redondeo 1, no se redondea
                   
      end

      2: begin                                                 // Modo de redondeo 2, hacia menos infinito    
        if (sign_sc) begin                                     // Si el signo es 1 (negativo)...
            frc_Z_norm[24:2] = frc_Z_norm[24:2] + 1'b1;        // Se suma 1, se redondea
        end
      end

      3: begin                                                 // Modo de redondeo 3, hacia mas infinito
        if (!(sign_sc)) begin                                  // Si el signo es 0 (positivo)...
            frc_Z_norm[24:2] = frc_Z_norm[24:2] + 1'b1;        // Se suma 1, se redondea
        end
      end

      4: begin                                                 // Modo de redondeo 4, evalua el round bit
        if (frc_Z_norm[1]) begin                               // Si el round bit es 1...
            frc_Z_norm[24:2] = frc_Z_norm[24:2] + 1'b1;        // Se suma 1, se redondea
        end
      end

      default: begin                                           // Caso default, por si el modo de redondeo es invalido
          `uvm_fatal("SCBD","Modo de redondeo invalido")
      end
    
    endcase

    sc_result = {sign_sc, exp_sc[7:0], frc_Z_norm[24:2]};      // Concatenar el signo, exponente y fraccion calculados
    
    if(item_sc.fp_Z != sc_result) begin                        // Si el resultado del DUT y del scoreboard son diferentes...


      // Si el exponente de algun multiplicando es 1111_1111...
      // Puede ser un infinito...
      // Puede ser un NaN...
      // Si no es infinito o NaN, esta mal
      if (item_sc.fp_X[30:23] == 8'hff || item_sc.fp_Y[30:23] == 8'hff) begin
        if (item_sc.fp_Z[30:0] == inf) begin               
          `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %h Result_sc = %h", item_sc.fp_Z[30:0], zero), UVM_HIGH);
          result_aux = {sign_sc, inf};
          almacen.pushback(result_aux);
        end else if (item_sc.fp_Z[30:0] == NaN) begin
          `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %h Result_sc = %h", item_sc.fp_Z[30:0], zero), UVM_HIGH);
          result_aux = {sign_sc, NaN};
          almacen.pushback(result_aux);
        end else begin
          `uvm_error("SCBD",$sformatf("ERROR ! Result_dut = %h Result_sc = %h", item_sc.fp_Z, NaN))
          $display("[%g] Resultado Signo: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[31], sc_result[31]);
          $display("[%g] Resultado Exponente: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[30:23], NaN[30:23]);
          $display("[%g] Resultado Fraccion: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[22:0], NaN[22:0]);
        end
      end
      
      // Si el exponente de algun mutiplicando es 0...
      // Si el resultado del DUT es diferente de 0, esta mal
      else if (item_sc.fp_X[30:23] == 8'h00 || item_sc.fp_Y[30:23] == 8'h00) begin 
        if (item_sc.fp_Z[30:0] != zero) begin         
            `uvm_error("SCBD",$sformatf("ERROR ! Result_dut = %h Result_sc = %h", item_sc.fp_Z, zero))
            $display("[%g] Resultado Signo: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[31], sc_result[31]);
            $display("[%g] Resultado Exponente: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[30:23], zero[30:23]);
            $display("[%g] Resultado Fraccion: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[22:0], zero[22:0]);
        end else begin
            `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %h Result_sc = %h", item_sc.fp_Z[30:0], zero), UVM_HIGH);
            result_aux = {sign_sc, NaN};
            almacen.pushback(result_aux);
        end
      end

      // Si se levanto la bandera de overflow...
      // Esto ocurre porque el exponente calculado fue mayor a 254
      // Si el resultado del DUT es diferente de infinito, esta mal
      else if (item_sc.ovrf) begin
        if (exp_sc > 254) begin
          if (item_sc.fp_Z[30:0] != inf) begin
              `uvm_error("SCBD",$sformatf("ERROR ! Result_dut = %h Result_sc = %h", item_sc.fp_Z, inf))
              $display("[%g] Resultado Signo: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[31], sc_result[31]);
              $display("[%g] Resultado Exponente: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[30:23], inf[30:23]);
              $display("[%g] Resultado Fraccion: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[22:0], inf[22:0]);
          end else begin
              `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %h Result_sc = %h", item_sc.fp_Z[30:0], inf), UVM_HIGH);
              result_aux = {sign_sc, inf};
              almacen.pushback(result_aux);
          end
        end
      end

      // Si se levanto la bandera de underflow...
      // Esto ocurre porque el exponente calculado fue menor o igual a 127
      // Si el resultado del DUT es diferente de 0, esta mal
      else if (item_sc.udrf) begin
        if ((item_sc.fp_X[30:23] + item_sc.fp_Y[30:23]) <= 127) begin
          if (item_sc.fp_Z[30:0] != zero) begin
              `uvm_error("SCBD",$sformatf("ERROR ! Result_dut = %h Result_sc = %h", item_sc.fp_Z, zero))
              $display("[%g] Resultado Signo: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[31], sc_result[31]);
              $display("[%g] Resultado Exponente: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[30:23], zero[30:23]);
              $display("[%g] Resultado Fraccion: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[22:0], zero[22:0]);
          end else begin
              `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %h Result_sc = %h", item_sc.fp_Z[30:0], zero), UVM_HIGH);
              result_aux = {sign_sc, zero};
              almacen.pushback(result_aux);
          end
        end
      end

      // Si no fue ninguno de los casos anteriores
      // Significa que la multiplicacion de valores normales estuvo mal
      else begin
        `uvm_error("SCBD",$sformatf("ERROR ! Result_dut = %h Result_sc = %h", item_sc.fp_Z, sc_result))
        $display("[%g] Resultado Signo: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[31], sc_result[31]);
        $display("[%g] Resultado Exponente: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[30:23], sc_result[30:23]);
        $display("[%g] Resultado Fraccion: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[22:0], sc_result[22:0]);
      end

    // Si el resultado del DUT y del scoreboard son iguales, hubo una multiplicacion normal y estuvo bien
    end else begin
      `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %h Result_sc = %h", item_sc.fp_Z, sc_result), UVM_HIGH)
      result_aux = sc_result;
      almacen.pushback(result_aux);
    end

  endfunction

endclass