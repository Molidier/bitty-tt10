module bitty_sayat (
    input run,
    input clk,
    input reset,
    input [15:0] d_instr,
    // UART
    input [7:0] rx_data,
    input rx_done,
    input tx_done,

    output tx_en,
    output [7:0] tx_data,
    output [15:0] d_out,
    output done
);
    genvar k;
    wire [15:0] instruction, reg_c; //wires for data
    wire [15:0] reg_s, data_to_ld, out_mux, mux2_out;
    wire [15:0] out [7:0];
    // enable values
    wire en_c, en_s, ls_done, sel_reg_c, en_inst; 
    wire [7:0] en_reg;
    wire [3:0] mux_sel;
    wire [2:0] alu_sel;
    // values for output
    wire [15:0] alu_result, immediate;
    wire [1:0] en_ls;
    // Control Unit instance
    control_unit control(
        .instruction(instruction),
        .run(run),
        .clk(clk),
        .en(en_reg),
        .reset(reset),
        .mux_sel(mux_sel), // for getting the register
        .sel(alu_sel),
        .ls_done(ls_done),
        .sel_reg_c(sel_reg_c),
        .en_c(en_c),
        .en_ls(en_ls),
        .en_inst(en_inst),
        .en_s(en_s),
        .immediate(immediate),
        .done(done)
    );

    generate
        for (k = 0; k < 8; k=k+1) begin : loader
            loader reg_out (
                .clk(clk),
                .en(en_reg[k]),
                .d_in(reg_c),
                .reset(reset),
				.mux_out(out[k])
            );
        end
    endgenerate
    //values from multiplexer
    mux_sayat mux_inst(
        .reg0(out[0]),
        .reg1(out[1]),
        .reg2(out[2]),
        .reg3(out[3]),
        .reg4(out[4]),
        .reg5(out[5]),
        .reg6(out[6]),
        .reg7(out[7]),
        .immediate(immediate),
        .def_val(0),
        .mux_sel(mux_sel),
        .mux_out(out_mux)
    );
    mux2to1 for_reg_c(
        .reg0(alu_result),
        .reg1(data_to_ld),
        .sel(sel_reg_c),
        .out(mux2_out)
    );

    

    
    loader reg_inst(clk, en_inst, d_instr, reset, instruction);
    loader reg_s_load(clk, en_s, out_mux, reset, reg_s);
    loader reg_c_load(clk, en_c, mux2_out, reset, reg_c);
    lsu lsu_inst(
        .clk(clk),
        .reset(reset),

        .en_ls(en_ls),
        .data_to_store(reg_s),
        .address(out_mux[7:0]), 

        .rx_data(rx_data),
        .tx_done(tx_done),
        .rx_do(rx_done),
        .data_to_load(data_to_ld),
        .tx_start_out(tx_en),
        .tx_data_out(tx_data),
        .done_out(ls_done)
    );

    alu_sayat alu_inst(
        .in_a(reg_s),
        .in_b(out_mux),
        .select(alu_sel),
        .alu_out(alu_result)
    );
    
    assign d_out = reg_c;
endmodule