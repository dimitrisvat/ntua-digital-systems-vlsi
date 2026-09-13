# VLSI Digital Systems

Academic projects developed at the **National Technical University of Athens (NTUA)** as part of the 8th-semester VLSI Digital Systems course.

This repository contains the **VHDL implementation, hardware-software co-design, and testing of digital systems**, ranging from basic arithmetic circuits to runtime reconfigurable image processing accelerators. 

## Highlights

- Synchronous arithmetic circuits (Pipelined Adders, Systolic Multipliers)
- 8-tap FIR filter implementation with custom MAC, ROM, and RAM units
- Hardware/Software co-design on the ZYNQ SoC (ARM processor and FPGA)
- Communication via AXI4-Lite and AXI-Stream interfaces
- GBRG-type debayering image filters (Static and Runtime Reconfigurable)
- FPGA resource utilization and CPU vs. FPGA speedup analysis

## Tools

- VHDL
- Xilinx Vivado & Vitis
- ZYBO Development Board (Zynq-7000)

## Repository Structure

* **[`exercise-1/`](./exercise-1/) — Introductory VHDL**
  * Foundational combinational/sequential logic, behavioral modeling, and testbench validation.
* **[`exercise-2/`](./exercise-2/) — Adders & Systolic Multipliers**
  * Synchronous 4-bit Pipelined Adders and a 10-stage 4-bit Systolic Multiplier array.
* **[`exercise-3/`](./exercise-3/) — 8-Tap FIR Filter Architecture**
  * Hardware filter design with custom MAC unit, coefficient ROM, shift RAM, and central control FSM.
* **[`exercise-4/`](./exercise-4/) — FIR Filter ZYBO Deployment**
  * Integration of an AXI4-Lite IP wrapper and C host application for ARM-to-FPGA data exchange.
* **[`exercise-5/`](./exercise-5/) — Static GBRG Debayering Filter**
  * Image demosaicing engine using 3x3 sliding window line buffers for static $N \times N$ frames.
* **[`exercise-6/`](./exercise-6/) — Runtime Reconfigurable Accelerator**
  * Dynamic image dimension scaling via AXI-Stream interfaces, DMA transfers, and execution profiling.
---

**National Technical University of Athens — 2025/2026**

Dimitris V. & Aristotelis D.
