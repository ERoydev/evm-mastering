pragma solidity ^0.8.0;

contract MappingDemo {
    uint256 totalSupply;                    // slot 0
    mapping(address => uint256) approvals;  // slot 1

    constructor() {
        approvals[0x33A3FFd50C5805eF071380bDEbe76aEa8DFE248C] = 10;
        approvals[0x75cdA57917E9F73705dc8BCF8A6B2f99AdBdc5a5] = 20;
    }

    function getApprovals(address _address) public view returns (uint256) {
        return approvals[_address];
    }
} 

/* 
Here is how mapping is stored in Solidity:

The addresses inside the approvals are stored like this:
1. 0x33A3FFd50C5805eF071380bDEbe76aEa8DFE248C -> is lowercased and then padded to 32 bytes:
    - 00000000000000000000000033a3ffd50c5805ef071380bdebe76aea8dfe248c

2. Then i use this 32 bytes and i `append` the storage slot id of the mapping variable, 
in my case mapping is stored on slot 1 so i will always use id of `1` here:
    - 00000000000000000000000033a3ffd50c5805ef071380bdebe76aea8dfe248c<0000000000000000000000000000000000000000000000000000000000000001>

3. Then i keccak256 that 
00000000000000000000000033a3ffd50c5805ef071380bdebe76aea8dfe248c0000000000000000000000000000000000000000000000000000000000000001 
→ 4ab1da6bef620abdbfad2d7e5ea513e8b321d569c98e4e1c6e49203dfaa7be78


This is how i derive the storage slot of a mapping.

*/