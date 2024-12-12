module mux2to1_1(
    input reg0,
    input reg1,
    input sel,
    output reg out
);

    always @(*) begin
        if (sel)
            out = reg1;
        else
            out = reg0;
    end

endmodule