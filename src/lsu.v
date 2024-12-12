module lsu(
    input wire clk,
    input wire reset,
    //input next_instr_en,

    input [1:0] en_ls,
    input [15:0] data_to_store,
    input wire [7:0] address,  // 8-bit address to be sent

    
    input wire rx_do,          // Signal indicating data received
    input wire [7:0] rx_data,  // Data received from UART
    input wire tx_done,        // Signal indicating transmission is done
    output [15:0] data_to_load, // 16-bit instruction received
    output tx_start_out,       // Signal to start UART transmission
    output [7:0] tx_data_out,  // Data to be transmitted over UART
    output done_out            // Signal indicating the operation is complete
);

    reg [15:0] instruction;    // 16-bit instruction received
    reg tx_start;              // Signal to start UART transmission
    reg [7:0] tx_data;         // Data to be transmitted over UART
    reg done;                  // Signal indicating the operation is complete

    assign done_out = done;
    assign data_to_load = instruction;
    assign tx_start_out = tx_start;
    assign tx_data_out = tx_data;

    // State encoding
    parameter SEND_FLAG = 3'b001;
    parameter SEND_ADDR = 3'b010;
    //parameter WAIT_RX = 3'b011;
    parameter RECEIVE_INST_LOW = 3'b011;
    parameter RECEIVE_INST_HIGH = 3'b100;
    parameter SEND_INST_HIGH = 3'b101;
    parameter SEND_INST_LOW = 3'b110;
    parameter DONE = 3'b111;

    parameter LOAD = 2'b01;
    parameter STORE = 2'b10;

    
    reg [2:0] state, next_state;

    wire [1:0] en;
    assign en = en_ls;


    // Sequential logic for state transition
    always @(posedge clk) begin
        //ff_a <= instruction;
		if (!reset) begin
			state <= SEND_FLAG;
		end
		else begin
			state <= next_state;
		end
    end

    // State machine logic
    /* verilator lint_off LATCH */
    always @(*) begin
        // Default values
        tx_start = 1;  // No transmission by default
        tx_data = 8'b00000000;
        done = 0;
        instruction = instruction;

        case (state)

            SEND_FLAG: begin
                    //en = en_ls; //later en_ls
                if(en==2'b01) begin 
                    tx_data = 8'b00000001;  // Send flag byte
                    tx_start = 0;  // Start transmission

                end
                else if(en==2'b10) begin
                    tx_data = 8'b00000010;  // Send flag byte
                    tx_start = 0;  // Start transmission

                end

            end

            SEND_ADDR: begin
                if(en==LOAD) begin 
                    tx_data = address;  // Send address byte
                    tx_start = 0;  // Start transmission
                end
                else if(en==STORE) begin 
                    tx_data = address;  // Send address byte
                    tx_start = 0;  // Start transmission
                end
            end

            RECEIVE_INST_HIGH: begin
                if (rx_do) begin
                    instruction[15:8] = rx_data;  // Store lower 8 bits of instruction
                end
            end

            RECEIVE_INST_LOW: begin
                if (rx_do) begin
                    instruction[7:0] = rx_data;  // Store upper 8 bits of instruction
                end
            end

            SEND_INST_HIGH: begin
                tx_data = data_to_store[15:8];  // Send flag byte
                tx_start = 0;  // Start transmission
            end

            SEND_INST_LOW: begin
                tx_data = data_to_store[7:0];  // Send flag byte
                tx_start = 0;  // Start transmission
            end

            DONE: begin
                done = 1'b1;  // Set done signal
            end

            default: begin
				done = 0;
            end
        endcase
    end

    /* verilator lint_off LATCH */
    always @(*) begin
        case (state)
            SEND_FLAG: next_state = (tx_done==1'b1 & en_ls!=2'b0) ? SEND_ADDR:SEND_FLAG;
            SEND_ADDR: begin
                if (tx_done) begin
                    if (en==LOAD) begin 
                        next_state = RECEIVE_INST_HIGH; 
                        $display("SENDING ADDRESS LOAD IN LS");

                    end
                    else if (en==STORE) begin 
                        next_state = SEND_INST_HIGH;  
                        $display("SENDING ADDRESS STORE IN LS");

                    end 
                    else begin
                        next_state = SEND_ADDR;
                    end
                end
            end
            RECEIVE_INST_HIGH: next_state = (rx_do==1'b1) ? RECEIVE_INST_LOW:RECEIVE_INST_HIGH;
            RECEIVE_INST_LOW: next_state = (rx_do==1'b1) ? DONE:RECEIVE_INST_LOW;
            SEND_INST_HIGH: next_state = (tx_done==1'b1) ? SEND_INST_LOW:SEND_INST_HIGH;
            SEND_INST_LOW: next_state = (tx_done==1'b1) ? DONE:SEND_INST_LOW;
            DONE: next_state = SEND_FLAG;
            default: next_state = SEND_FLAG;
        endcase 
    end
endmodule