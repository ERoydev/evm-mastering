
# Introduction
### Resources i have used
#### Good blogpost [here](https://jamesbachini.com/proxy-contracts-tutorial/)
#### Used for the examples [this](https://rareskills.io/post/openzeppelin-foundry-upgrades)

## Intro: What is a Proxy?

**Proxy = Storage + Dispatcher**

- Holds all the state variables (storage layout)
- Is the true owner of all data across upgrades
- Dispatches function calls to the implementation contract using `delegatecall`

**Implementation(Logic Contract) = Behavior**

- Contains only functions and logic.
- Declares the same variable layout, but doesn't actually store anything - describes where proxy should r/w in storage using delegateCall
- Can be replaced(upgraded) safely, as long as the storage layout remains compatible

## 1. Upgradeable Contract has 2 parts:

- **Proxy itself** - which is the address that the user will call (act as the permanent address that users interact with)
- **Implementation contract** - which is the second contract that contains all the functionality for the dApp (contains business logic)

### Data flow: 
The proxy forwards calls to the implementation contract

### How it works:
- The proxy uses `delegatecall` to execute code from the implementation contract while maintaining its own storage
- This allows the implementation to be swapped out while keeping the same proxy address
- Users always interact with the proxy address, so they don't need to update their interfaces when upgrades happen

## 2. Key Benefits:

- Fix bugs without changing the contract address
- Add new features to existing contracts
- Maintain state/data across upgrades

## 3. Important Considerations:

- Storage layout must be carefully managed to avoid conflicts during upgrades
- There are different proxy patterns (Transparent, UUPS, Beacon, etc.)
- Upgrades typically require admin privileges and should be carefully governed



### The Common Proxy patterns:
>Note: For more patterns take a look inside `Patterns-2.md`

## 1. Transparent Proxy Pattern

### Structure:
There are two separate contracts:
- **Proxy contract** – Holds the storage and delegates calls to the implementation
- **ProxyAdmin Contract** - The contract links Proxy and Implementation
- **Implementation (logic) contract** – Contains the actual logic

### Key Idea:
Only admin can upgrade the implementation; normal users interact transparently.

### Behavior:
- Regular users' calls are forwarded to the implementation
- Admin calls are handled by the proxy itself to perform upgrades

### Pros:
- Simple and well-tested (used by OpenZeppelin's TransparentUpgradeableProxy)
- Clear separation of admin and user interactions

### Cons:
- Admin cannot interact with implementation logic via the proxy (to prevent accidental state conflicts)
- Slightly more gas because of the extra proxy logic for admin checks

## 2. UUPS Proxy Pattern

### Structure:
- The logic contract itself has the upgrade function (`upgradeTo`) and handles upgrades
- Proxy is minimal, mainly for storage and delegate calls

### Key Idea:
Only the logic contract is aware of how to upgrade itself; the proxy is "dumb."

### Behavior:
- All calls, including upgrades, go through the proxy and are delegated to the implementation

### Pros:
- Much cheaper in gas than transparent proxies because the proxy is minimal
- Upgrade logic is in the implementation contract, so easier to maintain

### Cons:
- Slightly more complex to implement safely
- Requires careful attention to storage layout during upgrades


# Notes:

### Upgradeable Contract Initializer Note

- When upgrading a contract (e.g., from Box to BoxV2), the `initialize` function in the new version **must have the same signature** as the original.
- **Do not add or change arguments** in the original `initialize` function for upgrade safety.
- To initialize new variables in the upgraded contract, add a new function (e.g., `initializeV2`) and mark it with `reinitializer(version)`.
- Example:
  ```solidity
  function initialize(uint256 initialValue) public initializer { ... }
  function initializeV2(uint256 anotherValue) public reinitializer(2) { ... }
  ```
- This ensures safe upgrades and proper initialization of new state variables.