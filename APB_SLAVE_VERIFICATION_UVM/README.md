⚡ **APB Slave Verification using SystemVerilog & UVM**

📌 **Project Overview**
This project focuses on verifying an **APB Slave** using **SystemVerilog and UVM**. The verification environment validates APB read/write transactions and DUT behavior through multiple test scenarios.

🎯 **Key Features**
✅ UVM-based verification environment
✅ APB read and write transaction verification
✅ Multiple sequences and test scenarios
✅ Functional coverage
✅ APB protocol assertions
✅ Transaction monitoring and checking
✅ Achieved **100% functional coverage** for one sequence
✅ Achieved **70% functional coverage** for another sequence
✅ All tests passed with **no errors or warnings**
✅ Waveform analysis using QuestaSim

📂 **Files in this Project**

`transaction.sv` → Defines APB transaction/sequence item
`sequence.sv` → Generates APB stimulus
`sequencer.sv` → Sends transactions from sequence to driver
`driver.sv` → Drives APB signals to the DUT
`monitor.sv` → Monitors APB transactions
`agent.sv` → Contains sequencer, driver and monitor
`environment.sv` → UVM environment and component connections
`scoreboard.sv` → Checks expected vs actual results
`coverage.sv` → Functional coverage
`interface.sv` → APB interface and signals
`package.sv` → Contains UVM classes and package definitions
`testbench.sv` → Top-level testbench and DUT instantiation
`tests.sv` → Contains different UVM test scenarios

🛠️ **Tools & Methodology**
**Language:** SystemVerilog
**Methodology:** UVM
**Simulator:** QuestaSim
**Protocol:** AMBA APB
**Verification:** Functional Coverage + Assertions + UVM Testbench
