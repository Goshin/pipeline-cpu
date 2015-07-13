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
module cache(
input rst,
input dwe,
input [7:0] ex_addr,
input [7:0] mem_addr,
input [15:0] wdata,
output hit,
output reg [15:0] rdata
    );

//sets: 4
//ways: 2

//tag width = 8 - 2 = 6
//(1 + 1 + 6 + 16) * 2 = 48
reg [47:0] d [0:3];

//**************EX HIT***************//
wire [5:0]ex_tag;
wire [1:0]ex_set;

assign ex_tag = ex_addr[7:2];
assign ex_set = ex_addr[1:0];

//way1
`define ex_v1 d[ex_set][47]
`define ex_u1 d[ex_set][46]
`define ex_tag1 d[ex_set][45:40]
`define ex_block1 d[ex_set][39:24]
//way2
`define ex_v2 d[ex_set][23]
`define ex_u2 d[ex_set][22]
`define ex_tag2 d[ex_set][21:16]
`define ex_block2 d[ex_set][15:0]

wire hit1;
wire hit2;

assign hit1 = `ex_v1 && `ex_tag1 == ex_tag;
assign hit2 = `ex_v2 && `ex_tag2 == ex_tag;
assign hit = hit1 | hit2;

//***********INITIALIZE************//
always @(*)
    if (!rst)
        begin
            d[0] = 48'b0;
            d[1] = 48'b0;
            d[2] = 48'b0;
            d[3] = 48'b0;
        end

//*************MEM HIT**************//
wire [5:0]mem_tag;
wire [1:0]mem_set;

assign mem_tag = mem_addr[7:2];
assign mem_set = mem_addr[1:0];

//way1
`define mem_v1 d[mem_set][47]
`define mem_u1 d[mem_set][46]
`define mem_tag1 d[mem_set][45:40]
`define mem_block1 d[mem_set][39:24]
//way2
`define mem_v2 d[mem_set][23]
`define mem_u2 d[mem_set][22]
`define mem_tag2 d[mem_set][21:16]
`define mem_block2 d[mem_set][15:0]

wire mem_hit1;
wire mem_hit2;

assign mem_hit1 = `mem_v1 && `mem_tag1 == mem_tag;
assign mem_hit2 = `mem_v2 && `mem_tag2 == mem_tag;

//**************READ***************//
always @(*)
    begin
        if (mem_hit1)
            begin
                `mem_u1 <= 1;
                `mem_u2 <= 0;
                rdata <= `mem_block1;
            end
        else if (mem_hit2)
            begin
                `mem_u1 <= 0;
                `mem_u2 <= 1;
                rdata <= `mem_block2;
            end
    end
    
//**************WRITE***************//
always @(posedge dwe)
    begin
        if (`mem_v1 != 1 || (`mem_v2 == 1 && `mem_u1 == 0))
            begin
                `mem_v1 <= 1;
                `mem_tag1 <= mem_tag;
                `mem_block1 <= wdata;
            end
        else
            begin
                `mem_v2 <= 1;
                `mem_tag2 <= mem_tag;
                `mem_block2 <= wdata;
            end
    end

endmodule
