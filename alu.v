module alu (
  output reg zero,
  output reg signed [31:0] result,
  input signed [31:0] op1,
  input signed [31:0] op2,
  input wire [3:0] alu_op 
);

  // ALU operation parameters
  parameter [3:0] ALUOP_AND = 4'b0000;
  parameter [3:0] ALUOP_OR  = 4'b0001;
  parameter [3:0] ALUOP_ADD = 4'b0010;
  parameter [3:0] ALUOP_SUB = 4'b0110;
  parameter [3:0] ALUOP_LT  = 4'b0111;
  parameter [3:0] ALUOP_LSR = 4'b1000;
  parameter [3:0] ALUOP_LSL = 4'b1001;
  parameter [3:0] ALUOP_ASR = 4'b1010;
  parameter [3:0] ALUOP_XOR = 4'b1101;
  
  always @*
  begin
    // Multiplexer to select the appropriate operation
    case (alu_op)
      ALUOP_AND: result = op1 & op2; // Bitwise AND
      ALUOP_OR : result = op1 | op2; // Bitwise OR
      ALUOP_ADD: result = op1 + op2;
      ALUOP_SUB: result = op1 - op2;
      ALUOP_LT : result = (op1 < op2) ? 1 : 0; // Less than comparison
      ALUOP_LSR: result = op1 >> op2[4:0]; // Logical shift right
      ALUOP_LSL: result = op1 << op2[4:0]; // Logical shift left 
      ALUOP_ASR: result = $unsigned(op1 >>> op2[4:0]); // Arithmetic shift right 
      ALUOP_XOR: result = op1 ^ op2;
      default   : result = 32'b0;
    endcase
    
    zero = (result == 0);
  end

endmodule
