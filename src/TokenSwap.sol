// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TokenSwap {
    uint256 public SwapRateAtoB;
    uint256 public SwapRateBtoA;
    address public tokenA;
    address public tokenB;

    constructor(address _tokenA, address _tokenB, uint256 _SwapRateAtoB, uint256 _SwapRateBtoA) {
        SwapRateAtoB = _SwapRateAtoB; // 3
        SwapRateBtoA = _SwapRateBtoA; // 1/3
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function swapAtoB(uint256 amount) public {
        
        payable(msg.sender).transfer(amountB);

    }

       function swapBtoA(uint256 amount) public {

        uint256 amountB = (msg.value * SwapRateAtoB) / 1 ether;
        payable(msg.sender).transfer(amountB);

    }
}