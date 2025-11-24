// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault vault;
    address alice = address(0xAAA);
    address bob = address(0xBBB);

    function setUp() public {
        vault = new Vault();
    }

    function testOwnerWithdrawRevertIfNotOwner() public {
        // mimic a user
        vm.prank(alice);

        vm.expectRevert(abi.encodeWithSelector(Vault.NotOwner.selector, alice));
        vault.ownerWithdraw(1);
    }

    function testWithdrawInsufficientBalance() public {
        // alice has zero deposited
        vm.prank(alice);

        vm.expectRevert(
            abi.encodeWithSelector(
                Vault.InsufficientBalance.selector,
                1 ether,
                0 // available
            )
        );

        vault.withdraw(1 ether);
    }

    function testDepositAndWithdraw() public {
        vm.deal(alice, 5 ether);

        vm.prank(alice);
        vault.deposit{value: 2 ether}();

        assertEq(vault.balanceOf(alice), 2 ether);

        vm.prank(alice);
        vault.withdraw(1 ether);

        assertEq(vault.balanceOf(alice), 1 ether);
    }
}
