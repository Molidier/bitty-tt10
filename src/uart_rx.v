module uart_rx
#(
    parameter data_width   = 8,
              IDLE         = 3'b000,
              START_BIT    = 3'b001,
              DATA_BITS    = 3'b010,
              STOP_BIT     = 3'b011,
              DONE         = 3'b101,
              ERROR_ST     = 3'b110
)
(
    input                     data_bit,
    input                     clk,
    input                     rst,
    input [12:0]             CLKS_PER_BIT,
    output                    done,
    output [data_width - 1:0] data_bus
);
    // FSM states
    reg [2:0] PS, NS;
    // Internal nets
    reg [2:0]  bit_counter;
    reg [12:0] clk_counter;
    reg [data_width - 1:0] data_bus_wire;
    
    // Output assignments
    assign done = (PS == DONE);
    assign data_bus = data_bus_wire;
    
    // Combined sequential logic block
    always @(posedge clk) begin
        if (!rst) begin
            PS <= IDLE;
        end
        else begin
            PS <= NS;
        end
    end
    
    always @(posedge clk) begin
        if (!rst) begin
            clk_counter <= 0;
            bit_counter <= 0;
            data_bus_wire <= 0;
        end
        else begin          
            // Data and control logic
            case (PS)
                IDLE: begin
                    clk_counter <= 0;
                    bit_counter <= 0;
                end
                
                START_BIT: begin
                    if (clk_counter == CLKS_PER_BIT / 2) begin
                        if (data_bit == 1'b0) begin
                            clk_counter <= 0;
                        end
                    end
                    else begin
                        clk_counter <= clk_counter + 1;
                    end
                end
                
                DATA_BITS: begin
                    if (clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                    end
                    else begin
                        clk_counter <= 0;
                        data_bus_wire[bit_counter] <= data_bit;
                        /* verilator lint_off WIDTHEXPAND */
                        if (bit_counter < data_width - 1) begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                end
                
                STOP_BIT: begin
                    if (clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                    end
                    else begin
                        clk_counter <= 0;
                    end
                end
                
                ERROR_ST: begin
                    clk_counter <= 0;
                    bit_counter <= 0;
                end
                
                DONE: begin
                    clk_counter <= 0;
                    bit_counter <= 0;
                end
                
                default: begin
                    clk_counter <= 0;
                    bit_counter <= 0;
                    data_bus_wire <= 0;
                end
            endcase
        end
    end
    
    // Combinational next state logic
    always @(*) begin
        // Default next state
        NS = PS;
        
        case (PS)
            IDLE: begin
                if (data_bit == 1'b0) begin
                    NS = START_BIT;
                end
            end
            
            START_BIT: begin
                if (clk_counter == CLKS_PER_BIT / 2) begin
                    NS = (data_bit == 1'b0) ? DATA_BITS : ERROR_ST;
                end
            end
            
            DATA_BITS: begin
                if (clk_counter == CLKS_PER_BIT - 1) begin
                /* verilator lint_off WIDTHEXPAND */
                    NS = (bit_counter < data_width - 1) ? DATA_BITS : STOP_BIT;
                end
            end
            
            STOP_BIT: begin
                if (clk_counter == CLKS_PER_BIT - 1) begin
                    NS = (data_bit == 1'b1) ? DONE : ERROR_ST;
                end
            end
            
            ERROR_ST: begin
                if (data_bit == 1'b1) begin
                    NS = IDLE;
                end
            end
            
            DONE: begin
                NS = IDLE;
            end
            
            default: begin
                NS = IDLE;
            end
        endcase
    end
    
endmodule
