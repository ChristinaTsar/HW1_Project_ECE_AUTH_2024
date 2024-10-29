`include "alu.v"
`include "regfile.v"
module datapath (
  output wire Zero, 
  output reg [31:0] PC,WriteBackData,dWriteData,dAddress,
  input clk,rst,PCSrc,MemToReg,loadPC,ALUSrc,RegWrite,
  input wire [3:0] ALUCtrl,
  input wire [31:0] instr,dReadData
);
  
  // Parameter for the initial program counter value
  parameter [31:0] INITIAL_PC=32'h00400000;
  // Constants for instruction types
  parameter [6:0] LW=7'b0000011;
  parameter [6:0] SW=7'b0100011;
  parameter [6:0] IMM=7'b0010011;


reg [31:0] regData1,regData2;
  reg [31:0] immediateTypeI,immediateStore,branchOffset,writeBackDataIn,branchOffsetEx;
  wire [31:0] aluResult,aluOp1,aluOp2;
  reg [4:0] readReg1Addr,readReg2Addr,writeRegAddr;
  reg [6:0] opcode;


  // Instantiate register file module
  regfile my_regfile(.readData1(aluOp1),
  .readData2(aluOp2),
  .write(RegWrite),
  .writeData(writeBackDataIn),
  .readReg1(readReg1Addr),
  .readReg2(readReg2Addr),
  .writeReg(writeRegAddr),
  .clk(clk)
);
  
  // Instantiate ALU module
  alu my_alu(.result(aluResult), 
 .op1(regData1), 
 .op2(regData2),
 .alu_op(ALUCtrl),
 .zero(Zero)
);
  
// Decode instruction and set register and immediate values
always @(instr) begin 
readReg1Addr <= instr[19:15];
readReg2Addr <= instr[24:20];
writeRegAddr <= instr[11:7];

//Immediate instructions 
immediateTypeI <= {{20{instr[31]}},instr[31:20]};

//Store instructions
immediateStore <= {{20{instr[31]}},instr[31:25], instr[11:7]};

//Branch instructions
branchOffsetEx <= {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
branchOffset <= branchOffsetEx<<1;
  
  // Extract opcode
  opcode <= instr[6:0]; // optional, just for better understanding
end
  

 // Mux for deciding the 2nd operand of ALU (op2)
always @(*) begin
if(ALUSrc) begin 
    case(instr[6:0])
    SW : regData2 <= immediateStore; //SW
    LW : regData2 <= immediateTypeI; //LW
    IMM : case(ALUCtrl)
    4'b1001, 4'b1000, 4'b1010 : //SLLI, SRLI, SRAI
        regData2 <= immediateTypeI[4:0]; 
    default : regData2 <= immediateTypeI; //THE REST IMMEDIATE
    endcase
    default : regData2 <= immediateTypeI;  
    endcase 
end
else begin
    regData2 <= aluOp2; //RR,BEQ
end
dWriteData <= aluOp2; 
regData1 <= aluOp1; //first operand is always from register file
end
  
// Mux for writing to register file
always @(*) begin
if(MemToReg) begin
    writeBackDataIn <= dReadData;
    WriteBackData <= dReadData;
    end
else begin
    writeBackDataIn <= aluResult;
    WriteBackData <= aluResult;
end
dAddress <= aluResult;
end


// Update PC logic 
always @(posedge clk) begin 
if(rst) begin 
    PC <= INITIAL_PC;
end

else if (loadPC) begin 
if(PCSrc) begin 
    PC <= PC + branchOffset;
end
else begin 
    PC <= PC + 4;
end
end

end

endmodule
