class monitor extends uvm_monitor;

  `uvm_component_utils(monitor)    // Registrar en la fabrica

  bit [30:0] inf = 31'b11111111_00000000000000000000000;             // Valor especial infinito
  bit [30:0] zero = 31'b00000000_00000000000000000000000;            // Valor especial cero
  bit [30:0] NaN = 31'b11111111_10000000000000000000000;             // Valor especial NaN

  // Funcion constructora
  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  uvm_analysis_port #(item_seq) mon_analysis_port;  // Puerto de analisis
  virtual interfaz vif;                             // Interfaz del DUT

  // Funcion de fase Build, si no se encontro la interfaz se cae la simulacion
  // Tambien se inicializa el puerto de analisis
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual interfaz)::get(this, "", "vif", vif))
      `uvm_fatal("MON","No se obtuvo la vif")
    mon_analysis_port = new("mon_analysis_port", this);
  endfunction

  // Funcion de fase Run, se leen los datos de la interfaz
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(vif.clk) begin
          item_seq item_monitor = item_seq::type_id::create("item_monitor");
          item_monitor.fp_X = vif.fp_X;
          item_monitor.fp_Y = vif.fp_Y;
          item_monitor.fp_Z = vif.fp_Z;
          item_monitor.r_mode = vif.r_mode;
          item_monitor.ovrf = vif.ovrf;
          item_monitor.udrf = vif.udrf;
          mon_analysis_port.write(item_monitor);
          `uvm_info("MON", $sformatf("Leyo item %s", item_monitor.print()), UVM_HIGH)
      end
    end
  endtask
endclass