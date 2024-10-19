class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)
  
  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  uvm_analysis_imp #(item_seq, scoreboard) m_analysis_imp;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  virtual function write(item_seq item_sc);

    //bit [7:0] exp_sc;
    //bit [22:0] frac_sc;
    //bit sign_sc;
    //bit [32:0] sc_result;

    //sign_sc = item_sc.fp_X[31] ^ item_sc.fp_Y[31];
    //exp_sc = item_sc.fp_X[30:23] + item_sc.fp_Y[30:23] - 8'b0111_1111;
    //frac_sc = item_sc.fp_X[22:0] * item_sc.fp_Y[22:0];
    //sc_result = {sign_sc, exp_sc, frac_sc};
    int sc_result;
    sc_result = 0;

    `uvm_info("SCBD", $sformatf("fp_X = %0d, fp_Y = %0d, fp_Z = %0d r_mode = %0d, ovrf = %0d, udrf = %0d", 
                                 item_sc.fp_X, item_sc.fp_Y, item_sc.fp_Z, item_sc.r_mode, item_sc.ovrf, item_sc.udrf), UVM_LOW)
    
    if(item_sc.result != sc_result) begin
      `uvm_error("SCBD",$sformatf("ERROR ! Result_dut = %0d Result_sc = %0d", item_sc.fp_Z, sc_result))
    end else begin
      `uvm_info("SCBD",$sformatf("PASS ! Result_dut = %0d Result_sc = %0d", item_sc.fp_Z, sc_result), UVM_HIGH)
    end

  endfunction

endclass