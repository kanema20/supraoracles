// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract TokenSwap {
    uint256 public SwapRateAtoB;
    uint256 public SwapRateBtoA;
    address public tokenA;
    address public tokenB;

    event SwapAtoB(address indexed sender, uint256 amount);
    event SwapBtoA(address indexed sender, uint256 amount);

    constructor(address _tokenA, address _tokenB, uint256 _SwapRateAtoB) {
        SwapRateAtoB = _SwapRateAtoB; // 3
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function swapAtoB(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        IERC20 tokenA_ = IERC20(tokenA);
        IERC20 tokenB_ = IERC20(tokenB);

        uint256 tokenABalance = tokenA_.balanceOf(msg.sender);
        require(tokenABalance >= amount, "Insufficient tokenA balance");

        uint256 tokenBAmount = amount * SwapRateAtoB;

        uint256 tokenBBalance = tokenB_.balanceOf(address(this));
        require(tokenBBalance >= tokenBAmount, "Insufficient tokenB balance");

        // Transfer tokens from sender to contract
        require(tokenA_.transferFrom(msg.sender, address(this), amount), "Failed to transfer tokenA");

        // Transfer tokens from contract to sender
        require(tokenB_.transfer(msg.sender, tokenBAmount), "Failed to transfer tokenB");

        emit SwapAtoB(msg.sender, amount);
    }

    function swapBtoA(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        IERC20 tokenA_ = IERC20(tokenA);
        IERC20 tokenB_ = IERC20(tokenB);

        uint256 tokenBBalance = tokenB_.balanceOf(msg.sender);
        require(tokenBBalance >= amount, "Insufficient tokenB balance");

        uint256 tokenAAmount = amount / SwapRateBtoA;

        uint256 tokenABalance = tokenA_.balanceOf(address(this));
        require(tokenABalance >= tokenAAmount, "Insufficient tokenA balance");

        // Transfer tokens from sender to contract
        require(tokenB_.transferFrom(msg.sender, address(this), amount), "Failed to transfer tokenA");

        // Transfer tokens from contract to sender
        require(tokenA_.transfer(msg.sender, tokenAAmount), "Failed to transfer tokenA");

        emit SwapBtoA(msg.sender, amount);
    }

    function getRateAtoB() public view returns (uint256) {
        return SwapRateAtoB;
    }
}
