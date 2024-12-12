module fui_control_2(
    input clk,
    input reset,
    input [12:0] clks_per_bit,

    input rx_data_bit, 
    output       tx_data_bit
	
);

    wire [15:0] instr;
    wire [7:0] new_pc;  // Declare new_pc as a wire
	wire [7:0] addr;

    wire [15:0] d_out;
    wire done;

    reg [3:0] cur_state, next_state;
	wire tx_done;
    wire rx_done;
    reg en_pc;

    reg run_bitty;
    reg [15:0] mem_out;    
    
    wire [7:0] from_uart_to_modules;
    wire [7:0] data_to_uart_from_fetch;
    wire [7:0] from_bitty_to_uart;
    wire tx_en, tx_en_fiu, tx_en_bitty;
   
    reg en_fetch;
	wire fetch_done;
    wire [7:0] tx_data;
    
    reg uart_sel;

    parameter S0 = 4'b0000;
    parameter S1 = 4'b0001;
    parameter S2 = 4'b0010;
    parameter S3 = 4'b0011;
    parameter S4 = 4'b0100;
    parameter S5 = 4'b0101;
    parameter S6 = 4'b0110;
    parameter S7 = 4'b0111;
    parameter S8 = 4'b1000;
    parameter S9 = 4'b1001;
    parameter S10 = 4'b1010;
    parameter S11 = 4'b1011;
    parameter S12 = 4'b1100;
    parameter S13 = 4'b1101;

    //Use in FSM
    reg stop_for_rw;

    // Fetch instruction instance
    fetch_instruction fi_inst(
        .clk(clk),
        .reset(reset),
        .en_fetch(en_fetch),
        .address(addr),  

        .stop_for_rw(stop_for_rw),

        .rx_do(rx_done),          
        .rx_data(from_uart_to_modules),  
        .tx_done(tx_done),        
        .instruction_out(mem_out), 
        .tx_start_out(tx_en_fiu),       
        .tx_data_out(data_to_uart_from_fetch),  
        .done_out(fetch_done)
    );
	 


    // UART module instance
    uart_module uart_inst(
        .clk(clk), 
        .rst(reset),
        .clks_per_bit(clks_per_bit),
        .rx_data_bit(rx_data_bit),
        .rx_done(rx_done),
        .tx_data_bit(tx_data_bit),
        .data_tx(tx_data),
        .tx_en(tx_en),
        .tx_done(tx_done),
        .recieved_data(from_uart_to_modules)
    );
	 
	branch_logic bl_inst(
        .address(addr),
        .instruction(mem_out),
        .last_alu_result(d_out),
        .new_pc(new_pc)  // Connect new_pc here
    );

    // PC instance
    pc pc_inst(
        .clk(clk),
        .en_pc(en_pc),
        .reset(reset),
        .d_in(new_pc),   // Use new_pc for the input here
        .d_out(addr)
    );

    mux2to1_8 mux2to1_txdata(
        .reg0(data_to_uart_from_fetch),
        .reg1(from_bitty_to_uart),
        .sel(uart_sel),
        .out(tx_data)
    );

    mux2to1_1 mux2to1_txen(

        .reg0(tx_en_fiu),
        .reg1(tx_en_bitty),
        .sel(uart_sel),
        .out(tx_en)
    );


    bitty bitty_inst(
        .clk(clk),
        .reset(reset),
        .run(run_bitty),
        .d_instr(mem_out),
        .rx_data(from_uart_to_modules),
        .rx_done(rx_done),
        .tx_done(tx_done),
        .tx_en(tx_en_bitty),
        .tx_data(from_bitty_to_uart),
        .done(done),
        .d_out(d_out)
    );

    always @(posedge clk) begin
        if(!reset || done) begin
            cur_state <= S0;
        end
        else begin
            cur_state <= next_state;
        end
    end

   always @(*) begin
	     en_fetch = 1'b0;
         run_bitty = 1'b0;
         en_pc = 1'b0;
         uart_sel = 1'b0;
         stop_for_rw = 1'b0;
        case (cur_state)
            S0: begin
                stop_for_rw = 1'b0;
            end
            S1: begin
                en_fetch = 1'b1;
            end
            S3: begin
                en_pc = 1'b1;
            end 
            S7: begin
                run_bitty = 1'b1;
            end
            S8: begin
                stop_for_rw = 1'b0;
            end
            S9: begin
                uart_sel = 1'b1;
                stop_for_rw = 1'b1;
            end
            S10: begin
                uart_sel = 1'b0;
                stop_for_rw = 1'b0;
            end
            S11: begin
                stop_for_rw = 1'b0;
            end
            default: begin
                 run_bitty = 0;
            end
        endcase
    end



    always @(*) begin
        case(cur_state)
            S0: next_state = (fetch_done==1) ? S1:S0;
            S1: next_state = S2;
            S2: next_state = S3;
            S3: next_state = (mem_out[1:0]==2'b11) ? S4:S5;
            S4: next_state = S6;
            S5: next_state = S6;
            S6: next_state = S7; 
            S7: next_state = (mem_out[1:0]==2'b11) ? S9:S8;
            S8: next_state = (done==1) ? S0:S8;
            S9: next_state = (done==1) ? S0:S9;
            default: next_state = S0;
        endcase
    end





endmodule