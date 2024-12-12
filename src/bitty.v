module bitty(
    input run,
    input clk,
    input reset,
    input [15:0] d_instr,

    input [7:0] rx_data,
    input rx_done,
    input tx_done,

    output tx_en,
    output [7:0] tx_data,

    output [15:0] d_out,

    /*output [15:0] reg0,
    output [15:0] reg1,
    output [15:0] reg2,
    output [15:0] reg3,
    output [15:0] reg4,
    output [15:0] reg5,
    output [15:0] reg6,
    output [15:0] reg7,*/
    output done

);

    genvar k;
    wire [3:0] mux_sel;
    wire [7:0] en;
    wire [15:0] out [7:0];

    wire [15:0] out_mux;

    // ALU components
    wire [15:0] alu_out;

    // CPU components
    wire en_s, en_c, en_inst;
    wire [2:0] alu_sel;
    wire [15:0] instruction;
    wire [15:0] im_d;

    // Additional components
    wire [15:0] regs;
    wire [15:0] regc;

    wire [1:0] en_ls;
    wire [15:0] data_to_ld;
    wire ls_done;
    wire sel_reg_c;
    wire [15:0] mux2_out;




    // CPU connection
    cpu cpu_inst(
        .clk(clk),
        .run(run),
        .reset(reset),
        .d_inst(instruction),
        .ls_done(ls_done),
        .mux_sel(mux_sel),
        .done(done),
        .sel(alu_sel),
        .sel_reg_c(sel_reg_c),
        .en_s(en_s),
        .en_c(en_c),
        .en_ls(en_ls),
        .en(en),
        .en_inst(en_inst),
        .im_d(im_d)
    );

    lsu lsu_inst(
    .clk(clk),
    .reset(reset),

    .en_ls(en_ls),
    .data_to_store(regs),
    .address(out_mux[7:0]), 

    .rx_data(rx_data),
    .tx_done(tx_done),
    .rx_do(rx_done),
    .data_to_load(data_to_ld),
    .tx_start_out(tx_en),
    .tx_data_out(tx_data),
    .done_out(ls_done)
);
	mux2to1 for_reg_c(
        .reg0(alu_out),
        .reg1(data_to_ld),
        .sel(sel_reg_c),
        .out(mux2_out)
    );


    // ALU Connection
    alu alu_inst(
        .in_a(regs),
        .in_b(out_mux),
        .select(alu_sel),
        .alu_out(alu_out) // Changed to alu_out
    );

    // MUX connection
    generate
        for (k = 0; k < 8; k=k+1) begin : gen_dff

            dff_lol reg_out (
                .clk(clk),
                .en(en[k]),
                .d_in(regc),
                .reset(reset),
				.mux_out(out[k])      // Corrected output signal name
            );
        end
    endgenerate
    

    mux mux_inst(
        .reg0(out[0]),
        .reg1(out[1]),
        .reg2(out[2]),
        .reg3(out[3]),
        .reg4(out[4]),
        .reg5(out[5]),
        .reg6(out[6]),
        .reg7(out[7]),
        .im_d(im_d),
        .def_val(0),
        .mux_sel(mux_sel),
        .mux_out(out_mux)
    );

    dff_lol reg_inst(clk, en_inst, d_instr, reset, instruction);
    dff_lol reg_s(clk, en_s, out_mux, reset, regs);
    dff_lol reg_c(clk, en_c, mux2_out, reset, regc);

    // Assigning out array elements to module outputs
    assign d_out = regc;

    /*assign rega = regs;
    assign regb = out_mux;

    assign regcc = regc;
    assign regss = regs;*/
    /*assign reg0 = out[0];
    assign reg1 = out[1];
    assign reg2 = out[2];
    assign reg3 = out[3];
    assign reg4 = out[4];
    assign reg5 = out[5];
    assign reg6 = out[6];
    assign reg7 = out[7];*/
   /* assign reginst = instruction;*/

endmodule

