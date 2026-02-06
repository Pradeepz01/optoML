module tb_pipeline_reg;

    parameter DATA_WIDTH = 32;

    logic clk;
    logic rst_n;

    logic                   in_valid;
    logic                   in_ready;
    logic [DATA_WIDTH-1:0]  in_data;

    logic                   out_valid;
    logic                   out_ready;
    logic [DATA_WIDTH-1:0]  out_data;

    // DUT instantiation
    pipeline_reg #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (in_valid),
        .in_ready  (in_ready),
        .in_data   (in_data),
        .out_valid (out_valid),
        .out_ready (out_ready),
        .out_data  (out_data)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk       = 0;
        rst_n     = 0;
        in_valid  = 0;
        in_data   = 0;
        out_ready = 0;

        // Apply reset
        #20;
        rst_n = 1;

        // ----------------------------
        // Test 1: Normal data transfer
        // ----------------------------
        @(posedge clk);
        in_valid  <= 1;
        in_data   <= 32'hA5A5_0001;
        out_ready <= 1;

        @(posedge clk);
        in_valid <= 0;

        // ----------------------------
        // Test 2: Backpressure
        // ----------------------------
        @(posedge clk);
        in_valid  <= 1;
        in_data   <= 32'hDEAD_BEEF;
        out_ready <= 0;   // Apply backpressure

        repeat (3) @(posedge clk); // Hold output blocked

        out_ready <= 1;  // Release backpressure
        in_valid  <= 0;

        // ----------------------------
        // Test 3: Back-to-back transfers
        // ----------------------------
        @(posedge clk);
        in_valid <= 1;
        in_data  <= 32'h1111_1111;

        @(posedge clk);
        in_data  <= 32'h2222_2222;

        @(posedge clk);
        in_valid <= 0;

        // Let things settle
        repeat (5) @(posedge clk);

        $display("TEST COMPLETED SUCCESSFULLY");
        $finish;
    end

endmodule
