`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:17:38 01/11/2015
// Design Name:   top
// Module Name:   D:/Documents/studio/digital_design/cpu/test.v
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

module test;

	// Inputs
	reg button;
	reg clk;
	reg reset;
	reg enable;
	reg start;
	reg [3:0] select_y;

	// Outputs
	wire [3:0] en;
	wire [6:0] y;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.button(button), 
		.clk(clk), 
		.reset(reset), 
		.enable(enable), 
		.start(start), 
		.select_y(select_y), 
		.en(en), 
		.y(y)
	);

	initial begin
		// Initialize Inputs
		button = 0;
		clk = 0;
		reset = 0;
		enable = 0;
		start = 0;
		select_y = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
$display(" pc:     id_ir      :     ex_ir      :    mem_ir      :     wb_ir      :reg_A:reg_B:reg_C:da: dd :w:reC1:gr1 :gr2 :gr3 :gr4 :gr5 :gr6 :gr7 :NF:ZF:CF");
$monitor("%d:%b:%b:%b:%b:%h :%h :%h :%h:%h:%b:%h:%h:%h:%h:%h:%h:%h:%h:%b :%b :%b ", uut.cpu_instance.pc, uut.cpu_instance.id_ir, uut.cpu_instance.ex_ir, uut.cpu_instance.mem_ir, uut.cpu_instance.wb_ir, uut.cpu_instance.reg_A, uut.cpu_instance.reg_B, uut.cpu_instance.reg_C, uut.d_addr, uut.d_dataout, uut.d_we, uut.cpu_instance.reg_C1, uut.cpu_instance.gr[1], uut.cpu_instance.gr[2], uut.cpu_instance.gr[3], uut.cpu_instance.gr[4], uut.cpu_instance.gr[5], uut.cpu_instance.gr[6], uut.cpu_instance.gr[7], uut.cpu_instance.nf, uut.cpu_instance.zf, uut.cpu_instance.cf);
	
enable <= 1; start <= 0; select_y <= 0;

#10 reset <= 0;
#10 reset <= 1;
#10 enable <= 1;
#10 start <=1;
#10 start <= 0;
	end
      always #1  clk= ~clk;
      always #2 uut.bclk=~uut.bclk;
      assign uut.sa.mclk = uut.sa.count[0];
endmodule
