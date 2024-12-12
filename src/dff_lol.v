module dff_lol(
    input clk,
    input en,
    input wire [15:0] d_in,
    input reset,

    output reg [15:0] mux_out

);

    always @(posedge clk) begin
        if (!reset) begin
            mux_out <= 16'b0;
        end
        else if(en) begin
            mux_out <= d_in;
        end
    end
	 
endmodule