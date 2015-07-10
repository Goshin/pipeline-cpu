`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:16:26 01/05/2015
// Design Name:   top
// Module Name:   C:/Documents and Settings/cpu/cpu/main_test.v
// Project Name:  cpu
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module main_test;

	// Inputs
	reg clk;
	reg reset;
	reg enable;
	reg start;
	reg [3:0] select_y;

	// Outputs
	wire [15:0] y;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.reset(reset), 
		.enable(enable), 
		.start(start), 
		.select_y(select_y), 
		.y(y)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		enable = 0;
		start = 0;
		select_y = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
$display("pc:     id_ir      :reg_A:reg_B:reg_C:da: dd :w:reC1:gr1 :gr2 : gr3");
$monitor("%h:%b:%h :%h :%h :%h:%h:%b:%h:%h:%h:%h", uut.cpu_instance.pc, uut.cpu_instance.id_ir, uut.cpu_instance.reg_A, uut.cpu_instance.reg_B, uut.cpu_instance.reg_C, uut.d_addr, uut.d_dataout, uut.d_we, uut.cpu_instance.reg_C1, uut.cpu_instance.gr[1], uut.cpu_instance.gr[2], uut.cpu_instance.gr[3]);
	
enable <= 1; start <= 0; select_y <= 0;

#10 reset <= 0;
#10 reset <= 1;
#10 enable <= 1;
#10 start <=1;
#10 start <= 0;
	end
      always #5 clk= ~clk; 
endmodule

