`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:35:41 12/29/2014 
// Design Name: 
// Module Name:    instr_mem 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// Operation code
//Data transfer & Arithmetic
`define NOP   5'b00000
`define HALT  5'b00001
`define LOAD  5'b00010
`define STORE 5'b00011
`define LDIH  5'b10000
`define ADD   5'b01000
`define ADDI  5'b01001
`define ADDC  5'b10001
`define SUB   5'b01010
`define SUBI  5'b01011
`define SUBC  5'b10010
`define CMP   5'b01100
//Logical / Shift
`define AND   5'b01101
`define OR    5'b01110
`define XOR   5'b01111
`define SLL   5'b00100
`define SRL   5'b00110
`define SLA   5'b00101
`define SRA   5'b00111
//Control
`define JUMP  5'b11000
`define JMPR  5'b11001
`define BZ    5'b11010
`define BNZ   5'b11011
`define BN    5'b11100
`define BNN   5'b11101
`define BC    5'b11110
`define BNC   5'b11111
//Custom Operation
`define NOR   5'b10101
`define NXOR  5'b10110
`define NAND  5'b10111

`define gr0 3'b000
`define gr1 3'b001
`define gr2 3'b010
`define gr3 3'b011
`define gr4 3'b100
`define gr5 3'b101
`define gr6 3'b110
`define gr7 3'b111

module instr_mem(
input clk,
input [7:0] addr,
output [15:0] rdata
    );
 
reg [15:0] i_mem [255:0];
assign rdata = i_mem[addr];

always@(posedge clk)
	case(addr)
        0 : i_mem[addr] <= {`ADDI, `gr1, 4'b0000,  4'h0005};//i=5
        1 : i_mem[addr] <= {`BZ, `gr0, 4'b0000,  4'h0007};//if !i
        2 : i_mem[addr] <= {`LOAD, `gr2, 1'b0, `gr0, 4'h4};
        3 : i_mem[addr] <= {`LOAD, `gr3, 1'b0, `gr0, 4'hc};
        4 : i_mem[addr] <= {`LOAD, `gr4, 1'b0, `gr0, 4'h8};
        5 : i_mem[addr] <= {`SUBI, `gr1, 4'd0, 4'd1};//i--
        6 : i_mem[addr] <= {`JUMP, 11'b000_0000_0001};
        7 : i_mem[addr] <= {`HALT, 11'd0};
        default : i_mem[addr] <= {`NOP, 11'b000_0000_0000};
	endcase

endmodule
