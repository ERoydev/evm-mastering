pragma solidity ^0.8.0;

contract ShortStringDemo {
  uint256 totalSupply;    // slot 0
  string name = "Jeremy"  // slot 1
}


contract LongStringDemo {
  uint256 totalSupply;    // slot 0
  string name;            // slot 1

  constructor() {
        name = "JeremyJeremyJeremyJeremyJeremyJeremyJeremyJeremyJeremyJeremyJeremyJeremy";
    }
}

/*
Short string storage layout:
if this string is 31 bytes, the entire string will occupy one slot and the last byte will contain the length of the string in bytes.

0x4a6572656d79000000000000000000000000000000000000000000000000000c where
4a6572656d79 → Jeremy and c → 12 represent the length of the bytes.

Long string storage layout:
When a string is above 31 bytes, it will span into multiple slots. The storage layout would map to the below

slot 1 -> would containt the length of th string * 2 + 1
keccak256(slotId) -> keccak256(0000000000000000000000000000000000000000000000000000000000000001) → b10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6

The next slot would be +1 of the previous slot


*/