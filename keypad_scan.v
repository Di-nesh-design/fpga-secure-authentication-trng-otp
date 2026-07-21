module keypad_scan (
    input  wire       clk,
    input  wire       reset,
    output reg  [3:0] col,
    input  wire [3:0] row,
    output reg        key_valid,
    output reg  [7:0] key_ascii
);

    reg [16:0] tick_count;
    reg [1:0]  scan_col;
    reg        key_held;
    reg        frame_has_key;
    reg        released_frames;

    function [7:0] decode_key;
        input [1:0] c;
        input [1:0] r;
        begin
            case ({c, r})
                4'b0000: decode_key = "1";
                4'b0001: decode_key = "4";
                4'b0010: decode_key = "7";
                4'b0011: decode_key = "0";

                4'b0100: decode_key = "2";
                4'b0101: decode_key = "5";
                4'b0110: decode_key = "8";
                4'b0111: decode_key = "F";

                4'b1000: decode_key = "3";
                4'b1001: decode_key = "6";
                4'b1010: decode_key = "9";
                4'b1011: decode_key = "E";

                4'b1100: decode_key = "A";
                4'b1101: decode_key = "B";
                4'b1110: decode_key = "C";
                default: decode_key = "D";
            endcase
        end
    endfunction

    function [1:0] row_number;
        input [3:0] r;
        begin
            if (!r[0])
                row_number = 2'd0;
            else if (!r[1])
                row_number = 2'd1;
            else if (!r[2])
                row_number = 2'd2;
            else
                row_number = 2'd3;
        end
    endfunction

    always @(*) begin
        case (scan_col)
            2'd0:   col = 4'b1110;
            2'd1:   col = 4'b1101;
            2'd2:   col = 4'b1011;
            default: col = 4'b0111;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            tick_count      <= 0;
            scan_col        <= 0;
            key_held        <= 0;
            frame_has_key   <= 0;
            released_frames <= 0;
            key_valid       <= 0;
            key_ascii       <= 0;
        end else begin
            key_valid <= 0;

            if (tick_count == 100_000 - 1) begin
                tick_count <= 0;

                if ((row != 4'b1111) && !key_held) begin
                    key_ascii <= decode_key(scan_col, row_number(row));
                    key_valid <= 1'b1;
                    key_held <= 1'b1;
                end

                if (row != 4'b1111)
                    frame_has_key <= 1'b1;

                if (scan_col == 2'd3) begin
                    if (!frame_has_key && (row == 4'b1111)) begin
                        if (released_frames) begin
                            key_held <= 1'b0;
                            released_frames <= 1'b0;
                        end else begin
                            released_frames <= 1'b1;
                        end
                    end else begin
                        released_frames <= 1'b0;
                    end

                    frame_has_key <= 1'b0;
                end

                scan_col <= scan_col + 1'b1;
            end else begin
                tick_count <= tick_count + 1'b1;
            end
        end
    end

endmodule