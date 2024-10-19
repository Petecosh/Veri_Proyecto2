//`timescale 1ns / 1ps

module half(A, B, S, Cout);
  
  input A, B;
  output S;
  output Cout;
  
  assign S = A ^ B;
  assign Cout = A & B;
  
endmodule

module full(A, B, C, S, Cout);
  
  input A, B, C;
  output S;
  output Cout;
  
  wire y1, y2, y3;
  
  assign y1 = A ^ B;
  assign S = y1 ^ C;
  assign y2 = y1 & C;
  assign y3 = A & B;
  assign Cout = y2 | y3;
  
endmodule

module encoder(x, sel);
  
  input [3:0]x;
  output [3:0]sel; //4Y, 2Y, 3Y, Y
  
  wire neta, netb, netc;
  
  assign neta = x[0] ^ x[1];
  assign netb = x[1] ^ x[2];
  assign netc = x[2] ^ x[3];
  
  assign sel[0] = ~(!neta | netc);
  assign sel[1] = ~(!neta | !netc);
  assign sel[2] = ~(neta | !netb);
  assign sel[3] = ~(neta | netb | !netc);
  
endmodule

module selector(x, y, Y3, pp);
  input [22:0]y;
  input [23:0]Y3;
  input [3:0]x; //x[3] = neg
  
  output [25:0]pp;
  
  wire [3:0]sel; //4Y, 2Y, 3Y, Y
  
  wire[25:0]Y, Y2, Y4;
  
  assign Y = {3'b001, y};
  assign Y2 = {2'b01, y, 1'b0};
  assign Y4 = {1'b1, y, 2'b00};
  
  encoder encoder(.x(x), .sel(sel));
  
  wire [25:0]net0, net1, net2, net3;
  
  assign net0 = sel[0] ? Y : 0;
  assign net1 = sel[1] ? {Y3[23], !Y3[23], Y3[22:0], y[0]} : 0;
  assign net2 = sel[2] ? Y2 : 0;
  assign net3 = sel[3] ? Y4 : 0;
  
  assign pp = (net0 | net1 | net2 | net3) ^ {26{x[3]}};
  
endmodule

module selector0(x, y, Y3, pp);
  input [22:0]y;
  input [23:0]Y3;
  input [2:0]x; //x[3] = neg
  
  output [25:0]pp;
  
  wire [3:0]sel; //4Y, 2Y, 3Y, Y
  
  wire[25:0]Y, Y2, Y4;
  
  assign Y = {3'b001, y};
  assign Y2 = {2'b01, y, 1'b0};
  assign Y4 = {1'b1, y, 2'b00};
  
  wire neta, netb, netc;
  
  assign neta = x[0];
  assign netb = x[0] ^ x[1];
  assign netc = x[1] ^ x[2];
  
  assign sel[0] = ~(!neta | netc);
  assign sel[1] = ~(!neta | !netc);
  assign sel[2] = ~(neta | !netb);
  assign sel[3] = ~(neta | netb | !netc);
  
  wire [25:0]net0, net1, net2, net3;
  
  assign net0 = sel[0] ? Y : 0;
  assign net1 = sel[1] ? {Y3[23], !Y3[23], Y3[22:0], y[0]} : 0;
  assign net2 = sel[2] ? Y2 : 0;
  assign net3 = sel[3] ? Y4 : 0;
  
  assign pp = (net0 | net1 | net2 | net3) ^ {26{x[2]}};
  
endmodule

module selector7(x, y, Y3, pp);
  input [22:0]y;
  input [23:0]Y3;
  input [2:0]x; //x[3] = neg
  
  output [25:0]pp;
  
  wire [3:0]sel; //4Y, 2Y, 3Y, Y
  
  wire[25:0]Y, Y2, Y4;
  
  assign Y = {3'b001, y};
  assign Y2 = {2'b01, y, 1'b0};
  assign Y4 = {1'b1, y, 2'b00};
  
  wire neta, netb, netc;
  
  assign neta = x[0] ^ x[1];
  assign netb = x[1] ^ x[2];
  assign netc = !x[2];
  
  assign sel[0] = ~(!neta | netc);
  assign sel[1] = ~(!neta | !netc);
  assign sel[2] = ~(neta | !netb);
  assign sel[3] = ~(neta | netb | !netc);
  
  wire [25:0]net0, net1, net2, net3;
  
  assign net0 = sel[0] ? Y : 0;
  assign net1 = sel[1] ? {Y3[23], !Y3[23], Y3[22:0], y[0]} : 0;
  assign net2 = sel[2] ? Y2 : 0;
  assign net3 = sel[3] ? Y4 : 0;
  
  assign pp = ~(net0 | net1 | net2 | net3);
  
endmodule

module Y3_gen(
  input [22:0]Y,
  output [23:0]Y3);
  
  assign Y3 = {1'b1, Y[22:1]} + Y;
  
endmodule

module booth(
  input [22:0]X, Y,
  output [26:0]pp[6:0],
  output [25:0]pp7,
  output [22:0]pp8);
  
  wire [23:0]Y3;
  
  Y3_gen Y3_gen(.Y(Y), .Y3(Y3));
  
  genvar i;
  for (i = 0; i < 9; i = i+1)begin
    if(i == 0) begin
      
      selector0 selector0(.x(X[3*i+2:i]), .y(Y), .Y3(Y3), .pp(pp[i][26:1]));
      assign pp[i][0] = X[3*i+2];
     
    end else if(i < 7) begin
      selector selector(.x(X[3*i+2:3*i-1]), .y(Y), .Y3(Y3), .pp(pp[i][26:1]));
      assign pp[i][0] = X[3*i+2];
      
      
    end else if(i < 8) begin
      
      selector7 selector7(.x(X[3*i+1:3*i-1]), .y(Y), .Y3(Y3), .pp(pp7));
      
      
    end else begin
      
      //selector selector(.x({3'b000, x[3*i-1]}), .y(y), .Y3(Y3), .pp(pp[i]));
      assign pp8 = Y;
      
    end
  end
  
endmodule

module REDUCTION1(
  input [26:0]pp0, pp1, pp2, pp3, pp4, pp5, pp6,
  input [25:0]pp7,
  input [22:0]pp8,
  
  output [47:0]red1_0,
  output [43:0]red1_1,
  output [38:0]red1_2,
  output [32:0]red1_3,
  output [26:0]red1_4,
  output [20:0]red1_5,
  output [14:0]red1_6,
  output [8:0]red1_7,
  output [2:0]red1_8);
  
  half half1_0[12:0](
    .A({pp0[23], pp0[20:19], pp0[17:16], pp0[14:13], pp0[11:10], pp0[8:7], pp0[5:4]}),
    
    .B({pp1[20], pp1[17:16], pp1[14:13], pp1[11:10], pp1[8:7], pp1[5:4], pp1[2:1]}),
    
    .S({red1_0[23], red1_0[20:19], red1_0[17:16], red1_0[14:13], red1_0[11:10], red1_0[8:7], red1_0[5:4]}),
    
    .Cout({red1_0[24], red1_0[21], red1_1[16], red1_0[18], red1_1[13], red1_0[15], red1_1[10], red1_0[12], red1_1[7], red1_0[9], red1_1[4], red1_0[6], red1_1[1]}));
  
  assign red1_1[19] = pp0[22];
  assign red1_0[22] = !pp0[22];
  
  assign red1_0[47:25] = {
    pp7[25:23],
    pp6[26:24],
    pp5[26:24],
    pp4[26:24],
    pp3[26:24],
    pp2[26:24],
    pp1[26:24],
    pp0[26:25]};
  assign red1_0[3:0] = pp0[3:0];
  
  assign red1_1[43:20] = {
    pp8[22:20],
    pp7[22:20],
    pp6[23:21],
    pp5[23:21],
    pp4[23:21],
    pp3[23:21],
    pp2[23:21],
    pp1[23:22],
    pp0[24]};
  assign red1_1[18:17] = {pp1[19], pp0[21]};
  assign red1_1[15:14] = {pp2[13], pp0[18]};
  assign red1_1[12:11] = {pp2[10], pp0[15]};
  assign red1_1[9:8] = {pp2[7], pp0[12]};
  assign red1_1[6:5] = {pp2[4], pp0[9]};
  assign red1_1[3:2] = {pp2[1], pp0[6]};
  assign red1_1[0] = pp1[0];
  
  assign red1_2[38:0] = {
    pp8[19:17],
    pp7[19:17],
    pp6[20:18],
    pp5[20:18],
    pp4[20:18],
    pp3[20:18],
    pp2[20:19],
    pp1[21], pp2[17:16],
    pp1[18], pp2[14], pp3[10],
    pp1[15], pp2[11], pp3[7],
    pp1[12], pp2[8], pp3[4],
    pp1[9], pp2[5], pp3[1],
    pp1[6], pp2[2], pp2[0],
    pp1[3]};
  
  assign red1_3[32:0] = {
    pp8[16:14],
    pp7[16:14],
    pp6[17:15],
    pp5[17:15],
    pp4[17:15],
    pp3[17:16],
    pp2[18], pp3[14:13],
    pp2[15], pp3[11], pp4[7],
    pp2[12], pp3[8], pp4[4],
    pp2[9], pp3[5], pp4[1],
    pp2[6], pp3[2], pp3[0],
    pp2[3]};
  
  assign red1_4[26:0] = {
    pp8[13:11],
    pp7[13:11],
    pp6[14:12],
    pp5[14:12],
    pp4[14:13],
    pp3[15], pp4[11:10],
    pp3[12], pp4[8], pp5[4],
    pp3[9], pp4[5], pp5[1],
    pp3[6], pp4[2], pp4[0],
    pp3[3]};
  
  assign red1_5[20:0] = {
    pp8[10:8],
    pp7[10:8],
    pp6[11:9],
    pp5[11:10],
    pp4[12], pp5[8:7],
    pp4[9], pp5[5], pp6[1],
    pp4[6], pp5[2], pp5[0],
    pp4[3]};
  
  assign red1_6[14:0] = {
    pp8[7:5],
    pp7[7:5],
    pp6[8:7],
    pp5[9], pp6[5:4],
    pp5[6], pp6[2], pp6[0],
    pp5[3]};
  
  assign red1_7[8:0] = {
    pp8[4:2],
    pp7[4:3], pp6[6],
    pp7[1:0], pp6[3]};
  
  assign red1_8[2:0] = {pp8[1:0], pp7[2]};
  
endmodule

module REDUCTION2(
  input [47:0]red1_0,
  input [43:0]red1_1,
  input [38:0]red1_2,
  input [32:0]red1_3,
  input [26:0]red1_4,
  input [20:0]red1_5,
  input [14:0]red1_6,
  input [8:0]red1_7,
  input [2:0]red1_8,
  
  output [46:0]red2_0,
  output [44:0]red2_1,
  output [38:0]red2_2,
  output [32:0]red2_3,
  output [27:0]red2_4,
  output [23:0]red2_5);
  
  assign {red2_1[36], red2_0[37]} = {red1_0[38], !red1_0[38]};
  assign {red2_1[35], red2_0[36]} = {red1_0[37], !red1_0[37]};
  
  half half2_0(
    .A(red1_0[18]),
    .B(red1_1[14]),
    .S(red2_0[17]),
    .Cout(red2_1[16]));
  
  full full2_0[17:0](
    .A({!red1_3[1], red1_0[35:34], !red1_2[1], red1_0[32:19]}),
    .B(red1_1[32:15]),
    .C(red1_2[30:13]),
    .S(red2_0[35:18]),
    .Cout(red2_1[34:17]));
  
  
  assign {red2_3[27], red2_2[29]} = {red1_3[26], !red1_3[26]};
  assign {red2_3[26], red2_2[28]} = {red1_3[25], !red1_3[25]};
  
  half half2_1(
    .A(red1_3[12]),
    .B(red1_4[9]),
    .S(red2_2[15]),
    .Cout(red2_3[13]));
  
  full full2_1[11:0](
    .A(red1_3[24:13]),
    .B(red1_4[21:10]),
    .C(red1_5[18:7]),
    .S(red2_2[27:16]),
    .Cout(red2_3[25:14]));
  
  
  assign {red2_5[18], red2_4[20]} = {red1_6[14], !red1_6[14]};
  assign {red2_5[17], red2_4[19]} = {red1_6[13], !red1_6[13]};
  
  half half2_2(
    .A(red1_6[6]),
    .B(red1_7[3]),
    .S(red2_4[12]),
    .Cout(red2_5[10]));
  
  full full2_2[5:0](
    .A(red1_6[12:7]),
    .B({!red1_1[0], red1_7[8:4]}),
    .C({!red1_0[0], {3{red1_0[0]}}, red1_8[2:1]}),
    .S(red2_4[18:13]),
    .Cout(red2_5[16:11]));
  
  assign red2_0[2:0] = red1_0[2:1] + red1_0[0];
  
  
  assign red2_0[46:38] = red1_0[47:39];
  assign red2_0[16:3] = red1_0[17:4];
  
  assign red2_1[44:37] = red1_1[43:36];
  assign red2_1[15:0] = {red1_2[12], red1_1[13:0], red1_0[3]};
  
  assign red2_2[38:30] = {red1_2[38:34], red1_1[35:33], red1_0[36]};
  assign red2_2[14:0] = {red1_3[11:9], red1_2[11:0]};
  
  assign red2_3[32:28] = {red1_3[32:31], red1_2[33:31]};
  assign red2_3[12:0] = {red1_5[6], red1_4[8:6], red1_3[8:0]};
  
  assign red2_4[27:21] = {red1_3[30:27], red1_4[23:22], red1_0[33]};
  assign red2_4[11:0] = {red1_6[5:3], red1_5[5:3], red1_4[5:0]};
  
  assign red2_5[23:19] = {red1_4[26:24], red1_5[20:19]};
  assign red2_5[9:0] = {red1_8[0], red1_7[2:0], red1_6[2:0], red1_5[2:0]};
  
  
endmodule

module REDUCTION3(
  input [46:0]red2_0,
  input [44:0]red2_1,
  input [38:0]red2_2,
  input [32:0]red2_3,
  input [27:0]red2_4,
  input [23:0]red2_5,
  
  output [46:0]red3_0,
  output [44:0]red3_1,
  output [40:0]red3_2,
  output [35:0]red3_3);
  
  assign {red3_1[42], red3_0[43]} = {red2_0[43], !red2_0[43]};
  assign {red3_1[41], red3_0[42]} = {red2_0[42], !red2_0[42]};
  
  half half3_0[1:0](
    .A({!red2_5[4], red2_0[11]}),
    .B({red2_0[44], red2_1[9]}),
    .S({red3_0[44], red3_0[11]}),
    .Cout({red3_1[43], red3_1[10]}));
  
  full full3_0[29:0](
    .A(red2_0[41:12]),
    .C(red2_1[39:10]),
    .B({!red2_5[1], red2_2[35:7]}),
    .S(red3_0[41:12]),
    .Cout(red3_1[40:11]));
  
  
  assign {red3_3[33], red3_2[35]} = {red2_3[32], !red2_3[32]};
  assign {red3_3[32], red3_2[34]} = {red2_3[31], !red2_3[31]};
  
  half half3_1(
    .A(red2_3[6]),
    .B(red2_4[3]),
    .S(red3_2[9]),
    .Cout(red3_3[7]));
  
  full full3_1[23:0](
    .C(red2_3[30:7]),
    .B(red2_4[27:4]),
    .A({!red2_4[1], red2_5[23:1]}),
    .S(red3_2[33:10]),
    .Cout(red3_3[31:8]));
  
  
  assign red3_0[46:45] = red2_0[46:45];
  assign red3_0[10:0] = red2_0[10:0];
  
  assign red3_1[44] = red2_1[44];
  assign red3_1[9:0] = {red2_2[6], red2_1[8:0]};
  
  assign red3_2[40:36] = {red2_1[43:40], red2_2[36]};
  assign red3_2[8:0] = {red2_3[5:3], red2_2[5:0]};
  
  assign red3_3[35:34] = red2_2[38:37];
  assign red3_3[6:0] = {red2_5[0], red2_4[2:0], red2_3[2:0]};
  
endmodule

module REDUCTION4(
  input [46:0]red3_0,
  input [44:0]red3_1,
  input [40:0]red3_2,
  input [35:0]red3_3,
  
  output [47:0]red4_0,
  output [44:0]red4_1,
  output [41:0]red4_2);
  
  assign red4_0[47:46] = {red3_1[44], !red3_1[44]};
  
  assign {red4_1[44], red4_0[45]} = {
    (red3_1[43] ^ red3_2[40]) | (red3_1[43] & red3_2[40]),
    ~(red3_1[43] ^ red3_2[40])};
  
  half half4_0[1:0](
    .A({red3_1[42], red3_1[6]}),
    .B({red3_2[39], red3_2[3]}),
    .S({red4_0[44], red4_0[8]}),
    .Cout({red4_1[43], red4_1[7]}));
  
  full full4_0[34:0](
    .C(red3_1[41:7]),
    .B(red3_2[38:4]),
    .A(red3_3[35:1]),
    .S(red4_0[43:9]),
    .Cout(red4_1[42:8]));
  
  
  assign red4_0[7:0] = red3_0[7:0];
  
  assign red4_1[6:0] = {red3_0[8], red3_1[5:0]};
  
  assign red4_2[41:0] = {red3_0[46:9], red3_3[0], red3_2[2:0]};
  
endmodule

module REDUCTION5(
  input [47:0]red4_0,
  input [44:0]red4_1,
  input [41:0]red4_2,
  
  output [47:0]red5_0,
  output [45:0]red5_1);
  
  assign red5_0[47] = !red4_0[47];
  
  half half5_0(
    .A(red4_0[5]),
    .B(red4_1[3]),
    .S(red5_0[5]),
    .Cout(red5_1[4]));
  
  full full5_0[40:0](
    .A(red4_0[46:6]),
    .C(red4_1[44:4]),
    .B(red4_2[41:1]),
    .S(red5_0[46:6]),
    .Cout(red5_1[45:5]));
  
  assign red5_0[4:0] = red4_0[4:0];
  
  assign red5_1[3:0] = {red4_2[0], red4_1[2:0]};
  
endmodule

module CPA(
  input [47:0]red5_0,
  input [45:0]red5_1,
  
  output [47:0]Z);
  
  assign Z[1:0] = red5_0[1:0];
  
  assign Z[47:2] = red5_0[47:2] + red5_1;
  
endmodule

module REDUCTION_TREE(
  input [26:0]pp[6:0],
  input [25:0]pp7,
  input [22:0]pp8,
  
  output [47:0]Z);
  
  //REDUCTION 1 (only took 1 hour and 40 minutes!)
  
  wire [47:0]red1_0;
  wire [43:0]red1_1;
  wire [38:0]red1_2;
  wire [32:0]red1_3;
  wire [26:0]red1_4;
  wire [20:0]red1_5;
  wire [14:0]red1_6;
  wire [8:0]red1_7;
  wire [2:0]red1_8;
  
  REDUCTION1 REDUCTION1(.pp0(pp[0]), .pp1(pp[1]), .pp2(pp[2]), .pp3(pp[3]), .pp4(pp[4]), .pp5(pp[5]), .pp6(pp[6]), .pp7(pp7), .pp8(pp8),
                       
                       .red1_0(red1_0), .red1_1(red1_1), .red1_2(red1_2), .red1_3(red1_3),
                       .red1_4(red1_4), .red1_5(red1_5), .red1_6(red1_6), .red1_7(red1_7),
                       .red1_8(red1_8));
  
  //REDUCTION 2
  
  wire [46:0]red2_0;
  wire [44:0]red2_1;
  wire [38:0]red2_2;
  wire [32:0]red2_3;
  wire [27:0]red2_4;
  wire [23:0]red2_5;
  
  REDUCTION2 REDUCTION2(.red1_0(red1_0), .red1_1(red1_1), .red1_2(red1_2), .red1_3(red1_3),
                        .red1_4(red1_4), .red1_5(red1_5), .red1_6(red1_6), .red1_7(red1_7),
                        .red1_8(red1_8),
                      
                       .red2_0(red2_0), .red2_1(red2_1), .red2_2(red2_2),
                       .red2_3(red2_3), .red2_4(red2_4), .red2_5(red2_5));
  
  //REDUCTION 3
  
  wire [46:0]red3_0;
  wire [44:0]red3_1;
  wire [40:0]red3_2;
  wire [35:0]red3_3;
  
  REDUCTION3 REDUCTION3(.red2_0(red2_0), .red2_1(red2_1), .red2_2(red2_2),
                        .red2_3(red2_3), .red2_4(red2_4), .red2_5(red2_5),
                        
                        .red3_0(red3_0), .red3_1(red3_1), .red3_2(red3_2),
                        .red3_3(red3_3));
  
  //REDUCTION 4
  
  wire [47:0]red4_0;
  wire [44:0]red4_1;
  wire [41:0]red4_2;
  
  REDUCTION4 REDUCTION4(.red3_0(red3_0), .red3_1(red3_1), .red3_2(red3_2),
                        .red3_3(red3_3),
                        
                        .red4_0(red4_0), .red4_1(red4_1), .red4_2(red4_2));
  
  //REDUCTION 5
  
  wire [47:0]red5_0;
  wire [45:0]red5_1;
  
  REDUCTION5 REDUCTION5(.red4_0(red4_0), .red4_1(red4_1), .red4_2(red4_2),
                        
                        .red5_0(red5_0), .red5_1(red5_1));
  
  
  //FINAL CPA
  
  CPA CPA(.red5_0(red5_0), .red5_1(red5_1), .Z(Z));
  
endmodule

module MUL(
  input [22:0]frc_X, frc_Y,
  output [47:0]frc_Z_full);
  
  //wire [28:0]pp[12:0];
  
  wire [26:0]pp[6:0];
  wire [25:0]pp7;
  wire [22:0]pp8;
  
  booth booth(.X(frc_X), .Y(frc_Y), .pp(pp), .pp7(pp7), .pp8(pp8));
  
  REDUCTION_TREE RED(.pp(pp),
                     .pp7(pp7),
                     .pp8(pp8),
                     
                     .Z(frc_Z_full));
  
  //assign frc_Z_full = {1'b1, frc_X} * {1'b1, frc_Y};
  
endmodule

module NORM(
  input [47:0]Z_in,
  output [26:0]Z_out,
  output norm_n);
  
  wire [47:0]Z_shift;
  
  assign Z_shift = Z_in << !Z_in[47];
  
  assign Z_out[26:1] = Z_shift[47:22];
  assign Z_out[0] = |Z_shift[21:0]; //sticky
  
  assign norm_n = Z_in[47];
  
endmodule

module ROUND(
  input sign_Z,
  input [2:0]r_mode,
  input [26:0]Z_in,
  output norm_r,
  output [22:0]Z_out);
  
  wire [24:0]Z_plus, Z_up, Z_down, Z_near_max, Z_near_even;
  wire [24:0]Z_round;
  wire RNE, RTZ, RDN, RUP, RMM;
  
  assign RNE = (r_mode == 3'b000); //round to nearest, ties to even
  assign RTZ = (r_mode == 3'b001); //round to zero
  assign RDN = (r_mode == 3'b010); //round down
  assign RUP = (r_mode == 3'b011); //round up
  assign RMM = (r_mode == 3'b100); //round to nearest, ties to max magnitude
  
  assign Z_plus = Z_in[26:3] + 1'b1;
  
  assign Z_up = sign_Z ? {1'b0, Z_in[26:3]} : Z_plus;
  assign Z_down = sign_Z ? Z_plus : {1'b0, Z_in[26:3]};
  
  assign Z_near_even = !Z_in[2] ? Z_in[26:3] : (|Z_in[1:0] ? Z_plus : (Z_in[3] ? Z_plus : Z_in[26:3]));
  assign Z_near_max = !Z_in[2] ? Z_in[26:3] : Z_plus;
  
  //assign Z_round = Z_near_max;
  assign Z_round =
    RNE ? Z_near_even :
    (RTZ ? Z_in[26:3] :
     (RDN ? Z_down :
      (RUP ? Z_up : Z_near_max)));
  
  assign norm_r = Z_round[24];
  
  assign Z_out = norm_r ? Z_round[23:1] : Z_round[22:0];
  
endmodule

module EXP(
  input norm,
  input [7:0]exp_X, exp_Y,
  output [7:0]exp_Z,
  output ovrf, udrf);
  
  wire [8:0]buffer;
  
  assign buffer = exp_X + exp_Y;
  
  wire [7:0]bias;
  
  assign bias = {7'b0111111, !norm};
  
  assign ovrf = {buffer >= {255 + bias}};
  assign udrf = {buffer <= bias};
  
  assign exp_Z = exp_X + exp_Y - bias;
  
endmodule

module EXC(
  input [22:0]frc_X, frc_Y,
  input [7:0]exp_X, exp_Y,
  input udrf, ovrf,
  
  output nan, inf, zer);
  
  wire nan_X, nan_Y, nan_Z;
  wire inf_X, inf_Y;
  wire zer_X, zer_Y;
  
  assign inf_X = &exp_X & ~|frc_X;
  assign inf_Y = &exp_Y & ~|frc_Y;
  assign inf = inf_X | inf_Y | ovrf;
  
  assign zer_X = ~|exp_X;
  assign zer_Y = ~|exp_Y;
  assign zer = zer_X | zer_Y | udrf;
  
  assign nan_X = &exp_X & |frc_X;
  assign nan_Y = &exp_Y & |frc_Y;
  assign nan_Z = {&exp_X & zer_Y} | {&exp_Y & zer_X};
  assign nan = nan_X | nan_Y | nan_Z;
  
endmodule

module NET(
  input nan, inf, zer,
  input [31:0]Z,
  output [31:0]fp_Z);
  
  assign fp_Z = nan ? 32'h7fc00000 : (inf ? {Z[31], 8'hff, 23'b0} : (zer ? {Z[31], 8'h00, 23'b0} : Z));
  
  /*always @(posedge clk)begin
    if(nan)
      res <= {z[31], 8'hff, 22'b0, 1'b1};
    else if(inf)
      res <= {z[31], 8'hff, 23'b0};
    else if(zer)
      res <= {z[31], 8'h00, 23'b0};
    else
      res <= z;
    
  end*/
  
endmodule

module FPM(
  input [2:0]r_mode,
  input [31:0]fp_X, fp_Y,
  output [31:0]fp_Z,
  output ovrf, udrf);
  
  wire [31:0]z;
  
  wire [22:0]frc_X, frc_Y;
  wire [7:0]exp_X, exp_Y, exp_Z;
  
  wire nan, inf, zer;
  wire norm_n, norm_r;
  wire sign_Z;
  
  assign exp_X = fp_X[30:23];
  assign exp_Y = fp_Y[30:23];
  
  assign frc_X = fp_X[22:0];
  assign frc_Y = fp_Y[22:0];
  
  assign sign_Z = fp_X[31] ^ fp_Y[31];
  
  wire [47:0]frc_Z_full; //full multiplier output
  wire [26:0]frc_Z_norm; //with leading, guard, round and sticky bits
  wire [22:0]frc_Z; //rounded Z fraction bits
  
  MUL MUL(.frc_X(frc_X),
          .frc_Y(frc_Y),
          
          .frc_Z_full(frc_Z_full));
  
  NORM NORM(.Z_in(frc_Z_full),
            
            .Z_out(frc_Z_norm),
            .norm_n(norm_n));
  
  ROUND ROUND(.sign_Z(sign_Z),
              .r_mode(r_mode),
              .Z_in(frc_Z_norm),
              
              .norm_r(norm_r),
              .Z_out(frc_Z));
  
  EXP EXP(.norm(norm_n | norm_r),
          .exp_X(exp_X),
          .exp_Y(exp_Y),
          
          .exp_Z(exp_Z),
          .ovrf(ovrf),
          .udrf(udrf));
  
  EXC EXC(.frc_X(frc_X), .frc_Y(frc_Y),
          .exp_X(exp_X), .exp_Y(exp_Y),
          .ovrf(ovrf), .udrf(udrf),
          
          .nan(nan),
          .inf(inf),
          .zer(zer));
  
  NET NET(.nan(nan),
          .inf(inf),
          .zer(zer),
          .Z({sign_Z, exp_Z, frc_Z}),
          
          .fp_Z(fp_Z));
  
endmodule

module top(
  input clk,
  input [2:0]r_mode,
  input [31:0]fp_X, fp_Y,
  output [31:0]fp_Z,
  output ovrf, udrf);
  
  FPM FPM(.r_mode(r_mode),
          .fp_X(fp_X),
          .fp_Y(fp_Y),
          
          .fp_Z(fp_Z),
          .ovrf(ovrf),
          .udrf(udrf));
  
endmodule