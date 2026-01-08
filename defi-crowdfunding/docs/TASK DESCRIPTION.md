# Week 14 Capstone Project  
## DeFi-Style Crowdfunding Protocol (Learning Version)

This capstone is a **learning-focused DeFi protocol** designed to practice smart contract architecture, upgradeability, multisig patterns, AMMs, and gasless transactions — without production-level complexity.

You will **only write contracts and tests** (no frontend required).

---

## 1. Learning Objectives

By completing this project, you should understand:

- Factory patterns and multi-campaign systems
- Crowdfunding state machines
- Multisig treasury mechanics
- ERC20-based reward incentives
- Basic AMM (constant product) math
- Upgradeable contracts (UUPS or Transparent Proxy)
- Gasless transactions using signed messages
- Writing integration-style tests in Foundry

---

## 2. High-Level Architecture

```
CrowdfundingFactory
│
├── Campaign (one per campaign, upgradeable)
│
├── Treasury (multisig)
│
├── RewardToken (ERC20)
│
└── SimpleAMM (toy AMM)
```

---

## 3. System Components & Requirements

### 3.1 CrowdfundingFactory (Multi-Campaign)

**Purpose:**  
Deploy and track multiple crowdfunding campaigns.

#### Requirements
- Deploy new campaign contracts
- Store all deployed campaign addresses
- Each campaign is initialized with:
  - Campaign creator
  - Funding goal
  - Deadline
  - Treasury address

#### Required Functions
```solidity
createCampaign(uint256 goal, uint256 duration) external returns (address);
getCampaigns() external view returns (address[]);
```

#### Concepts Learned
- Factory pattern
- Contract deployment
- Managing multiple instances

---

### 3.2 Campaign Contract (Core Crowdfunding Logic)

**Purpose:**  
Handle donations, track progress, and manage success/failure states.

#### Campaign States
```
Active → Successful → Funds Released
       → Failed → Refunds Enabled
```

#### Requirements
- Accept ETH donations
- Track donations per user
- Enforce campaign deadline
- Determine success or failure
- Allow treasury withdrawal only if successful
- Allow refunds only if failed

#### Required Functions
```solidity
donate(address donor, uint256 amount) external payable;
finalize() external;
claimRefund() external;
```

> NOTE: `donate()` will later be triggered via gasless meta-transactions.

#### Concepts Learned
- State machines
- Time-based logic
- ETH accounting
- Pull-based refunds

---

### 3.3 Treasury Contract (Simplified Multisig)

**Purpose:**  
Safely control campaign funds using multiple signers.

#### Requirements
- Fixed set of 3 signers
- 2-of-3 approvals required
- Treasury receives ETH from campaigns
- Executes ETH transfers after approval

#### Required Functions
```solidity
proposeTransaction(address to, uint256 value) external returns (uint256);
approveTransaction(uint256 txId) external;
executeTransaction(uint256 txId) external;
```

#### Simplifications
- ETH-only transfers
- No transaction cancellation
- Signers are fixed at deployment

#### Concepts Learned
- Multisig design
- Approval tracking
- Access control

---

### 3.4 RewardToken Contract (ERC20 Incentives)

**Purpose:**  
Reward donors with tokens for participating.

#### Requirements
- ERC20 token
- Minted when users donate
- Minting rate:
```
1 ETH donated → 100 RWD tokens
```

#### Required Functions
```solidity
mint(address to, uint256 amount) external;
```

#### Concepts Learned
- ERC20 implementation
- Token incentives
- Controlled minting

---

### 3.5 SimpleAMM Contract (Toy AMM)

**Purpose:**  
Allow swapping between ETH and RewardToken using a constant product AMM.

#### Requirements
- Single ETH ↔ RewardToken pool
- Constant product formula:
```
x * y = k
```

#### Required Functions
```solidity
addLiquidity(uint256 tokenAmount) external payable;
swapEthForTokens() external payable;
swapTokensForEth(uint256 tokenAmount) external;
```

#### Simplifications
- No LP tokens
- No swap fees
- Single pool only

#### Concepts Learned
- AMM mechanics
- Reserves and pricing
- Slippage basics

---

### 3.6 Upgradeability

**Purpose:**  
Practice upgrading smart contracts safely.

#### Requirements
- Campaign contract must be upgradeable
- Use either:
  - UUPS, or
  - Transparent Proxy
- Create `CampaignV2` with:
  - One new storage variable
  - One new function
- Write a test demonstrating a successful upgrade

#### Concepts Learned
- Proxy patterns
- Storage layout safety
- Upgrade testing

---

### 3.7 Gasless Donations (Meta-Transactions)

**Purpose:**  
Allow users to donate without paying gas.

#### Requirements
- Users sign donation data off-chain
- A relayer submits the transaction
- Contract verifies the signature
- Replay protection using nonces

#### Data Structure
```solidity
struct DonationRequest {
    address donor;
    uint256 amount;
    uint256 deadline;
    uint256 nonce;
}
```

#### Required Function
```solidity
donateWithSignature(
    DonationRequest calldata req,
    bytes calldata signature
) external payable;
```

#### Simplifications
- No EIP-2771 forwarder
- No trusted relayer system
- Manual `ecrecover` verification

#### Concepts Learned
- ECDSA signatures
- Meta-transactions
- Replay protection

---

## 4. Testing Requirements (Foundry)

No frontend is required.  
All interactions are validated through tests.

### Minimum Tests
- Deploy factory and create multiple campaigns
- Donate ETH to a campaign
- Failed campaign → refunds enabled
- Successful campaign → treasury withdrawal
- Multisig approval and execution flow
- Reward token minting
- AMM swaps and reserve changes
- Campaign contract upgrade
- Gasless donation using a signed message

---

## 5. Suggested Folder Structure

```
src/
├── factory/
│   └── CrowdfundingFactory.sol
│
├── campaign/
│   ├── Campaign.sol
│   └── CampaignV2.sol
│
├── treasury/
│   └── Treasury.sol
│
├── token/
│   └── RewardToken.sol
│
├── amm/
│   └── SimpleAMM.sol
│
└── libraries/
    └── ECDSA.sol (optional)

test/
├── Factory.t.sol
├── Campaign.t.sol
├── Treasury.t.sol
├── AMM.t.sol
├── Upgrade.t.sol
└── GaslessDonation.t.sol
```

---

## 6. Definition of Done

This capstone is complete when:

- All contracts compile successfully
- All tests pass
- You can explain:
  - Why a factory is used
  - How campaign states work
  - How multisig approvals protect funds
  - How AMM pricing changes with swaps
  - Why upgradeability is risky
  - How gasless transactions prevent replay attacks

---

## 7. Stretch Goals (Optional)

- Add protocol fees
- Add ERC20 donations
- Add campaign cancellation
- Add events for all state changes
- Replace toy AMM with Uniswap-style interface

---

**End of Capstone Specification**
