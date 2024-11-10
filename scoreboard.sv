class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)
  
  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  bit sign_sc;
  bit [7:0] exp_sc;
  bit [23:0] frac_X; 
  bit [23:0] frac_Y;
  bit [47:0] frac_sc;
  bit [31:0] sc_result;
  bit [30:0] sc_overflow;
  bit [30:0] sc_underflow;
  bit [30:0] NaN;

  bit [26:0] frc_Z_norm; 
  bit sticky_bit;

  uvm_analysis_imp #(item_seq, scoreboard) m_analysis_imp;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  virtual function write(item_seq item_sc);  

    sc_overflow = 31'b11111111_00000000000000000000000;
    sc_underflow = 31'b00000000_00000000000000000000000;
    NaN = 31'b11111111_10000000000000000000000;

    sign_sc = item_sc.fp_X[31] ^ item_sc.fp_Y[31];
    exp_sc = item_sc.fp_X[30:23] + item_sc.fp_Y[30:23] - 8'b0111_1111;

    frac_X = {1'b1, item_sc.fp_X[22:0]};
    frac_Y = {1'b1, item_sc.fp_Y[22:0]};

    frac_sc = frac_X * frac_Y;

    // Mux normalizer
    if (!(frac_sc[47])) begin
        frac_sc = {frac[46:0], 0}
        //exp_sc = exp_sc + 1;
    end

    // OR Logic
    if (frac_sc[21:0] == 0) begin
        sticky_bit = 1;
    end else begin
        sticky_bit = 0;
    end

    frc_Z_norm = {frac_sc[47:22], sticky_bit};

    `uvm_info("SCBD", $sformatf("fp_X = %h, fp_Y = %h, fp_Z = %h, r_mode = %h, ovrf = %h, udrf = %h", 
                                 item_sc.fp_X, item_sc.fp_Y, item_sc.fp_Z, item_sc.r_mode, item_sc.ovrf, item_sc.udrf), UVM_LOW)

    case (item_sc.r_mode)

      0: begin
          
      end

      1: begin
            
      end

      2: begin
        if (item_sc.fp_Z[31]) begin
            frc_Z_norm[26:3] = frc_Z_norm[26:3] + 1'b1;
        end
      end

      3: begin
        if (!(item_sc.fp_Z[31])) begin
            frc_Z_norm[26:3] = frc_Z_norm[26:3] + 1'b1;
        end
      end

      4: begin
        if (frc_Z_norm[2]) begin
            frc_Z_norm[26:3] = frc_Z_norm[26:3] + 1'b1;
        end
      end

      default: begin
          `uvm_fatal("SCBD","Modo de redondeo invalido")
      end
    
    endcase

    sc_result = {sign_sc, exp_sc, frc_Z_norm[26:3]};
    
    if(item_sc.fp_Z != sc_result) begin

      if (item_sc.ovrf) begin 

        if (item_sc.fp_Z[30:0] != sc_overflow) begin
            `uvm_error("SCBD",$sformatf("ERROR ! Result_dut = %h Result_sc = %h", item_sc.fp_Z, sc_overflow))
            $display("[%g] Resultado Signo: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[31], sc_result[31]);
            $display("[%g] Resultado Exponente: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[30:23], sc_overflow[30:23]);
            $display("[%g] Resultado Fraccion: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[22:0], sc_overflow[22:0]);
        end else begin
            `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %h Result_sc = %h", item_sc.fp_Z[30:0], sc_overflow), UVM_HIGH);
        end
        
      end else if (item_sc.udrf) begin

        if (item_sc.fp_Z[30:0] != sc_underflow) begin
            `uvm_error("SCBD",$sformatf("ERROR ! Result_dut = %h Result_sc = %h", item_sc.fp_Z, sc_underflow))
            $display("[%g] Resultado Signo: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[31], sc_result[31]);
            $display("[%g] Resultado Exponente: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[30:23], sc_underflow[30:23]);
            $display("[%g] Resultado Fraccion: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[22:0], sc_underflow[22:0]);
        end else begin
            `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %h Result_sc = %h", item_sc.fp_Z[30:0], sc_underflow), UVM_HIGH);
        end

      end else if (item_sc.fp_Z[30:0] == NaN) begin
        `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %h Result_sc = %h", item_sc.fp_Z[30:0], NaN), UVM_HIGH);

      end else begin
        `uvm_error("SCBD",$sformatf("ERROR ! Result_dut = %h Result_sc = %h", item_sc.fp_Z, sc_result))
        $display("[%g] Resultado Signo: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[31], sc_result[31]);
        $display("[%g] Resultado Exponente: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[30:23], sc_result[30:23]);
        $display("[%g] Resultado Fraccion: fp_Z = %h, sc_result = %h", $time, item_sc.fp_Z[22:0], sc_result[22:0]);
      end
      
    end else begin
      `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %h Result_sc = %h", item_sc.fp_Z, sc_result), UVM_HIGH)
    end

  endfunction

endclass