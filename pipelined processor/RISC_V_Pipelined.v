`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2023 08:34:56 AM
// Design Name: 
// Module Name: RISC_V_Pipelined
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


module RISC_V_Pipelined(
    input clk,reset,
    output [63:0] PcOut_InstAddr,
    [31:0] Instr,
     [4:0] rs1,
     [4:0] rs2,
     [4:0] rd,
     [63:0] ReadData1,
     [63:0] ReadData2,
     [63:0] WriteData,
     [63:0] ImmData,
     [63:0] AluResult,
     [63:0] ReadMemData,
     Branch,MemRead,MemReg,MemWrite,AluSrc,RegWrite,
     [1:0] ALUOp,
     [3:0] Operation,
    [6:0] OpCode,
    [7:0] Arr1,
    [7:0] Arr2,
    [7:0] Arr3,
    [7:0] Arr4,
    flush, [4:0] rd_memwb_out,
    [63:0] Result_memwb_out,
    MemtoReg_memwb_out,
    RegWrite_memwb_out,
    [63:0] alu1,
    [63:0] Mux_Alu, [1:0] fwdb,
    Branch_exmem_out, Zero_exmem_out, [1:0] fwda
    
    );
    wire [63:0]PC_in;
    wire [63:0] PcOut_InstAddr;
    wire [31:0] Instr;
    wire [6:0] OpCode;
    wire [63:0] Four_add;
    wire [63:0] Branch_add;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [63:0] ReadData1;
    wire [63:0] ReadData2;
    wire [63:0] WriteData;
    wire [63:0] ImmData;
    wire [63:0] Mux_Alu;
    wire [63:0] AluResult;
    wire [63:0] ReadMemData;
//    wire [63:0] ReadDataOne;
    wire Branch,MemRead,MemReg,MemWrite,AluSrc,RegWrite;
    wire Branch_mux,MemRead_mux,MemReg_mux,MemWrite_mux,ALUSrc_mux,RegWrite_mux;
    wire [1:0] ALUOp_mux;
    wire [1:0] ALUOp;
    wire [3:0] Operation;
    reg [63:0] b=64'd4;
    wire flush;
    wire Zero;
    wire [2:0] funct3;
    wire [6:0] funct7;
    
    wire [7:0] Arr1;
    wire [7:0] Arr2;
    wire [7:0] Arr3;
    wire [7:0] Arr4;
    
    wire [63:0] ifid_pcin;
    wire [31:0] ifid_instr;
    wire ifid_write;
    
   wire [63:0] PC_Out;
   wire [3:0] Funct_out;
   wire [1:0] ALUOp_out;
   wire MemtoReg_out; 
   wire RegWrite_out;
   wire Branch_out;
   wire MemWrite_out; 
   wire MemRead_out;
   wire ALUSrc_out;
   wire [63:0] ReadData1_out;
   wire [63:0]ReadData2_out;
   wire [4:0] rs1_out;
   wire [4:0] rs2_out;
   wire [4:0] rd_out;
   wire [63:0] immdata_out; 
   
   wire [63:0] data_out;
   wire [63:0] Branchadd_out;
   wire [4:0] rd_exmem_out;
   wire Branch_exmem_out;
   wire MemWrite_exmem_out;
   wire MemRead_exmem_out;
   wire MemtoReg_exmem_out; 
   wire RegWrite_exmem_out;
   wire [63:0] Result_exmem_out;
   wire Zero_exmem_out;
   
   wire MemtoReg_memwb_out; 
   wire RegWrite_memwb_out;
   wire [63:0] Result_memwb_out;
   wire [63:0] ReadMemData_out;
   wire [4:0] rd_memwb_out;
   
   wire pcwrite;
   wire CU_mux_ctrl;
   
   wire [1:0] fwda;
   wire [1:0] fwdb;
   wire [63:0] alu1;
   wire [63:0] alu2;
   
//   wire pos; 
//   wire pos_mem;
   wire [2:0] f3_idex;
   wire [2:0] funct_mem;
   
   HazardDetection hd(rs1, rs2, rd_out, MemRead_out, pcwrite, CU_mux_ctrl, ifid_write);
   
   CU_mux cmx(CU_mux_ctrl, Branch, MemRead, MemReg, MemWrite, AluSrc, RegWrite, ALUOp, Branch_mux, MemRead_mux, MemtoReg_mux, MemWrite_mux, ALUSrc_mux, RegWrite_mux, ALUOp_mux);
   
   ForwardingUnit fdu(rs1_out, rs2_out, RegWrite_exmem_out, RegWrite_memwb_out,  rd_memwb_out,rd_exmem_out, fwda, fwdb);
   
    
    assign flush = Branch_exmem_out & Zero_exmem_out;    
    Mux3 forwarda(ReadData1_out, WriteData, Result_exmem_out, fwda, alu1);
    Mux3 forwardb(ReadData2_out, WriteData, Result_exmem_out, fwdb, alu2); 
   
    
    
    
    
    Program_Counter pc(clk,reset,pcwrite,PC_in,ifid_pcin);
    pc_adder add(ifid_pcin,b,Four_add);
    pc_adder add2(PC_Out, immdata_out<<1 ,Branch_add); //tbd
    Mux2 branch(Four_add,Branchadd_out,flush,PC_in);
    Instruction_Memory Mem(ifid_pcin,ifid_instr);
    
    IFID ifid(clk, reset, ifid_pcin, ifid_instr, Instr, PcOut_InstAddr,ifid_write, flush);
    registerFile REG(clk,reset,WriteData,rs1,rs2,rd_memwb_out,RegWrite_memwb_out, ReadData1,ReadData2);
    IDEX idex(clk, reset, {Instr[30], Instr[14:12]}, ALUOp_mux, MemtoReg_mux, RegWrite_mux, Branch_mux, MemWrite_mux, MemRead_mux, ALUSrc_mux, ReadData1, ReadData2, rd, rs1, rs2, ImmData, PcOut_InstAddr,
    PC_Out, Funct_out, ALUOp_out, MemtoReg_out, RegWrite_out, Branch_out, MemWrite_out, MemRead_out, ALUSrc_out, 
    ReadData1_out, ReadData2_out, rs1_out, rs2_out, rd_out, immdata_out, flush, funct3, f3_idex);
    ALU_64 a64(Zero, alu1, Mux_Alu ,Operation,AluResult);
    
    EXMEM exmem(clk, reset, rd_out, Branch_out, MemWrite_out, MemRead_out, MemtoReg_out, RegWrite_out, Branch_add, AluResult, Zero, alu2,
    data_out, Branchadd_out, rd_exmem_out, Branch_exmem_out, MemWrite_exmem_out, MemRead_exmem_out, MemtoReg_exmem_out,
    RegWrite_exmem_out, Result_exmem_out, Zero_exmem_out, flush, f3_idex, funct_mem);
    Data_Memory data(Result_exmem_out,data_out,clk,MemWrite_exmem_out,MemRead_exmem_out,ReadMemData, Arr1, Arr2, Arr3, Arr4);
    MEMWB memwb(clk, reset, Result_exmem_out, ReadMemData, rd_exmem_out, MemtoReg_exmem_out, RegWrite_exmem_out, 
    MemtoReg_memwb_out, RegWrite_memwb_out, Result_memwb_out, ReadMemData_out, rd_memwb_out);
    
    
    
    InsParser Pars(Instr,OpCode,rd,funct3,rs1,rs2,funct7);
    
    Control_Unit CU(OpCode, Branch, MemRead,MemReg,MemWrite,AluSrc, RegWrite,ALUOp);
    Mux ALU(alu2,immdata_out,ALUSrc_out, Mux_Alu);
    
    
    Mux wb(Result_memwb_out,ReadMemData_out,MemtoReg_memwb_out,WriteData);
    
    ImmGen IG(Instr,ImmData);
    ALU_Control aluct(ALUOp_out, Funct_out,Operation);
    
    
    
    
    
    
    
endmodule
