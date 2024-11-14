class agente extends uvm_agent;

  `uvm_component_utils(agente)    // Registrar en la fabrica

  // Funcion constructora
  function new(string name = "agente", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  driver  driver_inst;                       // Instancia del driver
  monitor monitor_inst;                      // Instancia del monitor
  uvm_sequencer #(item_seq) sequencer_inst;  // Instancia del sequencer

  // Funcion de fase Build, se crea el driver, monitor y sequencer
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer_inst = uvm_sequencer#(item_seq)::type_id::create("sequencer_inst",this);
    driver_inst = driver::type_id::create("driver_inst",this);
    monitor_inst = monitor::type_id::create("monitor_inst",this);
  endfunction

  // Funcion de fase Connect, se conecta el puerto del driver con el puerto del sequencer
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver_inst.seq_item_port.connect(sequencer_inst.seq_item_export);
  endfunction

endclass 