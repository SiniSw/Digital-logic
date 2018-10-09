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
    wire [6:0]seg;
    wire [7:0]an;
    wire RL,SPL,XDL,PXL,TSL,BUL,JSL,PSL;
//    wire [6:0]data_out[0:5];
    parameter DELY=10;
    parameter LDELY=1000;
    MainSystem WM(Reset,CLK,Control,SP,CWS,seg,an,RL,SPL,XDL,PXL,TSL,BUL,JSL,PSL);
    always #(DELY/2) CLK=~CLK;
    initial begin
       CLK=0;
    end
    initial begin
        Reset=0;
        Control=0;
        SP=0;
        CWS=3'b101;
        #10 Reset=1;
        #10  Reset=0;
        
        #60 Control=1;
        #20 Control=0;
        #40 Control=1;
        #20 Control=0;
        #40 Control=1;
        #20 Control=0;
        #40 Control=1;
        #20 Control=0;
        #40 Control=1;
        #20 Control=0;
        #40 Control=1;
        #20 Control=0;
        
        #30 SP=1;
        #10 SP=0;
        #100 Control=1;
        #10 Control=0;
     
        #10 SP=1;
        #10 SP=0;
        #100 Control=1;
        #10 Control=0;

        #10 SP=1;
        #10 SP=0;
 
    end
endmodule
