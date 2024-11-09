# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting test...")

    # Start clocl with period of 1 ns
    clock = Clock(dut.clk, 1, units ="ns")
    cocotb.start_soon(clock.start())
    
    # # Active low reset
    # dut.rst_n.value = 0
    # await ClockCycles(dut.clk, 10)
    # dut.rst_n.value = 1     # exit reset
    
    # Reset the circuit
    dut.rst_n.value = 0  # Apply reset (active low)
    await ClockCycles(dut.clk, 5)  # Hold reset for 5 clock cycles
    dut.rst_n.value = 1  # Release reset
    await ClockCycles(dut.clk, 5)  # Wait a few cycles to settle

    # Test Case 1: Initial state, input of 0 (no input current)
    dut.ui_in.value = 0  # No input current
    await ClockCycles(dut.clk, 10)
    dut._log.info(f"State after no input current: uo_out = {dut.uo_out.value}, uio_out (difference) = {dut.uio_out.value}")
    assert dut.uo_out.value == 0, "Expected state to be zero after no input current"
    assert dut.uio_out.value == 0, "Expected difference output to be zero after no input current"

    # Test Case 2: Apply input current and check state increment
    dut.ui_in.value = 50  # Apply a constant input
    await ClockCycles(dut.clk, 20)
    dut._log.info(f"State after applying current of 50: uo_out = {dut.uo_out.value}, uio_out (difference) = {dut.uio_out.value}")
    assert dut.uo_out.value > 0, "Expected state to increase with input current"
    assert dut.uio_out.value == 0, "Expected no difference output before spike"
    
    dut._log.info("Finished test!")