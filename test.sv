class base_test extends uvm_test;

  `uvm_component_utils(base_test)
  
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  ambiente ambiente_inst;
  gen_secuencia  secuencia;
  virtual interfaz  vif;

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    ambiente_inst = ambiente::type_id::create("ambiente_inst", this);

    if(!uvm_config_db#(virtual interfaz)::get(this, "", "vif", vif))
      `uvm_fatal("TEST","No se obtuvo la vif")
    uvm_config_db#(virtual interfaz)::set(this, "ambiente_inst.agente_inst.*","vif",vif);

    secuencia = gen_secuencia::type_id::create("secuencia");
    secuencia.randomize();

  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //apply_reset();
    secuencia.start(ambiente_inst.agente_inst.sequencer_inst);
    #200;
    phase.drop_objection(this);
  endtask

  virtual task apply_reset();
  endtask
endclass