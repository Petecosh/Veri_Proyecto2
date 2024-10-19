class agente extends uvm_agent;

  `uvm_component_utils(agente)

  function new(string name = "agente", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  driver  driver_inst;
  monitor monitor_inst;
  uvm_sequencer #(item_seq) sequencer_inst;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer_inst = uvm_sequencer#(item_seq)::type_id::create("sequencer_inst",this);
    driver_inst = driver::type_id::create("driver_inst",this);
    monitor_inst = monitor::type_id::create("monitor_inst",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver_inst.seq_item_port.connect(sequencer_inst.seq_item_export);
  endfunction

endclass 