module otp_uart_sender (
    input  wire        clk,
    input  wire        reset,
    input  wire        send_otp,
    input  wire [23:0] otp,
    input  wire        uart_busy,
    output reg         uart_start,
    output reg  [7:0]  uart_data
);

    localparam IDLE      = 2'd0;
    localparam SEND      = 2'd1;
    localparam WAIT_BUSY = 2'd2;
    localparam WAIT_DONE = 2'd3;

    reg [1:0] state;
    reg [3:0] index;

    function [7:0] hex_to_ascii;
        input [3:0] value;
        begin
            if (value < 10)
                hex_to_ascii = "0" + value;
            else
                hex_to_ascii = "A" + (value - 10);
        end
    endfunction

    function [7:0] message_byte;
        input [3:0] pos;
        input [23:0] code;
        begin
            case (pos)
                0:  message_byte = "O";
                1:  message_byte = "T";
                2:  message_byte = "P";
                3:  message_byte = ":";
                4:  message_byte = " ";
                5:  message_byte = hex_to_ascii(code[23:20]);
                6:  message_byte = hex_to_ascii(code[19:16]);
                7:  message_byte = hex_to_ascii(code[15:12]);
                8:  message_byte = hex_to_ascii(code[11:8]);
                9:  message_byte = hex_to_ascii(code[7:4]);
                10: message_byte = hex_to_ascii(code[3:0]);
                11: message_byte = 8'h0D;
                default: message_byte = 8'h0A;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            index <= 0;
            uart_start <= 0;
            uart_data <= 0;
        end else begin
            uart_start <= 0;

            case (state)
                IDLE: begin
                    if (send_otp) begin
                        index <= 0;
                        state <= SEND;
                    end
                end

                SEND: begin
                    if (!uart_busy) begin
                        uart_data <= message_byte(index, otp);
                        uart_start <= 1'b1;
                        state <= WAIT_BUSY;
                    end
                end

                WAIT_BUSY: begin
                    if (uart_busy)
                        state <= WAIT_DONE;
                end

                WAIT_DONE: begin
                    if (!uart_busy) begin
                        if (index == 4'd12)
                            state <= IDLE;
                        else begin
                            index <= index + 1'b1;
                            state <= SEND;
                        end
                    end
                end
            endcase
        end
    end

endmodule