<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:6a0dad,50:7b2cbf,100:9d4edd&height=200&section=header&text=Design%20Validation%20for%20HDL%20Models&fontSize=35&fontColor=ffffff&animation=fadeIn&fontAlignY=35"/>
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

  <p align="left"> <img src="images/random_constraint.png" width="500"> </p>

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


## Modules

### 1. SDRAM Model
* Purpose: Simulates the behavior of an SDRAM chip.
* Key Features:
   * Memory array divided into banks, rows, and columns.
   * Handles read and write operations based on control signals (CS, RAS, CAS, WE).
  
### 2. SDRAM Controller
* Purpose: Manages read/write requests and interacts with the SDRAM model.
* Key Features:
  * Implements a finite state machine (FSM) for SDRAM operations.
  * Decodes address into bank, row, and column.
  * Ensures timing constraints of SDRAM commands.
  
### 3. Stimuli
* Purpose: Generates predefined test scenarios for SDRAM testing.
* Key Features:
  * Includes tasks for initialization, sequential writing, and reading.
  * Covers specific scenarios like timing-based writes and invalid commands.
  
### 4. RandomStimuli
* Purpose: Provides randomized inputs for robust testing.
* Key Features:
  * Randomly generates control signals, addresses, and data.
  * Ensures edge-case testing and corner-case validation.
  
### 5. GoldenModel
* Purpose: Serves as the reference implementation of SDRAM behavior.
* Key Features:
  * Simple memory model that mimics SDRAM functionality.
  * Used to verify the correctness of the DUT (Device Under Test).
  
### 6. Checker
* Purpose: Compares outputs of the DUT and Golden Model to detect mismatches.
* Key Features:
  * Highlights any discrepancies between expected and actual outputs.
  * Logs errors for debugging.
  
### 7. Scoreboard
Purpose: Tracks the performance and coverage of the testbench.
* Key Features:
   *  Counts the number of reads, writes, and errors.
   * Measures test coverage based on executed scenarios.
  
### 8. Testbench (sdram_top_tb.v)
* Purpose: Integrates all modules into a unified testing environment.
* Key Features:
  * Orchestrates stimuli, DUT, Golden Model, Checker, and Scoreboard.
  * Executes simulations and logs results for analysis.

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

## 👨‍💻 Author

**Behzad Jannati**
M.Sc. Student – Computer Architecture
University of Tehran

GitHub: [https://github.com/bhzadjnty7](https://github.com/bhzadjnty7)

Linkedin: [www.linkedin.com/in/behzadjannati](www.linkedin.com/in/behzadjannati)


## License

This project is intended for educational and academic purposes.


---

## ⭐️ Support

If you find this repository useful, consider giving it a ⭐️
