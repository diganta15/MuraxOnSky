# 🚀 Murax RISC-V SoC: Sky130 Tapeout

![Sky130](https://img.shields.io/badge/Process-Sky130-blue)
![OpenLANE](https://img.shields.io/badge/Tools-OpenLANE%20%2F%20OpenROAD-purple)
![Architecture](https://img.shields.io/badge/Architecture-RISC--V%20(RV32I)-orange)
![Status](https://img.shields.io/badge/Status-DRC%20%26%20LVS%20Clean-success)

## Overview
This repository contains the full physical design and RTL-to-GDSII pipeline for a custom 32-bit RISC-V microcontroller. The core architecture is based on the **Murax (VexRiscv)** CPU, integrated into the **Efabless Caravel** user project wrapper and targeted for the **SkyWater 130nm** open-source foundry node.

## 🛠️ Engineering Highlights
Designing a modern SoC requires navigating severe physical routing constraints. This project successfully utilizes a **Hierarchical Physical Design Flow** to bypass heavy core congestion:
* **Isolated Macro Hardening:** The 17,000+ gate Murax CPU was synthesized and routed as an isolated, dense physical macro to prevent OpenROAD routing exhaustion.
* **Top-Level Integration:** The hardened CPU macro was instantiated as a blackbox and successfully integrated into the 2.9mm x 3.5mm Caravel canvas.
* **Signoff:** The final layout achieved complete routing with **0 DRC and 0 LVS violations**, successfully passing the Efabless precheck pipeline.

*(Note: Don't forget to drop one of your stunning 3D Blender renders of the met4/met5 layers right here so people can see the physical silicon!)*