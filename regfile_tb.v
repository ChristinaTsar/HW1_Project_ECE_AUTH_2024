`timescale 1ns/1ns

module regfile_tb;

    // Declare simulation signals
    reg clk;
    reg write_enable; 
    reg [4:0] readReg1, readReg2;
    wire [31:0] readData1, readData2;
    reg [4:0] write_addr;
    reg [31:0] writeData;
    
    // Instantiate the regfile module
    regfile DUT (
        .readData1(readData1),
        .readData2(readData2),
        .clk(clk),
        .write(write_enable), 
        .readReg1(readReg1),
        .readReg2(readReg2),
        .writeReg(write_addr),
        .writeData(writeData)
    );
    
    
    // Generate clock signal
    always #5 clk = ~clk;
    
    // Initialize write enable signal
    initial begin
        write_enable = 0;
        #20 write_enable = 1;
    end
    
    // Initialize clock and perform write operations
    initial begin
        clk = 0; 
        write_addr = 2;
        writeData = 32'h01234567;
        #30 write_addr = 3;
        writeData = 32'h346712AD;
        #40 write_addr = 4;
        writeData = 32'hAB12CD34;
        #50 write_addr = 5;
        writeData = 32'hFED765AB;
        #60 write_addr = 6;
        writeData = 32'h12312345;
    end
    
    // Initialize simulation setup
    initial begin
      $dumpfile("regfile_tb.vcd"); // Set up VCD file for waveform dumping
      $dumpvars(0,regfile_tb); // Dump variables for waveform display
        // Read operations
        #70 readReg1 = 2;
        #80 readReg2 = 3;
        #90 readReg1 = 4;
        #100 readReg2 = 5;
        #110 readReg1 = 6;
        #120 readReg2 = 7;
        
        // Display register values
      #130 $display("Register 1: %h", readData1);
      #140 $display("Register 2: %h", readData2);
        #150 $finish; // Finish simulation after displaying values
    end
    
endmodule
