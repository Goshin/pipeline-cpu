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

reg [15:0] d_mem [0:255];
assign rdata = d_mem[addr];
always@(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                d_mem[0] <= 16'hfffd;
                d_mem[1] <= 16'h0004;
                d_mem[2] <= 16'h0005;
                d_mem[3] <= 16'hc369;
                d_mem[4] <= 16'h69c3;
                d_mem[5] <= 16'h0041;
                d_mem[6] <= 16'hffff;
                d_mem[7] <= 16'h0001;
            end
        else if(dwe)
            d_mem[addr] <= wdata;
    end

endmodule
