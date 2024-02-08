// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract ProposalDAO {
    address public owner;
    uint256 public nextProposalId;
    address public tokenAddress; // Address of the ERC-20 token contract

    // Proposal structure
    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 votingStartTime;
        uint256 votingEndTime;
        uint256 requiredTokenAmount; // Minimum token amount required to vote on this proposal
        mapping(address => bool) hasVoted; // Track whether an address has voted
        uint256 votes; // Total votes for the proposal
    }

    // Mapping to store proposals by their ID
    mapping(uint256 => Proposal) public proposals;

    // Members of the DAO
    mapping(address => bool) public members;

    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        string description,
        uint256 startTime,
        uint256 endTime,
        uint256 requiredTokenAmount
    );
    event Voted(uint256 proposalId, address voter, uint256 votes);
    event MemberAdded(address member);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Not a DAO member");
        _;
    }

    modifier validProposal(uint256 _proposalId) {
        require(_proposalId < nextProposalId, "Invalid proposal ID");
        _;
    }

    constructor(address _tokenAddress) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
    }

    function createProposal(
        string memory _description,
        uint256 _votingStartTime,
        uint256 _votingEndTime,
        uint256 _requiredTokenAmount
    ) external onlyMember {
        require(_votingStartTime < _votingEndTime, "Invalid voting times");
        require(
            _requiredTokenAmount > 0,
            "Required token amount must be greater than 0"
        );

        Proposal storage newProposal = proposals[nextProposalId];
        newProposal.id = nextProposalId;
        newProposal.proposer = msg.sender;
        newProposal.description = _description;
        newProposal.votingStartTime = _votingStartTime;
        newProposal.votingEndTime = _votingEndTime;
        newProposal.requiredTokenAmount = _requiredTokenAmount;

        emit ProposalCreated(
            nextProposalId,
            msg.sender,
            _description,
            _votingStartTime,
            _votingEndTime,
            _requiredTokenAmount
        );

        nextProposalId++;
    }

    function vote(uint256 _proposalId)
        external
        onlyMember
        validProposal(_proposalId)
    {
        Proposal storage proposal = proposals[_proposalId];

        require(
            block.timestamp >= proposal.votingStartTime &&
                block.timestamp <= proposal.votingEndTime,
            "Voting outside the allowed time"
        );

        // Fetch the balance from the ERC-20 token contract
        uint256 userTokenBalance = IERC20(tokenAddress).balanceOf(msg.sender);
        require(
            userTokenBalance >= proposal.requiredTokenAmount,
            "Insufficient tokens to vote"
        );
        require(!proposal.hasVoted[msg.sender], "Address has already voted");

        proposal.hasVoted[msg.sender] = true;
        proposal.votes += userTokenBalance;

        emit Voted(_proposalId, msg.sender, userTokenBalance);
    }

    function addMember(address _member) external onlyOwner {
        require(!members[_member], "Address is already a member");
        members[_member] = true;
        emit MemberAdded(_member);
    }



    // Additional functions may be needed for managing token balances, transferring ownership, etc.
}
