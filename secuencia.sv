class gen_secuencia extends uvm_sequence;

  `uvm_object_utils(gen_secuencia);
  
  function new(string name = "gen_secuencia");
    super.new(name);
  endfunction

  rand int cantidad_item;

  constraint const_cantidad {10 < cantidad_item < 50;}

  virtual task body();
    for (int i = 0; i < cantidad_item; i++) begin
      item_secuencia item = item_secuencia::type_id::create("item");
      start_item(item);
      item.randomize();
      `uvm_info("SEQ", $sformatf("Generado nuevo item: %s", item.print()), UVM_HIGH);
      finish_item(item);
    end
    `uvm_info("SEQ", $sformatf("Completada generacion de %0d items", cantidad_item), UVM_LOW);
  endtask

endclass