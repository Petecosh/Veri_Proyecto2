class gen_secuencia extends uvm_sequence;

  `uvm_object_utils(gen_secuencia);  // Registrar en la fabrica
  
  // Funcion constructora
  function new(string name = "gen_secuencia");
    super.new(name);
  endfunction

  // Cantidad de sequence items
  rand int cantidad_item;

  // Constriant para randomizar cantidad de sequence items
  constraint const_cantidad {cantidad_item < 500; cantidad_item > 200;}

  // Ciclo for para randomizar una determinada cantidad de sequence items
  virtual task body();
    for (int i = 0; i < cantidad_item; i++) begin
      item_seq item = item_seq::type_id::create("item");
      start_item(item);
      item.randomize();
      `uvm_info("SEQ", $sformatf("Generado nuevo item: %s", item.print()), UVM_HIGH);
      $display("Cantidad de items generados: %0d", cantidad_item);
      finish_item(item);
    end
    `uvm_info("SEQ", $sformatf("Completada generacion de %0d items", cantidad_item), UVM_LOW);
  endtask

endclass