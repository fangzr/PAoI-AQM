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

## System Model

**Fig. 1. Sleep-scheduling aided underwater information collection**  
![System Model](https://raw.githubusercontent.com/fangzr/PAoI-AQM/refs/heads/main/system-model.png)  

Without loss of generality, we consider a simple underwater environmental monitoring system consisting of \( N \) IoUT nodes and one sink node, as shown in Fig. 1. The IoUT nodes send the latest packets to the sink node using acoustic communication units. Packets are generated and stored at the IoUT nodes' queues in a FIFO manner. Each packet contains underwater environmental information and a timestamp indicating its generation time. The generation of each packet follows a Poisson process with arrival rate \( \lambda \), and the service time is exponentially distributed with rate \( \mu \). To reduce AoI and save energy, lossy packets are discarded without retransmission. Given the limited battery life, continuous transmission is infeasible. Thus, the IoUT nodes switch between active and idle modes dynamically. When a node's queue becomes empty, it enters idle mode—turning off the acoustic transmitter (except during AQM procedures) while continuing to collect data. If the queue remains empty at the end of an idle period (with duration exponentially distributed with parameter \( \theta \)), the node re-enters idle mode.

---

## Markov Chain Model

**Fig. 2. The two-dimensional Markov chain of the AQM policy**  
![AQM Policy Model](https://raw.githubusercontent.com/fangzr/PAoI-AQM/refs/heads/main/AQM-policy.png)  

In this section, we derive the average PAoI for the multiple vacation queue under the AQM policy. The system is modeled as a continuous-time Markov chain with state \( \{ N(t), J(t) \} \), where the state space is  
\[
\varTheta = \{ (0,0) \} \cup \{ (k,j) : k \geq 1,\; j=0,1 \}.
\]
Here, \( N(t) \) denotes the number of packets in the system and \( J(t) \) indicates the mode (with \( J(t)=1 \) for active and \( J(t)=0 \) for idle). Let \( \boldsymbol{Q}_A \) be the transition rate matrix whose element \( q_{(i,j),(k,z)} \) represents the transition rate from state \( (i,j) \) to \( (k,z) \). In Fig. 2, the two-dimensional Markov chain is illustrated. Let \( f_{i,j} \) denote the transition rate caused by the AQM during idle mode: when \( i \geq 1, \, j=0 \), \( f_{i,j} = \gamma \alpha^{i+1} \); when \( i > j > 0 \), \( f_{i,j} = \gamma \alpha^{i-j}\beta \); otherwise, \( f_{i,j} = 0 \). Thus, the transition rate matrix \( \boldsymbol{Q}_A \) is given by

\[
\boldsymbol{Q}_A=\begin{pmatrix}
\boldsymbol{B}_0 & \boldsymbol{C}_0 & \,& \,& \,& \, \\
\boldsymbol{B}_1 & \boldsymbol{A}_1 & \boldsymbol{A}_0 & \,& \,& \, \\
\boldsymbol{B}_2 & \boldsymbol{A}_2 & \boldsymbol{A}_1 & \boldsymbol{A}_0 & \,& \, \\
\boldsymbol{B}_2 & \boldsymbol{A}_3 & \boldsymbol{A}_2 & \boldsymbol{A}_1 & \boldsymbol{A}_0 & \, \\
\vdots & \vdots & \vdots & \vdots & \vdots & \ddots \\
\end{pmatrix},
\]
  
where \( \boldsymbol{A}_0 = \operatorname{diag}(\lambda,\lambda) \), \( \boldsymbol{C}_0 = (0,\lambda) \), \( \boldsymbol{B}_0 = (\mu,\,\gamma \alpha)^{\mathsf{T}} \), and for \( i \geq 1 \), \( \boldsymbol{B}_i = (0,\,\gamma \alpha^{i+1})^{\mathsf{T}} \).

---

## Performance Evaluation

**Fig. 3. The average PAoI under three policies over different packet generation rates \( \lambda L_s \).**  
![Average PAoI](https://raw.githubusercontent.com/fangzr/PAoI-AQM/refs/heads/main/The-average-PAoI.png)  

Figures 3(a) and 3(b) depict the average PAoI of the system as a function of the arrival rate \( \lambda \) for different idle mode parameters \( \theta \), AQM rate \( \gamma \), and discard probability \( \alpha \).

Another result is shown below:

![Alternate Average PAoI](https://raw.githubusercontent.com/fangzr/PAoI-AQM/refs/heads/main/The-average-PAoI-2.png)

**Fig. 4.** The average PAoI under AQM policy and non-AQM policy over different packet generation rates \( \lambda L_s \) and idle mode parameter \( \theta \).  
Fig. 4 illustrates the average PAoI with different policies versus the idle mode parameter \( \theta \) and the packet generation rate. In this experiment, we set \( \gamma=10 \) and \( \alpha=0.8 \).

---

## File Structure

- **TVT_Final_AoI_multiple_vacation.pdf**  
  The published paper.

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

- **Number of Packets (N):** The simulation generates \( N \) packets.
- **Interarrival and Service Times:**  
  Each packet’s interarrival time and service time are drawn from exponential distributions, capturing the randomness found in real-world scenarios.

### 2. Queue Processing with Two Modes

- **Packet Pointer (`pr`):**  
  The pointer is initialized to the first packet in the queue and advances as packets are processed.

- **Sleep Mode (Idle):**  
  If the service time of the current packet is **less than** the next packet’s interarrival interval:
  - The current packet is served.
  - The sink enters a vacation period where the system time is updated by adding the service time and the vacation duration (determined by the next packet’s arrival time).
  - During this vacation, the AQM algorithm is executed at random instants. The algorithm determines how many packets to discard based on a geometric distribution.
  - Once the vacation ends, any remaining packets are processed in active mode, and the pointer resets.

- **Work Mode (Active):**  
  If the service time is **greater than** the next packet’s interarrival interval:
  - The current packet’s departure time is computed.
  - The pointer moves to the next packet, which immediately begins service.
  - The simulation continuously updates the system time and processes packets in this active mode.

### 3. AQM Mechanism

- **Active Queue Management (AQM):**  
  During the idle (sleep) period, AQM is triggered according to a Poisson process. For each AQM event:
  - A geometric random variable determines the number of packets to discard.
  - The event time and the affected packets are logged.
  - This mechanism reduces outdated information in the queue, thus lowering the overall PAoI.

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

4. **Modify parameters** as needed by editing `CreateModel.m` or within the experiments section in `Main.m`.

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

These parameters can be adjusted in `CreateModel.m` to fit your experimental needs.

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

