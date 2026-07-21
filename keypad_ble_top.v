module keypad_ble_top (
    input  wire       clk,
    output wire [3:0] col,
    input  wire [3:0] row,
    output reg  [15:0] led,
    output wire       ble_uart_rx
);

    reg [4:0] por_count;

    wire por_reset = ~(&por_count);
    wire soft_reset;
    wire reset = por_reset | soft_reset;

    wire key_valid;
    wire [7:0] key_ascii;

    wire entropy_valid, entropy_bit;
    wire success, failure, locked;
    wire otp_new;
    wire [23:0] otp;

    wire uart_start, uart_busy;
    wire [7:0] uart_data;

    reg [24:0] led_timer;

    initial begin
        por_count = 0;
        led = 0;
        led_timer = 0;
    end

    always @(posedge clk) begin
        if (!(&por_count))
            por_count <= por_count + 1'b1;
    end

    keypad_scan scanner (
        .clk(clk),
        .reset(reset),
        .col(col),
        .row(row),
        .key_valid(key_valid),
        .key_ascii(key_ascii)
    );

    // Press F on the keypad to create a new OTP and clear lockout.
    keypad_soft_reset reset_control (
        .clk(clk),
        .por_reset(por_reset),
        .key_valid(key_valid),
        .key_ascii(key_ascii),
        .soft_reset(soft_reset)
    );

    trng_core trng (
        .clk(clk),
        .reset(reset),
        .random_valid(entropy_valid),
        .random_bit(entropy_bit)
    );

    otp_lock_controller locker (
        .clk(clk),
        .reset(reset),
        .entropy_valid(entropy_valid),
        .entropy_bit(entropy_bit),
        .key_valid(key_valid),
        .key_ascii(key_ascii),
        .otp(otp),
        .otp_new(otp_new),
        .success(success),
        .failure(failure),
        .locked(locked)
    );

    otp_uart_sender sender (
        .clk(clk),
        .reset(reset),
        .send_otp(otp_new),
        .otp(otp),
        .uart_busy(uart_busy),
        .uart_start(uart_start),
        .uart_data(uart_data)
    );

    uart_tx #(.CLKS_PER_BIT(868)) uart (
        .clk(clk),
        .reset(reset),
        .start(uart_start),
        .data(uart_data),
        .tx(ble_uart_rx),
        .busy(uart_busy)
    );

    always @(posedge clk) begin
        if (reset) begin
            led <= 16'h0000;
            led_timer <= 0;
        end else if (locked) begin
            led <= 16'hFFFF;          // All LEDs: locked
        end else if (success) begin
            led <= 16'h001F;          // LED0-LED4: correct OTP
            led_timer <= 0;
        end else if (failure) begin
            led <= 16'h8000;          // LED15: wrong OTP
            led_timer <= 0;
        end else if (led != 0) begin
            if (led_timer == 25_000_000 - 1) begin
                led <= 0;
                led_timer <= 0;
            end else begin
                led_timer <= led_timer + 1'b1;
            end
        end
    end

endmodule