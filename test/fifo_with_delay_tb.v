`timescale 1ns / 1ps

module tb_fifo_with_delay_tb;

    // Parameters
    parameter FIFO_DEPTH = 16;
    parameter DATA_WIDTH = 8;
    parameter PIPELINE_DEPTH = 4; // Change this to a larger value to observe a larger delay

    // Testbench signals
    reg clk;
    reg rst;
    reg write_en;
    reg read_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire full;
    wire empty;

    // Instantiate the FIFO with delay module
    fifo_with_delay #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .PIPELINE_DEPTH(PIPELINE_DEPTH)
    ) fifo_dut (
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .read_en(read_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10 ns period, 100 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        write_en = 0;
        read_en = 0;
        data_in = 0;

        // Reset the FIFO
        #20 rst = 0;

        // Write some data into the FIFO
        #10;
        write_en = 1;
        data_in = 8'hA1;  // First data
        #10;
        data_in = 8'hB2;  // Second data
        #10;
        data_in = 8'hC3;  // Third data
        #10;
        data_in = 8'hD4;  // Fourth data
        #10;
        write_en = 0;  // Stop writing

        // Wait for a few cycles to observe the pipeline delay
        #50;

        // Enable read to start retrieving data from FIFO with delay
        read_en = 1;

        // Continue reading for several cycles to observe delayed data output
        #100;
        read_en = 0;

        // End simulation
        #50;
        $stop;
    end

    // Monitor output to see the delay effect
    initial begin
        $dumpfile("test/tb_fifo_with_delay_tb.vcd");
        $dumpvars(0, tb_fifo_with_delay_tb);
    end

endmodule
