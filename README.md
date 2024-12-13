# README: Quantum Entanglement and Spacetime Emergence Simulations

## Project Overview
This repository supports the research project investigating the relationship between quantum entanglement and spacetime emergence within the AdS/CFT framework. The project uses MATLAB to simulate Clifford circuits and analyze how measurement interactions affect entanglement entropy through the Ryu-Takayanagi formula. The main focus is to explore collapse dynamics in entangled quantum systems and their implications for spacetime geometry.

### Key Concepts
- **Quantum Entanglement**: Investigated through Renyi entropies to analyze the quantum correlations between subsystems.
- **AdS/CFT Framework**: Provides the theoretical background for relating entanglement entropy to minimal surfaces in AdS spacetime.
- **Measurement-Induced Phase Transitions (MIPTs)**: Explored by introducing measurements to quantum circuits and analyzing their impact on entanglement dynamics.

---

## Files Overview

### Core MATLAB Files

#### 1. **`runsingleprogram.m`**
- **Purpose**: Executes a single quantum circuit program.
- **Key Details**:
  - **Input**: Name of the circuit program (e.g., `entropycircuit`) and the cycle interval for data printing.
  - **Process**: Creates a timestamped directory for storing simulation data and invokes the `main_program.exe` executable with the specified `.chp` circuit file.
  - **Output**: Simulation results stored in the created directory.
- **Relevance**: Acts as the entry point for running quantum circuit simulations and ensures proper data organization.

#### 2. **`loadstatefromfile.m`**
- **Purpose**: Loads and decodes quantum state data from simulation output files.
- **Key Details**:
  - **Input**: Binary file containing the quantum state data.
  - **Process**: Extracts stabilizer and destabilizer matrices, along with auxiliary data (e.g., row vectors), using byte-level parsing.
  - **Output**: Two matrices representing the quantum state and a row vector.
- **Relevance**: Converts low-level simulation output into a usable format for subsequent entropy analysis.

#### 3. **`calcentropy.m`**
- **Purpose**: Calculates the Renyi entropy for a specified subregion of the quantum system.
- **Key Details**:
  - **Input**: Quantum state matrix, region of interest, and type of stabilizers (default is "stab").
  - **Process**: Constructs subregion matrices for stabilizers and destabilizers, computes the rank over GF(2), and subtracts the region size.
  - **Output**: A structure containing the computed entropy and the region analyzed.
- **Relevance**: Central to evaluating entanglement properties in different regions of the quantum system.

#### 4. **`gfrank.m`**
- **Purpose**: Computes the rank of binary matrices over Galois fields, used in entropy calculations.
- **Key Details**:
  - **Input**: Binary matrix and prime field (default is GF(2)).
  - **Process**: Implements Gaussian elimination to determine the rank while ensuring numerical stability in GF arithmetic.
  - **Output**: The rank of the matrix.
- **Relevance**: Provides the mathematical backbone for calculating entanglement entropy.

#### 5. **`measurementscode.m`**
- **Purpose**: Analyzes the impact of probabilistic measurements on entanglement entropy.
- **Key Details**:
  - **Input**: Number of qubits, circuit depth (layers), and measurement probabilities ranging from 0 to 1.
  - **Process**:
    - Generates random quantum circuits.
    - Introduces measurements with specified probabilities.
    - Computes entropy for a specified subregion after each measurement.
  - **Output**: Plots entropy as a function of measurement probability, comparing it to the theoretical maximum entropy.
- **Relevance**: Explores how measurements induce phase transitions in entanglement, testing hypotheses about quantum collapse.

#### 6. **`codenew.m`**
- **Purpose**: Determines the circuit depth required to achieve maximum entanglement entropy.
- **Key Details**:
  - **Input**: Number of qubits and an upper limit on the number of layers.
  - **Process**:
    - Iteratively adds layers to a random quantum circuit.
    - Tracks entropy for a half-chain region and compares it to the theoretical maximum (Page curve).
  - **Output**: Plots entropy as a function of circuit depth and indicates when maximum entropy is reached.
- **Relevance**: Validates theoretical predictions about maximal entanglement in random circuits.

---

### Circuit Files

#### 7. **`hex.chp`**
- **Purpose**: Predefined Clifford circuit file containing a sequence of quantum gates.
- **Key Details**:
  - Includes Hadamard (`h`), CNOT (`c`), and measurement (`m`) operations.
  - Represents a static test case for entropy calculations.
- **Relevance**: Serves as a benchmark for verifying simulation accuracy and consistency.

#### 8. **`entropycircuit.chp`**
- **Purpose**: Dynamically generated Clifford circuit used in simulations.
- **Key Details**:
  - Created by MATLAB scripts based on user-defined parameters (e.g., qubit count, layer count).
  - Includes random single- and two-qubit gates with optional measurements.
- **Relevance**: Enables flexible experimentation with different circuit configurations.

---

## How to Use

### 1. Run a Quantum Circuit Simulation
- **Command**: Use `runsingleprogram.m` to execute a predefined `.chp` program.
  ```matlab
  datadir = runsingleprogram('entropycircuit', 1);
  ```
- **Output**: Simulation data stored in a timestamped directory.

### 2. Load and Analyze Quantum State
- **Command**: Use `loadstatefromfile.m` to load simulation results:
  ```matlab
  [qstate, rdata] = loadstatefromfile('path_to_binary_file');
  ```

### 3. Calculate Entropy
- **Command**: Compute entropy for a region:
  ```matlab
  entropy = calcentropy(qstate, 1:ceil(num_qubits / 2)).entropy;
  ```
- **Output**: Renyi entropy for the specified region.

### 4. Analyze Measurement Effects
- **Command**: Use `measurementscode.m` to analyze entropy under varying measurement probabilities:
  ```matlab
  analyze_entropy_with_measurements(num_qubits, num_layers);
  ```
- **Output**: A plot showing entropy vs. measurement probability, compared to the theoretical maximum.

### 5. Determine Layers for Maximum Entropy
- **Command**: Use `codenew.m` to find the required circuit depth:
  ```matlab
  find_layers_for_max_entropy(num_qubits);
  ```
- **Output**: A plot of entropy vs. circuit depth, indicating when maximum entropy is achieved.

---

## Visualization
- **Entropy vs. Measurement Probability**: Examines how probabilistic measurements influence entanglement dynamics, revealing phase transitions.
- **Entropy vs. Circuit Depth**: Demonstrates the buildup of maximal entanglement with increasing circuit layers, validating theoretical predictions.

---

## Notes and Future Directions
- Ensure all `.chp` programs are properly formatted and stored in the `programs` directory.
- Modify `measurementscode.m` and `codenew.m` to explore alternative boundary conditions or circuit configurations.
- Experiment with different subregion sizes and boundary conditions to test the universality of results.
- Integrate findings with the Ryu-Takayanagi prescription to relate entanglement entropy to minimal surface areas in AdS spaces.

