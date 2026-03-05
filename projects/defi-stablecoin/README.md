# Stablecoin Plan, Requirements

Here the idea is to practice Stablecoins as defined [here](https://github.com/ERoydev/evm-mastering/blob/main/docs/Stablecoins.md).
This project is based on [this](https://updraft.cyfrin.io/courses/advanced-foundry/develop-defi-protocol/defi-deposit-collateral) course.

1. Relative Stability: Anchored or Pegged -> $1.00
    1. Chainlink Price feed.
    2. Set a function to exchange ETH & BTC -> $$$
2. Stability Mechanism (Minting): Algorithmic (Decentralized)
    1. People can only mint the stablecoin with enough collateral (coded in our protocol)
3. Collateral Type: Exogenous (Crypto)
    1. wETH (ERC20 version of ETH)
    2. wBTC (ERC20 version of BTC)

