class gen_secuencia extends uvm_sequence;

  `uvm_object_utils(gen_secuencia);
  
  function new(string name = "gen_secuencia");
    super.new(name);
  endfunction

  rand int cantidad_item;
  rand int delay;

  constraint const_cantidad {250 < cantidad_item < 500;}
  constraint const_delay {1 < delay < 10;}

  virtual task body();
    for (int i = 0; i < cantidad_item; i++) begin
      delay.randomize();
      $display("delay = %d",delay);
      while (delay > 0) begin
        delay = delay - 1;
        #10
      end 
      item_seq item = item_seq::type_id::create("item");
      start_item(item);
      item.randomize();
      `uvm_info("SEQ", $sformatf("Generado nuevo item: %s", item.print()), UVM_HIGH);
      finish_item(item);
    end
    `uvm_info("SEQ", $sformatf("Completada generacion de %0d items", cantidad_item), UVM_LOW);
  endtask

endclass