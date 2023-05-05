`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2023 08:35:27 AM
// Design Name: 
// Module Name: IFID
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


module IFID(clk, reset, PC_In, Inst_input,	Inst_output, PC_Out, IFIDWrite, flush);
  
  input wire clk;
  input reset;
  input wire [63:0] PC_In;
  input  [31:0] Inst_input;
  input wire IFIDWrite;
  output reg [31:0]Inst_output;
  output reg [63:0] PC_Out;
  input flush;
  
  always @ (posedge clk or posedge reset)
    begin
    if (reset)
      begin
         PC_Out <= PC_Out; 
         Inst_output <= 0;
      end
     else if (~IFIDWrite) 
        begin
          PC_Out <= PC_Out;
          Inst_output <= Inst_output;
        end
     else 
       begin
         PC_Out = PC_In;
         Inst_output <= Inst_input;
       end
       
       if (flush) begin
      Inst_output <= 32'd0;
    end
    end
endmodule

