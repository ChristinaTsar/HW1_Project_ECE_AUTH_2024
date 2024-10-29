module regfile (
  output reg [31:0] readData1,readData2,
  input clk,write,
  input wire [4:0] readReg1,readReg2,writeReg,
  input wire [31:0] writeData
);

  reg [31:0] registers [31:0];

  // Initialize registers with zeros
  initial begin
    for (int i = 0; i < 32; i = i + 1) 
        registers[i] = 0;
  end

  // Read and Write Logic
  always @(posedge clk) begin
    // Read from registers
    readData1 <= registers[readReg1];
    readData2 <= registers[readReg2];

    // Write to registers based on control signal
    if (write)                                           
          registers[writeReg] <= writeData;                
  end

endmodule
