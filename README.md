<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0f2027,50:203a43,100:2c5364&height=200&section=header&text=Design%20Validation%20for%20HDL%20Models&fontSize=35&fontColor=ffffff&animation=fadeIn&fontAlignY=35"/>
</p>

# SDRAM-Functional-Verification-Project

![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)
![Design](https://img.shields.io/badge/Design-SDRAM_Controller-red)
![Verification](https://img.shields.io/badge/Verification-ABV-green)
![Simulator](https://img.shields.io/badge/Simulator-ModelSim-purple)
![Coverage](https://img.shields.io/badge/Functional_Coverage-100%25-success)
![Code Coverage](https://img.shields.io/badge/Code_Coverage-97.24%25-brightgreen)
![Status](https://img.shields.io/badge/Status-Complete-success)
![University](https://img.shields.io/badge/University-University_of_Tehran-blueviolet)
![Course](https://img.shields.io/badge/Course-HDL_Verification-orange)

## Overview

This project presents a complete functional verification environment for an SDRAM controller using **SystemVerilog** and **ModelSim**.  
The project was developed as part of the **HDL Model Verification** course at the University of Tehran under the supervision of **Dr. Siamak Mohammadi**.

The verification environment was incrementally developed through multiple project phases, including:

- Deterministic stimulus generation
- Random/semi-random stimulus generation
- Golden model implementation
- Checker and scoreboard design
- Assertion-based verification
- Functional coverage collection
- Code coverage analysis

  <p align="center"> <img src="images/random_constraint.png" width="700"> </p>

The final implementation achieved:

- ✅ **100% Functional Coverage**
- ✅ **97.24% Code Coverage**

---

## Verification Architecture

The verification environment includes the following components:

- **Stimulus Generator**
  - Deterministic scenarios
  - Randomized scenarios

- **Golden Model**
  - Reference SDRAM behavior modeling

- **Checker**
  - Output timing and data validation

- **Scoreboard**
  - DUV vs Golden Model comparison

- **Assertions**
  - Protocol and behavior checking

- **Functional Coverage**
  - Coverage-driven verification

---

## Verification Scenarios

Implemented test scenarios include:

- Memory write/read operations
- Accessing different memory banks and rows
- Consecutive read/write transactions
- Reset behavior validation
- Invalid `X` value testing for write signal
- Corner-case verification
- Randomized transaction generation

---

## Project Structure

```bash
├── src/
│   ├── sdram_controller.v
│   ├── sdram_model.v
│   ├── sdram_top.v
│   ├── testbench.v
│   ├── random_stimuli_generator.sv
│   ├── checker.sv
│   ├── scoreboard.sv
│   ├── Golden_Model_sdram.sv
│   ├── functional_coverage.sv
│   └── sdram_assertions.sv
│
├── Simulation/
│   ├── modelsim.ini
│   ├── wave.do
│   ├── compile.do
│   └── simulation_outputs/
│
├── Coverage Report/
│   └── coverage_report.pdf
│
└── README.md
```
## SDRAM Design Schematic

The following figure illustrates the SDRAM architecture and internal modules used in the verification process.

<p align="center"> <img src="images/sdram_architecture.jpg" width="700"> </p>

## ModelSim Waveform Results

The waveform below demonstrates successful SDRAM write/read operations and validates correct timing behavior between the DUV and Golden Model.

<p align="center"> <img src="images/modelsim_waveform.png" width="850"> </p>

## Functional & Code Coverage Report

Coverage analysis was performed using ModelSim coverage tools.

 Final results:

* Functional Coverage: 100%
* Code Coverage: 97.24%
  
<p align="center"> <img src="images/coverage_report.png" width="600"> </p>

## Tools & Technologies
* SystemVerilog
* Verilog HDL
* ModelSim SE-64 2020.4
* Assertion-Based Verification (ABV)
* Functional Coverage
* Coverage-Driven Verification
* 
## Course Information
* Course: HDL Model Verification
* Instructor: Dr. Siamak Mohammadi
* University: University of Tehran
* Semester: Fall 2024
## Key Achievements
* Designed a complete reusable verification environment
* Implemented deterministic and random stimulus generators
* Developed a cycle-accurate SDRAM Golden Model
* Built checker and scoreboard modules
* Achieved full functional coverage
* Performed comprehensive code coverage analysis
## License

This project is intended for educational and academic purposes.


---
