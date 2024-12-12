module branch_logic (
    input [7:0] address,
    /* verilator lint_off UNUSED */
    input [15:0] instruction,
    input [15:0] last_alu_result,
    output reg [7:0] new_pc
);
   /* typedef enum  logic [1:0] { 
        S0 = 2'b00,
        S1 = 2'b01,
        S2 = 2'b10,
        S3 = 2'b11
    } states;*/

    //states cur_state, next_state;

    wire [1:0] branch_cond;
    wire [7:0] immediate;
    wire [1:0] format;
    assign branch_cond = instruction[3:2];
    assign immediate = instruction[11:4];
    assign format = instruction[1:0];
    /*
    2061
    1111 1111 1111 1111
    0000 1111 1111 0000
    */

    always @(*) begin
        if(format == 2'b10) begin
            case(branch_cond)
            2'b00: begin
                if (last_alu_result == 0) begin
                    new_pc = immediate;
                    //$display("branching to: ", immediate);
                end else begin
                    new_pc = address +8'b00000001;
                end
            end
            2'b01: begin
                if (last_alu_result == 1) begin
                    new_pc = immediate;
                    //$display("branching to: ", immediate);
                end else begin
                    new_pc = address + 8'b00000001;
                end  
            end
            2'b10: begin
                if (last_alu_result == 2) begin
                    new_pc = immediate;
                    //$display("branching to: ", immediate);
                end else begin
                    new_pc = address + 8'b00000001;
                end  
            end
            default: begin
                new_pc = address + 8'b00000001;
            end
            endcase
        end
        else begin
            new_pc = address + 8'b00000001;
        end
    end

endmodule