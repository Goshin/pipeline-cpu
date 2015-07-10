`timescale 1ns / 1ps
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

// FSM for CPU control
`define idle 1'b0
`define exec 1'b1
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:07:28 12/23/2014 
// Design Name: 
// Module Name:    main 
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
module cpu(
input clock, reset, enable, start,
input [3:0] select_y,
input [15:0] i_datain,
input [15:0] d_datain,
output reg [15:0] y,
output [7:0] d_addr,
output [7:0] i_addr,
output [15:0] d_dataout,
output d_we
    );

reg [7:0] pc;
reg [15:0] id_ir, ex_ir, mem_ir, wb_ir;
reg [15:0] gr [0:7];
reg [15:0] reg_A, reg_B, reg_C, reg_C1, smdr, smdr1;
reg zf, nf, cf;
reg dw;

reg [15:0] ALUo;

reg state;
reg next_state;

assign i_addr = pc;
assign d_we  = dw;
assign d_addr = reg_C[7:0];
assign d_dataout = smdr1;

`define id_r1 id_ir[10:8]
`define id_r2 id_ir[6:4]
`define id_r3 id_ir[2:0]

`define ex_r1 ex_ir[10:8]
`define mem_r1 mem_ir[10:8]
`define wb_r1 wb_ir[10:8]

`define i_op i_datain[15:11]
`define ex_op ex_ir[15:11]
`define mem_op mem_ir[15:11]
`define wb_op wb_ir[15:11]

wire ex_not_branch;
wire mem_not_branch;
wire wb_not_branch;

assign ex_not_branch =!(`ex_op==`BZ 
                || `ex_op==`BNZ 
                || `ex_op==`BC 
                || `ex_op==`BNC 
                || `ex_op==`BN 
                || `ex_op==`BNN 
                || `ex_op==`JMPR 
                || `ex_op==`NOP
                || `ex_op==`CMP);

assign mem_not_branch =!(`mem_op==`BZ 
                || `mem_op==`BNZ 
                || `mem_op==`BC 
                || `mem_op==`BNC 
                || `mem_op==`BN 
                || `mem_op==`BNN 
                || `mem_op==`JMPR 
                || `mem_op==`NOP 
                || `mem_op==`CMP);

assign wb_not_branch =!(`wb_op==`BZ 
                || `wb_op==`BNZ 
                || `wb_op==`BC 
                || `wb_op==`BNC 
                || `wb_op==`BN 
                || `wb_op==`BNN 
                || `wb_op==`JMPR 
                || `wb_op==`NOP 
                || `wb_op==`CMP);

wire if_hazzard_r1;
assign if_hazzard_r1=(`i_op==`STORE 
                ||`i_op==`ADDI 
                ||`i_op==`SUBI 
                ||`i_op==`LDIH 
                ||`i_op==`JMPR 
                ||`i_op==`BN 
                ||`i_op==`BNN 
                ||`i_op==`BC 
                ||`i_op==`BNC
                ||`i_op==`BZ 
                ||`i_op==`BNZ)
            &&(i_datain[10:8] == `id_r1);

wire if_hazzard_r3;			
assign if_hazzard_r3=(`i_op==`ADD
                ||`i_op==`ADDC
                ||`i_op==`SUB
                ||`i_op==`SUBC
                ||`i_op==`CMP
                ||`i_op==`AND
                ||`i_op==`OR
                ||`i_op==`XOR)
            &&(i_datain[2:0] == `id_r1);

wire branch;
assign branch = ((`mem_op == `BZ)
                    && (zf == 1'b1))
                || ((`mem_op == `BNZ)
                    && (zf == 1'b0))
                || ((`mem_op == `BN)
                    && (nf == 1'b1))
                || ((`mem_op == `BNN)
                    && (nf == 1'b0))
                || ((`mem_op == `BC)
                    && (cf == 1'b1))
                || ((`mem_op == `BNC)
                    && (cf == 1'b0))
                || (`mem_op == `JUMP)
                || (`mem_op == `JMPR);

always @(posedge clock)
    begin
        if (!reset)
            state <= `idle;
        else
            state <= next_state;
    end
    
always @(*)
    begin
        case (state)
            `idle : 
                if ((enable == 1'b1) 
                && (start == 1'b1))
                    next_state <= `exec;
                else    
                    next_state <= `idle;
            `exec :
                if ((enable == 1'b0) 
                || (wb_ir[15:11] == `HALT))
                    next_state <= `idle;
                else
                    next_state <= `exec;
        endcase
    end
    
//************* IF *************//
always @(posedge clock or negedge reset)
    begin
        if (!reset)
            begin
                id_ir <= 16'b0000_0000_0000_0000;
                pc <= 8'b0000_0000;
            end
            
        else if (state ==`exec)
            begin
                if(branch)
                    id_ir <= 16'b0;
                else
                    begin
                        if(id_ir[15:11]==`LOAD && 
                            (if_hazzard_r1 || if_hazzard_r3 || i_datain[6:4]==`id_r1)) 
                            id_ir <= 16'b0;
                        else
                            id_ir <= i_datain;
                    end
                
                if(branch)
                    pc <= reg_C[7:0];
                else if(id_ir[15:11]==`LOAD && 
                    (if_hazzard_r1 || if_hazzard_r3 || i_datain[6:4]==`id_r1)) 
                    pc <= pc;
                else
                    pc <= pc + 1;
                    
            end
    end
    
    
//************* ID *************//
always @(posedge clock or negedge reset)
    begin
        if (!reset)
            begin
                ex_ir <= 16'b0000000000000000;
                reg_A <= 16'b0000000000000000;
                reg_B <= 16'b0000000000000000;
                smdr  <= 16'b0000000000000000;
            end
        else if (state == `exec)
            begin
                if(branch)
                    ex_ir <= 16'b0;
                else
                    ex_ir <= id_ir;
                
                //reg_A
                //r1 val2 val3
                if ((id_ir[15:11] == `LDIH)
                || (id_ir[15:11] == `ADDI)
                || (id_ir[15:11] == `SUBI)
                || (id_ir[15:11] == `JMPR)
                || (id_ir[15:11] == `BZ)
                || (id_ir[15:11] == `BNZ)
                || (id_ir[15:11] == `BN)
                || (id_ir[15:11] == `BNN)
                || (id_ir[15:11] == `BC)
                || (id_ir[15:11] == `BNC))
                    begin
                        if(ex_not_branch &&`id_r1 == `ex_r1)
                            reg_A <= ALUo;
                        else if(mem_not_branch && `id_r1 == `mem_r1 && `mem_op==`LOAD)
                            reg_A <= d_datain;
                        else if(mem_not_branch && `id_r1 == `mem_r1)
                            reg_A <= reg_C;
                        else if(wb_not_branch && `id_r1 == `wb_r1)
                            reg_A <= reg_C1;
                        else
                            reg_A <= gr[`id_r1];
                    end
                //r1 r2 val3 & r1 r2 r3
                else
                    begin
                        if(ex_not_branch && `id_r2 == `ex_r1)
                            reg_A <= ALUo;
                        else if(mem_not_branch && `id_r2 == `mem_r1 && `mem_op==`LOAD)
                            reg_A <=d_datain;	
                        else if(mem_not_branch && `id_r2 == `mem_r1)
                            reg_A <= reg_C;						
                        else if(wb_not_branch && `id_r2 == `wb_r1)
                            reg_A <= reg_C1;
                        else
                            reg_A <= gr[id_ir[6:4]];
                    end

                //reg_B
                //r1 r2 val3
                if ((id_ir[15:11] == `LOAD)
                ||  (id_ir[15:11] == `SLL)
                ||  (id_ir[15:11] == `SRL)
                ||  (id_ir[15:11] == `SLA)
                ||  (id_ir[15:11] == `SRA))
                    begin
                        reg_B <= {12'b0000_0000_0000, id_ir[3:0]};
                        smdr  <= 16'b0000000000000000;
                    end
                else if (id_ir[15:11] == `STORE)
                    begin
                        reg_B <= {12'b0000_0000_0000, id_ir[3:0]};
                        if(ex_not_branch &&`id_r1 == `ex_r1)
                            smdr <= ALUo;
                        else if(mem_not_branch && `id_r1 == `mem_r1 && `mem_op==`LOAD)
                            smdr <= d_datain;
                        else if(mem_not_branch && `id_r1 == `mem_r1)
                            smdr <= reg_C;
                        else if(wb_not_branch && `id_r1 == `wb_r1)
                            smdr <= reg_C1;
                        else
                            smdr <= gr[`id_r1];
                    end
                    
                //r1 val2 val3
                else if ((id_ir[15:11] == `LDIH)
                || (id_ir[15:11] == `ADDI)
                || (id_ir[15:11] == `SUBI)
                || (id_ir[15:11] == `JUMP)
                || (id_ir[15:11] == `JMPR)
                || (id_ir[15:11] == `BZ)
                || (id_ir[15:11] == `BNZ)
                || (id_ir[15:11] == `BN)
                || (id_ir[15:11] == `BNN)
                || (id_ir[15:11] == `BC)
                || (id_ir[15:11] == `BNC))
                    reg_B <= {8'b0000_0000, id_ir[7:0]};
                //r1 r2 r3
                else
                    begin
                        if(ex_not_branch && `id_r3 == `ex_r1)
                            reg_B <= ALUo;
                        else if(mem_not_branch && `id_r3 == `mem_r1 && `mem_op==`LOAD)
                            reg_B <= d_datain;
                        else if(mem_not_branch && `id_r3 == `mem_r1)
                            reg_B <= reg_C;
                        else if(wb_not_branch && `id_r3 == `wb_r1)
                            reg_B <= reg_C1;
                        else
                            reg_B <= gr[id_ir[2:0]];
                    end
            end
    end
            
reg ncf = 0;
//************* EX *************//
always @(posedge clock or negedge reset)
    begin
        if (!reset)
            begin
                mem_ir <= 16'b0000000000000000;
                reg_C <= 16'b0000000000000000;
                smdr1 <= 16'b0000000000000000;
                zf <= 1'b0;
                nf <= 1'b0;
                dw <= 1'b0;
            end
        else if (state == `exec)
            begin
                if(branch)
                    mem_ir <= 16'b0;
                else
                    mem_ir <= ex_ir;
                    
                reg_C <= ALUo;
                cf <= ncf;
                
                //arithmetic
                if ((ex_ir[15:11] == `LDIH)
                || (ex_ir[15:11] == `ADD)
                || (ex_ir[15:11] == `ADDI)
                || (ex_ir[15:11] == `ADDC)
                || (ex_ir[15:11] == `SUB)
                || (ex_ir[15:11] == `SUBI)
                || (ex_ir[15:11] == `SUBC)
                || (ex_ir[15:11] == `CMP))
                    begin
                        if (ALUo == 16'b0000_0000_0000_0000)
                            zf <= 1'b1;
                        else
                            zf <= 1'b0;
                        if (ALUo[15] == 1'b1)
                            nf <= 1'b1;
                        else
                            nf <= 1'b0;
                    end
                    
                if (ex_ir[15:11] == `STORE && !branch)
                    begin
                        dw <= 1'b1;
                        smdr1 <= smdr;
                    end
                else
                    begin
                        dw <= 1'b0;
                        smdr1 <= smdr;
                    end
            end
    end

always @(*)
    case (ex_ir[15:11])
        default : ALUo <= 16'b0000_0000_0000_0000;
        //Data transfer
        `LOAD  : ALUo <= reg_A + reg_B;
        `STORE : ALUo <= reg_A + reg_B;
        `LDIH  : ALUo <= reg_A + {reg_B[7:0], 8'b0000_0000};
        //Arithmetic
        `ADD   : {ncf, ALUo} <= reg_A + reg_B;
        `ADDI  : {ncf, ALUo} <= reg_A + reg_B;
        `ADDC  : {ncf, ALUo} <= reg_A + reg_B + cf;
        `SUB   : {ncf, ALUo} <= reg_A - reg_B;
        `SUBI  : {ncf, ALUo} <= reg_A - reg_B;
        `SUBC  : {ncf, ALUo} <= reg_A - reg_B - cf;
        `CMP   : {ncf, ALUo} = reg_A - reg_B;
        //Logical
        `AND   : ALUo = reg_A & reg_B;
        `OR    : ALUo = reg_A | reg_B;
        `XOR   : ALUo = reg_A ^ reg_B;
        //Shift
        `SLL   : ALUo = reg_A << reg_B;
        `SRL   : ALUo = reg_A >> reg_B;
        `SLA   : ALUo = $signed (reg_A) <<< reg_B;
        `SRA   : ALUo = $signed (reg_A) >>> reg_B;
        //Control
        `JUMP  : ALUo = reg_B;
        `JMPR  : ALUo = reg_A + reg_B;
        `BZ    : ALUo = reg_A + reg_B;
        `BNZ   : ALUo = reg_A + reg_B;
        `BN    : ALUo = reg_A + reg_B;
        `BNN   : ALUo = reg_A + reg_B;
        `BC    : ALUo = reg_A + reg_B;
        `BNC   : ALUo = reg_A + reg_B;
        //Custom operation
        `NOR   : ALUo = ~(reg_A | reg_B);
        `NAND  : ALUo = ~(reg_A & reg_B);
        `NXOR  : ALUo = ~(reg_A ^ reg_B);
    endcase

//************* MEM *************//
always @(posedge clock or negedge reset)
    begin
        if (!reset)
            begin
                wb_ir  <= 16'b0000000000000000;
                reg_C1 <= 16'b0000000000000000;
            end
        else if (state == `exec)
            begin
                if(branch)
                    wb_ir <= 16'b0;
                else
                    wb_ir <= mem_ir;

                if (mem_ir[15:11] == `LOAD)
                    reg_C1 <= d_datain;
                else
                    reg_C1 <= reg_C;
            end
    end

//************* WB *************//
always @(posedge clock or negedge reset)
    begin
        if (!reset)
            begin
                gr[0] <= 16'b0000000000000000;
                gr[1] <= 16'b0000000000000000;
                gr[2] <= 16'b0000000000000000;
                gr[3] <= 16'b0000000000000000;
                gr[4] <= 16'b0000000000000000;
                gr[5] <= 16'b0000000000000000;
                gr[6] <= 16'b0000000000000000;
                gr[7] <= 16'b0000000000000000;
            end
        else if (state == `exec)
            begin
                if ((wb_ir[15:11] == `LOAD)
                || (wb_ir[15:11] == `LDIH)
                || (wb_ir[15:11] == `ADD)
                || (wb_ir[15:11] == `ADDI)
                || (wb_ir[15:11] == `ADDC)
                || (wb_ir[15:11] == `SUB)
                || (wb_ir[15:11] == `SUBI)
                || (wb_ir[15:11] == `SUBC)
                || (wb_ir[15:11] == `AND)
                || (wb_ir[15:11] == `OR)
                || (wb_ir[15:11] == `XOR)
                || (wb_ir[15:11] == `SLL)
                || (wb_ir[15:11] == `SRL)
                || (wb_ir[15:11] == `SLA)
                || (wb_ir[15:11] == `SRA)
                || (wb_ir[15:11] == `NOR)
                || (wb_ir[15:11] == `NAND)
                || (wb_ir[15:11] == `NXOR)
                )
                    gr[wb_ir[10:8]] <= reg_C1;
            end
    end

//output control
always@(*)
    case(select_y)
       4'b0001 : y = gr[1];
       4'b0010 : y = gr[2];
       4'b0011 : y = gr[3];
       4'b0100 : y = gr[4];
       4'b0101 : y = gr[5];
       4'b0110 : y = gr[6];
       4'b0111 : y = gr[7];
       4'b1000 : y = reg_A;
       4'b1001 : y = reg_B;
       4'b1011 : y = reg_C;
       4'b1100 : y = reg_C1;
       4'b1101 : y = smdr;
       4'b1110 : y = id_ir;
       default : y = {3'b000, dw, 2'b00, zf, nf, pc};
    endcase

endmodule
