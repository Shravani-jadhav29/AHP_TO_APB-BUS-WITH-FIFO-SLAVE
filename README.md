# AHP_TO_APB-BUS-WITH-FIFO-SLAVE

An implementation of an **AHB-Lite Master to APB Bridge** protocol converter featuring FIFO-buffered slave interfaces designed for FPGA implementation (Nexys A7) using Verilog HDL.

## Overview
This project bridges high-performance **AHB-Lite** bus architecture with low-power **APB (Advanced Peripheral Bus)** devices. It includes a FIFO buffer to handle asynchronous data rate differences and multi-peripheral routing via an APB decoder.

## Repository Structure
* `AHB_lite_master.v`: Implementation of the AHB-Lite Master interface.
* `AHB_top.v`: Top-level module integrating the AHB interface for the Nexys A7 FPGA platform.
* `bridge_without_pipeline.v`: Unpipelined AHB to APB bridge logic.
* `APB_DECODER.v`: Address decoding module for peripheral selection across the APB bus.
* `APB_SLAVE.v`: APB slave peripheral interface.
* `FIFO.v`: Asynchronous/Synchronous FIFO memory module for temporary data storage.
* `dispay.v`: 7-segment display multiplexer module.
* `hex_to_7seg.v`: Hexadecimal to 7-segment decoder module.
* `xcd`: Xilinx Design Constraints (XDC) file defining I/O standards and package pin assignments.

## Features
* **Protocol Bridging**: Converts AHB-Lite transfer protocols into APB transfers.
* **Buffered Slave Interface**: Utilizes FIFO storage to prevent bus stalls.
* **Peripheral Selection**: Includes an APB decoder to drive multiple slaves.
* **Hardware Visualization**: Built-in 7-segment display modules (`hex_to_7seg` and `dispay`) for hardware debugging on the Nexys A7 FPGA.

## Hardware Platform
* **Target Board**: Nexys A7 FPGA
* **Language**: Verilog HDL
