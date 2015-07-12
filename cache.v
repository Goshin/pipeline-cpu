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
input [7:0] r_addr,
input [7:0] w_addr,
input [15:0] wdata,
output hit,
output reg [15:0] rdata
    );

//sets: 4
//ways: 2

//tag width = 8 - 2 = 6
//(1 + 1 + 6 + 16) * 2 = 48
reg [47:0] d [0:3];

wire [5:0]r_tag;
wire [1:0]r_set;

assign r_tag = r_addr[7:2];
assign r_set = r_addr[1:0];

//way1
`define r_v1 d[r_set][47]
`define r_u1 d[r_set][46]
`define r_tag1 d[r_set][45:40]
`define r_block1 d[r_set][39:24]


//way2
`define r_v2 d[r_set][23]
`define r_u2 d[r_set][22]
`define r_tag2 d[r_set][21:16]
`define r_block2 d[r_set][15:0]


wire hit1;
wire hit2;

assign hit1 = `r_v1 && `r_tag1 == r_tag;
assign hit2 = `r_v2 && `r_tag2 == r_tag;
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
                `r_u1 <= 1;
                `r_u2 <= 0;
                rdata <= `r_block1;
            end
        else if (hit2)
            begin
                `r_u1 <= 0;
                `r_u2 <= 1;
                rdata <= `r_block2;
            end
    end
    
//**************write***************//
wire [5:0]w_tag;
wire [1:0]w_set;

assign w_tag = w_addr[7:2];
assign w_set = w_addr[1:0];

//way1
`define w_v1 d[w_set][47]
`define w_u1 d[w_set][46]
`define w_tag1 d[w_set][45:40]
`define w_block1 d[w_set][39:24]


//way2
`define w_v2 d[w_set][23]
`define w_u2 d[w_set][22]
`define w_tag2 d[w_set][21:16]
`define w_block2 d[w_set][15:0]

always @(posedge dwe)
    begin
        if (`w_v1 != 1 || `w_u1 == 0)
            begin
                `w_v1 <= 1;
                `w_tag1 <= w_tag;
                `w_block1 <= wdata;
            end
        else
            begin
                `w_v2 <= 1;
                `w_tag2 <= w_tag;
                `w_block2 <= wdata;
            end
    end

/*
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
assign block2 = `block2;*/
endmodule
