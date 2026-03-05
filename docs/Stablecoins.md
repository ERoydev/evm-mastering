# Stablecoins
Blog: https://blog.chain.link/stablecoins-but-actually/
- Basically its buying power just has to stay relatively the same over time.

## Types of Stablecoins

1. Relative Stability (Pegged/Anchored or Floating)
- Stablecoin doesn't have to be `pegged` to another asset it could be `floating`

- floating stablecoins are using algorithms to do this. Basically mechanism to `burn` and `mint` to keep the buying power stable


# Stablecoins

**Blog:** [Stablecoins, But Actually](https://blog.chain.link/stablecoins-but-actually/)

> Basically, its buying power just has to stay relatively the same over time.

2. Stability Method (Governed or Algorithmic)
- Basically defines the mechanism that keeps the coin stable where if its Pegged or Floating. Usually refers to "who and what" is doing the minting and burning.

---

### 1. Relative Stability *(Pegged/Anchored or Floating)*

- A stablecoin doesn't have to be **pegged** to another asset; it could be **floating**.
- Floating stablecoins utilize algorithms to achieve this—essentially, mechanisms to **burn** and **mint** to maintain stable buying power.

**Summary:**
    - **Pegged stablecoins** have their value tied to another asset.
    - **Floating stablecoins** use mathematical models and other mechanisms to ensure a consistent buying power.

---

### 2. Stability Method *(Governed or Algorithmic)*

- This defines the mechanism that maintains the coin's stability, whether it is Pegged or Floating. It usually refers to "who and what" is responsible for minting and burning.
- **Algorithmic stablecoins** are governed by a set of autonomous code or algorithms that dictate the minting and burning process, with no human intervention.
- Typically, a coin can exist in a state between Pegged and Floating, utilizing both algorithms and a Decentralized Autonomous Organization (DAO) simultaneously.

**Summary:**
    - **Algorithmic stablecoins** rely on transparent mathematical equations or code to mint and burn tokens.
    - **Governed stablecoins** involve human oversight in the minting and burning processes.

---

### 3. Collateral Type *(Endogenous or Exogenous)*

- This refers to the assets backing our stablecoins and providing them with value.
- **Exogenous collateral** originates from outside the protocol.
- **Endogenous collateral** comes from within the protocol.

**Key Question:**
> If the stablecoin fails, does the underlying collateral also fail?
> - **YES** = Endogenous
> - **NO** = Exogenous

**Example:**
- If USDC fails, does the underlying collateral (the dollar) fail? **No** → Exogenous collateral
- If UST fails, does the underlying collateral (Luna/Terra) fail? **Yes** → Endogenous collateral (which can lead to significant losses)

**Summary:**
    - **Endogenous collateralized stablecoins** can be very risky, as their value may derive from unstable sources.
    - **Exogenous collateralized stablecoins** are typically over-collateralized.
3. Collateral Type (Endogenous or exogenous)
- The stuff backing our stablecoins and giving it value.

---

## Why do people want to create endogenous collateralized stablecoins?

- **Answer:** SCALE, or capital efficiency.
- With exogenous collateralized stablecoins, the only way to mint more is by onboarding additional collateral, which can require significant funds.
- Utilizing endogenous collateral allows for faster and more cost-effective scaling and growth.
- YES = Endogenous
- NO = Exogenous

---

## How it works: Example using DAI

1. Deposit ETH (collateral) to the smart contract with `DAI` algorithm code (e.g., $100 in ETH).
2. Based on the current ETH/USD price, it mints some amount of `DAI` (e.g., $50 in DAI).
3. You can always mint less DAI than the total value of the collateral (ETH) you have. This way, the system always has more collateral than minted DAI.
4. Every year, you are charged a `stability_fee` (probably 2%).
5. Because of this fee and collateralized ETH, this system is referred to as a **collateralized debt position** (CDP), since you technically owe DAI back to the protocol at some point.
6. All DAI in existence was minted from the Maker protocol and needs to be paid back at some point.
7. If you can't pay the stability fees or the price of ETH drops drastically (so your collateral is worth less than the DAI you minted), you can be **liquidated** (your collateral is taken).



---

## Who is actually paying to mint and keep these tokens in circulation?

- The basic idea: **Investors** use the minted tokens to buy more ETH. (Put ETH into protocol, mint RAI, then sell RAI for more ETH). This is called **leverage investing** or making leverage bets.
- So, "Why are stablecoins minted?" → Because **investors want to make leveraged bets**.
- The fun part: We need stablecoins for the 3 functions of money, but that's not why they are minted.
- The ratio of how many stablecoins are minted is based on how much investors think they can use that stablecoin to get more exposure to assets they really want.


## How it works example using DAI
1. I deposit ETH (collateral) to the smart contract that have `DAI` algorithm code for example ($100 in ETH).
2. And based of the current collateral to US dollar or ETH to US dollar price it mints me some amount of `DAI` ($50 in DAI).
3. I can always mint less DAI than the total value of the collateral or ETH that i have. This way the system always have more collateral than the minted DAI.
4. Every year i will be charged `stability_fee` probably 2%.
5. Because of this fee and collaterized ETH. This system is referred as `collateralized debt position`, since we technically own DAI back to the protocol at some point.
6. So all the DAI that is in existence, somebody minted from the maker protocol and needs to pay it back at some point.
7. If i cant pay the stability fees or the price of ETH drops drastically and the value of my collateral is less than the value of DAI i have minted, i can be `liquidated` (take my collateral).

## Who is the "idiot" that is paying to actually mint those tokens and often keep paying to keep them in circulation
- The basic idea is that `investor` use the minted tokens to buy more `eth`. (Put ETH into protocol, mint RAI, then sell RAI for more ETH). So called `leverage investing`, leverage bets.
- So basically "Why are stablecoins minted ?", Because "Investors want to make leveraged bets".
- So this is the the fun part, because we need stablecoins for the 3 functions of money, but that's not why they are minted.
- Basically the ratio if how much stablecoins are minted is based on how much the investors think that they can use that stablecoin to get more exposure to assets that they really want.