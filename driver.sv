class driver extends uvm_driver #(item_seq);

  `uvm_component_utils(driver)  // Registrar en la fabrica

  // Funcion constructora
  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual interfaz vif; // Interfaz del DUT

  // Funcion de fase Build, si no se encontro la interfaz se cae la simulacion
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual interfaz)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "No se obtuvo la vif");
  endfunction

  // Funcion de fase Run
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      item_seq item_drv;                     // Item obtenido del sequencer
      `uvm_info("DRV", $sformatf("Esperando item del sequencer"), UVM_HIGH);
      seq_item_port.get_next_item(item_drv); // Sacar el siguiente item del sequencer
      drive_item(item_drv);                  // Aplicar funcion drive
      seq_item_port.item_done();             // Indicar que se termino de procesar el item
    end
  endtask

  // Funcion de drive
  virtual task drive_item(item_seq item_drv);

    int random_delay = $urandom_range(0, 10); // Genera un delay aleatorio entre 0 y 10 ciclos

    // Aplica el delay aleatorio
    `uvm_info("DRV", $sformatf("Aplicando delay aleatorio: %0d ciclos", random_delay), UVM_HIGH);
    repeat(random_delay) @(vif.clk);

    // Enviar datos a la interfaz
    vif.fp_X <= item_drv.fp_X;
    vif.fp_Y <= item_drv.fp_Y;
    vif.r_mode <= item_drv.r_mode;
  endtask
endclass
