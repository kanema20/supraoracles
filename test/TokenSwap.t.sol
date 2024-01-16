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

    // function test_Increment() public {
    //     counter.increment();
    //     assertEq(counter.number(), 1);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
