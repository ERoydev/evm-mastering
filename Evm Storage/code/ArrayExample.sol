pragma solidity ^0.8.0;

contract ArrayDemo {
    uint256 totalSupply;                    // slot 0
    address[] users;                        // slot 1

    constructor() {
        users.push(0x33A3FFd50C5805eF071380bDEbe76aEa8DFE248C);
        users.push(0x75cdA57917E9F73705dc8BCF8A6B2f99AdBdc5a5);
    }

    function getUsers(uint256 _index) public view returns (address) {
        return users[_index];
    }
}

// Now deploy that on Remix and on the Debug u can get the `Full Storage Changes`