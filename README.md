
# Damn Vulnerable DeFi 

A hands-on smart contract security research portfolio documenting my journey through the [Damn Vulnerable DeFi](https://github.com/theredguild/damn-vulnerable-defi) challenges.

This repository contains my independent vulnerability analysis, exploit implementations, Foundry proof-of-concept tests, and technical explanations of the attack paths.

The goal is not just to solve challenges, but to understand **why vulnerabilities exist, how they can be exploited, and how to prove their impact.**

## Research Methodology

For each challenge, I follow a structured security research process:

1. **Protocol Understanding** — Study the contracts, architecture, state variables, and external interactions.
2. **Code Analysis** — Identify security-sensitive functions, trust assumptions, and potential attack surfaces.
3. **Vulnerability Investigation** — Trace execution paths and understand the root cause.
4. **Exploit Development** — Develop an attack strategy and implement it using Solidity and Foundry.
5. **Proof of Concept** — Write reproducible tests demonstrating the vulnerability and its impact.
6. **Technical Documentation** — Document vulnerable code, attack flow, root cause, and lessons learned.

## Challenges

| Challenge | Focus | Status |
|---|---|---|
| Naive Receiver | Flash loans, trusted forwarders, EIP-712, multicall, delegatecall | PoC completed |

*Additional challenges will be documented as I investigate and solve them.*

## Repository Structure

Each challenge has its own directory containing:

- `README.md` — Challenge overview and summary.
- `vulnerable-code.md` — Relevant original source snippets and line references.
- `technical-analysis.md` — Root cause and detailed vulnerability analysis.
- `exploit-poc.t.sol` — My Foundry proof-of-concept implementation.
- `visualization/` — Interactive attack-flow and code walkthrough.

## Tools & Technologies

- Solidity
- Foundry
- Forge Testing
- EVM execution and debugging
- Git and GitHub
- Smart Contract Security Analysis

## Attribution

The original challenge contracts and challenge framework belong to their respective authors and are sourced from [Damn Vulnerable DeFi](https://github.com/theredguild/damn-vulnerable-defi).

My original contributions in this repository are the independent analysis, exploit PoCs, explanations, and visualizations, unless explicitly attributed otherwise.

## Disclaimer

This repository is intended strictly for educational and security research purposes.

All exploits are demonstrated in local testing environments. Do not use these techniques against systems without explicit authorization.

---

**Learning by breaking, understanding, and securing smart contracts.**