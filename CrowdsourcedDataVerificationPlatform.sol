// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CrowdsourcedDataVerification {
    struct DataEntry {
        uint id;
        string dataHash; // Hash of the data submitted
        address submitter;
        uint upvotes;
        uint downvotes;
        mapping(address => bool) hasVoted;
        bool verified;
    }

    mapping(uint => DataEntry) public dataEntries;
    uint public dataCounter;
    
    event DataSubmitted(uint id, string dataHash, address submitter);
    event DataVerified(uint id, bool verified);
    event VoteCast(uint id, address voter, bool isUpvote);

    function submitData(string memory _dataHash) external {
        dataCounter++;
        DataEntry storage newData = dataEntries[dataCounter];
        newData.id = dataCounter;
        newData.dataHash = _dataHash;
        newData.submitter = msg.sender;
        newData.verified = false;

        emit DataSubmitted(dataCounter, _dataHash, msg.sender);
    }

    function voteOnData(uint _id, bool _isUpvote) external {
        require(dataEntries[_id].id == _id, "Invalid data entry");
        require(!dataEntries[_id].hasVoted[msg.sender], "Already voted");

        DataEntry storage data = dataEntries[_id];

        if (_isUpvote) {
            data.upvotes++;
        } else {
            data.downvotes++;
        }
        data.hasVoted[msg.sender] = true;

        emit VoteCast(_id, msg.sender, _isUpvote);
    }

    function verifyData(uint _id) external {
        require(dataEntries[_id].id == _id, "Invalid data entry");
        require(dataEntries[_id].upvotes > dataEntries[_id].downvotes, "Not enough upvotes to verify");

        dataEntries[_id].verified = true;

        emit DataVerified(_id, true);
    }

    function getDataEntry(uint _id) external view returns (uint, string memory, address, uint, uint, bool) {
        DataEntry storage data = dataEntries[_id];
        return (data.id, data.dataHash, data.submitter, data.upvotes, data.downvotes, data.verified);
    }
}
