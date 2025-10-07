# Upgradeable Contract Initializer Note

- When upgrading a contract (e.g., from Box to BoxV2), the `initialize` function in the new version **must have the same signature** as the original.
- **Do not add or change arguments** in the original `initialize` function for upgrade safety.
- To initialize new variables in the upgraded contract, add a new function (e.g., `initializeV2`) and mark it with `reinitializer(version)`.
- Example:
  ```solidity
  function initialize(uint256 initialValue) public initializer { ... }
  function initializeV2(uint256 anotherValue) public reinitializer(2) { ... }
  ```
- This ensures safe upgrades and proper initialization of new state variables.