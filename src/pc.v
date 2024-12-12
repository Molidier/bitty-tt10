module pc(
    input clk,
    input en_pc,
    input reset,
    input [7:0] d_in,

    output reg [7:0] d_out
);
    
    always @(posedge clk) begin
        if(!reset) begin
            d_out <= 8'b0;
        end
        else if(en_pc) begin
            d_out <= d_in;
        end
    end

endmodule