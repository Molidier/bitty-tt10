module mux2to1_8(
    input [7:0] reg0,
    input [7:0] reg1,
    input sel,
    output reg [7:0] out
);

    always @(*) begin
        if (sel)
            out = reg1;
        else
            out = reg0;
    end

endmodule