`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:25:03 01/05/2015 
// Design Name: 
// Module Name:    data_mem 
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
module data_mem(
input rst,
input clk,
input dwe,
input [7:0] addr,
input [15:0] wdata,
output [15:0] rdata
    );

reg [15:0] d_mem [255:0];
assign rdata = d_mem[addr];
always@(clk)
    begin
        if(!rst)
            case(addr)
                default : d_mem[addr] <= 16'b0000_0000_0000_0000;
            endcase
        else if(dwe)
            d_mem[addr] <= wdata;
    end

endmodule
