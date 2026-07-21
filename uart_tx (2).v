module uart_tx #(
    parameter integer CLKS_PER_BIT = 868
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       start,
    input  wire [7:0] data,
    output reg        tx,
    output reg        busy
);

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0]  state;
    reg [15:0] count;
    reg [2:0]  bit_number;
    reg [7:0]  data_reg;

    always @(posedge clk) begin
        if (reset) begin
            state      <= IDLE;
            tx         <= 1'b1;
            busy       <= 1'b0;
            count      <= 0;
            bit_number <= 0;
            data_reg   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx    <= 1'b1;
                    busy  <= 1'b0;
                    count <= 0;

                    if (start) begin
                        data_reg <= data;
                        tx       <= 1'b0;
                        busy     <= 1'b1;
                        state    <= START;
                    end
                end

                START: begin
                    if (count == CLKS_PER_BIT - 1) begin
                        count      <= 0;
                        bit_number <= 0;
                        tx         <= data_reg[0];
                        state      <= DATA;
                    end else begin
                        count <= count + 1'b1;
                    end
                end

                DATA: begin
                    if (count == CLKS_PER_BIT - 1) begin
                        count <= 0;

                        if (bit_number == 3'd7) begin
                            tx    <= 1'b1;
                            state <= STOP;
                        end else begin
                            bit_number <= bit_number + 1'b1;
                            tx <= data_reg[bit_number + 1'b1];
                        end
                    end else begin
                        count <= count + 1'b1;
                    end
                end

                STOP: begin
                    if (count == CLKS_PER_BIT - 1) begin
                        count <= 0;
                        tx    <= 1'b1;
                        busy  <= 1'b0;
                        state <= IDLE;
                    end else begin
                        count <= count + 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                    tx <= 1'b1;
                    busy <= 1'b0;
                end
            endcase
        end
    end

endmodule