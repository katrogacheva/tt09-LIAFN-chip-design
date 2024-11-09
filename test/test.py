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
    
    # Provide stimulus into circuit - current input
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 10)
    dut.ui_in.value = 120
    await ClockCycles(dut.clk, 100)
    
    dut._log.info("Finished test!")