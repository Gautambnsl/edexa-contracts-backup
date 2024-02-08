// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProposalDAO {
    address public owner;
    uint256 public nextProposalId;

    enum VoteChoice { None, Yes, No }

    struct Proposal {
        uint256 id;
        address proposer;
        string title;
        string ipfsLink; // Renamed field
        uint256 votingStartTime;
        uint256 votingEndTime;
        mapping(address => bool) hasVoted;
        mapping(address => VoteChoice) voteChoices;
        uint256 yesVotes;
        uint256 noVotes;
    }

    struct ProposalInfo {
        uint256 proposalId; // New field
        string title;
        string ipfsLink;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 endResults;
        uint256 votingStartTime;
        uint256 votingEndTime;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public members;

    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        string title,
        string ipfsLink, // Renamed field
        uint256 startTime,
        uint256 endTime
    );
    event Voted(uint256 proposalId, address voter, VoteChoice voteChoice, uint256 votes);
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

    constructor() {
        owner = msg.sender;
    }

    function createProposal(
        string memory _title,
        string memory _ipfsLink, // Renamed field
        uint256 _votingStartTime,
        uint256 _votingEndTime
    ) external onlyOwner {
        require(_votingStartTime < _votingEndTime, "Invalid voting times");

        Proposal storage newProposal = proposals[nextProposalId];
        newProposal.id = nextProposalId;
        newProposal.proposer = msg.sender;
        newProposal.title = _title;
        newProposal.ipfsLink = _ipfsLink; // Set the renamed field
        newProposal.votingStartTime = _votingStartTime;
        newProposal.votingEndTime = _votingEndTime;
        newProposal.yesVotes = 0;
        newProposal.noVotes = 0;

        emit ProposalCreated(
            nextProposalId,
            msg.sender,
            _title,
            _ipfsLink, // Include the renamed field in the event
            _votingStartTime,
            _votingEndTime
        );

        nextProposalId++;
    }

    function vote(uint256 _proposalId, VoteChoice _voteChoice)
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
        require(!proposal.hasVoted[msg.sender], "Address has already voted");

        proposal.hasVoted[msg.sender] = true;
        proposal.voteChoices[msg.sender] = _voteChoice;

        if (_voteChoice == VoteChoice.Yes) {
            proposal.yesVotes += 1;
        } else if (_voteChoice == VoteChoice.No) {
            proposal.noVotes += 1;
        }

        emit Voted(_proposalId, msg.sender, _voteChoice, 1);
    }

    function addMember(address _member) external onlyOwner {
        require(!members[_member], "Address is already a member");
        members[_member] = true;
        emit MemberAdded(_member);
    }

    function getProposalInfo(uint256 _proposalId)
    public
    view
    validProposal(_proposalId)
    returns (uint256, string memory, string memory, uint256, uint256, uint256, uint256, uint256)
    {
        Proposal storage proposal = proposals[_proposalId];

        uint256 yesVotes = proposal.yesVotes;
        uint256 noVotes = proposal.noVotes;
        uint256 endResults;

        // Determine the end results based on the voting outcome
        if (block.timestamp < proposal.votingEndTime) {
            endResults = 0; // Voting is still ongoing
        } else {
            endResults = yesVotes > noVotes ? 1 : (yesVotes == noVotes ? 2 : 3);
        }

        return (
            proposal.id, // Include proposalId in the return values
            proposal.title,
            proposal.ipfsLink, // Include the renamed field in the return values
            yesVotes,
            noVotes,
            endResults,
            proposal.votingStartTime, // Include the start time
            proposal.votingEndTime
        );
    }

    function getAllProposals() external view returns (uint256[] memory) {
        uint256[] memory proposalIds = new uint256[](nextProposalId);

        for (uint256 i = 0; i < nextProposalId; i++) {
            proposalIds[i] = i;
        }

        return proposalIds;
    }

    function getAllProposalsInfo() external view returns (ProposalInfo[] memory) {
        ProposalInfo[] memory allProposalsInfo = new ProposalInfo[](nextProposalId);

        for (uint256 i = 0; i < nextProposalId; i++) {
            (
                uint256 proposalId,
                string memory title,
                string memory ipfsLink,
                uint256 yesVotes,
                uint256 noVotes,
                uint256 endResults,
                uint256 votingStartTime,
                uint256 votingEndTime
            ) = getProposalInfo(i);

            allProposalsInfo[i] = ProposalInfo({
                proposalId: proposalId, // Include proposalId in the struct
                title: title,
                ipfsLink: ipfsLink,
                yesVotes: yesVotes,
                noVotes: noVotes,
                endResults: endResults,
                votingStartTime: votingStartTime,
                votingEndTime: votingEndTime
            });
        }

        return allProposalsInfo;
    }
}
