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

    function testDeposit() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        assertEq(vault.balanceOf(alice), 1 ether);
        assertEq(address(vault).balance, 1 ether);
    }

    function testWithdraw() public {
        vm.deal(bob, 3 ether);

        vm.startPrank(bob);
        assertEq(vault.balanceOf(bob), 0);

        vault.deposit{value: 2 ether}();
        assertEq(vault.balanceOf(bob), 2 ether);

        vault.withdraw(1 ether);
        assertEq(vault.balanceOf(bob), 1 ether);
        assertEq(address(vault).balance, 1 ether);
        vm.stopPrank();
    }

    function testDeposit_MultiUser() public {
        vm.deal(alice, 5 ether);
        vm.deal(bob, 3 ether);

        vm.startPrank(alice);
        vault.deposit{value: 2 ether}();
        vm.stopPrank();

        vm.startPrank(bob);
        vault.deposit{value: 1 ether}();
        vm.stopPrank();

        assertEq(address(vault).balance, 3 ether);
        assertEq(vault.balanceOf(alice), 2 ether);
        assertEq(vault.balanceOf(bob), 1 ether);

        uint256 aliceBefore = alice.balance;
        vm.startPrank(alice);
        vault.withdraw(1 ether);
        vm.stopPrank();

        assertEq(alice.balance, aliceBefore + 1 ether);
        assertEq(vault.balanceOf(alice), 1 ether);
        assertEq(address(vault).balance, 2 ether);

        uint256 bobBefore = bob.balance;

        vm.startPrank(bob);
        vault.withdraw(0.5 ether);
        vm.stopPrank();

        assertEq(vault.balanceOf(bob), 0.5 ether);
        assertEq(address(vault).balance, 1.5 ether);
        assertEq(bob.balance, bobBefore + 0.5 ether);
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
