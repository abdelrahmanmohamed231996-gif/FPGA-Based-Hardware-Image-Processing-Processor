# FPGA-Based-Hardware-Image-Processing-Processor

## 📌 Project Overview
This repository contains the RTL implementation of a **Real-Time 2D Convolution Hardware Accelerator**. Designed entirely in **Verilog HDL**, the system is optimized for **FPGA** deployment to perform on-the-fly image filtering (e.g., Edge Detection, Sharpening, Blurring) without relying on a general-purpose CPU.

The processed images are output directly to a monitor using a custom-designed **VGA Display Controller**, showcasing a complete end-to-end hardware system.

## 🚀 Key Features
* **Real-Time Processing:** Hardware-accelerated MAC (Multiply-Accumulate) units for high-throughput pixel computation.
* **FPGA Proven:** Fully synthesizable RTL design targeted and verified on FPGA hardware.
* **VGA Interface:** Integrated VGA sync generator to display the filtered video/image stream directly to a screen.
* **Optimized Memory Architecture:** Utilizes Line Buffers / Shift Registers to handle image kernel windowing efficiently.
* **Industry-Standard Tools:** Verification using QuestaSim and Synthesis/Implementation via Xilinx Vivado.

## 📂 Repository Structure
```text
├── docs/          # Architecture diagrams, block designs, and documentation
├── rtl/           # Synthesizable Verilog source files (MAC, Line Buffers, VGA Controller)
├── tb/            # Testbenches for module-level and system-level verification
├── scripts/       # TCL scripts for automation
└── synth/         # Synthesis logs and reports (Ignored in Git)
```

## 🛠️ Core Modules 
1. **VGA Controller:** Generates H-Sync, V-Sync, and coordinates pixel data output to the monitor.
2. **Line Buffer:** Manages row data caching to supply a 3x3 (or NxN) window to the convolution engine.
3. **MAC Engine (Multiply-Accumulate):** The arithmetic core applying the convolution kernel weights to the image pixels.
4. **Main Controller/FSM:** Orchestrates data flow between memory, the convolution core, and the VGA output.

## 👥 Team
* **Abdelrahman**
* **Ramadan**
* **Ayman**

---
*Developed as part of practical RTL design and digital IC verification endeavors.*
