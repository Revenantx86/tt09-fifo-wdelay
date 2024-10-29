import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_fifo_with_delay(dut):
    # Initialize and set up the clock
    clock = Clock(dut.clk, 10, units="ns")  # 100 MHz clock
    cocotb.start_soon(clock.start())
    dut._log.info("Starting test for tt_um_revenantx86_fifo_delay")

    # Reset the design (rst_n is active-low)
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    dut._log.info("Released reset")

    # Write some data into the FIFO
    data_values = [0b1010, 0b1100, 0b1110, 0b1111]  # Example 4-bit data values

    for data in data_values:
        dut.ui_in[0].value = 1       # Set write_en high
        dut.ui_in[1].value = 0       # Ensure read_en is low
        dut.ui_in[2].value = (data >> 0) & 1  # Load data bit 0
        dut.ui_in[3].value = (data >> 1) & 1  # Load data bit 1
        dut.ui_in[4].value = (data >> 2) & 1  # Load data bit 2
        dut.ui_in[5].value = (data >> 3) & 1  # Load data bit 3
        dut._log.info(f"Writing data: {bin(data)}")
        await ClockCycles(dut.clk, 1)

    # Stop writing and wait for the pipeline delay
    dut.ui_in[0].value = 0  # Set write_en low
    delay_cycles = 50  # Adjust this based on expected pipeline delay
    dut._log.info(f"Waiting for {delay_cycles} cycles for delay")
    await ClockCycles(dut.clk, delay_cycles)

    # Start reading from the FIFO and check outputs
    dut.ui_in[1].value = 1  # Set read_en high

    for i, expected_data in enumerate(data_values):
        await RisingEdge(dut.clk)
        observed_data = (dut.uo_out[5].value << 3) | (dut.uo_out[4].value << 2) | (dut.uo_out[3].value << 1) | dut.uo_out[2].value
        dut._log.info(f"Cycle {i+1}: Expected data: {bin(expected_data)}, Observed data: {bin(observed_data)}")
        assert observed_data == expected_data, f"Mismatch at cycle {i+1}: expected {bin(expected_data)}, got {bin(observed_data)}"

    # Stop reading
    dut.ui_in[1].value = 0

    dut._log.info("Finished test for tt_um_revenantx86_fifo_delay")
