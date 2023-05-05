`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2023 09:13:33 PM
// Design Name: 
// Module Name: Mux
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


module Mux(
	input [63:0] a,
	input [63:0] b,
	input  sel,
	
	output reg [63:0]data_out
);

always @ (a, b, sel)
begin
	if (!sel)
		data_out = a;
	else
		data_out = b;
end

endmodule 
