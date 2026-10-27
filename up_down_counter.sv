
module up_down_counter (
    input  logic       clk,
    input  logic       reset,
    input  logic       enable,
    input  logic       up_down,  // 1 = up, 0 = down
    output logic [7:0] count
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            count <= 8'd0;
        else if (enable) begin
            if (up_down)
                count <= count + 1'b1;
            else
                count <= count - 1'b1;
        end
    end

endmodule
