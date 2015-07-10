`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:17:22 12/15/2014 
// Design Name: 
// Module Name:    show 
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
module show(
input clk,
input [15:0] num,
output reg [6:0] y,
output reg [3:0] en
    );

reg [15:0] count = 0;
wire mclk;
assign mclk = count[14];

always@(posedge clk)
	begin
		count <= count + 1;
	end

always@(posedge mclk)
	begin
		case(en)
			4'b1111 :
				begin
					en <= 4'b1110;
				end
			4'b1110 :
				begin
					en <= 4'b1101;
				end
			4'b1101 :
				begin
					en <= 4'b1011;
				end
			4'b1011 :
				begin
					en <= 4'b0111;
				end
			default :
				begin
					en <= 4'b1111;
				end
		endcase
	end

reg [3:0] w;
always@(en)
	case(en)
		4'b1111 : w <= num[3:0];
		4'b1110 : w <= num[3:0];
		4'b1101 : w <= num[7:4];
		4'b1011 : w <= num[11:8];
		4'b0111 : w <= num[15:12];
		default : w <= num[3:0];
	endcase
	
always@(w)
	case(w)
		4'b0000:y=7'b0000001;
		4'b0001:y=7'b1001111;
		4'b0010:y=7'b0010010;
		4'b0011:y=7'b0000110;
		4'b0100:y=7'b1001100;
		4'b0101:y=7'b0100100;
		4'b0110:y=7'b0100000;
		4'b0111:y=7'b0001111;
		4'b1000:y=7'b0000000;
		4'b1001:y=7'b0000100;
		4'b1010:y=7'b0001000;
		4'b1011:y=7'b1100000;
		4'b1100:y=7'b0110001;
		4'b1101:y=7'b1000010;
		4'b1110:y=7'b0110000;
		4'b1111:y=7'b0111000;
	endcase
endmodule
