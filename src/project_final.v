/*
 * Copyright (c) 2024 Moldir Azhimukhanbet
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_bitty (
    input  wire [7:0] ui_in,    // Dedicated inputs
    /* verilator lint_off UNDRIVEN */
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    /* verilator lint_off UNDRIVEN */
    output wire [7:0] uio_out,  // IOs: Output path
    /* verilator lint_off UNDRIVEN */
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    //I/O ports assignment

    reg reset;
    reg rx_data_bit;
    wire tx_data_bit;
    reg [12:0] clks_per_bit;

    assign reset = rst_n;
    assign rx_data_bit = uio_in[0];
    //assign uio_oe[7] = 1'b1; //to enable output for this port

    assign clks_per_bit[12:8] = uio_in[7:3];
    assign clks_per_bit[7:0] = ui_in[7:0];

    /* verilator lint_off UNUSEDSIGNAL */
    wire _unused = &{ena, uio_in[2:1], uio_out, uo_out[7:1], 1'b0};

    assign uo_out[0] = tx_data_bit; //output

    fui_control_2 top_inst(
    .clk(clk),
    .reset(reset),
    .clks_per_bit(clks_per_bit),
    .rx_data_bit(rx_data_bit), 
    .tx_data_bit(tx_data_bit)
	
);



endmodule