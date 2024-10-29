module fifo_with_delay #(parameter FIFO_DEPTH = 16, DATA_WIDTH = 4) (
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
    reg [$clog2(FIFO_DEPTH)-1:0] write_ptr, read_ptr;
    integer fifo_count;

    // FIFO write operation
    always @(posedge clk) begin
        if (rst) begin
            write_ptr <= 0;
            fifo_count <= 0;
            full <= 0;
            empty <= 1;
        end else if (write_en && !full) begin
            fifo_mem[write_ptr] <= data_in;
            write_ptr <= (write_ptr + 1) % FIFO_DEPTH;
            fifo_count <= fifo_count + 1;
            full <= (fifo_count + 1 == FIFO_DEPTH);
            empty <= 0;
        end
    end

    // FIFO read operation
    always @(posedge clk) begin
        if (rst) begin
            read_ptr <= 0;
            data_out <= 0;
        end else if (read_en && !empty) begin
            data_out <= fifo_mem[read_ptr];
            read_ptr <= (read_ptr + 1) % FIFO_DEPTH;
            fifo_count <= fifo_count - 1;
            empty <= (fifo_count - 1 == 0);
            full <= 0;
        end
    end

    // Full and empty flag logic update
    always @(posedge clk) begin
        if (rst) begin
            full <= 0;
            empty <= 1;
        end else begin
            full <= (fifo_count == FIFO_DEPTH);
            empty <= (fifo_count == 0);
        end
    end

endmodule
