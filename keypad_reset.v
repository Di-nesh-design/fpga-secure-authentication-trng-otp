module keypad_soft_reset (
    input  wire       clk,
    input  wire       por_reset,
    input  wire       key_valid,
    input  wire [7:0] key_ascii,
    output wire       soft_reset
);

    // 50 ms reset period at 100 MHz.
    reg [22:0] reset_count;

    assign soft_reset = |reset_count;

    always @(posedge clk) begin
        if (por_reset) begin
            reset_count <= 0;
        end else if (key_valid && (key_ascii == "F")) begin
            reset_count <= 23'd5_000_000;
        end else if (reset_count != 0) begin
            reset_count <= reset_count - 1'b1;
        end
    end

endmodule