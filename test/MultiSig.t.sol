// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/MultiSig.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet public multiSigWallet;
    address[] walletOwners = [address(0x1), address(0x2), address(0x3)];

    function setUp() public {
        multiSigWallet = new MultiSigWallet(walletOwners, 2);
    //     counter.setNumber(0);
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
