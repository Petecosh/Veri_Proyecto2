class gen_secuencia extends uvm_sequence;

  `uvm_object_utils(gen_secuencia);
  
  function new(string name = "gen_secuencia");
    super.new(name);
  endfunction

  rand int cantidad_item;
  rand int delay;

  constraint const_cantidad {250 < cantidad_item < 500;}
  constraint const_delay {1 < delay < 10;}

  // Función para randomizar delay antes de cada item
  function void pre_randomize_delay();
    if (!randomize(delay)) begin
      `uvm_error("SEQ", "Fallo al randomizar delay");
    end
  endfunction

  virtual task body();
    // Generamos la cantidad de items especificada en `cantidad_item`
    for (int i = 0; i < cantidad_item; i++) begin
      begin
      // Randomizamos delay antes de cada item
      pre_randomize_delay();

      // Imprimimos el delay generado
      $display("delay = %d", delay);

      // Introducimos el delay en la simulación
      #(delay * 10);
      end begin
      // Creamos y procesamos el item
      item_seq item = item_seq::type_id::create("item");
      start_item(item);
      assert(item.randomize()) else `uvm_error("SEQ", "Fallo al randomizar item");
      `uvm_info("SEQ", $sformatf("Generado nuevo item: %s", item.print()), UVM_HIGH);
      finish_item(item);
      end
    end
    `uvm_info("SEQ", $sformatf("Completada generacion de %0d items", cantidad_item), UVM_LOW);
  endtask

endclass
