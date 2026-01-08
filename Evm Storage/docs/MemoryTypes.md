# References

- [Alchemy: Smart Contract Storage Layout](https://www.alchemy.com/docs/smart-contract-storage-layout)
- [Medium: Ethereum Virtual Machine Storage Layout](https://steveng.medium.com/ethereum-virtual-machine-storage-layout-beb9a72a07e9)

# Solidity Memory Types

Solidity uses three main memory types:

---

## 1. Memory

- Used to hold temporary values that only exist within the scope of a function call. (Mutable within the function call).

---

## 2. Calldata

- Similar to `memory` for holding temporary values in the function scope, but it is **immutable** and cheaper in gas cost because it skips copying values into memory (`sload` and `sstore`) and reads directly from call data.

```solidity
function limit(calldata string issue) {
    // ...
}
```

## 3. Storage 

**Key (slot index) → Value (32 bytes)**

- Each smart contract maintains its own storage. This persistent storage is basically a key-value mapping with 2 ²⁵⁶ keys mapped to each value of 32 bytes.

- Each key (slot number) in the contract’s storage maps to a single slot that holds up to 32 bytes of value.
  

- Smart contract can read or write from any particular slot. These data will be permanently stored on blockchain and retrievable on subsequent operation.

## 3.1 All State Variables are stored in `Storage`
- One slot can store 32 bytes of value and Solidity will try to pack variables efficiently.
- So in the example some values are packed in the same slot because they are 1 byte and can be packed up to 32 bytes in this slot.

```solidity
contract HelloWorld {
    uint256 apple;                         // in slot 0
    address pear;                          // in slot 1
    mapping(address => uint256) banana;    // in slot 2 
    bool xx1;                              // in slot 3 - 1 byte
    bool xx2;                              // in slot 3 - 1 byte
    bool xx3;                              // in slot 3 - 1 byte
    uint8 xx4;                             // in slot 3 - 1 byte 
    bytes16 xx5;                           // in slot 3 - 16 bytes
    uint128 xx6;                           // in slot 4
}
```

## 3.2 Strings

- When a string is 31 bytes and below, the entire string will only occupy one slot. Thus it will use the last byte of the slot to store the length of the string => (First N bytes: the string data (padded with zeros if needed), Last byte: the length of the string)
  
- If it is above 31 bytes then the string will be allocated into multiple slots