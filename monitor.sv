class monitor extends uvm_monitor;

  `uvm_component_utils(monitor)

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  uvm_analysis_port #(item_secuencia) mon_analysis_port;
  virtual interfaz vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual interfaz)::get(this, "", "vif", vif))
      `uvm_fatal("MON","No se obtuvo la vif")
    mon_analysis_port = new("mon_analysis_port", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(vif.clk);
        item_secuencia item_mon = item_secuencia::type_id::create("item_mon");
        item_mon.fp_X = vif.fp_X;
        item_mon.fp_Y = vif.fp_Y;
        item_mon.fp_Z = vif.fp_Z;
        item_mon.r_mode = vif.r_mode;
        item_mon.ovrf = vif.ovrf;
        item_mon.udrf = vif.udrf;
        mon_analysis_port.write(item_mon);
        `uvm_info("MON", $sformatf("Leyo item %s", item_mon.print()), UVM_HIGH)
    end
  endtask
endclass