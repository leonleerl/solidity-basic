// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Vault {
    address public owner;
    mapping(address => uint256) public balanceOf;

    error NotOwner(address caller);
    error InsufficientBalance(uint256 requested, uint256 available);

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
    }

    function ownerWithdraw(uint256 amount) external {
        if (msg.sender != owner) {
            revert NotOwner(msg.sender);
        }

        uint256 bal = address(this).balance;
        if (amount > bal) {
            revert InsufficientBalance(amount, bal);
        }
        payable(owner).transfer(amount);
    }

    function withdraw(uint256 amount) external {
        uint256 bal = balanceOf[msg.sender];

        if (amount > bal) {
            revert InsufficientBalance(amount, bal);
        }

        balanceOf[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}
