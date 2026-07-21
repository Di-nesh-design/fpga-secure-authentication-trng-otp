module trng_core (
    input  wire clk,
    input  wire reset,
    output reg  random_valid,
    output reg  random_bit
);

    wire ro0, ro1, ro2;

    trng_ring ring0 (.ro(ro0));
    trng_ring ring1 (.ro(ro1));
    trng_ring ring2 (.ro(ro2));

    (* ASYNC_REG = "TRUE" *) reg ro0_ff1, ro0_ff2;
    (* ASYNC_REG = "TRUE" *) reg ro1_ff1, ro1_ff2;
    (* ASYNC_REG = "TRUE" *) reg ro2_ff1, ro2_ff2;

    reg [15:0] sample_count;
    reg first_bit;
    reg have_first_bit;

    wire sampled_bit = ro0_ff2 ^ ro1_ff2 ^ ro2_ff2;

    always @(posedge clk) begin
        if (reset) begin
            ro0_ff1 <= 0;
            ro0_ff2 <= 0;
            ro1_ff1 <= 0;
            ro1_ff2 <= 0;
            ro2_ff1 <= 0;
            ro2_ff2 <= 0;
            sample_count <= 0;
            first_bit <= 0;
            have_first_bit <= 0;
            random_valid <= 0;
            random_bit <= 0;
        end else begin
            ro0_ff1 <= ro0;
            ro0_ff2 <= ro0_ff1;
            ro1_ff1 <= ro1;
            ro1_ff2 <= ro1_ff1;
            ro2_ff1 <= ro2;
            ro2_ff2 <= ro2_ff1;

            random_valid <= 0;
            sample_count <= sample_count + 1'b1;

            if (sample_count == 16'd0) begin
                if (!have_first_bit) begin
                    first_bit <= sampled_bit;
                    have_first_bit <= 1'b1;
                end else begin
                    have_first_bit <= 1'b0;

                    // Von Neumann whitening
                    if ({first_bit, sampled_bit} == 2'b01) begin
                        random_bit <= 1'b0;
                        random_valid <= 1'b1;
                    end else if ({first_bit, sampled_bit} == 2'b10) begin
                        random_bit <= 1'b1;
                        random_valid <= 1'b1;
                    end
                end
            end
        end
    end

endmodule


(* KEEP_HIERARCHY = "yes", DONT_TOUCH = "yes" *)
module trng_ring (
    output wire ro
);

    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) wire [2:0] ro_chain;

    assign ro_chain[0] = ~ro_chain[2];
    assign ro_chain[1] = ~ro_chain[0];
    assign ro_chain[2] = ~ro_chain[1];

    assign ro = ro_chain[2];

endmodule