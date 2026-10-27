
module tb_up_down_counter;

    logic clk;
    logic reset;
    logic enable;
    logic up_down;
    logic [7:0] count;

    integer passed = 0;
    integer failed = 0;

    up_down_counter dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .up_down(up_down),
        .count(count)
    );

    // Generate a clock with a 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    task automatic check_count(
        input logic [7:0] expected,
        input string test_name
    );
        begin
            if (count !== expected) begin
                $display("FAIL: %s | Expected=%0d Actual=%0d",
                         test_name, expected, count);
                failed = failed + 1;
            end
            else begin
                $display("PASS: %s | Count=%0d",
                         test_name, count);
                passed = passed + 1;
            end
        end
    endtask

    initial begin
        reset = 0;
        enable = 0;
        up_down = 1;

        $display("===== UP/DOWN COUNTER TESTS =====");

        // Test 1: Reset
        reset = 1;
        #1;
        check_count(8'd0, "Asynchronous reset");
        @(negedge clk);
        reset = 0;

        // Test 2: Count up
        enable = 1;
        up_down = 1;

        @(negedge clk);
        check_count(8'd1, "Count up to 1");

        @(negedge clk);
        check_count(8'd2, "Count up to 2");

        // Test 3: Hold count
        enable = 0;

        @(negedge clk);
        check_count(8'd2, "Hold when disabled");

        // Test 4: Count down
        enable = 1;
        up_down = 0;

        @(negedge clk);
        check_count(8'd1, "Count down to 1");

        @(negedge clk);
        check_count(8'd0, "Count down to 0");

        // Test 5: Underflow: 0 - 1 = 255
        @(negedge clk);
        check_count(8'd255, "Underflow wraparound");

        // Test 6: Reset again
        reset = 1;
        #1;
        check_count(8'd0, "Reset after counting");
        @(negedge clk);
        reset = 0;

        // Test 7: Count up to 255
        // Load 255 through 255 enabled clock cycles.
        enable = 1;
        up_down = 1;

        repeat (255) @(negedge clk);
        check_count(8'd255, "Count reaches 255");

        // Test 8: Overflow: 255 + 1 = 0
        @(negedge clk);
        check_count(8'd0, "Overflow wraparound");

        $display("================================");
        $display("Tests passed: %0d", passed);
        $display("Tests failed: %0d", failed);

        if (failed == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");

        $finish;
    end

endmodule
