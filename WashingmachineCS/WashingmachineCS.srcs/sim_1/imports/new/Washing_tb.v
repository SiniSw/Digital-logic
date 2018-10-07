`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/06 10:05:21
// Design Name: 
// Module Name: Washing_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Washing_tb();
    reg CLK,Reset,Control,SP;
    reg [2:0]CWS;
    wire RL,SPL,XDL,PXL,TSL,BUL,JSL,PSL;
//    wire [6:0]data_out[0:5];
    parameter DELY=10;
    parameter LDELY=1000;
    MainSystem WM(Reset,CLK,Control,SP,CWS,RL,SPL,XDL,PXL,TSL,BUL,JSL,PSL);
    always #(DELY/10) CLK=~CLK;
    initial begin
       CLK=0;
       Reset=0;
       Control=0;
       #(LDELY/10) Reset=1;
//       Control=1;
//       Control=0;
       CWS=3'b101;
       #(DELY/10) SP=1;
       #(LDELY) SP=0;
       Control=1;
       #(DELY/10) Control=0;
       SP=1;
    end
endmodule
