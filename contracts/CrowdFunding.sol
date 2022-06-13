// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowFundingStorage {
    struct Campaign {
        address payable receiver;
        uint256 numFunders;
        uint256 fundingGoal;
        uint256 totalAmount;
    }

    struct Funder {
        address addr;
        uint256 amount;
    }

    uint256 public numCampaign;
    mapping(uint256 => Campaign) campaigns;
    mapping(uint256 => Funder[]) funders;

    mapping(uint256 => mapping(address => bool)) public isParticipate;
}

contract CrowdFunding is CrowFundingStorage {
    address immutable owner;

    constructor() {
        owner = msg.sender;
    }

    modifier judgeParticipate(uint256 campaignID) {
        require(isParticipate[campaignID][msg.sender] == false);
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    function newCampaign(address payable receiver, uint256 goal)
        external
        returns (uint256 campaignID)
    {
        campaignID = numCampaign++;
        Campaign storage c = campaigns[campaignID];
        c.receiver = receiver;
        c.fundingGoal = goal;
    }

    function bid(uint256 campaignID)
        external
        payable
        judgeParticipate(campaignID)
    {
        Campaign storage c = campaigns[campaignID];
        c.totalAmount += msg.value;
        c.numFunders += 1;

        funders[campaignID].push(Funder({addr: msg.sender, amount: msg.value}));
    }

    function withdraw(uint256 campaignID) external returns (bool reached) {
        Campaign storage c = campaigns[campaignID];

        if (c.totalAmount < c.fundingGoal) {
            return false;
        }

        uint256 amount = c.totalAmount;
        c.totalAmount = 0;
        c.receiver.transfer(amount);
        return true;
    }
}
