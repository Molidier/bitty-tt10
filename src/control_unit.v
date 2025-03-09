module control_unit (
    input clk,
    input run,
    input reset,
    input [15:0] instruction,
    input ls_done,
    output reg [3:0] mux_sel,  // for getting the register
    output reg done,
    output reg [2:0] sel,
    output reg sel_reg_c,
    output reg en_s,
    output reg en_c,
    output reg [1:0] en_ls,
    output reg [7:0] en,
    output reg en_inst,
    output reg [15:0] immediate
);
    reg [1:0] state, next_state;
    wire [1:0] format;
    wire ls_flag;
    assign format = instruction[1:0];
    assign ls_flag = instruction[2];
    // State encoding
    parameter IDLE = 2'b00;
    parameter FETCH = 2'b01;
    parameter STORE = 2'b10;
    always @(posedge clk) begin
        if (!reset) begin
            state <= IDLE;
        end 
        else begin
            state <= next_state;
        end
    end
    always @(*) begin
        en_inst = 1;
        en_s = 0;
        en_c = 0;
        done = 0;
        mux_sel = 4'b1001;
        sel = 0;
        en = 0;
        immediate = {8'b0, instruction[12:5]}; 
        sel_reg_c = 1'b0;
        en_ls = 2'b00;
        //$display("the current state is %b", state);
        case (state)
            IDLE: begin
                if(format!=2'b10) begin
                    en_s = 1;
                    mux_sel = {1'b0, instruction[15:13]};
                    if(format == 2'b01) begin
                        immediate = {8'b0, instruction[12:5]}; 
                    end
                end
                sel = 3'b0;
                done = 0;
                en_inst = 1;
            end

            FETCH: begin
                //$display("run in fetch is %b", run);
                if(format!=2'b10) begin
                    if(format == 2'b00 | format == 2'b11) begin
                        mux_sel = {1'b0, instruction[12:10]};
                    end
                    else if(format == 2'b01) begin
                        mux_sel = 4'b1000;
                    end
                    else begin
                        mux_sel = 4'b1001;
                    end
                    sel = instruction[4:2];
                end
                else begin
                    sel = 3'b0;  
                    mux_sel = 4'b1001;
                end

                if(format == 2'b11) begin
                        if(ls_flag == 0) begin
                            en_ls = 2'b01;
                        end
                        else begin
                            en_ls = 2'b10;
                        end
                end
                if(format==2'b11) begin
                    sel_reg_c = 1'b1;
                end
                en_c = 1'b1;
                en_inst = 0;
                done = 0;       
            end

            STORE: begin
                if (format!=2'b10 & format!=2'b11) begin
                    en[instruction[15:13]] = 1;
                end
                else if(format==2'b11 & ls_flag==0) begin
                    en[instruction[15:13]] = 1;
                end
                else begin
                    en = 8'b0; 
                end
                sel = 3'b0;
                done = 1'b1;
                en_inst = 1;
            end

            default: begin
                en_s = 0;
                en_c = 0;
                done = 0;
                sel = 3'b0;
                en = 8'b0;
                en_inst = 0;
                mux_sel = 4'b1001;
            end
        endcase
    end
    always @(*) begin
        case (state)
            IDLE: begin
                //$display("CU state is IDLE: instruction is %b", instruction);
                if(run==1) begin
                    if(format==2'b10) begin
                        next_state = STORE;
                    end
                    else begin
                        next_state = FETCH;
                    end
                end
                else begin
                    next_state = IDLE;
                end
            end
            FETCH: begin
                if(format==2'b11) begin
                    next_state = (ls_done==1) ? STORE:FETCH;
                end
                else begin
                    next_state = (en_c==1) ? STORE:FETCH;
                end
            end
            STORE: next_state = (done == 1) ? IDLE : STORE;
            default: next_state = IDLE;
        endcase
    end
endmodule