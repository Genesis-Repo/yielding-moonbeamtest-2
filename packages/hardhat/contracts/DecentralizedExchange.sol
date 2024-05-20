// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DecentralizedExchange is ReentrancyGuard {
    using Address for address payable;

    mapping(address => mapping(address => uint256)) public tokens;

    event TokensSwapped(address indexed user, address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB);

    function swapTokens(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external nonReentrant {
        require(amountA > 0 && amountB > 0, "Amount must be greater than 0");
        require(tokens[tokenA][msg.sender] >= amountA, "Insufficient balance for token A");
        require(tokens[tokenB][msg.sender] >= amountB, "Insufficient balance for token B");

        tokens[tokenA][msg.sender] -= amountA;
        tokens[tokenB][msg.sender] -= amountB;
        tokens[tokenA][msg.sender] += amountB;
        tokens[tokenB][msg.sender] += amountA;

        emit TokensSwapped(msg.sender, tokenA, tokenB, amountA, amountB);
    }

    function depositTokens(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        tokens[token][msg.sender] += amount;
    }

    function withdrawTokens(address token, uint256 amount) external nonReentrant {
        require(tokens[token][msg.sender] >= amount, "Insufficient balance");

        tokens[token][msg.sender] -= amount;
        IERC20(token).transfer(msg.sender, amount);
    }
}