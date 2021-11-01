# Artifact for Paper Fast and Reliable Formal Verification of Smart Contracts with the Move Prover

Paper submission number: 99
Artifaction submission number: 100

## Directory Layout

```text
artifact/
│
├── bin/                # pre-built static binaries for the Move Prover (MVP)
│    ├─ move-prover-v1  # the prior release of MVP (September 2020)
│    └─ move-prover-v2  # the latest release of MVP (October 2021)
│
├── dep/                # dependencies of MVP
│    ├─ z3              # the Z3 solver executable (version 4.8.9) 
│    ├─ cvc4            # the CVC4 solver executable (version 1.9-prerelease)
│    └─ dotnet/         # the .NET framework distribution (version 5.0.208)
│       ├─ ...          # standard .NET framework library files
│       └─ tools/boogie # the Boogie executable (version 3.9.0.0)
│
├── data/               # Move code samples for evaluation
│   ├─ diem-v1          # the Diem framework code used to evaluate the prior release of MVP
│   └─ diem-v2          # the Diem framework code used to evaluate the latest release of MVP
│
├── doc/
│   ├─ move-lang        # documentation about the Move programming language
│   └─ move-prover      # documentation about the Move specification language and the MVP
│
├── mvp-v1              # a Bash wrapper to bin/move-prover-v1 with environment setup
├── mvp-v2              # a Bash wrapper to bin/move-prover-v2 with environment setup
├── mvp                 # a symbolic link to the most recent release of MVP (i.e., mvp-v2)
│
├── verify-diem-v1      # an utility driver for verifying Move files in data/diem-v1 
├── verify-diem-v2      # an utility driver for verifying Move files in data/diem-v2 
│
├── License.txt         # the License under which this artifact is published
└── Readme.txt          # this file
```
