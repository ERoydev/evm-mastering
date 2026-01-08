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

// Since it is a dynamic array, the length of the array is stored at slot 1
// The actual data is stored at keccak256(1) + index => 1 is the slot that users array is stored at

// Dynamic array storage layout: => Here Solidity is not packing anything
// N = slot assigned to the array variable
// slot N          -> stores array length
// keccak256(N)+i  -> stores arr[i] (i = 0,1,2...)


/*
So keccak256(slot_number) will result inb the `key` where the value of that slot is located inside blockchain storage,
if u check the Json u will see the key is derived like that

keccak256(0000000000000000000000000000000000000000000000000000000000000001) → b10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
this would be the slot id for the first element in the array.

Then on the next i use b10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf7 + 1 to get the second `key` for that slot in the array.
*/

// Now deploy that on Remix and on the Debug u can get the `Full Storage Changes`