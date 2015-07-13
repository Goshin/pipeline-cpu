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
output reg [15:0] rdata
    );

reg [15:0] d_mem [0:255];
always@(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                d_mem[1] <= 16'h000a;
                d_mem[5] <= 16'h000b;
                d_mem[9] <= 16'h000c;
            end
        else if(dwe)
            d_mem[addr] <= wdata;
        
        rdata <= d_mem [addr];
    end

endmodule
