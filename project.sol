// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TutorialRewards {
    struct Tutorial {
        string ipfsHash;
        address uploader;
        uint256 uploadTimestamp;
        uint256 rewardsClaimed;
    }

    address public owner;
    uint256 public rewardPerTutorial;
    mapping(string => bool) private uploadedHashes;
    Tutorial[] public tutorials;

    event TutorialUploaded(string ipfsHash, address indexed uploader, uint256 timestamp);
    event RewardClaimed(string ipfsHash, address indexed uploader, uint256 rewardAmount);

    constructor(uint256 _rewardPerTutorial) {
        owner = msg.sender;
        rewardPerTutorial = _rewardPerTutorial;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function uploadTutorial(string memory _ipfsHash) public {
        require(!uploadedHashes[_ipfsHash], "This tutorial has already been uploaded");

        tutorials.push(Tutorial({
            ipfsHash: _ipfsHash,
            uploader: msg.sender,
            uploadTimestamp: block.timestamp,
            rewardsClaimed: 0
        }));

        uploadedHashes[_ipfsHash] = true;

        emit TutorialUploaded(_ipfsHash, msg.sender, block.timestamp);
    }

    function claimReward(uint256 tutorialIndex) public {
        require(tutorialIndex < tutorials.length, "Invalid tutorial index");
        Tutorial storage tutorial = tutorials[tutorialIndex];
        require(tutorial.uploader == msg.sender, "You are not the uploader of this tutorial");
        require(tutorial.rewardsClaimed == 0, "Reward has already been claimed");

        tutorial.rewardsClaimed = rewardPerTutorial;
        payable(msg.sender).transfer(rewardPerTutorial);

        emit RewardClaimed(tutorial.ipfsHash, msg.sender, rewardPerTutorial);
    }

    function setRewardPerTutorial(uint256 _rewardPerTutorial) public onlyOwner {
        rewardPerTutorial = _rewardPerTutorial;
    }

    function depositFunds() public payable onlyOwner {}

    function getTutorialsCount() public view returns (uint256) {
        return tutorials.length;
    }
}
