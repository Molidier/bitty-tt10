# Bitty System: RTL Design and Verification Framework

This project implements a custom 16-bit processing system, including hardware modules for program counter (PC), instruction fetch, branch logic, UART communication, and integration with the **BittyEmulator** for co-simulation. The provided system allows robust testing of a Verilog-based design using a Python-based cocotb testbench. The testbench orchestrates data transfer via UART, interacts with shared memory, and verifies execution against the emulator.

## System Overview

### Core Components

1. **Program Counter (PC)**:
   - Handles sequential and branch-based instruction execution.
   - Interfaces directly with the branch logic for control flow changes.

2. **Instruction Fetch Unit**:
   - Reads and decodes instructions from memory.
   - Supplies data to the rest of the system.

3. **Branch Logic**:
   - Evaluates branch conditions and modifies the PC as needed.

4. **UART Module**:
   - Supports data exchange between the testbench and the DUT.
   - Operates with customizable baud rates and clock frequencies.

5. **Bitty Emulator**:
   - Acts as a functional reference model.
   - Validates the outputs and internal states of the hardware implementation.

### Memory Map
- **Shared Memory**:
  - Synchronizes data between the testbench, the hardware design (DUT), and the emulator.
  - Supports up to 256 entries.
- **Instruction Set**:
  - Defined in `instructions_for_em.txt`, loaded by the testbench for execution.

---

## Testbench Overview

### Key Features
The cocotb-based testbench facilitates end-to-end testing of the system by:
1. Generating UART signals to simulate input.
2. Capturing and decoding UART transmissions from the DUT.
3. Validating DUT outputs against expected results from the emulator.
4. Logging discrepancies between DUT and emulator states.

### Structure
1. **Initialization**:
   - Configures clock and UART parameters.
   - Applies and releases the reset signal.

2. **UART Communication**:
   - Implements UART data transmission (`send_uart_data`) and reception (`transmit_from_tx`).
   - Waits for completion flags using `wait_for_rx_done`.

3. **Flag Handling**:
   - Processes operation flags:
     - `0x01` (Load): Reads data from memory.
     - `0x02` (Store): Writes data to memory.
     - `0x03` (Instruction): Fetches and executes instructions.

4. **Verification**:
   - Compares the DUT and emulator outputs for each instruction.
   - Captures any mismatches and logs results to `uart_emulator_log.txt`.

---

## How to Use

### Setup
1. **Prerequisites**:
   - Install Python and cocotb.
   - Ensure Verilog simulation tools (e.g., Verilator, ModelSim) are installed.

2. **Input Files**:
   - Place the instruction file (`instructions_for_em.txt`) in the working directory.
   - Modify the file as needed to test specific scenarios.

3. **Shared Libraries**:
   - Ensure `BittyEmulator.py` and `shared_memory.py` are in the project directory.

### Running the Test
1. Execute the cocotb testbench:
   ```bash
   make SIM=verilator
   ```
   Replace `verilator` with your preferred simulator.

2. Observe the test results in the terminal and logs:
   - Successes and failures are detailed in `uart_emulator_log.txt`.

---

## External Hardware

This system does not require external hardware. UART communication is emulated within the testbench.

---

## Files Overview

### Verilog Files
- **`<module_name>.v`**: Contains the RTL design files for the system.
- **`tb_<module_name>.v`**: Top-level Verilog testbench wrapper.

### Python Files
- **`test_bitty.py`**: The cocotb testbench described above.
- **`BittyEmulator.py`**: Emulator for reference model validation.
- **`shared_memory.py`**: Utility for creating shared memory structures.

---

## Limitations and Future Work
1. **Hardware Expansion**:
   - Current implementation is limited to basic arithmetic and control operations.
   - Future iterations could incorporate advanced features like pipelining or caching.

2. **Error Handling**:
   - Expand error reporting for unresolved signals during simulation.

3. **Scalability**:
   - Extend memory and instruction sets for larger programs.

--- 

This project demonstrates a robust framework for RTL verification, combining software co-simulation with hardware modeling for high-fidelity testing and validation.
