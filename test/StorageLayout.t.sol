// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StorageLayout.sol";

contract StorageTest is Test {
    StorageLayout store;

    function setUp() public {
        store = new StorageLayout();
    }

    function testStorageSlots() public {
        // slot 0 -> a
        bytes32 slot0 = store.readStorage(0);
        assertEq(uint256(slot0), 1);

        // slot 1: packed b + c (uint128 + uint128)
        bytes32 slot1 = store.readStorage(1);

        // b 在低 128 bits，c 在高 128 bits
        uint128 b = uint128(uint256(slot1)); // lower 16 bytes
        uint128 c = uint128(uint256(slot1 >> 128)); // higher 16 bytes

        assertEq(b, 2);
        assertEq(c, 3);
    }

    function testDynamicArray() public {
        // slot 3 is array length
        bytes32 lenSlot = store.readStorage(3);
        assertEq(uint256(lenSlot), 2);

        // arr data starts at keccak256(abi.encode(uint256(3)))
        bytes32 base = keccak256(abi.encode(uint256(3)));

        // arr[0]
        bytes32 arr0 = store.readStorage(uint256(base));
        // arr[1]
        bytes32 arr1 = store.readStorage(uint256(base) + 1);

        assertEq(uint256(arr0), 10);
        assertEq(uint256(arr1), 20);
    }

    function testMappingSlotComputation() public {
        address user = address(0xBEEF);

        // mapping 在 slot 4：
        // users[user].balance 存在 keccak256(abi.encode(user, uint256(4))) 这个 slot
        bytes32 userSlotBase = keccak256(abi.encode(user, uint256(4)));

        // 这里我们没有写 users[user]，只是演示 slot 计算方式，
        // 你可以在后续 Day 的练习中给 users 填值再读。
        emit log_bytes32(userSlotBase);
    }
}
