// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;
    address alice = address(0xAAA);
    address bob = address(0xBBB);

    function setUp() public {
        token = new MyToken(1000 ether);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000 ether);
        assertEq(token.balanceOf(address(this)), 1000 ether);
    }

    function testTransfer() public {
        token.transfer(bob, 100 ether);
        assertEq(token.balanceOf(bob), 100 ether);
    }

    function testTransferFail() public {
        vm.prank(alice);
        vm.expectRevert();
        token.transfer(bob, 1000 ether);
    }

    function testMultipleTransfersWithPrank() public {
        token.transfer(alice, 200 ether);

        vm.startPrank(alice);
        token.transfer(bob, 50 ether);
        token.transfer(bob, 10 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(bob), 60 ether);
    }
}
