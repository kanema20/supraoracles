// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSale, TestToken} from "../src/TokenSale.sol";

contract TokenSaleTest is Test {
    TokenSale public tokenSale;
    TestToken public tokenA;

    function setUp() public {
        tokenSale = new TokenSale(tokenA, 50000, 50000, 0.0001 ether, 0.0002 ether, 0.0001 ether, 1 ether, 14400, 14400);
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
