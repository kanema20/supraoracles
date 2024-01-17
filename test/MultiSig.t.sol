// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/MultiSig.sol";

contract MultiSigWalletTest is Test {
    struct TxData {
        address to;
        uint value;
        bytes data;
    }

    MultiSigWallet public multiSigWallet;
    address[] walletOwners = [address(0x1), address(0x2), address(0x3)];

    function setUp() public {
        multiSigWallet = new MultiSigWallet(walletOwners, 2);
    }

    function test_submitTransaction(TxData memory txData) public {
        multiSigWallet.submitTransaction(txData.to, txData.value, txData.data);
        uint txIndex = multiSigWallet.transactions.length;
        assertEq(txData, multiSigWallet.transactions[txIndex]);
    }

    function test_confirmTransaction(uint txIndex) public {
        uint txConfirmations = multiSigWallet.transactions[txIndex].numConfirmations;
        multiSigWallet.confirmTransaction(txIndex);
        assertEq(txConfirmations + 1, multiSigWallet.transactions[txIndex].numConfirmations);
    }

    function test_executeTransaction(uint txIndex) public {
        multiSigWallet.executeTransaction(txIndex);
        assertEq(multiSigWallet.transactions[txIndex].executed, true);
    }
    
    function test_revokeConfirmation(uint txIndex) public {
        multiSigWallet.revokeConfirmation(txIndex);
        assertEq(multiSigWallet.isConfirmed[txIndex][msg.sender], false);
    }

    function test_getOwners() public {
        assertEq(multiSigWallet.getOwners(), multiSigWallet.owners);
    }

    function test_getTransactionCount() public {
        assertEq(multiSigWallet.getTransactionCount(), multiSigWallet.transactions.length);
    }

    function test_getTransaction(uint txIndex) public {
        assertEq(multiSigWallet.getTransaction(txIndex), multiSigWallet.transactions[txIndex]);
    }
}
