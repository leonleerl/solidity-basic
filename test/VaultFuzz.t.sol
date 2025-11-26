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

    function testFuzz_Deposit(uint256 amount) public {
        vm.assume(amount > 0 && amount <= 100 ether);
        vm.deal(alice, amount);
        vm.prank(alice);
        vault.deposit{value: amount}();

        assertEq(vault.balanceOf(alice), amount);
    }

    function testFuzz_DepositWithdraw(
        uint256 amount,
        uint256 withdrawAmount
    ) public {
        vm.assume(amount > 0 && amount <= 100 ether);
        vm.assume(withdrawAmount <= amount);

        vm.deal(alice, amount);

        vm.startPrank(alice);
        vault.deposit{value: amount}();

        vault.withdraw(withdrawAmount);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), amount - withdrawAmount);
        assertEq(alice.balance, withdrawAmount);
    }

    function testFuzz_WithdrawRevert(
        uint256 amount,
        uint256 withdrawAmount
    ) public {
        vm.assume(amount < 10 ether);
        vm.assume(withdrawAmount > amount);

        vm.deal(alice, amount);

        vm.startPrank(alice);
        vault.deposit{value: amount}();
        vm.expectRevert(
            abi.encodeWithSelector(
                Vault.InsufficientBalance.selector,
                withdrawAmount,
                amount
            )
        );
        vault.withdraw(withdrawAmount);

        vm.stopPrank();
    }
}
