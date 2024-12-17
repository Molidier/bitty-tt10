//Top level UART module
module uart_module #(
    parameter data_width = 8
)
(
	input        clk, 
	input        rst,
	input [1:0] sel_baude_rate,

	input        rx_data_bit,
	output       rx_done,

	output       tx_data_bit,
	input  [data_width-1:0] data_tx,
	input        tx_en,
	output       tx_done,

	output [data_width-1:0] recieved_data

	/*output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2*/
);
	/*wire [12:0] clks_per_bit;
	assign clks_per_bit = 434;*/
	/*always@(*) begin
		//clks_per_bit = 5208;
		case (sel_baude_rate)
			2'b00:clks_per_bit = 5208; //9600
			2'b01:clks_per_bit = 2604; //19200
			2'b10:clks_per_bit = 868; //57600
			2'b11:clks_per_bit = 434; //115200
			default: clks_per_bit = 5208;
		endcase
		
    end*/


	uart_rx R0(
		.data_bit(rx_data_bit),
		.clk(clk),
		.rst(rst),
    	.CLKS_PER_BITS({13'b0}),

		//.receiving(rx_receiving),
		.done(rx_done),
		.data_bus(recieved_data)
	);

	uart_tx T0(
		.data_bus(data_tx),
		.clk(clk),
		.rstn(rst), 
    	.CLKS_PER_BITS({13'b0}),
		.run(tx_en), //active when low
		//.transmitting(tx_transmitting),
		.done(tx_done),
		.data_bit(tx_data_bit)
	);			

endmodule
