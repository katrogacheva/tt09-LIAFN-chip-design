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
    
    # Active low reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1     # exit reset
    
    # Test Case 1: Initial state, input of 0 (no input current), states should be zero and there should be no difference
    dut.ui_in.value = 0  # No input current
    await ClockCycles(dut.clk, 10)
    dut._log.info(f"State after no input current: uo_out = {dut.uo_out.value}, uio_out (difference) = {dut.uio_out.value}")
    assert dut.uo_out.value == 0, "Expected state to be zero after no input current"
    assert dut.uio_out.value == 0, "Expected difference output to be zero after no input current"
    await ClockCycles(dut.clk, 10)

    # Test Case 2: Apply input current and check state increase, this is lower than the threshold so the difference should not trigger a spike
    dut.ui_in.value = 50  # Apply a constant input
    await ClockCycles(dut.clk, 20)
    dut._log.info(f"State after applying current of 50: uo_out = {dut.uo_out.value}, uio_out (difference) = {dut.uio_out.value}")
    assert dut.uo_out.value.integer > 0, "Expected state to increase with input current"
    assert dut.uio_out.value == 0, "Expected no difference output before spike"

    # Test Case 3: Apply a larger current and check for spike behavior, spike should be triggered by larger difference
    dut.ui_in.value = 120  # Increase the input to trigger a spike condition
    await ClockCycles(dut.clk, 80)
    dut._log.info(f"State after applying current of 120: uo_out = {dut.uo_out.value}, uio_out (difference) = {dut.uio_out.value}")
    # Check if spike and difference output behave as expected
    assert dut.uio_out.value.integer > 0, "Expected difference output on spike"
    
    # Reset the circuit again to test reset functionality, states should go back to zero
    dut.rst_n.value = 0  # Apply reset
    await ClockCycles(dut.clk, 20)
    dut._log.info(f"State after reset: uo_out = {dut.uo_out.value}, uio_out (difference) = {dut.uio_out.value}")
    assert dut.uo_out.value.integer == 0, "Expected state to reset to zero after reset"
    assert dut.uio_out.value == 0, "Expected difference output to reset to zero after reset"

    # Set reset high and let circuit resume
    dut.rst_n.value = 1  # Release reset
    await ClockCycles(dut.clk, 20)
    dut._log.info(f"State after reset: uo_out = {dut.uo_out.value}, uio_out (difference) = {dut.uio_out.value}")
    assert dut.uo_out.value.integer > 0, "Expected state to be greater than zero after reset going high"
    assert dut.uio_out.value.integer > 0, "Expected difference output to be greater than zero after reset going high"
    
    dut._log.info("Finished test!")