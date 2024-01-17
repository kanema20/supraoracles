// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSale, TestToken} from "../src/TokenSale.sol";

contract TokenSaleTest is Test {
    TokenSale public tokenSale;
    TestToken public tokenA;

    function setUp() public {
        tokenA = new TestToken("TokenA", "TKA", 18, 100000000);
        tokenSale =
            new TokenSale(tokenA, 50000000, 50000000, 0.0001 ether, 0.0002 ether, 0.0001 ether, 1 ether, 14400, 14400);
    }

    function test_openPresale() public {
        tokenSale.openPresale();
        assertEq(tokenSale.presaleOpen, true);
    }

    function test_openPubsale() public {
        tokenSale.openPubsale();
        assertEq(tokenSale.pubsaleOpen, true);
    }

    function test_buyPresaleTokens() public {
        tokenSale.buyPresaleTokens();
        assertEq(tokenSale.presaleBalances[msg.sender], msg.value * tokenSale.presaleTokenPrice);
    }

    function test_buyPubsaleTokens() public {
        tokenSale.buyPubsaleTokens();
        assertEq(tokenSale.pubsaleBalances[msg.sender], msg.value * tokenSale.pubsaleTokenPrice);
    }

    function test_distributePresaleTokens(address user) public {
        uint256 userBal = tokenSale.presaleBalances[user];
        tokenSale.distributePresaleTokens(user);
        assertEq(userBal, tokenA.balanceOf(user));
    }

    function test_distributePubsaleTokens(address user) public {
        uint256 userBal = tokenSale.pubsaleBalances[user];
        tokenSale.distributePubsaleTokens(user);
        assertEq(userBal, tokenA.balanceOf(user));
    }

    function test_claimPresaleRefund() public {
        uint256 userContribution = tokenSale.presaleEthContributions[msg.sender];
        uint256 userEthBalance = address(msg.sender).balance;
        tokenSale.claimPresaleRefund();
        assertEq(userContribution, address(msg.sender).balance - userEthBalance);
    }

    function test_claimPubsaleRefund() public {
        uint256 userContribution = tokenSale.pubsaleEthContributions[msg.sender];
        uint256 userEthBalance = address(msg.sender).balance;
        tokenSale.claimPubsaleRefund();
        assertEq(userContribution, address(msg.sender).balance - userEthBalance);
    }
}
