class ambiente extends uvm_env;

  `uvm_component_utils(ambiente)
  
  function new(string name = "ambiente", uvm_component parent = null);
    super.new(name,parent);
  endfunction

  agente  agente_inst;
  scoreboard scoreboard_inst;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agente_inst = agente::type_id::create("agente_inst",this);
    scoreboard_inst = scoreboard::type_id::create("scoreboard_inst",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agente_inst.monitor_inst.mon_analysis_port.connect(scoreboard_inst.m_analysis_imp);
  endfunction
endclass