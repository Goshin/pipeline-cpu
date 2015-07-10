`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:04:50 01/05/2015 
// Design Name: 
// Module Name:    top 
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
module top(
input button,
input clk,
input reset,
input enable,
input start,
input [3:0] select_y,
output [3:0] en,
output [6:0] y
    );

wire [7:0] i_addr;
wire [7:0] d_addr;
wire [15:0] d_dataout;
wire [15:0] i_datain;
wire [15:0] d_datain;
wire d_we;
wire [15:0] show_data;

reg bclk = 0;
reg [15:0] bcount = 0;
always@(clk)
	if(button && bcount == 0)
		begin
			bclk <= 1'b1;
			bcount <= 1;
		end
	else
		begin
			bcount <= bcount + 1;
			if(bcount == 5000)
				begin
					bcount <= 0;
					bclk <= 0;
				end
		end

reg [7:0] ticks = 0;
always@(posedge bclk)
    ticks = ticks + 1;

show sa(
    .clk(clk),
    .num(show_data),
    .y(y),
    .en(en)
);

reg mem_clk = 0;
data_mem dm(
    .rst(reset),
    .clk(mem_clk),
    .dwe(d_we),
    .addr(d_addr),
    .wdata(d_dataout),
    .rdata(d_datain)
);

instr_mem im(
    .clk(clk),
    .addr(i_addr),
    .rdata(i_datain)
);

wire cache_dwe;
wire cache_hit;
wire [15:0]cache_data;
cache cache_i(
    .dwe(cache_dwe),
    .addr(d_addr),
    .wdata(d_datain),
    .hit(cache_hit),
    .rdata(cache_data)
);

cpu cpu_instance(
    .clock(bclk),
    .reset(reset),
    .enable(enable),
    .start(start),
    .mem_clock(mem_clk),
    .select_y(select_y),
    .i_datain(i_datain),
    .d_datain(d_datain),
    
    .y(show_data),
    .d_addr(d_addr),
    .i_addr(i_addr),
    .d_dataout(d_dataout),
    .d_we(d_we)
);
endmodule
