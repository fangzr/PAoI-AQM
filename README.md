# Average Peak Age of Information (PAoI) Simulation with Sleep-Scheduling and AQM

This repository contains MATLAB code that accompanies the paper:

**Average Peak Age of Information in Underwater Information Collection With Sleep-Scheduling**  
Fang, Zhengru; Wang, Jingjing; Jiang, Chunxiao; Wang, Xijun; Ren, Yong  
*IEEE Transactions on Vehicular Technology*, May 2022  
DOI: [10.1109/TVT.2022.3176819](https://doi.org/10.1109/TVT.2022.3176819)

---

## Overview

This project implements a simulation framework to evaluate the Peak Age of Information (PAoI) in underwater wireless sensor networks (UWSNs) using a multiple vacation queueing model. The code simulates both scenarios—with and without an Active Queue Management (AQM) policy.

In the simulation, data packets are generated with interarrival and service times drawn from exponential distributions. A packet pointer (`pr`) tracks the current packet in the queue. The system operates in two modes:

- **Sleep Mode (Idle):**  
  When the service time of the current packet is less than the next packet’s arrival interval, the first packet is served, and the sink enters a vacation period. During this period, the AQM algorithm is triggered at random intervals to process (i.e., discard or compress) packets that have been waiting too long. After the vacation ends, any remaining packets in the queue are processed, and the pointer resets.

- **Work Mode (Active):**  
  When the service time exceeds the interarrival interval, the system continuously processes packets. Each packet’s departure time is computed based on the current system time plus its service period, and the pointer advances to the next packet.

The AQM mechanism, which is only active during sleep mode, uses a Poisson process to determine when to run and employs a geometric distribution to decide how many packets to discard. This helps reduce the PAoI and manage network congestion by discarding outdated packets.

---

## File Structure

- **TVT_Final_AoI_multiple_vacation.pdf**  
  The published paper providing the theoretical background and analytical derivations.

- **Multi_vacation.m**  
  MATLAB script that simulates the multiple vacation queueing model with AQM.  

- **Multi_vacation_NA.m**  
  MATLAB script for simulating the non-AQM scenario.  

- **Close_Form_AQM.m**  
  Function that computes the closed-form analytical solution for the system with AQM.  
  
- **Close_Form_NA.m**  
  Function that computes the closed-form analytical solution for the system without AQM.  

- **CreateModel.m**  
  Initializes experimental parameters and creates the simulation model.  

- **Main.m**  
  The main script that runs various simulation experiments, compares simulation results with closed-form solutions, and saves the results.  

---

## How It Works

### 1. Packet Generation and Initialization

- **Number of Packets (N):** The simulation generates N packets.
- **Interarrival and Service Times:**  
  Each packet’s arrival interval and service time are generated using exponential distributions. These random values mimic real-world variability.

### 2. Queue Processing with Two Modes

- **Packet Pointer (`pr`):**  
  Initialized to the first packet in the queue, it is used to step through the packets during simulation.

- **Sleep Mode (Idle):**  
  If the service time of the current packet is **less than** the next packet’s interarrival interval:
  - The first packet is served.
  - The sink enters a vacation period. The system time is updated by adding the service time and the vacation duration (determined by the arrival time of the next packet).
  - During the vacation, the AQM algorithm runs at randomly generated instants, determining:
    - The number of AQM runs during the vacation.
    - Which packets (if any) are discarded.
  - Once the vacation ends, remaining packets are processed in work mode, and the pointer is reset to the start of the queue.

- **Work Mode (Active):**  
  If the service time is **greater than** the next packet’s arrival interval:
  - The departure time for the current packet is computed.
  - The packet pointer is moved to the next packet, which starts its service immediately.
  - The simulation loops by continuously updating the system time and processing packets.

### 3. AQM Mechanism

- **Active Queue Management (AQM):**  
  During the sleep period, AQM is triggered based on a Poisson process with a predefined rate. For each AQM event:
  - A geometric random variable determines the number of packets to discard.
  - The system logs the AQM event time and the packets affected.
  - This mechanism helps in reducing outdated information in the queue, thereby lowering the overall PAoI.

---

## Requirements

- MATLAB (R2020a or later recommended)
- No additional toolboxes are necessary

---

## How to Run

1. **Clone the repository:**

   ```bash
   git clone https://github.com/fangzr/PAoI-AQM.git
   ```

2. **Open MATLAB** and navigate to the project folder.

3. **Run the Main script:**

   ```matlab
   Main
   ```

   This script will:
   - Initialize parameters via `CreateModel.m`
   - Execute various simulation experiments (e.g., Lab_test_1, Lab_test_theta, Lab_test_gamma, etc.)
   - Compare simulation results with analytical closed-form solutions (using `Close_Form_AQM.m` and `Close_Form_NA.m`)
   - Save simulation data to MAT files (modify file paths if necessary)

4. **Modify parameters** as needed by editing `CreateModel.m` or within the `Main.m` experiments section.

---

## Parameter Settings

Key simulation parameters include:
- **Lambda:** Packet arrival rate.
- **mu:** Service rate.
- **theta:** Inverse of the mean vacation time.
- **gamma:** AQM occurrence rate.
- **alpha:** AQM packet discard probability.
- **beta:** Complement of alpha (probability of retaining a packet).
- **Packet_Sum:** Total number of packets to simulate.

You can adjust these parameters in `CreateModel.m` to suit your experiment.

---

## Citation

If you use this code in your research, please cite the following paper:

```
@ARTICLE{9779912,
  author={Fang, Zhengru and Wang, Jingjing and Jiang, Chunxiao and Wang, Xijun and Ren, Yong},
  journal={IEEE Transactions on Vehicular Technology},
  title={Average Peak Age of Information in Underwater Information Collection With Sleep-Scheduling},
  year={May 2022},
  volume={71},
  number={9},
  pages={10132-10136},
  doi={10.1109/TVT.2022.3176819}
}
```
