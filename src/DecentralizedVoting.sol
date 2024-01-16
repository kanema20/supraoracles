// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";

contract DecentralizedVoting is Ownable {
    // counter enables us to use a mapping
    // instead of an array for the ballots
    // this is more gas effiecient
    uint public ballotCounter;
    uint public candidateCounter;
    uint public voterCounter;

    mapping (uint256 => Candidate) public candidates;
    mapping (uint256 => Voter) public voters;
    mapping (uint256 => Ballot) public ballots;

    mapping (address => bool) public isRegistered;
    mapping (address => bool) public isBlacklisted;

    struct Ballot {
        Candidate[] candidates;
        uint startTime;
        uint duration;
        bool ballotOpen;
    }

    struct Candidate {
        address candidateAddress;
        bytes name;
        uint age;
        bytes position;
        bool addedToBallot;
    }

    struct Voter {
        address userWallet;
        bool isRegistered;
        bool hasVoted;
    }

    mapping(uint => mapping(uint => uint)) private _tally;
    mapping(uint => mapping(address => bool)) public hasVoted;
    mapping(uint => mapping(address => bool)) public addedToBallot;

    // EVENTS
    // TODO: FINISH EMITTING THESE
    event BallotCreated(
        uint indexed ballotId,
        uint startTime,
        uint duration
    );
    event CandidateAdded(
        uint indexed ballotId,
        address indexed candidateAddress,
        bytes name,
        uint age,
        bytes position
    );
    event VoteCast(
        uint indexed ballotId,
        address indexed voterAddress,
        uint indexed candidateId
    );
    // event BallotClosed(
    //     uint indexed ballotId
    // );
    event VoterRegistered(
        address indexed voterAddress
    );
    event BallotWinner(
        uint indexed ballotId,
        address indexed candidateAddress
    );
    event VotingOpen(
        uint indexed ballotId,
        uint startTime,
        uint duration
    );

    constructor(uint ballotCounter_, uint voterCounter_, uint candidateCounter_) Ownable(msg.sender) {
        ballotCounter = ballotCounter_;
        voterCounter = voterCounter_;
        candidateCounter = candidateCounter_;
    }

    function addCandidate(
        uint ballotIndex_,
        address candidateAddress_,
        bytes memory name_,
        uint age_,
        bytes memory position_
    ) internal onlyOwner {
        require(addedToBallot[ballotIndex_][candidateAddress_], "Candidate already added");
        require(block.timestamp < ballots[ballotIndex_].startTime, "Ballot closed");
        candidates[candidateCounter] = Candidate(candidateAddress_, name_, age_, position_, true);
        candidateCounter++;
        ballots[ballotIndex_].candidates.push(candidates[candidateCounter]);
        addedToBallot[ballotCounter][candidateAddress_] = true;

        emit CandidateAdded(ballotIndex_, candidateAddress_, name_, age_, position_);
    }

    modifier notBlacklisted() {
        require(
            !isBlacklisted[msg.sender],
            "Address is blacklisted"
        );
        _;
    }

    function register() public notBlacklisted {
        require(
            !isRegistered[msg.sender],
            "Address already registered"
        );
        isRegistered[msg.sender] = true;
        hasVoted[ballotCounter][msg.sender] = false;
        voters[voterCounter] = Voter(msg.sender, true, false);
        voterCounter++;
        emit VoterRegistered(msg.sender);
    }

    function getBallotByIndex(
        uint index_
    ) external view returns (Ballot memory ballot) {
        ballot = ballots[index_];
    }

    function castVote(uint ballotIndex_, uint candidateIndex_) external {
        // must be registered
        require(isRegistered[msg.sender], "voter is not reigstered");
        // can only vote once
        require(
            !hasVoted[ballotIndex_][msg.sender],
            "Address already casted a vote for this ballot"
        );
        Ballot memory ballot = ballots[ballotIndex_];
        require(
            block.timestamp >= ballot.startTime,
            "Can't cast before start time"
        );
        require(
            block.timestamp < ballot.startTime + ballot.duration,
            "Can't cast after end time"
        );

        _tally[ballotIndex_][candidateIndex_]++;
        hasVoted[ballotIndex_][msg.sender] = true;

        emit VoteCast(ballotIndex_, msg.sender, candidateIndex_);
    }

    function isBallotOpen(uint ballotIndex_) public view returns(bool) {
        Ballot memory ballot = ballots[ballotIndex_];
        return ballot.ballotOpen;
    }

    function createBallot(uint duration_, uint startTime_, Candidate[] memory candidates_) internal onlyOwner {
        require(!ballots[ballotCounter].ballotOpen, "Ballot already open");
        ballots[ballotCounter] = Ballot(candidates_, startTime_, duration_, true);
        ballotCounter++;
        emit BallotCreated(ballotCounter, startTime_, duration_);
        emit VotingOpen(ballotCounter, startTime_, duration_);
    }

    function getCandidates(uint _ballotIndex) public returns (Candidate[] memory) {
        Ballot memory ballot = ballots[_ballotIndex];
        return ballot.candidates;
    }

    function getTallyByCandidate(
        uint ballotIndex_,
        uint candidateIndex_
    ) external view returns (uint) {
        return _tally[ballotIndex_][candidateIndex_];
    }

    function results(uint ballotIndex_) external view returns (uint[] memory) {
        Ballot memory ballot = ballots[ballotIndex_];
        uint len = ballot.candidates.length;
        uint[] memory result = new uint[](len);
        for (uint i = 0; i < len; i++) {
            result[i] = _tally[ballotIndex_][i];
        }
        return result;
    }

    function winner(uint ballotIndex_) external returns (bool[] memory) {
        Ballot memory ballot = ballots[ballotIndex_];
        uint len = ballot.candidates.length;
        uint[] memory result = new uint[](len);
        uint max;
        for (uint i = 0; i < len; i++) {
            result[i] = _tally[ballotIndex_][i];
            if (result[i] > max) {
                max = result[i];
            }
        }
        bool[] memory winner_ = new bool[](len);
        for (uint i = 0; i < len; i++) {
            if (result[i] == max) {
                winner_[i] = true;
            }
        }
        emit BallotWinner(ballotIndex_, ballot.candidates[max].candidateAddress);

        return winner_;
    }
}