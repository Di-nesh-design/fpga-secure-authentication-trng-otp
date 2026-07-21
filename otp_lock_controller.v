module otp_lock_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire       entropy_valid,
    input  wire       entropy_bit,
    input  wire       key_valid,
    input  wire [7:0] key_ascii,

    output reg [23:0] otp,
    output reg        otp_new,
    output reg        success,
    output reg        failure,
    output reg        locked
);

    reg [2:0] bit_count;
    reg [2:0] digit_count;
    reg [3:0] current_nibble;
    reg [2:0] position;
    reg [1:0] failed_attempts;
    reg       generating;
    reg [7:0] expected_key;

    function [7:0] hex_to_ascii;
        input [3:0] value;
        begin
            if (value < 10)
                hex_to_ascii = "0" + value;
            else
                hex_to_ascii = "A" + (value - 10);
        end
    endfunction

    always @(*) begin
        case (position)
            3'd0: expected_key = hex_to_ascii(otp[23:20]);
            3'd1: expected_key = hex_to_ascii(otp[19:16]);
            3'd2: expected_key = hex_to_ascii(otp[15:12]);
            3'd3: expected_key = hex_to_ascii(otp[11:8]);
            3'd4: expected_key = hex_to_ascii(otp[7:4]);
            default: expected_key = hex_to_ascii(otp[3:0]);
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            otp             <= 0;
            otp_new         <= 0;
            success         <= 0;
            failure         <= 0;
            locked          <= 0;
            bit_count       <= 0;
            digit_count     <= 0;
            current_nibble  <= 0;
            position        <= 0;
            failed_attempts <= 0;
            generating      <= 1'b1;
        end else begin
            otp_new <= 0;
            success <= 0;
            failure <= 0;

            // Generate six random characters from 0-9 and A-D.
            // E and F are discarded. F is reserved for reset.
            if (generating && entropy_valid) begin
                current_nibble <= {current_nibble[2:0], entropy_bit};

                if (bit_count == 3'd3) begin
                    bit_count <= 0;

                    if ({current_nibble[2:0], entropy_bit} <= 4'd13) begin
                        otp <= {otp[19:0], current_nibble[2:0], entropy_bit};

                        if (digit_count == 3'd5) begin
                            digit_count <= 0;
                            generating <= 0;
                            otp_new <= 1'b1;
                        end else begin
                            digit_count <= digit_count + 1'b1;
                        end
                    end
                end else begin
                    bit_count <= bit_count + 1'b1;
                end
            end

            if (!generating && !locked && key_valid) begin
                if (key_ascii == expected_key) begin
                    if (position == 3'd5) begin
                        success <= 1'b1;
                        position <= 0;
                        failed_attempts <= 0;
                        generating <= 1'b1; // Generate next OTP
                    end else begin
                        position <= position + 1'b1;
                    end
                end else begin
                    position <= 0;
                    failure <= 1'b1;

                    if (failed_attempts == 2'd2)
                        locked <= 1'b1; // Third failure locks system
                    else
                        failed_attempts <= failed_attempts + 1'b1;
                end
            end
        end
    end

endmodule