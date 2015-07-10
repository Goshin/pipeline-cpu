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
`define SUB   5'b10010
`define SUBI  5'b10011
`define SUBC  5'b10100
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

module instr_mem(
input clk,
input [7:0] addr,
output [15:0] rdata
    );
 
reg [15:0] i [255:0];
assign rdata = i[addr];

always@(posedge clk)
	case(addr)
        0  : i[addr] <= {`ADDI, `gr1, 4'hA, 4'hB};
        4  : i[addr] <= {`LDIH, `gr1, 4'hC, 4'hC};
        8  : i[addr] <= {`ADDI, `gr2, 4'hF, 4'hF};
        12 : i[addr] <= {`LDIH, `gr2, 4'h3, 4'hC};
        16 : i[addr] <= {`ADD,  `gr3, 1'b0, `gr1, 1'b0, `gr2};
        20 : i[addr] <= {`SUB,  `gr3, 1'b0, `gr1, 1'b0, `gr2};
        24 : i[addr] <= {`AND,  `gr3, 1'b0, `gr1, 1'b0, `gr2};
        28 : i[addr] <= {`OR,   `gr3, 1'b0, `gr1, 1'b0, `gr2};
        32 : i[addr] <= {`XOR,  `gr3, 1'b0, `gr1, 1'b0, `gr2};
        36 : i[addr] <= {`NAND, `gr3, 1'b0, `gr1, 1'b0, `gr2};
        40 : i[addr] <= {`NXOR, `gr3, 1'b0, `gr1, 1'b0, `gr2};
        44 : i[addr] <= {`SLL,  `gr3, 1'b0, `gr1, 4'b0001};
        48 : i[addr] <= {`SLA,  `gr3, 1'b0, `gr1, 4'b0001};
        52 : i[addr] <= {`JUMP, 3'b000, 8'd60};
        60 : i[addr] <= {`ADD,  `gr3, 1'b0, `gr1, 1'b0, `gr0};
        64 : i[addr] <= {`ADDI, `gr3, 8'd2};
        68 : i[addr] <= {`ADDI, `gr1, 8'b1};
        72 : i[addr] <= {`CMP,  3'b000, 1'b0, `gr3, 1'b0, `gr1};
        76 : i[addr] <= {`BNZ,  `gr0, 8'd68};
        80 : i[addr] <= {`STORE,`gr3, 8'b0000_0001};
        84 : i[addr] <= {`LOAD, `gr2, 8'b0000_0001};
        88 : i[addr] <= {`HALT, 11'b000_0000_0000};
        default : i[addr] <= {`NOP, 11'b000_0000_0000};
	endcase

endmodule
