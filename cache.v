`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:02:05 07/10/2015 
// Design Name: 
// Module Name:    cache 
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

//Cache 组合逻辑实现//
module cache(
input rst,
input dwe,
input [7:0] addr,
input [15:0] wdata,
output hit,
output reg [15:0] rdata
    );

//sets: 4
//ways: 2

//tag width = 8 - 2 = 6
//(1 + 1 + 6 + 16) * 2 = 48
reg [47:0] d [0:3];


wire [5:0]tag;
wire [1:0]set;

assign tag = addr[7:2];
assign set = addr[1:0];

//way1
`define v1 d[set][47]
`define u1 d[set][46]
`define tag1 d[set][45:40]
`define block1 d[set][39:24]


//way2
`define v2 d[set][23]
`define u2 d[set][22]
`define tag2 d[set][21:16]
`define block2 d[set][15:0]


wire hit1;
wire hit2;

assign hit1 = `v1 && `tag1 == tag;
assign hit2 = `v2 && `tag2 == tag;
assign hit = hit1 | hit2;

//initialize
always @(*)
    if (!rst)
        begin
            d[0] = 48'b0;
            d[1] = 48'b0;
            d[2] = 48'b0;
            d[3] = 48'b0;
        end

//read
always @(*)
    begin
        if (hit1)
            begin
                `u1 <= 1;
                `u2 <= 0;
                rdata <= `block1;
            end
        else if (hit2)
            begin
                `u1 <= 0;
                `u2 <= 1;
                rdata <= `block2;
            end
    end
    
//write
always @(posedge dwe)
    begin
        if (`v1 != 1 || `u1 == 0)
            begin
                `v1 <= 1;
                `tag1 <= tag;
                `block1 <= wdata;
            end
        else
            begin
                `v2 <= 1;
                `tag2 <= tag;
                `block2 <= wdata;
            end
    end

wire v1;
wire u1;    
wire [5:0]tag1;
wire [15:0]block1;
assign v1 = `v1;
assign u1 = `u1;
assign tag1 = `tag1;
assign block1 = `block1;
wire v2;
wire u2;    
wire [5:0]tag2;
wire [15:0]block2;
assign v2 = `v2;
assign u2 = `u2;
assign tag2 = `tag2;
assign block2 = `block2;
endmodule
