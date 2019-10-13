`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) WSCEC, Inc. All rights reserved.                               
////////////////////////////////////////////////////////////////////////////////
// Create Date:    07/31/2010 
// Design Name: 
// Module Name:    top_descrambler 
// Project Name:   信道编码模块，信号解扰实验
// Target Devices: 
// Tool versions: 
// Description:    该模块为信号解扰的顶层模块，系统时钟为40M,将产生的
//                 伪随机序列作为加扰器的输入序列，婊蛄胁?
//                 生成项式为M(x) = x^8 +x^4+ x^3+ x^2+1，再将加扰后序
//                 列作为解扰器的输入，经过解扰模块后，输出信息序列。              
//
// Dependencies: 
//
// Revision:       V1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////
module top_descrambler(
//      输入端口  
        clk_40M,
//      输出端口
		//indata,
		outdata,
		out_scramble_data
		);
							
//////////////////////////////////////////////////////////
		input clk_40M;                  //40M时钟信号

		output outdata;             //解扰后输出
		//output indata;
		output out_scramble_data;
		
		reg  [7:0]shift_reg;
		//wire indata;                //输入的伪随机序列
		wire out_scramble_data;     //加扰后信息序列
		
		wire   indata;
        reg[4:0]  count;
		reg    outdata;
		reg    clk;

        parameter   N = 40;         //分频参数设置
		reg rst;
       reg[31:0] rst_count=0; 
         
           always @(posedge clk_40M) 
           if(rst_count==32'h00000111)
           begin
                  rst_count<=rst_count; 
                  rst<=1'b0;
           end
            else
            begin
                  rst_count<=rst_count+ 32'h1;
                    rst <=1'b1; 
            end
		
////////时钟分频模块//////////////////////////////////////
////////对40M的输入时钟进行N=40分频///////////////////////

        always @ (posedge clk_40M)
            if(rst)
                begin
                count <= 1'b0;
                clk <= 1'b0;
                end
            else
                if (count < N/2-1)
                    begin         
                    count <= count + 1'b1;           
                    end
                else
                    begin       
                    count <= 1'b0;
                    clk <= ~clk;     
                    end
    
////////由伪随机序列产生的恚个伪随机序列////////
////////作为加扰器的输入数据，该伪随机序列的生成多项式////
////////为x^8+x^4+x^3+x^2+1///////////////////////////////

		always @ (posedge clk)
			if(rst)
				begin
				shift_reg[7:0] <= 8'b1111_1111;
				end
			else
				begin
				shift_reg[7:1] <= shift_reg[6:0];
				shift_reg[0] <= shift_reg[7]^shift_reg[3]^shift_reg[2]^shift_reg[1];
				end

		assign indata = shift_reg[7];
		
		always @ (posedge clk)
			begin
			outdata<=out_data;
			end

		 	 	 
////////////信号串行加扰、解扰模块/////////////////////

		serial_scrambler U1(
			.clk(clk),
			.rst(rst),
			.in_scramble_data(indata),
			.out_scramble_data(out_scramble_data)
			);
			
		serial_descrambler U2(
			.clk(clk),
			.rst(rst),
			.in_descramble_data(out_scramble_data),
			.out_descramble_data(out_data)
			);

ila_0 ila_0_inst (
	.clk(clk_40M), // input wire clk
	.probe0(indata), // input wire [0:0]  probe0  
	.probe1(out_scramble_data), // input wire [0:0]  probe1 
	.probe2(out_data), // input wire [0:0]  probe2 
	.probe3(shift_reg), // input wire [7:0]  probe3
    .probe4(rst),
    .probe5(rst_count)
);

endmodule
