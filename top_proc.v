`include "datapath.v"
`include "ram.v"
`include "rom.v"
module multicycle(
  output wire [31:0] PC,dWriteData,dAddress,WriteBackData,
  output reg MemRead,MemWrite,
  input wire [31:0] instr,dReadData,
  input clk,rst 
);
  
  // Define parameters for initial PC value and instruction types
  parameter [31:0] INITIAL_PC=32'h00400000;
  parameter [6:0] SW=7'b0100011;
  parameter [6:0] LW=7'b0000011;
  parameter [6:0] IMMEDIATE=7'b0010011;
  parameter [6:0] BEQ=7'b1100011;
  parameter [6:0] RR=7'b0110011;
  // Define states for the finite state machine (FSM)
  parameter [2:0] IF=3'b000;
  parameter [2:0] ID=3'b001;
  parameter [2:0] EX=3'b010;
  parameter [2:0] MEM=3'b011;
  parameter [2:0] WB=3'b100;


// Internal signals for control unit
  wire zero;
  reg aluSource,pcLoad,pcSource,registerWrite,dataMemToReg;
  reg [3:0] aluControl;
  reg [2:0] currentState,nextState;
  

  // Instantiate the datapath module
  datapath  #(.INITIAL_PC(INITIAL_PC)) my_datapath(
    .PC(PC),
    .instr(instr),
    .dAddress(dAddress),
    .dReadData(dReadData),
    .dWriteData(dWriteData),
    .ALUSrc(aluSource),
    .ALUCtrl(aluControl),
    .RegWrite(registerWrite),
    .MemToReg(dataMemToReg),
    .loadPC(pcLoad),
    .Zero(zero),
    .PCSrc(pcSource),
    .clk(clk),
    .rst(rst),
    .WriteBackData(WriteBackData)
);

  // FSM state memory logic
always @(posedge clk)
begin : STATE_MEMORY 
if(rst)
    currentState <= IF;
else
    currentState <= nextState;
end
 
  // FSM next state logic
always @(currentState)
begin : NEXT_STATE_LOGIC
  case(currentState)
IF : nextState <= ID;
ID : nextState <= EX;
EX : nextState <= MEM;
MEM : nextState <= WB;
WB : nextState <= IF;
endcase
end

   // FSM output logic
  always @(currentState)
  begin : OUTPUT_LOGIC
  case(currentState)
  IF : begin 
    pcLoad <= 0;
    registerWrite <= 0;
    pcSource <= 0;
    dataMemToReg <= 0;
 end
ID : begin  
end
EX : begin 
end
MEM : begin
case(instr[6:0])     
SW : begin 
    MemWrite <= 1; 
    MemRead <= 0;
end
LW : begin 
    MemWrite <= 0; 
    MemRead <= 1;
end 
endcase
end
WB : begin
case(instr[6:0])
LW : begin 
    registerWrite <= 1; 
    dataMemToReg <= 1;
end
BEQ : begin 
    registerWrite <= 0; 
    dataMemToReg <= 0;
    if(zero)
        pcSource <= 1;
end 
SW : begin
    registerWrite <= 0; 
    dataMemToReg <= 0;
end
default : begin 
    registerWrite <= 1; 
    dataMemToReg <= 0;
end
endcase
pcLoad <= 1;
MemRead <= 0;
MemWrite <= 0;
end
endcase
end
 
  // ALU control and ALU source logic based on instruction
always @(instr) begin
case(instr[6:0])
// Store and load instructions
SW : begin 
    aluSource <= 1; 
    aluControl <= 4'b0010; 
end  
LW : begin 
    aluSource <= 1; 
    aluControl <= 4'b0010; 
end

// BEQ instructions
BEQ : begin 
    aluSource <= 0;
    aluControl <= 4'b0110;     
end

// Immediate instructions
IMMEDIATE: begin 
    aluSource <= 1;
    case(instr[14:12])
    3'b000 : aluControl <= 4'b0010; //ADDI
    3'b010 : aluControl <= 4'b0111; //SLTI
    3'b100 : aluControl <= 4'b1101; //XORI
    3'b110 : aluControl <= 4'b0001; //ORI
    3'b111 : aluControl <= 4'b0000; //ANDI
    3'b001 : aluControl <= 4'b1001; //SLLI
    3'b101 : begin
    case(instr[31:25])
    7'b0000000 : aluControl <= 4'b1000; //SRLI
    7'b0100000 : aluControl <= 4'b1010; //SRAI
    endcase
    end
    endcase  
end

//Register-Register instructions
RR: begin
    aluSource <= 0;
    case(instr[31:25])
    7'b0000000 : begin
        case(instr[14:12])
        3'b000 : aluControl <= 4'b0010; //ADD
        3'b001 : aluControl <= 4'b1001; //SLL
        3'b010 : aluControl <= 4'b0111; //SLT
        3'b100 : aluControl <= 4'b1101; //XOR
        3'b110 : aluControl <= 4'b0001; //OR
        3'b111 : aluControl <= 4'b0000; //AND
        3'b101 : aluControl <= 4'b1000; //SRL
        endcase
    end
    7'b0100000 : begin 
        case(instr[14:12])
        3'b000 : aluControl <= 4'b0110; //SUB
        3'b101 : aluControl <= 4'b1010; //SRA
        endcase
    end
    endcase
end
default : begin 
     aluSource <= 0; 
     aluControl <= 0;
end
endcase
end
endmodule 
