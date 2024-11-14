class item_seq extends uvm_sequence_item;

  `uvm_object_utils(item_seq)

  rand bit [2:0] r_mode;
  rand bit [31:0] fp_X;
  rand bit [31:0] fp_Y;
  bit [31:0] fp_Z;
  bit ovrf;
  bit udrf;

  virtual function string print();
    return $sformatf("fp_X = %h, fp_Y = %h, fp_Z = %h, R_mode = %h, Ovrf = %h, Udrf = %h", fp_X, fp_Y, fp_Z, r_mode, ovrf, udrf);
  endfunction

  function new(string name = "item_seq");
    super.new(name);
  endfunction

  constraint const_redondeo {r_mode <= 4;}

  constraint const_dist {fp_Y[30:0] dist {31'b00000000_00000000000000000000000 := 10, 
                                          31'b11111111_00000000000000000000000 := 10,
                                          31'b11111111_10000000000000000000000 := 10,
                                          [31'b0:31'b1111111111111111111111111111111] :/ 70};}

endclass