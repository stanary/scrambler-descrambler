module serial_scrambler(
////////////input///////////////////////
		clk,
		rst,
		in_scramble_data,
/////////////output/////////////////////
		out_scramble_data
		);
		
/////////端口声明////////////////////////

		input  clk;
		input  rst;
		input  in_scramble_data;  //扰码数据输入
		output out_scramble_data; //加扰数据输出
		
		reg [6:0] feedback_reg;   //反馈移位寄存器

////////输出的反馈异或关系///////////////////

		assign out_scramble_data = feedback_reg[6]^feedback_reg[5]^in_scramble_data;
		
		always @ (posedge clk)
			if(rst)
				begin
				feedback_reg[6:0] <= 7'b1111111;
				end
			else
				begin
				feedback_reg[6:1] <= feedback_reg[5:0];
				feedback_reg[0] <= feedback_reg[6]^feedback_reg[5]^in_scramble_data;
				end

endmodule
