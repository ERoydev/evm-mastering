# EVM Mastering

This repository is my personal playground for learning and mastering the Ethereum Virtual Machine (EVM), Solidity, and common smart contract patterns. It contains small experiments, practice projects, notes, and reference implementations.

## Structure

- `defi-crowdfunding/` – A Foundry-based DeFi crowdfunding project, with contracts, tests, and deployment scripts.
- `Evm Storage/` – Examples and notes focused on EVM storage layout, arrays, mappings, structs, and related concepts.
- `Solidity-Onboarding/` – Introductory and fundamental Solidity exercises and small projects.
- `Solidity_0.8/` – Standalone Solidity contracts and concept demos for Solidity 0.8 (functions, errors, modifiers, events, etc.).
- `Upgradeable Proxies/` – Experiments with upgradeable proxy patterns and upgrade flows.
- `COMMON_ISSUES/` – Notes and fixes for common issues encountered while working with this repo and its tools (e.g. Git submodule problems).

## Tooling

Most projects here use **Foundry**:

- Build & test (from each project folder):
  ```bash
  forge build
  forge test
  ```

- Install dependencies (from a Foundry project folder):
  ```bash
  forge install
  ```

## Purpose

This repo is not a polished product, but a living notebook of:

- Hands-on practice with Solidity and the EVM
- Experimentation with DeFi and upgradeable patterns
- Personal notes and reference code I can reuse in future projects

Feel free to browse individual folders to see how particular topics are implemented and tested.