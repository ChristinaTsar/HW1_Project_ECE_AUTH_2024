`timescale 1ns/1ns

module multicycle_tb;

    // Inputs
    reg clk, rst;
    
    // Outputs
    wire [31:0] PC,dAddress,dWriteData,WriteBackData;
    wire MemRead,MemWrite;
    wire [31:0] instr,dReadData;
 
    
DATA_MEMORY ram(.we(MemWrite),.dout(dReadData),.din(dWriteData),.addr(dAddress[8:0]),.clk(clk));

INSTRUCTION_MEMORY rom(.addr(PC[8:0]),.dout(instr),.clk(clk));

multicycle UUT (
    .PC(PC),
    .dAddress(dAddress),
    .dWriteData(dWriteData),
    .WriteBackData(WriteBackData),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .dReadData(dReadData)
);
    
    // Clock generation
    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end
    
    // Reset generation
    initial begin
        rst = 1;
        #10;
        rst = 0;     
    end
    
initial begin
  $dumpfile("multicycle_tb.vcd");
  $dumpvars(0,multicycle_tb);
  

    // Finish the simulation
    #10000;
    $finish;
end


endmodule
