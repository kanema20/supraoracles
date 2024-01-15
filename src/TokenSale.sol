// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import { IERC20 } from "forge-std/interfaces/IERC20.sol";

contract Presale {
    address public tokenAddress;  // Address of the ERC-20 token
    uint256 public presaleCap;    // Total cap for the presale in ETH
    uint256 public pubsaleCap;    // Total cap for the pubsale in ETH
    uint256 public presaleTokenPrice;    // Price of 1 presale token in wei
    uint256 public pubsaleTokenPrice;    // Price of 1 pubsale token in wei
    uint256 public totalTokensSold;
    bool public presaleOpen;
    bool public pubsaleOpen;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public ethContributions;
    mapping(address => bool) public refundClaimed;
    mapping(address => bool) public whiteListedForPresale;

    uint256 public minContribution;  // Minimum ETH contribution amount
    uint256 public maxContribution;  // Maximum ETH contribution amount
    uint256 public presaleLength;   // End time of the presale period
    uint256 public presaleStartTime;   // start time of the presale period

    event TokensPurchased(address indexed buyer, uint256 amount);
    event RefundClaimed(address indexed buyer, uint256 amount);
    event PresaleOpened();
    event PubsaleOpened();
    event PresaleEnded();
    event PubsaleEnded();
            
    constructor(address _tokenAddress, uint256 _presaleCap, uint256 _presaleTokenPrice, uint256 _pubsaleTokenPrice, uint256 _minContribution, uint256 _maxContribution, uint256 _presaleLength) {
        tokenAddress = _tokenAddress;
        presaleCap = _presaleCap;
        presaleTokenPrice = _presaleTokenPrice;
        pubsaleTokenPrice = _pubsaleTokenPrice;
        minContribution = _minContribution;
        maxContribution = _maxContribution;
        presaleLength = _presaleLength;
    }

    function whiteListForPresale(address[] usersToWhitelist) internal {
        require(!whiteListedForPresale[msg.sender], "Already whitelisted");
        for (uint256 i = 0; i < usersToWhitelist.length; i++) {
            whiteListedForPersale[usersToWhitelist[i]] = true;
        }
    }

    function openPresale() internal onlyOwner {
        // TODO: set presale flag to true
        require(presaleOpen != true, "Presale already open");
        presaleStartTime = block.timestamp;
        presaleOpen = true;
    }

    function openPublicSale() internal {
        // TODO: set pubsale flag to true
        require(pubsaleOpen != true, "pubsale already open");
        pubsaleStartTime = block.timestamp;
        pubsaleOpen = true;
        presaleOpen = false;
    }

    function buyPresaleTokens() external payable {
        if (presaleStartTime + presaleLength <= block.timestamp) {
            openPublicSale();
        }
        require(presaleOpen == true, "Presale period has ended");
        require(totalTokensSold < presaleCap, "Presale cap reached");
        require(msg.value >= minContribution, "Below minimum contribution amount");
        require(msg.value <= maxContribution, "Exceeds maximum contribution amount");
        require(!refundClaimed[msg.sender], "Refund already claimed");

        uint256 tokensToBuy = msg.value / tokenPrice;
        require(tokensToBuy > 0, "Insufficient amount to buy tokens");

        require(IERC20(tokenAddress).transfer(msg.sender, tokensToBuy), "Token transfer failed");
        balances[msg.sender] += tokensToBuy;
        totalTokensSold += tokensToBuy;
        ethContributions[msg.sender] += msg.value;

        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function buyPubsaleTokens() external payable {
        require(pubsaleOpen == true, "Pubsale not started yet");
        require(totalTokensSold < pubsaleCap, "Presale cap reached");
        require(msg.value >= minContribution, "Below minimum contribution amount");
        require(msg.value <= maxContribution, "Exceeds maximum contribution amount");
        require(!refundClaimed[msg.sender], "Refund already claimed");

        uint256 tokensToBuy = msg.value / tokenPrice;
        require(tokensToBuy > 0, "Insufficient amount to buy tokens");

        require(IERC20(tokenAddress).transfer(msg.sender, tokensToBuy), "Token transfer failed");
        balances[msg.sender] += tokensToBuy;
        totalTokensSold += tokensToBuy;
        ethContributions[msg.sender] += msg.value;

        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function distributePresaleTokens() external onlyOwner {
        require(block.timestamp > presaleEndTime, "Presale period has not ended");
        require(totalTokensSold == presaleCap, "Presale not yet completed");

        // Perform the token distribution logic here
        // Distribute the ERC-20 tokens to the presale participants

        // Example: Transfer tokens from contract to the participant
        require(IERC20(tokenAddress).transfer(msg.sender, balances[msg.sender]), "Token transfer failed");
    }


    function distributePubsaleTokens() external onlyOwner {
        require(block.timestamp > presaleEndTime, "Presale period has not ended");
        require(totalTokensSold == presaleCap, "Presale not yet completed");

        // Perform the token distribution logic here
        // Distribute the ERC-20 tokens to the presale participants

        // Example: Transfer tokens from contract to the participant
        require(IERC20(tokenAddress).transfer(msg.sender, balances[msg.sender]), "Token transfer failed");
    }

    function claimRefund() external {
        require(block.timestamp > presaleEndTime, "Presale period has not ended");
        require(totalTokensSold < presaleCap, "Presale cap reached");
        require(ethContributions[msg.sender] > 0, "No ETH contribution to refund");
        require(!refundClaimed[msg.sender], "Refund already claimed");

        uint256 refundAmount = ethContributions[msg.sender];
        ethContributions[msg.sender] = 0;
        refundClaimed[msg.sender] = true;

        payable(msg.sender).transfer(refundAmount);

        emit RefundClaimed(msg.sender, refundAmount);
    }

    function withdrawFunds() external {
        require(block.timestamp > presaleEndTime, "Presale period has not ended");
        require(totalTokensSold == presaleCap, "Presale not yet completed");
        require(address(this).balance > 0, "No funds to withdraw");

        // Transfer the funds to the contract owner
        payable(msg.sender).transfer(address(this).balance);
    }
}
