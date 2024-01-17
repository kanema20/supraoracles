    // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract TestToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
    }

    function transfer(address _to, uint256 _value) external override returns (bool) {
        require(balanceOf[msg.sender] >= _value, "insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external override returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool) {
        require(balanceOf[_from] >= _value, "insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "insufficient allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}

contract TokenSale is Ownable {
    uint256 public presaleCap; // Total cap for the presale in ETH
    uint256 public pubsaleCap; // Total cap for the pubsale in ETH
    uint256 public presaleTokenPrice; // Price of 1 presale token in wei
    uint256 public pubsaleTokenPrice; // Price of 1 pubsale token in wei
    uint256 public totalTokensSold;
    bool public presaleOpen;
    bool public pubsaleOpen;
    mapping(address => uint256) public presaleBalances;
    mapping(address => uint256) public presaleEthContributions;
    mapping(address => uint256) public pubsaleBalances;
    mapping(address => uint256) public pubsaleEthContributions;
    mapping(address => bool) public refundClaimed;
    mapping(address => bool) public whiteListedForPresale;

    uint256 public minContribution; // Minimum ETH contribution amount
    uint256 public maxContribution; // Maximum ETH contribution amount
    uint256 public presaleLength; // End time of the presale period
    uint256 public pubsaleLength; // End time of the presale period
    uint256 public presaleStartTime; // start time of the presale period
    uint256 public presaleEndTime; // start time of the presale period
    uint256 public pubsaleStartTime; // start time of the presale period
    uint256 public pubsaleEndTime; // start time of the presale period
    TestToken public token; // initialize TestToken to be used for Sale

    event TokensPurchased(address indexed buyer, uint256 amount);
    event RefundClaimed(address indexed buyer, uint256 amount);
    event PresaleOpened(uint256 startTime, uint256 length, uint256 endTime);
    event PubsaleOpened(uint256 startTime, uint256 length, uint256 endTime);
    event PresaleRefundClaimed(address indexed buyer, uint256 amount);
    event PubsaleRefundClaimed(address indexed buyer, uint256 amount);
    event PresaleTokensDistributed(address user, uint256 amount);
    event PubsaleTokensDistributed(address user, uint256 amount);

    constructor(
        TestToken _token,
        uint256 _presaleCap,
        uint256 _pubsaleCap,
        uint256 _presaleTokenPrice,
        uint256 _pubsaleTokenPrice,
        uint256 _minContribution,
        uint256 _maxContribution,
        uint256 _presaleLength,
        uint256 _pubsaleLength
    ) Ownable(msg.sender) {
        token = _token;
        presaleCap = _presaleCap;
        pubsaleCap = _pubsaleCap;
        presaleTokenPrice = _presaleTokenPrice;
        pubsaleTokenPrice = _pubsaleTokenPrice;
        minContribution = _minContribution;
        maxContribution = _maxContribution;
        presaleLength = _presaleLength;
        pubsaleLength = _pubsaleLength;
    }

    function whiteListForPresale(address[] memory usersToWhitelist) internal {
        require(!whiteListedForPresale[msg.sender], "Already whitelisted");
        for (uint256 i = 0; i < usersToWhitelist.length; i++) {
            whiteListedForPresale[usersToWhitelist[i]] = true;
        }
    }

    function openPresale() internal onlyOwner {
        require(presaleOpen != true, "Presale already open");
        presaleStartTime = block.timestamp;
        presaleOpen = true;
        presaleEndTime = block.timestamp + presaleLength;
        emit PresaleOpened(presaleStartTime, presaleLength, presaleEndTime);
    }

    function openPublicSale() internal onlyOwner {
        require(pubsaleOpen != true, "pubsale already open");
        pubsaleStartTime = block.timestamp;
        presaleOpen = false;
        pubsaleOpen = true;
        pubsaleEndTime = block.timestamp + pubsaleLength;
        emit PubsaleOpened(pubsaleStartTime, pubsaleLength, pubsaleEndTime);
    }

    function buyPresaleTokens() external payable {
        if (presaleStartTime + presaleLength <= block.timestamp) {
            openPublicSale();
        }
        require(whiteListedForPresale[msg.sender], "Not whitelisted for presale");
        require(presaleOpen == true, "Presale period has ended");
        require(totalTokensSold < presaleCap, "Presale cap reached");
        require(msg.value >= minContribution, "Below minimum contribution amount");
        require(msg.value <= maxContribution, "Exceeds maximum contribution amount");
        require(!refundClaimed[msg.sender], "Refund already claimed");

        uint256 tokensToBuy = msg.value / presaleTokenPrice;
        // require(IERC20(tokenAddress).transfer(msg.sender, tokensToBuy), "Token transfer failed");
        presaleBalances[msg.sender] += tokensToBuy;
        totalTokensSold += tokensToBuy;
        presaleEthContributions[msg.sender] += msg.value;

        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function buyPubsaleTokens() external payable {
        require(pubsaleStartTime + pubsaleLength <= block.timestamp, "Pubsale has ended.");
        require(pubsaleOpen == true, "Pubsale not started yet");
        require(totalTokensSold < pubsaleCap, "Presale cap reached");
        require(msg.value >= minContribution, "Below minimum contribution amount");
        require(msg.value <= maxContribution, "Exceeds maximum contribution amount");
        require(!refundClaimed[msg.sender], "Refund already claimed");

        uint256 tokensToBuy = msg.value / pubsaleTokenPrice;
        require(tokensToBuy > 0, "Insufficient amount to buy tokens");

        require(IERC20(address(token)).transfer(msg.sender, tokensToBuy), "Token transfer failed");
        pubsaleBalances[msg.sender] += tokensToBuy;
        totalTokensSold += tokensToBuy;
        pubsaleEthContributions[msg.sender] += msg.value;

        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function distributePresaleTokens(address _user) external onlyOwner {
        require(block.timestamp > presaleEndTime, "Presale period has not ended");
        require(totalTokensSold == presaleCap, "Presale not yet completed");

        // Distribute the ERC-20 tokens to the presale participants
        token.transfer(msg.sender, presaleBalances[_user]);
        presaleBalances[_user] = 0;
        emit PresaleTokensDistributed(_user, presaleBalances[_user]);
    }

    function distributePubsaleTokens(address _user) external onlyOwner {
        require(block.timestamp > presaleEndTime, "Presale period has not ended");
        require(totalTokensSold == presaleCap, "Presale not yet completed");

        // Distribute the ERC-20 tokens to the presale participants
        token.transfer(msg.sender, pubsaleBalances[_user]);
        pubsaleBalances[_user] = 0;

        emit PubsaleTokensDistributed(_user, pubsaleBalances[_user]);
    }

    function claimPresaleRefund() external {
        require(block.timestamp > presaleEndTime, "Presale period has not ended");
        require(totalTokensSold < presaleCap, "Presale cap reached");
        require(presaleEthContributions[msg.sender] > 0, "No ETH contribution to refund");
        require(!refundClaimed[msg.sender], "Refund already claimed");

        uint256 refundAmount = presaleEthContributions[msg.sender];
        presaleEthContributions[msg.sender] = 0;
        refundClaimed[msg.sender] = true;

        payable(msg.sender).transfer(refundAmount);

        emit PresaleRefundClaimed(msg.sender, refundAmount);
    }

    function claimPubsaleRefund() external {
        require(block.timestamp > presaleEndTime, "Presale period has not ended");
        require(totalTokensSold < presaleCap, "Presale cap reached");
        require(pubsaleEthContributions[msg.sender] > 0, "No ETH contribution to refund");
        require(!refundClaimed[msg.sender], "Refund already claimed");

        uint256 refundAmount = pubsaleEthContributions[msg.sender];
        pubsaleEthContributions[msg.sender] = 0;
        refundClaimed[msg.sender] = true;

        payable(msg.sender).transfer(refundAmount);

        emit PubsaleRefundClaimed(msg.sender, refundAmount);
    }

    function withdrawFunds() external onlyOwner {
        require(block.timestamp > presaleEndTime, "Presale period has not ended");
        require(totalTokensSold == presaleCap, "Presale not yet completed");
        require(address(this).balance > 0, "No funds to withdraw");

        // Transfer the funds to the contract owner
        payable(msg.sender).transfer(address(this).balance);
    }
}
