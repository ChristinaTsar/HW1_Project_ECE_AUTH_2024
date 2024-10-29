`include "alu.v"
`include "decoder.v"
module calc (output reg [15:0] led,
input clk,btnc,btnl,btnu,btnr,btnd,
input wire signed [15:0] sw);
  
  reg  signed [15:0] accumulator; // 16-bit accumulator to hold the current value of the calculator
  reg signed [31:0] op1_ex; // Sign-extended version of the 16-bit accumulator
  reg signed [31:0] op2_ex; // Sign-extended version of the 16-bit switch inputs
  wire  signed [31:0] alu_result;
  wire [3:0] alu_bit; // ALU operation control bits


always @(accumulator or sw)
begin 
    // Concatenation to create sign-extended versions of op1 and op2
    op1_ex <= {{16{accumulator[15]}},accumulator};
    op2_ex <= {{16{sw[15]}},sw};
end

  // Instantiate decoder module
  decoder my_decoder (.B(alu_bit), .R(btnr), .L(btnl), .C(btnc));

  // Instantiate alu module
  alu my_alu (.result(alu_result), 
          .op1(op1_ex), 
          .op2(op2_ex),
          .alu_op(alu_bit));

// Update the accumulator with the lower 16 bits of the ALU result and
// update the LED with the lower 16 bits of the accumulator

always @ (posedge clk or posedge btnu)
begin
if(btnu) begin
    accumulator = 0;
    led=0;
end
else if(btnd) begin
    accumulator = alu_result[15:0];
    led = accumulator;
end
else begin
    accumulator <= accumulator;
end

end

endmodule
