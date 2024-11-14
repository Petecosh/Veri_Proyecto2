class driver extends uvm_driver #(item_seq);

  `uvm_component_utils(driver)

  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual interfaz vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual interfaz)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "No se obtuvo la vif");
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      item_seq item_drv;
      `uvm_info("DRV", $sformatf("Esperando item del sequencer"), UVM_HIGH);
      seq_item_port.get_next_item(item_drv);
      drive_item(item_drv);
      seq_item_port.item_done();
    end
  endtask

  virtual task drive_item(item_seq item_drv);
    // Genera un delay aleatorio entre 0 y 10 ciclos
    int random_delay = $urandom_range(0, 10);

    // Aplica el delay aleatorio
    `uvm_info("DRV", $sformatf("Aplicando delay aleatorio: %0d ciclos", random_delay), UVM_HIGH);
    repeat(random_delay) @(vif.clk);

    // Enviar señales al DUT
    vif.fp_X <= item_drv.fp_X;
    vif.fp_Y <= item_drv.fp_Y;
    vif.r_mode <= item_drv.r_mode;
  endtask
endclass
