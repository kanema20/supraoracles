// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DecentralizedVoting} from "../src/DecentralizedVoting.sol";

contract DecentralizedVotingTest is Test {
    DecentralizedVoting public decentVoting;

    function setUp() public {
        decentVoting = new DecentralizedVoting(0, 0, 0);
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
