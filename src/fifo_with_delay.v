module fifo_with_delay #(parameter FIFO_DEPTH = 16, DATA_WIDTH = 4, PIPELINE_DEPTH = 4)(
    input clk,
    input rst,
    input write_en,
    input read_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg full,
    output reg empty
);

    // Internal FIFO buffer
    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [FIFO_DEPTH-1:0] write_ptr, read_ptr;
    reg [DATA_WIDTH-1:0] pipeline [0:PIPELINE_DEPTH-1];

    integer i;

    // FIFO write operation
    always @(posedge clk) begin
        if (rst) begin
            write_ptr <= 0;
        end else if (write_en && !full) begin
            fifo_mem[write_ptr] <= data_in;
            write_ptr <= write_ptr + 1;
        end
    end

    // FIFO read operation
    always @(posedge clk) begin
        if (rst) begin
            read_ptr <= 0;
        end else if (read_en && !empty) begin
            pipeline[0] <= fifo_mem[read_ptr];  // Load FIFO output into pipeline start
            read_ptr <= read_ptr + 1;
        end
    end

    // Pipeline for combinatorial delay
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < PIPELINE_DEPTH; i = i + 1) begin
                pipeline[i] <= 0;
            end
        end else begin
            // Shift data through the pipeline
            for (i = 1; i < PIPELINE_DEPTH; i = i + 1) begin
                pipeline[i] <= pipeline[i-1];
            end
            data_out <= pipeline[PIPELINE_DEPTH-1];  // Output the last pipeline stage
        end
    end

    // Full and empty flags
    assign full = (write_ptr == FIFO_DEPTH-1);
    assign empty = (read_ptr == FIFO_DEPTH-1);

endmodule
