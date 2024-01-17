// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import { TokenSwap} from "../src/TokenSwap.sol";
import { TestToken } from "../src/TokenSale.sol";

contract TokenSwapTest is Test {
    TokenSwap public tokenSwap;
    TestToken public tokenA;
    TestToken public tokenB;

    function setUp() public {
        tokenA = new TestToken("TokenA", "TKA", 18, 100000000);
        tokenB = new TestToken("TokenB", "TKB", 18, 300000000);
        tokenSwap = new TokenSwap(address(tokenA), address(tokenB), 3);
    }

    function test_swapAtoB(uint256 fromAmount) public {
        tokenSwap.swapAtoB(fromAmount);
        assertEq(tokenB.balanceOf(msg.sender), fromAmount*tokenSwap.getRateAtoB());
    }

    function test_swapBtoA(uint256 fromAmount) public {
        tokenSwap.swapBtoA(fromAmount);
        assertEq(tokenA.balanceOf(msg.sender), fromAmount/tokenSwap.getRateAtoB());
    }

    function test_getRateAtoB() public {
        assertEq(tokenSwap.getRateAtoB(), 3);
    }
}