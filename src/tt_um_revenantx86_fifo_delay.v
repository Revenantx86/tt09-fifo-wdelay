/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_revenantx86_fifo_delay 
(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
  //
  wire rst;
  wire write_en;
  wire read_en;
  wire full;
  wire empty;
  wire [3:0] data_in;
  wire [3:0] data_out;
  //
  assign rst = ~rst_n;
  //
  /*
    Assign IO
  */
  // Input Assign
  assign write_en   = ui_in[0];
  assign read_en    = ui_in[1];
  assign data_in[0] = ui_in[2];
  assign data_in[1] = ui_in[3];
  assign data_in[2] = ui_in[4];
  assign data_in[3] = ui_in[5];

  // Output Assign
  assign uo_out[0] = full;
  assign uo_out[1] = empty;
  assign uo_out[2] = data_out[0];
  assign uo_out[3] = data_out[1];
  assign uo_out[4] = data_out[2];
  assign uo_out[5] = data_out[3];
  assign uo_out[6] = 0;
  assign uo_out[7] = 0;
  //
  assign uio_oe = 8'b00;
  assign uio_out = 8'b0;
  //
  fifo_with_delay #(.FIFO_DEPTH(16), .DATA_WIDTH(4), .PIPELINE_DEPTH(4)) 
      fifo_with_delay_inst (
                          .clk(clk),
                          .rst(rst),
                          .write_en(write_en),
                          .read_en(read_en),
                          .data_in(data_in),
                          .data_out(data_out),
                          .full(full),
                          .empty(empty)
                       );
endmodule
