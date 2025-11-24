contract StructDemo {
  struct Item {
    uint256 price; // first slot -- 32 bytes
    address owner; // second slot -- 20 bytes
    uint8 fee;     // second slot -- 1 bytes
  }
}

/*
Here Solidity is packing owner and fee in one slot, because they can be fit in 32 bytes slot.
So this is a gas optimization as Solidity will load the entire struct from storage and will cost lesser gas if lesser slots are loaded.
*/