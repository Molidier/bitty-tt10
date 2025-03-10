module alu_sayat (
    input [15:0] in_a,
    input  [15:0] in_b,
    input  [2:0] select,
    output [15:0] alu_out
);
    parameter add = 3'b000; 
    parameter sub = 3'b001;
    parameter and_op = 3'b010;
    parameter or_op =  3'b011;
    parameter xor_op = 3'b100;
    parameter shl = 3'b101;
    parameter shr = 3'b110;
    parameter cmp = 3'b111;    
    reg [15:0] result;
    always @(*) begin
        // Default value for alu_out
        //result = 16'b0;

        case (select)
            add: result = in_a + in_b;
            sub: result = in_a - in_b;
            and_op: result = in_a & in_b;
            or_op: result = in_a | in_b;
            xor_op: result = in_a ^ in_b;
            shl: result = in_a << (in_b % 16); 
            shr: result = in_a >> (in_b % 16); 
            cmp: result = (in_a > in_b) ? 1 : (in_a < in_b) ? 2 : 0;
            default: result = 16'b0; // Default case for invalid select
        endcase
    end
    assign alu_out = 7;
endmodule