// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StorageLayout {
    uint256 public a = 1; // slot 0
    uint128 public b = 2; // slot 1
    uint128 public c = 3; // slot 1 (might be packed with b)
    address public owner = msg.sender; // slot 2

    struct User {
        uint256 balance;
        uint256 lastUpdate;
    }

    uint256[] public arr; // slot 3: arr

    mapping(address => User) public users; // slot 4: users (mapping)

    constructor() {
        arr.push(10); // arr[0]
        arr.push(20); // arr[1]
    }

    // using assembly to read any slot
    function readStorage(uint256 slot) public view returns (bytes32 data) {
        assembly {
            data := sload(slot)
        }
    }
}
