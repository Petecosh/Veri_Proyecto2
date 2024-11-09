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

  uvm_analysis_imp #(item_seq, scoreboard) m_analysis_imp;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  virtual function write(item_seq item_sc);  

    sign_sc = item_sc.fp_X[31] ^ item_sc.fp_Y[31];
    exp_sc = item_sc.fp_X[30:23] + item_sc.fp_Y[30:23] - 8'b0111_1111;

    frac_X = {1'b1, item_sc.fp_X[22:0]};
    frac_Y = {1'b1, item_sc.fp_Y[22:0]};

    frac_sc = frac_X * frac_Y;

    if (frac_sc[47]) begin
        frac_sc = frac_sc >> 1;
        exp_sc = exp_sc + 1;
    end

    sc_result = {sign_sc, exp_sc, frac_sc[46:24]};

    `uvm_info("SCBD", $sformatf("fp_X = %0d, fp_Y = %0d, fp_Z = %0d, r_mode = %0d, ovrf = %0d, udrf = %0d", 
                                 item_sc.fp_X, item_sc.fp_Y, item_sc.fp_Z, item_sc.r_mode, item_sc.ovrf, item_sc.udrf), UVM_LOW)
    
    if(item_sc.fp_Z != sc_result) begin
      `uvm_error("SCBD",$sformatf("ERROR ! Result_dut = %0d Result_sc = %0d", item_sc.fp_Z, sc_result))
      $display("[%g] Resultado Signo: fp_Z = %0h, sc_result = %0h", $time, item_sc.fp_Z[31], sc_result[31]);
      $display("[%g] Resultado Exponente: fp_Z = %0h, sc_result = %0h", $time, item_sc.fp_Z[30:23], sc_result[30:23]);
      $display("[%g] Resultado Fraccion: fp_Z = %0h, sc_result = %0h", $time, item_sc.fp_Z[22:0], sc_result[22:0]);
      
    end else begin
      `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %0d Result_sc = %0d", item_sc.fp_Z, sc_result), UVM_HIGH)
    end

  endfunction

endclass