class base_test extends uvm_test;

  `uvm_component_utils(base_test)  // Registrar en la fabrica
  
  // Funcion constructora
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  ambiente ambiente_inst;    // Instancia del ambiente
  gen_secuencia  secuencia;  // Instancia de la secuencia
  virtual interfaz vif;      // Interfaz del DUT

  // Funcion de fase Build
  // Se crea el agente
  // Si no se encontro la interfaz, se cae la simulacion
  // Se crea la secuencia y se randomiza
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    ambiente_inst = ambiente::type_id::create("ambiente_inst", this);

    if(!uvm_config_db#(virtual interfaz)::get(this, "", "vif", vif))
      `uvm_fatal("TEST","No se obtuvo la vif")
    uvm_config_db#(virtual interfaz)::set(this, "ambiente_inst.agente_inst.*","vif",vif);

    secuencia = gen_secuencia::type_id::create("secuencia");
    secuencia.randomize();

  endfunction


  // Funcion de fase Run
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