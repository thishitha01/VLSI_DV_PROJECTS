// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module tb_multiplier;

    // DUT signals
    logic clk;
    logic rst_n;
    logic [15:0] a, b;
    logic [31:0] res;

    // DUT instantiation
    multiplier dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .res(res)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset and stimulus
    initial begin
      
      $dumpfile("waveform.vcd");   // VCD file name
        $dumpvars(0, tb_multiplier);
      
      rst_n = 0; //(active low reset)
        a = 0;
        b = 0;
      repeat (5) @(posedge clk);
        rst_n = 1;

        // Apply some test vectors
       // Hit all individual bins
        drive(0,0);           // zero-zero
        drive(5,7);           // low-low
        drive(150,180);       // mid-mid
        drive(32760,32767);   // high-high

        // Hit cross bins explicitly
        drive(0,5);           // zero-low
        drive(0,150);         // zero-mid
        drive(0,32760);       // zero-high
        drive(5,0);           // low-zero
        drive(5,150);         // low-mid
        drive(5,32760);       // low-high
        drive(150,0);         // mid-zero
        drive(150,5);         // mid-low
        drive(150,32760);     // mid-high
        drive(32760,0);       // high-zero
        drive(32760,5);       // high-low
        drive(32760,150);     // high-mid


        // Random stimulus for coverage
        repeat (50) drive($urandom_range(0, 65535), $urandom_range(0, 65535));

        repeat (5) @(posedge clk);
        $display("Coverage = %0.2f%%", cov.get_coverage());
        $finish;
    end

    // Task to send one set of inputs
    task drive(input logic [15:0] a_val, input logic [15:0] b_val);
        @(posedge clk);
        a <= a_val;
        b <= b_val;
    endtask

    // ================================
    // Assertions
    // ================================
   
    property p_correct_mult;
        @(posedge clk) disable iff (!rst_n)
            res == $past(a) * $past(b);
    endproperty
    assert property (p_correct_mult)
        else $error("Multiplier output incorrect: a=%0d b=%0d res=%0d expected=%0d",
                    $past(a), $past(b), res, $past(a) * $past(b));

    // ================================
    // Functional Coverage
    // ================================
    covergroup cov @(posedge clk);
        option.per_instance = 1;

       coverpoint a {
    bins zero  = {0};
    bins low = { [1:10] };
    bins mid   = { [100:200] };
    bins high = { [32760:32767] };
}

coverpoint b {
    bins zero  = {0};
    bins low = { [1:10] };
    bins mid   = { [100:200] };
    bins high = { [32760:32767] };
}


        cross a, b;

        coverpoint res {
            bins zero = {0};
            bins low = {[1:100]};
            bins mid   = {[101:10000]};
            bins highj = {[10001:32'hFFFF_FFFF]};
        }
    endgroup

    cov c = new();

endmodule
